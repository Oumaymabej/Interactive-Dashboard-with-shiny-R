# ************************************Univariate Analysis************************************
# **************************Select Inputs**************************
output$FeatureSelect = renderUI({
  selectInput("Features", "Sélectionner le type de variable", c(unique(selectdata()$FeatureName)), "Variable quantitative")
})

output$FeatureValueSelect = renderUI(
  if (is.null(input$Features)){
    return(NULL)
  }
  else if (input$Features == "Variable quantitative") {
    selectInput("Measures", "Sélectionner une variable", 
                c(selectdata()$FeatureValue[which(selectdata()$FeatureName == input$Features)]), rmeasures()[1])
  } else if (input$Features == "Variable qualitative") {
    selectInput("Dimensions", "Sélectionner une variable", 
                c(selectdata()$FeatureValue[which(selectdata()$FeatureName == input$Features)]), rdimensions()[1])
  })

# **************************Reactive Variable**************************
dataInput = reactive({
  if (is.null(input$Measures) & is.null(input$Dimensions)) {
    return(NULL)
  } else if (input$Features == "Variable quantitative") {
    inputdata = finalInputData() %>% select(one_of(input$Measures))
    colnames(inputdata) = c("XVar")
    return(inputdata)
  } else if (input$Features == "Variable qualitative") {
    inputdata = finalInputData() %>% select(one_of(input$Dimensions))
    colnames(inputdata) = c("XVar")
    return(inputdata)
  }
})

# **************************Outputs**************************


output$Univariate = renderPlotly(
  if (is.null(dataInput())) {
    return()
  } else if (input$Features == "Variable quantitative") {
plotly::subplot(
  # Histogram sorted from highest to lowest distribution
  dataInput() %>% plot_ly(alpha = 1) %>% 
    add_histogram(x = ~ XVar, histnorm = "frequency") %>%
    layout(bargap = 0.1, xaxis = list(title = paste0(input$Measures)), yaxis = list(title = "Mesure")),
  # Box Plot
  dataInput() %>% plot_ly(alpha = 1) %>% add_boxplot(y = ~ XVar, x = "") %>%
    layout(yaxis = list(title = paste0(input$Measures))),
  nrows = 1, titleY = TRUE, margin = 0.05) %>% 
  layout(title = paste0("Distribution de ", input$Measures), showlegend = FALSE)
    

  } else if (input$Features == "Variable qualitative") {
    # Bar Plots
    dataInput() %>%
      count(XVar) %>%
      mutate(XVar = reorder(XVar, -n)) %>%
      plot_ly(x = ~XVar, y = ~n, type = "bar") %>%
      layout(bargap = 0.1, title = paste0("Distribution de ", input$Dimensions),
             xaxis = list(title = paste0(input$Dimensions)), yaxis = list(title = "Mesure"))
  }
)


output$downloadPDF2 <- downloadHandler(
  filename = function() {
    "plot.pdf"
  },
  content = function(file) {
    # Create a PDF file
    pdf(file, width = 11, height = 8.5)
    
    # Plot based on the selected feature
    if (input$Features == "Variable quantitative") {
      # Create a histogram
      hist(dataInput()$XVar, main = paste0("Distribution de ", input$Measures), xlab = input$Measures)
    } else if (input$Features == "Variable qualitative") {
      # Create a bar plot
      barplot(table(dataInput()$XVar), main = paste0("Distribution de ", input$Dimensions), xlab = input$Dimensions)
    }
    # Close the PDF device
    dev.off()
  }
)