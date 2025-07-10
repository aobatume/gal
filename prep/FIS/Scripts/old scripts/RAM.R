library(ramlegacy)
library(dplyr)
library(readr)

#setwd("/Users/batume/Documents/R/GAL_git/FIS") 

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
# We filter by checking if 'region' or 'areaid' contain keywords.
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

# ---------------------------------------------------------
# Step 2a: Create groups based on areaid patterns
# You provided these criteria. Adjust the patterns as needed.
galicia_stocks <- galicia_stocks %>%
  mutate(group = case_when(
    grepl("VIIIc|IXa", areaid) ~ 1,                         # Group 1: Areas VIIIc or IXa
    grepl("VIIIa|VIIIb|VIIId|VIIIe|IXb", areaid) ~ 2,         # Group 2: Areas VIIIa, VIIIb, VIIId, VIIIe, IXb
    grepl("VII", areaid) ~ 3,                                 # Group 3: Area VII
    TRUE ~ 4                                               # Group 4: All other areas
  ))

# Optional: inspect the filtered stocks
cat("Number of stocks identified:", n_distinct(galicia_stocks$stockid), "\n")
head(galicia_stocks)
summary(galicia_stocks)

# ---------------------------------------------------------
# Step 3: Extract timeseries data (catch and biomass) for these stocks
# We assume that:
#   - TCbest represents the best catch estimate (in tons)
#   - TBbest represents the best total biomass estimate (in tons)
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
# Step 4: Merge timeseries data with stock info to add species names and group info
galicia_data <- galicia_timeseries %>%
  left_join(galicia_stocks, by = "stockid")

# Optional: inspect the merged data
head(galicia_data)

# ---------------------------------------------------------
# Step 5: Summarize data by year, scientific name, group, and common name
# Calculate the total catch and biomass for each combination.
galicia_summary <- galicia_data %>%
  group_by(year, scientificname, group, commonname) %>%
  summarise(
    total_catch = sum(as.numeric(TCbest), na.rm = TRUE),
    total_biomass = sum(as.numeric(TBbest), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(year, scientificname, group)

# ---------------------------------------------------------
# Step 6: Inspect and save the final summary
head(galicia_summary)
summary(galicia_summary)

# Save the summary to a CSV file for use in OHI assessments
write.csv(galicia_summary, "Galicia_Fisheries_Summary.csv", row.names = FALSE) 

table(galicia_summary$commonname)
