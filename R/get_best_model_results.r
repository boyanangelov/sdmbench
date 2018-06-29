#' Extract best model performances
#'
#' @param bmr A bmr object, result of the \code{\link{benchmark_sdm}} function.
#'
#' @return A dataframe containing the best model results (learner name, optimal iteration number and associated AUC).
#' @examples
#' best_results <- get_best_model_results(bmr)
get_best_model_results <- function(bmr) {
    perf <- mlr::getBMRPerformances(bmr, as.df = TRUE)
    best_results <- perf %>%
        dplyr::group_by(learner.id) %>%
        dplyr::top_n(n = 1)
    best_results$task.id <- NULL

    return(best_results)
}
