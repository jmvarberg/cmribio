# Annotation table for mouse using ENSMBL GRCm38 from stephenturner/annotables package.

Annotation table for mouse using ENSMBL GRCm38 from
stephenturner/annotables package.

## Usage

``` r
grcm38
```

## Format

A data frame mouse annotation information.

## Source

Generated in `data-raw/grcm38.R`.

## Details

Used for annotating datasets, swapping IDs between types etc.
`data-raw/grcm38.R`.

## Examples

``` r
# Basic usage
head(grcm38)
#> # A tibble: 6 × 9
#>   ensgene           entrez symbol chr    start    end strand biotype description
#>   <chr>              <int> <chr>  <chr>  <int>  <int>  <int> <chr>   <chr>      
#> 1 ENSMUSG000000000…  14679 Gnai3  3     1.08e8 1.08e8     -1 protei… G protein …
#> 2 ENSMUSG000000000…  54192 Pbsn   X     7.69e7 7.69e7     -1 protei… probasin   
#> 3 ENSMUSG000000000…  12544 Cdc45  16    1.86e7 1.86e7     -1 protei… cell divis…
#> 4 ENSMUSG000000000…  14955 H19    7     1.42e8 1.42e8     -1 lncRNA  H19, impri…
#> 5 ENSMUSG000000000… 107815 Scml2  X     1.60e8 1.60e8      1 protei… Scm polyco…
#> 6 ENSMUSG000000000…  11818 Apoh   11    1.08e8 1.08e8      1 protei… apolipopro…
colnames(grcm38)
#> [1] "ensgene"     "entrez"      "symbol"      "chr"         "start"      
#> [6] "end"         "strand"      "biotype"     "description"


```
