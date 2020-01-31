class: CommandLineTool
cwlVersion: v1.0
id: cellranger aggr
baseCommand: ['cellranger', 'aggr']
inputs:
  - id: molecule_h5
    type: File[]
  - id: sample_csv
    type: File
outputs:
  - id: combined_output
    type: File
    outputBinding:
      glob: 'combined/combined.mri.tgz'
label: cellranger aggr
arguments:
  - position: 1
    prefix: '--id='
    separate: false
    valueFrom: combined
  - position: 2
    prefix: '--csv='
    separate: false
    valueFrom: $(inputs.sample_csv)
requirements:
  - class: DockerRequirement
    dockerPull: sagebionetworks/cellranger
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.sample_csv)
      - $(inputs.molecule_h5)
