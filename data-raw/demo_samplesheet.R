## code to prepare `demo_samplesheet` dataset goes here

# raw fastq files for mouse RNASeq study SRP549060 were pulled from GEO and processed with nf-core/rnaseq v 3.19.0 with star_rsem.
# Output file rsem.merged.gene_counts.tsv is used here as a demo dataset for bulk RNAseq pipelines and visualization functions
# Sample sheet was modified from the table downloaded from GEO.

demo_samplesheet <- data.table::fread("./inst/extdata/samplesheet.csv") |>
  dplyr::select(sample, fastq_1, fastq_2, submission_accession, sample_title)

usethis::use_data(demo_samplesheet, overwrite = TRUE)
