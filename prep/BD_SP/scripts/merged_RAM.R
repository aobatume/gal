# ================================================================
# Galicia Fisheries Goal (FP-FIS) Assessment - species tracking and adapted penalty system
# ================================================================

library(ramlegacy)
library(dplyr)
library(readr)
library(zoo)
library(rfishbase)
library(tidyr)
library(stringr)
library(broom)
library(ggplot2)

# ---------------------------
# 1. CONFIGURATION
# ---------------------------
YEAR_RANGE <- 2018:2022  # Assessment period
TREND_YEARS <- 5         # Years for trend calculation
MIN_CATCH <- 10          # Minimum annual catch threshold (tons)

# ---------------------------
# 2. DATA LOADING
# ---------------------------
# 2a. Load RAM Legacy Database
ram_data <- load_ramlegacy()

# 2b. Load Pesca de Galicia data (example structure)
# Assuming this contains catch data and possibly assessments
pesca_galicia <- read_csv("pesca_galicia_data.csv") %>%
  mutate(source = "pesca_galicia")

# 2c. Load ICES stock assessments
ices_assessments <- read_csv("ices_stock_assessments.csv") %>%
  mutate(source = "ices")

# 2d. Load FAO catch data
fao_catch <- read_csv("FAO_Galicia_Catch.csv") %>%
  mutate(source = "fao")

# ---------------------------
# 3. STOCK PROCESSING
# ---------------------------
# 3a. Filter Galicia-relevant stocks from RAM
galicia_stocks <- ram_data$stock %>%
  filter(
    grepl("Northeast Atlantic", region, ignore.case = TRUE) |
      grepl("Spain|Galicia", areaid, ignore.case = TRUE) |
      grepl("ICES", areaid, ignore.case = TRUE)
  ) %>%
  select(stockid, areaid, scientificname, commonname)

# 3b. Add species from other sources
additional_species <- bind_rows(
  pesca_galicia %>% distinct(scientificname),
  ices_assessments %>% distinct(scientificname),
  fao_catch %>% distinct(scientificname)
) %>% filter(!scientificname %in% galicia_stocks$scientificname)

galicia_stocks <- bind_rows(
  galicia_stocks,
  tibble(
    scientificname = additional_species$scientificname,
    source = "external"
  )
)

# 3c. Assign ICES area groups
galicia_stocks <- galicia_stocks %>%
  mutate(group = case_when(
    grepl("27\\.8\\.c|27\\.9\\.a", areaid) ~ 1,
    grepl("27\\.8\\.a|27\\.8\\.b|27\\.8\\.d|27\\.8\\.e|27\\.9\\.b", areaid) ~ 2,
    grepl("27\\.7", areaid) ~ 3,
    TRUE ~ 4
  ))

# 3d. Get resilience scores from FishBase
species_list <- unique(galicia_stocks$scientificname)
resilience_data <- species(species_list, fields = c("Species", "Vulnerability")) %>%
  rename(scientificname = Species) %>%
  mutate(
    resilience_score = case_when(
      Vulnerability <= 20 ~ 0.8,
      Vulnerability <= 40 ~ 0.6,
      Vulnerability <= 60 ~ 0.4,
      TRUE ~ 0.2
    )
  ) %>%
  select(-Vulnerability)

# 3e. Add resilience to stocks
galicia_stocks <- galicia_stocks %>%
  left_join(resilience_data, by = "scientificname")

# ---------------------------
# 4. CATCH DATA PROCESSING
# ---------------------------
# 4a. Combine all catch data sources
catch_data <- bind_rows(
  # RAM data
  ram_data$timeseries_values_views %>%
    filter(stockid %in% galicia_stocks$stockid) %>%
    select(stockid, year, catch = TCbest) %>%
    mutate(source = "ram"),
  
  # Pesca de Galicia
  pesca_galicia %>%
    select(stockid, year, catch, scientificname) %>%
    mutate(source = "pesca_galicia"),
  
  # FAO data
  fao_catch %>%
    select(stockid, year, catch, scientificname) %>%
    mutate(source = "fao")
) %>%
  group_by(stockid, year) %>%
  # Prioritize local data over RAM over FAO
  arrange(match(source, c("pesca_galicia", "ram", "fao"))) %>%
  slice(1) %>%
  ungroup()

# 4b. Gapfill catch data
catch_data <- catch_data %>%
  group_by(stockid) %>%
  arrange(year) %>%
  mutate(
    # Linear interpolation for internal gaps
    catch_gapfilled = na.approx(catch, na.rm = FALSE),
    # Trim leading NAs
    first_valid = min(which(!is.na(catch_gapfilled))),
    catch_gapfilled = if_else(row_number() >= first_valid, catch_gapfilled, NA_real_)
  ) %>%
  filter(!is.na(catch_gapfilled)) %>%
  select(-first_valid)

