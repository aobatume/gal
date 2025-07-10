library(ramlegacy)
library(dplyr)
library(readr)
library(zoo)
library(rfishbase)


#http://ohi-science.org/ohiprep_v2020/globalprep/fis/v2020/catch_data_prep.html
getwd()


# ---------------------------------------------------------
# Step 1: Load RAM Legacy database with error handling
ram_data <- tryCatch({
  load_ramlegacy()
}, error = function(e) {
  cat("Error loading RAM data:", e$message, "\n")
  NULL
})
if (is.null(ram_data)) stop("Failed to load RAM data. Exiting the script.")

# ---------------------------------------------------------
# Step 2: Filter stock data for Galicia (Northeast Atlantic, Spain, ICES)
galicia_stocks <- tryCatch({
  ram_data$stock %>%
    filter(grepl("Northeast Atlantic", region, ignore.case = TRUE) | 
             grepl("Spain", areaid, ignore.case = TRUE) |
             grepl("ICES", areaid, ignore.case = TRUE)) %>%
    select(stockid, areaid, stocklong, scientificname, commonname)
}, error = function(e) {
  cat("Error filtering stock data for Galicia:", e$message, "\n")
  NULL
})
if (is.null(galicia_stocks)) stop("Failed to filter stock data. Exiting the script.")

any(duplicated(galicia_stocks$stockid))

# ---------------------------------------------------------
# Step 2a: Create groups based on areaid patterns
galicia_stocks <- galicia_stocks %>%
  mutate(group = case_when(
    grepl("VIIIc|IXa", areaid) ~ 1,                         
    grepl("VIIIa|VIIIb|VIIId|VIIIe|IXb", areaid) ~ 2,       
    grepl("VII", areaid) ~ 3,                               
    TRUE ~ 4                                               
  ))

# ---------------------------------------------------------
# Step 3: Load species resilience data from FishBase
# This queries FishBase for species resilience based on the scientific names in our dataset.

species_list <- unique(galicia_stocks$scientificname)
species_data <- species(species_list, fields = c("Species", "Vulnerability", "LongevityWild", "Length"))

species_data <- species_data %>%
  rename(scientificname = Species)

# Convert Vulnerability into a Resilience Score
species_data <- species_data %>%
  mutate(resilience_score = case_when(
    Vulnerability <= 20  ~ 0.8,  # High resilience (low vulnerability)
    Vulnerability <= 40  ~ 0.6,  # Medium resilience
    Vulnerability <= 60  ~ 0.4,  # Low resilience
    TRUE                 ~ 0.2   # Very low resilience (high vulnerability)
  ))

# Merge resilience data into the stock dataset
galicia_stocks <- left_join(galicia_stocks, species_data, by = "scientificname")


# ---------------------------------------------------------
# Step 4: Extract timeseries data (catch and biomass) for these stocks
galicia_timeseries <- tryCatch({
  ram_data$timeseries_values_views %>%
    filter(stockid %in% galicia_stocks$stockid) %>%
    select(stockid, year, TCbest, TBbest)
}, error = function(e) {
  cat("Error retrieving timeseries data:", e$message, "\n")
  NULL
})
if (is.null(galicia_timeseries)) stop("Failed to retrieve timeseries data. Exiting the script.")

# ---------------------------------------------------------
# Step 5: Merge timeseries data with stock info and resilience scores

galicia_data <- galicia_timeseries %>%
  left_join(galicia_stocks, by = "stockid")


# ---------------------------------------------------------
# Step 6: Data Cleaning and Processing
# Handle NA values and apply resilience adjustments
galicia_data <- galicia_data %>%
  mutate(
    TCbest = ifelse(is.na(TCbest), 0, TCbest),
    TBbest = ifelse(is.na(TBbest), 0, TBbest),
    adjusted_catch = TCbest * resilience_score
  )


head(galicia_data)
# ---------------------------------------------------------
# Step 7: Interpolation/Smoothing for Missing Years
# Apply rolling mean to smooth catch data
galicia_data <- galicia_data %>%
  group_by(stockid) %>%
  arrange(year) %>%
  mutate(smoothed_catch = rollapply(adjusted_catch, width = 3, FUN = mean, align = 'right', fill = NA, na.rm = TRUE)) %>%
  ungroup()

# ---------------------------------------------------------
# Step 8: Summarize data by year, scientific name, group, and common name
galicia_summary <- galicia_data %>%
  group_by(year, scientificname, group, commonname) %>%
  summarise(
    total_catch = sum(TCbest, na.rm = TRUE),
    total_biomass = sum(TBbest, na.rm = TRUE),
    total_adjusted_catch = sum(adjusted_catch, na.rm = TRUE),
    avg_smoothed_catch = mean(smoothed_catch, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(year, scientificname, group)

head(galicia_summary)
table(galicia_summary$scientificname)

length(unique(galicia_summary$scientificname))
