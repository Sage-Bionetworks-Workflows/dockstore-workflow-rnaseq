class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com'
id: sample_provenance
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
arguments: ['python3', 'provenance.py']
hints:
  - class: DockerRequirement
    dockerPull: sagebionetworks/synapsepythonclient:v1.9.2
requirements:
  - class: InitialWorkDirRequirement
    listing:
      - entryname: provenance.py
        entry: |-
          #!/usr/bin/env python

          import json
          import os
          import logging
          import requests
          import synapseclient as sc
          import sys

          from requests.adapters import HTTPAdapter
          from requests.packages.urllib3.util.retry import Retry

          # synapse config file
          synconf = sys.argv[1]
          #url to job.json file
          joburl = sys.argv[2]

          # Retrieve the data in the input job.json file
          s = requests.Session()
          retries = Retry(total=5, backoff_factor=1, status_forcelist=[ 502, 503, 504 ])
          s.mount('http://', HTTPAdapter(max_retries=retries))
          print('Retrieve job.json file from url:', joburl)
          response = s.get(joburl)
          try:
            data = response.json()
          except json.decoder.JSONDecodeError as e:
            print('Decoding JSON failed:', e)
            print('Response status:', response.status_code, response.reason)
            sys.exit(1)

          # Login to synapse using credentials in synapse config file
          syn = sc.Synapse(configPath=synconf)
          syn.login()

          # Print header of provenance file
          print('id' + ',' + 'versionNumber' + ',' +  'specimenID', file=open('provenance.csv', 'a'))

          # Iterate through input bam files and retrieve specimen ids and version numbers
          for item in data['synapseid']:
              version = (syn.get(item, downloadFile=False).versionNumber)
              annotations = syn.getAnnotations(item)
              if annotations:
                  specimen = annotations['specimenID'][0]
              else:
                  specimen = "NA"
              print(item + ',' + str(version) + ',' +  specimen, file=open('provenance.csv','a'))


          # Get list of synapse IDs in the genome folder and retrieve specimen ids and version numbers
          synlist = []
          indexfolder = data['index_synapseid']
          reffiles = syn.getChildren(parent=indexfolder, includeTypes=['file'])
          for item in reffiles:
              synlist.append(item['id'])


          for item in synlist:
              version = (syn.get(item, downloadFile=False).versionNumber)
              annotations = syn.getAnnotations(item)
              if annotations:
                  specimen = annotations['specimenID'][0]
              else:
                  specimen = "NA"
              print(item + ',' + str(version) + ',' +  specimen, file=open('provenance.csv','a'))
