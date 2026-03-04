# Initialize Project Directory

Initialize Project Directory

## Usage

``` r
init_proj(dir = NULL, overwrite = c("ask", TRUE, FALSE))
```

## Arguments

- dir:

  Path to parent directory to create subdirectories: data, documents,
  results, scripts and README.txt template

- overwrite:

  How to handle scenario when 'dir' provided or any of the
  subdirectories exist. Default "ask" prompts user for how to handle.
  TRUE overwrites existing, FALSE stops if 'dir' exists.

## Value

Invisible file path to created 'dir'

## Examples

``` r
init_proj(dir = "./test_init", overwrite = "ask")
#> Parent directory does not exist. Creating it...
#> Created README at: /home/runner/work/cmribio/cmribio/docs/reference/test_init/README.txt
```
