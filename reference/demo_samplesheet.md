# Example bulk RNAseq sample sheet

An example sample sheet for 'demo_counts' with metadata mapping sample
names to group information.

## Usage

``` r
demo_samplesheet
```

## Format

A data frame with 12 rows/samples and 5 columns of metadata:

## Source

Generated in `data-raw/demo_samplesheet.R`.

## Details

Used for demo purposes of '\_targets_bulkRNA_DEseq2.R' demo pipeline for
bulk RNAseq analysis. Generated using code in:
`data-raw/demo_samplesheet.R`.

## Examples

``` r
# Basic usage
head(demo_samplesheet)
#>        sample                                             fastq_1
#> 1 SRX26953675 ./raw_data/fastq/SRX26953675_SRR31588248_1.fastq.gz
#> 2 SRX26953676 ./raw_data/fastq/SRX26953676_SRR31588247_1.fastq.gz
#> 3 SRX26953677 ./raw_data/fastq/SRX26953677_SRR31588246_1.fastq.gz
#> 4 SRX26953678 ./raw_data/fastq/SRX26953678_SRR31588245_1.fastq.gz
#> 5 SRX26953679 ./raw_data/fastq/SRX26953679_SRR31588244_1.fastq.gz
#> 6 SRX26953680 ./raw_data/fastq/SRX26953680_SRR31588243_1.fastq.gz
#>                                               fastq_2 submission_accession
#> 1 ./raw_data/fastq/SRX26953675_SRR31588248_2.fastq.gz           SRA2026553
#> 2 ./raw_data/fastq/SRX26953676_SRR31588247_2.fastq.gz           SRA2026553
#> 3 ./raw_data/fastq/SRX26953677_SRR31588246_2.fastq.gz           SRA2026553
#> 4 ./raw_data/fastq/SRX26953678_SRR31588245_2.fastq.gz           SRA2026553
#> 5 ./raw_data/fastq/SRX26953679_SRR31588244_2.fastq.gz           SRA2026553
#> 6 ./raw_data/fastq/SRX26953680_SRR31588243_2.fastq.gz           SRA2026553
#>              sample_title
#> 1 Macrophage, replicate 1
#> 2 Macrophage, replicate 2
#> 3 Macrophage, replicate 3
#> 4 Macrophage, replicate 4
#> 5       MNGC, replicate 1
#> 6       MNGC, replicate 2
dim(demo_samplesheet)
#> [1] 12  5

```
