# Functions for doing pathway/enrichment analysis for DE results (i.e., DESeq2 output)

#' Pull Gene Sets of Interest from msigdbr package
#'
#' @param species "mouse" or "human"; default = "human"
#' @param sets which gene set collections to include, values = "hallmark", "kegg", "wiki", "reactome", "go_bp", "go_cc", "go_mf". Note, "kegg" not available for mouse.
#'
#' @returns data frame of gene sets and their associated genes and information as output by msigdbr::msigdbr()
#' @export
#' @import msigdbr
#' @importFrom rlang .data
#' @importFrom tibble deframe
#' @importFrom limma ids2indices cameraPR
#' @importFrom jmvtools named_group_split
#' @examples
#' gs <- get_genesets(species = "human", sets = "hallmark")
#' head(gs)
get_genesets <- function(species = c("human","mouse"), sets = c("hallmark", "kegg", "wiki", "reactome", "go_bp", "go_cc", "go_mf")) {

  species <- match.arg(species)
  sets <- match.arg(sets, several.ok = TRUE)

  if(species == "mouse") {

    gs <- c()

    if ("hallmark" %in% sets) {
      gs <- c(gs, "Hallmark")
    }
    if ("wiki" %in% sets) {
      gs <- c(gs, "WikiPathways")
    }
    if ("reactome" %in% sets) {
      gs <- c(gs, "`Reactome Pathways`")
    }
    if ("go_bp" %in% sets) {
      gs <- c(gs, "`GO Biological Process`")
    }
    if ("go_cc" %in% sets) {
      gs <- c(gs, "`GO Cellular Component`")
    }
    if ("go_cc" %in% sets) {
      gs <- c(gs, "`GO Molecular Function`")
    }
    if ("kegg" %in% sets) {
      stop("KEGG database not available for mouse.")
    }

    all_gs <- msigdbr::msigdbr(db_species = "MM", species = "mouse")

    selected_gs <- all_gs |>
      dplyr::filter(.data$gs_collection_name %in% gs)

    return(selected_gs)
  }

  if(species == "human") {

    gs <- c()

    if ("hallmark" %in% sets) {
      gs <- c(gs, "Hallmark")
    }
    if ("wiki" %in% sets) {
      gs <- c(gs, "WikiPathways")
    }
    if ("reactome" %in% sets) {
      gs <- c(gs, "`Reactome Pathways`")
    }
    if ("go_bp" %in% sets) {
      gs <- c(gs, "`GO Biological Process`")
    }
    if ("go_cc" %in% sets) {
      gs <- c(gs, "`GO Cellular Component`")
    }
    if ("go_cc" %in% sets) {
      gs <- c(gs, "`GO Molecular Function`")
    }
    if ("kegg" %in% sets) {
      gs <- c(gs, "`KEGG Legacy Pathways`")
    }

    all_gs <- msigdbr::msigdbr(db_species = "HS", species = "human")

    selected_gs <- all_gs |> dplyr::filter(.data$gs_collection_name %in% gs)

    return(selected_gs)

  }

}


#' Run limma::cameraPR
#'
#' @param geneset_df data.frame, containing all gene sets of interest for testing. Created from msigdbr, using cmribio::get_genesets
#' @param de_results data.frame object, containing full DE testing results (not filtered for FDR or logFC). Assumes all comparisons made are present, with that info in a column.
#' @param fc_col character, column in de_results that contains the logFC information. default value = "log2FoldChange"
#' @param ens_col character, column in de_results data frame that contains the ENSEMBL gene IDs. default value = "ensemble_gene_id"
#' @param comp_col character, column in the de_results that contains the test/contrast/comparison name. Used to split the de_results into named logFC vectors for each test.
#'
#' @returns list containing limma::cameraPR results for each contrast/logFC vector tested.
#' @export
#'
run_cameraPR <- function(geneset_df, de_results,
                         fc_col = "log2FoldChange",
                         ens_col = "ensemble_gene_id",
                         comp_col = "test") {

  #split data frame of gene sets into a list
  gs_list <- split(x = geneset_df$ensembl_gene, f = geneset_df$gs_name)

  #convert dataframe with full DE results (not filtered for logFC or FDR) into list of named vectors with logFC values and ENSEMBL IDs as names
  #split by test
  de_list <- de_results |>
    dplyr::select(.data[[fc_col]], .data[[ens_col]], .data[[comp_col]]) |>
    jmvtools::named_group_split(.data[[comp_col]])

  #convert split into named vectors, values = logFC, names = ENSGENE
  de_list_vectors <- lapply(de_list, function(x) {
    x |>
      dplyr::select(.data[[ens_col]], .data[[fc_col]]) |>
      tibble::deframe()
  })

  #This function takes a list of gene sets, and a vector of logFC values with ENSGENE names. Creates and index and runs cameraPR on it.
  index_and_run <- function(gs_list, logFC_vector) {
    cam_index <- limma::ids2indices(gs_list, names(logFC_vector))
    camPR_res <- limma::cameraPR(statistic = logFC_vector, index = cam_index, use.ranks = TRUE)
  }

  #now, we run this on each logFC vector in our list of DE results - one for each comparison made
  camera_results <- lapply(de_list_vectors, index_and_run, gs_list = gs_list)

  return(camera_results)

}


