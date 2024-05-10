
library(ggplot2)
library(tseries)
library(moments)

# **************************Select Inputs for variables**************************

output$choisirCol = renderUI({
  selectInput("Collonne", "Sélectionner une Mesure", 
              choices = unique(selectdata()$FeatureValue[which(selectdata()$FeatureName == "Variable quantitative")]))
})

# **************************Reactive Variable for variable**************************

dataInput99 = reactive({
  req(input$Collonne)
  inputdata99 <- finalInputData() %>% select(input$Collonne)
  colnames(inputdata99) <- c("XVar")
  inputdata99
})

# **************************Outputs for plot**************************


output$qqPlot <- renderPlot({
  req(dataInput99())
  qqnorm(dataInput99()$XVar, main = "QQ-Plot")
  qqline(dataInput99()$XVar)
})

output$densityPlot <- renderPlot({
  req(dataInput99())
  # Density plot with a normal distribution overlay
  ggplot(data.frame(XVar = dataInput99()$XVar), aes(x = XVar)) +
    geom_density(aes(y = ..scaled..), fill = "blue", alpha = 0.5) +
    stat_function(fun = dnorm, args = list(mean = mean(dataInput99()$XVar, na.rm = TRUE),
                                           sd = sd(dataInput99()$XVar, na.rm = TRUE)),
                  colour = "red", linetype = "dashed") +
    labs(title = "Density Plot with Normal Curve Overlay", x = input$Collonne, y = "Density")
})


# **************************Outputs for tests**************************

output$testResult <- renderText({
  req(input$PrintTest, dataInput99())
  
  # Perform the selected test based on user input
  result <- NULL
  dof <- NULL  # Initialize degrees of freedom variable
  
  if (input$PrintTest == "Kolmogorov-Smirnov") {
    result <- ks.test(dataInput99()$XVar, "pnorm", mean = mean(dataInput99()$XVar), sd = sd(dataInput99()$XVar))
    dof <- length(dataInput99()$XVar)  # Degrees of freedom for Kolmogorov-Smirnov
  } else if (input$PrintTest == "Shapiro-Wilk") {
    result <- shapiro.test(dataInput99()$XVar)
    dof <- result$parameter  # Degrees of freedom from the test result
  } else if (input$PrintTest == "Jarque-Bera") {
    result <- jarque.test(dataInput99()$XVar)
    dof <- result$parameter  # Degrees of freedom from the test result
  }
  
  # Format the result for display with HTML tags
  if (!is.null(result)) {
    result_text <- paste("Test : <strong>", input$PrintTest, "</strong><br>",
                         "p-value: <strong>", result$p.value, "</strong><br>",
                         "Test Statistic: <strong>", result$statistic, "</strong><br>")
                         
    
    # Use HTML function to interpret HTML tags
    HTML(result_text)
  } else {
    "No result available."
  }
})
