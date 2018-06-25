context("MaxEnt testing")


result <- get_benchmarking_data("Lynx lynx")
partitioning_type <- "checkerboard1"

maxent_results <- evaluate_maxent(result$raster_data, method = partitioning_type)

test_that("MaxEnt evaluation works", {
    expect_gt(maxent_results$best_auc, 0.8)
})
