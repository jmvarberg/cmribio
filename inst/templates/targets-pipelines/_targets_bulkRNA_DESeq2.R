
options(bitmapType = "cairo")
knitr::opts_chunk$set(dev = "png", dev.args = list(type = "cairo"))

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c("tibble", "DESeq2", "tidyverse", "cowplot", "ggsci", "ggpubr", "jmvtools", "RColorBrewer", "PCAtools", "ComplexUpset", "data.table", "quarto", "pheatmap", "msigdbr", "limma", "UpSetR"), # Packages that your targets need for their tasks.
  format = "qs" # Uses qs2::qs_save() and qs2::qs_read() for faster I/O
  # Set other options as needed. See targets::tar_option_set() help for full list of available options to set.
)

# Run the R scripts in the R/ folder with your custom functions:
# This reads in an R script containing the analysis functions required to run the targets pipeline for DESeq2 analysis.
tar_source("./scripts/targets_bulkRNA_functions.R") # Source other scripts as needed.

# Below is the targets pipeline for bulk RNAseq analysis using DESeq2.
# This pipeline assumes that you are starting with a sample sheet containing sample metadata, and a raw counts matrix (feature X sample)
# To use with your data, modify the following:
# 1) Change the path in the 'sample_sheet_tracked' to point to your CSV file containing sample metadata.
# 2) Change the path to the 'gene_counts_tracked' target to point to your counts matrix.
# 3) Open the './scripts/targets_bulkRNA_functions.R' script and modify the function 'A02_make_colData()' to make any changes needed for your metadata sheet to allow your analysis of interest.

