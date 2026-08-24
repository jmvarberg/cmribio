# BCB/CMRI Color Palettes

Specific color palette based on CMRI brand guidlines.

## Usage

``` r
pal_bcb(alpha = 1)
```

## Arguments

- alpha:

  Transparency level, real number between 0-1.

## Examples

``` r
library(scales)
show_col(bcb_colors)

show_col(scales::alpha(bcb_colors, 0.5))


```
