class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com'
id: upload_synapse
requirements:
  - class: DockerRequirement
    dockerPull: sagebionetworks/synapsepythonclient:v1.9.2
  - class: InitialWorkDirRequirement
    listing:
      - entryname: synstore.py
        entry: |-
          #!/usr/bin/env python3
          import argparse

          import synapseclient as sc
          from synapseclient.activity import Activity

          parser = argparse.ArgumentParser()
          parser.add_argument(
            '--file-paths',
            required=True,
            nargs='+',
            help='Files to store')
          parser.add_argument(
            '--parent',
            required=True,
            help='Synapse id of parent entity, the folder on synapse that will host the uploaded file')
          parser.add_argument(
            '--synapse-config',
            required=True,
            help='Synapse configuration file')
          parser.add_argument(
            '--used',
            required=True,
            help='URL for job arguments file')
          parser.add_argument(
            '--executed',
            required=True,
            help='URL for workflow')
          args = parser.parse_args()

          syn = sc.Synapse(configPath=args.synapse_config)
          syn.login()

          files = [
            sc.File(path=file_path, parent=args.parent)
            for file_path in args.file_paths]

          activity = Activity(
              name='amp-rna-seq_reprocess-workflow-run',
              description='Run of the amp-rna-seq_reprocess-workflow',
              used=[args.used],
              executed=args.executed)

          results = []
          for item in files:
              stored = syn.store(obj=item, activity=activity)
              results.append(stored)
              activity = syn.getProvenance(entity=stored['id'])

arguments: ['python3', 'synstore.py']
inputs:
  - id: infiles
    type: File[]
    inputBinding:
      prefix: '--file-paths'
  - id: synapse_parentid
    type: string
    inputBinding:
      prefix: '--parent'
  - id: synapseconfig
    type: File
    inputBinding:
      prefix: '--synapse-config'
  - id: argurl
    type: string
    inputBinding:
      prefix: '--used'
  - id: wfurl
    type: string
    inputBinding:
      prefix: '--executed'
outputs: []
label: upload_synapse.cwl


