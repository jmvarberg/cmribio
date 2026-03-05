#' Initialize Project Directory
#'
#' @param dir Path to parent directory to create subdirectories: data, documents, results, scripts and README.txt template
#' @param overwrite How to handle scenario when 'dir' provided or any of the subdirectories exist. Default "ask" prompts user for how to handle. TRUE overwrites existing, FALSE stops if 'dir' exists.
#'
#' @returns Invisible file path to created 'dir'
#' @export
#'
#'
init_proj <- function(dir = NULL, overwrite = c("ask", TRUE, FALSE)) {
  overwrite <- overwrite[1]

  # 1) Resolve project root 'wd'
  if (is.null(dir)) {
    wd <- getwd()
    message("Using current working directory: ", normalizePath(wd, winslash = "/"))
  } else {
    if (!dir.exists(dir)) {
      message("Parent directory does not exist. Creating it...")
      dir.create(dir, recursive = TRUE, showWarnings = FALSE)
    } else {
      message("Parent directory exists: ", normalizePath(dir, winslash = "/"))
    }
    wd <- dir
  }

  stopifnot(is.character(wd), length(wd) == 1, nzchar(wd))

  # 2) Determine if any managed assets already exist
  subdirs <- c("data", "documents", "results", "scripts")
  readme_path <- file.path(wd, "README.txt")

  existing_assets <- c(
    file.exists(readme_path),
    dir.exists(file.path(wd, subdirs))
  )
  any_managed_exists <- any(existing_assets)

  # If something managed already exists and policy is "ask", handle prompt policy
  if (any_managed_exists && identical(overwrite, "ask")) {
    if (!interactive()) {
      stop(
        "Some project assets already exist, but you provided overwrite='ask' in a non-interactive session.\n",
        "Re-run interactively or specify overwrite=TRUE (recreate managed assets) ",
        "or overwrite=FALSE (only create missing assets)."
      )
    }
    reply <- utils::askYesNo(
      sprintf(
        "Project assets already exist under '%s'. Overwrite standard subdirectories and README?",
        normalizePath(wd, winslash = "/")
      ),
      default = FALSE
    )
    if (isTRUE(reply)) {
      overwrite <- TRUE
    } else if (identical(reply, FALSE)) {
      overwrite <- FALSE
    } else {
      stop("No response received. Aborting to avoid accidental overwrite.")
    }
  }

  # 3) Apply policy to managed assets (never delete the parent dir itself)
  if (isTRUE(overwrite)) {
    for (sd in subdirs) {
      p <- file.path(wd, sd)
      if (dir.exists(p)) unlink(p, recursive = TRUE, force = TRUE)
      dir.create(p, recursive = TRUE, showWarnings = FALSE)
    }
  } else {
    # Create any missing subdirs; leave existing as-is
    for (sd in subdirs) {
      dir.create(file.path(wd, sd), recursive = TRUE, showWarnings = FALSE)
    }
  }

  # README boilerplate (yours, with R version expansion)
  boilerplate <- c(
    "Project Title: <Your Project Name>",
    "",
    paste0("Date: ", as.character.Date(Sys.Date())),
    "",
    "Overview",
    "--------",
    "Add notes about the project and analysis here as needed.",
    "",
    "Data",
    "----",
    "- Describe input data sources and formats.",
    "- Note any preprocessing steps.",
    "",
    "Analysis",
    "--------",
    "- Briefly outline methods, tools, and parameters.",
    "",
    "Reproducibility",
    "---------------",
    paste0("- R version: ", as.character(getRversion())),
    "- Package versions: ",
    "- How to reproduce: ",
    "",
    "Contact",
    "-------",
    "- Author: Your Name",
    "- Email: you@example.com"
  )

  if (isTRUE(overwrite)) {
    writeLines(boilerplate, con = readme_path)
    message("Wrote README at: ", normalizePath(readme_path, winslash = "/"))
  } else {
    if (!file.exists(readme_path)) {
      writeLines(boilerplate, con = readme_path)
      message("Created README at: ", normalizePath(readme_path, winslash = "/"))
    } else {
      message("README.txt already exists; not overwritten (set overwrite=TRUE to replace).")
    }
  }

  invisible(normalizePath(wd, winslash = "/"))
}

