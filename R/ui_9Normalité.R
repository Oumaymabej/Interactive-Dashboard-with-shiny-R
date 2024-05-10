

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
    box(withSpinner(plotOutput(
      "qqPlot", height = 500, width = 850
    )), width = 10),
    box(uiOutput("choisirCol"),width = 2
    ),
    box(withSpinner(plotOutput(
      "densityPlot", height = 500, width = 850
      )),width = 10),
    box("choix_du_test",
        selectInput("PrintTest", "Choisir un Test :", choices = c("Kolmogorov-Smirnov", "Shapiro-Wilk","Jarque-Bera")),
        htmlOutput("testResult")        

  ))
)
)

