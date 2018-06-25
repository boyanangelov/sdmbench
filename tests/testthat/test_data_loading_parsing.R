context("Data tests")


result <- get_benchmarking_data("Lynx lynx", limit = 1000)

test_that("Data is downloaded", {
    expect_is(result$df_data, "data.frame")
    expect_is(result$raster_data$bioclim_data, "RasterBrick")
    expect_equal(dim(result$df_data), c(11000, 20))
})

result$df_data <- partition_data(result$raster_data,
                                result$df_data,
                                result$raster_data$bioclim_data,
                                method = "checkerboard1")

test_that("Data is parsed", {
    expect_gt(matrix(table(result$df_data$grp_checkerboard))[1], 2800)
    expect_gt(matrix(table(result$df_data$grp_checkerboard))[2], 3000)
})
