#scripts for '_targets_bulkRNA_DESEq2.R' pipeline


# Analysis Functions ------------------------------------------------------
A01_make_counts <- function(gene_counts) {

  counts_matrix <- gene_counts %>%
    dplyr::mutate(across(where(is.numeric), as.integer))

  #remove features/rows where there are zero counts in all columns/samples
  counts_matrix <- counts_matrix[rowSums(counts_matrix != 0) > 0, , drop = F]

}

A02_make_colData <- function(sample_sheet, counts_matrix) {

  #make the colData as needed for grouping and sample information
  metadata <- sample_sheet |>
    dplyr::select(sample, sample_title) |>
    dplyr::distinct() |>
    dplyr::filter(sample %in% colnames(counts_matrix)) |> #this removes any samples that were in the sample sheet but didn't make it through the analysis to the counts matrix.
    dplyr::mutate(group = dplyr::case_when(stringr::str_detect(sample_title, "Macrophage") ~ "Macrophage",
                                           stringr::str_detect(sample_title, "MNGC") ~ "MNGC",
                                           stringr::str_detect(sample_title, "Stroma") ~ "Stroma")
                  ) |>  #add mutate calls etc. to modify/rename metadata columns as needed for DESeq2 design
    dplyr::arrange(match(sample, colnames(counts_matrix))) |> #this makes sure columns are ordered in the same order as columns in counts matrix
    DataFrame() #this last step needed in order to get the DESeq2 object creation to work
}

#annotate results data frames using annotables
A03_annotate_results <- function(results, species = c("human", "mouse"), id_type = c("ensgene", "entrez", "symbol")) {

  #get the reference annotation table
  if(species == "human") {
    ref <- annotables::grch38
  } else if(species == "mouse") {
    ref <- annotables::grcm38
  }

  out <- results |>
    tibble::rownames_to_column(var = id_type) |>
    dplyr::left_join(ref) |>
    dplyr::distinct(symbol, .keep_all = TRUE)
}

#normalized_dds_object - either rlog() or vst(); de_results_list - full DE results for each contrast/comparison
A04_quickomics_export <- function(normalized_dds_object, de_results_list, model_name = NULL, outDir = "./results/Quickomics") {

  output_location <- file.path(outDir, model_name)

  #Create the Quikomics output directory as specified in outDir path
  if(!dir.exists(output_location)) {
    dir.create(output_location, recursive = T)
    print(paste0("Creating output directory for Quickomics files at: ", output_location))
  }

  #metadata: sampleid, group, additional columns. sampleid must match expresion data file column names
  quickomics_md <- as.data.frame(colData(normalized_dds_object)) |>
    dplyr::rename(sampleid = sample,
                  genotype = cell_line) |>
    dplyr::select(sampleid, group, everything(), -sizeFactor)
  quickomics_md

  write.csv(quickomics_md, file = file.path(output_location,"quickomics_metadata.csv"), row.names = F)

  #expression data - UniqueID, sampleids, use vst/rlog normalized counts object
  quickomics_expression <- as.data.frame(assay(normalized_dds_object)) |>
    tibble::rownames_to_column(var = "UniqueID") |>
    dplyr::filter(rowSums(across(where(is.numeric))) != 0)

  write.csv(quickomics_expression, file = file.path(output_location, "quickomics_expression.csv"), row.names = F)

  #Comparison data: UniqueID, test, Adj.P.Value, P.Value, logFC. test labels must match group MD labels with 'vs' separator no spaces
  quickomics_tests <- de_results_list |>
    #dplyr::bind_rows(.id = "test") |>
    dplyr::bind_rows() |>
    tibble::rownames_to_column(var = "UniqueID") |>
    dplyr::mutate(UniqueID = stringr::str_remove(UniqueID, pattern = "\\.\\.\\..*$"),
                  parts = stringr::str_split_fixed(comparison, "_", n = 3),
                  test = stringr::str_c(parts[, 2], "vs", parts[, 3], sep = "_")) |>
    dplyr::filter(UniqueID %in% quickomics_expression$UniqueID) |>
    dplyr::rename(P.Value = pvalue,
                  Adj.P.Value = padj,
                  logFC = log2FoldChange) |>
    dplyr::select(-baseMean, -lfcSE, -parts) |>
    na.omit()

  write.csv(quickomics_tests, file = file.path(output_location, "quickomics_comparison.csv"), row.names = F)

  return(list(meta = quickomics_metadata,
              norm_expr = quickomics_expression,
              de_res = quickomics_tests))

}

#Export significant DE hits for each comparison to file for upload to Metascape for enrichment/pathway analysis
# Assumes columns with 'log2FoldChange' and 'entrez' for fold change filtering and pulls the gene EntrezIDs for Metascape upload
A05_Metascape_files <- function(annotated_significant_results) {

  #for each contrast, pull the Up (positive lfc) DEGs, sort by LFC and keep up to 200.
  #Want to save out Metascape formatted CSV file with column for each comparison and ENSMBL ID's for genes
  up_hits <- lapply(annotated_significant_results, function(x) {
    x |> dplyr::filter(log2FoldChange > 0) |>
      dplyr::arrange(desc(log2FoldChange)) |>
      dplyr::pull(entrez)
  }
  )

  down_hits <- lapply(annotated_significant_results, function(x) {
    x |> dplyr::filter(log2FoldChange < 0) |>
      dplyr::arrange(desc(log2FoldChange)) |>
      dplyr::pull(entrez)
  }
  )

  #now make output files
  output_up <- jmvtools::jmv_mixedLengthDF(up_hits)
  output_down <- jmvtools::jmv_mixedLengthDF(down_hits)

  message("Creating ./results/Metascape/ directory to save up and down-regulated gene lists.")
  dir.create("./results/Metascape", recursive = TRUE)
  write.csv(output_up, file.path("./results/Metascape", "Up_DEGs_for_Metascape.csv", row.names = F))
  write.csv(output_down, file.path("./results/Metascape", "Down_DEGs_for_Metascape.csv", row.names = F))

  #return the up/down results in Metascape format as list
  return(list(metascape_up_degs = output_up,
              metascape_down_degs = output_down)
  )

}





# Visualization Functions -------------------------------------------------
reads_plot <- function(dds, metadata, normalized = F) {

  if(!normalized) {
    #get the counts from the dds object
    counts <- counts(dds, normalized = F)
    title <- "Raw Counts"
  } else {
    counts <- counts(dds, normalized = T)
    title <- "Normalized Counts"
  }

  df <- data.frame(sample = colnames(counts),
                   total_counts = colSums(counts)) %>%
    dplyr::left_join(as_tibble(metadata))

  #make plot
  ggplot(df, aes(x=sample, y = total_counts, fill = condition)) +
    geom_col() +
    ggsci::scale_fill_igv(name = "Condition") +
    xlab("Sample") +
    ylab("Total Reads") +
    coord_flip() +
    ggtitle(title) +
    theme_bw()

}


