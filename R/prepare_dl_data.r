#' Parse data for it to be suitable for deep learning modeling
#'
#' @param input_data Input dataframe
#' @param partitioning_type Desired data partitioning type
#'
#' @return Parsed dataframe
prepare_dl_data <- function(input_data, partitioning_type) {
    if (partitioning_type %in% c("checkerboard1", "checkerboard2")) {

        input_data$grp_checkerboard <- NULL

        input_data$label <- as.integer(input_data$label)

                # fix coercion error (for plotting)
        input_data$label <- ifelse(input_data$label == 2, 1, 0)
    }

    input_data$grp <- NULL

    input_data <- input_data %>%
        tidyr::drop_na() %>%
        dplyr::select(label, dplyr::everything())

    train_test_split <- rsample::initial_split(input_data, prop = 0.8)
    train_tbl <- rsample::training(train_test_split)
    test_tbl <- rsample::testing(train_test_split)

    rec_obj <- recipes::recipe(label ~ ., data = train_tbl) %>%
        recipes::step_center(all_predictors(),
        -all_outcomes()) %>%
        recipes::step_scale(all_predictors(), -all_outcomes()) %>%
        recipes::prep(data = train_tbl)


    x_train_tbl <- recipes::bake(rec_obj, newdata = train_tbl) %>%
        dplyr::select(-label)
    x_test_tbl <- recipes::bake(rec_obj, newdata = test_tbl) %>%
        dplyr::select(-label)

    y_train_vec <- train_tbl$label
    y_test_vec <- test_tbl$label

    result_list <- list(train_tbl = x_train_tbl,
                        test_tbl = x_test_tbl,
                        y_train_vec = y_train_vec,
                        y_test_vec = y_test_vec,
                        rec_obj = rec_obj)

    return(result_list)
}
