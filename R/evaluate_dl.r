#' Evaluate deep learning model performance
#'
#' A function to evaluate a deep learning model.
#' @param model_keras Keras deep learning model.
#' @param input_data A dataframe containing occurrence data parsed for deep learning using the \code{\link{prepare_dl_data}} function.
#'
#' @return A tibble containing the model estimates.
#' @examples
#' benchmarking_data <- get_benchmarking_data("Lynx lynx", limit = 1500, climate_resolution = 10)
#' benchmarking_data_dl <- prepare_dl_data(benchmarking_data$df_data, "default")
#' keras_results <- train_dl(benchmarking_data_dl)
#' keras_evaluation <- evaluate_dl(keras_results$model, benchmarking_data_dl)
evaluate_dl <- function(model_keras, input_data) {
    yhat_keras_class_vec <- keras::predict_classes(object = model_keras,
                                                   x = as.matrix(input_data$test_tbl)) %>%
        as.vector()

    yhat_keras_prob_vec <- keras::predict_proba(object = model_keras,
                                                x = as.matrix(input_data$test_tbl)) %>%
        as.vector()

    estimates_keras_tbl <- tibble::tibble(truth = as.factor(input_data$y_test_vec),
                                          estimate = as.factor(yhat_keras_class_vec),
        class_prob = yhat_keras_prob_vec)

    return(estimates_keras_tbl)
}