#' Create dot plots of cameraPR results by direction and contrast
#'
#' @param x data frame, containing results from cameraPR (with/without FDR filtering).
#'   Should be combined to include all tests/contrasts/comparisons of interest in the experiment.
#'   Must contain columns: \code{Direction}, \code{Contrast}, \code{NGenes}, \code{GeneSet}, \code{FDR}.
#' @param n_path integer, number of pathways to show for each direction (Up and Down).
#'   Selects the top n based on the strongest enrichment (-log10(FDR)) for Up and Down separately.
#'
#' @return A named list of ggplot objects: \code{list(Up = <plot>, Down = <plot>)}.
#'   You can further modify them with ggplot2 methods.
#'
#' @import ggsci
#' @import ggplot2
#' @import dplyr
#' @import scales
#' @importFrom stringr str_replace_all
#' @importFrom jmvtools named_group_split
#' @importFrom rlang .data abort
#' @importFrom stats reorder
#' @export
#'
camera_dotplot <- function(x, n_path = 10) {

  required_cols <- c("Direction", "Contrast", "NGenes", "GeneSet", "FDR")
  missing <- setdiff(required_cols, names(x))
  if (length(missing) > 0) {
    rlang::abort(
      paste0("Missing required column(s): ", paste(missing, collapse = ", "))
    )
  }

  # Ensure Contrast is a factor
  if (!is.factor(x$Contrast)) {
    message(
      "Contrast column is not a factor. Coercing to factor with default level order. ",
      "If a different order is desired, set levels in the input and re-run."
    )
    x$Contrast <- factor(x$Contrast, levels = unique(x$Contrast))
  }

  # Color mapping to Contrast levels
  contrast_lvls <- levels(x$Contrast)
  n_colors <- length(contrast_lvls)

  if (n_colors <= 10) {
    # npg palette handles up to 10 colors
    contrast_cols <- ggsci::pal_npg("nrc")(n_colors)
  } else {
    # igv palette handles up to 51 colors
    contrast_cols <- ggsci::pal_igv("default")(n_colors)
  }
  names(contrast_cols) <- contrast_lvls

  # Pretty size breaks for NGenes
  ext_fun <- scales::breaks_pretty(n = 4)
  size_breaks <- ext_fun(c(min(x$NGenes, na.rm = TRUE), max(x$NGenes, na.rm = TRUE)))

  # Clean up GeneSet labels and compute MaxSig per (Direction, GeneSet)
  x <- x |>
    dplyr::mutate(GeneSet = stringr::str_replace_all(.data[["GeneSet"]], "_", " ")) |>
    dplyr::group_by(.data[["Direction"]], .data[["GeneSet"]]) |>
    dplyr::mutate(MaxSig = max(-log10(.data[["FDR"]]), na.rm = TRUE))

  # Select top n_path pathways per Direction by MaxSig
  top_gs <- x |>
    dplyr::ungroup() |>
    dplyr::group_by(.data[["Direction"]], .data[["GeneSet"]]) |>
    dplyr::summarise(MaxSigFilt = max(.data[["MaxSig"]], na.rm = TRUE), .groups = "drop") |>
    dplyr::group_by(.data[["Direction"]]) |>
    dplyr::arrange(dplyr::desc(.data[["MaxSigFilt"]])) |>
    dplyr::slice_head(n = n_path) |>
    jmvtools::named_group_split(.data[["Direction"]])

  # UP plot
  up <- x |>
    dplyr::filter(.data[["Direction"]] == "Up", .data[["GeneSet"]] %in% top_gs$Up$GeneSet) |>
    ggplot2::ggplot(ggplot2::aes(
      x = -log10(.data[["FDR"]]),
      y = stats::reorder(.data[["GeneSet"]], .data[["MaxSig"]]),
      size = .data[["NGenes"]],
      fill = .data[["Contrast"]]
    )) +
    ggplot2::geom_point(alpha = 0.7, color = "black", pch = 21) +
    ggplot2::scale_size_area(
      name    = "# Genes in Set",
      breaks  = size_breaks,
      limits  = c(min(size_breaks), max(size_breaks)),
      max_size = 10,
      oob     = scales::oob_squish
    ) +
    ggplot2::facet_wrap(~ .data[["Direction"]]) +
    ggplot2::ylab("") +
    ggplot2::scale_fill_manual(values = contrast_cols) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      strip.background = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(face = "bold", color = "black", size = 12)
    ) +
    ggplot2::guides(fill = ggplot2::guide_legend(override.aes = list(size = 6), order = 1))

  # DOWN plot
  down <- x |>
    dplyr::filter(.data[["Direction"]] == "Down", .data[["GeneSet"]] %in% top_gs$Down$GeneSet) |>
    ggplot2::ggplot(ggplot2::aes(
      x = -log10(.data[["FDR"]]),
      y = stats::reorder(.data[["GeneSet"]], .data[["MaxSig"]]),
      size = .data[["NGenes"]],
      fill = .data[["Contrast"]]
    )) +
    ggplot2::geom_point(alpha = 0.7, color = "black", pch = 21) +
    ggplot2::scale_size_area(
      name    = "# Genes in Set",
      breaks  = size_breaks,
      limits  = c(min(size_breaks), max(size_breaks)),
      max_size = 10,
      oob     = scales::oob_squish
    ) +
    ggplot2::facet_wrap(~ .data[["Direction"]]) +
    ggplot2::ylab("") +
    ggplot2::scale_fill_manual(values = contrast_cols) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      strip.background = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(face = "bold", color = "black", size = 12)
    ) +
    ggplot2::guides(fill = ggplot2::guide_legend(override.aes = list(size = 6), order = 1))

  # Return result
  list(Up = up, Down = down)
}


