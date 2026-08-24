# Custom BCB theme

This applies standard modifications to ggplot2 outputs to use "sans"
family font, make all text black, and set sizing.

## Usage

``` r
theme_bcb(
  base_theme = c("bw", "cow"),
  base_size = 14,
  axis_text_size = 16,
  axis_title_size = 18
)
```

## Arguments

- base_theme:

  Specifies which theme to start from, either "bw" for
  ggplot2::theme_bw, or "cow" for cowplot::theme_cowplot().

- base_size:

  Sets the base size for the plot, default = 14

- axis_text_size:

  Sets the size for the axis text (units/markers), default = 16

- axis_title_size:

  Sets the size for the axis labels/titles, default = 18

## Value

A ggplot2 theme object.

## Examples

``` r
ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point() + theme_bcb(base_theme = "bw")

ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point() + theme_bcb(base_theme = "cow")
```
