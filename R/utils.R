#' Initialize Project Directory
#'
#' @param dir Path to parent directory to create subdirectories: data, documents, results, scripts and README.txt template
#' @param overwrite How to handle scenario when 'dir' provided or any of the subdirectories exist. Default "ask" prompts user for how to handle. TRUE overwrites existing, FALSE stops if 'dir' exists.
#'
#' @returns Invisible file path to created 'dir'
#' @export
#'
#' @examples
#' \dontrun {
#' init_proj(dir = "./test_init", overwrite = "ask")
#' }
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
