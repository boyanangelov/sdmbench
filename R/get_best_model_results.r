#' Extract best per-fold AUC for each learner
#'
#' For each learner in a benchmark result, returns the single CV fold that achieved
#' the highest ROC-AUC. Useful for a quick ranking, but note this is the best fold,
#' not the mean across folds. For mean AUC use
#' \code{bmr$aggregate(mlr3::msr("classif.auc"))} directly.
#'
#' @param bmr A \code{BenchmarkResult} object returned by \code{\link{benchmark_sdm}}.
#'
#' @return A data frame with columns \code{learner_id}, \code{iteration} (fold index),
#'   and \code{classif.auc} (best ROC-AUC for that learner).
#' @examples
#' \dontrun{
#' bmr <- benchmark_sdm(benchmarking_data$df_data,
#'                      learners = list(mlr3::lrn("classif.ranger", predict_type = "prob")))
#' get_best_model_results(bmr)
#' }
#' @export
get_best_model_results <- function(bmr) {
    perf <- as.data.frame(bmr$score(mlr3::msr("classif.auc")))
    perf |>
        dplyr::group_by(learner_id) |>
        dplyr::slice_max(order_by = classif.auc, n = 1, with_ties = FALSE) |>
        dplyr::ungroup() |>
        dplyr::select(learner_id, iteration, classif.auc)
}
