# ************************************Bi Variate Box Plot************************************
# **************************Select Inputs**************************
output$BoxMeasure = renderUI({
  selectInput("BoxMeasure", "Sélectionner Mesure", 
              c(selectdata()$FeatureValue[which(selectdata()$FeatureName == "Variable quantitative")]), "Variable quantitative")
})

output$BoxDimension = renderUI({
  selectInput("BoxDimension", "Sélectionner Dimension", 
              c(selectdata()$FeatureValue[which(selectdata()$FeatureName == "Variable qualitative")]), "Variable qualitative")
})

# **************************Reactive Variable**************************
dataInput3 = reactive({
  if(is.null(input$BoxMeasure) & is.null(input$BoxDimension)) {
    return(NULL)
  } else {
    inputdata3 = finalInputData() %>% select(one_of(c(input$BoxDimension, input$BoxMeasure)))
    colnames(inputdata3) = c("XVar", "YVar")
    return(inputdata3)
  }
})

# **************************Outputs**************************
output$BoxPlot = renderPlotly(
  if(is.null(dataInput3())) {
    return()
  } else {
    dataInput3() %>% plot_ly(alpha = 1) %>% 
      add_boxplot(x = ~ XVar, y = ~ YVar, color = ~ XVar) %>% 
      layout(title = paste0("Distribution de ", input$BoxMeasure, " à travers ", input$BoxDimension), 
             xaxis = list(title = input$BoxDimension), yaxis = list(title = input$BoxMeasure), legend = FALSE)
    
  })



output$downloadBoxPlotPDF <- downloadHandler(
  filename = function() {
    "box_plot.pdf"
  },
  content = function(file) {
    # Create box plot using ggplot2
    box_plot <- ggplot(dataInput3(), aes(x = factor(XVar), y = YVar, fill = factor(XVar))) +
      geom_boxplot() +
      labs(title = paste0("Distribution de ", input$BoxMeasure, " à travers ", input$BoxDimension), 
           x = input$BoxDimension, y = input$BoxMeasure) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    # Save the plot into the PDF file
    ggsave(file, plot = box_plot, device = "pdf", width = 11, height = 8.5)
  }
)
