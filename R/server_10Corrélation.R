library(plotly)
library(stats)


output$Collonne23 = renderUI({
  selectInput("Collonne23", "Sélectionner Mesure 1", 
              c(selectdata()$FeatureValue[which(selectdata()$FeatureName == "Variable quantitative")]), "Variable quantitative")
})

output$Collonne33 = renderUI({
  selectInput("Collonne33", "Sélectionner Mesure 2", 
              c(selectdata()$FeatureValue[which(selectdata()$FeatureName == "Variable quantitative")]), "Variable quantitative")
})
# **************************Reactive Variable**************************
dataInput100 = reactive({
 
  if (is.null(input$Collonne23) & is.null(input$Collonne33)) {
    return(NULL)
  } else if (input$Collonne23 != input$Collonne33) {
    inputdata100 = finalInputData() %>% select(one_of(c(input$Collonne23,input$Collonne33)))
    colnames(inputdata100) = c("XVar", "YVar")
    return(inputdata100)
  } else if(input$Collonne23 == input$Collonne33) {
    inputdata100 = finalInputData() %>% select(one_of(c(input$Collonne23,input$Collonne33)))
    colnames(inputdata100) = c("XVar")
    inputdata100$YVar = inputdata100$XVar
    return(inputdata100)
  }
})
# **************************Outputs**************************
output$heatmapPlot = renderPlotly(
  if(is.null(finalInputData() %>% select_if(is.numeric))) {print('hello')
    return()
  } else {
    
    plotly::subplot(plot_ly(x = colnames(cor(finalInputData() %>% select_if(is.numeric))), y = colnames(cor(finalInputData() %>% select_if(is.numeric))), z = cor(finalInputData() %>% select_if(is.numeric)), type = "heatmap") %>% 
                      layout(xaxis = list(categoryorder = "trace"),yaxis = list(categoryorder = "trace")))
  })
# **************************Outputs for tests**************************

output$testResult2 <- renderText({
  req(input$PrintTest2, dataInput100())
  
  # Perform the selected test based on user input
  result_test2 <- NULL
  
  if (input$PrintTest2 == "Pearson_correlation_test") {
    result_test2 <- cor.test(dataInput100()$XVar, dataInput100()$YVar, method = "pearson")

  } else if (input$PrintTest2 == "Spearman_correlation_test") {
    result_test2 <- cor.test(dataInput100()$XVar, dataInput100()$YVar, method = "spearman")
    
  } 
  
  print(result_test2)
  # Format the result for display with HTML tags
  if (!is.null(result_test2)) {
    result_text2 <- paste("Test : <strong>", input$PrintTest2, "</strong><br>",
                         "Coéfficient de Correlation: <strong>", round(result_test2$estimate, 4), "</strong><br>",
                         "p-value: <strong>", formatC(result_test2$p.value, digits = 3), "</strong><br>",
                         "Test Statistique: <strong>", round(result_test2$statistic, 4), "</strong><br>")
    
    # Use HTML function to interpret HTML tags
    HTML(result_text2)
  } else {
    "No result available."
  }
  
})





