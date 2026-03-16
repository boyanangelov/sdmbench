#' Custom predict functions for terra/dismo raster prediction
#'
#' These functions are used internally by \code{\link{plot_sdm_map}} to apply trained
#' mlr3 learner models to raster data via \code{terra::predict}.
#' Each function accepts the underlying model object (extracted from the mlr3 learner)
#' and a data frame of raster cell values, and returns a numeric vector of predictions.
#'
#' @param model A fitted model object (the \code{$model} slot of an mlr3 learner).
#' @param data A data frame of predictor values for each raster cell.
#' @importFrom stats predict
#'
#' @return A numeric vector of predicted probabilities (presence).
#' @name custom_predict_functions
NULL

customPredictFun <- function(model, data) {
    v <- predict(model, data, type = "prob")
    v <- as.data.frame(v)
    colnames(v) <- c("absence", "presence")
    v$presence
}

customPredictFunLogreg <- function(model, data) {
    as.vector(predict(model, data, type = "response"))
}

customPredictFunMultinom <- function(model, data) {
    as.vector(predict(model, data, type = "probs"))
}

customPredictFunNB <- function(model, data) {
    v <- predict(model, data, type = "raw")
    v <- as.data.frame(v)
    colnames(v) <- c("absence", "presence")
    v$presence
}

customPredictFunXGB <- function(model, data) {
    as.vector(predict(model, data.matrix(data)))
}

customPredictFunKSVM <- function(model, data) {
    v <- predict(model, data, type = "probabilities")
    v <- as.data.frame(v)
    colnames(v) <- c("absence", "presence")
    v$presence
}

customPredictFunRanger <- function(model, data) {
    v <- predict(model, data)$predictions
    v <- as.data.frame(v)
    colnames(v) <- c("absence", "presence")
    v$presence
}

# Map mlr3 learner IDs to their predict functions
.predict_fun_lookup <- list(
    "classif.log_reg"    = customPredictFunLogreg,
    "classif.multinom"   = customPredictFunMultinom,
    "classif.naive_bayes" = customPredictFunNB,
    "classif.xgboost"    = customPredictFunXGB,
    "classif.svm"        = customPredictFunNB,
    "classif.ksvm"       = customPredictFunKSVM,
    "classif.ranger"     = customPredictFunRanger
)

#' Select the appropriate predict function for a given learner
#' @param learner_id Character string: the mlr3 learner id.
#' @return A predict function.
.get_predict_fun <- function(learner_id) {
    fn <- .predict_fun_lookup[[learner_id]]
    if (is.null(fn)) customPredictFun else fn
}