#' List available targets pipeline templates
#'
#' @returns List of all targets templates included in the package
#' @export
#'
list_targets_templates <- function() {
  dir <- system.file("templates", "targets-pipelines", package = "cmribio")
  if (!nzchar(dir)) {
    return(character())
  }
  files <- list.files(dir, pattern = "\\.R$", full.names = FALSE)
  unname(files)
}


#' Use targets pipeline templates for bulk RNAseq analysis with DESeq2
#'
#' @param dir default = NULL, which will use current working directory; path to directory to copy tempate files to
#'
#' @returns copies three files: _targets.R (pipeline script), _targets_bulkRNA_DESeq2_functions.R (functions to run pipeline), and DESeq2_analysis_report.qmd (Quarto report template). Also makes copies of the demo counts matrix and sample sheet for testing the pipeline.
#'
#' @export

use_deseq_targets <- function(dir = NULL) {

  # Resolve project directory
  if (is.null(dir)) {
    wd <- getwd()

    reply <- utils::askYesNo(
      sprintf(
        "No directory specified - using current working directory '%s'. Do you want to proceed? Existing versions of the _targets pipeline script, functions and Quarto report file will be overwritten.",
        normalizePath(wd, winslash = "/")
      ),
      default = FALSE
    )
  } else {
    if (!dir.exists(dir)) {
      message("Specified directory does not exist. Creating it now...")
      dir.create(dir, recursive = TRUE, showWarnings = FALSE)
    } else {

      reply <- utils::askYesNo(
        sprintf(
          "Specified directory already exists under '%s'. Do you want to proceed? Existing versions of the _targets pipeline script, functions and Quarto report file will be overwritten.",
          normalizePath(wd, winslash = "/")
        ),
        default = FALSE
      )
    }
    wd <- dir
  }

  #Copy _targets_bulkRNA_DESeq2.R pipeline template into specified directory.
  # Get the full path to the internal template file from the package
  template_path <- system.file("templates", "targets-pipelines", "_targets_bulkRNA_DESeq2.R",
                               package = "cmribio")

  if (template_path == "") {
    stop("Template file not found in the package.")
  }

  # Copy the file to the new location with a new name
  success <- file.copy(
    from = template_path,
    to = file.path(wd, "_targets.R"),
    overwrite = TRUE
  )

  if (!success) {
    stop("File copy failed. Check permissions or paths.")
  }

  # Copy functions file needed for the pipeline.
  functions_path <- system.file("templates", "targets-functions", "_targets_bulkRNA_DESeq2_functions.R",
                               package = "cmribio")

  if (functions_path == "") {
    stop("Pipeline functions file not found in the package.")
  }

  # Copy the file to the new location with a new name
  success <- file.copy(
    from = functions_path,
    to = file.path(wd, "_targets_bulkRNA_DESeq2_functions.R"),
    overwrite = TRUE
  )

  if (!success) {
    stop("Functions script copy failed. Check permissions or paths.")
  }

  # Copy Quarto report file needed for the pipeline.
  report_path <- system.file("templates", "targets-quarto", "_targets_bulkRNA_DESeq2_report.qmd",
                                package = "cmribio")

  if (report_path == "") {
    stop("Pipeline functions file not found in the package.")
  }

  # Copy the file to the new location with a new name
  success <- file.copy(
    from = report_path,
    to = file.path(wd, "DESeq2_analysis_report.qmd"),
    overwrite = TRUE
  )

  if (!success) {
    stop("Functions script copy failed. Check permissions or paths.")
  }

  #Now, make copies of the demo sample sheet and counts matrix in the specified directory.
  #load demo counts data and sample sheet and save them into working directory.
  utils::write.csv(cmribio::demo_samplesheet, file.path(wd, "cmribio_demo_samplesheet.csv"), row.names = F)
  data.table::fwrite(cmribio::demo_counts, file.path(wd, "cmribio_demo_counts_matrix.tsv"), sep = "\t")


}


