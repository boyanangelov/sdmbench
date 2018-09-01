#' Download data for benchmarking
#'
#' @param scientific_name A character string indicating scientific species name.
#' @param limit A numeric value indicating maximum number of occurrence records requested. The value has to be positive and has a maximum of 200000 (observations you can download with a single call).
#' @param climate_resolution A numeric value indicating the resolution of the raster environmental variables. For a climate type of `default` possible resolutions are: 0.5, 2.5, 5, and 10 (minutes of a degree). For a `future` climate: 2.5, 5, and 10.
#' @param climate_type A character string indicating type of climate variables, either `default` for current climate or `future` for CMIP5 projections.
#' @param projected_model A character string indicates the type of future climate projection. Possible values are: "AC", "BC", "CC", "CE", "CN", "GF", "GD", "GS", "HD", "HG", "HE", "IN", "IP", "MI", "MR", "MC", "MP", "MG", or "NO".
#' @param rcp A numeric value indicating representative concentration pathways. Possible values: 26, 45, 60, or 85.
#' @param year A numeric value indicating the number of years into the future for projection. Can be 50 or 70.
#'
#' @return A list containing the downloaded datasets.
#'
#' @examples
#' \dontrun{
#' # get data using the default parameters (the only required one is the species name)
#' result_data <- get_benchmarking_data("Lynx lynx")
#'
#' # get a custom number of observations at a higher climate resolution
#' # note that downloading higher resolution data takes longer
#' result_data <- get_benchmarking_data("Lynx lynx",
#'                                      limit = 1500,
#'                                      climate_resolution = 5)
#'
#' # get environmental data for a future climate projection (CMIP5)
#' result_data <- get_benchmarking_data("Lynx lynx",
#'                                      limit = 1500,
#'                                      climate_resolution = 5,
#'                                      climate_type = "future")
#'
#' # specify projection model
#' # the default is BC (Beijing Climate Center Climate System Model)
#' # note that not all combinations of climate values are possible
#' result_data <- get_benchmarking_data("Lynx lynx",
#'                                      limit = 1500,
#'                                      climate_resolution = 10,
#'                                      climate_type = "future",
#'                                      projected_model = "AC")
#'
#' # specify number of years into the future
#' # if you are interested in the longer term effects of climate change
#' result_data <- get_benchmarking_data("Lynx lynx",
#'                                      limit = 1500,
#'                                      climate_resolution = 5,
#'                                      climate_type = "future",
#'                                      year = 70)
#'
#' # specify RCP (representative concentration pathway)
#' # this value represents one of four greenhouse gas concentration trajectories
#' result_data <- get_benchmarking_data("Lynx lynx",
#'                                      limit = 1500,
#'                                      climate_resolution = 5,
#'                                      climate_type = "future",
#'                                      year = 70,
#'                                      rcp = 26)
#'
#' # after obtaining the data you can inspect its different components
#' # raw data
#' head(result_data$df_data)
#'
#' # check class balance (presence / absence)
#' table(result_data$df_data$label)
#'
#' # the result object also contains the data in raster format
#' result_data$raster_data
#' }
get_benchmarking_data <- function(scientific_name,
                                  limit = 1000,
                                  climate_type = "default",
                                  climate_resolution = 10,
                                  projected_model = "BC",
                                  rcp = 45,
                                  year = 50) {
    print("Getting benchmarking data....")

    # download occurrence data
    species_occ <- rgbif::occ_data(scientificName = scientific_name,
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
    if (climate_type == "default") {
        climate_variables <- raster::getData(name = "worldclim",
                                             var = "bio",
                                             res = climate_resolution)
    } else if (climate_type == "future") {
        # TODO add more control to variables
        climate_variables <- raster::getData(name = "CMIP5",
                                             var = "bio",
                                             rcp = rcp,
                                             model = projected_model,
                                             year = year,
                                             res = climate_resolution)
    }


    # construct data
    coords_presence <- data.frame(x = species_occ_data$decimalLongitude,
                                  y = species_occ_data$decimalLatitude)

    xmin <- min(coords_presence$x)
    xmax <- max(coords_presence$x)
    ymin <- min(coords_presence$y)
    ymax <- max(coords_presence$y)
    e <- raster::extent(xmin, xmax, ymin, ymax)

    # generate absence data
    coords_absence <- dismo::randomPoints(climate_variables, 10000, ext = e)

    points_presence <- sp::SpatialPoints(coords_presence, proj4string = climate_variables@crs)
    points_absence <- sp::SpatialPoints(coords_absence, proj4string = climate_variables@crs)

    env_presence <- raster::extract(climate_variables, points_presence)
    env_absence <- raster::extract(climate_variables, points_absence)

    # prepare output DataFrame
    df_presence <- cbind.data.frame(sp::coordinates(points_presence), env_presence)
    df_absence <- cbind.data.frame(sp::coordinates(points_absence), env_absence)
    df_presence$label <- 1
    df_absence$label <- 0

    output_df <- rbind(df_presence, df_absence)
    output_df$x <- NULL
    output_df$y <- NULL


    data_output <- list(df_data = output_df,
                        raster_data = list(climate_variables = raster::crop(climate_variables, e),
                                           coords_presence = coords_presence,
                                           points_presence = points_presence,
                                           background = coords_absence))
    print("Done!")
    return(data_output)
}
