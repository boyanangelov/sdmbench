#' Start sdmbench GUI
#'
#' @return Shiny app object
run_sdmbench <- function() {
    app_path <- system.file("shiny", package = "sdmbench")
    return(shiny::runApp(app_path, launch.browser = TRUE))
    # return(shiny::runApp(app_path)) # for development
}
