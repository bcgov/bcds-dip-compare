# Copyright 2023 Province of British Columbia
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

## Some useful libraries
library(shiny)
library(shinydashboard)
library(markdown)
library(tidyverse)  ## for data manipulation
library(janitor)    ## for cleaning data (includes rounding functions)
library(lubridate)  ## for dates
library(ggplot2)    ## for plots
library(plotly)     ## for interactive plots
library(hover)      ## for action button hover animation
library(DT)         ## for tables


## Add code that you want to run before your app launches

### e.g., reading in data
## no longer reading in csvs - formatting lost
# combined_overview <- read_csv(safepaths::use_network_path("2023 ARDA BCDS Data Evaluation/data_for_dashboard/combined/combined_overview.csv"))
# combined_detailed <- read_csv(safepaths::use_network_path("2023 ARDA BCDS Data Evaluation/data_for_dashboard/combined/combined_detailed.csv"))
# combined_list_vars <- read_csv(safepaths::use_network_path("2023 ARDA BCDS Data Evaluation/data_for_dashboard/combined/combined_list.csv"))
# combined_summary <- read_csv(safepaths::use_network_path("2023 ARDA BCDS Data Evaluation/data_for_dashboard/combined/combined_summary.csv"))

## read in rds versions
combined_overview <- readRDS("data/combined_overview.rds")
combined_detailed <- readRDS("data/combined_detailed.rds")
#combined_list_vars <- readRDS("data/combined_list.rds")
combined_summary <- readRDS("data/combined_summary.rds")


# create a header
header <- htmltools::tagList(
  ## Header Styles
  htmltools::tags$head(htmltools::tags$style(htmltools::HTML('#header_col {background-color:#003366; border-bottom:2px solid #fcba19; position:fixed; z-index:10000;"}'))),
  htmltools::tags$head(htmltools::tags$style(htmltools::HTML('.header {padding:0 0px 0 0px; display:flex; height:80px; width:100%;}'))),
  htmltools::tags$head(htmltools::tags$style(htmltools::HTML('.banner {width:100%; display:flex; justify-content:space-between; align-items:center; margin: 0 10px 0 10px}'))),
  htmltools::tags$head(htmltools::tags$style(htmltools::HTML('#app_title {font-weight:400; color:white; margin: 5px 5px 0 18px;}'))),
  htmltools::tags$head(htmltools::tags$style(htmltools::HTML('.source_links {margin-left:auto; margin-right:10px;}'))),
  
  shiny::column(
    id = "header_col",
    width = 12,
    htmltools::tags$header(
      class="header",
      
      htmltools::tags$div(
       class="banner",
       
       htmltools::a(
         href= "https://www2.gov.bc.ca/gov/content/data/about-data-management/bc-stats",
         htmltools::img(
           src = "bcstats_logo_rev.png",
           title = "BC Stats",
           height = "80px",
           alt = "British Columbia - BC Stats"
           ),
         onclick="gtag"
       ),
       shiny::h1(
         id = "app_title", "BC Demographic Survey: DIP Data Linkage Rates"
       ),
       htmltools::tags$div(
         class = "source_links",
         # Data Catalog
         htmltools::tags$a(
           href = "https://catalogue.data.gov.bc.ca/", 
           target = "_blank",
           shiny::icon("table", "fa-lg"), 
           'Download the Data',
           style = "color:white; margin-left:10px"
         )
         ),
       # Github
       htmltools::tags$a(
         href = 'http://github.com', 
         target = "_blank",
         shiny::icon("github", "fa-lg"), 
         'Source Code',
         style = "color:white; margin-left:10px"
       ), 
       # Link List
       shiny::uiOutput('links_yn')
      )
    )
  )
)
