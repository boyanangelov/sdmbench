#' Download data for benchmarking
#'
#' @param scientific_name A character string indicating scientific species name.
#' @param country A character string indicating country ISO2 code for filtering occurrence records.
#' @param limit A numeric value indicating maximum number of occurrence records (max 200000).
#' @param climate_resolution A numeric value indicating raster resolution in minutes of a degree.
#'   For \code{climate_type = "default"}: 0.5, 2.5, 5, or 10. For \code{"future"}: 2.5, 5, or 10.
#' @param climate_type A character string: \code{"default"} for current WorldClim bioclimatic
#'   variables or \code{"future"} for CMIP5 projections.
#' @param projected_model A character string indicating the CMIP5 model code (e.g. \code{"BC"},
#'   \code{"CN"}). Only used when \code{climate_type = "future"}.
#' @param rcp A numeric value for the Representative Concentration Pathway: 26, 45, 60, or 85.
#'   Only used when \code{climate_type = "future"}.
#' @param year A numeric value for years into the future: 50 or 70.
#'   Only used when \code{climate_type = "future"}.
#' @param shp Optional shapefile used as seas reference in coordinate cleaning.
#'
#' @return A list with two elements:
#'   \itemize{
#'     \item \code{df_data}: data frame of presence and background records with 19 bioclimatic
#'       variable columns (\code{bio1}...\code{bio19}) and an integer \code{label} column
#'       (1 = presence, 0 = background).
#'     \item \code{raster_data}: list with \code{climate_variables} (SpatRaster cropped to species
#'       extent), \code{coords_presence} (data frame with x/y), \code{points_presence} (SpatVector),
#'       and \code{background} (data frame with x/y of background points).
#'   }
#' @export
get_benchmarking_data <- function(scientific_name,
                                  country = NULL,
                                  limit = 1000,
                                  climate_type = "default",
                                  climate_resolution = 10,
                                  projected_model = "BC",
                                  rcp = 45,
                                  year = 50,
                                  shp = NULL) {
    message("Downloading occurrence data from GBIF...")
    species_occ <- rgbif::occ_data(
        scientificName     = scientific_name,
        limit              = limit,
        hasGeospatialIssue = FALSE,
        country            = country
    )

    species_occ_data <- species_occ$data |>
        dplyr::select(dplyr::any_of(c("name", "decimalLatitude", "decimalLongitude", "countryCode"))) |>
        dplyr::filter(!is.na(decimalLongitude), !is.na(decimalLatitude))

    message("Cleaning coordinates...")
    species_occ_data <- CoordinateCleaner::clean_coordinates(
        x         = species_occ_data,
        lon       = "decimalLongitude",
        lat       = "decimalLatitude",
        countries = "countryCode",
        species   = "name",
        tests     = c("capitals", "centroids", "equal", "gbif", "zeros", "seas"),
        seas_ref  = shp
    ) |>
        dplyr::filter(.summary == TRUE) |>
        dplyr::select(name, decimalLatitude, decimalLongitude)

    message("Downloading climate data...")
    if (climate_type == "default") {
        climate_variables <- geodata::worldclim_global(
            var  = "bio",
            res  = climate_resolution,
            path = tempdir()
        )
    } else if (climate_type == "future") {
        # CMIP5 data is not available via geodata; use the legacy raster package
        climate_variables <- terra::rast(raster::getData(
            name  = "CMIP5",
            var   = "bio",
            rcp   = rcp,
            model = projected_model,
            year  = year,
            res   = climate_resolution
        ))
    }

    # Standardise layer names to bio1...bio19 for downstream consistency
    names(climate_variables) <- paste0("bio", seq_len(terra::nlyr(climate_variables)))

    coords_presence <- data.frame(
        x = species_occ_data$decimalLongitude,
        y = species_occ_data$decimalLatitude
    )

    e <- terra::ext(
        min(coords_presence$x), max(coords_presence$x),
        min(coords_presence$y), max(coords_presence$y)
    )

    # Sample random background (pseudo-absence) points within the species extent
    coords_absence <- as.data.frame(terra::spatSample(
        terra::crop(climate_variables[[1]], e),
        size   = 10000,
        method = "random",
        na.rm  = TRUE,
        xy     = TRUE,
        values = FALSE
    ))

    points_presence <- terra::vect(coords_presence, geom = c("x", "y"), crs = "EPSG:4326")
    points_absence  <- terra::vect(coords_absence,  geom = c("x", "y"), crs = "EPSG:4326")

    env_presence <- terra::extract(climate_variables, points_presence, ID = FALSE)
    env_absence  <- terra::extract(climate_variables, points_absence,  ID = FALSE)

    df_presence <- cbind(coords_presence, env_presence, label = 1L)
    df_absence  <- cbind(coords_absence,  env_absence,  label = 0L)

    output_df <- rbind(df_presence, df_absence)
    output_df$x <- NULL
    output_df$y <- NULL

    message("Done!")
    list(
        df_data = output_df,
        raster_data = list(
            climate_variables = terra::crop(climate_variables, e),
            coords_presence   = coords_presence,
            points_presence   = points_presence,
            background        = coords_absence
        )
    )
}
