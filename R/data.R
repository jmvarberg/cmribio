#' Converse MNGC bulk RNAseq dataset
#'
#' RSEM merged gene counts from nf-core/rnaseq v. 3.19.0, from mouse study SRP549060
#' Report ...
#'
#' @format ## `converse_gene_counts`
#' A data frame with 78,317 rows (genes/features) and 14 columns (samples):
#' \describe{
#'   \item{gene_id}{ENSMBL ID}
#'   \item{transcript_id(s)}{transcript IDs associated with ENSMBL IDs}
#'   ...
#' }
#' @source <https://trace.ncbi.nlm.nih.gov/Traces/?view=study&acc=SRP549060>
"converse_gene_counts"

#' Converse nf-core/rnaseq sample sheet
#'
#' Sample sheet with metadata from nf-core/rnasesq processing for converse_gene_counts
#' Report ...
#'
#' @format ## `converse_samplesheet`
#' A data frame with 78,317 rows (genes/features) and 14 columns (samples):
#' \describe{
#'   \item{fastq_1, fastq_2}{paths to raw fastq files for processing}
#'   \item{strandedness}{param passed to nf-core/rnaseq to auto detect strandedness}
#'   \item{sample_title}{Grouping for cell type, replicate for experimental design}
#'   ...
#' }
#' @source <https://trace.ncbi.nlm.nih.gov/Traces/?view=study&acc=SRP549060>
"converse_samplesheet"
