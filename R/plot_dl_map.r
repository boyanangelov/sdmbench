#' Plot deep learning SDM map
#'
#' Generates a static or interactive map of species distribution predictions from a
#' trained Keras model applied to a climate raster.
#'
#' @param raster_data The \code{raster_data} list element from \code{\link{get_benchmarking_data}}.
#' @param keras_model A trained Keras model returned by \code{\link{train_dl}}.
#' @param custom_fun A function with signature \code{function(model, data)} that applies the
#'   Keras model to a data frame of predictor values and returns a numeric vector of predictions.
#' @param map_type A character string: \code{"static"} (default) or \code{"interactive"}.
#'
#' @return For \code{"static"}: called for its side effect (plot). For \code{"interactive"}:
#'   a \pkg{leaflet} widget.
#' @export
plot_dl_map <- function(raster_data, keras_model, custom_fun, map_type = "static") {
    pr <- terra::predict(raster_data$climate_variables, keras_model, fun = custom_fun)
    .render_map(pr, raster_data$coords_presence, title = "DL SDM Map", map_type = map_type)
}
