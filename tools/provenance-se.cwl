class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com'
id: sample_provenance
baseCommand:
  - provenance-se.py
inputs:
  - id: synapseconfig
    type: File
    inputBinding:
      position: 1
  - id: argurl
    type: string
    inputBinding:
      position: 2
outputs:
  - id: provenance_csv
    type: File
    outputBinding:
      glob: '*csv'
label: provenance.cwl
hints:
  - class: DockerRequirement
    dockerPull: 'wpoehlm/ngstools:pyscript-b66e489'
