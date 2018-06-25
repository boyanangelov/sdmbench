#' Plot SDM map
#'
#' @param raster_data Raster data
#' @param bmr_models Models extracted from the benchmarking bmr object
#' @param model_id The model id of interest
#' @param model_iteration The model iteration of interesst
#'
#' @return SDM Map plot
plot_sdm_map <- function(raster_data, bmr_models, model_id, model_iteration) {
    if (model_id == "classif.logreg") {
        model <- bmr_models$benchmarking_data[[model_id]][[model_iteration]]$learner.model
        pr <- dismo::predict(raster_data, model, fun = customPredictFunLogreg)
        raster::plot(pr, main = model_id)
    } else if (model_id == "classif.gbm") {
        model <- bmr_models$benchmarking_data[[model_id]][[model_iteration]]$learner.model
        pr <- dismo::predict(raster_data, model, fun = customPredictFunGBM)
        raster::plot(pr, main = model_id)
    } else if (model_id == "classif.multinom") {
        model <- bmr_models$benchmarking_data[[model_id]][[model_iteration]]$learner.model
        pr <- dismo::predict(raster_data, model, fun = customPredictFunMultinom)
        raster::plot(pr, main = model_id)
    } else if (model_id == "classif.naiveBayes") {
        model <- bmr_models$benchmarking_data[[model_id]][[model_iteration]]$learner.model
        pr <- dismo::predict(raster_data, model, fun = customPredictFunNB)
        raster::plot(pr, main = model_id)
    } else if (model_id == "classif.xgboost") {
        model <- bmr_models$benchmarking_data[[model_id]][[model_iteration]]$learner.model
        pr <- dismo::predict(raster_data, model, fun = customPredictFunXGB)
        raster::plot(pr, main = model_id)
    } else {
        model <- bmr_models$benchmarking_data[[model_id]][[model_iteration]]$learner.model
        pr <- dismo::predict(raster_data, model, fun = customPredictFun)
        raster::plot(pr, main = model_id)
    }
}