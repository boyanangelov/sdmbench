#' Custom functions for dismo prediction
#'
#'
#' A collection of functions that enable the usage of mlr model predictions with dismo.
#' @param model MLR trained model.
#' @param data A dataframe containing occurrence data.
#' @importFrom stats predict
#'
#' @return A vector with predictions.
customPredictFun <- function(model, data) {
    v <- predict(model, data, type = "prob")
    v <- as.data.frame(v)
    colnames(v) <- c("absence", "presence")
    return(v$presence)
}

customPredictFunLogreg <- function(model, data) {
    v <- predict(model, data, type = "response")
    return(v)
}

customPredictFunGBM <- function(model, data) {
    v <- predict(model, data, type = "response", n.trees = model$n.trees)
    # scale results
    v <-  (v - min(v))/(max(v) - min(v))
    return(1 - v)
}

customPredictFunMultinom <- function(model, data) {
    v <- predict(model, data, type = "probs")
    return(v)
}

customPredictFunNB <- function(model, data) {
    v <- predict(model, data, type = "raw")
    v <- as.data.frame(v)
    colnames(v) <- c("absence", "presence")
    return(v$presence)
}

customPredictFunXGB <- function(model, data) {
    data <- data.matrix(data)
    v <- predict(model, data)
    return(v)
}

customPredictFunKSVM <- function(model, data) {
    v <- raster::predict(model, data, type = "prob")
    v <- as.data.frame(v)
    colnames(v) <- c("absence", "presence")
    return(v$presence)
}
