context("Test Deep Learning")


result <- get_benchmarking_data("Lynx lynx")
partitioning_type <- "checkerboard1"
result$df_data <- partition_data(result$raster_data,
                                result$df_data,
                                result$raster_data$climate_variables,
                                partitioning_type)
result_dl <- prepare_dl_data(result$df_data, partitioning_type)


test_that("Data parsed properly for DL", {
    expect_equal(length(result_dl), 5)
    expect_is(result_dl$rec_obj, "recipe")
})

keras_results <- train_dl(result_dl)
keras_evaluation <- evaluate_dl(keras_results$model, result_dl)
dl_auc <- get_dl_auc(keras_evaluation)

test_that("DL model trained", {
    expect_gt(dl_auc, 0.6)
})
