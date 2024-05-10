# ************************************Bi Variate Group Histogram************************************
# **************************Select Inputs**************************
output$GHistMeasure = renderUI({
  selectInput("GHistMeasure", "Sélectionner Mesure", 
              c(selectdata()$FeatureValue[which(selectdata()$FeatureName == "Variable quantitative")]), "Variable quantitative")
})

output$GHistDimension = renderUI({
  selectInput("GHistDimension", "Sélectionner Dimension", 
              c(selectdata()$FeatureValue[which(selectdata()$FeatureName == "Variable qualitative")]), "Variable qualitative")
})

# **************************Reactive Variable**************************
dataInput5 = reactive({
  if(is.null(input$GHistDimension) & is.null(input$GHistMeasure)) {
    return(NULL)
  } else {
    inputdata5 = finalInputData() %>% select(one_of(c(input$GHistMeasure, input$GHistDimension)))
    colnames(inputdata5) = c("XVar", "YVar") 
    return(inputdata5)
  }
})

# **************************Outputs**************************
output$GHistPlot = renderPlotly({
  if(is.null(dataInput5())) {
    return()
  } else {
    dataInput5() %>% 
      count(XVar, YVar) %>%
      group_by(XVar) %>%
      mutate(percentage = n/sum(n) * 100) %>%  # Calculate percentages
      arrange(desc(percentage)) %>%  # Sort by percentage in descending order
      plot_ly(x = ~ reorder(XVar, percentage), y = ~ percentage, color = ~ YVar, type = "bar") %>%
      layout(title = paste0("Distribution de ", input$GHistMeasure, " à travers ", input$GHistDimension),
             xaxis = list(title = input$GHistMeasure, categoryorder = "array", categoryarray = ~ XVar), 
             yaxis = list(title = "Pourcentage (%)"), legend = TRUE)
  }
})



