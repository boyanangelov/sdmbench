#' Plot SDM map
#'
#' @param raster_data A raster dataset containing the occurence data.
#' @param bmr_models A list of models extracted from the benchmarking bmr object.
#' @param model_id A character string indicating the model id of interest.
#' @param model_iteration A numeric vlaue indicating the model iteration of interest.
#'
#' @return A plot, showing the species distribution.
#' @examples
#' \dontrun{
#' plot_sdm_map(raster_data = benchmarking_data$raster_data$climate_variables, bmr_models = bmr_models, model_id = best_results$learner.id[4], model_iteration = best_results$iter[4])
#' }
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
    } else if (model_id == "classif.ksvm") {
        model <- bmr_models$benchmarking_data[[model_id]][[model_iteration]]$learner.model
        pr <- dismo::predict(raster_data, model, fun = customPredictFunKSVM)
        raster::plot(pr, main = model_id)
    }
    else {
        model <- bmr_models$benchmarking_data[[model_id]][[model_iteration]]$learner.model
        pr <- dismo::predict(raster_data, model, fun = customPredictFun)
        raster::plot(pr, main = model_id)
    }
}