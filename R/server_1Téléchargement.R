# ************************************Data Source************************************
library(highcharter)

# **************************Select Inputs**************************
output$FileInput = renderUI({
  fileInput("datafile", "Choisir un fichier", accept = c(".xlsx,.rda,.csv"))
})
output$SelectSheet = renderUI({
  if (!is.null(fileSheets()))
    radioButtons("sheetName", "Select Sheet Name", c(fileSheets()), inline = TRUE)
})
output$InputValidation = renderText({
  inFile = input$fileType
  if (is.null(inFile)) {
    return()
  } else {
    HTML(validateInput())
  }
})
# **************************Reactive Variable**************************
validateInput <- eventReactive(input$btSubmit, {
  valIn <- ""
  validate(need(input$datafile, "Sélectionner un fichier"))
  validate(need(file_ext(input$datafile$name) %in% c("xlsx", "csv", "rda"), "Unsupported file format"))
  return(valIn)
})
output$ValFlag <- reactive({
  return(!is.null(validateInput()))
})
outputOptions(output, 'ValFlag', suspendWhenHidden=FALSE)
fileSheets <- reactive({ 
  inFile <- input$datafile
  if (!is.null(inFile)) {
    validate(need(inFile, message = FALSE))
    inputbook <- loadWorkbook(inFile$datapath)
    sheetnames <- names(getSheets(inputbook))
    return(sheetnames)
  }
})
uploadData <- reactiveValues()
observeEvent(input$btSubmit, {
  if (validateInput() == "") {
    inFile <- input$datafile
    if (!is.null(inFile)) {
      if (file_ext(inFile$name) %in% c("xlsx")) {
        validate(need(input$datafile, message = FALSE))
        inputbook <- loadWorkbook(inFile$datapath)
        uploadData$fiData <- read.xlsx2(input$datafile$datapath, sheetName = input$sheetName, header = input$header, stringsAsFactors = FALSE, na.strings = c("", "NA","N/A","n/a","na"))
        # Ensure that empty strings and "NA" are treated as NA during XLSX import
      } else if (file_ext(inFile$name) %in% c("csv")) {
        validate(need(input$datafile, message = FALSE))
        uploadData$fiData <- read.csv(input$datafile$datapath, header = input$header, sep = input$sep, stringsAsFactors = FALSE, na.strings = c("", "NA","N/A","n/a","na"))
        # Ensure that empty strings and "NA" are treated as NA during CSV import
      } else if (file_ext(inFile$name) %in% c("rda")) {
        validate(need(input$datafile, message = FALSE))
        dsName <- load(input$datafile$datapath)
        uploadData$fiData <- get(dsName)
      }
    }
  }
})
output$DataTable = DT::renderDataTable({
  if(input$btSubmit > 1 || input$btExplore == 0){
    uploadData$fiData
  }
  else if(input$btExplore > 0){
    finalInputData()
  }
}, 
options = list(lengthMenu = c(5, 30, 50), pageLength = 10, scrollX = TRUE, scrollY = '500px', autoWidth = TRUE),
width = '100%' # Adjust the width as needed
)
fn_GetDataStructure = function(idata){
  dstr = data.frame(Variable = idata %>% colnames,
                    Class = idata %>% sapply(typeof), stringsAsFactors = FALSE)
  dstr = dstr %>% mutate(DMClass = if_else(Class %in% c("integer","numeric"), "Variable quantitative","Variable qualitative"))
  row.names(dstr) = NULL
  return(dstr)
}
rbVarReactive = reactiveValues(IsRbLoaded = FALSE)
output$SelDimMeas = renderUI({
  if (is.null(uploadData$fiData)) {
    return(NULL)
  } else {
    dsstr = fn_GetDataStructure(uploadData$fiData)
    rbVarReactive$IsRbLoaded = TRUE
    lapply(dsstr$Variable, function(x) {
      rbSel = dsstr[dsstr$Variable == x, ]$DMClass
      list(radioButtons(
        paste0("rb", x),
        x,
        choices = c(
          `Variable qualitative` = "Variable qualitative",
          `Variable quantitative` = "Variable quantitative",
          `Exclure` = "Exclure"
          
        ),
        selected = rbSel,
        inline = TRUE
        
      ))
    })
  }
})
# Define a reactiveValues object to store user selections
userSelections <- reactiveValues(selectedColumns = NULL)

