context("Test benchmarking")


result <- get_benchmarking_data("Lynx lynx")
partitioning_type <- "default"
learners <- list(mlr::makeLearner("classif.logreg", predict.type = "prob"),
                 mlr::makeLearner("classif.rpart", predict.type = "prob"))
result$df_data <- na.omit(result$df_data)
bmr <- benchmark_sdm(result$df_data, learners = learners, dataset_type =  partitioning_type, sample = FALSE)
bmr_results <- get_best_model_results(bmr)


test_that("Benchmarking works", {
    expect_is(bmr, "BenchmarkResult")
    expect_equal(bmr_results$auc > 0.8, c(TRUE, TRUE))
})

