#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool
baseCommand: [cmo_split_reads]
id: cmo-split-reads

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 24000
    coresMin: 1
  DockerRequirement:
    dockerPull: mskcc/roslin-variant-cmo-utils:1.9.15


doc: |
  split files into chunks based on filesize

inputs:
  fastq1:
    type: File
    doc: filename to split
    inputBinding:
      prefix: --fastq1

  fastq2:
    type: File
    doc: filename2 to split
    inputBinding:
      prefix: --fastq2

  platform_unit:
    type:

    - 'null'
    - string
    doc: RG/PU ID
    inputBinding:
      prefix: --platform-unit


outputs:

  chunks1:
    type:
      type: array
      items: File
    outputBinding:
      glob: |
        ${
          var pattern = inputs.platform_unit + "-" + inputs.fastq1.basename.split(".",1)[0].split('_').slice(1).join("-") + ".chunk*";
          return pattern
        }

  chunks2:
    type:
      type: array
      items: File
    outputBinding:
      glob: |
        ${
          var pattern = inputs.platform_unit + "-" + inputs.fastq2.basename.split(".",1)[0].split('_').slice(1).join("-") + ".chunk*";
          return pattern
        }
