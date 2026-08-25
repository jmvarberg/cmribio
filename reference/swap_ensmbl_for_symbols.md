# Convert ENSMBL IDs to Gene Symbols

This is a helper function to simplify the conversion of matrix rownames
formatted in ENSMBL ID format (i.e., ENSMUSG00000051951) to the
corresponding gene symbols (i.e, Xkr4). This is mostly a helper tool for
late stages of analysis with Seurat objects, where you want to make
plots showing gene names, or you need to format with gene names as input
for other analysis tools. This is also used for preparing the files
needed for uploading of datasets to the Single Cell Portal.

## Usage

``` r
swap_ensmbl_for_symbols(x, species = c("mouse", "human"))
```

## Arguments

- x:

  Input matrix with rownames as ENSMBL IDs

- species:

  Character, either "mouse" or "human" are currently supported.

## Value

Output matrix with rownames converted from ENSMBL IDs to gene names.

## Details

The approach uses reference tables from the `annotables` package for the
conversion purposes. The grcm38 and grch38 are used for conversion for
mouse and human, respectively. One-to-many mapping issues are handled by
only replacing the ENSMBL ID if it maps to a unique gene name. If
multiple ENSMBL IDs map to the same gene symbol, then the feature name
is left in ENSMBL format.

## Examples

``` r
if (FALSE) { # \dontrun{
data <- cmribio::demo_counts
orig <- rownames(data)
new <- swap_ensmbl_for_symbols(data, species = "mouse")
head(orig)
head(new)
} # }
```
