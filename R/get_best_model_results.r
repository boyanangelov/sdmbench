#' Extract best model performances
#'
#' @param bmr A bmr object, result of the \code{\link{benchmark_sdm}} function.
#'
#' @return A dataframe containing the best model results (learner name, optimal iteration number and associated AUC).
#' @examples
#' \dontrun{
#' # download benchmarking data
#' benchmarking_data <- get_benchmarking_data("Lynx lynx",
#'                                            limit = 1500)
#'
#' # create a list of algorithms to compare
#' learners <- list(mlr::makeLearner("classif.randomForest",
#'                                   predict.type = "prob"),
#'                  mlr::makeLearner("classif.logreg",
#'                                   predict.type = "prob"))
#'
#' # run the model benchmarking process
#' bmr <- benchmark_sdm(benchmarking_data$df_data,
#'                      learners = learners,
#'                      dataset_type = "default",
#'                      sample = FALSE)
#'
#' # get best model results
#' # you should obtain a dataframe containing the highest performing (by AUC)
#' # algorithm name, iteration and associated AUC
#' best_results <- get_best_model_results(bmr)
#' best_results
#' }
#' @export
get_best_model_results <- function(bmr) {
    perf <- mlr::getBMRPerformances(bmr, as.df = TRUE)
    best_results <- perf %>%
        dplyr::group_by(learner.id) %>%
        dplyr::top_n(n = 1)
    best_results$task.id <- NULL

    return(best_results)
}
