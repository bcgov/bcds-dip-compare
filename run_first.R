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
  data <- mutate(
    data, 
    file_name = folder
    )
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

# write combined data to rds for use by app
if(!dir.exists("app/data")) {dir.create("app/data") } # create data folder if doesn't exist
saveRDS(combined_overview, "app/data/combined_overview.rds")

##############################
# DETAILED VAR LINKAGE RATES ----
##############################

# first get the detailed .csvs
directory <- safepaths::use_network_path(
  "2023 ARDA BCDS Data Evaluation/data_for_dashboard/linkage_by_var_detailed"
  )

# Get a list of all CSV files in the directory
file_list <- list.files(path = directory, pattern = "\\.csv$", full.names = TRUE, recursive=TRUE)
file_list

# Read all CSV files, add a column for the filename, and combine them into one data frame
combined_detailed <- map_dfr(file_list, ~ {
  file_name <- basename(.x)
  data_group <- basename(dirname(.x))
  data <- read_csv(.x, na=c("","NA", "MASK"))
  data <- mutate(
    data, 
    file_name = str_split(file_name, "_primary_variable")[[1]][1],
    data_group = data_group
    )
  return(data)
})

combined_detailed

# confirm numeric datatypes
combined_detailed <- combined_detailed %>% 
  mutate(
    unique_n = as.numeric(unique_n),
    unique_percent = as.numeric(unique_percent),
    unique_percent_survey = as.numeric(unique_percent_survey),
    # clean up a couple of issues with large percentages 
    unique_percent_survey = if_else(unique_percent_survey > 100, NA_real_, unique_percent_survey)
    ) %>% 
  # fill in missing rows 
  group_by(data_group, file_name, var) %>% 
  complete(dip_value, bcds_value) %>% 
  ungroup() %>% 
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
    unique_percent_survey_str = case_when(
      is.na(unique_percent_survey) & is.na(unique_percent) ~ 'MASK', 
      is.na(unique_percent_survey) & !is.na(unique_percent) ~ 'NA',
      TRUE ~ unique_percent_survey_str),
    bcds_value = if_else(is.na(bcds_value), 'Not in Survey', bcds_value)
  ) %>% 
  # remove total counts 
  filter( var!= "TOTAL") %>% 
  # fix typo
  mutate(
    var = case_when(
      var == "dip_gdr" ~ "gender",
      TRUE ~ var
    )
  )

# filter out status variables now from the full detailed set, not useful 
combined_detailed <- combined_detailed %>% 
  filter(!var %in% c('gender status', 'dob status')) 

combined_detailed 

# Write the combined data to a new CSV file for review
write_csv(
  combined_detailed, 
  safepaths::use_network_path(
    "2023 ARDA BCDS Data Evaluation/data_for_dashboard/combined/combined_detailed.csv"
    )
)

# write combined data to rds for use by app
saveRDS(combined_detailed, "app/data/combined_detailed.rds")

##############################
# DETAILS ON COLUMN NAMES ----
##############################

# get a list of what does/doesn't exist in each dataset, and what the column name is
# this should be complete for every dataset? 
# note: weird extra msp row - gender fmou - remove?
col_names_path <- safepaths::use_network_path(
  "2023 ARDA BCDS Data Evaluation/data_for_dashboard/column_names/linkage_variable_names.csv"
)

tmp <- read_csv(col_names_path) %>% 
  filter(var_main != 'gender_FMOU') %>% 
  filter(set == 'primary') %>% # remove later 
  mutate(exists_in_dip = var_dip!='no such variable') %>% 
  mutate(file_name = name)

combined_list_vars <- tmp %>% group_by(name, var_main) %>% 
  mutate(row_num = row_number()) %>% 
  # fix gender and dob to gender status and dob status
  mutate(var_main = case_when(
    var_main == 'gender' & row_num == 2 ~ 'gender status',
    var_main == 'dob' ~ 'dob status',
    TRUE ~ var_main
  )) %>% 
  filter(
    var_main != 'gender status'
  ) 

combined_list_vars <- combined_list_vars %>% 
  # fix typo
  mutate(
    var_main = case_when(
      var_main == "disability: phsyical capacity" ~ "disability: physical capacity",
      TRUE ~ var_main
    )
  ) %>% 
  # add "survey" variable; manually fix non-matching default survey variables
  mutate(
    survey_var = case_when(
      var_main == "disability 2" ~ "disability",
      var_main == "indigenous ever" ~ "indigenous",
      var_main == "indigenous ever backdated" ~ "indigenous",
      var_main == "FN income assist" ~ "indigenous",
      var_main == "dip_gdr" ~ "gender",
      grepl("disability: ",var_main) ~ "disability",
      TRUE ~ var_main
    )
  )

write_csv(
  combined_list_vars, 
  safepaths::use_network_path(
    "2023 ARDA BCDS Data Evaluation/data_for_dashboard/combined/combined_list.csv"
  )
)

# write combined data to rds for use by app
saveRDS(combined_list_vars, "app/data/combined_list.rds")

##############################
# SUMMARY OF LINKAGE BY VAR ----
##############################

# first get the summary .csvs
directory <- safepaths::use_network_path(
  "2023 ARDA BCDS Data Evaluation/data_for_dashboard/linkage_by_var_summary/"
  )

# Get a list of all CSV files in the directory
file_list <- list.files(path = directory, pattern = "\\.csv$", full.names = TRUE, recursive=TRUE)
file_list

# Read all CSV files, add a column for the filename, and combine them into one data frame
combined_summary <- map_dfr(file_list, ~ {

  file_name <- basename(.x)
  data_group <- basename(dirname(.x))
  data <- read_csv(.x, na=c("","NA", "MASK"))
  data <- mutate(data, file_name = str_split(file_name, "_primary_variable")[[1]][1])
  data <- mutate(data, mask_flag = is.na(unique_n))
  data <- mutate(data, data_group = data_group)

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
  group_by(file_name, var, data_group) %>% 
  complete(
    cross_status = unique(combined_summary$cross_status), 
    fill = list(unique_n = 0, unique_percent = 0, unique_percent_survey = 0, mask_flag = FALSE)
  ) %>% 
  ungroup() %>% 
  
  # get strings for %s and commas for Ns
  mutate(
    unique_n_str = format(unique_n, big.mark = ","),
    unique_percent_str = sprintf("%.2f%%", unique_percent),
    unique_percent_survey_str = sprintf("%.2f%%", unique_percent_survey)
  ) %>% 
  # clean up NAs
  mutate(
    unique_n_str = if_else(mask_flag, 'MASK', unique_n_str),
    unique_percent_str = if_else(mask_flag, 'MASK', unique_percent_str),
    unique_percent_survey_str = case_when(
      mask_flag ~ 'MASK', 
      unique_percent_survey_str == 'NA%' ~ 'NA', 
      TRUE ~ unique_percent_survey_str
      )
  ) %>% 
  # tidy up the wording of cross status
  mutate(
    cross_status = case_when(
      cross_status == 'added info' ~ 'Survey only',
      cross_status == 'lost info' ~ 'DIP only',
      cross_status == 'both NA or invalid' ~ 'Neither source',
      cross_status == 'both known' ~ 'DIP and survey'
    )
  ) %>% 
  # filter out status variables now from the summary set, not useful 
  filter(!var %in% c('gender status')) %>% 
  # fix typo
  mutate(
    var = case_when(
      var == "dip_gdr" ~ "gender",
      TRUE ~ var
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

# write combined data to rds for use by app
saveRDS(combined_summary, "app/data/combined_summary.rds")
