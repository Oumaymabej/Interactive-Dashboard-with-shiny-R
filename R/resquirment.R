# List of packages to install
packages <- c("shiny", "shinyjs", "shinydashboard", "plotly", "DT", 
              "xlsx", "evaluate", "shinycssloaders", "dplyr", "tools", "stringr")

# Check if each package is already installed
new_packages <- packages[!packages %in% installed.packages()]

# If any packages need to be installed, install them
if (length(new_packages) > 0) {
  install.packages(new_packages)
} else {
  # If all packages are already installed, update them
  update.packages(ask = FALSE)
}
install.packages("htmltools", dependencies = TRUE)
install.packages("highcharter")

