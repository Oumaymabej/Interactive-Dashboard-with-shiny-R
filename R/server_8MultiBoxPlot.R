# ************************************Multi Variate Box Plot************************************
# **************************Select Inputs**************************
output$MultiBoxMeasure = renderUI({
  selectInput("MultiBoxMeasure", "Sélectionner Measure",
              c(selectdata()$FeatureValue[which(selectdata()$FeatureName == "Variable quantitative")]), "Variable quantitative")
})

output$MultiBoxDimension1 = renderUI({
  selectInput("MultiBoxDimension1", "Sélectionner Dimension1",
              c(selectdata()$FeatureValue[which(selectdata()$FeatureName == "Variable qualitative")]), "Variable qualitative")
})

output$MultiBoxDimension2 = renderUI({
  selectInput("MultiBoxDimension2", "Sélectionner Dimension2", 
              c(selectdata()$FeatureValue[which(selectdata()$FeatureName == "Variable qualitative")]), "Variable qualitative")
})

# **************************Reactive Variable**************************
dataInput7 = reactive({
  if (is.null(input$MultiBoxMeasure) & is.null(input$MultiBoxDimension1) & is.null(input$MultiBoxDimension2)) {
    return(NULL)
  } else if (input$MultiBoxDimension1 != input$MultiBoxDimension2) {
    inputdata7 = finalInputData() %>% select(one_of(c(input$MultiBoxDimension1, input$MultiBoxMeasure, input$MultiBoxDimension2)))
    colnames(inputdata7) = c("XVar", "YVar", "CVar")
    return(inputdata7)
  } 
  else if (input$MultiBoxDimension1 == input$MultiBoxDimension2) {
    inputdata7 = finalInputData() %>% select(one_of(c(input$MultiBoxDimension1, input$MultiBoxMeasure, input$MultiBoxDimension2)))
    colnames(inputdata7) = c("XVar", "YVar")
    inputdata7$CVar = inputdata7$XVar
    return(inputdata7)
  }
})

# **************************Outputs**************************
output$MultiBoxPlot = renderPlotly(
  if(is.null(dataInput7())) {
    return()
  } else {
    dataInput7() %>% plot_ly(alpha = 1) %>% 
      add_boxplot(x = ~ XVar, y = ~ YVar, color = ~ CVar) %>% 
      layout(title = paste0("Distribution de ", input$MultiBoxMeasure, " à travers ", input$MultiBoxDimension1,
                            " et ", input$MultiBoxDimension2), xaxis = list(title = input$MultiBoxDimension1), 
             yaxis = list(title = input$MultiBoxMeasure), legend = FALSE, boxmode = "group")
  })

output$downloadMultiBoxPlotPDF <- downloadHandler(
  filename = function() {
    "multi_box_plot.pdf"
  },
  content = function(file) {
    # Prepare data for plotting
    plot_data <- dataInput7()
    
    # Create multi-grouped box plot using ggplot2
    multi_box_plot <- ggplot(plot_data, aes(x = XVar, y = YVar, fill = CVar)) +
      geom_boxplot() +
      labs(title = paste0("Distribution de ", input$MultiBoxMeasure, " à travers ", input$MultiBoxDimension1,
                          " et ", input$MultiBoxDimension2),
           x = input$MultiBoxDimension1,
           y = input$MultiBoxMeasure) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      scale_fill_manual(values = c("blue", "red"))  # Adjust fill colors as needed
    
    # Save the plot into the PDF file
    ggsave(file, plot = multi_box_plot, device = "pdf", width = 11, height = 8.5)
  }
)




