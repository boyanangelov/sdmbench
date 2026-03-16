#' Plot SDM map
#'
#' Generates a static or interactive map of species distribution predictions for a
#' specific learner from a benchmark result.
#'
#' @param raster_data The \code{raster_data} list element from \code{\link{get_benchmarking_data}}.
#' @param bmr A \code{BenchmarkResult} object from \code{\link{benchmark_sdm}}.
#' @param learner_id A character string: the mlr3 learner id to plot (e.g. \code{"classif.ranger"}).
#' @param iteration An integer indicating which CV fold's model to use (default: 1).
#' @param map_type A character string: \code{"static"} (default) or \code{"interactive"}.
#'
#' @return For \code{"static"}: called for its side effect (plot). For \code{"interactive"}:
#'   a \pkg{leaflet} widget.
#' @export
plot_sdm_map <- function(raster_data, bmr, learner_id, iteration = 1, map_type = "static") {
    # Extract the underlying model from the BenchmarkResult
    rr_list <- bmr$resample_results
    rr      <- rr_list[rr_list$learner_id == learner_id, ]$resample_result[[1]]
    model   <- rr$learners[[iteration]]$model

    pred_fun <- .get_predict_fun(learner_id)
    pr       <- terra::predict(raster_data$climate_variables, model, fun = pred_fun)

    .render_map(pr, raster_data$coords_presence, title = learner_id, map_type = map_type)
}

# -- internal helpers ---------------------------------------------------------

.render_map <- function(pr, coords_presence, title, map_type) {
    if (map_type == "static") {
        terra::plot(pr, main = title)
    } else if (map_type == "interactive") {
        pal <- leaflet::colorNumeric(
            c("#ffdbe2", "#fff56b", "#58ff32"),
            terra::values(pr),
            na.color = "transparent"
        )
        leaflet::leaflet(data = coords_presence) |>
            leaflet::addTiles() |>
            leaflet::addRasterImage(raster::raster(pr), colors = pal, opacity = 0.5) |>
            leaflet::addLegend(
                title   = "Habitat Suitability",
                pal     = pal,
                values  = terra::values(pr),
                opacity = 1
            )
    }
}
