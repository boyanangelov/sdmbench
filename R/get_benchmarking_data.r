#' Download data for benchmarking
#'
#' @param scientific_name A character string indicating scientific species name.
#' @param limit A numeric value indicating maximum number of occurence records requested.
#' @param bioclim_resolution A numeric vlaue indicating the resolution of the raster Bioclim variables.
#'
#' @return A list containing the downloaded datasets.
#'
#' @examples
#' result.data <- get_benchmarking_data("Lynx lynx", limit = 1500, bioclim_resolution = 10)
get_benchmarking_data <- function(scientific_name, limit = 1000, bioclim_resolution = 10) {
    print("Getting benchmarking data....")

    # download occurence data
    species_occ <- rgbif::occ_search(scientificName = scientific_name,
                                     limit = limit,
                                     hasGeospatialIssue = FALSE)
    species_occ_data <- species_occ$data %>%
        dplyr::select(c("name", "decimalLatitude", "decimalLongitude"))

    # use scrubr to clean data
    print("Cleaning benchmarking data....")
    species_occ_data <- scrubr::dframe(species_occ_data) %>%
        scrubr::coord_impossible() %>%
        scrubr::coord_incomplete() %>%
        scrubr::coord_unlikely()

    names(species_occ_data) <- c("name", "decimalLatitude", "decimalLongitude")

    # download bioclim data (if not already downloaded)
    bioclim_data <- raster::getData(name = "worldclim",
                                    var = "bio",
                                    res = bioclim_resolution)

    # construct data
    coords_presence <- data.frame(x = species_occ_data$decimalLongitude,
                                  y = species_occ_data$decimalLatitude)

    xmin <- min(coords_presence$x)
    xmax <- max(coords_presence$x)
    ymin <- min(coords_presence$y)
    ymax <- max(coords_presence$y)
    e <- raster::extent(xmin, xmax, ymin, ymax)

    # generate absence data
    coords_absence <- dismo::randomPoints(bioclim_data, 10000, ext = e)

    points_presence <- sp::SpatialPoints(coords_presence, proj4string = bioclim_data@crs)
    points_absence <- sp::SpatialPoints(coords_absence, proj4string = bioclim_data@crs)

    env_presence <- raster::extract(bioclim_data, points_presence)
    env_absence <- raster::extract(bioclim_data, points_absence)

    # prepare output DataFrame
    df_presence <- cbind.data.frame(sp::coordinates(points_presence), env_presence)
    df_absence <- cbind.data.frame(sp::coordinates(points_absence), env_absence)
    df_presence$label <- 1
    df_absence$label <- 0

    output_df <- rbind(df_presence, df_absence)
    output_df$x <- NULL
    output_df$y <- NULL


    data_output <- list(df_data = output_df,
                        raster_data = list(bioclim_data = raster::crop(bioclim_data, e),
                                           coords_presence = coords_presence,
                                           points_presence = points_presence,
                                           background = coords_absence))
    print("Done!")
    return(data_output)
}