#' Interactive data tables
#'
#' @param df Data frame
#' @param digits Number of digits to include in formatted numbers.
#' @param ... Additional parameters to pass to `DT::datatable`
#'
#' @return Embedded HTML data table, `DT::datatable` object
#' @import DT tidyselect dplyr
#' @export
#'
#' @examples
#'
#' cmri_datatable(mtcars)
#'
#'
#'
cmri_datatable <- function(df, digits=2, ...) {

  if (!is.data.frame(df)) {
    df <- as.data.frame(df)
  }

  stopifnot("Input object is not coerrcible to a data frame."= is.data.frame(df))

  df |>
    dplyr::mutate(dplyr::across(where(is.numeric), \(x) round(x, digits))) |>
    DT::datatable(extensions = 'Buttons', options = list(
      scrollY="true",
      scrollX="true",
      pageLength = 10,
      lengthMenu = c(10, 25, 50, 100),
      dom = 'Blfrtip',
      buttons = c('copy', 'csv', 'excel', 'pdf', 'print'),
      ...
    )
    )
}

#' Convert ENSMBL IDs to Gene Symbols
#'
#' This is a helper function to simplify the conversion of matrix rownames formatted in ENSMBL ID format (i.e., ENSMUSG00000051951) to the corresponding
#' gene symbols (i.e, Xkr4). This is mostly a helper tool for late stages of analysis with Seurat objects, where you want to make plots showing gene names,
#' or you need to format with gene names as input for other analysis tools. This is also used for preparing the files needed for uploading of datasets
#' to the Single Cell Portal.
#'
#' The approach uses reference tables from the `annotables` package for the conversion purposes. The grcm38 and grch38 are used for conversion for mouse and human, respectively.
#' One-to-many mapping issues are handled by only replacing the ENSMBL ID if it maps to a unique gene name.
#' If multiple ENSMBL IDs map to the same gene symbol, then the feature name is left in ENSMBL format.
#'
#' @param x Input matrix with rownames as ENSMBL IDs
#' @param species Character, either "mouse" or "human" are currently supported.
#'
#' @return Output matrix with rownames converted from ENSMBL IDs to gene names.
#' @importFrom rlang .data abort
#' @export
#'
#' @examples
#' \dontrun{
#' data <- cmribio::demo_counts
#' orig <- rownames(data)
#' new <- swap_ensmbl_for_symbols(data, species = "mouse")
#' head(orig)
#' head(new)
#'}
#'

swap_ensmbl_for_symbols <- function(x, species = c("mouse", "human")) {

  species <- match.arg(species)

  # get the annotable for species
  ref_table <- if (species == "mouse") {
    cmribio::grcm38
  } else {
    cmribio::grch38
  }

  # row/feature names
  eids <- rownames(x)
  if (is.null(eids)) {
    rlang::abort("Input object must have rownames (Ensembl IDs).")
  }

  # map IDs -> symbols
  symbols <- ref_table$symbol[match(eids, ref_table$ensgene)]

  # build df
  df <- data.frame(
    Original = eids,
    New      = symbols,
    stringsAsFactors = FALSE
  )

  # symbols that map to multiple IDs (including handling NAs safely)
  # duplicated() handles NA as duplicated NA; we keep those in multi-matches
  multi_matches <- unique(df$New[duplicated(df$New) & !is.na(df$New)])

  # for multi-mapped symbols, keep the Ensembl ID; otherwise use the symbol
  df <- df |>
    dplyr::mutate(
      Final = dplyr::if_else(
        .data$New %in% multi_matches | is.na(.data$New),
        .data$Original,
        .data$New
      )
    )

  # replace rownames and return
  rownames(x) <- df$Final
  x
}


