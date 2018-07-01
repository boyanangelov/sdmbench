#' Plot deep learning SDM map
#'
#' A function that enables the plotting of deep learning predictions on a map.
#' @param raster_data A raster dataset containing the occurence data.
#' @param keras_model A trained deep learning model.
#' @param custom_fun A custom predict function.
#'
#' @return A plot, showing the species distribution.
#' @examples
#' \dontrun{
#' plot_dl_map(benchmarking_data$raster_data$climate_variables, keras_results$model, custom_fun = temp_fun)
#' }
plot_dl_map <- function(raster_data, keras_model, custom_fun) {
    pr <- dismo::predict(raster_data, keras_model, fun = custom_fun)
    raster::plot(pr, main = "DLSDM Map")
}
