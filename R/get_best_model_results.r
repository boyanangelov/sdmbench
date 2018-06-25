#' Extract best model performances
#'
#' @param bmr BMR object, result of the \code{\link{benchmark_sdm}} function.
#'
#' @return Dataframe containing the best model results
get_best_model_results <- function(bmr) {
    perf <- mlr::getBMRPerformances(bmr, as.df = TRUE)
    best_results <- perf %>% dplyr::group_by(iter, learner.id) %>%
        dplyr::slice(which.max(auc)) %>%
        head(NROW(perf)/length(unique(perf$iter)))
    best_results$task.id <- NULL

    return(best_results)
}
