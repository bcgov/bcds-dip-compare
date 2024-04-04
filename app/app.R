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
  
  ## deprecated so copied appropriate code into functions.R
  useShinydashboard(),
  ## allow scrolling on x-axis in browser
  tags$body(style = "overflow-x:scroll"),
  
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
              
              # filter for the data group variable
              pickerInput(
                inputId = "data_group_summary",
                label = "Choose Data Provider:",
                choices = unique(combined_summary$data_group),
                selected = unique(combined_summary$data_group),
                options = pickerOptions(
                  actionsBox = TRUE, 
                  liveSearch = TRUE,
                  selectedTextFormat = "count > 3",
                  size = 10
                ),
                multiple = TRUE
              ),
              
              # Filter for the 'file_name' variable
              selectInput(
                "file_summary", 
                "Choose File:", 
                choices = NULL #unique(combined_summary$file_name)
              ),
              
              # Filter for the 'var' variable
              # depends on choice of file_name
              pickerInput(
                inputId = "var_summary", 
                label = "Choose Variable(s):", 
                choices = NULL,
                selected = NULL,
                options = pickerOptions(
                  actionsBox = TRUE, 
                  liveSearch = TRUE,
                  selectedTextFormat = "count > 3",
                  size = 10
                ), 
                multiple = TRUE
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
              ),
              # Information added about the dob variable name only when selected/exists (dobflag created in server)
              conditionalPanel(condition = 'output.dobflag == true',
                               HTML("<small>* Note: dip_dob_status is a replacement for the actual date of birth variable.
                                    See metadata for the relevant dataset to determine the variable name.</small>"))
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
             
             # filter for the data group variable
             pickerInput(
               "data_group_detailed",
               "Choose Data Provider:",
               choices = unique(combined_detailed$data_group),
               selected = unique(combined_detailed$data_group),
               options = pickerOptions(
                 actionsBox = TRUE, 
                 liveSearch = TRUE,
                 selectedTextFormat = "count > 3",
                 size = 10
               ),
               multiple = TRUE
             ),
             
             # Filter for the 'file_name' variable
             selectInput(
               "file_detailed", 
               "Choose File:", 
               choices = NULL #unique(combined_detailed$file_name)
             ),
             
             # Filter for the 'var' variable
             # depends on choice of file_name 
             selectInput(
               "var_detailed", 
               "Choose Variable:", 
               choices = NULL #unique(combined_detailed$var)
             ),
             
             # Description of DIP variable name for selected input
             fluidRow(
               box(
                 width = NULL,
                 solidHeader = TRUE,
                 title = HTML("<small><p><b>Actual DIP Variable Name:</b></small>"),
                 span(textOutput("dipVarName"),style="font-size:12px"))
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
       ),
      # about ----
      tabPanel(
        "About",
        value="about",
        mainPanel(
          fluidRow(class = "bg-row",
                   h1(style="padding-left:15px;margin-bottom:25px",
                      "About the Dashboard"),
                   div(style = "margin-left:20px;margin-right:20px",
                       includeMarkdown("R/methodology.Rmd"),
                       br(),
                       br()))
        )
      )
      ,
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
      options = list(pageLength = 100),
      rownames=FALSE,
      filter = list(position="top"))
  })
  
  # data_summary ----
  # Filter data based on user inputs
  
  filtered_by_data_group_summary <- reactive({
    combined_summary %>% 
      filter(data_group %in% input$data_group_summary)
  })
  
  # choose variables based on data group filters 
  observeEvent(filtered_by_data_group_summary(), {
    choices <- sort(unique(filtered_by_data_group_summary()$file_name))
    updateSelectInput(inputId = 'file_summary', choices=choices)
  })
  
  filtered_by_file_summary <- reactive({
    req(input$file_summary)
    filtered_by_data_group_summary() %>% 
      filter(file_name == input$file_summary)
  }) 
  
  # choose variables based on the file filters
  observeEvent(filtered_by_file_summary(),{
    choices <- unique(filtered_by_file_summary()$var)
    updatePickerInput(inputId = 'var_summary', choices = choices, selected = choices)
  })
  
  # create final filtered table
  filtered_data_summary <- reactive({
    req(input$var_summary)
    filter(filtered_by_file_summary(), var %in% input$var_summary) %>% 
      select(
        "Demographic Variable" = var, 
        "DIP Variable Name" = var_dip,
        "Cross-Status" = cross_status, 
        "Unique IDs in DIP Dataset" = unique_n_str, 
        "Percent of Unique IDs" = unique_percent_str
      )
  })
  
  ## render table ----
  output$data_summary <- renderDT({
    datatable(filtered_data_summary(), rownames=FALSE, options = list(pageLength = 25))
    
  })
  
  # create dob status flag
  output$dobflag <- reactive("dip_dob_status" %in% filtered_data_summary()$"DIP Variable Name")
  outputOptions(output, "dobflag", suspendWhenHidden = FALSE)
  
  ## summary info boxes ----
  summary_info <- reactive({
    
    req(input$var_summary)
    var_list <- input$var_summary
    
    temp <- combined_summary %>% 
      filter(file_name == input$file_summary)
    
    info <- lapply(
      var_list, function(var_name){
        
        # check if it exists in DIP
        in_dip <- combined_list_vars %>% 
          filter(file_name == input$file_summary, var_main==var_name) %>% 
          pull(exists_in_dip)
        
        # get info about the variable 
        t1 <- temp %>% 
          filter(var==var_name)
        
        # get dip var name
        dip_var_name <- unique(t1 %>% pull(var_dip))
        
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
            ' DIP Variable Name: ','<strong>',dip_var_name, '</strong>',
            '<br>',
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
            'No DIP Variable',
            '<br>',
            extra_coverage,
            ' Coverage from Survey',
            '<br>',
            survey_coverage,
            ' Coverage of Survey'
          )
        }
        
        # return the info box
        infoBox(
          title = HTML(paste0("<strong>", var_name, "</strong>")),
          value = HTML(paste0("<p style='font-size:14px; font-weight: normal;'>", info, "</p>")),
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
  
  filtered_by_data_group_detailed <- reactive({
    combined_detailed %>% 
      filter(data_group %in% input$data_group_detailed)
  })
  
  # choose variables based on data group filters 
  observeEvent(filtered_by_data_group_detailed(), {
    choices <- sort(unique(filtered_by_data_group_detailed()$file_name))
    updateSelectInput(inputId = 'file_detailed', choices=choices)
  })
  
  filtered_by_file_detailed <- reactive({
    req(input$file_detailed)
    filtered_by_data_group_detailed() %>% 
      filter(file_name == input$file_detailed)
  }) 
  
  # choose variables based on the file filters
  observeEvent(filtered_by_file_detailed(),{
    choices <- unique(filtered_by_file_detailed()$var)
    updateSelectInput(inputId = 'var_detailed', choices = choices)
  })
  
  # get data for dip var name based on inputs/filters
  filtered_by_data_detailed_var_names <- reactive({
    combined_list_vars %>%
      filter(name %in% input$file_detailed) %>% 
      filter(var_main == input$var_detailed)
  })
  
  # create the description of the dip var name, N/A if no such variable, otherwise actual dip var name
  output$dipVarName <- renderText({
    dip_var <- filtered_by_data_detailed_var_names()$var_dip
    if(!dip_var=="no such variable") {
      paste(dip_var)
    } else {
      paste("N/A")
    }
  })
  
  
  # create final filtered table
  filtered_data_detailed <- reactive({
    filtered_by_file_detailed() %>%
      filter(var %in% input$var_detailed) %>% 
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
    datatable(filtered_data_detailed(), rownames=FALSE, options = list(pageLength = 25))

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
