# Generate a standard analysis report from template in the current directory.

Generate a standard analysis report from template in the current
directory.

## Usage

``` r
create_bcb_report(
  file_name = NULL,
  dir = NULL,
  ext_name = c("bcb-report", "bulk-rnaseq")
)
```

## Arguments

- file_name:

  Name for the Quarto report file.

- dir:

  Directory to save the report file to. Default is NULL, which will
  default to the current working directory.

- ext_name:

  Which template to use. One of c("bcb-report", "bulk-rnaseq"). Use
  "bcb-report" for general analyses, and "bulk-rnaseq" to perform DESeq2
  analysis of RNAseq datasets.

## Value

Copies template file into working directory.

## Examples

``` r
if (interactive()) {
create_bcb_report(file_name = "BCB172_Analysis", ext_name = "bcb-report")
}
```
