fluidPage(
  # supress error messages in app
  tags$style(
    type = 'text/css',
    ".shiny-output-error{ visibility: hidden;}",
    ".shiny-output-error:before { visibility:hidden; }"
  ),
  source("./ui_CustomError.R", local = T)[1],
  fluidRow(conditionalPanel(
    "output.ValPlots",
    box(withSpinner(plotlyOutput(
      "heatmapPlot", height = 450, width = 850
    )), width = 10),
    box(uiOutput("Collonne23"),width = 2
    ),
    box(uiOutput("Collonne33"),width = 2
    ),
    box("choix_du_test2",
        selectInput("PrintTest2", "Choisir un Testttt :", choices = c("Pearson_correlation_test", "Spearman_correlation_test")),
        htmlOutput("testResult2")   
  )
  )
))