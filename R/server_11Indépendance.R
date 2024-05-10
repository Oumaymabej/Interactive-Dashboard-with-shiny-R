


output$Collonne44 = renderUI({
  selectInput("Collonne44", "Sélectionner Variable 1", 
              c(selectdata()$FeatureValue[which(selectdata()$FeatureName == "Variable quantitative")]), "Variable quantitative")
})

output$Collonne55 = renderUI({
  selectInput("Collonne55", "Sélectionner Variable 2", 
              c(selectdata()$FeatureValue[which(selectdata()$FeatureName == "Variable quantitative")]), "Variable quantitative")
})
# **************************Reactive Variable**************************
dataInput200 = reactive({
  
  if (is.null(input$Collonne44) & is.null(input$Collonne55)) {
    return(NULL)
  } else if (input$Collonne44 != input$Collonne55) {
    inputdata200 = finalInputData() %>% select(one_of(c(input$Collonne44,input$Collonne55)))
    colnames(inputdata200) = c("XVar", "YVar")
    return(inputdata200)
  } else if(input$Collonne44 == input$Collonne55) {
    inputdata200 = finalInputData() %>% select(one_of(c(input$Collonne44,input$Collonne55)))
    colnames(inputdata200) = c("XVar")
    inputdata200$YVar = inputdata200$XVar
    return(inputdata200)
  }
})
# **************************Outputs**************************
output$testResult3 <- renderText({
  req(input$PrintTest3, dataInput200())
  
  # Perform the selected test based on user input
  result_text7 <- NULL

  if (input$PrintTest3 == "Test de Student") {
    result_text7 <- t.test(dataInput200()$XVar, dataInput200()$YVar)

  } else if (input$PrintTest3 == "Test du Khi-deux (χ²)") {
    result_text7 <- chisq.test(dataInput200()$XVar, dataInput200()$YVar)

  } else if (input$PrintTest3 == "Test de Fisher") {
    result_text7 <- var.test(dataInput200()$XVar, dataInput200()$YVar)

  } 

  
  # Format the result for display with HTML tags
  if (!is.null(result_text7)) {
    result_text7 <- paste("Test : <strong>", input$PrintTest3, "</strong><br>",
                         "p-value: <strong>", format(result_text7$p.value, digits = 3), "</strong><br>",
                         "Test Statistique: <strong>", format(result_text7$statistic, digits = 3), "</strong><br>")

    
    # Use HTML function to interpret HTML tags
    HTML(result_text7)
  } else {
    "No result available."
  }
})



# **************************Reactive Variable for ANOVA**************************
dataInputANOVA = reactive({
  if (is.null(input$Collonne44) | is.null(input$Collonne55)) {
    return(NULL)
  } else {
    inputdataANOVA = finalInputData() %>% select(one_of(c(input$Collonne44, input$Collonne55)))
    colnames(inputdataANOVA) = c("XVar", "YVar")
    return(inputdataANOVA)
  }
})

# **************************Output for ANOVA**************************
output$anovaResult <- renderText({
  req(dataInputANOVA())
  
  # Perform ANOVA test
  result_anova <- anova(lm(YVar ~ XVar, data = dataInputANOVA()))
  
  # Format the result for display with HTML tags
  result_text_anova <- paste(
                             "F-Value: <strong>", format(result_anova$`F value`, digits = 3), "</strong><br>",
                             "Pr(>F): <strong>", format(result_anova$`Pr(>F)`, digits = 3), "</strong><br>",
                             "Degré de liberté : <strong>", result_anova$Df[1], ", ", result_anova$Df[2], "</strong><br>")
  
  # Use HTML function to interpret HTML tags
  HTML(result_text_anova)
})
