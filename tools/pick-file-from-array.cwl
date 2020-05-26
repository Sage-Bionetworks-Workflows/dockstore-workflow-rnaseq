#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool
id: pick-file-from-array
label: Pick a single file from a file array
doc: Returns the first file that matches a regex from a file array.
$namespaces:
  dct: 'http://purl.org/dc/terms/'
  foaf: 'http://xmlns.com/foaf/0.1/'

requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: files
    type: File[]
  - id: regex
    type: string

expression: |
  ${
    
    // This script looks for the first file in the input array
    // that matches the input regex.

    if (inputs.files.length === 0) {
      throw new Error("'files' is empty.")
    }
    var regex = RegExp(inputs.regex)
    var the_file = inputs.files.find(function(item) {
      return regex.test(item.basename)
    })
    return { "file": the_file }
  }

outputs:
  - id: file
    type: File

'dct:creator':
  '@id': 'http://orcid.org/0000-0002-4475-8396'
  'foaf:name': 'Tess Thyer'
  'foaf:mbox': 'mailto:tess.thyer@sagebionetworks.org'
