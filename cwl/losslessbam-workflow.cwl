#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
id: sample-workflow
requirements:
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  sample:
    type:
      type: record
      fields:
        CN: string
        LB: string
        ID: string
        PL: string
        PU: string[]
        R1: File[]
        R2: File[]
        bam: File[]
        RG_ID: string[]
        bwa_output: string
  ref_fasta:
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
      - ^.dict

  genome: string


outputs:
  output_file:
    type: File
    outputSource: merge_bams/output_file

    # outputBinding:
    #   glob: '*merged.bam'

steps:
  get_sample_info:
      in:
        sample: sample
      out: [ CN,LB,ID,PL,PU,R1,R2,bam,RG_ID,bwa_output]
      run:
          class: ExpressionTool
          id: get_sample_info
          inputs:
            sample:
              type:
                type: record
                fields:
                  CN: string
                  LB: string
                  ID: string
                  PL: string
                  PU: string[]
                  R1: File[]
                  R2: File[]
                  bam: File[]
                  RG_ID: string[]
                  bwa_output: string
          outputs:
            CN: string
            LB: string
            ID: string
            PL: string
            PU: string[]
            R1: File[]
            R2: File[]
            bam: File[]
            RG_ID: string[]
            bwa_output: string
          expression: "${ var sample_object = {};
            for(var key in inputs.sample){
              sample_object[key] = inputs.sample[key]
            }
            return sample_object;
          }"

  chunking:
    run: ../argos-cwl/tools/cmo-utils/1.9.15/cmo-split-reads.cwl
    in:
      fastq1:
        source: [get_sample_info/R1]#, consolidate_reads/r1]
        linkMerge: merge_flattened
      fastq2:
        source: [get_sample_info/R2]#, consolidate_reads/r2]
        linkMerge: merge_flattened
      platform_unit: get_sample_info/PU
    out: [chunks1, chunks2]
    scatter: [fastq1, fastq2, platform_unit]
    scatterMethod: dotproduct

  flatten:
    run: ../argos-cwl/tools/flatten-array/1.0.0/flatten-array-fastq.cwl
    in:
      fastq1: chunking/chunks1
      fastq2: chunking/chunks2
      add_rg_ID: get_sample_info/RG_ID
      add_rg_PU: get_sample_info/PU
    out:
      [chunks1, chunks2, rg_ID, rg_PU]
  align:
    in:
      ref_fasta: ref_fasta
      chunkfastq1: flatten/chunks1
      chunkfastq2: flatten/chunks2
      genome: genome
      bwa_output: get_sample_info/bwa_output
      add_rg_LB: get_sample_info/LB
      add_rg_PL: get_sample_info/PL
      add_rg_ID: flatten/rg_ID
      add_rg_PU: flatten/rg_PU
      add_rg_SM: get_sample_info/ID
      add_rg_CN: get_sample_info/CN
    scatter: [chunkfastq1, chunkfastq2, add_rg_ID, add_rg_PU]
    scatterMethod: dotproduct
    out: [bam]
    run:
      class: Workflow
      id: alignment_sample
      inputs:
        ref_fasta: File
        chunkfastq1: File
        chunkfastq2: File
        genome: string
        bwa_output: string
        add_rg_LB: string
        add_rg_PL: string
        add_rg_ID: string
        add_rg_PU: string
        add_rg_SM: string
        add_rg_CN: string
      outputs:
        bam:
          type: File
          outputSource: add_rg_id/bam

      steps:
        bwa:
          run: ../argos-cwl/tools/bwa-mem/0.7.12/bwa-mem.cwl
          in:
            reference: ref_fasta
            fastq1: chunkfastq1
            fastq2: chunkfastq2
            basebamname: bwa_output
            output:
              valueFrom: ${ return inputs.basebamname.replace(".bam", "." + inputs.fastq1.basename.match(/chunk\d\d\d/)[0] + ".sam");}
            genome: genome
          out: [sam]
        sam_to_bam:
          run: ../argos-cwl/tools/samtools.view/1.3.1/samtools.view.cwl
          in:
            input: bwa/sam
            isbam:
              valueFrom: ${ return true; }
            samheader:
              valueFrom: ${ return true; }
          out: [output_bam]
        add_rg_id:
          run: ../argos-cwl/tools/picard.AddOrReplaceReadGroups/2.9/picard.AddOrReplaceReadGroups.cwl
          in:
            I: sam_to_bam/output_bam
            O:
              valueFrom: ${ return inputs.I.basename.replace(".bam", ".rg.bam") }
            LB: add_rg_LB
            PL: add_rg_PL
            ID: add_rg_ID
            PU: add_rg_PU
            SM: add_rg_SM
            CN: add_rg_CN
            SO:
              default: "coordinate"
          out: [bam, bai]
  merge_bams:
    run: ../argos-cwl/tools/samtools.merge/1.9/samtools.merge.cwl
    in:
      input_bams: align/bam
    out:
    - id: output_file
