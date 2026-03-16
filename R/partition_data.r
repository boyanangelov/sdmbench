#' Partition spatial data
#'
#' Partitions spatial data to avoid spatial autocorrelation in model evaluation.
#' The \code{"block"} and \code{"checkerboard"} methods assign spatial fold IDs that are
#' passed to \code{\link{benchmark_sdm}} as blocking factors.
#'
#' @param dataset_raster A list as returned by \code{\link{get_benchmarking_data}}'s
#'   \code{raster_data} element, containing \code{climate_variables}, \code{coords_presence},
#'   and \code{background}.
#' @param dataset A data frame as returned by \code{\link{get_benchmarking_data}}'s
#'   \code{df_data} element.
#' @param env A SpatRaster of environmental variables (same as \code{dataset_raster$climate_variables}).
#'   Only used when \code{method} is \code{"checkerboard1"} or \code{"checkerboard2"}; ignored
#'   for \code{"block"} and \code{"default"}.
#' @param method A character string: \code{"default"}, \code{"block"}, \code{"checkerboard1"},
#'   or \code{"checkerboard2"}.
#'
#' @return A data frame with bioclimatic variables, a \code{label} column, and (for non-default
#'   methods) a spatial group column (\code{grp} for block, \code{grp_checkerboard} for
#'   checkerboard methods).
#' @export
partition_data <- function(dataset_raster, dataset, env, method) {
    if (method == "default") {
        return(dataset)
    }

    if (method == "block") {
        blocks  <- .get_block(dataset_raster$coords_presence, dataset_raster$background)
        occ_grp <- .grp_field(blocks, "occ")
        bg_grp  <- .grp_field(blocks, "bg")
        dataset$grp <- c(occ_grp, bg_grp)
        return(dataset)
    }

    if (method %in% c("checkerboard1", "checkerboard2")) {
        return(.partition_checkerboard(dataset_raster, env, method))
    }

    stop("Unknown method: ", method, ". Use 'default', 'block', 'checkerboard1', or 'checkerboard2'.")
}

# -- helpers ------------------------------------------------------------------

.get_block <- function(occs, bg) {
    tryCatch(
        ENMeval::get.block(occs = occs, bg = bg),
        error = function(e) ENMeval::get.block(occ = occs, bg.coords = bg)
    )
}

.get_checkerboard <- function(method, occs, env, bg, agg) {
    fn <- if (method == "checkerboard1") ENMeval::get.checkerboard1 else ENMeval::get.checkerboard2
    tryCatch(
        fn(occs = occs, envs = env, bg = bg, aggregation.factor = agg),
        error = function(e) fn(occ = occs, env = env, bg.coords = bg, aggregation.factor = agg)
    )
}

# Return occ or bg group vector, handling ENMeval 2.0 / 0.3 column name differences
.grp_field <- function(result, type) {
    if (type == "occ") {
        if (!is.null(result$occs.grp)) result$occs.grp else result$occ.grp
    } else {
        result$bg.grp
    }
}

.partition_checkerboard <- function(dataset_raster, env, method) {
    agg <- if (method == "checkerboard1") 5 else c(5, 5)
    check   <- .get_checkerboard(method,
                                 dataset_raster$coords_presence,
                                 env,
                                 dataset_raster$background,
                                 agg)
    occ_grp <- .grp_field(check, "occ")
    bg_grp  <- .grp_field(check, "bg")

    pres_data <- as.data.frame(terra::extract(
        dataset_raster$climate_variables,
        terra::vect(dataset_raster$coords_presence, geom = c("x", "y"), crs = "EPSG:4326"),
        ID = FALSE
    ))
    bg_data <- as.data.frame(terra::extract(
        dataset_raster$climate_variables,
        terra::vect(dataset_raster$background, geom = c("x", "y"), crs = "EPSG:4326"),
        ID = FALSE
    ))

    pres_data$grp_checkerboard <- as.factor(occ_grp)
    pres_data$label            <- as.factor(1L)
    bg_data$grp_checkerboard   <- as.factor(bg_grp)
    bg_data$label              <- as.factor(0L)

    rbind(pres_data, bg_data)
}
