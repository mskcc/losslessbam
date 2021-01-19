#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: ExpressionTool
id: flatten-array-directory
requirements:
  - class: InlineJavascriptRequirement

inputs:

  directory_list:
    type:
      type: array
      items: Directory

outputs:

  output_directory: Directory

expression: "${ if (inputs.directory_list.length != 0) { return {'output_directory':inputs.directory_list[0]}; } else { return { 'output_directory': {'class': 'Directory','basename': 'empty','listing': []} }}; }"