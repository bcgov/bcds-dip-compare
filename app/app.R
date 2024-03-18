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
library(plotly)
library(shinyWidgets)
library(shinydashboard)

# Define UI ----
ui <- fluidPage(

  theme = "styles.css",
  HTML("<html lang='en'>"),
  
  ## note that doing the infoboxes this way is deprecated but I don't know a better way
  useShinydashboard(),
  fluidRow(
    
    ## Replace appname with the title that will appear in the header
    bcsapps::bcsHeaderUI(
      id = 'header', 
      appname = "BC Demographic Survey: DIP Linkage Rates", 
      github = NULL # replace with github URL or NULL
      ),
    
    tags$head(tags$link(rel = "shortcut icon", href = "favicon.png")), ## to add BCGov favicon
    
    column(
      width = 12,
      style = "margin-top:100px",
           
      # Create tabs
      tabsetPanel(
         
        # overall linkage rates ----
        tabPanel(
         "Overall Linkage Rates",
         mainPanel(
           DTOutput("data_overview") ## data_overview ----
         )
        )
      ,
         
       # linked summary ----
       tabPanel(
         "Linked Variables - Summary",
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
                  collapsed = FALSE, 
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
              
              tabsetPanel(
                tabPanel(
                  'Highlights',
                  uiOutput('summary_info'), ## summary highlights ----                
                ),
                
                tabPanel(
                  'Table',
                  DTOutput("data_summary") ## data_summary ----
                )
              )
            )
          )
         ),
      
       # linked individual demos ----
       tabPanel(
         "Linked Individual Demos",
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
             
             tabsetPanel(
               
               ## table ----
               tabPanel(
                 "Table",
                 DTOutput("data_detailed") ### data_detailed ----
               ),
               
               ## heatmap ----
               tabPanel(
                 "Heatmap",
                  radioButtons(
                    "detail_plot_option", "Plot heatmap based on:",
                    c(
                      'Percent of BC Demographic Survey' = 'bcds', 
                      'Percent of DIP Dataset' = 'dip'
                      ),
                    inline=TRUE
                    ),
                 plotlyOutput("heatmap_detailed", height="800px") ### heatmap_detailed ----
                )
             )
           )
         )
       )
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
          "Dataset" = dataset, 
          "File Name" = file_name, 
          "DIP Dataset Records" = in_dip_dataset_str, 
          "DIP Dataset Records Linked" = in_both_str, 
          "Percent of Survey Covered" = pct_demo_in_dip_str, 
          "Percent of DIP Dataset Covered" = pct_dip_in_demo_str
          ), 
      options = list(pageLength = 10))
  })
  
  # data_summary ----
  # Filter data based on user inputs
  filtered_data_summary <- reactive({
    combined_summary %>%
      filter(var %in% input$var_summary, file_name == input$file_summary) %>% 
      select(
        "Demographic Variable" = var, 
        "Cross-Status" = cross_status, 
        "Unique IDs in DIP Dataset" = unique_n_str, 
        "Percent of Unique IDs" = unique_percent_str
        )
  })
  
  ## render table ----
  output$data_summary <- renderDT({
    datatable(filtered_data_summary(), options = list(pageLength = 25))
    
  })
  
  ## summary info boxes ----
  summary_info <- reactive({
    
    var_list <- input$var_summary
    
    temp <- combined_summary %>% 
      filter(file_name == input$file_summary)
    
    info <- lapply(
      var_list, function(var_name){
        
        # check if it exists in DIP
        in_dip <- combined_list_vars %>% 
          filter(file_name == input$file_summary, var==var_name) %>% 
          pull(exists_in_dip)
        
        # get info about the variable 
        t1 <- temp %>% 
          filter(var==var_name)
        
        extra_coverage <- t1 %>% 
          filter(cross_status == 'Present in survey only') %>% 
          pull(unique_percent_str)
        
        already_covered <- t1 %>% 
          filter(cross_status == 'Present in DIP dataset only') %>% 
          pull(unique_percent_str)
        
        survey_coverage <- t1 %>% 
          filter(cross_status == 'Present in survey only') %>% 
          pull(unique_percent_survey_str)
        
        # create info box material 
        if (in_dip) {
          icon <-  'check'
          color <- 'green'
          info <- paste0(
            already_covered, 
            ' Already Covered in DIP', 
            '<br>',
            extra_coverage,
            ' Extra Coverage from Survey',
            '<br>',
            survey_coverage,
            ' Coverage of Survey'
          )
        } else {
          icon <-  'x'
          color <- 'red'
          info <- paste0(
            extra_coverage,
            ' Coverage from Survey',
            '<br>',
            survey_coverage,
            ' Coverage of Survey'
          )
        }
        
        # return the info box
        infoBox(
          title = var_name, #HTML(paste0(var_name,'<br>')),
          value = HTML(paste0("<p style='font-size:22px'>", info, "</p>")),
          icon = icon(icon),
          color = color,
          width = 6
        )
        
      })
    
    info
  })
  
  ### render info boxes ----
  output$summary_info <- renderUI({
    summary_info()
  })
  
  # data_detailed ----
  # Filter data based on user inputs
  filtered_data_detailed <- reactive({
    combined_detailed %>%
      filter(var %in% input$var_detailed, file_name == input$file_detailed) %>% 
      select(
        "Value in DIP" = dip_value,
        "Value in Survey" = bcds_value,
        "Unique IDs in DIP Dataset" = unique_n_str,
        "Percent of Unique IDs" = unique_percent_str,
        "Percent of Survey Unique IDs" = unique_percent_survey_str
      )
  })

  ## render table ----
  output$data_detailed <- renderDT({
    datatable(filtered_data_detailed(), options = list(pageLength = 25))

  })
  
  ## render heatmap ----
  output$heatmap_detailed <- renderPlotly({
    
    # choose which column to use for the heat map
    col_to_use <- if (input$detail_plot_option == 'bcds'){
      col_to_use = 'unique_percent_survey'
    } else {
      col_to_use = 'unique_percent'
    }
    temp <- combined_detailed %>% 
      filter(file_name == input$file_detailed) %>% 
      filter(var == input$var_detailed) %>% 
      mutate(text = paste0(
        "BC Demographic Survey Value: ", bcds_value, "\n",
        "DIP Dataset Value: ", dip_value, "\n",
        "Number of Records: ", unique_n_str, "\n",
        "Percent of BC Demographic Survey: ", unique_percent_survey_str, "\n",
        "Percent of DIP Dataset: ", unique_percent_str
      )) %>% 
      mutate(percent = get(col_to_use)) %>% 
      select(dip_value, bcds_value, percent, text) %>% 
      arrange(desc(percent)) %>% 
      mutate(
        dip_value = factor(dip_value, levels=unique(.$dip_value), exclude=NULL),
        bcds_value = factor(bcds_value, levels=unique(.$bcds_value), exclude=NULL)
      ) 
    
    t1 <- temp %>% 
      select(-text) %>% 
      pivot_wider(names_from = bcds_value, values_from = percent)
    
    t2 <- temp %>% 
      select(-percent) %>% 
      pivot_wider(names_from = bcds_value, values_from = text) %>% 
      select(-dip_value) %>% 
      as.matrix()
    
    row_names = t1$dip_value
    t1 <- as.matrix(t1 %>% select(-dip_value))
    rownames(t1) = row_names
    
    fig <- plot_ly(
      x = colnames(t1),
      y = rownames(t1),
      z = t1, 
      text = t2,
      type = 'heatmap',
      hoverinfo = 'text'
    ) %>% 
      layout(
        title = list(
          text = "Distribution of Demographic Values Across DIP and BC Demographic Survey",
          automargin = TRUE,
          yanchor = 'top',
          y = 0.98
        ),
        xaxis = list(
          title = "BC Demographic Survey",
          side="top",
          automargin = TRUE,
          pad = list(t = 10)
        ),
        yaxis = list(
          title = "DIP Dataset", autorange = "reversed"
        ),
        margin = list(
          l = 50,
          r = 50,
          b = 10,
          t = 150,
          pad = 0
        )
      )
    
    fig
    
  })


}

# Run the application
shinyApp(ui = ui, server = server)
