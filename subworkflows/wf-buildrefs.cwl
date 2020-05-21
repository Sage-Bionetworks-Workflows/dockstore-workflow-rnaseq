class: Workflow
cwlVersion: v1.0
label: Reference building sub-workflow
doc: |
  Build and format reference files for metrics tools.
$namespaces:
  dct: 'http://purl.org/dc/terms/'
  foaf: 'http://xmlns.com/foaf/0.1/'
  sbg: 'https://www.sevenbridges.com/'
inputs:
  - id: genemodel_gtf
    type: File
    'sbg:x': -550
    'sbg:y': -208
  - id: aligned_reads_sam
    type: File
    'sbg:x': -552
    'sbg:y': -72
outputs:
  - id: picard_riboints
    outputSource:
      - prep_riboints/picard_riboints
    type: File
    'sbg:x': -119
    'sbg:y': -79
  - id: picard_refflat
    outputSource:
      - prep_refflat/picard_refflat
    type: File
    'sbg:x': -115
    'sbg:y': -220
steps:
  - id: prep_refflat
    in:
      - id: genemodel_gtf
        source: genemodel_gtf
    out:
      - id: picard_refflat
    run: steps/prep_refflat.cwl
    label: Build Picard refFlat
    'sbg:x': -322
    'sbg:y': -236
  - id: prep_riboints
    in:
      - id: genemodel_gtf
        source: genemodel_gtf
      - id: aligned_reads_sam
        source: aligned_reads_sam
    out:
      - id: picard_riboints
    run: steps/prep_riboints.cwl
    label: Build Picard ribosomal intervals
    'sbg:x': -319
    'sbg:y': -59
requirements:
  - class: StepInputExpressionRequirement
  - class: ResourceRequirement
    $mixin: resources-buildrefs.yaml
'dct:creator':
  '@id': 'http://orcid.org/0000-0001-9758-0176'
  'foaf:mbox': 'mailto:james.a.eddy@gmail.com'
  'foaf:name': James Eddy
