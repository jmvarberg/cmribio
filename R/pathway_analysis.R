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
    de_list_vectors <- lapply(de_list, tibble::deframe)

    #This function takes a list of gene sets, and a vector of logFC values with ENSGENE names. Creates and index and runs cameraPR on it.
    index_and_run <- function(gs_list, logFC_vector) {
      cam_index <- limma::ids2indices(gs_list, names(logFC_vector))
      camPR_res <- limma::cameraPR(statistic = logFC_vector, index = cam_index, use.ranks = TRUE)
    }

    #now, we run this on each logFC vector in our list of DE results - one for each comparison made
    camera_results <- lapply(gs_list, index_and_run, logFC_vector = de_list_vectors)

    return(camera_results)

}
