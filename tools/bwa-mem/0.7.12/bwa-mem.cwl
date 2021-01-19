#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool
baseCommand:
- /usr/bin/bwa
- mem
id: bwa-mem

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 32000
    coresMin: 4
  DockerRequirement:
    dockerPull: mskcc/bwa_mem:0.7.12

label: "run bwa mem -t 6 -M"
doc: |
  bwa mem
    args set:
      -M
      -t 6

inputs:

  reference:
    type: File
    inputBinding:
      position: 1
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
      - .fai
      - ^.dict

  fastq1:
    type:
    - string
    - File
    inputBinding:
      position: 2

  fastq2:
    type:
    - string
    - File
    inputBinding:
      position: 2

  output:
    type: string

#
# Non-default args used: -M -t 6
#

  M:
    type: ['null', boolean]
    default: true
    doc: mark shorter split hits as secondary (for Picard/GATK compatibility)
    inputBinding:
      prefix: -M
      position: 0

  t:
    type: ['null', string]
    doc: INT number of threads [1]
    inputBinding:
      prefix: -t
      position: 0
    default: '6'

#
# Remaining arguments at default values unless
# explicitly set
#

  E:
    type: ['null', string]
    doc: INT gap extension penalty; a gap of size k cost {-O} + {-E}*k [1]
    inputBinding:
      prefix: -E
      position: 0

  d:
    type: ['null', string]
    doc: INT off-diagonal X-dropoff [100]
    inputBinding:
      prefix: -d
      position: 0

  A:
    type: ['null', string]
    doc: INT score for a sequence match [1]
    inputBinding:
      prefix: -A
      position: 0

  C:
    type: ['null', boolean]
    default: false
    doc: append FASTA/FASTQ comment to SAM output
    inputBinding:
      prefix: -C
      position: 0

  c:
    type: ['null', string]
    doc: INT skip seeds with more than INT occurrences [10000]
    inputBinding:
      prefix: -c
      position: 0

  B:
    type: ['null', string]
    doc: INT penalty for a mismatch [4]
    inputBinding:
      prefix: -B
      position: 0


  L:
    type: ['null', string]
    doc: INT penalty for clipping [5]
    inputBinding:
      prefix: -L
      position: 0

  O:
    type: ['null', string]
    doc: INT gap open penalty [6]
    inputBinding:
      prefix: -O
      position: 0

  R:
    type: ['null', string]
    doc: STR read group header line such as '@RG\tID -foo\tSM -bar' [null]
    inputBinding:
      prefix: -R
      position: 0

  k:
    type: ['null', string]
    doc: INT minimum seed length [19]
    inputBinding:
      prefix: -k
      position: 0

  U:
    type: ['null', string]
    doc: INT penalty for an unpaired read pair [17]
    inputBinding:
      prefix: -U
      position: 0


  w:
    type: ['null', string]
    doc: INT band width for banded alignment [100]
    inputBinding:
      prefix: -w
      position: 0

  v:
    type: ['null', string]
    doc: INT verbose level - 1=error, 2=warning, 3=message, 4+=debugging [3]
    inputBinding:
      prefix: -v
      position: 0

  T:
    type: ['null', string]
    doc: INT minimum score to output [30]
    inputBinding:
      prefix: -T
      position: 0

  P:
    type: ['null', boolean]
    default: false
    doc: skip pairing; mate rescue performed unless -S also in use
    inputBinding:
      prefix: -P
      position: 0

  S:
    type: ['null', boolean]
    default: false
    doc: skip mate rescue
    inputBinding:
      prefix: -S
      position: 0

  r:
    type: ['null', string]
    doc: FLOAT look for internal seeds inside a seed longer than {-k} * FLOAT [1.5]
    inputBinding:
      prefix: -r
      position: 0

  a:
    type: ['null', boolean]
    default: false
    doc: output all alignments for SE or unpaired PE
    inputBinding:
      prefix: -a
      position: 0

  p:
    type: ['null', string]
    doc: first query file consists of interleaved paired-end sequences
    inputBinding:
      prefix: -p
      position: 0

stdout: $(inputs.output)
outputs:
  sam:
    type: File
    outputBinding:
      glob: |-
        ${
          if (inputs.output)
            return inputs.output;
          return null;
        }
