# Load necessary libraries
library(dplyr)
library(readr)
library(readr)

# Define column names
column_names <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", 
                  "Admi_area", "market", "kg", "euros", "price_per_kilo")

# Define years of datasets
years <- 2003:2022

# Read CSV files and store in a list
datasets <- lapply(years, function(year) {
  file_path <- paste0("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca", year, ".csv")
  if (file.exists(file_path)) {
    df <- read.csv(file_path, header=FALSE, sep=";", col.names=column_names)
    df$year <- year  # Add year column
    return(df)
  } else {
    return(NULL)
  }
})

# Remove NULL values (for missing years) and bind datasets into one dataframe
combined_data <- bind_rows(datasets)

# Ensure numeric conversion (fixing potential character encoding issues)
combined_data <- combined_data %>%
  mutate(
    kg = as.numeric(gsub(",", ".", kg)),  
    euros = as.numeric(gsub(",", ".", euros))
  )

# Summarize total kg and euros per species and year

total_summary_PESCA <- combined_data %>%
  group_by(year, Galician_name, FAOcode) %>%  # Add FAOcode to group_by
  summarise(
    total_kg = sum(kg, na.rm = TRUE),
    total_euros = sum(euros, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(year))


#Check FAO CODES https://www.fao.org/fishery/en/collection/asfis/en

asfis_raw <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/ASFIS_sp_2024.csv", encoding = "Latin1")
colnames(asfis_raw)

asfis <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/ASFIS_sp_2024.csv", encoding = "Latin1") %>%
  select(
    FAOcode = Alpha3_Code,
    Scientific_name = Scientific_Name,
    English_name = English_name,
    Family, Order.or.higher.taxa
  )


head(asfis)

merged_data <- total_summary_PESCA %>%
  left_join(asfis, by = "FAOcode")

head(merged_data)

# Missing species: CTS - Venerupis corrugata , HK0 - Merluccius merluccius*, LA5 - Saccorhiza polyschides, LI0 - Molva molva*, BL0 - X, PO0 - Brama brama*


write.csv(merged_data, "/Users/batume/Documents/R/GAL_git/prep/FIS/total_summary_FAO_PESCADEGALICIA.csv", row.names = FALSE)

