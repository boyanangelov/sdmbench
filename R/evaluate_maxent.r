#' Evaluate MaxEnt model performance
#'
#' Runs \code{\link[ENMeval]{ENMevaluate}} with the \code{maxent.jar} algorithm and selects
#' the best model by mean validation AUC.
#'
#' Tuning is fixed to linear feature class only (\code{fc = "L"}) and regularisation
#' multipliers \code{rm = c(1, 2)}. The best model is chosen as the one with the
#' highest mean validation AUC across partitions.
#'
#' Requires \code{maxent.jar} to be present in the \pkg{dismo} Java directory
#' (typically \code{system.file("java", package = "dismo")}). See \code{?dismo::maxent}
#' for installation instructions.
#'
#' @param raster_data The \code{raster_data} list element from \code{\link{get_benchmarking_data}}.
#' @param method A character string: the spatial partitioning method passed to
#'   \code{ENMeval::ENMevaluate}. One of \code{"jackknife"}, \code{"randomkfold"},
#'   \code{"user"}, \code{"block"}, \code{"checkerboard1"}, \code{"checkerboard2"}.
#'
#' @return A list with \code{best_auc} (numeric) and \code{best_model_pr} (SpatRaster of
#'   predicted habitat suitability).
#' @export
evaluate_maxent <- function(raster_data, method) {
    eval <- ENMeval::ENMevaluate(
        occs       = raster_data$coords_presence,
        envs       = raster_data$climate_variables,
        bg         = raster_data$background,
        algorithm  = "maxent.jar",
        partitions = method,
        tune.args  = list(fc = c("L"), rm = c(1, 2))
    )

    # Column name for mean validation AUC changed in ENMeval 2.0
    auc_col <- if ("auc.val.avg" %in% names(eval@results)) "auc.val.avg" else "avg.test.AUC"
    best_idx <- which.max(eval@results[[auc_col]])
    best_auc <- eval@results[[auc_col]][[best_idx]]

    # Predict over climate raster (convert to Raster* for dismo compatibility)
    climate_raster <- raster::stack(raster_data$climate_variables)
    best_model_pr  <- terra::rast(dismo::predict(climate_raster, eval@models[[best_idx]]))

    list(best_auc = best_auc, best_model_pr = best_model_pr)
}
