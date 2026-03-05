## code to prepare `demo_counts` dataset goes here

# raw fastq files for mouse RNASeq study SRP549060 were pulled from GEO and processed with nf-core/rnaseq v 3.19.0 with star_rsem.
# Output file rsem.merged.gene_counts.tsv is used here as a demo dataset for bulk RNAseq pipelines and visualization functions
# Sample sheet was modified from the table downloaded from GEO.
demo_counts <- data.table::fread("./inst/extdata/rsem.merged.gene_counts.tsv") |>
  dplyr::select(-`transcript_id(s)`) |>
  tibble::column_to_rownames(var = "gene_id")

usethis::use_data(demo_counts, overwrite = TRUE)
