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
library(shinyBS)

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

    header = header,
    # header = bcsapps::bcsHeaderUI(
    #   id = 'header',
    #   appname = "BC Demographic Survey: DIP Data Linkage Rates",
    #   github = NULL # replace with github URL or NULL
    # ),

    footer = fluidRow(
      style = "padding-top:15px;margin-top:-15px;min-width:-webkit-fill-available;",
      br(),br(),
      div(style = "padding-left:45px;margin-top:-50px;",
          br(),br(),
          h3('Linkage rates reflect data as of 2024.'),
          "Questions for DIP?", 
          a(style = "text-decoration:underline",
            href = "https://dpdd.atlassian.net/servicedesk/customer/portal/2",
            target = "_blank",
            "Open a ticket here."),
          br(),
          
          "Questions about the Dashboard or BC Demographic Survey?",
          a(style = "text-decoration:underline",
            href = "https://dpdd.atlassian.net/servicedesk/customer/portal/12",
            target = "_blank",
            "Contact BC Stats."),
          br()),
      
          br(),br(),
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
      # title
      fluidRow(style="padding-right:30px;padding-left:30px;background-color:white;min-width:fit-content",
        column(width = 12,
               offset = 0,
               br(),
               h1("BC Demographic Survey: DIP Data Linkage Rates", style="color:#29619d"),
               br()
        )
      ),
      # about the dashboard
      fluidRow(style = "padding-left:30px;background-color:#29619d;min-width:fit-content",
        column(
          width = 9,style="color:white",
          h1("About the Dashboard"),
          h3("This dashboard provides information on how the 2023 BC Demographic Survey data links to other available data in the Data Innovation Program (DIP)."),
          br(),br(),
          hover_action_button("link_about",
                              div(style ="font-size:18px",
                                  "Read more about the data in the dashboard",
                                  tags$i(class="fa-solid fa-arrow-right-long"),
                                  hr(style= "border-top:2px solid;margin-top:10px")),
                              style = "color:white;background-color:transparent;border:none;margin-left:-12px",
                              button_animation = "grow"),
          br(),br()
        )
        ),
      # tabs info, as boxes
      fluidRow(
        style="padding-left:50px;padding-right:50px;min-width:fit-content",
        br(),br(),br(),
        column(
          ## FOR MVP: change width from 4 to 10
          width = 10, #4,
          wellPanel(
            style="padding:20px;border-radius: 25px; min-height:300px;background:white; align-items:center; justify-text:center",
            hr(style= "border-top: 5px solid #f6b900;margin-top:0px"),
            br(),
            hover_action_button(
              "link_overall",
              div(style ="font-size:18px",
                  tags$i(class='fa-solid fa-link'),
                  "Overall Linkage Rates",
                  hr(style= "border-top:2px solid;margin-top:10px")),
              style = "color:#29619d;border:none;margin-left:15px;background-color:transparent;max-width:100%",
              button_animation = "grow"),
            h3("For more information on the percentage of a dataset that has linked records in the BC Demographic Survey.")
          )),
        ### FOR MVP: remove tabs 2/3 ----
        # column(
        #   width = 4,
        #   wellPanel(
        #     style="padding:20px;border-radius: 25px; min-height:300px;background:white; align-items:center; justify-text:center",
        #     hr(style= "border-top: 5px solid #f6b900;margin-top:0px"),
        #     br(),
        #     hover_action_button(
        #       "link_summary",
        #       div(style ="font-size:18px",
        #           tags$i(class='fa-solid fa-chart-bar'),
        #           "Linked Variables Summary",
        #           hr(style= "border-top:2px solid;margin-top:10px")),
        #       style = "color:#29619d;border:none;margin-left:15px;background-color:transparent",
        #       button_animation = "grow"),
        #     h3("For more information on which demographic variables had prior information present in the DIP dataset, and how much extra information the BC Demographic Survey is providing."),
        #     ### FOR SIMPLIFIED: coming soon text ----
        #     h2("Coming Soon!", style="color:red")
        #   )),
        # column(
        #   width = 4,
        #   wellPanel(
        #     style="padding:20px;border-radius: 25px; min-height:300px;background:white; align-items:center; justify-text:center",
        #     hr(style= "border-top: 5px solid #f6b900;margin-top:0px"),
        #     br(),
        #     hover_action_button(
        #       "link_detailed",
        #       div(style ="font-size:18px",
        #           tags$i(class='fa-solid fa-code-compare'),
        #           "Linked Variables Detail",
        #           hr(style= "border-top:2px solid;margin-top:10px")),
        #       style = "color:#29619d;border:none;margin-left:15px;background-color:transparent",
        #       button_animation = "grow"),
        #     h3("For a deeper dive into individual demographic variables, and how individual DIP record values compare to individual BC Demographic Survey values."),
        #     ### FOR SIMPLIFIED: coming soon text ----
        #     h2("Coming Soon!", style="color:red")
        #   ))
      )
    )
    ,
    # overall linkage rates ----
    tabPanel(
      title = div(style = "padding:9.5px 0",
                  tags$i(class = 'fa-solid fa-link'),
                  "Overall Linkage Rates"),
     value="overall",
     style = "padding-top:160px",
     fluidRow(
       style = "padding-right:30px;padding-left:30px;background-color:white;min-width:fit-content",
       DTOutput("data_overview"), ## data_overview ----
     )
    )
  ,
  
  ## FOR MVP: remove tabs 2/3
  # # linked summary (SHORT) ----
  # tabPanel(
  #   title = div(style = "padding:9.5px 0",
  #               tags$i(class = 'fa-solid fa-chart-bar'),
  #               "Linked Variables Summary"),
  #   value="summary",
  #   style = "padding-top:160px",
  #   fluidRow(style="padding-right:30px;padding-left:30px;background-color:white;min-width:fit-content",
  #            column(width = 10,
  #                   offset = 0,
  #                   br(),
  #                   h1("BC Demographic Survey: DIP Data Linkage Rates", style="color:#29619d"),
  #                   br(),
  #                   h2("Coming Soon!", style="color:red"),
  #                   br(),
  #                   h3("For more information on which demographic variables had prior information present in the DIP dataset, and how much extra information the BC Demographic Survey is providing.")
  #            )
  #   ),
  # ),
  #    
  #  # # linked summary (FULL) ----
  #  # tabPanel(
  #  #   title = div(style = "padding:9.5px 0",
  #  #               tags$i(class = 'fa-solid fa-chart-bar'),
  #  #               "Linked Variables Summary"),
  #  #   value="summary",
  #  #   style = "padding-top:160px",
  #  #    sidebarLayout(
  #  #      sidebarPanel(
  #  #        style = "padding-right:30px;padding-left:30px;min-height:750px",
  #  #        
  #  #        # filter for the data provider variable
  #  #        pickerInput(
  #  #          inputId = "data_group_summary",
  #  #          label = "Choose Data Provider:",
  #  #          choices = unique(combined_summary$`Data Provider/Ministry`),
  #  #          selected = unique(combined_summary$`Data Provider/Ministry`),
  #  #          options = pickerOptions(
  #  #            actionsBox = TRUE, 
  #  #            liveSearch = TRUE,
  #  #            selectedTextFormat = "count > 3",
  #  #            size = 10
  #  #          ),
  #  #          multiple = TRUE
  #  #        ),
  #  #        
  #  #        # filter for the dataset variable
  #  #        pickerInput(
  #  #          "dataset_summary",
  #  #          "Choose Dataset:",
  #  #          choices = unique(combined_summary$`Dataset`),
  #  #          selected = unique(combined_summary$`Dataset`),
  #  #          options = pickerOptions(
  #  #            actionsBox = TRUE, 
  #  #            liveSearch = TRUE,
  #  #            selectedTextFormat = "count > 3",
  #  #            size = 10
  #  #          ),
  #  #          multiple = TRUE
  #  #        ),
  #  #        
  #  #        # Filter for the 'File' variable
  #  #        selectInput(
  #  #          "file_summary", 
  #  #          "Choose File:", 
  #  #          choices = default_file 
  #  #        ),
  #  #        
  #  #        # Filter for the 'survey var' variable
  #  #        pickerInput(
  #  #          inputId = "var_summary", 
  #  #          label = "Choose Survey Variable(s):", 
  #  #          choices = unique(combined_summary$survey_var),
  #  #          selected = unique(combined_summary$survey_var),
  #  #          options = pickerOptions(
  #  #            actionsBox = TRUE, 
  #  #            liveSearch = TRUE,
  #  #            selectedTextFormat = "count > 3",
  #  #            size = 10
  #  #          ), 
  #  #          multiple = TRUE
  #  #        ),
  #  #        
  #  #        # Filter for the 'dip var' variable
  #  #        # depends on choice of survey var
  #  #        pickerInput(
  #  #          inputId = "dip_var_summary", 
  #  #          label = "Choose DIP Variable(s):", 
  #  #          choices = NULL,
  #  #          selected = NULL,
  #  #          options = pickerOptions(
  #  #            actionsBox = TRUE, 
  #  #            liveSearch = TRUE,
  #  #            selectedTextFormat = "count > 3",
  #  #            size = 10
  #  #          ), 
  #  #          multiple = TRUE
  #  #        ),
  #  #        
  #  #        fluidRow(
  #  #          box(
  #  #            width = NULL,
  #  #            solidHeader = TRUE,
  #  #            collapsible = TRUE, 
  #  #            collapsed = FALSE, 
  #  #            title = HTML("<small><p><b>Cross-Status Table Definitions:</b></small>"),
  #  #            HTML(
  #  #              "<small>
  #  #              <p><b>Survey only:</b> 
  #  #              <p>Demographic information for the given variable is not available within the DIP File, but is available from the BC Demographic Survey. <em>Relates to \"Added from Survey\" in the Highlights tab.</em>
  #  #              <p><b>DIP only:</b>
  #  #              <p>Demographic information for the given variable is available within the DIP File, and is not available from the BC Demographic Survey. <em>Combined with 'DIP and survey' makes \"Known from DIP\" in the Highlights tab.</em>
  #  #              <p><b>DIP and survey:</b>
  #  #              <p>Demographic information for the given variable is available within the DIP File, and also from the BC Demographic Survey. Variable values may or may not align. <em>Combined with 'DIP only' makes \"Known from DIP\" in the Highlights tab.</em>
  #  #              <p><b>Neither source:</b>
  #  #              <p>Demographic information for the given variable is not available within the DIP File or from the BC Demographic Survey. <em>Relates to \"Still Unknown\" in the Highlights tab.</em>
  #  #              <p>
  #  #              </small>"
  #  #            )
  #  #          )
  #  #        ),
  #  #        
  #  #        # Information added about the dob variable name only when selected/exists (dobflag created in server)
  #  #        conditionalPanel(condition = 'output.dobflag == true',
  #  #                         HTML("<small>* Note: dip_dob_status is a replacement for the actual date of birth variable.
  #  #                              See metadata for the relevant dataset to determine the variable name.</small>"))
  #  #      ),
  #  #      mainPanel(
  #  #        style = "padding-right:30px;padding-left:30px;background-color:white;min-height:750px",
  #  #        # add information about data displayed
  #  #        uiOutput("viewingSummary"),
  #  #        
  #  #        tabsetPanel(
  #  #          tabPanel(
  #  #            'Highlights',
  #  #            uiOutput('summary_info'), ## summary highlights ----                
  #  #          ),
  #  #          
  #  #          tabPanel(
  #  #            'Table',
  #  #            DTOutput("data_summary") ## data_summary ----
  #  #          )
  #  #        )
  #  #      )
  #  #    )
  #  #   ),
  # 
  # # linked variables detail (SHORT) ----
  # tabPanel(
  #   title = div(style = "padding:9.5px 0",
  #               tags$i(class = 'fa-solid fa-code-compare'),
  #               "Linked Variables Detail"),
  #   value="summary",
  #   style = "padding-top:160px",
  #   fluidRow(style="padding-right:30px;padding-left:30px;background-color:white;min-width:fit-content",
  #            column(width = 10,
  #                   offset = 0,
  #                   br(),
  #                   h1("BC Demographic Survey: DIP Data Linkage Rates", style="color:#29619d"),
  #                   br(),
  #                   h2("Coming Soon!", style="color:red"),
  #                   br(),
  #                   h3("For a deeper dive into individual demographic variables, and how individual DIP record values compare to individual BC Demographic Survey values.")
  #            )
  #   ),
  # ),
  # 
  #  # # linked variables detail (FULL) ----
  #  # tabPanel(
  #  #   div(style = "padding:9.5px 0",
  #  #       tags$i(class = 'fa-solid fa-code-compare'),
  #  #       "Linked Variables Detail"),
  #  #   style = "padding-top:160px",
  #  #   value="detailed",
  #  #   sidebarLayout(
  #  #     
  #  #     sidebarPanel(
  #  #       style = "padding-right:30px;padding-left:30px;",
  #  #       
  #  #       # filter for the data provider variable
  #  #       pickerInput(
  #  #         "data_group_detailed",
  #  #         "Choose Data Provider:",
  #  #         choices = unique(combined_detailed$`Data Provider/Ministry`),
  #  #         selected = unique(combined_detailed$`Data Provider/Ministry`),
  #  #         options = pickerOptions(
  #  #           actionsBox = TRUE, 
  #  #           liveSearch = TRUE,
  #  #           selectedTextFormat = "count > 3",
  #  #           size = 10
  #  #         ),
  #  #         multiple = TRUE
  #  #       ),
  #  #       
  #  #       # filter for the dataset variable
  #  #       pickerInput(
  #  #         "dataset_detailed",
  #  #         "Choose Dataset:",
  #  #         choices = unique(combined_detailed$`Dataset`),
  #  #         selected = unique(combined_detailed$`Dataset`),
  #  #         options = pickerOptions(
  #  #           actionsBox = TRUE, 
  #  #           liveSearch = TRUE,
  #  #           selectedTextFormat = "count > 3",
  #  #           size = 10
  #  #         ),
  #  #         multiple = TRUE
  #  #       ),
  #  #       
  #  #       # Filter for the file variable
  #  #       selectInput(
  #  #         "file_detailed", 
  #  #         "Choose File:", 
  #  #         choices = default_file
  #  #       ),
  #  #       
  #  #       # Filter for the 'survey var' variable
  #  #       selectInput(
  #  #         "var_detailed", 
  #  #         "Choose Survey Variable:", 
  #  #         choices = unique(combined_detailed$survey_var),
  #  #         selected = default_survey_var,
  #  #       ),
  #  #       
  #  #       # Filter for the 'dip var' variable
  #  #       # depends on choice of survey var 
  #  #       selectInput(
  #  #         "dip_var_detailed", 
  #  #         "Choose DIP Variable:", 
  #  #         choices = NULL #unique(combined_detailed$var)
  #  #       ),
  #  #       
  #  #       # Note added to indicate multiple dip variables available
  #  #       conditionalPanel(condition = 'output.multivarflag == true',
  #  #                        textOutput("multivarnote"))
  #  #     ),
  #  #     
  #  #     mainPanel(
  #  #       style = "padding-right:30px;padding-left:30px;background-color:white;",
  #  #       # add information about data displayed
  #  #       uiOutput("viewingDetailed"),
  #  #       
  #  #       tabsetPanel(
  #  #         
  #  #         ## table ----
  #  #         tabPanel(
  #  #           "Table",
  #  #           DTOutput("data_detailed") ### data_detailed ----
  #  #         ),
  #  #         
  #  #         ## heatmap ----
  #  #         tabPanel(
  #  #           "Heatmap",
  #  #            radioButtons(
  #  #              "detail_plot_option", "Plot heatmap based on:",
  #  #              c(
  #  #                'Percent of BC Demographic Survey' = 'bcds', 
  #  #                'Percent of DIP File' = 'dip'
  #  #                ),
  #  #              inline=TRUE
  #  #              ),
  #  #           plotlyOutput("heatmap_detailed", height="800px") ### heatmap_detailed ----
  #  #          )
  #  #       )
  #  #     )
  #  #   )
  #  # ),
  
  # about ----
  tabPanel(
    div(style = "padding:9.5px 0",
        tags$i(class = 'fa-solid fa-circle-info'),
        "About"),
    style = "padding-top:160px",
    value="about",
    fluidRow(
      style="padding-right:30px;padding-left:30px;background-color:white;min-width:fit-content",
      class = "bg-row",
      h1(style="padding-left:15px;margin-bottom:25px",
        "About the Dashboard")
    ),
    fluidRow(
      style = "padding-right:30px;padding-left:30px;background-color:white;min-width:fit-content",
      # about survey
      column(
        width = 6, style="color:white",
        wellPanel(
          style="padding:20px;border-radius: 25px; min-height:150px;background:#29619d; align-items:center; justify-text:center",
          h3(
            "In 2023, BC Stats conducted the",
            a(
              "BC Demographic Survey.", 
              href='https://antiracism.gov.bc.ca/',
              target="_blank",
              style='color:#ccffff; text-decoration: underline;'
              ),
            "More than 200,000 people responded to the voluntary survey, providing information about many aspects of their identity  (such as race, ethnicity, ancestry, gender and many others)."
            ),
        )),
      
      # about dip
      column(
        width = 6, style="color:white",
        wellPanel(
          style="padding:20px;border-radius: 25px; min-height:150px;background:#29619d; align-items:center; justify-text:center",
          h3(
            "The",
            a(
              "Data Innovation Program (DIP)", 
              href='https://www2.gov.bc.ca/gov/content?id=2F6E3BF426034EDBA62F3F016EE2313D',
              target="_blank",
              style='color:#ccffff; text-decoration: underline;'
              ),
            "securely links and de-identifies data from multiple ministries, organizations or agencies in a secure platform. This dashboard looks at how successfully DIP datasets can be supplemented by data available from the BC Demographic Survey."
          ),
        ))
    ),
    
    ### FOR SIMPLIFIED: comment out variables for simplified version bit ----
    # fluidRow(style = "padding-right:30px;padding-left:30px;background-color:white;min-width:fit-content",
    #   column(
    #     width= 12,
    #     h1("BC Demographic Survey Variables"),
    #     br(),
    #     "Five variables from the BC Demographic Survey were analyzed for linkage with DIP datasets.",
    #     "These variables were chosen either for priority use or because they feature more commonly in DIP datasets and will give meaningful comparisons.",
    #     "Hover over each of the options for more information about the demographic variable.",
    #     br(), br()
    #   )
    # ),
    # 
    # # demographic tooltips ----
    # fluidRow(
    #   style = "padding-right:30px;padding-left:30px;background-color:white;min-width:100%",
    #   #### disability ---- 
    #   column(
    #     width=2, 
    #     hover_action_button(
    #       "link_disability",
    #       div(style ="font-size:18px",
    #           "Disability"
    #           ),
    #       style = "background-color:#d4dfeb;border:none;margin-left:-12px;min-width:95%;max-width:95%;min-height:100px;vertical-align: middle",
    #       button_animation = "grow"
    #       ),
    #     bsTooltip(
    #       'link_disability',
    #       "Identifies survey respondents who responded always, often, or sometimes has a disability.",
    #       placement = "bottom"
    #     )
    #     ),
    #   #### gender ----
    #   column(
    #     width=2, 
    #     hover_action_button(
    #       "link_gender",
    #       div(style ="font-size:18px",
    #           "Gender"
    #           ),
    #       style = "background-color:#d4dfeb;border:none;margin-left:-12px;min-width:95%;max-width:95%;min-height:100px;vertical-align: middle",
    #       button_animation = "grow"
    #     ),
    #     bsTooltip(
    #       'link_gender',
    #       "Identifies survey respondents who responded man/boy, woman/girl, or non-binary.",
    #       placement = "bottom"
    #     )
    #   ),
    #   #### indigenous identity----
    #   column(
    #     width=2, 
    #     hover_action_button(
    #       "link_indigenous_db",
    #       div(
    #         style ="font-size:18px",
    #         "Indigenous Identity"
    #       ),
    #       style = "background-color:#d4dfeb;border:none;margin-left:-12px;min-width:95%;max-width:95%;min-height:100px;vertical-align: middle",
    #       button_animation = "grow"
    #     ),
    #     bsTooltip(
    #       'link_indigenous_db',
    #       "Identifies survey respondents who responded First Nations, Métis or Inuk (Inuit).",
    #       placement = "bottom"
    #     )
    #   ),
    #   #### race ----
    #   column(
    #     width=2, 
    #     hover_action_button(
    #       "link_race",
    #       div(
    #         style ="font-size:18px",
    #         "Racial Identity"
    #       ),
    #       style = "background-color:#d4dfeb;border:none;margin-left:-12px;min-width:95%;max-width:95%;min-height:100px;vertical-align: middle",
    #       button_animation = "grow"
    #     ),
    #     bsTooltip(
    #       'link_race',
    #       "Identifies survey respondents who provided one or more racial identities.",
    #       placement = "bottom"
    #     )
    #   ),
    #   ### dob ----
    #   column(
    #     width=2, 
    #     hover_action_button(
    #       "link_dob",
    #       div(
    #         style ="font-size:18px",
    #         "Date of Birth"
    #       ),
    #       style = "background-color:#d4dfeb;border:none;margin-left:-12px;min-width:95%;max-width:95%;min-height:100px;vertical-align: middle",
    #       button_animation = "grow"
    #     ),
    #     bsTooltip(
    #       'link_dob',
    #       "Identifies if a record has a valid date of birth (or associated birth year, month, etc.), but does not dive deeper into the specific values.",
    #       placement = "bottom"
    #     )
    #   ),
    # ),
    
    fluidRow(style = "padding-right:30px;padding-left:30px;background-color:white;min-width:fit-content",
             br(),br(),
             column(
               width=10,
               HTML(
                 "<ul>
                    <li>
                      For more details on methodology and caveats, see the
                      <a href='bcds-dip-linkage-rates-technical-document.pdf' target='_blank'>technical documentation.</a>
                    </li>
                    <li>
                      For more details on the approach to the BC Demographic Survey, see the 
                      <a href='https://www2.gov.bc.ca/assets/gov/british-columbians-our-governments/multiculturalism-anti-racism/anti-racism/anti-racism-hub/anti-racism-stats-and-research/2024-research-release/bc-demographic-survey-report.pdf'
                        target='_blank'>2024 technical report.</a>
                    </li>
                    <li>
                      For other research that has been done using the survey, see the  
                        <a href='https://antiracism.gov.bc.ca/?page_id=34752'
                        target='_blank'>anti-racism website.</a>
                    </li>
                    <li>
                      The data in this dashboard is available for download from the
                      <a href='https://catalogue.data.gov.bc.ca/dataset/bc-demographic-survey-dip-data-linkage-rates' target='_blank'>BC Data Catalogue</a>
                      under the
                      <a href='https://www2.gov.bc.ca/gov/content/data/open-data/open-government-licence-bc' target='_blank'>Open Government Licence - British Columbia.</a>
                    </li>
                  
                  </ul>"
               ),
               br(), br(),
               "The Province recognizes the rights of Indigenous peoples to self-government and self-determination, which includes data sovereignty.",
               ## FOR SIMPLIFIED: remove wording on working with Indigenous groups until ready ----
               #"The BC Data Service (BCDS) in the Ministry of Citizens’ Services is working with Indigenous groups to develop decision-making models for data about Indigenous peoples.",
               "Under the ",
               a(
                 "Declaration Act Action Plan",
                 href='https://www2.gov.bc.ca/gov/content/governments/indigenous-people/new-relationship/united-nations-declaration-on-the-rights-of-indigenous-peoples/implementation',
                 target="_blank",
                 ),
               ", BC Data Services is committed to advancing the distinctions-based collection and use of disaggregated demographic data 
               and supporting the establishment of a First Nations-governed and mandated regional data governance centre 
               in alignment with the ",
               a(
                 "First Nations Data Governance Strategy.",
                 href='https://fnigc.ca/news/introducing-a-first-nations-data-governance-strategy/',
                 target="_blank",
                 )
             )
    )
  )
  )
)


