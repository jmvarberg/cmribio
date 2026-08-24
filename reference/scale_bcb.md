# Functions to apply BCB Color Palettes

Functions to apply BCB Color Palettes

## Usage

``` r
scale_color_bcb(alpha = 1, ...)

scale_fill_bcb(alpha = 1, ...)
```

## Arguments

- alpha:

  Set transparency value for color/fill

- ...:

  Additional arguments passed to ggplot2::discrete_scale

## Value

ggplot2 scale object using the BCB discrete palette.

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(mpg, wt, color = as.factor(cyl))) + geom_point()

ggplot(mtcars, aes(mpg, wt, color = as.factor(cyl))) + geom_point() + scale_color_bcb()
```
