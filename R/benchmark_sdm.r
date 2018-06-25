#' Benchmark regular machine learning models
#'
#' @param benchmarking_data Dataframe from the output of \code{\link{get_benchmarking_data}} function.
#' @param learners MLR learner objects
#' @param dataset_type Partitioning method
#' @param sample Logical value to indicate whether benchmarking should be done on an undersampled dataset
#'
#' @return Benchmarking object (bmr class)
#'
benchmark_sdm <- function(benchmarking_data, learners, dataset_type = "default", sample = FALSE) {
    benchmarking_data$label <- as.factor(benchmarking_data$label)
    if (dataset_type == "default") {
        ms <- list(mlr::auc)

        if (sample) {

            task_default <- mlr::makeClassifTask(data = benchmarking_data, target = "label")
            task <- mlr::undersample(task_default, rate = 1/8)

        } else {
            task <- mlr::makeClassifTask(data = benchmarking_data, target = "label")
        }

        bmr <- mlr::benchmark(learners = learners, tasks = task, measures = ms, show.info = TRUE)
        return(bmr)

    } else if (dataset_type == "checkerboard1" | dataset_type == "checkerboard2") {
        rdesc <- mlr::makeResampleDesc("CV", iters = 2)
        ms <- list(mlr::auc)
        blocking <- benchmarking_data$grp_checkerboard
        benchmarking_data$grp_checkerboard <- NULL
        if (sample) {
            task_default <- mlr::makeClassifTask(data = benchmarking_data, target = "label", blocking = blocking)
            task <- mlr::undersample(task_default, rate = 1/8)
        } else {

            task <- mlr::makeClassifTask(data = benchmarking_data, target = "label", blocking = blocking)
        }
        bmr <- mlr::benchmark(learners = learners, tasks = task, measures = ms, show.info = TRUE, resampling = rdesc)
        return(bmr)
    } else if (dataset_type == "block") {
        rdesc <- mlr::makeResampleDesc("CV", iters = 4)
        ms <- list(mlr::auc)
        blocking <- as.factor(benchmarking_data$grp)
        benchmarking_data$grp <- NULL
        if (sample) {
            task_default <- mlr::makeClassifTask(data = benchmarking_data, target = "label", blocking = blocking)
            task <- mlr::undersample(task_default, rate = 1/8)
        } else {
            task <- mlr::makeClassifTask(data = benchmarking_data, target = "label", blocking = blocking)
        }

        bmr <- mlr::benchmark(learners = learners, tasks = task, measures = ms, show.info = TRUE, resampling = rdesc)
        return(bmr)
    }
}
