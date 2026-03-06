# Use targets pipeline templates for bulk RNAseq analysis with DESeq2

Use targets pipeline templates for bulk RNAseq analysis with DESeq2

## Usage

``` r
use_targets_template(dir = NULL, type = c("deseq2"))
```

## Arguments

- dir:

  default = NULL, which will use current working directory; path to
  directory to copy tempate files to

- type:

  character, choose which targets pipeline template to use. Available
  options include "deseq2".

## Value

copies three files: \_targets.R (pipeline script),
\_targets_bulkRNA_DESeq2_functions.R (functions to run pipeline), and
DESeq2_analysis_report.qmd (Quarto report template). Also makes copies
of the demo counts matrix and sample sheet for testing the pipeline.
