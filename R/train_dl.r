#' Train deep learning SDM
#'
#' @param input_data A dataframe containing parsed and processed deep leanring data.
#'
#' @return A list containing the trained deep learning model object and a history object for performance evaluation.
#' @examples
#' benchmarking_data <- get_benchmarking_data("Lynx lynx", limit = 1500, climate_resolution = 10)
#' benchmarking_data_dl <- prepare_dl_data(benchmarking_data$df_data, "default")
#' keras_results <- train_dl(benchmarking_data_dl)
train_dl <- function(input_data) {
    # initialize model
    model_keras <- keras::keras_model_sequential()

    # specify network architecture
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

    # train model
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
