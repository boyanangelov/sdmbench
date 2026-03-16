#' Train deep learning SDM
#'
#' Trains a small fully-connected Keras neural network for binary SDM classification.
#' The architecture is two hidden layers of 13 units (ReLU) with 10% dropout,
#' followed by a sigmoid output layer. Optimised with Adam and binary cross-entropy loss.
#'
#' @importFrom magrittr %>%
#'
#' @param input_data A list returned by \code{\link{prepare_dl_data}}.
#'
#' @return A list with \code{model} (the trained Keras model) and \code{history}
#'   (training history object for plotting with \code{plot(history)}).
#' @export
train_dl <- function(input_data) {
    n_features <- ncol(input_data$train_tbl)

    model_keras <- keras::keras_model_sequential() %>%
        keras::layer_dense(units = 13, kernel_initializer = "uniform",
                           activation = "relu", input_shape = n_features) %>%
        keras::layer_dropout(rate = 0.1) %>%
        keras::layer_dense(units = 13, kernel_initializer = "uniform",
                           activation = "relu") %>%
        keras::layer_dropout(rate = 0.1) %>%
        keras::layer_dense(units = 1, kernel_initializer = "uniform",
                           activation = "sigmoid") %>%
        keras::compile(
            optimizer = "adam",
            loss      = "binary_crossentropy",
            metrics   = c("accuracy")
        )

    history <- keras::fit(
        object           = model_keras,
        x                = as.matrix(input_data$train_tbl),
        y                = input_data$y_train_vec,
        batch_size       = 50,
        epochs           = 100,
        validation_split = 0.3,
        view_metrics     = FALSE,
        verbose          = 0
    )

    list(model = model_keras, history = history)
}
