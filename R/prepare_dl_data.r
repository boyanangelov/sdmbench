#' Parse data for deep learning model training
#'
#' Prepares a data frame for Keras model training: removes spatial grouping columns,
#' splits into train/test sets, and applies centering and scaling via a \pkg{recipes} workflow.
#'
#' @importFrom recipes all_predictors
#' @importFrom recipes all_outcomes
#'
#' @param input_data A data frame as returned by \code{\link{partition_data}}.
#' @param partitioning_type A character string indicating the partitioning method used:
#'   \code{"default"}, \code{"block"}, \code{"checkerboard1"}, or \code{"checkerboard2"}.
#'
#' @return A list with elements:
#'   \itemize{
#'     \item \code{train_tbl}: scaled predictor matrix for training.
#'     \item \code{test_tbl}: scaled predictor matrix for testing.
#'     \item \code{y_train_vec}: integer response vector for training.
#'     \item \code{y_test_vec}: integer response vector for testing.
#'     \item \code{rec_obj}: the fitted \pkg{recipes} recipe (needed for prediction on new data).
#'   }
#' @export
prepare_dl_data <- function(input_data, partitioning_type) {
    # Remove spatial grouping columns added by partition_data
    if (partitioning_type %in% c("checkerboard1", "checkerboard2")) {
        input_data$grp_checkerboard <- NULL
        input_data$label <- as.integer(input_data$label)
        # Recode factor levels (1/2) back to 0/1 when label was coerced via as.factor
        input_data$label <- ifelse(input_data$label == 2L, 1L, 0L)
    }
    input_data$grp <- NULL

    input_data <- input_data |>
        tidyr::drop_na() |>
        dplyr::select(label, dplyr::everything())

    split   <- rsample::initial_split(input_data, prop = 0.8)
    train_tbl <- rsample::training(split)
    test_tbl  <- rsample::testing(split)

    rec_obj <- recipes::recipe(label ~ ., data = train_tbl) |>
        recipes::step_center(all_predictors(), -all_outcomes()) |>
        recipes::step_scale(all_predictors(),  -all_outcomes()) |>
        recipes::prep(data = train_tbl)

    x_train_tbl <- recipes::bake(rec_obj, new_data = train_tbl) |> dplyr::select(-label)
    x_test_tbl  <- recipes::bake(rec_obj, new_data = test_tbl)  |> dplyr::select(-label)

    list(
        train_tbl  = x_train_tbl,
        test_tbl   = x_test_tbl,
        y_train_vec = train_tbl$label,
        y_test_vec  = test_tbl$label,
        rec_obj    = rec_obj
    )
}
