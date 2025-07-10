# Set working directory and load necessary libraries
setwd("/Users/batume/Documents/R/GAL_git/prep/FIS")

library(ramlegacy)
library(dplyr)

# Load RAM database
ram_data <- load_ramlegacy(version = "4.44")
colnames(ram_data$timeseries_values_views)

# Define the correct year column based on inspection
year_col <- "year"  

# Step 1: Filter stock data for Galicia (Northeast Atlantic, Spain, ICES)
galicia_ram_filtered <- ram_data$stock %>%
  filter(grepl("Northeast Atlantic", region, ignore.case = TRUE) | 
           grepl("Spain", areaid, ignore.case = TRUE) |
           grepl("ICES", areaid, ignore.case = TRUE)) %>%
  filter(grepl("VII", areaid)) # Keep only Subarea VII

# Step 2: Merge with timeseries data to get TSN and all relevant columns
tsn_per_year <- ram_data$timeseries_values_views %>%
  inner_join(galicia_ram_filtered, by = "stockid") %>%
  select(all_of(year_col), tsn, everything())  # Keep all columns

# Step 3: Inspect and summarize results
head(tsn_per_year)
summary(tsn_per_year)

# Step 4: Create a frequency table for TSN occurrences per year
table(tsn_per_year[[year_col]])



year_col <- "year" 

# Define the variables to keep
selected_vars <- c("year", "tsn", "stockid", "scientificname", 
                   "commonname", "areaid", "stocklong.y", 
                   "region", "inmyersdb", "myersstockid")

# Filter tsn_per_year for years between 2003 and 2022 & keep only selected variables
tsn_per_year_filtered <- tsn_per_year %>%
  filter(between(.data[[year_col]], 2003, 2022)) %>%
  select(all_of(selected_vars))  

head(tsn_per_year_filtered)
summary(tsn_per_year_filtered)

# Check TSN frequency per year
table(tsn_per_year_filtered[[year_col]])



# Convert TSN to numeric (handling potential non-numeric values)
tsn_per_year_filtered <- tsn_per_year_filtered %>%
  mutate(tsn = as.numeric(tsn))  # Convert to numeric

# Summarize total TSN (tons) per year per stockid while keeping other variables
tsn_summary <- tsn_per_year_filtered %>%
  group_by(year, stockid) %>%
  summarise(
    total_tons = sum(tsn, na.rm = TRUE),  # Sum TSN per stock per year
    scientificname = first(scientificname),  # Keep species name
    commonname = first(commonname),  # Keep common name
    areaid = first(areaid),  # Keep area ID
    stocklong = first(stocklong.y),  # Keep full stock name
    region = first(region),  # Keep region info
    inmyersdb = first(inmyersdb),  # Keep database flag
    myersstockid = first(myersstockid),  # Keep Myers stock ID
    .groups = "drop"
  )

# Display the summarized results
head(tsn_summary)
summary(tsn_summary)

