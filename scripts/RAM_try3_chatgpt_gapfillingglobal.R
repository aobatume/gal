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
# Step 3: Extract timeseries data (catch and biomass) for these stocks
galicia_timeseries <- tryCatch({
  ram_data$timeseries_values_views %>%
    filter(stockid %in% galicia_stocks$stockid) %>%
    select(stockid, year, TCbest, TBbest, TBdivTBmsy, SSBdivSSBmsy)
}, error = function(e) {
  cat("Error retrieving timeseries data:", e$message, "\n")
  NULL
})
if (is.null(galicia_timeseries)) stop("Failed to retrieve timeseries data. Exiting the script.")

# ---------------------------------------------------------
# Step 4: Compute B/Bmsy values
galicia_timeseries <- galicia_timeseries %>%
  mutate(b_bmsy = ifelse(!is.na(TBdivTBmsy), TBdivTBmsy, SSBdivSSBmsy)) %>%
  select(-TBdivTBmsy, -SSBdivSSBmsy)

# ---------------------------------------------------------
# Step 5: Merge timeseries data with stock info
galicia_data <- galicia_timeseries %>%
  left_join(galicia_stocks, by = "stockid")

# ---------------------------------------------------------
# Step 6: Filter out forage fish catch used for non-human purposes
galicia_data <- galicia_data %>%
  mutate(forager = ifelse(commonname %in% c("Anchovy", "Sardine", "Herring", "Menhaden"), TRUE, FALSE)) %>%
  mutate(TCbest = ifelse(forager, TCbest * 0.1, TCbest))

# ---------------------------------------------------------
# Step 7: Apply Regression-Based Gapfilling for Missing B/Bmsy
galicia_data <- galicia_data %>%
  group_by(stockid) %>%
  arrange(year) %>%
  mutate(
    b_bmsy = ifelse(
      is.na(b_bmsy) & sum(!is.na(b_bmsy)) >= 5, 
      {
        non_na_data <- filter(., !is.na(b_bmsy))
        if (nrow(non_na_data) >= 5) {
          model <- lm(b_bmsy ~ year, data = non_na_data)
          pred <- predict(model, newdata = .)
          pmax(pred, 0.0026)  # Ensure no values go below the observed minimum
        } else {
          NA  # If not enough data, keep NA
        }
      }, 
      b_bmsy
    )
  ) %>%
  ungroup()

# ---------------------------------------------------------
# Step 8: Summarize data by year, scientific name, group, and common name
galicia_summary <- galicia_data %>%
  group_by(year, scientificname, group, commonname) %>%
  summarise(
    total_catch = sum(as.numeric(TCbest), na.rm = TRUE),
    total_biomass = sum(as.numeric(TBbest), na.rm = TRUE),
    avg_b_bmsy = mean(b_bmsy, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(year, scientificname, group)

# ---------------------------------------------------------
# Step 9: Save the final summary
write.csv(galicia_summary, "Galicia_Fisheries_Summary.csv", row.names = FALSE)

head(galicia_summary)
table(galicia_summary$commonname)

head(galicia_summary$avg_b_bmsy)
