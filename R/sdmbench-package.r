#' @title sdmbench: Benchmark Species Distribution Models
#'
#' @description This package provides tools and functions to benchmark
#' Species Distribution Models (SDMs). In addition to domain specific tools,
#' a GUI is provided as an easier interface.
#'
#' @section Download data:
#'
#' A good starting point to explore the package is to run the
#' \code{\link{run_sdmbench}} function. This will start a GUI that can guide
#' you through several typical benchmarking workflows.
#'
#' To obtain benchmarking data you can use
#' \code{\link{get_benchmarking_data}}, followed by \code{\link{partition_data}}
#' if you want to avoid spatial autocorrelation.
#'
#' @section Benchmark models:
#'
#' The output of the previous functions can be then fed into
#' \code{\link{benchmark_sdm}} which runs the actual benchmarking.
#'
#' @section Evaluate results:
#'
#' You can inspect the model results by using the
#' \code{\link{get_best_model_results}} function, or by plotting them on a map
#'  with \code{\link{plot_sdm_map}}.
#'
#' There are several additional functions that you might find useful. Those are
#' described in the package vignette.
#'
#' @name sdmbench
#' @docType package
NULL
