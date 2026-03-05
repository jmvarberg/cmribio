# Create dot plots of cameraPR results by direction and contrast

Create dot plots of cameraPR results by direction and contrast

## Usage

``` r
camera_dotplot(x, n_path = 10)
```

## Arguments

- x:

  data frame, containing results from cameraPR (with/without FDR
  filtering). Should be combined to include all
  tests/contrasts/comparisons of interest in the experiment. Must
  contain columns: `Direction`, `Contrast`, `NGenes`, `GeneSet`, `FDR`.

- n_path:

  integer, number of pathways to show for each direction (Up and Down).
  Selects the top n based on the strongest enrichment (-log10(FDR)) for
  Up and Down separately.

## Value

A named list of ggplot objects: `list(Up = <plot>, Down = <plot>)`. You
can further modify them with ggplot2 methods.
