#' Evaluate MaxEnt model performance
#'
#' @param raster_data A raster dataset.
#' @param method A character string indicating the spatial data partitioning method. Possible values are `jackknife`, `randomkfold`, `user`, `block`, `checkerboard1`, `checkerboard2`.
#'
#' @return A list containing AUC value and predict object (for plotting).
#' @examples
#' \dontrun{
#' # download benchmarking data
#' benchmarking_data <- get_benchmarking_data("Lynx lynx",
#'                                            limit = 1500)
#' # run MaxEnt evaluation
#' maxent_results <- evaluate_maxent(raster_data = benchmarking_data$raster_data,
#'                                   method = "block")
#'
#' # get AUC of best model run
#' maxent_results$best_auc
#' }
evaluate_maxent <- function(raster_data, method) {
    eval <- ENMeval::ENMevaluate(occ = raster_data$coords_presence,
                                 env = raster_data$climate_variables,
                                 bg.coords = raster_data$background,
                                 method = method,
                                 RMvalues = c(1, 2),
                                 fc = c("L"))

    best_model_id <- as.integer(row.names(eval@results[which.max(eval@results$avg.test.AUC), ]))
    best_auc <- eval@results$avg.test.AUC[[best_model_id]]
    best_model_pr <- dismo::predict(raster_data$climate_variables, eval@models[[best_model_id]])
    me_results <- list(best_auc = best_auc, best_model_pr = best_model_pr)

    return(me_results)
}
