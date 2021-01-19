#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool
id: picard-AddOrReplaceReadGroups

baseCommand:
  - java
arguments:
- valueFrom: "/usr/bin/picard-tools/picard.jar"
  prefix: "-jar"
  position: 1
  shellQuote: false
- valueFrom: "AddOrReplaceReadGroups"
  position: 1
  shellQuote: false
- valueFrom: "-Xms$(Math.round(parseInt(runtime.ram)/1910))G"
  position: 0
  shellQuote: false
- valueFrom: "-Xmx$(Math.floor(parseInt(runtime.ram)/1048) - 1)G"
  position: 0
  shellQuote: false
- valueFrom: "-XX:-UseGCOverheadLimit"
  position: 0
  shellQuote: false
- valueFrom: "-Djava.io.tmpdir=$(runtime.tmpdir)"
  position: 0
  shellQuote: false
- valueFrom: "TMP_DIR=$(runtime.tmpdir)"
  position: 2
  shellQuote: false

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 25000
    coresMin: 1
  DockerRequirement:
    dockerPull: mskcc/roslin-variant-picard:2.9

doc: |
  None

inputs:

  I:
    type: File
    inputBinding:
      prefix: I=
      position: 2
      separate: false
  O:
    type: string
    doc: Output file (BAM or SAM). Required.
    inputBinding:
      prefix: O=
      position: 2
      separate: false

  SO:
    type: ['null', string]
    doc: Optional sort order to output in. If not supplied OUTPUT is in the same order
      as INPUT. Default value - null. Possible values - {unsorted, queryname, coordinate,
      duplicate, unknown}
    inputBinding:
      prefix: SO=
      position: 2
      separate: false

  ID:
    type: ['null', string]
    doc: Read Group ID Default value - 1. This option can be set to 'null' to clear
      the default value.
    inputBinding:
      prefix: ID=
      position: 2
      separate: false

  LB:
    type: string
    doc: Read Group library Required.
    inputBinding:
      prefix: LB=
      position: 2
      separate: false

  PL:
    type: string
    doc: Read Group platform (e.g. illumina, solid) Required.
    inputBinding:
      prefix: PL=
      position: 2
      separate: false

  PU:
    type: string
    doc: Read Group platform unit (eg. run barcode) Required.
    inputBinding:
      prefix: PU=
      position: 2
      separate: false

  SM:
    type: string
    doc: Read Group sample name Required.
    inputBinding:
      prefix: SM=
      position: 2
      separate: false

  CN:
    type: ['null', string]
    doc: Read Group sequencing center name Default value - null.
    inputBinding:
      prefix: CN=
      position: 2
      separate: false

  DS:
    type: ['null', string]
    doc: Read Group description Default value - null.
    inputBinding:
      prefix: DS=
      position: 2
      separate: false

  DT:
    type: ['null', string]
    doc: Read Group run date Default value - null.
    inputBinding:
      prefix: DT=
      position: 2
      separate: false

  KS:
    type: ['null', string]
    doc: Read Group key sequence Default value - null.
    inputBinding:
      prefix: KS=
      position: 2
      separate: false

  FO:
    type: ['null', string]
    doc: Read Group flow order Default value - null.
    inputBinding:
      prefix: FO=
      position: 2
      separate: false

  PI:
    type: ['null', string]
    doc: Read Group predicted insert size Default value - null.
    inputBinding:
      prefix: PI=
      position: 2
      separate: false

  PG:
    type: ['null', string]
    doc: Read Group program group Default value - null.
    inputBinding:
      prefix: PG=
      position: 2
      separate: false

  PM:
    type: ['null', string]
    doc: Read Group platform model Default value - null.
    inputBinding:
      prefix: PM=
      position: 2
      separate: false

  QUIET:
    type: ['null', boolean]
    default: false
    inputBinding:
      prefix: QUIET=True
      position: 2

  CREATE_MD5_FILE:
    type: ['null', boolean]
    default: false
    inputBinding:
      prefix: CREATE_MD5_FILE=True
      position: 2

  CREATE_INDEX:
    type: ['null', boolean]
    default: true
    inputBinding:
      prefix: CREATE_INDEX=True
      position: 2

  VERBOSITY:
    type: ['null', string]
    inputBinding:
      prefix: VERBOSITY=
      position: 2
      separate: false

  VALIDATION_STRINGENCY:
    type: ['null', string]
    inputBinding:
      prefix: VALIDATION_STRINGENCY=
      position: 2
      separate: false

  COMPRESSION_LEVEL:
    type: ['null', string]
    inputBinding:
      prefix: COMPRESSION_LEVEL=
      position: 2
      separate: false

  MAX_RECORDS_IN_RAM:
    type: ['null', string]
    inputBinding:
      prefix: MAX_RECORDS_IN_RAM=
      position: 2
      separate: false


outputs:
  bam:
    type: File
    outputBinding:
      glob: |
        ${
          if (inputs.O)
            return inputs.O;
          return null;
        }
  bai:
    type: File?
    outputBinding:
      glob: |-
        ${
          if (inputs.O)
            return inputs.O.replace(/^.*[\\\/]/, '').replace(/\.[^/.]+$/, '').replace(/\.bam/,'') + ".bai";
          return null;
        }
