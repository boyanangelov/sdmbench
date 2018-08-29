#' Plot deep learning SDM map
#'
#' A function that enables the plotting of deep learning predictions on a map.
#' @param raster_data A raster dataset containing the occurrence data.
#' @param keras_model A trained deep learning model.
#' @param custom_fun A custom predict function.
#' @param map_type A logical indicating if the map should be static or interactive.
#' @return An interactive leaflet map, showing the species distribution.
#' @examples
#' \dontrun{
#' # download benchmarking data
#' benchmarking_data <- get_benchmarking_data("Lynx lynx",
#'                                            limit = 1500,
#'                                            climate_resolution = 10)
#'
#' # transform benchmarking data into a format suitable for deep learning
#' # if you have previously used a partitioning method you should specify it here
#' benchmarking_data_dl <- prepare_dl_data(input_data = benchmarking_data$df_data,
#'                                        partitioning_type = "default")
#'
#' # perform sanity check on the transformed dataset
#' # for the training set
#' head(benchmarking_data_dl$train_tbl)
#' table(benchmarking_data_dl$y_train_vec)
#'
#' # for the test set
#' head(benchmarking_data_dl$test_tbl)
#' table(benchmarking_data_dl$y_test_vec)
#'
#' # train neural network
#' keras_results <- train_dl(benchmarking_data_dl)
#'
#' # this function is needed for plotting
#' temp_fun <- function(model, input_data) {
#'   input_data <- tibble::as_tibble(input_data)
#'   data <- recipes::bake(benchmarking_data_dl$rec_obj, newdata = input_data)
#'   v <- keras::predict_proba(object = model, x = as.matrix(data))
#'   as.vector(v)
#' }
#'
#' # plot SDM map of neural network predictions
#' # change the map_type argument if you want a dynamic leaflet map
#' plot_dl_map(benchmarking_data$raster_data$climate_variables,
#'            keras_results$model,
#'            custom_fun = temp_fun,
#'            map_type = "static")
#'}
plot_dl_map <- function(raster_data, keras_model, custom_fun, map_type = "static") {
    pr <- dismo::predict(raster_data$climate_variables, keras_model, fun = custom_fun)
    if (map_type == "static") {
        raster::plot(pr, main = "DL SDM Map")
    } else if (map_type == "interactive") {
        pal <- leaflet::colorNumeric(c("#ffdbe2", "#fff56b", "#58ff32"), raster::values(pr), na.color = "transparent")
        leaflet::leaflet(data = raster_data$coords_presence) %>%
            leaflet::addTiles() %>%
            leaflet::addRasterImage(pr, colors = pal, opacity = 0.5) %>%
            leaflet::addLegend(title = "Habitat Suitability", pal = pal, values = raster::values(pr), opacity = 1)
    }
}
