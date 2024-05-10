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
    box(uiOutput("Collonne44"),width = 4
    ),
    box(uiOutput("Collonne55"),width = 4
    ),
    box(
        selectInput("PrintTest3", "Choix des tests :", choices = c("Test de Student", "Test du Khi-deux (χ²)","Test de Fisher")),
        htmlOutput("testResult3")   
    ),
    box("Analyse de variance (ANOVA)",
        width = 12,
        htmlOutput("anovaResult")
        
        )
  ))
)