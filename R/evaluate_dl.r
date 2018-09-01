#' Evaluate deep learning model performance
#'
#' A function to evaluate a deep learning model.
#' @param model_keras Keras deep learning model.
#' @param input_data A dataframe containing occurrence data parsed for deep learning using the \code{\link{prepare_dl_data}} function.
#'
#' @return A tibble containing the model estimates.
#' @examples
#' \dontrun{
#' # download benchmarking data
#' benchmarking_data <- get_benchmarking_data("Lynx lynx",
#'                                            limit = 1500)
#'
#' # transform benchmarking data into a format suitable for deep learning
#' # if you have previously used a partitioning method you should specify it here
#' benchmarking_data_dl <- prepare_dl_data(input_data = benchmarking_data$df_data,
#'                                        partitioning_type = "default")
#'
#' # perform sanity checks on the transformed data
#' # for the training set
#' head(benchmarking_data_dl$train_tbl)
#' table(benchmarking_data_dl$y_train_vec)
#'
#' # for the test set
#' head(benchmarking_data_dl$test_tbl)
#' table(benchmarking_data_dl$y_test_vec)
#'
#' # train neural network
#' keras_results <- train_dl(benchmarking_data_dl)
#'
#' # inspect training results
#' keras_results$history
#'
#' # you can also plot them
#' plot(keras_results$history)
#'
#' # create evaluation tibble containing training results
#' keras_evaluation <- evaluate_dl(keras_results$model, benchmarking_data_dl)
#' head(keras_evaluation)
#' }
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
