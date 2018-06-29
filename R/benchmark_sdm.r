#' Benchmark regular models
#'
#' A function to benchmark a collection of regular machine learning models.
#' @param benchmarking_data A dataframe from the output of \code{\link{get_benchmarking_data}} function.
#' @param learners A list of mlr learner objects.
#' @param dataset_type A character string indicating spatial partitioning method.
#' @param sample Logical. Indicates whether benchmarking should be done on an undersampled dataset.
#'
#' @return Benchmarking object (class bmr).
#' @examples
#' bmr <- benchmark_sdm(benchmarking_data$df_data, learners = learners, dataset_type = "block", sample = FALSE)
benchmark_sdm <- function(benchmarking_data, learners, dataset_type = "default", sample = FALSE) {
    benchmarking_data$label <- as.factor(benchmarking_data$label)
    if (dataset_type == "default") {
        # choose benchmarking metrics
        ms <- list(mlr::auc)

        # use undersampling
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
        # assign spatial partitioning vector to split the data
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
