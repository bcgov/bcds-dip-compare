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
library(scales)

# Define UI ----
ui <- fluidPage(

  # Application title
  titlePanel("BC Demo Survey - DIP Comparison"),

  # Create tabs
  tabsetPanel(
    # First tab for the filters and table
    tabPanel("Linked Overview",
             sidebarLayout(
               sidebarPanel(
                 # Filter for the 'var' variable
                 selectInput("var2", "Choose Variable:", choices = unique(combined_summary$var)),
                 # Filter for the 'file_name' variable
                 selectInput("file2", "Choose File:", choices = unique(combined_summary$file_name))
               ),
               mainPanel(
                 DTOutput("datatable2") #linked overview: datatable2 ----
               )
             )),

    # Second tab for content

    tabPanel("Linked Individual Demos",
             sidebarLayout(
               sidebarPanel(
                 # Filter for the 'var' variable
                 selectInput("var", "Choose Variable:", choices = unique(combined_run$var)),
                 # Filter for the 'file_name' variable
                 selectInput("file", "Choose File:", choices = unique(combined_run$file_name))
               ),
               mainPanel(
                 DTOutput("datatable") #linked individual demos: datatable ----
               )
             )),
        )
  )



#server logic ----
server <- function(input, output) {

  # Filter data based on user inputs
  filtered_data <- reactive({
    combined_detailed %>%
      filter(var == input$var, file_name == input$file)
  })

  # Render table datatable ----
  output$datatable <- renderDT({
    datatable(filtered_data(), options = list(pageLength = 10))

  })
  
  # Filter data based on user inputs
  filtered_data2 <- reactive({
      combined_summary %>%
        filter(var == input$var2, file_name == input$file2)
    })
  
  # Render table datatable2 ----
  output$datatable2 <- renderDT({
    datatable(filtered_data2(), options = list(pageLength = 10))

  })

}

# Run the application
shinyApp(ui = ui, server = server)
