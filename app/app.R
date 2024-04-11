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

ui <- tagList(

  shinyjs::useShinyjs(),
  hover::use_hover(popback = TRUE),
  
  # additional css to make certain things work
  tags$head(tags$link(rel = "shortcut icon", href = "favicon.png")), ## to add BCGov favicon
  tags$style(type='text/css', ".btn.dropdown-toggle.btn-default { background: white;}"), ## make filter drop-downs white
  tags$body(style = "overflow-x:scroll"), ## allow scrolling on x-axis in browser
  
  ## deprecated so copied appropriate code into functions.R
  useShinydashboard(),
  
  navbarPage(
    id = 'navbar',
    theme = "styles.css",
    lang = 'en',
    position = c('fixed-top'),
    collapsible = TRUE,
    #fluid=TRUE,
    selected = 'home',
    
    ## title/header/footer ----
    title = "",

    header = bcsapps::bcsHeaderUI(
      id = 'header',
      appname = "BC Demographic Survey: DIP Linkage Rates",
      github = NULL # replace with github URL or NULL
    ),

    footer = fluidRow(
      style = "padding-top:15px;margin-top:-15px;min-width:-webkit-fill-available;",
      br(),br(),
      div(style = "padding-left:45px;margin-top:-50px;",
          br(),br(),
          h3('This dashboard was produced in 2024. Linkage rates will change overtime.'),
          "Questions for DIP?", 
          a(style = "text-decoration:underline",
            href = "https://dpdd.atlassian.net/servicedesk/customer/portal/12",
            "Open a ticket here."),
          br(),
          
          "Questions about the Dashboard?",
          a(style = "text-decoration:underline",
            href = "https://dpdd.atlassian.net/servicedesk/customer/portal/12",
            "Contact BC Stats."),
          br(),
          
          "Questions about the BC Demographic Survey?",
          a(style = "text-decoration:underline",
            href = "https://dpdd.atlassian.net/servicedesk/customer/portal/12",
          "Contact them here.")),
      
          #br(),br(),
          bcsapps::bcsFooterUI(id = 'footer')
              ),
 
    # Create tabs
    # home ----
    tabPanel(
      title = div(style = "padding:9.5px 0",
                  tags$i(class = 'fa-solid fa-house'),
                  "Home"),
      value="home",
      style = "padding-top:160px",
      fluidRow(style="padding-right:30px;padding-left:30px;background-color:white;min-width:fit-content",
        column(width = 12,
               offset = 0,
               br(),
               h1("BC Demographic Survey: DIP Linkage Rates", style="color:#29619d"),
               br(),
               "This dashboard includes information on how the recent BC Demographic Survey data links to existing data in the
                              Data Innovation Program (DIP).",
               br(),br(),
               "See the ",actionLink("link_overall", "Overall Linkage Rates")," tab for information on the percentage of a dataset that has linked records in the BC Demographic Survey.",
               br(),br(),
               "See the ",actionLink("link_summary", "Linked Variables - Summary")," tab for information on which demographic variables had prior information present in the DIP dataset, and how much extra information the BC Demographic Survey is providing.",
               br(),br(),
               "See the ",actionLink("link_detailed", "Linked Individual Demogs")," tab for a deeper dive into individual demographic variables, and how individual DIP record responses compare to individual BC Demographic Survey responses.",
               br(),br(),
               "This analysis was completed in early 2024, and the datasets analyzed from within DIP include records no later than November 29, 2023.",
               "For more details on the data included in the dashboard and associated caveats, see the ",
               actionLink("link_about", "About")," tab.",
               br(),br()
        ))
    )
    ,
    # overall linkage rates ----
    tabPanel(
      title = div(style = "padding:9.5px 0",
                  #tags$i(class = 'fa-solid fa-house'),
                  "Overall Linkage Rates"),
     value="overall",
     style = "padding-top:160px",
       fluidRow(
         style="padding-right:30px;padding-left:30px;min-width:fit-content",
         box(
           width = NULL,
           solidHeader = TRUE,
           collapsible = TRUE,
           collapsed = FALSE,
           title = HTML("<small><p><b>File Name Information:</b></small>"),
           HTML(
             "<small>
             <p>This tab contains all possible datasets accessed for checking linkage rates.
             Note that some datasets may not appear in the rest of the tabs due to several reasons described below.
             <p><b>NOT_DONE_subset:</b> These datasets were deemed subsets of other datasets, and were not assessed further.
             <p><b>NOT_DONE_no_studyid:</b> These datasets did not contain a studyid variable required for linking to BC Demographic Survey information.
             <p><b>NOT_DONE_see_:</b> These datasets were not done, as they were deemed a repeat of another (e.g., calendar year dataset versus fiscal year dataset).
             </small>"
           )
         )
       ),
     fluidRow(
       style = "padding-right:30px;padding-left:30px;background-color:white;min-width:fit-content",
       DTOutput("data_overview"), ## data_overview ----
     )
    )
  ,
     
   # linked summary ----
   tabPanel(
     title = div(style = "padding:9.5px 0",
                 #tags$i(class = 'fa-solid fa-house'),
                 "Linked Variables - Summary"),
     value="summary",
     style = "padding-top:160px",
      sidebarLayout(
        sidebarPanel(
          style = "padding-right:30px;padding-left:30px;min-height:750px",
          
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
            label = "Choose Survey Variable(s):", 
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
          
          # Filter for the 'dip var' variable
          # depends on choice of var
          pickerInput(
            inputId = "dip_var_summary", 
            label = "Choose DIP Variable(s):", 
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
              collapsible = TRUE, 
              collapsed = FALSE, 
              title = HTML("<small><p><b>Cross-Status Definitions:</b></small>"),
              HTML(
                "<small>
                <p><b>Survey only:</b> 
                <p>These records contain no demographic information for the given variable within the DIP Dataset, but are supplemented by valid demographic information from the BC Demographic Survey.
                <p><b>DIP only:</b>
                <p>These records contain demographic information for the given variable within the DIP Dataset, and have no valid supplemental information from the BC Demographic Survey.
                <p><b>DIP and survey:</b>
                <p>These records contain demographic information for the given variable within the DIP Dataset, and have valid supplemental information from the BC Demographic Survey. This information may or may not align.
                <p><b>Neither source:</b>
                <p>These records contain no demographic information for the given variable within the DIP Dataset, and have no valid supplemental information from the BC Demographic Survey.
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
        mainPanel(style = "padding-right:30px;padding-left:30px;background-color:white;min-height:750px",
          
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
  
   # linked individual demogs ----
   tabPanel(
     div(style = "padding:9.5px 0",
         #tags$i(class = 'fa-solid fa-house'),
         "Linked Individual Demogs"),
     style = "padding-top:160px",
     value="detailed",
     sidebarLayout(
       
       sidebarPanel(
         style = "padding-right:30px;padding-left:30px;",
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
           "Choose Survey Variable:", 
           choices = NULL #unique(combined_detailed$var)
         ),
         
         # Filter for the 'dip var' variable
         # depends on choice of var 
         selectInput(
           "dip_var_detailed", 
           "Choose DIP Variable:", 
           choices = NULL #unique(combined_detailed$var)
         ),
       ),
       
       mainPanel(
         style = "padding-right:30px;padding-left:30px;background-color:white;",
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
    div(style = "padding:9.5px 0",
        #tags$i(class = 'fa-solid fa-house'),
        "About"),
    style = "padding-top:160px",
    value="about",
    fluidRow(
      style="padding-right:30px;padding-left:30px;background-color:white;min-width:fit-content",
      class = "bg-row",
      h1(style="padding-left:15px;margin-bottom:25px",
        "About the Dashboard"),
      div(style = "margin-left:20px;margin-right:20px",
         includeMarkdown("R/methodology.Rmd"),
         br(),
         br()))
    
  )
  )
)



#server logic ----
server <- function(input, output, session) {
  
  # formatting ----
  ## Change links to false to remove the link list from the header
  bcsapps::bcsHeaderServer(id = 'header', links = TRUE)
  bcsapps::bcsFooterServer(id = 'footer')
  
  # tab links ----
  observeEvent(input$link_about, {
    updateTabsetPanel(session, "navbar", "about")
  })
  
  observeEvent(input$link_overall, {
    updateTabsetPanel(session, "navbar", "overall")
  })
  
  observeEvent(input$link_summary, {
    updateTabsetPanel(session, "navbar", "summary")
  })
  
  observeEvent(input$link_detailed, {
    updateTabsetPanel(session, "navbar", "detailed")
  })

  # data_overview ----
  ## render table ----
  output$data_overview <- renderDT({
    datatable(
      combined_overview %>% 
        select(
          # select desired vars and numeric versions for hidden sorting
          "Dataset" = dataset, 
          "File Name" = file_name, 
          "DIP Dataset Records" = in_dip_dataset_str, 
          in_dip_dataset,
          "DIP Dataset Records Linked to Survey Records" = in_both_str,
          in_both,
          "Percent of Survey Covered" = pct_demo_in_dip_str, 
          pct_demo_in_dip,
          "Percent of DIP Dataset Covered" = pct_dip_in_demo_str,
          pct_dip_in_demo
          ), 
      #extensions = 'FixedHeader',
      options = list(pageLength = 100,
                     # use numeric columns (not visible) to properly sort string versions of columns (shown in app)
                     columnDefs = list(list(targets = 2, orderData = 3),list(targets = 4, orderData = 5),
                                       list(targets = 6, orderData = 7),list(targets = 8, orderData = 9),
                                       list(targets = c(3,5,7,9), visible = FALSE)),
                     #fixedHeader = TRUE
                     scrollY = "1000px"
                     ),
      rownames=FALSE,
      filter = list(position="top"))
  })
  
  # data_summary ----
  # Filter data based on user inputs
  
  filtered_by_data_group_summary <- reactive({
    combined_summary %>% 
      filter(data_group %in% input$data_group_summary) %>% 
      left_join(select(combined_list_vars,name,var_main,var_dip,survey_var),by=c("file_name"="name","var"="var_main"))
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
    choices <- unique(filtered_by_file_summary()$survey_var)
    updatePickerInput(inputId = 'var_summary', choices = choices, selected = choices)
  })
  
  # filter by var
  filtered_by_var_summary <- reactive({
    req(input$var_summary)
    filtered_by_file_summary() %>% 
      filter(survey_var %in% input$var_summary)
  }) 
  
  # choose variables based on the file filters
  observeEvent(filtered_by_var_summary(),{
    choices <- unique(filtered_by_var_summary()$var_dip)
    updatePickerInput(inputId = 'dip_var_summary', choices = choices, selected = choices)
  })
  
  # create final filtered table
  filtered_data_summary <- reactive({
    req(input$dip_var_summary)
    filter(filtered_by_var_summary(), var_dip %in% input$dip_var_summary) %>% 
      select(
        "Survey Variable" = survey_var, 
        "DIP Variable Name" = var_dip,
        "Cross-Status" = cross_status, 
        "Unique IDs in DIP Dataset" = unique_n_str, 
        "Percent of Unique IDs" = unique_percent_str
      )
  })
  
  ## render table ----
  output$data_summary <- renderDT({
    # add warning messages in case any filter has none selected
    validate(
      need(input$data_group_summary, 'Select at least one data provider.'),
      need(input$var_summary, 'Select at least one survey variable.'),
      need(input$dip_var_summary, 'Select at least one DIP variable.')
    )
    
    datatable(filtered_data_summary(), rownames=FALSE, options = list(pageLength = 50, scrollY = "600px"))
    
  })
  
  # create dob status flag
  output$dobflag <- reactive("dip_dob_status" %in% filtered_data_summary()$"DIP Variable Name")
  outputOptions(output, "dobflag", suspendWhenHidden = FALSE)
  
  ## summary info boxes ----
  summary_info <- reactive({
    
    list1 <- combined_list_vars %>% 
      filter(file_name == input$file_summary) %>% 
      filter(survey_var %in% input$var_summary) %>% 
      filter(var_dip %in% input$dip_var_summary) %>% 
      pull(var_dip)
    
    list2 <- combined_list_vars %>% 
      filter(file_name == input$file_summary) %>% 
      filter(survey_var %in% input$var_summary) %>% 
      filter(var_dip %in% input$dip_var_summary) %>% 
      pull(survey_var)
    
    temp <- combined_summary %>% 
      left_join(select(combined_list_vars,name,var_main,var_dip,survey_var),by=c("file_name"="name","var"="var_main")) %>% 
      filter(file_name == input$file_summary)
    
    info <- lapply(
      1:length(list1), function(index){
        
        dip_var_name = list1[index]
        var_name = list2[index]
        
        # check if it exists in DIP
        in_dip <- combined_list_vars %>% 
          filter(file_name == input$file_summary, survey_var==var_name, var_dip == dip_var_name) %>% 
          pull(exists_in_dip)
        
        # get info about the variable 
        t1 <- temp %>% 
          filter(survey_var==var_name, var_dip == dip_var_name)
        
        extra_coverage <- t1 %>% 
          filter(cross_status == 'Survey only') %>% 
          pull(unique_percent_str)
        
        already_covered <- t1 %>% 
          filter(cross_status == 'DIP only' | cross_status == 'DIP and survey') %>% 
          pull(unique_percent) %>% sum()
        
        already_covered <- sprintf("%.2f%%", already_covered)
        
        unknown_amount <- t1 %>% 
          filter(cross_status == 'Neither source') %>% 
          pull(unique_percent_str)
        
        # create info box material 
        if (in_dip) {
          icon <-  'check'
          color <- 'green'
          info <- paste0(
            ' Variable Name in DIP: ','<strong>',dip_var_name, '</strong>',
            '<br>',
            already_covered, 
            ' Known from DIP', 
            '<br>',
            extra_coverage,
            ' Additional Coverage from Survey',
            '<br>',
            unknown_amount,
            ' Still Unknown'
          )
        } else {
          icon <-  'x'
          color <- 'red'
          info <- paste0(
            'No DIP Variable',
            '<br>',
            already_covered, 
            ' Known from DIP', 
            '<br>',
            extra_coverage,
            ' Additional Coverage from Survey',
            '<br>',
            unknown_amount,
            ' Still Unknown'
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
    # add warning messages in case any filter has none selected
    validate(
      need(input$data_group_summary, 'Select at least one data provider.'),
      need(input$var_summary, 'Select at least one survey variable.'),
      need(input$dip_var_summary, 'Select at least one DIP variable.')
    )
    
    summary_info()
  })
  
  # data_detailed ----
  # Filter data based on user inputs
  
  filtered_by_data_group_detailed <- reactive({
    combined_detailed %>% 
      filter(data_group %in% input$data_group_detailed) %>% 
      left_join(select(combined_list_vars,name,var_main,var_dip,survey_var),by=c("file_name"="name","var"="var_main"))
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
    choices <- unique(filtered_by_file_detailed()$survey_var)
    updateSelectInput(inputId = 'var_detailed', choices = choices)
  })
  
  # filter by var
  filtered_by_var_detailed <- reactive({
    req(input$var_detailed)
    filtered_by_file_detailed() %>% 
      filter(survey_var == input$var_detailed)
  }) 
  
  # choose variables based on the file filters
  observeEvent(filtered_by_var_detailed(),{
    choices <- unique(filtered_by_var_detailed()$var_dip)
    updateSelectInput(inputId = 'dip_var_detailed', choices = choices)
  })
  
  # create final filtered table
  filtered_data_detailed <- reactive({
    filtered_by_var_detailed() %>%
      filter(var_dip %in% input$dip_var_detailed) %>% 
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
    # add warning message in case none selected
    validate(
      need(input$data_group_detailed, 'Select at least one data provider.')
    )
    
    datatable(
      filtered_data_detailed(), 
      rownames=FALSE, 
      options = list(pageLength = 50, scrollY = "600px")
      )

  })
  
  ## render heatmap ----
  output$heatmap_detailed <- renderPlotly({
    
    # add warning message in case none selected
    validate(
      need(input$data_group_detailed, 'Select at least one data provider.')
    )
    
    # choose which column to use for the heat map
    col_to_use <- if (input$detail_plot_option == 'bcds'){
      col_to_use = 'unique_percent_survey'
    } else {
      col_to_use = 'unique_percent'
    }
    
    temp <- combined_detailed %>% 
      left_join(select(combined_list_vars,name,var_main,var_dip,survey_var),by=c("file_name"="name","var"="var_main")) %>% 
      filter(file_name == input$file_detailed) %>% 
      filter(survey_var == input$var_detailed) %>% 
      filter(var_dip == input$dip_var_detailed) %>% 
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
      x = lapply(colnames(t1), function(x) replace(x, is.na(x), 'NA')),
      y = lapply(rownames(t1), function(x) replace(x, is.na(x), 'NA')),
      z = t1, 
      text = t2,
      type = 'heatmap',
      hoverinfo = 'text'
    ) %>% 
      layout(
        xaxis = list(
          title = "BC Demographic Survey",
          side="top",
          automargin = TRUE,
          pad = list(t = 10)
        ),
        yaxis = list(
          title = "DIP Dataset", 
          autorange = "reversed",
          type = "category"
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
