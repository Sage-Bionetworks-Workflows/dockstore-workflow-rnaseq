cwlVersion: v1.0
class: CommandLineTool

baseCommand: 'zcat'
stdout: "$(inputs.output_basename)"

requirements:
  - class: InlineJavascriptRequirement

inputs:

  - id: input_gzs
    label: Input gzipped file
    type: File
    inputBinding:
      position: 1

  - id: output_basename
    type: string

outputs:

  - id: output_uncompressed
    label: uncompressed file
    type: File
    outputBinding:
      glob: "$(inputs.output_basename)"

