#! /usr/bin/env bash

if [[ -z "$1" ]]; then
    echo "Missing argument: job directory"
    exit 1
fi

DIR=$1

if [[ ! -d "$DIR" ]]; then
    echo "Directory $DIR does not exist" 
    exit 1
fi

if [[ ! -f "$DIR/job.json" ]]; then
    echo "job.json file missing from $DIR"
    exit 1
fi

if [[ -z "$2" ]]; then
    echo "Missing argument: main workflow"
    exit 1
fi

WF=$2

echo "Running job defined in $DIR"
cwl-runner \
  --verbose \
  --preserve-environment WORKFLOW_URL \
  --preserve-environment CWL_ARGS_URL \
  --tmpdir-prefix tmp/cwl \
  --tmp-outdir-prefix tmp/cwl-out \
  "$WF" "$DIR"/job.json