observeEvent(input$validerplz, {
  if (!is.null(input$validerplz) && input$validerplz == 1) {
    # Retrieve data structure and filtered columns with missing values
    dsstr <- fn_GetDataStructure(uploadData$fiData)
    cols_with_missing <- colnames(uploadData$fiData)[colSums(is.na(uploadData$fiData)) > 0]
    
    # Filter the columns based on data structure and missing values
    cols_to_impute <- intersect(cols_with_missing, dsstr$Variable)
    
    # Generate radio buttons only for columns with missing values
    imputeOptionsList <- lapply(cols_to_impute, function(var) {
      dmClass <- dsstr$DMClass[dsstr$Variable == var]
      choices <- switch(dmClass,
                        "Variable quantitative" = c("Mean", "Median", "Do Not Impute"),
                        "Variable qualitative" = c("Mode", "Do Not Impute"))
      radioButtons(
        paste0("impute", var),
        var,
        choices = choices,
        inline = TRUE
      )
    })
    
    output$imputationOptions <- renderUI({
      imputeOptionsList
    })
  }
})


# Handle Exclusion
observeEvent(input$applyChanges, {
  if (!is.null(uploadData$fiData)) {
    dsstr <- fn_GetDataStructure(uploadData$fiData)
    for (var in dsstr$Variable) {
      dmClass <- input[[paste0("rb", var)]]
      if (dmClass == "Exclure") {
        # Exclude the column from further processing
        uploadData$fiData <- uploadData$fiData[, -which(names(uploadData$fiData) == var)]
      }
    }
    # Perform further processing as needed
    missingValuesHandled$handled <- TRUE
  }
})




finalInputData = eventReactive(input$btExplore, {
  if (rbVarReactive$IsRbLoaded == TRUE) {
    dsstr = fn_GetDataStructure(uploadData$fiData)
    udstr = sapply(dsstr$Variable, function(x) gsub(pattern = "\\[1\\]|\"|\\n", 
                                                    x = evaluate::evaluate(paste0("input$rb",x))[[2]] , 
                                                    replacement = ""))
    udstr = data.frame(Variable = names(udstr), UserClass = udstr, stringsAsFactors = FALSE)
    row.names(udstr) = NULL
    udstr$UserClass = str_trim(udstr$UserClass, side = "both")
    dnames = udstr %>% filter(UserClass == "Variable qualitative") %>% select(Variable) %>% collect %>% .[["Variable"]]
    mnames = udstr %>% filter(UserClass == "Variable quantitative") %>% select(Variable) %>% collect %>% .[["Variable"]]
    usrStructData = uploadData$fiData
    if(!is.null(dnames))
      usrStructData[,dnames] = lapply(usrStructData[,dnames], as.factor)
    if(!is.null(mnames))
      usrStructData[,mnames] = lapply(usrStructData[,mnames], as.numeric)
    usrStructData = usrStructData %>% select(one_of(c(dnames, mnames)))
    return(usrStructData)
  } else {
    return(NULL)
  }
})
ValTabs = reactiveValues(Tabs = TRUE, Plots = FALSE)
observeEvent(input$fileType,{
  if(is.null(input$datafile)){
    ValTabs$Tabs = TRUE
    ValTabs$Plots = FALSE
  }
})
observeEvent(input$btExplore,{
  if(!is.null(input$btExplore)){
    ValTabs$Tabs = FALSE
    ValTabs$Plots = TRUE
    newtab <- switch(input$MenuTabs, "Téléchargement" = "Univarié","Univarié" = "Téléchargement")
    updateTabItems(session, "MenuTabs", newtab)
  }
})



observeEvent(input$validerplz, {
  if (!is.null(input$validerplz) && input$validerplz == 1) {
    newtab <- switch(input$InputData,  # Use the correct ID here
                     "Choisir les attributs des colonnes" = "Néttoyage de la data",
                     "Néttoyage de la data" = "Choisir les attributs des colonnes"
    )
    updateTabItems(session, "InputData", newtab)  # Use the correct ID here
  }
})



output$ValTabs <- reactive({
  return(ValTabs$Tabs)
})
outputOptions(output, 'ValTabs', suspendWhenHidden=FALSE)

output$ValPlots <- reactive({
  return(ValTabs$Plots)
})
outputOptions(output, 'ValPlots', suspendWhenHidden=FALSE)
rmeasures = reactive({
  return(colnames(finalInputData() %>% select_if(is.numeric)))
})
rdimensions = reactive({
  return(colnames(finalInputData() %>% select_if(is.factor)))
})
selectdata = reactive({
  measures = colnames(finalInputData() %>% select_if(is.numeric))
  dimensions = colnames(finalInputData() %>% select_if(is.factor))
  seldata = data.frame(FeatureName = character(), FeatureValue = character(), stringsAsFactors = FALSE)
  if(length(measures)>1)
    seldata = rbind(seldata, 
                    data.frame(FeatureName = paste("Variable quantitative"), FeatureValue = measures, stringsAsFactors = FALSE))
  if(length(dimensions)>1)
    seldata = rbind(seldata, 
                    data.frame(FeatureName = paste("Variable qualitative"), FeatureValue = dimensions, stringsAsFactors = FALSE))
  return(seldata)
})
###############################################################################

