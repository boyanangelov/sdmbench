#' Plot SDM map from deep learning predictions
#'
#' @param raster_data Raster dataset containing the data
#' @param keras_model Trained deep learning model
#' @param custom_fun Custom predict function to enable the prediction
#'
#' @return Plot of SDM
plot_dl_map <- function(raster_data, keras_model, custom_fun) {
    pr <- dismo::predict(raster_data, keras_model, fun = custom_fun)
    raster::plot(pr, main = "DLSDM Map")
}
