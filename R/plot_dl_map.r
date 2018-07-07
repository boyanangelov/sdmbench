#' Plot deep learning SDM map
#'
#' A function that enables the plotting of deep learning predictions on a map.
#' @param raster_data A raster dataset containing the occurence data.
#' @param keras_model A trained deep learning model.
#' @param custom_fun A custom predict function.
#' @param map_type A logical indicating if the map should be static or interactive
#' @return An interactive leaflet map, showing the species distribution.
#' @examples
#' \dontrun{
#' plot_dl_map(benchmarking_data$raster_data$climate_variables, keras_results$model, custom_fun = temp_fun, map_type = "static")
#' }
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
