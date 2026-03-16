context("Test benchmarking")

# test bioclim (current climate) benchmarking
result <- get_benchmarking_data("Lynx lynx")
partitioning_type <- "default"
learners <- list(
    mlr3::lrn("classif.log_reg", predict_type = "prob"),
    mlr3::lrn("classif.rpart",   predict_type = "prob")
)
result$df_data <- na.omit(result$df_data)
bmr        <- benchmark_sdm(result$df_data, learners = learners,
                             dataset_type = partitioning_type, sample = FALSE)
bmr_results <- get_best_model_results(bmr)

test_that("Bioclim benchmarking works", {
    expect_true(inherits(bmr, "BenchmarkResult"))
    expect_true(all(bmr_results$classif.auc > 0.8))
})

# test CMIP5 (future climate) benchmarking
result <- get_benchmarking_data("Lynx lynx",
                                climate_type    = "future",
                                projected_model = "CN",
                                rcp  = 45,
                                year = 70)
learners <- list(
    mlr3::lrn("classif.naive_bayes", predict_type = "prob"),
    mlr3::lrn("classif.ranger",      predict_type = "prob")
)
result$df_data <- na.omit(result$df_data)
bmr        <- benchmark_sdm(result$df_data, learners = learners,
                             dataset_type = "default", sample = FALSE)
bmr_results <- get_best_model_results(bmr)

test_that("CMIP5 benchmarking works", {
    expect_true(inherits(bmr, "BenchmarkResult"))
    expect_true(all(bmr_results$classif.auc > 0.8))
})
