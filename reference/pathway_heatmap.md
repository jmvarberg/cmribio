# Heatmap of pathway of interest

Heatmap of pathway of interest

## Usage

``` r
pathway_heatmap(
  expr_mat,
  gs_list,
  pathway_name,
  species = c("mouse", "human"),
  show_rowNames = FALSE
)
```

## Arguments

- expr_mat:

  matrix, expression matrix with ENSEMBL IDs as row names

- gs_list:

  data frame, list of gene sets for species of interest

- pathway_name:

  character, name of pathway to use for heatmap.

- species:

  character, either "mouse" or "human"

- show_rowNames:

  boolean, whether to show row names on pheatmap::pheatmap output.

## Value

pheatmap plot object
