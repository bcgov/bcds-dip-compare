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

# FOR /RUN FILES

# first get the run .csvs
directory <- "U:/Operations/Data Science and Analytics/2023 ARDA BCDS Data Evaluation/bcds-dip-compare/bcds-dip-compare/app/data/run/"

# Get a list of all CSV files in the directory
file_list <- list.files(pattern = "\\.csv$")
file_list

# Get a list of all CSV files in the directory
file_list <- list.files(path = directory, pattern = "\\.csv$", full.names = TRUE)

# Read all CSV files, add a column for the filename, and combine them into one data frame
combined_run <- map_dfr(file_list, ~ {
  file_name <- basename(.x)
  data <- read_csv(.x)
  data <- mutate(data, file_name = str_split(file_name, "_")[[1]][1])
  return(data)
})

combined_run

combined_run$unique_n <- as.numeric(combined_run$unique_n)
combined_run$unique_percent <- as.numeric(combined_run$unique_percent)
combined_run$unique_percent_survey <- as.numeric(combined_run$unique_percent_survey)

combined_run <- combined_run %>%
  filter(var != "TOTAL")

# Write the combined data to a new CSV file for review
write_csv(combined_run, "U:/Operations/Data Science and Analytics/2023 ARDA BCDS Data Evaluation/bcds-dip-compare/bcds-dip-compare/app/data/combined/combined_run.csv")


# FOR /SUMMARY FILES

# first get the summary .csvs
directory <- "U:/Operations/Data Science and Analytics/2023 ARDA BCDS Data Evaluation/bcds-dip-compare/bcds-dip-compare/app/data/summary/"

# Get a list of all CSV files in the directory
file_list <- list.files(pattern = "\\.csv$")
file_list

# Get a list of all CSV files in the directory
file_list <- list.files(path = directory, pattern = "\\.csv$", full.names = TRUE)
file_list

# Read all CSV files, add a column for the filename, and combine them into one data frame
combined_summary <- map_dfr(file_list, ~ {

  file_name <- basename(.x)
  data <- read_csv(.x)

  # Convert necessary columns from character to double
  convert_to_double <- c("unique_n", "unique_percent", "unique_percent_survey")  # Replace with your column names
  data[, convert_to_double] <- lapply(data[, convert_to_double], as.numeric)

  data <- mutate(data, file_name = str_split(file_name, "_")[[1]][1])

  return(data)
})

combined_summary

# Write the combined data to a new CSV file for review
write_csv(combined_summary, "U:/Operations/Data Science and Analytics/2023 ARDA BCDS Data Evaluation/bcds-dip-compare/bcds-dip-compare/app/data/combined/combined_summary.csv")
