# Copyright 2024 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Load necessary libraries
library(shiny)
library(DT)
library(dplyr)

# Define UI
ui <- fluidPage(

  # Application title
  titlePanel("Simple Dashboard"),

  # Create tabs
  tabsetPanel(
    # First tab for the filters and table
    tabPanel("Data Table",
             sidebarLayout(
               sidebarPanel(
                 # Filter for the 'var' variable
                 selectInput("var", "Choose Variable:", choices = unique(combined_run$var)),
                 # Filter for the 'file_name' variable
                 selectInput("file", "Choose File:", choices = unique(combined_run$file_name))
               ),
               mainPanel(
                 DTOutput("datatable")
               )
             )),

    # Second tab for content
    tabPanel("Second Tab",
             # Add content for the second tab here
             p("This is the content for the second tab.")
    )
  )
)

# Define server logic
server <- function(input, output) {

  # Filter data based on user inputs
  filtered_data <- reactive({
    combined_run %>%
      filter(var == input$var, file_name == input$file)
  })








  combined_run$unique_percent <- sprintf("%.2f%%", combined_run$unique_percent)
  combined_run$unique_percent_survey <- sprintf("%.2f%%", combined_run$unique_percent_survey)
  combined_run$unique_n <- format(combined_run$unique_n, big.mark = ",")

  # Render table
  output$datatable <- renderDT({
    datatable(filtered_data(), options = list(pageLength = 10))

  })
}

# Run the application
shinyApp(ui = ui, server = server)
