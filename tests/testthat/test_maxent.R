context("MaxEnt testing")

result <- get_benchmarking_data("Lynx lynx")
partitioning_type <- "checkerboard1"

jar <- file.path(system.file(package = "dismo"), "java", "maxent.jar")
if (file.exists(jar)) {
    maxent_results <- evaluate_maxent(result$raster_data, method = partitioning_type)

    test_that("MaxEnt evaluation works", {
        expect_gt(maxent_results$best_auc, 0.8)
        expect_true(inherits(maxent_results$best_model_pr, "SpatRaster"))
    })
}
