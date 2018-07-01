#' Extract AUC from keras evaluation
#'
#' @param keras_evaluation A table containing the keras evaluation.
#'
#' @return A numeric value indicating the AUC of the tested keras model.
#' @examples
#' benchmarking_data <- get_benchmarking_data("Lynx lynx", limit = 1500, climate_resolution = 10)
#' benchmarking_data_dl <- prepare_dl_data(benchmarking_data$df_data, "default")
#' keras_results <- train_dl(benchmarking_data_dl)
#' keras_evaluation <- evaluate_dl(keras_results$model, benchmarking_data_dl)
#' keras_auc <- get_dl_auc(keras_evaluation)
get_dl_auc <- function(keras_evaluation) {
    keras_auc <- keras_evaluation %>%
        yardstick::pr_auc(truth, class_prob)

    return(round(keras_auc, 3))
}
