library(shinydashboard)

dashboardPage(
    skin = "green",
    dashboardHeader(title = "SDMBench"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Data",           tabName = "get_data"),
            menuItem("General Models", tabName = "gen_methods"),
            menuItem("MaxEnt",         tabName = "profile_methods"),
            menuItem("Deep Learning",  tabName = "dl_methods")
        ),
        tags$hr(),
        checkboxInput("custom_data", "Use custom data?", FALSE),
        tags$p("* at the moment just for General Models",
               style = "margin-left: 15px;"),
        fileInput(
            "file1",
            "Upload custom data",
            multiple = FALSE,
            accept   = c("text/csv", "text/comma-separated-values,text/plain", ".csv")
        ),
        actionButton(
            "go_custom", "Parse custom data",
            icon  = icon("play"),
            style = "width: 200px; font-weight: bold; border: 2px;"
        ),
        tags$hr(),
        textInput("text", "Species name:"),
        numericInput("limit", "Max number of records:", 1000, min = 1, max = 200000),
        selectInput(
            "climate_type", "Climate type:",
            c("Default" = "default", "Future (CMIP5)" = "future")
        ),
        textInput("projected_model", "Climate projection*", value = "BC"),
        numericInput("rcp", "RCP (26, 45, 60 or 85):", 45),
        numericInput("years", "Years into future (50 or 70):", 50),
        numericInput("climate_resolution", "Climate resolution (arc-min):", 10),
        checkboxInput("sample", "Undersample background?", FALSE),
        tags$p("* see WorldClim website for CMIP5 model codes",
               style = "margin-left: 15px;"),
        selectInput(
            "data_partitioning_type", "Spatial partitioning:",
            c(
                "Default"       = "default",
                "Block"         = "block",
                "Checkerboard1" = "checkerboard1",
                "Checkerboard2" = "checkerboard2"
            )
        ),
        actionButton(
            "go", "Get Data",
            icon  = icon("download"),
            style = "width: 200px; font-weight: bold; border: 2px;"
        ),
        tags$hr(),
        checkboxGroupInput(
            "checkGroup",
            h5("Algorithm selection"),
            choices = list(
                "Random Forest"         = "classif.ranger",
                "Logistic Regression"   = "classif.log_reg",
                "Decision Tree"         = "classif.rpart",
                "Support Vector Machine" = "classif.svm",
                "eXtreme Gradient Boosting" = "classif.xgboost",
                "Multinomial Regression" = "classif.multinom",
                "Naive Bayes"           = "classif.naive_bayes",
                "K-Nearest Neighbours"  = "classif.kknn"
            ),
            selected = "classif.ranger"
        ),
        actionButton("go_bmr",    "General Models", style = "width: 200px;"),
        actionButton("go_maxent", "MaxEnt",         style = "width: 200px;"),
        actionButton("go_dl",     "Neural Network", style = "width: 200px;")
    ),
    dashboardBody(
        shinyjs::useShinyjs(),
        tags$head(
            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
        ),
        tabItems(
            tabItem(
                tabName = "get_data",
                fluidRow(
                    box(
                        leaflet::leafletOutput("occ_map"),
                        title      = "Occurrence Map",
                        collapsible = TRUE,
                        collapsed   = TRUE,
                        status      = "success",
                        solidHeader = TRUE,
                        width       = 12
                    )
                ),
                fluidRow(
                    box(
                        div(style = "overflow-x: scroll", tableOutput("table")),
                        title      = "Climate Variables (preview)",
                        collapsible = TRUE,
                        collapsed   = TRUE,
                        status      = "info",
                        solidHeader = TRUE,
                        width       = 12
                    )
                )
            ),

            tabItem(
                tabName = "gen_methods",
                fluidRow(
                    box(
                        tableOutput("bmr_results"),
                        title      = "Benchmarking Results",
                        solidHeader = TRUE,
                        status      = "success"
                    ),
                    box(
                        plotOutput("bmr_plot1"),
                        title      = "AUC by Algorithm",
                        solidHeader = TRUE,
                        status      = "info"
                    )
                ),
                fluidRow(
                    box(leaflet::leafletOutput("model_map_1"),  title = "SDM Map 1",  collapsible = TRUE, collapsed = TRUE),
                    box(leaflet::leafletOutput("model_map_2"),  title = "SDM Map 2",  collapsible = TRUE, collapsed = TRUE)
                ),
                fluidRow(
                    box(leaflet::leafletOutput("model_map_3"),  title = "SDM Map 3",  collapsible = TRUE, collapsed = TRUE),
                    box(leaflet::leafletOutput("model_map_4"),  title = "SDM Map 4",  collapsible = TRUE, collapsed = TRUE)
                ),
                fluidRow(
                    box(leaflet::leafletOutput("model_map_5"),  title = "SDM Map 5",  collapsible = TRUE, collapsed = TRUE),
                    box(leaflet::leafletOutput("model_map_6"),  title = "SDM Map 6",  collapsible = TRUE, collapsed = TRUE)
                ),
                fluidRow(
                    box(leaflet::leafletOutput("model_map_7"),  title = "SDM Map 7",  collapsible = TRUE, collapsed = TRUE),
                    box(leaflet::leafletOutput("model_map_8"),  title = "SDM Map 8",  collapsible = TRUE, collapsed = TRUE)
                )
            ),

            tabItem(
                tabName = "profile_methods",
                fluidRow(
                    box(
                        textOutput("maxent_auc"),
                        title      = "MaxEnt AUC",
                        status     = "success",
                        solidHeader = TRUE
                    ),
                    box(
                        leaflet::leafletOutput("maxent_map"),
                        title      = "MaxEnt Map",
                        collapsible = TRUE,
                        collapsed   = TRUE
                    )
                )
            ),

            tabItem(
                tabName = "dl_methods",
                fluidRow(
                    box(
                        textOutput("dl_auc"),
                        plotOutput("dl_history"),
                        title      = "Deep Learning Performance",
                        status     = "success",
                        solidHeader = TRUE
                    ),
                    box(
                        leaflet::leafletOutput("dl_map"),
                        title      = "Deep Learning Map",
                        collapsible = TRUE,
                        collapsed   = TRUE
                    )
                )
            )
        )
    )
)
