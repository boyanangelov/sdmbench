server <- function(input, output) {

    shinyjs::disable("go_bmr")
    shinyjs::disable("go_maxent")
    shinyjs::disable("go_profile")
    shinyjs::disable("go_dl")

    data("wrld_simpl", package = "maptools")

    v <- reactiveValues(data = NULL, bmr = NULL, partitioning_type = NULL)
    observeEvent(input$go, {
        req(input$text)


        progress <- shiny::Progress$new()

        progress$set(message = "Status", value = 0)
        progress$inc(1/4, detail = "Downloading species occurence data and bioclim variables...")

        benchmarking_data <- get_benchmarking_data(scientific_name = input$text,
                                                   limit = input$limit)

        progress$inc(1/4, detail = "Processing data...")

        benchmarking_data$df_data <- partition_data(dataset_raster = benchmarking_data$raster_data,
                                                   dataset = benchmarking_data$df_data,
                                                   env = benchmarking_data$raster_data$bioclim_data,
                                                   method = input$data_partitioning_type)

        progress$inc(1/4, detail = "Plotting map...")


        output$table <- renderTable(head(benchmarking_data$df_data))
        output$species_name <- renderText(input$text)


        output$occ_map <- renderPlot(raster::plot(benchmarking_data$raster_data$bioclim_data, 1) +
                                         points(benchmarking_data$raster_data$coords_presence,
                                                col = "red", cex=1.15, pch = 10) +
                                         raster::plot(wrld_simpl, add = TRUE, border = "darkgrey"))

        progress$inc(1/4, detail = "Finished")
        progress$close()

        v$data <- benchmarking_data
        v$partitioning_type = input$data_partitioning_type

        shinyjs::enable("go_bmr")
        shinyjs::enable("go_maxent")
        shinyjs::enable("go_profile")
        shinyjs::enable("go_dl")

    })

    observeEvent(input$go_bmr, {
        benchmarking_data <- v$data
        partitioning_type <- v$partitioning_type


        progress_bmr <- shiny::Progress$new()
        progress_bmr$set(message = "Status", value = 0)
        progress_bmr$inc(1/3, detail = "Benchmarking...")

        learners_list = input$checkGroup
        learners <- list()
        for (i in 1:length(learners_list)) {
            learners[[i]] <- mlr::makeLearner(learners_list[[i]], predict.type = "prob")
        }

        benchmarking_data$df_data <- na.omit(benchmarking_data$df_data)
        bmr <- benchmark_sdm(benchmarking_data = benchmarking_data$df_data,
                             learners = learners,
                             dataset_type =  partitioning_type,
                             sample = input$sample)

        progress_bmr$inc(1/3, detail = "Plotting benchmark results...")
        output$bmr_plot1 <- renderPlot(plotBMRBoxplots(bmr, measure = mlr::auc))
        output$bmr_results <- renderTable(get_best_model_results(bmr))


        bmr_models <- mlr::getBMRModels(bmr)
        best_results <- get_best_model_results(bmr)

        output$model_map_1 <- renderPlot(plot_sdm_map(raster_data = benchmarking_data$raster_data$bioclim_data,
                                                      bmr_models = bmr_models,
                                                    model_id = best_results$learner.id[1],
                                                    model_iteration = best_results$iter[1]) +
                                             raster::plot(wrld_simpl, add = TRUE, border = "darkgrey"))

        output$model_map_2 <- renderPlot(plot_sdm_map(raster_data = benchmarking_data$raster_data$bioclim_data,
                                                      bmr_models = bmr_models,
                                                    model_id = best_results$learner.id[2],
                                                    model_iteration = best_results$iter[2]) +
                                             raster::plot(wrld_simpl, add = TRUE, border = "darkgrey"))

        output$model_map_3 <- renderPlot(plot_sdm_map(raster_data = benchmarking_data$raster_data$bioclim_data,
                                                      bmr_models = bmr_models,
                                                    model_id = best_results$learner.id[3],
                                                    model_iteration = best_results$iter[3]) +
                                             raster::plot(wrld_simpl, add = TRUE, border = "darkgrey"))

        output$model_map_4 <- renderPlot(plot_sdm_map(raster_data = benchmarking_data$raster_data$bioclim_data,
                                                      bmr_models = bmr_models,
                                                    model_id = best_results$learner.id[4],
                                                    model_iteration = best_results$iter[4]) +
                                             raster::plot(wrld_simpl, add = TRUE, border = "darkgrey"))
        output$model_map_5 <- renderPlot(plot_sdm_map(raster_data = benchmarking_data$raster_data$bioclim_data,
                                                      bmr_models = bmr_models,
                                                      model_id = best_results$learner.id[5],
                                                      model_iteration = best_results$iter[5]) +
                                             raster::plot(wrld_simpl, add = TRUE, border = "darkgrey"))
        output$model_map_6 <- renderPlot(plot_sdm_map(raster_data = benchmarking_data$raster_data$bioclim_data,
                                                      bmr_models = bmr_models,
                                                      model_id = best_results$learner.id[6],
                                                      model_iteration = best_results$iter[6]) +
                                             raster::plot(wrld_simpl, add = TRUE, border = "darkgrey"))
        output$model_map_7 <- renderPlot(plot_sdm_map(raster_data = benchmarking_data$raster_data$bioclim_data,
                                                      bmr_models = bmr_models,
                                                      model_id = best_results$learner.id[7],
                                                      model_iteration = best_results$iter[7]) +
                                             raster::plot(wrld_simpl, add = TRUE, border = "darkgrey"))
        output$model_map_8 <- renderPlot(plot_sdm_map(raster_data = benchmarking_data$raster_data$bioclim_data,
                                                      bmr_models = bmr_models,
                                                      model_id = best_results$learner.id[8],
                                                      model_iteration = best_results$iter[8]) +
                                             raster::plot(wrld_simpl, add = TRUE, border = "darkgrey"))
        output$model_map_9 <- renderPlot(plot_sdm_map(raster_data = benchmarking_data$raster_data$bioclim_data,
                                                      bmr_models = bmr_models,
                                                      model_id = best_results$learner.id[9],
                                                      model_iteration = best_results$iter[9]) +
                                             raster::plot(wrld_simpl, add = TRUE, border = "darkgrey"))
        output$model_map_10 <- renderPlot(plot_sdm_map(raster_data = benchmarking_data$raster_data$bioclim_data,
                                                      bmr_models = bmr_models,
                                                      model_id = best_results$learner.id[10],
                                                      model_iteration = best_results$iter[10]) +
                                             raster::plot(wrld_simpl, add = TRUE, border = "darkgrey"))

        progress_bmr$inc(1/3, detail = "Done!")
        progress_bmr$close()

    })

    observeEvent(input$go_maxent, {


        if (v$partitioning_type %in% c("block", "checkerboard1", "checkerboard2")) {
            data("wrld_simpl", package = "maptools")
            progress_meeval <- shiny::Progress$new()
            progress_meeval$set(message = "Status", value = 0)
            progress_meeval$inc(1/3, detail = "Evaluating MaxEnt...")

            maxent_results <- evaluate_maxent(raster_data = v$data$raster_data,
                                              method = v$partitioning_type)

            progress_meeval$inc(1/3, detail = "Plotting MaxEnt map")

            output$maxent_auc <- renderText(maxent_results$best_auc)
            output$maxent_map <- renderPlot(raster::plot(maxent_results$best_model_pr)+
                                                raster::plot(wrld_simpl, add = TRUE, border = "darkgrey"))


            progress_meeval$inc(1/3, detail = "Finished")
            progress_meeval$close()

        } else {
            output$maxent_auc <- renderText("Select a partitioning method (current is default).")
        }
    })


    observeEvent(input$go_dl, {
        progress_dl <- shiny::Progress$new()
        progress_dl$set(message = "Status", value = 0)
        progress_dl$inc(1/3, detail = "Preparing training data...")

        df_data <- v$data$df_data

        benchmarking_data_dl <- prepare_dl_data(input_data = df_data,
                                                partitioning_type = v$partitioning_type)
        progress_dl$inc(1/3, detail = "Training network...")
        keras_results <- train_dl(benchmarking_data_dl)
        keras_evaluation <- evaluate_dl(model_keras = keras_results$model,
                                        input_data = benchmarking_data_dl)

        temp_fun <- function(model, input_data) {
            input_data <- tibble::as_tibble(input_data)
            data <- recipes::bake(benchmarking_data_dl$rec_obj,
                                  newdata = input_data)

            v <- keras::predict_proba(object = model, x = as.matrix(data))
            as.vector(v)
        }

        output$dl_auc<- renderText(paste("AUC: ", get_dl_auc(keras_evaluation)))
        output$dl_map <- renderPlot(plot_dl_map(raster_data = v$data$raster_data$bioclim_data,
                                                keras_model = keras_results$model,
                                                custom_fun = temp_fun)+
                                        raster::plot(wrld_simpl, add = TRUE, border = "darkgrey"))
        output$dl_history <- renderPlot(plot(keras_results$history))

        progress_dl$inc(1/3, detail = "Finished!")
        progress_dl$close()
    })

}
