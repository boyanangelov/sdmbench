context("Test benchmarking")

# test bioclim benchmarking
result <- get_benchmarking_data("Lynx lynx")
partitioning_type <- "default"
learners <- list(mlr::makeLearner("classif.logreg", predict.type = "prob"),
                 mlr::makeLearner("classif.rpart", predict.type = "prob"))
result$df_data <- na.omit(result$df_data)
bmr <- benchmark_sdm(result$df_data, learners = learners, dataset_type =  partitioning_type, sample = FALSE)
bmr_results <- get_best_model_results(bmr)


test_that("Bioclim benchmarking works", {
    expect_is(bmr, "BenchmarkResult")
    expect_equal(bmr_results$auc > 0.8, c(TRUE, TRUE))
})

# test CMIP5 benchmarking
result <- get_benchmarking_data("Lynx lynx",
                                climate_type = "future",
                                projected_model = "CN",
                                rcp = 45,
                                year = 70)
partitioning_type <- "default"
learners <- list(mlr::makeLearner("classif.naiveBayes", predict.type = "prob"),
                 mlr::makeLearner("classif.randomForest", predict.type = "prob"))
result$df_data <- na.omit(result$df_data)
bmr <- benchmark_sdm(result$df_data, learners = learners, dataset_type =  partitioning_type, sample = FALSE)
bmr_results <- get_best_model_results(bmr)

test_that("CMIP5 benchmarking works", {
    expect_is(bmr, "BenchmarkResult")
    expect_equal(bmr_results$auc > 0.8, c(TRUE, TRUE))
})