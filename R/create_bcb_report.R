#' Generate a standard analysis report from template in the current directory.
#'
#' @param file_name Name for the Quarto report file.
#' @param ext_name Which template to use. One of c("bcb-report", "bulk-rnaseq"). Use "bcb-report" for general analyses, and "bulk-rnaseq" to perform DESeq2 analysis of RNAseq datasets.
#'
#' @returns Copies template file into working directory.
#' @export
#'
#' @examples
#' if (interactive()) {
#' create_bcb_report(file_name = "BCB172_Analysis", ext_name = "bcb-report")
#' }
create_bcb_report <- function(file_name = NULL, ext_name = c("bcb-report", "bulk-rnaseq")) {
  if (is.null(file_name)) {
    stop("You must provide a valid file_name")
  }

  # check for available extensions
  stopifnot("Extension not in package" = ext_name %in% c("bcb-report", "bulk-rnasseq"))

  # check for existing _extensions directory
  if(!file.exists("_extensions")) dir.create("_extensions")
  message("Created '_extensions' folder")

  # create folder
  if(!file.exists(paste0("_extensions/", ext_name))) dir.create(paste0("_extensions/", ext_name))

  # copy from internals
  file.copy(
    from = system.file(paste0("extdata/_extensions/", ext_name), package = "cmribio"),
    to = paste0("_extensions/"),
    overwrite = TRUE,
    recursive = TRUE,
    copy.mode = TRUE
  )

  # logic check to make sure extension files were moved
  n_files <- length(dir(paste0("_extensions/", ext_name)))

  if(n_files >= 2){
    message(paste(ext_name, "was installed to _extensions folder in current working directory."))
  } else {
    message("Extension appears not to have been created")
  }

  if(ext_name == "bcb-report") {
    # create new qmd report based on skeleton
    file.copy("_extensions/bcb-report/cmri-bcb-report-template.qmd",
              paste0(file_name, ".qmd", collapse = ""))
  }

  if(ext_name == "bulk-rnaseq") {

    # create new qmd report based on skeleton
    file.copy("_extensions/bulk-rnaseq/cmri-bcb-bulk-rnaseq-template.qmd",
              paste0(file_name, ".qmd", collapse = ""))

  }

  # open the new file in the editor
  file.edit(paste0(file_name, ".qmd", collapse = ""))

}
