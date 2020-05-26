#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool
id: directory-to-file-list
label: Transform Directory type to File type
doc: Convert a directory type input to a file array output.
$namespaces:
  dct: 'http://purl.org/dc/terms/'
  foaf: 'http://xmlns.com/foaf/0.1/'
  
requirements:
  - class: InlineJavascriptRequirement

inputs:
  - id: dir
    type: Directory
  - id: recurse
    type: boolean?
    default: false
expression: |
  ${

    // Adds only items of class "File" to the filtered array
    // If a "Directory" is encountered, and recurse is selected,
    // look for files in there as well.

    var filtered = []

    function filesFromDir(dir) {
      for (var n in dir.listing) {
        var item = dir.listing[n]
        if (item.class == "File"){
          filtered.push(item)
        } else if (item.class == "Directory" && inputs.recurse) {
          filesFromDir(item)
        }
      } 
    }

    filesFromDir(inputs.dir)
    
    return { "files": filtered }
  }

outputs:
  - id: files
    type: File[]

'dct:creator':
  '@id': 'http://orcid.org/0000-0002-4475-8396'
  'foaf:name': 'Tess Thyer'
  'foaf:mbox': 'mailto:tess.thyer@sagebionetworks.org'
