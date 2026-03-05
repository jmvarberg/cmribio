# Run limma::cameraPR

Run limma::cameraPR

## Usage

``` r
run_cameraPR(
  geneset_df,
  de_results,
  fc_col = "log2FoldChange",
  ens_col = "ensemble_gene_id",
  comp_col = "test"
)
```

## Arguments

- geneset_df:

  data.frame, containing all gene sets of interest for testing. Created
  from msigdbr, using cmribio::get_genesets

- de_results:

  data.frame object, containing full DE testing results (not filtered
  for FDR or logFC). Assumes all comparisons made are present, with that
  info in a column.

- fc_col:

  character, column in de_results that contains the logFC information.
  default value = "log2FoldChange"

- ens_col:

  character, column in de_results data frame that contains the ENSEMBL
  gene IDs. default value = "ensemble_gene_id"

- comp_col:

  character, column in the de_results that contains the
  test/contrast/comparison name. Used to split the de_results into named
  logFC vectors for each test.

## Value

list containing limma::cameraPR results for each contrast/logFC vector
tested.
