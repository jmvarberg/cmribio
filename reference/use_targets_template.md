# Use targets pipeline templates

Use targets pipeline templates

## Usage

``` r
use_targets_template(dir = NULL, type = c("deseq2"))
```

## Arguments

- dir:

  default = NULL, which will use current working directory; path to
  directory to copy template files to

- type:

  character, choose which targets pipeline template to use. Available
  options include "deseq2".

## Value

copies template files, functions, Quarto report templates and any demo
data needed to run the pipeline into the working directory.
