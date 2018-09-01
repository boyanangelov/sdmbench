#' Extract AUC from keras evaluation
#'
#' @param keras_evaluation A table containing the keras evaluation.
#'
#' @return A numeric value indicating the AUC of the tested keras model.
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
#' # perform sanity check on the transformed dataset
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
#'
#' # compute AUC
#' keras_auc <- get_dl_auc(keras_evaluation)
#'
#' # print AUC
#' keras_auc
#' }
get_dl_auc <- function(keras_evaluation) {
    keras_auc <- keras_evaluation %>%
        yardstick::pr_auc(truth, class_prob)

    return(round(keras_auc, 3))
}
