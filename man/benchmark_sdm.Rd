% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/benchmark_sdm.r
\name{benchmark_sdm}
\alias{benchmark_sdm}
\title{Benchmark regular models}
\usage{
benchmark_sdm(benchmarking_data, learners, dataset_type = "default",
  sample = FALSE)
}
\arguments{
\item{benchmarking_data}{A dataframe from the output of \code{\link{get_benchmarking_data}} function. This dataset contains species occurrence coordinates together with a set of environmental data points.}

\item{learners}{A list of mlr learner objects which specify which models to use (i.e. Random Forests). The following learners are supported: "classif.logreg", "classif.gbm", "classif.multinom", "classif.naiveBayes", "classif.xgboost", "classif.ksvm".}

\item{dataset_type}{A character string indicating spatial partitioning method. This is used in order to avoid spatial autocorrelation issues.}

\item{sample}{Logical. Indicates whether benchmarking should be done on an undersampled dataset. This is useful for testing model efficiency with an imbalanced dataset (i.e. few observations and many background (pseudo-absence) points).}
}
\value{
Benchmarking object (class bmr). This object can be accessed by other functions in order to obtain the benchmark results.
}
\description{
A function to benchmark a collection of regular machine learning models.
}
\examples{
\dontrun{
# download benchmarking data
benchmarking_data <- get_benchmarking_data("Lynx lynx",
                                           limit = 1500)

# create a list of algorithms to compare
# here it is important to specify predict.type as "prob"
learners <- list(mlr::makeLearner("classif.randomForest",
                                  predict.type = "prob"),
                 mlr::makeLearner("classif.logreg",
                                 predict.type = "prob"))

# run the model benchmarking process
# if you have previously used a partitioning method you should specify it here
bmr <- benchmark_sdm(benchmarking_data$df_data,
                    learners = learners,
                    dataset_type = "default")

# for benchmarking an imbalanced dataset you can undersample
bmr <- benchmark_sdm(benchmarking_data$df_data,
                    learners = learners,
                    dataset_type = "default",
                    sample = TRUE)

# inspect the benchmark results
bmr
}
}
