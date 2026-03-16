context("Data tests")

result <- get_benchmarking_data("Lynx lynx", limit = 1000)

test_that("Data is downloaded", {
    expect_s3_class(result$df_data, "data.frame")
    expect_true(inherits(result$raster_data$climate_variables, "SpatRaster"))
    # 19 bioclim columns + label; row count depends on successful GBIF download + cleaning
    expect_equal(ncol(result$df_data), 20L)
    expect_gt(nrow(result$df_data), 1000L)
})

result$df_data <- partition_data(
    result$raster_data,
    result$df_data,
    result$raster_data$climate_variables,
    method = "checkerboard1"
)

test_that("Data is partitioned into two spatial groups", {
    grp_counts <- as.integer(table(result$df_data$grp_checkerboard))
    expect_length(grp_counts, 2L)
    expect_gt(grp_counts[1], 100L)
    expect_gt(grp_counts[2], 100L)
})