#server logic ----
server <- function(input, output, session) {
  
  # formatting ----
  bcstatslinks::linkModServer('links')
  output$links_yn <- shiny::renderUI(bcstatslinks::linkModUI('links'))
  ## Change links to false to remove the link list from the header
  # bcsapps::bcsHeaderServer(id = 'header', links = TRUE)
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
  
  # nav bar ----
  ## code to close navbar (when in collapsed form) once a tab has been selected
  observeEvent(input$navbar, {
    shinyjs::runjs('
      var elem = document.getElementsByClassName("navbar-collapse")[0]
      elem.setAttribute("aria-expanded", "false");
      elem.setAttribute("class", "navbar-collapse collapse");
    ')
    
    shinyjs::runjs("window.scrollTo(0,0)")
  })

  # data_overview ----
  ## render table ----
  output$data_overview <- renderDT({
    datatable(
      combined_overview %>% 
        select(
          # select desired vars and ranks for hidden sorting
          "Data Provider/Ministry",
          "Dataset",
          "File",
          "SAE File Name",
          "DIP File Records" = in_dip_dataset_str, 
          in_dip_dataset_rank,
          "DIP File Records Linked to Survey Records" = in_both_str,
          in_both_rank,
          "Percent of Survey Covered" = pct_demo_in_dip_str, 
          pct_demo_in_dip_rank,
          "Percent of DIP File Covered" = pct_dip_in_demo_str,
          pct_dip_in_demo_rank
          ## FOR SIMPLIFIED: remove notes column from overview page ----
          #,
          #"Notes"=Notes
          ), 
      #extensions = 'FixedHeader',
      options = list(pageLength = 150,
                     # use numeric columns (not visible) to properly sort string versions of columns (shown in app)
                     # columnDefs = list(list(targets = 2, orderData = 3),list(targets = 4, orderData = 5),
                     #                   list(targets = 6, orderData = 7),list(targets = 8, orderData = 9),
                     #                   list(targets = c(3,5,7,9), visible = FALSE)),
                     columnDefs = list(list(targets = 4, orderData = 5),list(targets = 6, orderData = 7),
                                       list(targets = 8, orderData = 9),list(targets = 10, orderData = 11),
                                       list(targets = c(5,7,9,11), visible = FALSE)),
                     #fixedHeader = TRUE
                     scrollY = "1000px"
                     ),
      rownames=FALSE,
      filter = list(position="top"))
  })
  
  # FOR SIMPLIFIED: COMMENT OUT SUMMARY AND DETAILED SECTIONS ----
  # # data_summary ----
  # # Filter data based on user inputs
  # 
  # # data group reactive object 
  # filtered_by_data_group_summary <- reactive({
  #   #req(input$data_group_summary) # breaks if this is included -- needs to evalutate regardless 
  #   combined_summary %>% 
  #     filter(`Data Provider/Ministry` %in% input$data_group_summary)
  # })
  # 
  # # dataset reactive object 
  # filtered_by_dataset_summary <- reactive({
  #   #req(input$dataset_summary) 
  #   filtered_by_data_group_summary() %>% 
  #     filter(Dataset %in% input$dataset_summary)
  # }) 
  # 
  # # file reactive object 
  # filtered_by_file_summary <- reactive({
  #   #req(input$file_summary)
  #   filtered_by_dataset_summary() %>% 
  #     filter(File == input$file_summary)
  # }) 
  # 
  # # survey variables reactive object 
  # filtered_by_var_summary <- reactive({
  #   #req(input$var_summary)
  #   filtered_by_file_summary() %>% 
  #     filter(survey_var %in% input$var_summary)
  # }) 
  # 
  # # create final filtered table
  # filtered_data_summary <- reactive({
  #   #req(input$dip_var_summary)
  #   filter(filtered_by_var_summary(), var_dip %in% input$dip_var_summary) %>% 
  #     select(
  #       "Survey Variable" = survey_var, 
  #       "DIP Variable Name" = var_dip,
  #       "Cross-Status" = cross_status, 
  #       "Unique IDs in DIP File" = unique_n_str, 
  #       "Percent of Unique IDs" = unique_percent_str
  #     )
  # })
  # 
  # ## filter triggers ----
  # 
  # # choose datasets based on data group filters 
  # # only choose from what's already in the options list 
  # observeEvent(filtered_by_data_group_summary(), {
  #   
  #   # get full list that should be shown as options 
  #   choices_full <- sort(unique(filtered_by_data_group_summary()$Dataset))
  #   
  #   # get the current list of choices
  #   choices_selected <- sort(unique(filtered_by_dataset_summary()$Dataset))
  #   
  #   # if some of those choices aren't in full list, drop them
  #   choices <- choices_selected[choices_selected %in% choices_full]
  #   
  #   # if all choices weren't in full list, make NULL
  #   if (length(choices)==0){
  #     choices <- NULL
  #   }
  #   
  #   # update picker with selected choices 
  #   updatePickerInput(inputId = 'dataset_summary', choices = choices_full, selected = choices)
  #   
  # })
  # 
  # # choose file based on the dataset filters
  # # keep current file if it's in the allowed list of files 
  # observeEvent(filtered_by_dataset_summary(),{
  # 
  #   # all possible files based on the dataset filters
  #   choices <- sort(unique(filtered_by_dataset_summary()$File))
  #   
  #   # most recent choice 
  #   current_choice <- unique(filtered_by_file_summary()$File)
  # 
  #   # choose most recent as first priority, followed by the default, followed by alphabetical
  #   
  #   # note that if current_choice is empty, doesn't return a nice boolean 
  #   if (isTruthy(current_choice %in% choices)){
  #     selected <- current_choice
  #   } else if (default_file %in% choices){
  #     selected <- default_file
  #   } else {
  #     selected <- choices
  #   }
  #   
  #   # update filter with choices and current selection
  #   updateSelectInput(inputId = 'file_summary', choices = choices, selected = selected)
  # })
  # 
  # # choose Survey variables based on the file filters
  # # no longer needed, as survey variables should be a fixed list of 5 for every dataset 
  # # observeEvent(filtered_by_file_summary(),{
  # #   choices <- unique(filtered_by_file_summary()$survey_var)
  # #   updatePickerInput(inputId = 'var_summary', choices = choices, selected = choices)
  # # })
  # 
  # # triggers to make the dip vars work
  # triggers <- reactiveValues()
  # triggers$update_current <- 0
  # # keeps a list of the current survey vars to compare to the update
  # observeEvent(
  #   triggers$update_current,{
  #     out <- unique(filtered_by_var_summary()$var_dip)
  #     triggers$current_survey_vars <- out
  #   })
  # 
  # # reset DIP variables if the File is changed - choose all 
  # observeEvent(filtered_by_file_summary(), priority=0, {
  #   choices <- sort(unique(filtered_by_var_summary()$var_dip))
  #   updatePickerInput(inputId = 'dip_var_summary', choices = choices, selected = choices)
  #   
  #   # update current vars list 
  #   triggers$update_current  <- triggers$update_current + 1
  # })
  # 
  # # # choose DIP variables based on the survey variables filters
  # # only works with input, not the filtered table reactive var...
  # observeEvent(filtered_by_var_summary(), {
  # 
  #   # get full list that should be shown as options
  #   choices_full <- sort(unique(filtered_by_var_summary()$var_dip))
  # 
  #   # get the current list of choices
  #   choices_selected <- sort(unique(filtered_data_summary()$`DIP Variable Name`))
  # 
  #   # if some of the full list choices weren't previously options, but now are, add them in
  #   # ex gender had been unclicked, adding it back to survey vars should add its dip vars back in too
  #   new_choices <- choices_full[!choices_full %in% triggers$current_survey_vars]
  #   if (length(new_choices)>0){
  #     choices_selected <- c(choices_selected, new_choices)
  #   }
  #   
  #   # if some of those choices aren't in full list, drop them
  #   choices <- choices_selected[choices_selected %in% choices_full]
  # 
  #   # if all choices weren't in full list, make NULL
  #   if (length(choices)==0){
  #    choices <- NULL
  #   }
  # 
  #   # get current list of DIP vars being shown
  #   updatePickerInput(inputId = 'dip_var_summary', choices = choices_full, selected = choices)
  #   
  #   # update current vars list 
  #   triggers$update_current  <- triggers$update_current + 1
  #   
  # })
  # 
  # ## render table ----
  # output$data_summary <- renderDT({
  #   # add warning messages in case any filter has none selected
  #   validate(
  #     need(input$data_group_summary, 'Select at least one data provider.'),
  #     need(input$dataset_summary, 'Select at least one dataset.'),
  #     need(input$var_summary, 'Select at least one survey variable.'),
  #     need(input$dip_var_summary, 'Select at least one DIP variable.')
  #   )
  #   
  #   datatable(filtered_data_summary(), rownames=FALSE, options = list(pageLength = 50, scrollY = "600px"))
  #   
  # })
  # 
  # # create dob status flag
  # output$dobflag <- reactive("dip_dob_status" %in% filtered_data_summary()$"DIP Variable Name")
  # outputOptions(output, "dobflag", suspendWhenHidden = FALSE)
  # 
  # # add note to top of tab for information on what provider/dataset/file displayed
  # output$viewingSummary <- renderUI({
  #   h2(HTML(paste0("Currently viewing data for: <br>",
  #                  "Data Provider: ", unique(filtered_by_var_summary()$`Data Provider/Ministry`), "<br>",
  #                  "Dataset: ", unique(filtered_by_var_summary()$Dataset), "<br>",
  #                  "File: ", unique(filtered_by_var_summary()$File))))
  # })
  # 
  # ## summary info boxes ----
  # summary_info <- reactive({
  #   
  #   list1 <- combined_summary %>% 
  #     filter(File == input$file_summary) %>% 
  #     filter(survey_var %in% input$var_summary) %>% 
  #     filter(var_dip %in% input$dip_var_summary) %>% 
  #     distinct(File,var_dip,survey_var) %>% 
  #     pull(var_dip)
  #   
  #   list2 <- combined_summary %>% 
  #     filter(File == input$file_summary) %>% 
  #     filter(survey_var %in% input$var_summary) %>% 
  #     filter(var_dip %in% input$dip_var_summary) %>% 
  #     distinct(File,var_dip,survey_var) %>% 
  #     pull(survey_var)
  #   
  #   temp <- combined_summary %>% 
  #     filter(File == input$file_summary)
  #     
  #   # because using input not reactive table, get weird error message if I don't include this... 
  #   if (length(list1)==0){
  #     info <- ''
  #   } else {
  #     
  #     info <- lapply(
  #       1:length(list1), function(index){
  #         
  #         dip_var_name = list1[index]
  #         var_name = list2[index]
  #         
  #         # get info about the variable 
  #         t1 <- temp %>% 
  #           filter(survey_var==var_name, var_dip == dip_var_name)
  #         
  #         # check if it exists in DIP
  #         in_dip <- t1 %>% 
  #           distinct(exists_in_dip) %>% pull()
  #         
  #         extra_coverage <- t1 %>% 
  #           filter(cross_status == 'Survey only') %>% 
  #           pull(highlights)
  #         
  #         already_covered <- t1 %>% 
  #           filter(cross_status == 'DIP only' | cross_status == 'DIP and survey') %>% 
  #           distinct(str_replace(highlights,"Greater than or equal to ","&GreaterEqual;")) %>% pull()
  #         
  #         # find count of MASK
  #         # already_covered_mask <- t1 %>% 
  #         #   filter(cross_status == 'DIP only' | cross_status == 'DIP and survey') %>% 
  #         #   filter(unique_percent_str=="MASK")
  #         # 
  #         # # treat already covered % differently, depending on MASK result
  #         # if(nrow(already_covered_mask) == 2) {
  #         #   already_covered <- "MASK"
  #         # } else if(nrow(already_covered_mask)==1) {
  #         #   already_covered <- paste0("&GreaterEqual;",sprintf("%.2f%%", already_covered))
  #         # } else {
  #         #   already_covered <- sprintf("%.2f%%", already_covered)
  #         # }
  #         
  #         unknown_amount <- t1 %>% 
  #           filter(cross_status == 'Neither source') %>% 
  #           pull(highlights)
  #         
  #         # create info box material 
  #         if (in_dip) {
  #           icon <-  'check'
  #           color <- 'green'
  #           info <- paste0(
  #             ' Variable Name in DIP: ','<strong>',dip_var_name, '</strong>',
  #             '<br>',
  #             already_covered, 
  #             '<br>',
  #             extra_coverage,
  #             '<br>',
  #             unknown_amount
  #           )
  #         } else {
  #           icon <-  'x'
  #           color <- 'red'
  #           info <- paste0(
  #             'No DIP Variable',
  #             '<br>',
  #             already_covered, 
  #             '<br>',
  #             extra_coverage,
  #             '<br>',
  #             unknown_amount
  #           )
  #         }
  #         
  #         # return the info box
  #         infoBox(
  #           title = HTML(paste0("<p style='font-weight: bold; white-space: break-spaces;'>", var_name, "</p>")),
  #           value = HTML(paste0("<p style='font-size:14px; font-weight: normal;'>", info, "</p>")),
  #           icon = icon(icon),
  #           color = color,
  #           width = 6
  #         )
  #         
  #       })
  #   }
  #   
  #   info
  # })
  # 
  # ### render info boxes ----
  # output$summary_info <- renderUI({
  #   # add warning messages in case any filter has none selected
  #   validate(
  #     need(input$data_group_summary, 'Select at least one data provider.'),
  #     need(input$dataset_summary, 'Select at least one dataset.'),
  #     need(input$var_summary, 'Select at least one survey variable.'),
  #     need(input$dip_var_summary, 'Select at least one DIP variable.')
  #   )
  #   
  #   summary_info()
  # })
  # 
  # # data_detailed ----
  # # Filter data based on user inputs
  # 
  # # data group reactive object
  # filtered_by_data_group_detailed <- reactive({
  #   combined_detailed %>% 
  #     filter(`Data Provider/Ministry` %in% input$data_group_detailed)
  # })
  # 
  # # dataset reactive object 
  # filtered_by_dataset_detailed <- reactive({
  #   # req(input$dataset_detailed)
  #   filtered_by_data_group_detailed() %>% 
  #     filter(Dataset %in% input$dataset_detailed)
  # }) 
  # 
  # # file reactive object
  # filtered_by_file_detailed <- reactive({
  #   # req(input$file_detailed)
  #   filtered_by_dataset_detailed() %>% 
  #     filter(File == input$file_detailed)
  # }) 
  # 
  # # survey var reactive object
  # filtered_by_var_detailed <- reactive({
  #   # req(input$var_detailed)
  #   filtered_by_file_detailed() %>% 
  #     filter(survey_var == input$var_detailed)
  # }) 
  # 
  # # create final filtered table
  # filtered_data_detailed <- reactive({
  #   filtered_by_var_detailed() %>%
  #     filter(var_dip %in% input$dip_var_detailed) %>% 
  #     select(
  #       "Value in DIP" = dip_value,
  #       "Value in Survey" = bcds_value,
  #       "Unique IDs in DIP File" = unique_n_str,
  #       "Percent of Unique IDs" = unique_percent_str,
  #       "Percent of Survey Unique IDs" = unique_percent_survey_str
  #     )
  # })
  # 
  # ## filter triggers ----
  # 
  # # choose datasets based on data group filters 
  # # only choose from what's already in the options list 
  # observeEvent(filtered_by_data_group_detailed(), {
  #   
  #   # get full list that should be shown as options 
  #   choices_full <- sort(unique(filtered_by_data_group_detailed()$Dataset))
  #   
  #   # get the current list of choices
  #   choices_selected <- sort(unique(filtered_by_dataset_detailed()$Dataset))
  #   
  #   # if some of those choices aren't in full list, drop them
  #   choices <- choices_selected[choices_selected %in% choices_full]
  #   
  #   # if all choices weren't in full list, make NULL
  #   if (length(choices)==0){
  #     choices <- NULL
  #   }
  #   
  #   # update picker with selected choices 
  #   updatePickerInput(inputId = 'dataset_detailed', choices = choices_full, selected = choices)
  #   
  # })
  # 
  # # choose file based on the dataset filters
  # # keep current file if it's in the allowed list of files 
  # observeEvent(filtered_by_dataset_detailed(),{
  #   
  #   # all possible files based on the dataset filters
  #   choices <- sort(unique(filtered_by_dataset_detailed()$File))
  #   
  #   # most recent choice 
  #   current_choice <- unique(filtered_by_file_detailed()$File)
  #   
  #   # choose most recent as first priority, followed by the default, followed by alphabetical
  #   
  #   # note that if current_choice is empty, doesn't return a nice boolean 
  #   if (isTruthy(current_choice %in% choices)){
  #     selected <- current_choice
  #   } else if (default_file %in% choices){
  #     selected <- default_file
  #   } else {
  #     selected <- choices
  #   }
  #   
  #   # update filter with choices and current selection
  #   updateSelectInput(inputId = 'file_detailed', choices = choices, selected = selected)
  # })
  # 
  # # # choose survey variables based on the file filters
  # # observeEvent(filtered_by_file_detailed(),{
  # #   choices <- unique(filtered_by_file_detailed()$survey_var)
  # #   updateSelectInput(inputId = 'var_detailed', choices = choices, selected = default_survey_var)
  # # })
  # 
  # # choose DIP variables based on the survey var filters
  # observeEvent(filtered_by_var_detailed(),{
  #   choices <- sort(unique(filtered_by_var_detailed()$var_dip))
  #   updateSelectInput(inputId = 'dip_var_detailed', choices = choices)
  # })
  # 
  # ## render table ----
  # output$data_detailed <- renderDT({
  #   # add warning message in case none selected
  #   validate(
  #     need(input$data_group_detailed, 'Select at least one data provider.'),
  #     need(input$dataset_detailed, 'Select at least one dataset.')
  #   )
  #   
  #   datatable(
  #     filtered_data_detailed(), 
  #     rownames=FALSE, 
  #     options = list(pageLength = 50, scrollY = "600px")
  #     )
  # 
  # })
  # 
  # # create multi var flag & note
  # output$multivarflag <- reactive(length(unique(filtered_by_var_detailed()$var_dip)) > 1)
  # outputOptions(output, "multivarflag", suspendWhenHidden = FALSE)
  # output$multivarnote <- renderText({
  #   paste0("Multiple DIP Variable choices available for ",as.character(input$var_detailed))
  # })
  # 
  # # add note to top of tab for information on what provider/dataset/File displayed
  # output$viewingDetailed <- renderUI({
  #   h2(HTML(paste0("Currently viewing data for: <br>",
  #                  "Data Provider: ", unique(filtered_by_var_detailed()$`Data Provider/Ministry`), "<br>",
  #                  "Dataset: ", unique(filtered_by_var_detailed()$Dataset), "<br>",
  #                  "File: ", unique(filtered_by_var_detailed()$File))))
  # })
  # 
  # ## render heatmap ----
  # output$heatmap_detailed <- renderPlotly({
  #   
  #   # add warning message in case none selected
  #   validate(
  #     need(input$data_group_detailed, 'Select at least one data provider.')
  #   )
  #   
  #   # choose which column to use for the heat map
  #   col_to_use <- if (input$detail_plot_option == 'bcds'){
  #     col_to_use = 'unique_percent_survey'
  #   } else {
  #     col_to_use = 'unique_percent'
  #   }
  #   
  #   temp <- combined_detailed %>% 
  #     mutate(unique_percent_survey = ifelse(unique_percent_survey_str=="MASK",NA_integer_,str_replace(unique_percent_survey_str,"%","")),
  #            unique_percent = ifelse(unique_percent_str=="MASK",NA_integer_,str_replace(unique_percent_str,"%",""))) %>% 
  #     mutate(unique_percent_survey = as.numeric(unique_percent_survey),
  #            unique_percent = as.numeric(unique_percent)) %>% 
  #     filter(File == input$file_detailed) %>% 
  #     filter(survey_var == input$var_detailed) %>% 
  #     filter(var_dip == input$dip_var_detailed) %>% 
  #     mutate(text = paste0(
  #       "BC Demographic Survey Value: ", bcds_value, "\n",
  #       "DIP File Value: ", dip_value, "\n",
  #       "Number of Records: ", unique_n_str, "\n",
  #       "Percent of BC Demographic Survey: ", unique_percent_survey_str, "\n",
  #       "Percent of DIP File: ", unique_percent_str
  #     )) %>% 
  #     mutate(percent = get(col_to_use)) %>% 
  #     select(dip_value, bcds_value, percent, text) %>% 
  #     arrange(desc(percent)) %>% 
  #     mutate(
  #       dip_value = factor(dip_value, levels=unique(.$dip_value), exclude=NULL),
  #       bcds_value = factor(bcds_value, levels=unique(.$bcds_value), exclude=NULL)
  #     ) 
  #   
  #   t1 <- temp %>% 
  #     select(-text) %>% 
  #     pivot_wider(names_from = bcds_value, values_from = percent)
  #   
  #   t2 <- temp %>% 
  #     select(-percent) %>% 
  #     pivot_wider(names_from = bcds_value, values_from = text) %>% 
  #     select(-dip_value) %>% 
  #     as.matrix()
  #   
  #   row_names = t1$dip_value
  #   t1 <- as.matrix(t1 %>% select(-dip_value))
  #   rownames(t1) = row_names
  #   
  #   fig <- plot_ly(
  #     x = lapply(colnames(t1), function(x) replace(x, is.na(x), 'NA')),
  #     y = lapply(rownames(t1), function(x) replace(x, is.na(x), 'NA')),
  #     z = t1, 
  #     text = t2,
  #     type = 'heatmap',
  #     hoverinfo = 'text'
  #   ) %>% 
  #     layout(
  #       xaxis = list(
  #         title = "BC Demographic Survey",
  #         side="top",
  #         automargin = TRUE,
  #         pad = list(t = 10)
  #       ),
  #       yaxis = list(
  #         title = "DIP File", 
  #         autorange = "reversed",
  #         type = "category"
  #       ),
  #       margin = list(
  #         l = 50,
  #         r = 50,
  #         b = 10,
  #         t = 150,
  #         pad = 0
  #       )
  #     )
  #   
  #   fig
  #   
  # })


}

# Run the application
shinyApp(ui = ui, server = server)
