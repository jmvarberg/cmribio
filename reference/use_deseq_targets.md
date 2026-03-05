# Use targets pipeline templates for bulk RNAseq analysis with DESeq2

Use targets pipeline templates for bulk RNAseq analysis with DESeq2

## Usage

``` r
use_deseq_targets(dir = NULL)
```

## Arguments

- dir:

  default = NULL, which will use current working directory; path to
  directory to copy tempate files to

## Value

copies three files: \_targets.R (pipeline script),
\_targets_bulkRNA_DESeq2_functions.R (functions to run pipeline), and
DESeq2_analysis_report.qmd (Quarto report template). Also makes copies
of the demo counts matrix and sample sheet for testing the pipeline.
