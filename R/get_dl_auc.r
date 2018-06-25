#' Extract AUC from keras evaluation
#'
#' @param keras_evaluation Table containing the keras evaluation
#'
#' @return AUC of the tested keras model
get_dl_auc <- function(keras_evaluation) {
    keras_auc <- keras_evaluation %>%
        yardstick::pr_auc(truth, class_prob)

    return(keras_auc)
}
