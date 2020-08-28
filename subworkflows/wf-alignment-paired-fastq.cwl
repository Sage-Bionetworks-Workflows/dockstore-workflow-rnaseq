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
  - id: genstr
    type: string?
  - id: nthreads
    type: int
  - id: synapse_config
    type: File
  - id: synapseid
    type: string
  - id: synapseid_2
    type: string
  - id: sjdbGTFfile
    type: File?
  - id: alignEndsType
    type: string?
  - id: outFilterMismatchNmax
    type: int?
  - id: outFilterMultimapScoreRange
    type: int?
  - id: outFilterMultimapNmax
    type: int?
  - id: outFilterScoreMinOverLread
    type: int?
  - id: outFilterMatchNminOverLread
    type: int?
  - id: outFilterMatchNmin
    type: int?
  - id: alignSJDBoverhangMin
    type: int?
  - id: alignIntronMax
    type: int?

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
        source: zcat_1/output_uncompressed
      - id: mate_2_fastq
        source: zcat_2/output_uncompressed
      - id: genstr
        source: genstr
      - id: genome_dir
        source:
          - genome_dir
      - id: nthreads
        source: nthreads
      - id: output_dir_name
        source: synapseid
      - id: sjdbGTFfile
        source: sjdbGTFfile
      - id: alignEndsType
        source: alignEndsType
      - id: outFilterMismatchNmax
        source: outFilterMismatchNmax
      - id: outFilterMultimapScoreRange
        source: outFilterMultimapScoreRange
      - id: outFilterMultimapNmax
        source: outFilterMultimapNmax
      - id: outFilterScoreMinOverLread
        source: outFilterScoreMinOverLread
      - id: outFilterMatchNminOverLread
        source: outFilterMatchNminOverLread
      - id: outFilterMatchNmin
        source: outFilterMatchNmin
      - id: alignSJDBoverhangMin
        source: alignSJDBoverhangMin
      - id: alignIntronMax
        source: alignIntronMax
    out:
      - id: aligned_reads_sam
      - id: reads_per_gene
      - id: splice_junctions
      - id: logs
    run: https://raw.githubusercontent.com/Sage-Bionetworks-Workflows/dockstore-tool-star/v1.0.1/cwl/star_align.cwl
    label: STAR spliced alignment
    'sbg:x': 1044.3306884765625
    'sbg:y': 193
  - id: synapse_get_tool_1
    in:
      - id: synapse_config
        source: synapse_config
      - id: synapseid
        source: synapseid
    out:
      - id: filepath
    run: ../tools/synapse-get-tool.cwl
    'sbg:x': 310
    'sbg:y': -256
  - id: synapse_get_tool_2
    in:
      - id: synapse_config
        source: synapse_config
      - id: synapseid
        source: synapseid_2
    out:
      - id: filepath
    run: ../tools/synapse-get-tool.cwl
    'sbg:x': 310
    'sbg:y': -256
  - id: zcat_1
    in:
      - id: input_gzs
        source: synapse_get_tool_1/filepath
      - id: output_basename
        source: synapse_get_tool_1/filepath
        valueFrom: $(self.nameroot).txt
    out:
      - id: output_uncompressed
    run: ../tools/zcat.cwl
    'sbg:x': 534.0625
    'sbg:y': -348
  - id: zcat_2
    in:
      - id: input_gzs
        source: synapse_get_tool_2/filepath
      - id: output_basename
        source: synapse_get_tool_2/filepath
        valueFrom: $(self.nameroot).txt
    out:
      - id: output_uncompressed
    run: ../tools/zcat.cwl
    'sbg:x': 534.0625
    'sbg:y': -348
requirements:
  - class: ResourceRequirement
    ramMin: 60000
    coresMin: 15
    tmpdirMin: 225000
    outdirMin: 225000
'dct:creator':
  '@id': 'http://orcid.org/0000-0001-9758-0176'
  'foaf:mbox': 'mailto:james.a.eddy@gmail.com'
  'foaf:name': James Eddy
