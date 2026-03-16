#' @title sdmbench: Benchmark Species Distribution Models
#'
#' @description Tools and functions to benchmark Species Distribution Models (SDMs)
#' using modern R spatial (\pkg{terra}, \pkg{geodata}) and machine learning
#' (\pkg{mlr3}, \pkg{mlr3learners}) packages. A Shiny GUI is provided for non-technical users.
#'
#' @section Typical workflow:
#'
#' \enumerate{
#'   \item \code{\link{get_benchmarking_data}} — download GBIF occurrences and WorldClim
#'     climate variables.
#'   \item \code{\link{partition_data}} — apply spatial blocking to reduce autocorrelation.
#'   \item \code{\link{benchmark_sdm}} — cross-validate a list of \pkg{mlr3} learners.
#'   \item \code{\link{get_best_model_results}} — summarise AUC by learner.
#'   \item \code{\link{plot_sdm_map}} — render static or interactive habitat suitability maps.
#' }
#'
#' For deep learning: \code{\link{prepare_dl_data}} → \code{\link{train_dl}} →
#' \code{\link{evaluate_dl}} → \code{\link{get_dl_auc}} → \code{\link{plot_dl_map}}.
#'
#' For MaxEnt (requires maxent.jar): \code{\link{evaluate_maxent}}.
#'
#' Start the GUI with \code{\link{run_sdmbench}}.
#'
#' @name sdmbench
#' @docType package
NULL
