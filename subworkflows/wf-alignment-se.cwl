class: Workflow
cwlVersion: v1.0
id: wf_alignment
doc: |
  Align RNA-seq data for each sample using STAR.
label: Alignment sub-workflow
$namespaces:
  dct: 'http://purl.org/dc/terms/'
  foaf: 'http://xmlns.com/foaf/0.1/'
  sbg: 'https://www.sevenbridges.com/'
inputs:
  - id: genome_dir
    type: 'File[]'
    'sbg:x': 769.881103515625
    'sbg:y': 321
  - id: genstr
    type: string?
  - id: nthreads
    type: int
    'sbg:x': 739.2590942382812
    'sbg:y': 152.51564025878906
  - id: synapse_config
    type: File
    'sbg:x': 0
    'sbg:y': 107
  - id: synapseid
    type: string
    'sbg:x': 0
    'sbg:y': 0
outputs:
  - id: splice_junctions
    outputSource:
      - star_align/splice_junctions
    type: File
    'sbg:x': 1399.3011474609375
    'sbg:y': 53.5
  - id: reads_per_gene
    outputSource:
      - star_align/reads_per_gene
    type: File
    'sbg:x': 1399.3011474609375
    'sbg:y': 267.5
  - id: logs
    outputSource:
      - star_align/logs
    type: File
    'sbg:x': 1399.3011474609375
    'sbg:y': 374.5
  - id: realigned_reads_sam
    outputSource:
      - star_align/aligned_reads_sam
    type: File
    'sbg:x': 1410.3011474609375
    'sbg:y': 504.5
steps:
  - id: star_align
    in:
      - id: mate_1_fastq
        source: zcat/output_uncompressed
      - id: genstr
        source: genstr
      - id: genome_dir
        source:
          - genome_dir
      - id: nthreads
        source: nthreads
      - id: output_dir_name
        source: synapseid
    out:
      - id: aligned_reads_sam
      - id: reads_per_gene
      - id: splice_junctions
      - id: logs
    run: steps/star_align-se.cwl
    label: STAR spliced alignment
    'sbg:x': 1044.3306884765625
    'sbg:y': 193
  - id: synapse_get_tool
    in:
      - id: synapse_config
        source: synapse_config
      - id: synapseid
        source: synapseid
    out:
      - id: filepath
    run: steps/synapse-get-tool.cwl
    'sbg:x': 310
    'sbg:y': -256
  - id: zcat
    in:
      - id: input_gzs
        source: synapse_get_tool/filepath
      - id: output_basename
        source: synapse_get_tool/filepath
        valueFrom: $(self.nameroot).txt
    out:
      - id: output_uncompressed
    run: steps/zcat.cwl
    'sbg:x': 534.0625
    'sbg:y': -348
requirements: []
'dct:creator':
  '@id': 'http://orcid.org/0000-0001-9758-0176'
  'foaf:mbox': 'mailto:james.a.eddy@gmail.com'
  'foaf:name': James Eddy
