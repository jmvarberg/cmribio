#' Generate a standard analysis report from template in the current directory.
#'
#' @param file_name Name for the Quarto report file.
#' @param dir Directory to save the report file to. Default is NULL, which will default to the current working directory.
#' @param ext_name Which template to use. One of c("bcb-report", "bulk-rnaseq"). Use "bcb-report" for general analyses, and "bulk-rnaseq" to perform DESeq2 analysis of RNAseq datasets.
#'
#' @returns Copies template file into working directory.
#' @export
#'
#' @examples
#' if (interactive()) {
#' create_bcb_report(file_name = "BCB172_Analysis", ext_name = "bcb-report")
#' }
create_bcb_report <- function(file_name = NULL, dir = NULL, ext_name = c("bcb-report", "bulk-rnaseq")) {
  if (is.null(file_name)) {
    stop("You must provide a valid file_name")
  }

  if (is.null(dir)) {
    message("Report will be saved in working directory.")
    dir = getwd()
  } else if(!dir.exists(dir)) {
    message(paste0("Creating output directory: ", dir))
    dir.create(dir, recursive = T)
  }

  # check for available extensions
  stopifnot("Specified Report Template not found in package. Available options are 'bcb-report' or 'bulk-rnaseq'" = ext_name %in% c("bcb-report", "bulk-rnaseq"))

  # copy from internals
  if(ext_name == "bcb-report") {

    # Get the full path to the internal template file from the package
    template_path <- system.file("extdata/_extensions/bcb-report/cmri-bcb-report-template.qmd",
                                 package = "cmribio")

    if (template_path == "") {
      stop("Template file not found in the package.")
    }

    # Copy the file to the new location with a new name
    success <- file.copy(
      from = template_path,
      to = file.path(dir, paste0(file_name, ".qmd")),
      overwrite = TRUE
    )

    if (!success) {
      stop("File copy failed. Check permissions or paths.")
    }
  }


  if(ext_name == "bulk-rnaseq") {

    # Get the full path to the internal template file from the package
    template_path <- system.file("extdata/_extensions/bulk-rnaseq/cmri-bcb-bulk-rnaseq-template.qmd",
                                 package = "cmribio")

    if (template_path == "") {
      stop("Template file not found in the package.")
    }

    # Copy the file to the new location with a new name
    success <- file.copy(
      from = template_path,
      to = file.path(dir, paste0(file_name, ".qmd")),
      overwrite = TRUE
    )

    if (!success) {
      stop("File copy failed. Check permissions or paths.")
    }
  }


  # open the new file in the editor
  file.edit(file.path(dir, paste0(file_name, ".qmd")))

}
