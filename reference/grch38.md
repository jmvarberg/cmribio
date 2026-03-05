# Annotation table for human using ENSMBL GRCh38 from stephenturner/annotables package.

Annotation table for human using ENSMBL GRCh38 from
stephenturner/annotables package.

## Usage

``` r
grch38
```

## Format

A data frame mouse annotation information.

## Source

Generated in `data-raw/grch38.R`.

## Details

Used for annotating datasets, swapping IDs between types etc.
`data-raw/grch38.R`.

## Examples

``` r
# Basic usage
head(grch38)
#> # A tibble: 6 × 9
#>   ensgene         entrez symbol chr      start    end strand biotype description
#>   <chr>            <int> <chr>  <chr>    <int>  <int>  <int> <chr>   <chr>      
#> 1 ENSG00000000003   7105 TSPAN6 X       1.01e8 1.01e8     -1 protei… tetraspani…
#> 2 ENSG00000000005  64102 TNMD   X       1.01e8 1.01e8      1 protei… tenomodulin
#> 3 ENSG00000000419   8813 DPM1   20      5.09e7 5.10e7     -1 protei… dolichyl-p…
#> 4 ENSG00000000457  57147 SCYL3  1       1.70e8 1.70e8     -1 protei… SCY1 like …
#> 5 ENSG00000000460  55732 FIRRM  1       1.70e8 1.70e8      1 protei… FIGNL1 int…
#> 6 ENSG00000000938   2268 FGR    1       2.76e7 2.76e7     -1 protei… FGR proto-…
colnames(grch38)
#> [1] "ensgene"     "entrez"      "symbol"      "chr"         "start"      
#> [6] "end"         "strand"      "biotype"     "description"


```
