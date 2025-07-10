# Load necessary libraries
library(readxl)
library(dplyr)
library(tidyr)

# Read the data
df <- read_excel("/Users/batume/Documents/R/GAL_git/prep/FIS/ICESCatchDataset2006-2022.xlsx", sheet = "Dataset")

colnames(df)[1] <- "FAOcode"

# Filter for Spain (SP) and Area 27.8.c (Galicia)
galicia_df <- df %>%
  filter(Country == "ES", Area == "27.8.c"| Area=="27.9.a")

# Pivot longer: gather catch values for all years
catch_long <- galicia_df %>%
  pivot_longer(
    cols = starts_with("20"),  # assuming year columns start with "20"
    names_to = "Year",
    values_to = "Catch"
  )

# Clean types
catch_long <- catch_long %>%
  mutate(
    Year = as.integer(Year),
    Catch = as.numeric(Catch)
  ) %>%
  drop_na(Year, Catch)


head(catch_long)

filtered_ices_stocks <- catch_long %>%
  filter(Catch != 0)

