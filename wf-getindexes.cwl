class: Workflow
cwlVersion: v1.0
id: wf-getindexes
doc: |
  Retrieve genome and transcriptome indexes
inputs:
  - id: synapse_config
    type: File
  - id: synapseid
    type: string
outputs:
  - id: files
    type: File[]
    outputSource: convert_dir/files
  - id: genome_fasta
    type: File
    outputSource: pick_fasta/file
  - id: genemodel_gtf
    type: File
    outputSource: pick_gtf/file
steps:
  - id: syn_get_index
    in:
      - id: synapse_config
        source: synapse_config
      - id: synapseid
        source: synapseid
    out:
      - id: output_dir
    run: steps/synapse-recursive-get-tool.cwl
    label: Download Index Files from Synapse
  - id: convert_dir
    in:
      - id: dir
        source: syn_get_index/output_dir
    out:
      - id: files
    run: steps/directory-to-file-list-tool.cwl
    label: Convert Directory to File List
  - id: pick_fasta
    in:
      - id: files
        source: convert_dir/files
      - id: regex
        default: ".fa$"
    out:
      - id: file
    run: steps/pick-file-from-array.cwl
    label: Isolate the fasta file from the index array
  - id: pick_gtf
    in:
      - id: files
        source: convert_dir/files
      - id: regex
        default: ".gtf$"
    out:
      - id: file
    run: steps/pick-file-from-array.cwl
    label: Isolate the gtf file from the index array
requirements: 
  - class: StepInputExpressionRequirement
  - class: ResourceRequirement
    $mixin: resources-getindexes.yaml

