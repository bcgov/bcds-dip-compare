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
library(bcsapps)

# Define UI ----
ui <- fluidPage(

  theme = "styles.css",
  HTML("<html lang='en'>"),
  fluidRow(
    
    
    ## Replace appname with the title that will appear in the header
    bcsapps::bcsHeaderUI(
      id = 'header', 
      appname = "BC Demographic Survey: DIP Linkage Rates", 
      github = NULL # replace with github URL or NULL
      ),
    
    tags$head(tags$link(rel = "shortcut icon", href = "favicon.png")), ## to add BCGov favicon
    
    column(width = 12,
           style = "margin-top:100px",
           
           # Create tabs
           tabsetPanel(
             
             # overall linkage rates ----
             tabPanel(
               "Overall Linkage Rates",
               mainPanel(
                 DTOutput("data_overview") ## data_overview ----
               )
             ),
             
             # linked summary ----
             tabPanel("Linked Variables - Summary",
                      sidebarLayout(
                        sidebarPanel(
                          # Filter for the 'var' variable
                          selectInput(
                            "var_summary", 
                            "Choose Variable:", 
                            choices = unique(combined_summary$var), 
                            selected = unique(combined_summary$var),
                            multiple=TRUE
                          ),
                          # Filter for the 'file_name' variable
                          selectInput(
                            "file_summary", 
                            "Choose File:", 
                            choices = unique(combined_summary$file_name)
                          ),
                          fluidRow(
                            box(
                              width = NULL,
                              solidHeader = TRUE,
                              collapsible = TRUE, # not sure why not working 
                              collapsed = TRUE, 
                              title = HTML("<small><p><b>Cross-Status Definitions:</b></small>"),
                              HTML(
                                "<small>
                                <p><b>Present in survey only:</b> 
                                <p>These records contain no demographic information for the given variable within the DIP Dataset, but are supplemented by the BC Demographic Survey.
                                <p><b>Present in DIP dataset only:</b>
                                <p>These records contain demographic information for the given variable within the DIP Dataset, and have no supplemental information from the BC Demographic Survey.
                                <p><b>Present in survey AND DIP:</b>
                                <p>These records contain demographic information for the given variable within the DIP Dataset, and have supplemental information from the BC Demographic Survey. This information may or may not align.
                                <p><b>Not present in survey OR DIP:</b>
                                <p>These records contain no demographic information for the given variable within the DIP Dataset, and have no supplemental information from the BC Demographic Survey.
                                <p>
                                </small>"
                                   )
                              )
                          )
                        ),
                        mainPanel(
                          DTOutput("data_summary") ## data_summary ----
                        )
                      )),
             
            
             # linked individual demos ----
             tabPanel("Linked Individual Demos",
                      sidebarLayout(
                        sidebarPanel(
                          # Filter for the 'var' variable
                          selectInput(
                            "var_detailed", 
                            "Choose Variable:", 
                            choices = unique(combined_detailed$var)
                          ),
                          # Filter for the 'file_name' variable
                          selectInput(
                            "file_detailed", 
                            "Choose File:", 
                            choices = unique(combined_detailed$file_name)
                          )
                        ),
                        mainPanel(
                          DTOutput("data_detailed") ## data_detailed ----
                        )
                      )),
           )
    ),
    
    bcsapps::bcsFooterUI(id = 'footer')
  )
  )



#server logic ----
server <- function(input, output) {
  
  # formatting ----
  ## Change links to false to remove the link list from the header
  bcsapps::bcsHeaderServer(id = 'header', links = TRUE)
  bcsapps::bcsFooterServer(id = 'footer')

  # data_overview ----
  ## render table ----
  output$data_overview <- renderDT({
    datatable(
      combined_overview %>% 
        select(
          dataset, 
          file_name, 
          in_dip_dataset_str, 
          in_both_str, 
          pct_demo_in_dip_str, 
          pct_dip_in_demo_str
          ), 
      options = list(pageLength = 10))
  })
  
  # data_summary ----
  # Filter data based on user inputs
  filtered_data_summary <- reactive({
    combined_summary %>%
      filter(var %in% input$var_summary, file_name == input$file_summary) %>% 
      select(var, cross_status, unique_n_str, unique_percent_str)
  })
  
  ## render table ----
  output$data_summary <- renderDT({
    datatable(filtered_data_summary(), options = list(pageLength = 10))
    
  })
  
  # data_detailed ----
  # Filter data based on user inputs
  filtered_data_detailed <- reactive({
    combined_detailed %>%
      filter(var %in% input$var_detailed, file_name == input$file_detailed)
  })

  ## render table ----
  output$data_detailed <- renderDT({
    datatable(filtered_data_detailed(), options = list(pageLength = 10))

  })


}

# Run the application
shinyApp(ui = ui, server = server)
