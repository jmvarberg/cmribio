#' Custom BCB theme
#'
#' This applies standard modifications to ggplot2 outputs to use "sans" family font, make all text black, and set sizing.
#'
#'
#' @param base_size Sets the base size for the plot, default = 14
#' @param axis_text_size Sets the size for the axis text (units/markers), default = 16
#' @param axis_title_size Sets the size for the axis labels/titles, default = 18
#' @param base_theme Specifies which theme to start from, either "bw" for ggplot2::theme_bw, or "cow" for cowplot::theme_cowplot().
#'
#' @returns A ggplot2 theme object.
#' @export theme_bcb
#'
#' @importFrom cowplot theme_cowplot
#' @importFrom ggplot2 theme_bw
#'
#' @examples
#' ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point() + theme_bcb(base_theme = "bw")
#' ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) + ggplot2::geom_point() + theme_bcb(base_theme = "cow")
theme_bcb <- function(base_theme = c("bw", "cow"), base_size = 14, axis_text_size = 16, axis_title_size = 18) {

  base_theme <- match.arg(base_theme)

  thm <- switch(
    base_theme,
    cow = cowplot::theme_cowplot(font_size = base_size),
    bw = ggplot2::theme_bw(base_size = base_size)
  )

  thm +
    theme(
      text = element_text(
        family = "sans",
        colour = "black"
      ),

      axis.text = element_text(
        colour = "black",
        size = axis_text_size
      ),

      axis.title = element_text(
        colour = "black",
        face = "bold",
        size = axis_title_size
      ),

      axis.ticks = element_line(
        colour = "black",
        linewidth = 0.4
      ),

      axis.line = element_line(
        colour = "black",
        linewidth = 0.4
      ),

      legend.text = element_text(
        colour = "black"
      ),

      legend.title = element_text(
        colour = "black",
        face = "bold"
      ),

      strip.text = element_text(
        colour = "black",
        face = "bold"
      )
    )
}

#specify colors of interest to use for BCB/CMRI palette -taken from brand guidlines August 2026
#' BCB color palette
#' @format Named character vector of hex colors
#' @export
bcb_colors <- c(
  "BrandBlue" = "#005EB8",
  "DarkBlue" = "#003865",
  "Gold" = "#FED141",
  "CoolGray" = "#53565A",
  "AccessibleFunGreen" = "#008521",
  "EnergyBlue" = "#41B6E6",
  "SparkDarkGold" = "#FCA200",
  "AccessibleEnergyBlue" = "#299DDA",
  "SparkOrange" = "#FF4900",
  "FunGreen" = "#00A646"
)

#' BCB/CMRI Color Palettes
#'
#' Specific color palette based on CMRI brand guidlines.
#'
#' @param alpha Transparency level, real number between 0-1.
#'
#' @export pal_bcb
#'
#' @importFrom ggplot2 discrete_scale
#' @importFrom grDevices col2rgb rgb
#' @importFrom scales manual_pal
#' @examples
#' library(scales)
#' show_col(bcb_colors)
#' show_col(scales::alpha(bcb_colors, 0.5))
#'
#'
pal_bcb <- function(alpha = 1) {

  if (alpha > 1 || alpha <= 0) {
    stop("alpha value must be between 0 and 1")
  }

  raw_cols_rgb <- grDevices::col2rgb(bcb_colors)

  alpha_cols <- grDevices::rgb(
    raw_cols_rgb[1, ],
    raw_cols_rgb[2, ],
    raw_cols_rgb[3, ],
    alpha = alpha * 255,
    maxColorValue = 255
  )

  #create the palette with applied alpha
  scales::manual_pal(alpha_cols)
}

#' Functions to apply BCB Color Palettes
#'
#' @param alpha Set transparency value for color/fill
#' @param ... Additional arguments passed to ggplot2::discrete_scale
#'
#' @returns ggplot2 scale object using the BCB discrete palette.

#' @rdname scale_bcb
#' @export
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(mpg, wt, color = as.factor(cyl))) + geom_point()
#' ggplot(mtcars, aes(mpg, wt, color = as.factor(cyl))) + geom_point() + scale_color_bcb()
scale_color_bcb <- function(alpha = 1, ...) {
  ggplot2::discrete_scale("colour", palette = pal_bcb(alpha),
  ...
  )
}

#' @rdname scale_bcb
#' @export
scale_fill_bcb <- function(alpha = 1, ...) {
  ggplot2::discrete_scale("fill", palette = pal_bcb(alpha),
  ...
  )
}



