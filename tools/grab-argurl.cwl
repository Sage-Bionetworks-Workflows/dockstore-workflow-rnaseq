#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
inputs: []
stdout: echo_out
outputs:
  - id: cwl_args_url
    type: string
baseCommand: []
arguments:
  - valueFrom: >
      echo '{"cwl_args_url":"'"$CWL_ARGS_URL"'"}' > cwl.output.json
    shellQuote: false
requirements:
  - class: ShellCommandRequirement
