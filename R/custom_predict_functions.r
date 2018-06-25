#' Custom function for dismo prediction
#'
#' @param model MLR trained model
#' @param data Occurence data
#'
#' @return Vector with predictions
#'
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
    v <-  (v-min(v))/(max(v)-min(v))
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