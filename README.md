# dockstore-workflow-rnaseq

A workflow for processing bulk RNA Sequencing datasets.

# Description

This workflow automates and standardizes the processing of bulk RNASeq datasets. The following steps are performed:

* Download input BAM alignment files using the [Synapse Client](https://python-docs.synapse.org//build/html/CommandLineClient.html)
* Sort input BAM alignment files using [Picard SortSam](https://broadinstitute.github.io/picard/command-line-overview.html#SortSam)
* Convert sorted BAM files into FastQ files using [Picard SamToFastQ](https://broadinstitute.github.io/picard/command-line-overview.html#SamToFastq)
* Align reads to the reference genome using the [STAR Aligner](https://github.com/alexdobin/STAR)
* Generate raw gene expression counts using the [STAR Aligner](https://github.com/alexdobin/STAR) --quantMode (similar to the HTSeq algorithm)
* Collect RNASeq metrics from re-aligned bam files using [Picard CollectRNASeqMetrics](https://broadinstitute.github.io/picard/command-line-overview.html#CollectRnaSeqMetrics)
* Collect Alignment summary statistics from re-aligned bam files using [Picard AlignmentSummaryMetrics](https://broadinstitute.github.io/picard/command-line-overview.html#CollectAlignmentSummaryMetrics)

## CWL

Three main workflows are present in the root of this repository:

* [bam_paired.cwl](bam_paired.cwl): This workflow processes input BAM files from paired-end sequencing reads
* [fastq_paired.cwl](fastq_paired.cwl): This workflow processes paired end fastq files
* [fastq_single.cwl](fastq_single.cwl): This workflow processes single end fastq files
* [mirna_single.cwl](mirna_single.cwl): This workflow processes single-end fastq files from miRNA libraries 

Subworkflows that the main workflows utilize are present in the [subworkflows](subworkflows) folder. 


#### cwltool execution

The run-cwltool.sh script can be used to execute a workflow on a single compute instance using [cwltool](https://pypi.org/project/cwltool/1.0.20160325210917/). Two arguments must be provided:

* A path to your job directory
* The main workflow file that you want to run

For example, to run the paired-end BAM workflow, you can execute the following command from the base directory:

```bash
./utils/run-cwltool.sh jobs/test-paired-bam bam_paired.cwl
```

#### toil execution 

[Toil](https://toil.readthedocs.io/en/latest/) is a workflow engine that can execute CWL workflows in the cloud or other compute infrastructures. We have provided a [script](utils/run-toil.py) that can be used to submit workflows on a [Toil Cluster](https://toil.readthedocs.io/en/latest/running/cloud/amazon.html#details-about-launching-a-cluster-in-aws) in AWS. To run the script:

- ssh to toil cluster leader node
- from this directory (presuming the git repo was cloned to the leader),
- choose a job directory, for example, `jobs/test-paired-bam`
- execute toil run script: `./utils/run-toil.py jobs/test-paired-bam`

Run `./utils/run-toil.py -h` to see more options. Note that there is a `--dry-run`
option, which can help you to become familiar with the tool.

### How to Add More Jobs
To add a new job, create a new directory under `jobs`.

Each job directory requires an `options.json`, the set of options used by toil.
The `options.json` in `jobs/default` contains default options. Additional ones
can be added (or overwritten) in your job directory's `options.json`. The
`run-toil.py` script will warn you if any are missing.

Each job directory also requires a `job.json`. This contains the arguments that
are supplied to the CWL that you specify in your `options.json`.

For examples of both `options.json` and `job.json`, see `jobs/test-paired-bam`.

## Required Job Inputs

Each workflow requires the following inputs:

* `cwl_wf_url`: A URL that points to a commit or tagged version of this github repository at the time of job submission. "https://github.com/Sage-Bionetworks-Workflows/dockstore-workflow-rnaseq/tree/5832931a9569d9d8fba26a36146a682870d6f5f7", for example. Guidance on generating a permanent github link can be found [here](https://help.github.com/en/github/managing-files-in-a-repository/getting-permanent-links-to-files#press-y-to-permalink-to-a-file-in-a-specific-commit).
* `cwl_args_url`: A raw github URL that points to the input parameters file for the job that you are running. "https://raw.githubusercontent.com/Sage-Bionetworks-Workflows/dockstore-workflow-rnaseq/5832931a9569d9d8fba26a36146a682870d6f5f7/jobs/test-paired-bam/job.json", for example. To find the raw URL for a file on github, navigate to the file and follow the instructions for generating a [permanent url](https://help.github.com/en/github/managing-files-in-a-repository/getting-permanent-links-to-files#press-y-to-permalink-to-a-file-in-a-specific-commit). You can then click on the `raw` button to open the raw URL in your browser. 
* `index_synapseid`: A [Synapse](https://www.synapse.org/) ID for the folder that contains a STAR-indexed reference genome. An example can be found in `syn22152278`
* `nthreads`: An integer value that represents the number of compute threads that the STAR aligner should use. 
* `synapse_parentid`: A [Synapse](https://www.synapse.org/) ID for the folder that output tables will be uploaded to. 
* `synapse_config`: A [Synapse](https://www.synapse.org/) configuration file that will be used to authenticate data downloads and uploads during workflow execution
* `synapseid`: List of [Synapse](https://www.synapse.org/) ID's that correspond to input reads for processing. For the bam_paired.cwl workflow, the ID's should point to BAM files. For the fastq_paired.cwl workflow, these ID's should point to compressed fastq files for the forward reads. For the fastq_single.cwl workflow, these ID's should point to compressed fastq files. These files must contain a `specimenID` annotation in Synapse

The fastq_paired.cwl workflow also requires the following input:

* `synapseid_2`: A list of [Synapse](https://www.synapse.org/) ID's that correspond to the reverse reads in compressed fastq.gz format. These files must contain a `specimenID` annotation in Synapse, and this list should be ordered by specimen to match the `synapesid` list.

An example input json file that contains values for these required inputs can be found [here](https://raw.githubusercontent.com/Sage-Bionetworks-Workflows/dockstore-workflow-rnaseq/7d64748a3a6d7cc8cfd9f30fc43c1b9bc79b3b3f/jobs/test-paired-bam/job.json)

The mirna_single.cwl workflow also requires the following input:

* `sjdbGTFfile` : A mirNA subset gtf annotation file that STAR will use to guide mappings

An example input json file that contains example parameters for the miRNA workflow can be found [here](https://github.com/Sage-Bionetworks-Workflows/dockstore-workflow-rnaseq/blob/master/jobs/test-single-mirna/job.json)

### Optional Job inputs

You can optionally supply an input parameter that specifies the strandedness parameter of the library that will be used by Picard Tools. To do so, add the `strand_specificity` argument to your job.json file. The three valid string options for this parameter are:

* `NONE`
* `FIRST_READ_TRANSCRIPTION_STRAND`
* `SECOND_READ_TRANSCRIPTION_STRAND`

If this argument is not provided, the default value of `NONE` will be used. 

To specify the column parse from STAR gene count output, specify the `column_number` parameter. The three valid integer arguments are:

* `2` : counts for unstranded RNA libraries
* `3`: counts for first read stranded libraries
* `4`: counts for second read stranded libraries 

If this argument is not provided, the default value of `2` will be used. This is the correct value for libraries that are not specifically designed to be stranded. 

An example input json file that contains the required inputs and these optional inputs can be found [here](https://raw.githubusercontent.com/Sage-Bionetworks-Workflows/dockstore-workflow-rnaseq/7d64748a3a6d7cc8cfd9f30fc43c1b9bc79b3b3f/jobs/test-paired-fastq/job.json)

In addition, you may optionally specify the following parameters for the STAR alignment:

* `alignEndsType` : A string specifying the type of read ends alignment
* `outFilterMismatchNmax` : Integer specifying the maximum number of mismatches per pair
* `outFilterMultimapScoreRange` : Integer specifying the score range for multi-mapping alignments
* `outFilterMultimapNmax` : Integer specifying the maximum number of multiple alignments for a read
* `outFilterScoreMinOverLread` : Integer specifying the minimum score for an alignment to be reported, normalized to read length 
* `outFilterMatchNminOverLread` : Integer specifying the minimum number of matched bases for an alignment to be reported, normalized to read length
* `outFilterMatchNmin` : Integer specifying the minimum number of matched bases for an alignment to be reported
* `alignSJDBoverhangMin` : Integer specifying the minimum block size for annotated spliced alignments 
* `alignIntronMax` : Integer specifying the maximum intron size

For further details about these parameters, please refer to the [STAR manual](https://chagall.med.cornell.edu/RNASEQcourse/STARmanual.pdf

## Resource Requirements

Resource requirements are specified using the CWL `ResourceRequirement` class. Each subworkflow contains specific requests for RAM, disk space, and number of threads. These values are set for average-sized RNA Sequencing input files for alignment against the human reference genome. If the default values are not sufficient, please modify the `ResourceRequirement` values in the subworkflow CWL files. 

## Workflow Outputs

The following output files are uploaded to Synapse during workflow execution:

* `gene_all_counts_matrix.txt`: Table containing raw gene counts, where row labels are geneid's and column labels are synapseid's for input files
* `gene_all_counts_matrix_clean.txt`: The same gene count table, but synapseid's have been converted to specimenID's and any duplicate samples were removed
* `Star_Log_Merged.txt`: Table containing mapping statistics that were parsed from the STAR aligner log files
* `Star_Log_Merged_clean.txt`: The same mapping statistics table, but synapseid's have been converted to specimenID's and any duplicate samples were removed
* `Study_all_metrics_matrix.txt`: A table containing statistics about realigned BAM files, as generated by picardtools
* `Study_all_metrics_matrix_clean.txt`: The same table containing realigned BAM file statistics, but synapseid's have been converted to specimenID's and any duplicate samples were removed
* `provenance.csv`: A csv file where the first field contains the synapseid's for all input files that were used in the processing workflow, the second field contains the version of the synapseid that was used, and the third field contains the corresponding specimenID from the Synapse annotation

## Tests

[`cwltest`](https://github.com/common-workflow-language/cwltest) is used for
testing. Add test descriptions to `tests/test-descriptions.yaml`. Each test
added requires a file describing the job inputs that should be added to the
[tests](tests) directory.

### Integration Tests

Integration tests are automatically performed on any push to the master branch that does not contain the `[skip-ci]` string in the commit message. Test data is stored on a project in Synapse, and is accessed using a service account that has credentials stored as github secrets in this repository.

## Continuous Deployment and Versioning

This repository uses GitHub actions to run tests and perform automated versioning.

### CI
Defined in [.github/workflows/ci.yaml](.github/workflows/ci.yaml), this action
runs on each push to master where the commit does not contain '[skip-ci]'.

### Versioning
Versioning is achieved through git tagging using
[semantic versioning](https://semver.org/). Each push to master will generate an
increment to the patch value, unless the commit contains the string '[skip-ci]'.

Use the release script to do a minor or major release. 
To create a minor release, run `python utils/release.py` from the project root.
To create a major release, run the same command but add the flag `--major`.

The release script has dependencies which can be installed to virtual
environment using [pipenv](https://pipenv.pypa.io/en/latest/). After installing
pipenv, run `pipenv install` to install the dependencies, and `pipenv shell`
to activate the environment.

Alternately, to do a minor or major releases manually:
1. Determine what the tag value will be. For example, to make a minor release from v0.1.22, the next tag would be v0.2.0.
1. In the CWL tools, change the docker version to use that tag, and create a commit like "Update docker version in cwl tools in preparation for minor release"
1. Run the tagging commmand: `git tag v0.2.0`
1. Push the tag: `git push --tags`

#### Branch Versioning
Optionally, you can set up your repository for running the CI action on pushes
to all branches, not just master. This is not the default behavior because it
introduces complexity and requires that you use git in a certain way.

To set this up, in `.github/workflows/ci.yaml`, change `master` to `'*'` in the
event filter ( on > push > branches). This will cause pushes to non-master tags
to also build. They will be tagged with this pattern: <semver>-<git-short-sha>,
e.g. `v1.0.0-197e187`.

If you choose to make this change, for best results we recommend that you also
use the no-fast-forward flag (`--no-ff`) when merging branches to master. Using
that flag will ensure that a new merge commit is created, and CI will run
correctly. Without a new merge commit, versioning won't work correctly.