# See Vignette at jmvarberg.github.io/cmribio for DESeq2 Targets Pipeline for more information on running.
list(
  tar_file_read(
    name = sample_sheet_tracked,
    command = "./cmribio_demo_samplesheet.csv", #This points to demo sample sheet copied to working directory in code above. Replace with the path to your experiment sample sheet for your analysis.
    read = data.table::fread(!!.x),
    description = "Tracks samplesheet to monitor for changes, will invalidate if updated, also reads the file in."
  ),
  tar_file_read(
    name = gene_counts_tracked,
    command = "./cmribio_demo_counts_matrix.tsv", #This points to demo counts matrix copied to working directory in code above. Replace with the path to your experiment data for your analysis.
    read = data.table::fread(!!.x),
    description = "Tracks gene counts matrix with results to monitor for changes, also reads in the matrix as a target."
  ),
  tar_target(
    counts_matrix,
    A01_make_counts(gene_counts_tracked),
    description = "Counts matrix formatted to use to create DESeq2 object. Removes all rows that have zero counts in all samples."
  ),
  tar_target(
    name = column_data,
    command = A02_make_colData(sample_sheet_tracked, counts_matrix),
    description = "Modified sample sheet/metadata to use for colData to create DESeq2 object."
  ),
  #Define multiple design models, comparisons/contrasts of interest to test.
  #Each is created and tested separately using dynamic branching behind the scenes with targets.
  #This avoids having to make named targets for each one and all of its downstream targets explicitly.
  tar_target(
    name = design_setup,
    command = list(
      list(
        #DESeq2 model design '~ condition'; condition must be column in colData.
        #Add multiple comparisons/contrasts of interest in the comparisons list
        #Note, colData used in comparisons must be included in the design/model
        design = "group",
        label = "group",
        comparisons = list(
          c("group", "MNGC", "Macrophage"),
          c("group", "MNGC", "Stroma"),
          c("group", "Macrophage", "Stroma")
        )
      )
      ),
    #   list(
    #     #Example of adding a second design model using a different colData column
    #     design = "group",
    #     label = "group",
    #     comparisons = list(
    #       c("group", "Tumor", "Control")
    #     )
    #   ),
    #   list(
    #     # Example of using a design with covariate in the model:
    #     # This models 'effect of 'condition' on gene expression, after accounting for effect of 'group'
    #     design = "group + condition",
    #     label = "group_condition",
    #     comparisons = list(
    #       c("condition", "A", "B"),
    #       c("condition", "C", "B"),
    #     )
    #   )
    # ),
    iteration = "list",
    description = "Use this to create a list of specific pair-wise comparisons/contrasts you want to get results for from your model."
  ),
  # Dynamically branch over designs to build each dds
  tar_target(
    name = dynamic_dds,
    command = {

      dds <- DESeq2::DESeqDataSetFromMatrix(
        countData = counts_matrix,
        colData   = column_data,
        design    = as.formula(paste0("~ ", design_setup$design))
      )

      S4Vectors::metadata(dds)$branch_label <- design_setup$label
      S4Vectors::metadata(dds)$comparisons <- design_setup$comparisons
      dds
    },
    pattern   = map(design_setup),
    iteration = "list"
  ),
  # Downstream targets can now also branch automatically
  tar_target(
    name = dynamic_dds_fit,
    command = {
      dds_fit <- DESeq2::DESeq(dynamic_dds, test = "Wald")
      S4Vectors::metadata(dds_fit)$branch_label <- S4Vectors::metadata(dynamic_dds)$label
      S4Vectors::metadata(dds_fit)$comparisons <- S4Vectors::metadata(dynamic_dds)$comparisons
      dds_fit
    },
    pattern   = map(dynamic_dds),
    iteration = "list",
    description = "Performs the DESeq fit using the Wald test on each dynamically-created DDS object."
  ),
  tar_target(
    name = deseq_results,
    command = {
      results <- DESeq2::results(dynamic_dds_fit)
      S4Vectors::metadata(results)$branch_label <- S4Vectors::metadata(dynamic_dds_fit)$label
      S4Vectors::metadata(results)$comparisons <- S4Vectors::metadata(dynamic_dds_fit)$comparisons
    },
    pattern = map(dynamic_dds_fit),
    iteration = "list",
    description = "Pulls the results from the modeling performed in the DESeq command."
  ),
  tar_target(
    name = results_list,
    command = {
      comps <- S4Vectors::metadata(dynamic_dds_fit)$comparisons
      lab <- S4Vectors::metadata(dynamic_dds_fit)$branch_label

      output <- purrr::map(comps, function(comp) {
        res <- DESeq2::results(dynamic_dds_fit, contrast = comp, test = "Wald")
        lfc <- DESeq2::lfcShrink(dynamic_dds_fit, contrast = comp, res = res, type = "ashr")

        #return data frame
        res_df <- as.data.frame(lfc)
        res_df$comparison <- paste(comp, collapse = "_")
        res_df
      })
      output
    },
    pattern = map(dynamic_dds_fit),
    iteration = "list",
    description = "Extracts results specified in the contrasts object. Returns a list of data frames. Sets names of list items."
  ),
  tar_target(
    name = annotated_results_list,
    command = lapply(results_list, A03_annotate_results, species = "human", id_type = "ensgene"),
    pattern = map(results_list),
    iteration = "list",
    description = "Uses annotables package reference tables to add gene annotations to results data frames."
  ),
  tar_target(
    name = annotated_significant_results,
    command = lapply(annotated_results_list, function(x) x |> dplyr::filter(padj <= 0.05, abs(log2FoldChange) >= 0.58)),
    pattern = map(annotated_results_list),
    iteration = "list",
    description = "Apply FDR and/or log2FoldChange filtering/thresholds to define significant hits. Modify as desired."
  ),
  tar_target(
    name = vst_norm_object,
    command = vst(dynamic_dds_fit),
    pattern = map(dynamic_dds_fit),
    iteration = "list",
    description = "VST normalization should be used for PCA, heatmaps, boxplots etc., but not for any DE testing. Can use rlog() instead, vst faster for datasets with many (>30) samples."
  ),
  tar_target(
    name = vst_norm_counts_matrix,
    command = assay(vst_norm_object),
    pattern = map(vst_norm_object),
    iteration = "list",
    description = "VST normalized counts in matrix form, to use for plots, save as CSV, etc."
  ),
  tar_target(
    name = quickomics_files,
    command = A04_quickomics_export(normalized_dds_object = vst_norm_object,
                                    de_results_list = results_list,
                                    model_name = design_setup$label,
                                    outDir = "./results/Quickomics"),
    pattern = map(vst_norm_object, results_list, design_setup),
    iteration = "list",
    description = "Creates, saves CSV files in outDir, and returns list object of data.frames needed for Quickomics file upload."
  ),
  tar_target(
    name = metascape_files,
    command = A05_Metascape_files(annotated_significant_results),
    pattern = map(annotated_significant_results),
    iteration = "list",
    description = "Creates and saves CSV files of Up and Down DEG hits for each contrast in format for Metascape upload, and returns list object of data.frames."
  ),
  tar_quarto(name = analysis_report,
             path = "./DESeq2_analysis_report.qmd",
             quiet = F
  )
)
