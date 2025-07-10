library(ramlegacy)
library(dplyr)
library(readr)
library(zoo)
library(rfishbase)
library(tidyr)
library(stringr)

# ---------------------------------------------------------
# Step 1: Load RAM Legacy and FAO Data
ram_data <- tryCatch({
  load_ramlegacy()
}, error = function(e) {
  cat("Error loading RAM data:", e$message, "\n")
  NULL
})
if (is.null(ram_data)) stop("Failed to load RAM data. Exiting the script.")

# Load FAO fisheries data for Spain (extracted from FishStatJ)
fao_catch <- read_csv("/Users/batume/Documents/R/GAL_git/prep/FIS/FAO_SP.csv")

# ---------------------------------------------------------
# Step 2: Filter stock data for Galicia (Northeast Atlantic, Spain, ICES)
galicia_stocks <- ram_data$stock %>%
  filter(grepl("Northeast Atlantic", region, ignore.case = TRUE) | 
           grepl("Spain", areaid, ignore.case = TRUE) |
           grepl("ICES", areaid, ignore.case = TRUE)) %>%
  select(stockid, areaid, stocklong, scientificname, commonname)

# ---------------------------------------------------------
# Step 2a: Assign Area-based Groupings
galicia_stocks <- galicia_stocks %>%
  mutate(group = case_when(
    grepl("VIIIc|IXa", areaid) ~ 1,
    grepl("VIIIa|VIIIb|VIIId|VIIIe|IXb", areaid) ~ 2,
    grepl("VII", areaid) ~ 3,
    TRUE ~ 4
  ))

# ---------------------------------------------------------
# Step 3: Load species resilience data from FishBase
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
# Step 4: Extract Catch and Biomass Timeseries Data
galicia_timeseries <- ram_data$timeseries_values_views %>%
  filter(stockid %in% galicia_stocks$stockid) %>%
  select(stockid, year, TCbest, TBbest)

# ---------------------------------------------------------
# Step 5: Merge Timeseries Data with Stocks & Resilience

galicia_data <- galicia_timeseries %>%
  left_join(galicia_stocks, by = "stockid") %>%
  mutate(
    TCbest = ifelse(is.na(TCbest), NA, TCbest),  # Allow NA for gap-filling
    TBbest = ifelse(is.na(TBbest), NA, TBbest),
    adjusted_catch = TCbest * resilience_score
  )

# Merge FAO catch data with Galicia stocks
galicia_data <- galicia_data %>%
  left_join(fao_catch, by = c("stockid" = "Stock_ID", "year" = "Year"))

# ---------------------------------------------------------
# Step 6: Apply 5-Year Running Mean for Smoothing
galicia_data <- galicia_data %>%
  group_by(stockid) %>%
  arrange(year) %>%
  mutate(smoothed_catch = rollapply(adjusted_catch, width = 5, FUN = mean, align = 'right', fill = NA, na.rm = TRUE)) %>%
  ungroup()

# ---------------------------------------------------------
# Step 7: Integrate CMSY & RAM Data for B/Bmsy Calculation
cmsy_data <- read_csv("cmsy_bbmsy.csv")
ram_bmsy <- read_csv("ram_bmsy.csv")

galicia_data <- galicia_data %>%
  left_join(ram_bmsy, by = c("stockid" = "stock_id", "year")) %>%
  left_join(cmsy_data, by = c("stockid" = "stock_id", "year")) %>%
  mutate(
    b_bmsy = ifelse(!is.na(ram_bmsy), ram_bmsy, cmsy_bbmsy)  # Prioritize RAM over CMSY
  )

# ---------------------------------------------------------
# Step 8: Area-Weighted Summarization
galicia_summary <- galicia_data %>%
  group_by(year, scientificname, group, commonname, areaid) %>%
  summarise(
    total_catch = sum(TCbest, na.rm = TRUE),
    total_biomass = sum(TBbest, na.rm = TRUE),
    total_adjusted_catch = sum(adjusted_catch, na.rm = TRUE),
    avg_smoothed_catch = mean(smoothed_catch, na.rm = TRUE),
    avg_b_bmsy = mean(b_bmsy, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(year, scientificname, group)

# ---------------------------------------------------------
# Save Processed Data
write_csv(galicia_summary, "galicia_ohi_summary.csv")

head(galicia_summary)
