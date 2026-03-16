#' Compute precision-recall AUC for a deep learning model
#'
#' Computes the area under the precision-recall curve (PR-AUC) using
#' \code{\link[yardstick]{pr_auc}}. Note that this is PR-AUC, not ROC-AUC.
#'
#' @importFrom magrittr %>%
#'
#' @param keras_evaluation A tibble returned by \code{\link{evaluate_dl}}, with columns
#'   \code{truth} (factor), \code{estimate} (factor), and \code{class_prob} (numeric).
#'
#' @return A numeric scalar: the PR-AUC of the model, rounded to three decimal places.
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
#' @export
get_dl_auc <- function(keras_evaluation) {
    keras_auc_df <- keras_evaluation %>%
        yardstick::pr_auc(truth, class_prob)
    

    return(round(keras_auc_df$.estimate, 3))
}
