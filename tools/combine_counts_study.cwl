#!/usr/bin/env cwl-runner

class: CommandLineTool
cwlVersion: v1.0
id: combine-counts
label: Combine read counts across samples

doc: |
  Combine individual sample count files into a gene x sample matrix file.

baseCommand: ['combine_counts_study.R']

requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: DockerRequirement
    dockerPull: 'wpoehlm/ngstools:star'

arguments:

  - prefix: --out_dir
    valueFrom: $(runtime.outdir)

inputs:

  - id: read_counts
    label: Read count files to combine
    type: File[]
    inputBinding:
      position: 0

  - id: output_prefix
    label: Output counts file prefix
    doc: |
      Prefix for output file (i.e., <prefix>_all_counts_matrix.txt).
    type: string
    default: gene
    inputBinding:
      position: 1
      prefix: --out_prefix

  - id: sample_suffix
    label: Suffix to remove from filename
    doc: |
      Suffix to strip from sample filename [default %(default)s].
    type: string
    default: "ReadsPerGene.out.tab"
    inputBinding:
      position: 2
      prefix: --sample_suffix

  - id: column_number
    label: Counts column number
    doc: |
      1-based index of counts column to select [default %(default)s].
    type: int
    default: 2
    inputBinding:
      position: 4
      prefix: --col_num

outputs:

  - id: combined_counts
    label: Combined counts matrix
    doc: Combined counts matrix saved as tab-delimited text file.
    type: File
    outputBinding:
      glob: "*_all_counts_matrix.txt"
