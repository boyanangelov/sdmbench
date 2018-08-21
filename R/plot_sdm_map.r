#' Plot SDM map
#'
#' @param raster_data A raster dataset containing the occurence data.
#' @param bmr_models A list of models extracted from the benchmarking bmr object.
#' @param model_id A character string indicating the model id of interest.
#' @param model_iteration A numeric value indicating the model iteration of interest.
#' @param map_type A logical indicating if the map should be static or interactive.
#'
#' @return An interactive leaflet map, showing the species distribution.
#' @examples
#' \dontrun{
#' plot_sdm_map(raster_data = benchmarking_data$raster_data$climate_variables, bmr_models = bmr_models, model_id = best_results$learner.id[4], model_iteration = best_results$iter[4], map_type = "static")
#' }
plot_sdm_map <- function(raster_data, bmr_models, model_id, model_iteration, map_type = "static") {
    if (model_id == "classif.logreg") {
        model <- bmr_models$benchmarking_data[[model_id]][[model_iteration]]$learner.model
        pr <- dismo::predict(raster_data$climate_variables, model, fun = customPredictFunLogreg)
        if (map_type == "static") {
            raster::plot(pr, main = model_id)
        } else if (map_type == "interactive") {
            pal <- leaflet::colorNumeric(c("#ffdbe2", "#fff56b", "#58ff32"), raster::values(pr), na.color = "transparent")
            leaflet::leaflet(data = raster_data$coords_presence) %>%
                leaflet::addTiles() %>%
                leaflet::addRasterImage(pr, colors = pal, opacity = 0.5) %>%
                leaflet::addLegend(title = "Habitat Suitability", pal = pal, values = raster::values(pr), opacity = 1)
        }

    } else if (model_id == "classif.gbm") {
        model <- bmr_models$benchmarking_data[[model_id]][[model_iteration]]$learner.model
        pr <- dismo::predict(raster_data$climate_variables, model, fun = customPredictFunGBM)
        if (map_type == "static") {
            raster::plot(pr, main = model_id)
        } else if (map_type == "interactive") {
            pal <- leaflet::colorNumeric(c("#ffdbe2", "#fff56b", "#58ff32"), raster::values(pr), na.color = "transparent")
            leaflet::leaflet(data = raster_data$coords_presence) %>%
                leaflet::addTiles() %>%
                leaflet::addRasterImage(pr, colors = pal, opacity = 0.5) %>%
                leaflet::addLegend(title = "Habitat Suitability", pal = pal, values = raster::values(pr), opacity = 1)
        }


    } else if (model_id == "classif.multinom") {
        model <- bmr_models$benchmarking_data[[model_id]][[model_iteration]]$learner.model
        pr <- dismo::predict(raster_data$climate_variables, model, fun = customPredictFunMultinom)
        if (map_type == "static") {
            raster::plot(pr, main = model_id)
        } else if (map_type == "interactive") {
            pal <- leaflet::colorNumeric(c("#ffdbe2", "#fff56b", "#58ff32"), raster::values(pr), na.color = "transparent")
            leaflet::leaflet(data = raster_data$coords_presence) %>%
                leaflet::addTiles() %>%
                leaflet::addRasterImage(pr, colors = pal, opacity = 0.5) %>%
                leaflet::addLegend(title = "Habitat Suitability", pal = pal, values = raster::values(pr), opacity = 1)
        }

    } else if (model_id == "classif.naiveBayes") {
        model <- bmr_models$benchmarking_data[[model_id]][[model_iteration]]$learner.model
        pr <- dismo::predict(raster_data$climate_variables, model, fun = customPredictFunNB)
        if (map_type == "static") {
            raster::plot(pr, main = model_id)
        } else if (map_type == "interactive") {
            pal <- leaflet::colorNumeric(c("#ffdbe2", "#fff56b", "#58ff32"), raster::values(pr), na.color = "transparent")
            leaflet::leaflet(data = raster_data$coords_presence) %>%
                leaflet::addTiles() %>%
                leaflet::addRasterImage(pr, colors = pal, opacity = 0.5) %>%
                leaflet::addLegend(title = "Habitat Suitability", pal = pal, values = raster::values(pr), opacity = 1)
        }

    } else if (model_id == "classif.xgboost") {
        model <- bmr_models$benchmarking_data[[model_id]][[model_iteration]]$learner.model
        pr <- dismo::predict(raster_data$climate_variables, model, fun = customPredictFunXGB)
        if (map_type == "static") {
            raster::plot(pr, main = model_id)
        } else if (map_type == "interactive") {
            pal <- leaflet::colorNumeric(c("#ffdbe2", "#fff56b", "#58ff32"), raster::values(pr), na.color = "transparent")
            leaflet::leaflet(data = raster_data$coords_presence) %>%
                leaflet::addTiles() %>%
                leaflet::addRasterImage(pr, colors = pal, opacity = 0.5) %>%
                leaflet::addLegend(title = "Habitat Suitability", pal = pal, values = raster::values(pr), opacity = 1)
        }

    } else if (model_id == "classif.ksvm") {
        model <- bmr_models$benchmarking_data[[model_id]][[model_iteration]]$learner.model
        pr <- dismo::predict(raster_data$climate_variables, model, fun = customPredictFunKSVM)
        if (map_type == "static") {
            raster::plot(pr, main = model_id)
        } else if (map_type == "interactive") {
            pal <- leaflet::colorNumeric(c("#ffdbe2", "#fff56b", "#58ff32"), raster::values(pr), na.color = "transparent")
            leaflet::leaflet(data = raster_data$coords_presence) %>%
                leaflet::addTiles() %>%
                leaflet::addRasterImage(pr, colors = pal, opacity = 0.5) %>%
                leaflet::addLegend(title = "Habitat Suitability", pal = pal, values = raster::values(pr), opacity = 1)
        }

    }
    else {
        model <- bmr_models$benchmarking_data[[model_id]][[model_iteration]]$learner.model
        pr <- dismo::predict(raster_data$climate_variables, model, fun = customPredictFun)
        if (map_type == "static") {
            raster::plot(pr, main = model_id)
        } else if (map_type == "interactive") {
            pal <- leaflet::colorNumeric(c("#ffdbe2", "#fff56b", "#58ff32"), raster::values(pr), na.color = "transparent")
            leaflet::leaflet(data = raster_data$coords_presence) %>%
                leaflet::addTiles() %>%
                leaflet::addRasterImage(pr, colors = pal, opacity = 0.5) %>%
                leaflet::addLegend(title = "Habitat Suitability", pal = pal, values = raster::values(pr), opacity = 1)
        }

    }
}
