#' Benchmark regular models
#'
#' A function to benchmark a collection of regular machine learning models.
#' @param benchmarking_data A dataframe from the output of \code{\link{get_benchmarking_data}} function. This dataset contains species occurrence coordinates together with a set of environmental data points.
#' @param learners A list of mlr learner objects which specify which models to use (i.e. Random Forests). The following learners are supported: "classif.logreg", "classif.gbm", "classif.multinom", "classif.naiveBayes", "classif.xgboost", "classif.ksvm".
#' @param dataset_type A character string indicating spatial partitioning method. This is used in order to avoid spatial autocorrelation issues.
#' @param sample Logical. Indicates whether benchmarking should be done on an undersampled dataset. This is useful for testing model efficiency with an imbalanced dataset (i.e. few observations and many background (pseudo-absence) points).
#'
#' @return Benchmarking object (class bmr). This object can be accessed by other functions in order to obtain the benchmark results.
#' @examples
#' # download benchmarking data
#' benchmarking_data <- get_benchmarking_data("Lynx lynx",
#'                                            limit = 1500,
#'                                            climate_resolution = 10,
#'                                            method = "checkerboard1")
#'
#' # create a list of learners (algorithms) to compare
#' # here it is important to specify predict.type as "prob"
#' learners <- list(mlr::makeLearner("classif.randomForest",
#'                                   predict.type = "prob"),
#'                  mlr::makeLearner("classif.logreg",
#'                                  predict.type = "prob"))
#'
#' # run the benchmarking
#' # if a different data partitioning type has been used, you should specify it
#' bmr <- benchmark_sdm(benchmarking_data$df_data,
#'                     learners = learners,
#'                     dataset_type = "checkerboard1",
#'                     sample = FALSE)
#'
#' # if you are interested in benchmarking an imbalanced dataset you can undersample
#' bmr <- benchmark_sdm(benchmarking_data$df_data,
#'                     learners = learners,
#'                     dataset_type = "checkerboard1",
#'                     sample = TRUE)
#'
#' # inspect the results
#' bmr
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
