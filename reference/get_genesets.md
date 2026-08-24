# Pull Gene Sets of Interest from msigdbr package

Pull Gene Sets of Interest from msigdbr package

## Usage

``` r
get_genesets(
  species = c("human", "mouse"),
  sets = c("hallmark", "kegg", "wiki", "reactome", "go_bp", "go_cc", "go_mf")
)
```

## Arguments

- species:

  "mouse" or "human"; default = "human"

- sets:

  which gene set collections to include, values = "hallmark", "kegg",
  "wiki", "reactome", "go_bp", "go_cc", "go_mf". Note, "kegg" not
  available for mouse.

## Value

data frame of gene sets and their associated genes and information as
output by msigdbr::msigdbr()

## Examples

``` r
gs <- get_genesets(species = "human", sets = "hallmark")
#> Downloading gene sets (first use only, may take a few minutes)...
head(gs)
#> # A tibble: 6 × 20
#>   gene_symbol ncbi_gene ensembl_gene db_gene_symbol db_ncbi_gene db_ensembl_gene
#>   <chr>       <chr>     <chr>        <chr>          <chr>        <chr>          
#> 1 ABCA1       19        ENSG0000016… ABCA1          19           ENSG00000165029
#> 2 ABCB8       11194     ENSG0000019… ABCB8          11194        ENSG00000197150
#> 3 ACAA2       10449     ENSG0000016… ACAA2          10449        ENSG00000167315
#> 4 ACADL       33        ENSG0000011… ACADL          33           ENSG00000115361
#> 5 ACADM       34        ENSG0000011… ACADM          34           ENSG00000117054
#> 6 ACADS       35        ENSG0000012… ACADS          35           ENSG00000122971
#> # ℹ 14 more variables: source_gene <chr>, gs_id <chr>, gs_name <chr>,
#> #   gs_collection <chr>, gs_subcollection <chr>, gs_collection_name <chr>,
#> #   gs_description <chr>, gs_source_species <chr>, gs_pmid <chr>,
#> #   gs_geoid <chr>, gs_exact_source <chr>, gs_url <chr>, db_version <chr>,
#> #   db_target_species <chr>
```
