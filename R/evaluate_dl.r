#' Evaluate deep learning model performance
#'
#' @param model_keras Keras deep learning model
#' @param input_data Data parsed in a suitable way by using the  \code{\link{prepare_dl_data}} function.
#'
#' @return A table containing the model estimates
#'
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
