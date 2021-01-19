#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: ExpressionTool
id: flatten-array-file
requirements:
  - class: InlineJavascriptRequirement

inputs:

  file_list:
    type:
      type: array
      items:
        type: array
        items: File

outputs:

  output_file_list:
    type:
      type: array
      items: File

expression: ${ var files = []; for (var i = 0; i < inputs.file_list.length; i++) { for (var j = 0; j < inputs.file_list[i].length; j++) { files.push(inputs.file_list[i][j]) } } return { "output_file_list":files }; }
