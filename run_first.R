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

#*******************************
# DATASET INFORMATION LOOKUP ----
#*******************************

# get a list of nice dataset names and notes about each dataset
dataset_info_path <- safepaths::use_network_path(
  "2023 ARDA BCDS Data Evaluation/data_for_dashboard/combined/combined_cross_walk.csv"
)

dataset_info <- read_csv(dataset_info_path) 

# update header names
dataset_info <- dataset_info %>% 
  rename(`Data Innovation Program File Name` = `SAE File Name`)

#*******************************
# DETAILS ON COLUMN NAMES ----
#*******************************

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
  # add "survey" variable
  mutate(
    survey_var = case_when(
      # standardize regular vars
      var_main == "disability" ~ "Disability",
      var_main == "indigenous identity" ~ "Indigenous Identity",
      var_main == "gender" ~ "Gender",
      var_main == "race" ~ "Racial Identity",
      var_main == "dob status" ~ "Date of Birth",
      #manually fix non-matching default survey variables
      var_main == "gender boy" ~ "Gender",
      var_main == "gender girl" ~ "Gender",
      var_main == "gender old method" ~ "Gender",
      var_main == "gender other" ~ "Gender",
      var_main == "gender unknown" ~ "Gender",
      var_main == "disability 2" ~ "Disability",
      var_main == "indigenous ever" ~ "indigenous",
      var_main == "indigenous ever backdated" ~ "indigenous",
      var_main == "indigenous identity ever" ~ "Indigenous Identity",
      var_main == "indigenous identity overall" ~ "Indigenous Identity",
      var_main == "indigenous identity ever backdated" ~ "Indigenous Identity",
      #var_main == "FN income assist" ~ "indigenous",
      var_main == "dip_gdr" ~ "Gender",
      grepl("disability: ",var_main) ~ "Disability",
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
# saveRDS(combined_list_vars, "app/data/combined_list.rds") # app not using


#*******************************
# OVERVIEW OF LINKAGE RATES ----
#*******************************

# first get the overview .csvs
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
    in_demographic_str = format(in_demographic, big.mark = ",", trim = TRUE),
    in_dip_dataset_str = format(in_dip_dataset, big.mark = ",", trim = TRUE),
    in_both_str = format(in_both, big.mark = ",", trim = TRUE),
    pct_demo_in_dip_str = ifelse(is.na(pct_demo_in_dip),"NA",sprintf("%.2f%%", pct_demo_in_dip)),
    pct_dip_in_demo_str = ifelse(is.na(pct_dip_in_demo),"NA",sprintf("%.2f%%", pct_dip_in_demo))
  )  
  # clean up NAs

# replace numeric with ranks for sorting
combined_overview <- combined_overview %>% 
  mutate(in_dip_dataset_rank = ifelse(is.na(in_dip_dataset),NA_real_,rank(in_dip_dataset)),
         in_both_rank = ifelse(is.na(in_both),NA_real_,rank(in_both)),
         pct_demo_in_dip_rank = ifelse(is.na(pct_demo_in_dip),NA_real_,rank(pct_demo_in_dip)),
         pct_dip_in_demo_rank = ifelse(is.na(pct_dip_in_demo),NA_real_,rank(pct_dip_in_demo)),
         .keep="unused") %>% 
  select(-in_demographic)

# add dataset information
combined_overview <- combined_overview %>% 
  rename(`Data Innovation Program File Name`=dataset,`SAE File Name (Short)`=file_name) %>% 
  select(-folder) %>% 
  left_join(dataset_info, by=c("Data Innovation Program File Name","SAE File Name (Short)")) %>% 
  # add spaces for better layout on dashboard
  mutate(`Data Innovation Program File Name`=str_replace_all(`Data Innovation Program File Name`,"/"," / ")) %>%
  select(-`SAE File Name (Short)`)

# arrange alphabetically - data provider first, then Dataset, then File
combined_overview <- combined_overview %>% 
  dplyr::arrange(`Data Provider/Ministry`,Dataset,File)

combined_overview

# Write the combined data to a new CSV file for review
# note that this still has the notes column, but we won't include that in the actual dashboard
# keep notes for internal use
write_csv(
  combined_overview, 
  safepaths::use_network_path(
    "2023 ARDA BCDS Data Evaluation/data_for_dashboard/combined/combined_overview.csv"
  )
)

# write combined data to rds for use by app 
# and remove notes from data
if(!dir.exists("app/data")) {dir.create("app/data") } # create data folder if doesn't exist
saveRDS(combined_overview %>% select(-Notes), "app/data/combined_overview.rds")

# write data for catalogue
# remove rank columns
overall_linkage_rates <- combined_overview %>% 
  select(-contains("rank"))

# rename and order columns
overall_linkage_rates <- overall_linkage_rates %>%
  # remove extra spacing for catalogue
  mutate(`Data Innovation Program File Name`=str_replace_all(`Data Innovation Program File Name`," / ","/")) %>% 
  janitor::clean_names() %>% 
  #mutate(notes = ifelse(is.na(notes),"",notes)) %>% # not showing Notes column in linkage-only dashboard
  select(any_of(names(janitor::clean_names(dataset_info))),
         "survey_records"=in_demographic_str,
         "file_records"=in_dip_dataset_str,
         "file_records_linked_to_survey_records"=in_both_str,
         "percent_of_survey_covered" = pct_demo_in_dip_str, 
         "percent_of_file_covered" = pct_dip_in_demo_str,
         everything(),-notes
         #,notes # not showing notes in linkage-only dashboard
         )

write_csv(
  overall_linkage_rates, 
  safepaths::use_network_path(
    "2023 ARDA BCDS Data Evaluation/data_for_catalogue/bcds-dip-linkage-rates-data-overall.csv"
  )
)


#*******************************
# SUMMARY OF LINKAGE BY VAR ----
#*******************************

# first get the summary .csvs
directory <- safepaths::use_network_path(
  "2023 ARDA BCDS Data Evaluation/data_for_dashboard/linkage_by_var_summary/"
  )

# Get a list of all CSV files in the directory
file_list <- list.files(path = directory, pattern = "\\.csv$", full.names = TRUE, recursive=TRUE)
file_list

# Read all CSV files, add a column for the filename, and combine them into one data frame
combined_summary <- map_dfr(file_list, ~ {
  name <- basename(.x)
  data <- read_csv(.x, na=c("","NA", "MASK"))
  data <- mutate(data, file_name = str_split(name, "_primary_variable|_ind_variable|_missed_variable")[[1]][1])
  data <- mutate(data, mask_flag = is.na(unique_n))
  data <- mutate(data, name = name)

  return(data)
})

# fix incorrect gender/sex variable name in perinatal
combined_summary <- combined_summary %>% 
  mutate(var = case_when(
    var == 'sex' ~ 'gender',
    TRUE ~ var
  ))

# fix typo from health files
multi_file_groups <- combined_summary %>%
  distinct(name,file_name) %>%
  group_by(file_name) %>%
  summarise(
    name_combo = paste(name, collapse=", ")) %>%
  filter(grepl(",",name_combo)) %>%
  pull(file_name)

combined_summary <- combined_summary %>%
  mutate(var = case_when((file_name %in% multi_file_groups & grepl("_primary",name) & var=="indigenous") ~ "indigenous identity",
                         TRUE ~ var)) %>%
  select(-name)

# fix some cross_status data issues
combined_summary <- combined_summary %>%
  mutate(
    cross_status = case_when(
      # gender assumed for all IDs - revert to no DIP variable
      (file_name=="vital_events_stillbirths_id2_mom" & var %in% "gender" & cross_status=="lost info") ~ "both NA or invalid",
      (file_name=="vital_events_stillbirths_id2_mom" & var %in% "gender" & cross_status=="both known") ~ "added info",
      (file_name=="vital_events_births_id2_mom" & var %in% "gender" & cross_status=="lost info") ~ "both NA or invalid",
      (file_name=="vital_events_births_id2_mom" & var %in% "gender" & cross_status=="both known") ~ "added info",
      TRUE ~ cross_status
    )
  )

# confirm numeric datatypes
combined_summary <- combined_summary %>%
  mutate(
    unique_n = as.numeric(unique_n),
    unique_percent = as.numeric(unique_percent),
    unique_percent_survey = as.numeric(unique_percent_survey)
  ) %>%

  # fill in missing rows
  group_by(file_name, var) %>%
  complete(
    cross_status = unique(combined_summary$cross_status),
    fill = list(unique_n = 0, unique_percent = 0, unique_percent_survey = 0, mask_flag = FALSE)
  ) %>%
  ungroup() %>%

  # get strings for %s and commas for Ns
  mutate(
    unique_n_str = format(unique_n, big.mark = ",", trim = TRUE),
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
      cross_status == 'lost info' ~ 'File only',
      cross_status == 'both NA or invalid' ~ 'Neither source',
      cross_status == 'both known' ~ 'File and survey'
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
  ) %>%
  # filter out age
  filter(var != 'age')

combined_summary


# add survey column name
combined_summary <- combined_summary %>%
  left_join(select(combined_list_vars,name,var_main,var_dip,survey_var,exists_in_dip),by=c("file_name"="name","var"="var_main"))

# remove difficulty from data
combined_summary <- combined_summary %>%
  filter(survey_var!="difficulty")

# remove indigenous from data (only keeping Indigenous Identity (distinctions based version))
combined_summary <- combined_summary %>%
  filter(survey_var!="indigenous")

# remove indigenous identity unused from data (e.g., nation-related data)
combined_summary <- combined_summary %>%
  filter(survey_var!="indigenous identity unused")

# remove indigenous identity overall when doesn't exist in DIP
combined_summary <- combined_summary %>%
  filter(!(var=="indigenous identity overall" & exists_in_dip==FALSE))

# remove indigenous identity - for now ----
combined_summary <- combined_summary %>% 
  filter(survey_var!='Indigenous Identity')

# add dataset information
combined_summary <- combined_summary %>%
  rename(`SAE File Name (Short)`=file_name) %>%
  left_join(dataset_info, by=c("SAE File Name (Short)")) %>%
  mutate(`Data Innovation Program File Name`=str_replace_all(`Data Innovation Program File Name`,"/"," / ")) %>%
  select(-`SAE File Name (Short)`)

# remove datasets with 0 linkage
no_linkage_datasets <- combined_overview %>% filter(in_both_str=="0") %>% pull(File)

combined_summary <- combined_summary %>%
  filter(!File %in% no_linkage_datasets)

# add highlights information
known_dip_mask_count <- combined_summary %>%
  filter(cross_status == 'File only' | cross_status == 'File and survey') %>%
  filter(unique_percent_str=="MASK") %>%
  group_by(File,survey_var,var_dip) %>%
  tally()


combined_summary <- combined_summary %>%
  left_join(known_dip_mask_count,by=c("File","survey_var","var_dip")) %>%
  mutate(highlights_groups = case_when((cross_status == 'File only' | cross_status == 'File and survey') ~ "Known from File",
                                       cross_status=="Survey only" ~ "Added from Survey",
                                       cross_status=="Neither source" ~ "Still Unknown")) %>%
  group_by(File,survey_var,var_dip,highlights_groups) %>%
  mutate(known_sum = ifelse(highlights_groups=="Known from File",sum(unique_percent),NA_real_)) %>%
  mutate(highlights = case_when(cross_status=="Survey only" ~ paste0(unique_percent_str," ",highlights_groups),
                                cross_status=="Neither source" ~ paste0(unique_percent_str," ",highlights_groups),
                                (highlights_groups=="Known from File" & n==2) ~ paste0("MASK ",highlights_groups),
                                (highlights_groups=="Known from File" & n==1) ~  paste0("Greater than or equal to ",sprintf("%.2f%%", known_sum)," ",highlights_groups),
                                (highlights_groups=="Known from File") ~  paste0(sprintf("%.2f%%", known_sum)," ",highlights_groups))) %>%
  ungroup() %>% select(-n,-known_sum,-highlights_groups)

# remove unused columns
combined_summary <- combined_summary %>%
  select(-var,-unique_n,-unique_percent,-unique_percent_survey,-Notes,-unique_percent_survey_str)

# arrange alphabetically - data provider first, then Dataset, then File
combined_summary <- combined_summary %>%
  dplyr::arrange(`Data Provider/Ministry`,Dataset,File,survey_var,var_dip)

# Write the combined data to a new CSV file for review
write_csv(
  combined_summary,
  safepaths::use_network_path(
    "2023 ARDA BCDS Data Evaluation/data_for_dashboard/combined/combined_summary.csv"
    )
  )

# write combined data to rds for use by app
saveRDS(combined_summary, "app/data/combined_summary.rds")

# write data for catalogue
# remove app required columns
linked_variables_summary <- combined_summary %>%
  select(-highlights,-exists_in_dip,-mask_flag)

# rename and order columns
linked_variables_summary <- linked_variables_summary %>%
# remove extra spacing for catalogue
  mutate(`Data Innovation Program File Name`=str_replace_all(`Data Innovation Program File Name`," / ","/")) %>%
  janitor::clean_names() %>%
  select(any_of(names(janitor::clean_names(dataset_info))),
         "survey_variable" = survey_var,
         "file_variable" = var_dip,
         "cross_status"=cross_status,
         "unique_ids_in_file" = unique_n_str,
         "percent_of_unique_ids" = unique_percent_str,
         everything()
  )


write_csv(
  linked_variables_summary,
  safepaths::use_network_path(
    "2023 ARDA BCDS Data Evaluation/data_for_catalogue/bcds-dip-linkage-rates-data-summary.csv"
  )
)

#*******************************
# DETAILED VAR LINKAGE RATES ----
#*******************************

# first get the detailed .csvs
directory <- safepaths::use_network_path(
  "2023 ARDA BCDS Data Evaluation/data_for_dashboard/linkage_by_var_detailed"
)

# Get a list of all CSV files in the directory
file_list <- list.files(path = directory, pattern = "\\.csv$", full.names = TRUE, recursive=TRUE)
file_list

# Read all CSV files, add a column for the filename, and combine them into one data frame
combined_detailed <- map_dfr(file_list, ~ {
  name <- basename(.x)
  data <- read_csv(.x, na=c("","NA", "MASK"))
  data <- mutate(
    data,
    name = name,
    file_name = str_split(name, "_primary_variable|_ind_variable|_missed_variable")[[1]][1]
  )
  return(data)
})

# fix incorrect gender/sex variable name in perinatal
combined_detailed <- combined_detailed %>% 
  mutate(var = case_when(
    var == 'sex' ~ 'gender',
    TRUE ~ var
  ))

# fix typo from health files
multi_file_groups <- combined_detailed %>%
  distinct(name,file_name) %>%
  group_by(file_name) %>%
  summarise(
    name_combo = paste(name, collapse=", ")) %>%
  filter(grepl(",",name_combo)) %>%
  pull(file_name)

combined_detailed <- combined_detailed %>%
  mutate(var = case_when((file_name %in% multi_file_groups & grepl("_primary",name) & var=="indigenous") ~ "indigenous identity",
                         TRUE ~ var)) %>%
  select(-name)

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
  group_by(file_name, var) %>%
  complete(dip_value, bcds_value) %>%
  ungroup() %>%
  # get strings for %s and commas for Ns
  mutate(
    unique_n_str = format(unique_n, big.mark = ",", trim = TRUE),
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
  ) %>%
  # fix some dip value issues
  mutate(
    dip_value = case_when(
      dip_value=="assume F" ~ "no such variable",
      (file_name=="ed_student_enrolment" & var=="difficulty") ~ "no such variable",
      TRUE ~ dip_value
    )
  ) %>%
  # add accent to Metis in BCDS Values
  mutate(
    bcds_value = case_when(
      bcds_value == "Metis" ~ "M\u00e9tis",
      TRUE ~ bcds_value
    )
  )

# filter out status variables now from the full detailed set, not useful
combined_detailed <- combined_detailed %>%
  filter(!var %in% c('gender status', 'dob status')) %>%
  # filter out age
  filter(var != 'age')

combined_detailed


# add survey column name
combined_detailed <- combined_detailed %>%
  left_join(select(combined_list_vars,name,var_main,var_dip,survey_var),by=c("file_name"="name","var"="var_main"))

# remove difficulty from data
combined_detailed <- combined_detailed %>%
  filter(survey_var!="difficulty")

# remove indigenous from data (only keeping Indigenous Identity (distinctions based version))
combined_detailed <- combined_detailed %>%
  filter(survey_var!="indigenous")

# remove indigenous identity unused from data (e.g., nation-related data)
combined_detailed <- combined_detailed %>%
  filter(survey_var!="indigenous identity unused")

# remove indigenous identity overall when doesn't exist in DIP
combined_detailed <- combined_detailed %>%
  filter(!(var=="indigenous identity overall" & var_dip=="no such variable"))

# remove indigenous identity - for now ----
combined_detailed <- combined_detailed %>% 
  filter(!survey_var=='Indigenous Identity')

# add dataset information
combined_detailed <- combined_detailed %>%
  rename(`SAE File Name (Short)`=file_name) %>%
  left_join(dataset_info, by=c("SAE File Name (Short)")) %>%
  mutate(`Data Innovation Program File Name`=str_replace_all(`Data Innovation Program File Name`,"/"," / ")) %>%
  select(-`SAE File Name (Short)`)

# remove datasets with 0 linkage
no_linkage_datasets <- combined_overview %>% filter(in_both_str=="0") %>% pull(File)

combined_detailed <- combined_detailed %>%
  filter(!File %in% no_linkage_datasets)

# from earlier complete, some NAs are filled in, when they do not actually exist - remove them from data
survey_only_zeros <- combined_summary %>%
  filter(cross_status=='Survey only') %>%
  filter(exists_in_dip==TRUE) %>%
  filter(unique_n_str=="0") %>%
  select(File, survey_var,var_dip) %>%
  mutate(no_survey_only_flag="1")

to_fix <- combined_detailed %>%
  left_join(survey_only_zeros,by=c("File","survey_var","var_dip")) %>%
  filter(no_survey_only_flag=="1") %>%
  filter(is.na(dip_value)) %>%
  filter(bcds_value!="Not in Survey") %>%
  select(File, survey_var,var_dip,dip_value,bcds_value,no_survey_only_flag)

combined_detailed <- combined_detailed %>%
  left_join(to_fix,by=c("File","survey_var","var_dip","dip_value","bcds_value")) %>%
  filter(is.na(no_survey_only_flag)) %>% select(-no_survey_only_flag)

# check for missing MASK (comparing to totals provided in summary)
tmp <- combined_detailed %>%
  mutate(
    dip_group = !(dip_value == 'no such variable' | is.na(dip_value)),
    survey_group = !(bcds_value == 'Not in Survey'),
    cross_status =
      case_when(
        dip_group & survey_group ~ 'DIP and survey',
        dip_group & !survey_group ~ 'DIP only',
        !dip_group & survey_group ~ 'Survey only',
        !dip_group & !survey_group ~ 'Neither source',
        TRUE ~ 'MISSED ONE'
      ),
    masked = unique_n_str == 'MASK'
  )

not_masked <-  tmp %>%
  group_by(File, survey_var, var_dip, cross_status) %>%
  summarize(n_masked = sum(masked)) %>%
  filter(n_masked == 1) %>%
  filter(cross_status != 'DIP only') %>%
  ungroup()

not_masked <- not_masked %>%
  left_join(combined_summary, by=c('File','survey_var', 'var_dip', 'cross_status')) %>%
  filter(!mask_flag) %>%
  left_join(tmp, by=c('File','survey_var', 'var_dip', 'cross_status')) %>%
  select(
    File, survey_var, var_dip,dip_value, bcds_value, cross_status, n_masked, mask_flag, unique_n_summary = unique_n_str.x, unique_n_detailed = unique_n_str.y)

not_masked_missing <- not_masked %>%
  filter(cross_status != "Neither source") %>%
  filter(unique_n_detailed != "MASK") %>%
  mutate(missing_mask = "MISSING") %>%
  select(File,survey_var,var_dip,dip_value,bcds_value,missing_mask)

# add additional MASK
combined_detailed <- combined_detailed %>%
  left_join(not_masked_missing,by=c("File","survey_var","var_dip","dip_value","bcds_value")) %>%
  mutate(unique_n_str = ifelse(is.na(missing_mask),unique_n_str,"MASK")) %>%
  mutate(unique_percent_str = ifelse(is.na(missing_mask),unique_percent_str,"MASK")) %>%
  mutate(unique_percent_survey_str = ifelse(is.na(missing_mask),unique_percent_survey_str,"MASK")) %>%
  select(-missing_mask)


# check to see if the sum of masked cells is > 10 compared to summary file
tmp_summ <- combined_summary %>%
  mutate(summary_n = as.numeric(if_else(unique_n_str=='MASK', '0', str_replace_all(unique_n_str,',','')))) %>%
  select(cross_status,File, var_dip, survey_var, summary_n)

tmp_diff <- tmp %>%
  select(dip_value, bcds_value, unique_n_str, var_dip, survey_var, File, cross_status, masked ) %>%
  mutate(detailed_n = as.numeric(if_else(masked, '0', str_replace_all(unique_n_str,',','')))) %>%
  group_by(var_dip, survey_var, File, cross_status) %>%
  mutate(detailed_total = sum(detailed_n)) %>%
  ungroup() %>%
  select(-c(masked, unique_n_str)) %>%
  left_join(tmp_summ) %>%
  mutate(difference = summary_n - detailed_total)

small_diffs <- tmp_diff %>%
  filter(difference > 0 & difference < 10) %>%
  distinct(File, cross_status, survey_var,var_dip) %>%
  filter(cross_status != 'DIP only') %>%
  mutate(small_diffs_flag = "1")

# select next smallest by group to add masking
next_smallest_mask <- tmp %>%
  left_join(small_diffs,by =c("File","survey_var","var_dip","cross_status")) %>%
  filter(small_diffs_flag == "1") %>%
  filter(masked!=TRUE) %>%
  arrange(unique_n) %>%
  group_by(File,survey_var,var_dip,cross_status) %>%
  filter(row_number()==1) %>%
  mutate(add_mask_flag = "ADD MASK") %>%
  ungroup() %>%
  select(File,survey_var,var_dip,dip_value,bcds_value,add_mask_flag)

# add additional MASK
combined_detailed <- combined_detailed %>%
  left_join(next_smallest_mask, by =c("File","survey_var","var_dip","dip_value","bcds_value")) %>%
  mutate(unique_n_str = ifelse(is.na(add_mask_flag),unique_n_str,"MASK")) %>%
  mutate(unique_percent_str = ifelse(is.na(add_mask_flag),unique_percent_str,"MASK")) %>%
  mutate(unique_percent_survey_str = ifelse(is.na(add_mask_flag),unique_percent_survey_str,"MASK")) %>%
  select(-add_mask_flag)


# check masking is sufficient when there are multiple DIP variables for one survey variable
# review list of cases with multiple DIP variables
multi_dip_vars_list <- combined_detailed %>%
  distinct(File,survey_var,var_dip) %>%
  group_by(File,survey_var) %>%
  summarize(n = n()) %>% filter(n>1)

not_masked <- combined_detailed %>%
  select(File, var_dip, survey_var, dip_value, bcds_value, unique_n_str) %>%
  group_by(File, var_dip, survey_var, bcds_value) %>%
  summarize(bcds_masked = sum(unique_n_str=='MASK'), n_possible = n()) %>%
  # look for instances of there being 1 mask along a bcds_value
  # and no masked along the same survey value, for a different var_dip
  group_by(File, survey_var, bcds_value) %>%
  mutate(has_1_mask = any(bcds_masked==1), has_0_mask = any(bcds_masked==0)) %>%
  ungroup() %>%
  #filter(has_1_mask & has_0_mask) %>%
  mutate(problem_case = has_1_mask & has_0_mask)

# how to add masking in: if bcds_masked == 1 and n_possible > 1, mask the next lowest
#                        if bcds_masked ==1 and n_possible = 1, mask 1 in one of the other groups, then repeat

combined_detailed <- combined_detailed %>%
  left_join(not_masked, by=c('File', 'var_dip', 'survey_var', 'bcds_value')) %>%
  mutate(
    case_1 = bcds_masked==1 & n_possible>1,
    case_2 = bcds_masked==1 & n_possible==1
  ) %>%
  group_by(File, survey_var, var_dip, bcds_value) %>%
  arrange(File, survey_var, var_dip, bcds_value, unique_percent_str) %>%
  # only mask the top row of a variable that has a 1 mask, a 0 mask, and bcds_masked==1
  mutate(row_number = row_number()) %>%
  mutate(
    unique_n_str = if_else(problem_case & case_1 & row_number == 1, "MASK", unique_n_str),
    unique_percent_str = if_else(problem_case & case_1 & row_number == 1, "MASK", unique_percent_str),
    unique_percent_survey_str = if_else(problem_case & case_1 & row_number == 1, "MASK", unique_percent_survey_str)
  ) %>%
  # for those with n_possible = 1, grab top row of the other groups
  mutate(
    unique_n_str = if_else(problem_case & case_2 & row_number == 1, "MASK", unique_n_str),
    unique_percent_str = if_else(problem_case & case_2 & row_number == 1, "MASK", unique_percent_str),
    unique_percent_survey_str = if_else(problem_case & case_2 & row_number == 1, "MASK", unique_percent_survey_str)
  ) %>%
  ungroup() %>%
  select(-row_number,-bcds_masked,-n_possible,-has_1_mask,-has_0_mask,-problem_case,-case_1,-case_2)


# check no masking amount by bcds variable < 10 when multiple dip variables
# get updated mask count
tmp <- combined_detailed %>%
  mutate(masked = unique_n_str == 'MASK')

not_masked <- combined_detailed %>%
  mutate(unique_n_updated_numeric=ifelse(unique_n_str=="MASK",0,unique_n)) %>%
  select(File, var_dip, survey_var, dip_value, bcds_value, unique_n_str,unique_n_updated_numeric) %>%
  group_by(File, var_dip, survey_var,bcds_value) %>%
  summarize(bcds_masked = sum(unique_n_str=='MASK'), sum = sum(unique_n_updated_numeric)) %>%
  group_by(File, survey_var, bcds_value) %>%
  mutate(has_any_mask = any(bcds_masked>0), has_0_mask = any(bcds_masked==0)) %>%
  ungroup() %>%
  mutate(problem_case = has_any_mask & has_0_mask) %>%
  filter(problem_case) %>%
  mutate(non_masked_grp = bcds_masked==0) %>%
  select(-has_any_mask,-has_0_mask,-problem_case)

small_diffs <- not_masked %>%
  group_by(File, survey_var,bcds_value) %>%
  distinct() %>%
  mutate(diff = ifelse(non_masked_grp,NA,(sum[non_masked_grp]-sum[!non_masked_grp]))) %>%
  filter(diff < 10) %>%
  mutate(small_diffs_flag = "1")

# select next smallest by group to add masking
next_smallest_mask <- tmp %>%
  left_join(small_diffs,by =c("File","survey_var","var_dip","bcds_value")) %>%
  filter(small_diffs_flag == "1") %>%
  filter(masked!=TRUE) %>%
  arrange(unique_n) %>%
  group_by(File,survey_var,var_dip,bcds_value) %>%
  filter(row_number()==1) %>%
  mutate(add_mask_flag = "ADD MASK") %>%
  ungroup() %>%
  select(File,survey_var,var_dip,dip_value,bcds_value,add_mask_flag)

# add additional MASK
combined_detailed <- combined_detailed %>%
  left_join(next_smallest_mask, by =c("File","survey_var","var_dip","dip_value","bcds_value")) %>%
  mutate(unique_n_str = ifelse(is.na(add_mask_flag),unique_n_str,"MASK")) %>%
  mutate(unique_percent_str = ifelse(is.na(add_mask_flag),unique_percent_str,"MASK")) %>%
  mutate(unique_percent_survey_str = ifelse(is.na(add_mask_flag),unique_percent_survey_str,"MASK")) %>%
  select(-add_mask_flag)

# remove 'Not in Survey' results from data - detailed to be linked data only
combined_detailed <- combined_detailed %>%
  filter(bcds_value != "Not in Survey")

# remove unused columns
combined_detailed <- combined_detailed %>%
  select(-var,-unique_n,-unique_percent,-unique_percent_survey,-Notes)

# arrange alphabetically - data provider first, then Dataset, then File, then variables
combined_detailed <- combined_detailed %>%
  dplyr::arrange(`Data Provider/Ministry`,Dataset,File,survey_var,var_dip,dip_value,bcds_value)

# Write the combined data to a new CSV file for review
write_excel_csv(
  combined_detailed,
  safepaths::use_network_path(
    "2023 ARDA BCDS Data Evaluation/data_for_dashboard/combined/combined_detailed.csv"
  )
)

# write combined data to rds for use by app
saveRDS(combined_detailed, "app/data/combined_detailed.rds")

# write data for catalogue
# rename and order columns
linked_individual_demographics <- combined_detailed %>%
  # remove extra spacing for catalogue
  mutate(`Data Innovation Program File Name`=str_replace_all(`Data Innovation Program File Name`," / ","/")) %>%
  janitor::clean_names() %>%
  select(any_of(names(janitor::clean_names(dataset_info))),
         "survey_variable" = survey_var,
         "dip_variable" = var_dip,
         "value_in_dip" = dip_value,
         "value_in_survey" = bcds_value,
         "unique_ids_in_dip_file" = unique_n_str,
         "percent_of_unique_ids" = unique_percent_str,
         "percent_of_survey_unique_ids" = unique_percent_survey_str,
         everything()
  )

write_excel_csv(
  linked_individual_demographics,
  safepaths::use_network_path(
    "2023 ARDA BCDS Data Evaluation/data_for_catalogue/bcds-dip-linkage-rates-data-detailed.csv"
  )
)

