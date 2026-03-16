#' Evaluate deep learning model performance
#'
#' Runs the trained Keras model on the held-out test set and returns a tibble
#' suitable for metric calculation with \pkg{yardstick} (e.g. \code{\link{get_dl_auc}}).
#'
#' @param model_keras A trained Keras model — the \code{$model} element of the list
#'   returned by \code{\link{train_dl}} (i.e. \code{train_dl(...)$model}).
#' @param input_data A list returned by \code{\link{prepare_dl_data}}, containing
#'   \code{test_tbl} (scaled predictor matrix) and \code{y_test_vec} (integer labels).
#'
#' @return A tibble with columns \code{truth} (factor), \code{estimate} (factor), and
#'   \code{class_prob} (numeric predicted probability).
#' @export
evaluate_dl <- function(model_keras, input_data) {
    yhat_prob_vec  <- as.vector(predict(model_keras, as.matrix(input_data$test_tbl)))
    yhat_class_vec <- as.integer(yhat_prob_vec > 0.5)

    tibble::tibble(
        truth      = as.factor(input_data$y_test_vec),
        estimate   = as.factor(yhat_class_vec),
        class_prob = yhat_prob_vec
    )
}
