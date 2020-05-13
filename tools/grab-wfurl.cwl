#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
inputs: []
stdout: echo_out
outputs:
  - id: cwl_wf_url
    type: string
baseCommand: []
arguments:
  - valueFrom: >
      echo '{"cwl_wf_url":"'"$WORKFLOW_URL"'"}' > cwl.output.json
    shellQuote: false
requirements:
  - class: ShellCommandRequirement
