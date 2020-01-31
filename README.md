# RNASeq-CWL-Workflow

This workflow automates and standardizes the processing of bulk RNASeq datasets. The following steps are performed:

* Download input BAM alignment files using the [Synapse Client](https://python-docs.synapse.org//build/html/CommandLineClient.html)
* Sort input BAM alignment files using [Picard SortSam](https://broadinstitute.github.io/picard/command-line-overview.html#SortSam)
* Convert sorted BAM files into FastQ files using [Picard SamToFastQ](https://broadinstitute.github.io/picard/command-line-overview.html#SamToFastq)
* Align reads to the reference genome using the [STAR Aligner](https://github.com/alexdobin/STAR)
* Generate raw gene expression counts using the [STAR Aligner](https://github.com/alexdobin/STAR) --quantMode (similar to the HTSeq algorithm)
* Collect RNASeq metrics from re-aligned bam files using [Picard CollectRNASeqMetrics](https://broadinstitute.github.io/picard/command-line-overview.html#CollectRnaSeqMetrics)
* Collect Alignment summary statistics from re-aligned bam files using [Picard AlignmentSummaryMetrics](https://broadinstitute.github.io/picard/command-line-overview.html#CollectAlignmentSummaryMetrics)