# Generate radio buttons for imputation options based on user selections
# Update the output$imputationOptions to filter columns with missing values
# Update the output$imputationOptions to filter columns with missing values and relevant data types
output$imputationOptions <- renderUI({
  if (!is.null(uploadData$fiData)) {
    dsstr <- fn_GetDataStructure(uploadData$fiData)
    cols_with_missing <- colnames(uploadData$fiData)[colSums(is.na(uploadData$fiData)) > 0]
    
    # Filter out columns without missing values
    cols_with_missing <- cols_with_missing[cols_with_missing %in% dsstr$Variable]
    
    # Generate radio buttons for imputation options only for columns with missing values
    imputeOptionsList <- lapply(cols_with_missing, function(var) {
      dmClass <- dsstr$DMClass[dsstr$Variable == var]
      choices <- switch(dmClass,
                        "Variable quantitative" = c("Mean", "Median", "Do Not Impute"),
                        "Variable qualitative" = c("Mode", "Do Not Impute"))
      radioButtons(
        paste0("impute", var),
        var,
        choices = choices,
        inline = TRUE
      )
    })
    
    return(imputeOptionsList)
  } else {
    return(NULL)  # Return nothing if there's no data
  }
})



# Handle missing values based on user selections
# Update observeEvent(input$applyChanges) to handle missing values only for selected columns
# Handle imputation when "affecter" button is pressed
observeEvent(input$validerplz, {
  if (!is.null(input$validerplz) && input$validerplz == 1) {
    observeEvent(input$applyChanges, {
      if (!is.null(uploadData$fiData)) {
        dsstr <- fn_GetDataStructure(uploadData$fiData)
        cols_with_missing <- colnames(uploadData$fiData)[colSums(is.na(uploadData$fiData)) > 0 & dsstr$DMClass %in% c("Variable quantitative", "Variable qualitative")]
        for (var in cols_with_missing) {
          imputation_method <- input[[paste0("impute", var)]]
          if (imputation_method == "Mean") {
            # Perform mean imputation for quantitative variable 'var'
            uploadData$fiData[[var]][is.na(uploadData$fiData[[var]])] <- mean(uploadData$fiData[[var]], na.rm = TRUE)
          } else if (imputation_method == "Median") {
            # Perform median imputation for quantitative variable 'var'
            uploadData$fiData[[var]][is.na(uploadData$fiData[[var]])] <- median(uploadData$fiData[[var]], na.rm = TRUE)
          } else if (imputation_method == "Mode") {
            # Perform mode imputation for qualitative variable 'var'
            mode_val <- names(sort(table(uploadData$fiData[[var]]), decreasing = TRUE))[1]
            uploadData$fiData[[var]][is.na(uploadData$fiData[[var]])] <- mode_val
          }
        }
      }
    })
  }
})




# Define a reactiveValues object to store missing values handling status
missingValuesHandled <- reactiveValues(handled = FALSE)






###############################################################################
output$dataInfo <- renderUI({
  validate(need(input$btSubmit, message=FALSE))
  if (is.null(uploadData$fiData)) {
    return(NULL)
  } else {
    if (inherits(uploadData$fiData, "try-error", which = F)) {
      h3("Data input failed due to an unkown reason")
    } else {
      if (any(duplicated(colnames(uploadData$fiData)))) {
        h6("Duplicated colnames are not allowed")
      } else {
        HTML(
          paste0(
            "La table de données téléchargée a <b>",
            ncol(uploadData$fiData),
            " colonnes</b> et <b>",
            nrow(uploadData$fiData),
            " lignes</b>",
            "<br/> La structure des données est comme suit :"
          )
        )
      }
    }
  }
})
###############################################################################
# Function to calculate missing values count
missing_values_count <- function(data_val) {
  total_missing <- colSums(is.na(data_val))
  total_df <- data.frame(column = names(total_missing), count = total_missing)
  return(total_df)
}








# Render histogram of missing values
output$missing_histogram <- renderHighchart({
  
  total_df <- missing_values_count(uploadData$fiData)
  highchart() %>%
    hc_add_series(total_df, type = "column", hcaes(x = column, y = count)) %>%
    hc_title(text = "Total des valeurs manquantes par colonne") %>%
    hc_xAxis(categories = total_df$column) %>%
    hc_yAxis(title = list(text = "Nombre des valeurs manquantes")) %>%
    hc_tooltip(pointFormat = "Column: <b>{point.category}</b><br>Missing Values: <b>{point.y}</b>")
  
})







###############################################################################



output$strData <- renderPrint({
  validate(need(input$btSubmit, message=FALSE))
  if (is.null(uploadData$fiData)) {
    return(NULL)
  } else if(input$btSubmit > 1 || input$btExplore == 0){
    str(uploadData$fiData)
  }
  else if(input$btExplore > 0){
    str(finalInputData())
  }
})

observeEvent(input$btSubmit, {
  if (input$btSubmit >= 2) {
    ValTabs$Tabs = TRUE
    ValTabs$Plots = FALSE
  }
})  
