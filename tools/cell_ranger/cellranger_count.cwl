class: CommandLineTool
cwlVersion: v1.0
id: cellranger count
baseCommand: ['cellranger', 'count']
inputs:
  - id: fastq_dir
    type: Directory
  - id: genome_dir
    type: Directory
  - id: chemistry
    type: string?
    default: threeprime
outputs:
  - id: output
    type: File
    outputBinding:
      glob: '$(inputs.fastq_dir.basename)/outs/molecule_info.h5'
      outputEval: |
        ${
          self[0].basename = inputs.fastq_dir.basename + '_molecule_info.h5';
          return self[0]
        }
label: cellr_count
arguments:
  - position: 1
    prefix: '--id='
    separate: false
    valueFrom: $(inputs.fastq_dir.basename)
  - position: 2
    prefix: '--fastqs='
    separate: false
    valueFrom: $(inputs.fastq_dir)
  - position: 3
    prefix: '--transcriptome='
    separate: false
    valueFrom: $(inputs.genome_dir)
  - position: 4
    prefix: '--chemistry='
    separate: false
    valueFrom: $(inputs.chemistry)
  - position: 5
    prefix: '--sample='
    separate: false
    valueFrom: $(inputs.fastq_dir.basename)
requirements:
  - class: DockerRequirement
    dockerPull: sagebionetworks/cellranger
  - class: InlineJavascriptRequirement

