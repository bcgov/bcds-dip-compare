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
combined_list_vars <- readRDS("data/combined_list.rds")
combined_summary <- readRDS("data/combined_summary.rds")