#expectation: expression matrix with ENSG row IDs (human), input pathway name(s) from msigdbr, and list from msigdbr named by pathway with values of ENS IDs
#' Heatmap of pathway of interest
#'
#' @param expr_mat matrix, expression matrix with ENSEMBL IDs as row names
#' @param gs_list data frame, list of gene sets for species of interest
#' @param pathway_name character, name of pathway to use for heatmap.
#' @param species character, either "mouse" or "human"
#' @param show_rowNames boolean, whether to show row names on pheatmap::pheatmap output.
#' @importFrom pheatmap pheatmap
#' @importFrom grDevices colorRampPalette
#' @returns pheatmap plot object
#' @export
#'
pathway_heatmap <- function(expr_mat, gs_list, pathway_name, species = c("mouse", "human"), show_rowNames = FALSE) {

  #get genes to plot
  goi <- unique(gs_list[[pathway_name]])

  expr <- expr_mat[rownames(expr_mat) %in% goi, ]

  #swap out ensembl IDs for symbols
  expr <- cmribio::swap_ensmbl_for_symbols(expr, species)

  #make heatmap
  if(show_rowNames) {
    pheatmap::pheatmap(expr,
                       cluster_rows = TRUE,
                       cluster_cols = TRUE,
                       scale = "row",
                       color = colorRampPalette(c("darkblue", "white", "firebrick"))(100),
                       show_rownames = TRUE)
  } else {
    pheatmap::pheatmap(expr,
                       cluster_rows = TRUE,
                       cluster_cols = TRUE,
                       scale = "row",
                       color = colorRampPalette(c("darkblue", "white", "firebrick"))(100),
                       show_rownames = FALSE)


  }


}
