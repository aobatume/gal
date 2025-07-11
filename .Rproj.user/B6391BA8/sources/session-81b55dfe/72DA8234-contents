library(ramlegacy)
library(dplyr)
library(readr)
library(zoo)
library(rfishbase)

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

# Check for duplicates
any(duplicated(galicia_stocks$stockid))  # Should be FALSE ideally

# ---------------------------------------------------------
# Step 2a: Tag ICES groups
galicia_stocks <- galicia_stocks %>%
  mutate(group = case_when(
    grepl("VIIIc|IXa", areaid) ~ 1,
    grepl("VIIIa|VIIIb|VIIId|VIIIe|IXb", areaid) ~ 2,
    grepl("VII", areaid) ~ 3,
    TRUE ~ 4
  ))

# ---------------------------------------------------------
# Step 3: Load species resilience from FishBase
species_list <- unique(galicia_stocks$scientificname)
species_data <- species(species_list, fields = c("Species", "Vulnerability", "LongevityWild", "Length")) %>%
  rename(scientificname = Species) %>%
  mutate(resilience_score = case_when(
    Vulnerability <= 20  ~ 0.8,
    Vulnerability <= 40  ~ 0.6,
    Vulnerability <= 60  ~ 0.4,
    TRUE                 ~ 0.2
  ))

# Optionally, load resilience from file:
# resilience_lookup <- read_csv("taxon_resilience_lookup.csv")

galicia_stocks <- left_join(galicia_stocks, species_data, by = "scientificname")

# ---------------------------------------------------------
# Step 4: Get catch/biomass time series
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
# Step 5: Merge all data
galicia_data <- galicia_timeseries %>%
  left_join(galicia_stocks, by = "stockid")

# ---------------------------------------------------------
# Step 6: Trim leading zero-catch years
galicia_data <- galicia_data %>%
  group_by(stockid) %>%
  arrange(year) %>%
  mutate(cum_catch = cumsum(ifelse(is.na(TCbest), 0, TCbest))) %>%
  filter(cum_catch > 0 | year == min(year[cum_catch > 0])) %>%
  ungroup()

# ---------------------------------------------------------
# Step 7: Clean NA values & apply resilience score
galicia_data <- galicia_data %>%
  mutate(
    TCbest = ifelse(is.na(TCbest), 0, TCbest),
    TBbest = ifelse(is.na(TBbest), 0, TBbest),
    adjusted_catch = TCbest * resilience_score
  )

#Step 8 was a filtering step that was not needed. 

# ---------------------------------------------------------
# Step 9: Smooth catch with rolling average
galicia_data <- galicia_data %>%
  group_by(stockid) %>%
  arrange(year) %>%
  mutate(smoothed_catch = rollapply(adjusted_catch, width = 3, FUN = mean, align = 'right', fill = NA, na.rm = TRUE)) %>%
  ungroup()

# ---------------------------------------------------------
# Step 10: Summarize by year/species/group
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


str(galicia_summary)


length(unique(galicia_summary$scientificname))