# ---------------------------
# 5. B/BMSY INTEGRATION
# ---------------------------
# Priority: ICES > RAM > CMSY (approximated from resilience)
bbmsy_data <- bind_rows(
  # ICES assessments (highest priority)
  ices_assessments %>%
    select(stockid, year, bbmsy, scientificname) %>%
    mutate(source = "ices"),
  
  # RAM data
  ram_data$timeseries_values_views %>%
    filter(stockid %in% galicia_stocks$stockid) %>%
    select(stockid, year, bbmsy = BdivBmsytouse, scientificname) %>%
    mutate(source = "ram"),
  
  # Resilience-based approximation (lowest priority)
  galicia_stocks %>%
    select(scientificname) %>%
    distinct() %>%
    mutate(
      bbmsy = case_when(
        resilience_score == 0.8 ~ 1.2,  # High resilience
        resilience_score == 0.6 ~ 1.0,   # Medium
        resilience_score == 0.4 ~ 0.65,  # Low
        resilience_score == 0.2 ~ 0.3    # Very low
      ),
      source = "resilience_approx"
    )
) %>%
  arrange(stockid, year) %>%
  group_by(stockid, year) %>%
  # Take highest priority source
  arrange(match(source, c("ices", "ram", "resilience_approx"))) %>%
  slice(1) %>%
  ungroup()

# ---------------------------
# 6. TAXONOMIC PENALTY SYSTEM (ADAPTED)
# ---------------------------
# Simplified version using available data
galicia_stocks <- galicia_stocks %>%
  mutate(
    # Determine taxonomic level from scientific name
    taxonomic_level = case_when(
      # If name has two words (Genus species)
      str_count(scientificname, "\\S+") == 2 ~ "species",
      # If single word that's capitalized (Genus only)
      str_detect(scientificname, "^[A-Z][a-z]+$") ~ "genus",
      # If ends with "idae" (family)
      str_detect(scientificname, "idae$") ~ "family",
      # Common higher taxa patterns
      str_detect(scientificname, "iformes$") ~ "order",
      TRUE ~ "higher"
    ),
    # Simplified penalty weights
    penalty = case_when(
      taxonomic_level == "species" ~ 1.0,
      taxonomic_level == "genus" ~ 0.9,
      taxonomic_level == "family" ~ 0.8,
      taxonomic_level == "order" ~ 0.5,
      TRUE ~ 0.3  # Default for higher taxa
    )
  )

# ---------------------------
# 7. SPECIES TRACKING
# ---------------------------
# Create a species tracking table
species_used <- bbmsy_data %>%
  left_join(galicia_stocks, by = c("stockid", "scientificname")) %>%
  left_join(catch_data, by = c("stockid", "year")) %>%
  filter(year %in% YEAR_RANGE, catch_gapfilled >= MIN_CATCH) %>%
  group_by(scientificname, commonname, source_bbmsy = source.x, source_catch = source.y) %>%
  summarise(
    mean_bbmsy = mean(bbmsy, na.rm = TRUE),
    mean_catch = mean(catch_gapfilled, na.rm = TRUE),
    n_years = n_distinct(year),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_catch))

# Save species list
write_csv(species_used, "galicia_fis_species_list.csv")

# ---------------------------
# 8. STATUS CALCULATION (rest remains the same)
# ---------------------------
# [Previous status calculation code remains unchanged...]

# ---------------------------
# 9. FINAL REPORTING WITH SPECIES INFO
# ---------------------------
results <- list(
  score = tibble(
    assessment_year = max(YEAR_RANGE),
    status = round(current_status, 3),
    trend = round(current_trend, 3),
    fp_fis_score = round(fp_fis_score, 3),
    n_stocks = n_distinct(assessment_data$stockid),
    total_catch = sum(assessment_data$catch_gapfilled, na.rm = TRUE)
  ),
  species = species_used,
  catch_sources = catch_data %>% count(source),
  bbmsy_sources = bbmsy_data %>% count(source)
)

# Print summary
cat("\nGalicia Fisheries Goal Assessment Results:\n")
print(results$score)

cat("\nTop 10 Species by Catch Contribution:\n")
print(results$species %>% head(10))

cat("\nData Sources Used:\n")
print(bind_rows(
  "Catch Data" = results$catch_sources,
  "B/BMSY Data" = results$bbmsy_sources,
  .id = "type"
))