# List available targets pipeline templates

List available targets pipeline templates

## Usage

``` r
list_targets_templates()
```

## Value

Data frame with names and descriptions of templates available in the
package, and they 'type' value to provide to
cmribio::use_targets_template() to access.

## Examples

``` r
list_targets_templates()
#>     Name   Type                     Description
#> 1 DEseq2 deseq2 DESeq2 for bulk RNAseq analysis
```
