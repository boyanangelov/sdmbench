#' Partition data in order to avoid spatial auto correlation
#'
#' @param dataset_raster Raster data
#' @param dataset Dataframe containing species occurences
#' @param env Raster bioclim variables
#' @param method Desired partitioning method
#'
#' @return Dataframe partitionined using the selected method
partition_data <- function(dataset_raster, dataset, env, method) {
    if (method == "default") {
        result_dataset <- dataset
        return(result_dataset)
    }
    if (method == "block") {
        blocks <- ENMeval::get.block(occ = dataset_raster$coords_presence,
                                     bg.coords = dataset_raster$background)
        blocks_vector <- c(blocks$occ.grp, blocks$bg.grp)
        result_dataset <- dataset
        result_dataset$grp <- blocks_vector
        return(result_dataset)

    } else if (method == "checkerboard1") {
        check1 <- ENMeval::get.checkerboard1(occ = dataset_raster$coords_presence,
                                             env = env,
                                             bg.coords = dataset_raster$background,
                                             aggregation.factor = 5)
        nk <- length(unique(check1$occ.grp))
        pres <- as.data.frame(raster::extract(dataset_raster$bioclim_data, dataset_raster$coords_presence))
        bg <- as.data.frame(raster::extract(dataset_raster$bioclim_data, dataset_raster$background))

        # NOTE add attribution
        for (k in 1:nk) {
            train_val <- pres[check1$occ.grp != k, , drop = FALSE]
            test_val <- pres[check1$occ.grp == k, , drop = FALSE]
            bg_val <- bg[check1$bg.grp != k, , drop = FALSE]
        }

        train_val$grp <- "train"
        test_val$grp <- "test"
        bg_val$grp <- "bg"

        result_dataset <- rbind(train_val, test_val, bg_val)

        bg_rows <- as.integer(row.names(result_dataset)[result_dataset$grp == "bg"])
        bg_rows_idx <- sample.int(length(bg_rows), size = 1/2 * length(bg_rows))

        bg_rows_train <- bg_rows[bg_rows_idx]
        bg_rows_test <- bg_rows[-bg_rows_idx]

        grp1_indeces <- as.integer(row.names(result_dataset)[result_dataset$grp == "train"])
        grp1_indeces <- c(grp1_indeces, bg_rows_train)
        grp2_indeces <- as.integer(row.names(result_dataset)[result_dataset$grp == "test"])
        grp2_indeces <- c(grp2_indeces, bg_rows_test)

        # use train test splits
        where <- match(row.names(result_dataset), grp1_indeces)
        where <- ifelse(is.na(where), 1, 0)
        result_dataset$grp_checkerboard <- where

        # construct final dataframe
        result_dataset$grp_checkerboard <- as.factor(result_dataset$grp_checkerboard)
        result_dataset$label <- ifelse(result_dataset$grp != "bg", 1, 0)
        result_dataset$label <- as.factor(result_dataset$label)

        result_dataset$grp <- NULL

        return(result_dataset)

    } else if (method == "checkerboard2") {
        check2 <- ENMeval::get.checkerboard2(occ = dataset_raster$coords_presence,
                                             env = env,
                                             bg.coords = dataset_raster$background,
                                             aggregation.factor = c(5, 5))

        nk <- length(unique(check2$occ.grp))
        pres <- as.data.frame(raster::extract(dataset_raster$bioclim_data, dataset_raster$coords_presence))
        bg <- as.data.frame(raster::extract(dataset_raster$bioclim_data, dataset_raster$background))

        for (k in 1:nk) {
            train_val <- pres[check2$occ.grp != k, , drop = FALSE]
            test_val <- pres[check2$occ.grp == k, , drop = FALSE]
            bg_val <- bg[check2$bg.grp != k, , drop = FALSE]
        }

        train_val$grp <- "train"
        test_val$grp <- "test"
        bg_val$grp <- "bg"

        result_dataset <- rbind(train_val, test_val, bg_val)


        bg_rows <- as.integer(row.names(result_dataset)[result_dataset$grp == "bg"])
        bg_rows_idx <- sample.int(length(bg_rows), size = 1/2 * length(bg_rows))

        bg_rows_train <- bg_rows[bg_rows_idx]
        bg_rows_test <- bg_rows[-bg_rows_idx]

        grp1_indeces <- as.integer(row.names(result_dataset)[result_dataset$grp == "train"])
        grp1_indeces <- c(grp1_indeces, bg_rows_train)
        grp2_indeces <- as.integer(row.names(result_dataset)[result_dataset$grp == "test"])
        grp2_indeces <- c(grp2_indeces, bg_rows_test)

        # use train test splits
        where <- match(row.names(result_dataset), grp1_indeces)
        where <- ifelse(is.na(where), 1, 0)
        result_dataset$grp_checkerboard <- where

        # construct final dataframe
        result_dataset$grp_checkerboard <- as.factor(result_dataset$grp_checkerboard)
        result_dataset$label <- ifelse(result_dataset$grp != "bg", 1, 0)
        result_dataset$label <- as.factor(result_dataset$label)

        result_dataset$grp <- NULL

        return(result_dataset)
    }
}
