class: Workflow
cwlVersion: v1.0
id: main_paired
label: main-paired
$namespaces:
  sbg: 'https://www.sevenbridges.com'
inputs:
  - id: cwl_wf_url
    type: string
  - id: cwl_args_url
    type: string
  - id: index_synapseid
    type: string
  - id: synapse_config
    type: File
  - id: synapseid
    type: 'string[]'
  - id: synapseid_2
    type: 'string[]'
  - id: nthreads
    type: int
  - id: genstr
    type: string?
  - id: output_metrics_filename
    type: string?
  - id: synapse_parentid
    type: string
  - id: strand_specificity
    type: string?
  - id: column_number
    type: int?
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
  - id: clean_counts
    outputSource:
      - clean_tables/clean_counts
    type: File
  - id: clean_log
    outputSource:
      - clean_tables/clean_log
    type: File
  - id: clean_metrics
    outputSource:
      - clean_tables/clean_metrics
    type: File
steps:
  - id: input_provenance
    in:
      - id: argurl
        source: cwl_args_url
      - id: synapseconfig
        source: synapse_config
    out:
      - id: provenance_csv
    run: tools/provenance-paired.cwl
    label: gather sample provenance
    doc: capture the version numbers of input files on Synapse
  - id: wf_getindexes
    in:
      - id: synapseid
        source: index_synapseid
      - id: synapse_config
        source: synapse_config
    out:
      - id: files
      - id: genome_fasta
      - id: genemodel_gtf
    run: subworkflows/wf-getindexes.cwl
    label: Get index files
    doc: download the indexed reference genome
  - id: wf_alignment
    in:
      - id: genome_dir
        source: wf_getindexes/files
      - id: genstr
        source: genstr
      - id: nthreads
        source: nthreads
      - id: synapse_config
        source: synapse_config
      - id: synapseid
        source: synapseid
      - id: synapseid_2
        source: synapseid_2
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
      - id: splice_junctions
      - id: reads_per_gene
      - id: logs
      - id: realigned_reads_sam
    run: subworkflows/wf-alignment-paired-fastq.cwl
    label: Alignment sub-workflow
    doc: run the alignment sub-workflow
    scatter:
      - synapseid
      - synapseid_2
    scatterMethod: dotproduct
    'sbg:x': -310.91680908203125
    'sbg:y': -200.39964294433594
  - id: wf_buildrefs
    in:
      - id: genemodel_gtf
        source: wf_getindexes/genemodel_gtf
      - id: aligned_reads_sam
        source: wf_alignment/realigned_reads_sam
        valueFrom: $(self[0])
    out:
      - id: picard_riboints
      - id: picard_refflat
    run: subworkflows/wf-buildrefs.cwl
    label: Reference building sub-workflow
    doc: run the subworkflow that builds reference files for picard tools
    'sbg:x': -516
    'sbg:y': 12
  - id: wf_metrics
    in:
      - id: genome_fasta
        source: wf_getindexes/genome_fasta
      - id: aligned_reads_sam
        source: wf_alignment/realigned_reads_sam
      - id: picard_refflat
        source: wf_buildrefs/picard_refflat
      - id: picard_riboints
        source: wf_buildrefs/picard_riboints
      - id: basef
        source: synapseid
      - id: output_metrics_filename
        source: output_metrics_filename
      - id: strand_specificity
        source: strand_specificity
    out:
      - id: combined_metrics_csv
    run: subworkflows/wf-metrics.cwl
    label: Metrics sub-workflow
    doc: run the metrics subworkflow
    scatter:
      - aligned_reads_sam
      - basef
    scatterMethod: dotproduct
    'sbg:x': 128
    'sbg:y': -185
  - id: combine_counts
    in:
      - id: read_counts
        source:
          - wf_alignment/reads_per_gene
      - id: column_number
        source: column_number
    out:
      - id: combined_counts
    run: https://raw.githubusercontent.com/Sage-Bionetworks-Workflows/dockstore-tool-star/v1.0.0/cwl/combine_counts_study.cwl
    label: Combine read counts across samples
    doc: combine read counts across all samples
    'sbg:x': -63.8984375
    'sbg:y': 31.5
  - id: combine_metrics
    in:
      - id: picard_metrics
        source:
          - wf_metrics/combined_metrics_csv
    out:
      - id: combined_metrics
    run: https://raw.githubusercontent.com/Sage-Bionetworks-Workflows/dockstore-tool-picardtools/v1.0.1/cwl/combine_metrics_study.cwl
    label: Combine Picard metrics across samples
    doc: combine picard metrics across all samples
    'sbg:x': 343.8936767578125
    'sbg:y': -158.5
  - id: merge_starlog
    in:
      - id: logs
        source:
          - wf_alignment/logs
    out:
      - id: starlog_merged
    run: https://raw.githubusercontent.com/Sage-Bionetworks-Workflows/dockstore-tool-rnaseq-utils/v1.0.0/cwl/merge_starlog.cwl
    label: merge_starlog
    doc: merge STAR log files into a single table
    'sbg:x': -132.7860107421875
    'sbg:y': 294.5
  - id: synapse_upload
    in:
      - id: infiles
        source:
          - merge_starlog/starlog_merged
          - input_provenance/provenance_csv
          - combine_counts/combined_counts
          - combine_metrics/combined_metrics
      - id: synapse_parentid
        source: synapse_parentid
      - id: synapseconfig
        source: synapse_config
      - id: argurl
        source: cwl_args_url
      - id: wfurl
        source: cwl_wf_url
    out: []
    run: tools/upload_synapse.cwl
    doc: upload output files to Synapse
  - id: clean_tables
    in:
      - id: count_table
        source: combine_counts/combined_counts
      - id: star_table
        source: merge_starlog/starlog_merged
      - id: metric_table
        source: combine_metrics/combined_metrics
      - id: provenance_csv
        source: input_provenance/provenance_csv
    out:
      - id: clean_counts
      - id: clean_log
      - id: clean_metrics
    run: https://raw.githubusercontent.com/Sage-Bionetworks-Workflows/dockstore-tool-rnaseq-utils/v1.0.0/cwl/clean_tables.cwl
    doc: clean output tables and convert Synapse ID's to specimen ID's
  - id: clean_upload
    in:
      - id: infiles
        source:
          - clean_tables/clean_counts
          - clean_tables/clean_log
          - clean_tables/clean_metrics
      - id: synapse_parentid
        source: synapse_parentid
      - id: synapseconfig
        source: synapse_config
      - id: argurl
        source: cwl_args_url
      - id: wfurl
        source: cwl_wf_url
    out: []
    run: tools/upload_synapse.cwl
    doc: upload the cleaned tables to Synapse
requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
