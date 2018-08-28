#' Start sdmbench GUI in a browser window.
#'
#' This interface can be used to use the complete package functionality without
#' writing code.
#'
#' @return A shiny app object
#' @examples
#' run_sdmbench()
run_sdmbench <- function() {
    app_path <- system.file("shiny", package = "sdmbench")
    return(shiny::runApp(app_path, launch.browser = TRUE))
}
