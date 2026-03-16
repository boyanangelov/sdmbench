#' Benchmark species distribution models
#'
#' Runs cross-validated benchmarking of a collection of classification learners using the
#' \pkg{mlr3} framework. Spatial blocking is applied automatically based on \code{dataset_type}.
#'
#' @param benchmarking_data A data frame from \code{\link{get_benchmarking_data}} (optionally
#'   post-processed by \code{\link{partition_data}}). Must contain a \code{label} column and
#'   bioclimatic variable columns. For \code{"block"} type it also needs a \code{grp} column;
#'   for checkerboard types a \code{grp_checkerboard} column.
#' @param learners A list of \pkg{mlr3} learner objects created with \code{mlr3::lrn()}.
#'   Supported examples (requires \pkg{mlr3learners}):
#'   \code{"classif.ranger"}, \code{"classif.log_reg"}, \code{"classif.xgboost"},
#'   \code{"classif.naive_bayes"}, \code{"classif.rpart"}, \code{"classif.svm"},
#'   \code{"classif.multinom"}, \code{"classif.kknn"}.
#'   All learners must have \code{predict_type = "prob"}.
#' @param dataset_type A character string indicating the spatial partitioning method used:
#'   \code{"default"} (5-fold CV), \code{"block"} (4-fold spatial CV), or
#'   \code{"checkerboard1"} / \code{"checkerboard2"} (2-fold spatial CV).
#' @param sample Logical. If \code{TRUE}, undersample the background class (keeps at most
#'   8x the number of presence records) before benchmarking.
#'
#' @return A \code{BenchmarkResult} object (mlr3). Use \code{bmr$score(mlr3::msr("classif.auc"))}
#'   to extract per-fold AUC values, or \code{\link{get_best_model_results}} for a summary.
#' @export
benchmark_sdm <- function(benchmarking_data, learners,
                           dataset_type = "default", sample = FALSE) {
    benchmarking_data$label <- as.factor(benchmarking_data$label)

    if (dataset_type == "default") {
        if (sample) benchmarking_data <- .undersample(benchmarking_data)
        task       <- mlr3::TaskClassif$new(id = "sdm", backend = benchmarking_data,
                                            target = "label", positive = "1")
        resampling <- mlr3::rsmp("cv", folds = 5)

    } else if (dataset_type %in% c("checkerboard1", "checkerboard2")) {
        blocking <- as.integer(as.character(benchmarking_data$grp_checkerboard))
        benchmarking_data$grp_checkerboard <- NULL
        if (sample) {
            idx               <- .undersample_idx(benchmarking_data$label)
            benchmarking_data <- benchmarking_data[idx, ]
            blocking          <- blocking[idx]
        }
        benchmarking_data$block <- blocking
        task <- mlr3::TaskClassif$new(id = "sdm", backend = benchmarking_data,
                                      target = "label", positive = "1")
        task$col_roles$feature <- setdiff(task$col_roles$feature, "block")
        task$col_roles$group   <- "block"
        resampling             <- mlr3::rsmp("cv", folds = 2)

    } else if (dataset_type == "block") {
        blocking <- as.integer(as.factor(benchmarking_data$grp))
        benchmarking_data$grp <- NULL
        if (sample) {
            idx               <- .undersample_idx(benchmarking_data$label)
            benchmarking_data <- benchmarking_data[idx, ]
            blocking          <- blocking[idx]
        }
        benchmarking_data$block <- blocking
        task <- mlr3::TaskClassif$new(id = "sdm", backend = benchmarking_data,
                                      target = "label", positive = "1")
        task$col_roles$feature <- setdiff(task$col_roles$feature, "block")
        task$col_roles$group   <- "block"
        resampling             <- mlr3::rsmp("cv", folds = 4)

    } else {
        stop("Unknown dataset_type: ", dataset_type)
    }

    design <- mlr3::benchmark_grid(tasks = task, learners = learners, resamplings = resampling)
    mlr3::benchmark(design, store_models = TRUE)
}

# -- internal helpers ---------------------------------------------------------

.undersample <- function(data) {
    data[.undersample_idx(data$label), ]
}

.undersample_idx <- function(label) {
    pos_idx  <- which(label == "1")
    neg_idx  <- which(label == "0")
    keep_neg <- sample(neg_idx, min(length(neg_idx), length(pos_idx) * 8L))
    c(pos_idx, keep_neg)
}
