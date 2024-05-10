# ************************************Bi Variate Scatter Plot************************************
library(webshot2)
# **************************Select Inputs**************************
output$Measure1 = renderUI({
  selectInput("Measure1", "Sélectionner Measure1", 
              c(selectdata()$FeatureValue[which(selectdata()$FeatureName == "Variable quantitative")]), "Variable quantitative")
})

output$Measure2 = renderUI({
  selectInput("Measure2", "Sélectionner Measure2", 
              c(selectdata()$FeatureValue[which(selectdata()$FeatureName == "Variable quantitative")]), "Variable quantitative")
})
# **************************Reactive Variable**************************
dataInput2 = reactive({
  if (is.null(input$Measure1) & is.null(input$Measure2)) {
    return(NULL)
  } else if (input$Measure1 != input$Measure2) {
    inputdata2 = finalInputData() %>% select(one_of(c(input$Measure1,input$Measure2)))
    colnames(inputdata2) = c("XVar", "YVar")
    return(inputdata2)
  } else if(input$Measure1 == input$Measure2) {
    inputdata2 = finalInputData() %>% select(one_of(c(input$Measure1,input$Measure2)))
    colnames(inputdata2) = c("XVar")
    inputdata2$YVar = inputdata2$XVar
    return(inputdata2)
  }
})
# **************************Outputs**************************
output$ScatterPlot = renderPlotly({
  if(is.null(dataInput2())) {
    return()
  } else {
    plotly::subplot(
      
      plot_ly(data = dataInput2(), x = ~ XVar, y = ~ YVar, type = "scatter", mode = "markers", marker = list(size = 5)) %>% 
        layout(title = paste0("Scatter Plot: ", input$Measure1," vs ", input$Measure2),
               xaxis = list(title = paste0(input$Measure1)),
               yaxis = list(title = paste0(input$Measure2))),
      nrows = 1, margin = 0.05, titleY = TRUE, titleX = TRUE
    )
  }
})


output$downloadScatterPDF <- downloadHandler(
  filename = function() {
    "scatter_plot.pdf"
  },
  content = function(file) {
    # Create scatter plot using ggplot2
    scatter_plot <- ggplot(dataInput2(), aes(x = XVar, y = YVar)) +
      geom_point(size = 5) +
      labs(title = paste0("Scatter Plot: ", input$Measure1, " vs ", input$Measure2),
           x = input$Measure1,
           y = input$Measure2)
    
    # Save the plot into the PDF file
    ggsave(file, plot = scatter_plot, device = "pdf", width = 11, height = 8.5)
  }
)

