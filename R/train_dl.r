#' Train deep learning model
#'
#' @param input_data Parsed deep learning dataframe
#'
#' @return List containing the trained deep learning model, and a history object for performance evaluation
train_dl <- function(input_data) {
    model_keras <- keras::keras_model_sequential()

    model_keras %>%
        keras::layer_dense(units = 13,
                           kernel_initializer = "uniform",
                           activation = "relu",
                           input_shape = ncol(input_data$train_tbl)) %>%
        keras::layer_dropout(rate = 0.1) %>%
        keras::layer_dense(units = 13,
                           kernel_initializer = "uniform",
                           activation = "relu") %>%
        keras::layer_dropout(rate = 0.1) %>%
        keras::layer_dense(units = 1,
                           kernel_initializer = "uniform",
                           activation = "sigmoid") %>%
        keras::compile(optimizer = "adam",
                       loss = "binary_crossentropy",
                   metrics = c("accuracy"))

    history <- keras::fit(object = model_keras,
                          x = as.matrix(input_data$train_tbl),
                          y = input_data$y_train_vec,
                          batch_size = 50,
                          epochs = 100,
                          validation_split = 0.3,
                          view_metrics = FALSE,
                          verbose = 0)

    result_list <- list(model = model_keras,
                        history = history)

    return(result_list)
}
