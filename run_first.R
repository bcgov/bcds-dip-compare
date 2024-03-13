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


# Run this file at the beginning of your session - it prepares the data for app.R


library(readxl)
library(gt)
library(tidyverse)
library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(dplyr)
library(DT)
library(bcdata)
library(rmapshaper)
library(sf)
options(scipen = 999)

##############################
# OVERVIEW OF LINKAGE RATES ----
##############################

# first get the detailed .csvs
directory <- safepaths::use_network_path(
  "2023 ARDA BCDS Data Evaluation/data_for_dashboard/linkage_by_table"
)

# Get a list of all CSV files in the directory
file_list <- list.files(path = directory, pattern = "\\.csv$", full.names = TRUE)
file_list

# Read all CSV files, add a column for the filename, and combine them into one data frame
combined_overview <- map_dfr(file_list, ~ {
  file_name <- basename(.x)
  data <- read_csv(.x, na=c("","NA", "MASK"))
  data <- mutate(data, file_name = folder)
  return(data)
})

combined_overview


# confirm numeric datatypes
combined_overview <- combined_overview %>% 
  mutate(
    in_demographic = as.numeric(in_demographic),
    in_dip_dataset = as.numeric(in_dip_dataset),
    in_both = as.numeric(in_both),
    pct_demo_in_dip = as.numeric(pct_demo_in_dip),
    pct_dip_in_demo = as.numeric(pct_dip_in_demo)
  ) %>% 
  # get strings for %s and commas for Ns
  mutate(
    in_demographic_str = format(in_demographic, big.mark = ","),
    in_dip_dataset_str = format(in_dip_dataset, big.mark = ","),
    in_both_str = format(in_both, big.mark = ","),
    pct_demo_in_dip_str = sprintf("%.2f%%", pct_demo_in_dip),
    pct_dip_in_demo_str = sprintf("%.2f%%", pct_dip_in_demo)
  )  
  # clean up NAs


combined_overview

# Write the combined data to a new CSV file for review
write_csv(
  combined_overview, 
  safepaths::use_network_path(
    "2023 ARDA BCDS Data Evaluation/data_for_dashboard/combined/combined_overview.csv"
  )
)

##############################
# DETAILED VAR LINKAGE RATES ----
##############################

# first get the detailed .csvs
directory <- safepaths::use_network_path(
  "2023 ARDA BCDS Data Evaluation/data_for_dashboard/linkage_by_var_detailed"
  )

# Get a list of all CSV files in the directory
file_list <- list.files(path = directory, pattern = "\\.csv$", full.names = TRUE)
file_list

# Read all CSV files, add a column for the filename, and combine them into one data frame
combined_detailed <- map_dfr(file_list, ~ {
  file_name <- basename(.x)
  data <- read_csv(.x, na=c("","NA", "MASK"))
  data <- mutate(data, file_name = str_split(file_name, "_primary_variable")[[1]][1])
  return(data)
})

combined_detailed


# confirm numeric datatypes
combined_detailed <- combined_detailed %>% 
  mutate(
    unique_n = as.numeric(unique_n),
    unique_percent = as.numeric(unique_percent),
    unique_percent_survey = as.numeric(unique_percent_survey)
    ) %>% 
  # get strings for %s and commas for Ns
  mutate(
    unique_n_str = format(unique_n, big.mark = ","),
    unique_percent_str = sprintf("%.2f%%", unique_percent),
    unique_percent_survey_str = sprintf("%.2f%%", unique_percent_survey)
    ) %>% 
  # clean up NAs
  mutate(
    unique_n_str = if_else(grepl('NA', unique_n_str), 'MASK', unique_n_str),
    unique_percent_str = if_else(unique_percent_str == 'NA%', 'MASK', unique_percent_str),
    unique_percent_survey_str = if_else(unique_percent_survey_str == 'NA%', 'MASK', unique_percent_survey_str)
  ) %>% 
  # remove total counts 
  filter( var!= "TOTAL")

combined_detailed
combined_detailed %>% select(unique_n_str, unique_percent_str, unique_percent_survey_str)

# Write the combined data to a new CSV file for review
write_csv(
  combined_detailed, 
  safepaths::use_network_path(
    "2023 ARDA BCDS Data Evaluation/data_for_dashboard/combined/combined_detailed.csv"
    )
)


##############################
# SUMMARY OF LINKAGE BY VAR ----
##############################

# first get the summary .csvs
directory <- safepaths::use_network_path(
  "2023 ARDA BCDS Data Evaluation/data_for_dashboard/linkage_by_var_summary/"
  )

# Get a list of all CSV files in the directory
file_list <- list.files(path = directory, pattern = "\\.csv$", full.names = TRUE)
file_list

# Read all CSV files, add a column for the filename, and combine them into one data frame
combined_summary <- map_dfr(file_list, ~ {

  file_name <- basename(.x)
  data <- read_csv(.x, na=c("","NA", "MASK"))
  data <- mutate(data, file_name = str_split(file_name, "_primary_variable")[[1]][1])

  return(data)
})

# confirm numeric datatypes
combined_summary <- combined_summary %>% 
  mutate(
    unique_n = as.numeric(unique_n),
    unique_percent = as.numeric(unique_percent),
    unique_percent_survey = as.numeric(unique_percent_survey)
  ) %>% 
  # fill in missing rows 
  complete(
    file_name, var, cross_status,
    fill = list(unique_n = 0, unique_percent = 0, unique_percent_survey = 0)
  ) %>% 
  # get strings for %s and commas for Ns
  mutate(
    unique_n_str = format(unique_n, big.mark = ","),
    unique_percent_str = sprintf("%.2f%%", unique_percent),
    unique_percent_survey_str = sprintf("%.2f%%", unique_percent_survey)
  ) %>% 
  # clean up NAs
  mutate(
    unique_n_str = if_else(grepl('NA', unique_n_str), 'MASK', unique_n_str),
    unique_percent_str = if_else(unique_percent_str == 'NA%', 'MASK', unique_percent_str),
    unique_percent_survey_str = if_else(unique_percent_survey_str == 'NA%', 'MASK', unique_percent_survey_str)
  ) %>% 
  # tidy up the wording of cross status
  mutate(
    cross_status = case_when(
      cross_status == 'added info' ~ 'Present in survey only',
      cross_status == 'lost info' ~ 'Present in DIP dataset only',
      cross_status == 'both NA or invalid' ~ 'Not present in survey OR DIP',
      cross_status == 'both known' ~ 'Present in survey AND DIP'
    )
  )
  
combined_summary 

# Write the combined data to a new CSV file for review
write_csv(
  combined_summary, 
  safepaths::use_network_path(
    "2023 ARDA BCDS Data Evaluation/data_for_dashboard/combined/combined_summary.csv"
    )
  )
