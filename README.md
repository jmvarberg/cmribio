
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cmribio

<!-- badges: start -->

<!-- badges: end -->

This package contains functions and reporting templates used for
standard analysis and reporting for bioinformatics and biostatistics
projects.

## Installation

You can install the development version of cmribio from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("jmvarberg/cmribio")
```

## Initialize Project

Each project should be contained in it’s own project directory with
specific subdirectories, and should contain a README file to capture any
notes/information about the project to enable another member/user to
continue working on the project if needed.

A helper function has been provided to create all subdirectories and a
template README file.

``` r
temp <- tempdir()
cmribio::init_proj(dir = temp, overwrite = TRUE)
#> Parent directory exists: /private/var/folders/y6/wmk7zjhj649bvdzcyt87gp9xrvkk8z/T/RtmpAwSkk4
#> Wrote README at: /private/var/folders/y6/wmk7zjhj649bvdzcyt87gp9xrvkk8z/T/RtmpAwSkk4/README.txt
```

We can see the subdirectories created:

    #> /var/folders/y6/wmk7zjhj649bvdzcyt87gp9xrvkk8z/T//RtmpAwSkk4
    #> ├── README.txt
    #> ├── data
    #> ├── documents
    #> ├── results
    #> └── scripts

A template README is also created, which you should open and modify as
needed for your project.

    #> Project Title: <Your Project Name>
    #> 
    #> Date: 2026-03-06
    #> 
    #> Overview
    #> --------
    #> Add notes about the project and analysis here as needed.
    #> 
    #> Data
    #> ----
    #> - Describe input data sources and formats.
    #> - Note any preprocessing steps.
    #> 
    #> Analysis
    #> --------
    #> - Briefly outline methods, tools, and parameters.
    #> 
    #> Reproducibility
    #> ---------------
    #> - R version: 4.5.0
    #> - Package versions: 
    #> - How to reproduce: 
    #> 
    #> Contact
    #> -------
    #> - Author: Your Name
    #> - Email: you@example.com

## Pipeline Templates

Template files, functions and Quarto documents for automated reporting
are provided for a few common workflows. These templates are created
using the [`{targets}`](https://books.ropensci.org/targets/) package to
provide scalable, efficient and automated pipelines and report
generation. To see a list of the available templates, use the function
’cmribio::list_targets_templates()\`:

``` r
cmribio::list_targets_templates()
#>     Name   Type                     Description
#> 1 DEseq2 deseq2 DESeq2 for bulk RNAseq analysis
```

To use one of the templates, use the function
`cmribio::use_target_template()` and provide one of the available values
for ‘Type’ (returned by list_targets_templates()) to copy the pipeline
and all associated files to the specified directory.

``` r
temp <- tempdir()
cmribio::use_targets_template(dir = temp, type = "deseq2")
#> Specified directory already exists
#> '/private/var/folders/y6/wmk7zjhj649bvdzcyt87gp9xrvkk8z/T/RtmpAwSkk4'. Do you
#> want to proceed? Existing versions of the _targets pipeline script, functions
#> and Quarto report file will be overwritten. (yes/No/cancel)
```

    #> /var/folders/y6/wmk7zjhj649bvdzcyt87gp9xrvkk8z/T//RtmpAwSkk4
    #> ├── DESeq2_analysis_report.qmd
    #> ├── README.txt
    #> ├── _targets.R
    #> ├── cmribio_demo_counts_matrix.tsv
    #> ├── cmribio_demo_samplesheet.csv
    #> ├── data
    #> ├── documents
    #> ├── results
    #> ├── scripts
    #> └── targets_bulkRNA_DESeq2_functions.R
