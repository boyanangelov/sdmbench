#' Evaluate MaxEnt model performance
#'
#' @param raster_data A raster dataset
#' @param method Partitioning method.
#'
#' @return List containing AUC value and predict object (for plotting)
evaluate_maxent <- function(raster_data, method) {
    eval <- ENMeval::ENMevaluate(occ = raster_data$coords_presence,
                                 env = raster_data$bioclim_data,
                                 bg.coords = raster_data$background,
                                 method = method,
                                 RMvalues = c(1, 2),
                                 fc = c("L"))

    best_model_id <- as.integer(row.names(eval@results[which.max(eval@results$full.AUC), ]))
    best_auc <- eval@results$full.AUC[[best_model_id]]
    best_model_pr <- dismo::predict(raster_data$bioclim_data, eval@models[[best_model_id]])
    me_results <- list(best_auc = best_auc, best_model_pr = best_model_pr)

    return(me_results)
}
