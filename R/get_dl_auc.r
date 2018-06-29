#' Extract AUC from keras evaluation
#'
#' @param keras_evaluation A table containing the keras evaluation.
#'
#' @return A numeric value indicating the AUC of the tested keras model.
#' @examples
#' keras_auc <- get_dl_auc(keras_evaluation)
get_dl_auc <- function(keras_evaluation) {
    keras_auc <- keras_evaluation %>%
        yardstick::pr_auc(truth, class_prob)

    return(round(keras_auc, 3))
}
