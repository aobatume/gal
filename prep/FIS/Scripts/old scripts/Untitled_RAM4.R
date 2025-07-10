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
# Ensure that galicia_timeseries, galicia_stocks, and species_data are properly merged.
galicia_data <- galicia_timeseries %>%
  left_join(galicia_stocks, by = "stockid") %>%
  left_join(species_data, by = "scientificname")

# Ensure that all the variables are present
colnames(galicia_data)

# View the final dataset
View(galicia_data)

# Check for missing data after merging
summary(galicia_data)

# Filter rows where TBbest is NA and get the scientific names
missing_TBbest <- galicia_data %>%
  filter(is.na(TBbest)) %>%
  select(scientificname)

# View the result
table(missing_TBbest)
