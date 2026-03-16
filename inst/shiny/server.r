library(magrittr)

server <- function(input, output) {
    shinyjs::disable("go_bmr")
    shinyjs::disable("go_maxent")
    shinyjs::disable("go_profile")
    shinyjs::disable("go_dl")

    v <- reactiveValues(data = NULL, bmr = NULL, partitioning_type = NULL)

    # -- Custom data upload ---------------------------------------------------
    observeEvent(input$go_custom, {
        if (isTRUE(input$custom_data)) {
            tryCatch({
                df <- read.csv(input$file1$datapath)
                v$data             <- list(df_data = df)
                v$partitioning_type <- input$data_partitioning_type
                shinyjs::enable("go_bmr")
                showNotification("Custom data loaded successfully.")
            }, error = function(e) {
                showNotification(paste("Error parsing file:", conditionMessage(e)),
                                 type = "error")
            })
        } else {
            showNotification("Enable 'Use custom data?' first.", type = "warning")
        }
    })

    # -- GBIF data download --------------------------------------------------
    observeEvent(input$go, {
        req(input$text)

        progress <- shiny::Progress$new()
        on.exit(progress$close())
        progress$set(message = "Status", value = 0)
        progress$inc(0.25, detail = "Downloading occurrence and climate data...")

        benchmarking_data <- sdmbench::get_benchmarking_data(
            scientific_name    = input$text,
            limit              = input$limit,
            climate_type       = input$climate_type,
            climate_resolution = input$climate_resolution,
            projected_model    = input$projected_model,
            rcp                = input$rcp,
            year               = input$years
        )

        progress$inc(0.25, detail = "Partitioning data...")
        benchmarking_data$df_data <- sdmbench::partition_data(
            dataset_raster = benchmarking_data$raster_data,
            dataset        = benchmarking_data$df_data,
            env            = benchmarking_data$raster_data$climate_variables,
            method         = input$data_partitioning_type
        )

        progress$inc(0.25, detail = "Rendering occurrence map...")
        output$table       <- renderTable(head(benchmarking_data$df_data))
        output$occ_map     <- leaflet::renderLeaflet({
            leaflet::leaflet(data = benchmarking_data$raster_data$coords_presence) |>
                leaflet::addTiles() |>
                leaflet::addCircleMarkers(~x, ~y, fillOpacity = 0.3)
        })

        progress$inc(0.25, detail = "Done.")
        v$data              <- benchmarking_data
        v$partitioning_type <- input$data_partitioning_type

        shinyjs::enable("go_bmr")
        shinyjs::enable("go_maxent")
        shinyjs::enable("go_profile")
        shinyjs::enable("go_dl")
    })

    # -- General ML benchmarking ---------------------------------------------
    observeEvent(input$go_bmr, {
        benchmarking_data <- v$data
        partitioning_type <- v$partitioning_type

        progress_bmr <- shiny::Progress$new()
        on.exit(progress_bmr$close())
        progress_bmr$set(message = "Status", value = 0)
        progress_bmr$inc(0.33, detail = "Benchmarking models...")

        learners <- lapply(input$checkGroup, function(lid) {
            mlr3::lrn(lid, predict_type = "prob")
        })

        benchmarking_data$df_data <- na.omit(benchmarking_data$df_data)
        bmr <- sdmbench::benchmark_sdm(
            benchmarking_data = benchmarking_data$df_data,
            learners          = learners,
            dataset_type      = partitioning_type,
            sample            = input$sample
        )
        v$bmr <- bmr

        progress_bmr$inc(0.33, detail = "Rendering results...")
        best_results <- sdmbench::get_best_model_results(bmr)

        output$bmr_results <- renderTable(best_results)
        output$bmr_plot1   <- renderPlot({
            perf <- as.data.frame(bmr$score(mlr3::msr("classif.auc")))
            ggplot2::ggplot(perf, ggplot2::aes(x = learner_id, y = classif.auc)) +
                ggplot2::geom_boxplot(fill = "#4CAF50", alpha = 0.7) +
                ggplot2::theme_minimal(base_size = 13) +
                ggplot2::labs(x = "Algorithm", y = "AUC") +
                ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 35, hjust = 1))
        })

        # Render up to 8 maps (one per learner result row)
        map_ids <- seq_len(min(nrow(best_results), 8L))
        for (i in map_ids) {
            local({
                idx    <- i
                map_id <- paste0("model_map_", idx)
                output[[map_id]] <- leaflet::renderLeaflet(
                    sdmbench::plot_sdm_map(
                        raster_data = benchmarking_data$raster_data,
                        bmr         = bmr,
                        learner_id  = best_results$learner_id[[idx]],
                        iteration   = best_results$iteration[[idx]],
                        map_type    = "interactive"
                    )
                )
            })
        }

        progress_bmr$inc(0.34, detail = "Done!")
    })

    # -- MaxEnt --------------------------------------------------------------
    observeEvent(input$go_maxent, {
        if (!v$partitioning_type %in% c("block", "checkerboard1", "checkerboard2")) {
            output$maxent_auc <- renderText(
                "Please select a spatial partitioning method (block or checkerboard)."
            )
            return()
        }

        progress_me <- shiny::Progress$new()
        on.exit(progress_me$close())
        progress_me$set(message = "Status", value = 0)
        progress_me$inc(0.5, detail = "Evaluating MaxEnt...")

        maxent_results <- sdmbench::evaluate_maxent(
            raster_data = v$data$raster_data,
            method      = v$partitioning_type
        )

        progress_me$inc(0.3, detail = "Rendering MaxEnt map...")
        output$maxent_auc <- renderText(round(maxent_results$best_auc, 4))

        pal <- leaflet::colorNumeric(
            c("#ffdbe2", "#fff56b", "#58ff32"),
            terra::values(maxent_results$best_model_pr),
            na.color = "transparent"
        )
        output$maxent_map <- leaflet::renderLeaflet(
            leaflet::leaflet(data = v$data$raster_data$coords_presence) |>
                leaflet::addTiles() |>
                leaflet::addRasterImage(
                    raster::raster(maxent_results$best_model_pr),
                    colors  = pal,
                    opacity = 0.5
                ) |>
                leaflet::addLegend(
                    title   = "Habitat Suitability",
                    pal     = pal,
                    values  = terra::values(maxent_results$best_model_pr),
                    opacity = 1
                )
        )
        progress_me$inc(0.2, detail = "Done.")
    })

    # -- Deep Learning -------------------------------------------------------
    observeEvent(input$go_dl, {
        progress_dl <- shiny::Progress$new()
        on.exit(progress_dl$close())
        progress_dl$set(message = "Status", value = 0)
        progress_dl$inc(0.33, detail = "Preparing training data...")

        benchmarking_data_dl <- sdmbench::prepare_dl_data(
            input_data       = v$data$df_data,
            partitioning_type = v$partitioning_type
        )

        progress_dl$inc(0.33, detail = "Training neural network...")
        keras_results    <- sdmbench::train_dl(benchmarking_data_dl)
        keras_evaluation <- sdmbench::evaluate_dl(keras_results$model, benchmarking_data_dl)

        # Predict function that applies recipe + keras model to raster data
        rec_obj <- benchmarking_data_dl$rec_obj
        dl_predict_fun <- function(model, input_data) {
            input_data <- tibble::as_tibble(input_data)
            baked      <- recipes::bake(rec_obj, new_data = input_data)
            as.vector(predict(model, as.matrix(baked)))
        }

        output$dl_auc     <- renderText(paste("AUC:", sdmbench::get_dl_auc(keras_evaluation)))
        output$dl_history <- renderPlot(plot(keras_results$history))
        output$dl_map     <- leaflet::renderLeaflet(
            sdmbench::plot_dl_map(
                raster_data = v$data$raster_data,
                keras_model = keras_results$model,
                custom_fun  = dl_predict_fun,
                map_type    = "interactive"
            )
        )

        progress_dl$inc(0.34, detail = "Done!")
    })
}
