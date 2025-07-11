# ------------------ Load Required Libraries ------------------
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(readr)
library(worrms)
library(rfishbase)
library(zoo)
library(ramlegacy)

# ------------------ Step 1: Load RAM Legacy Data ------------------
ram_data <- tryCatch({
  load_ramlegacy()
}, error = function(e) {
  stop("Error loading RAM data: ", e$message)
})

# ------------------ Step 2: Filter Galicia Stocks ------------------
galicia_stocks <- ram_data$stock %>%
  filter(grepl("Northeast Atlantic", region, ignore.case = TRUE) | 
           grepl("Spain", areaid, ignore.case = TRUE) |
           grepl("ICES", areaid, ignore.case = TRUE)) %>%
  select(stockid, areaid, stocklong, scientificname, commonname) %>%
  distinct()

# Tag ICES Groups
galicia_stocks <- galicia_stocks %>%
  mutate(group = case_when(
    grepl("VIIIc|IXa", areaid) ~ 1,
    grepl("VIIIa|VIIIb|VIIId|VIIIe|IXb", areaid) ~ 2,
    grepl("VII", areaid) ~ 3,
    TRUE ~ 4
  ))

# ------------------ Step 3: Time Series Data ------------------
galicia_timeseries <- ram_data$timeseries_values_views %>%
  filter(stockid %in% galicia_stocks$stockid) %>%
  select(stockid, year, TCbest, TBbest, TBdivTBmsy)

# ------------------ Step 4: Combine Stock and Time Series ------------------
galicia_data <- galicia_timeseries %>%
  left_join(galicia_stocks, by = "stockid")

# ------------------ Step 5: Get Taxonomy via WoRMS ------------------
get_worms_taxonomy <- function(species_name) {
  res <- wm_records_name(name = species_name)
  if (length(res) == 0 || (is.data.frame(res) && nrow(res) == 0)) return(tibble())
  entry <- if (is.data.frame(res)) res[1, ] else res[[1]]
  tibble(
    scientificname = entry$scientificname,
    kingdom = entry$kingdom,
    phylum = entry$phylum,
    class = entry$class,
    order = entry$order,
    family = entry$family,
    genus = entry$genus,
    AphiaID = entry$AphiaID
  )
}

file_path <- "/Users/batume/Documents/R/GAL_git/prep/FIS/taxonomy_df.rds"
species_list <- unique(galicia_data$scientificname)

taxonomy_df <- if (file.exists(file_path)) {
  readRDS(file_path)
} else {
  safe_lookup <- possibly(get_worms_taxonomy, otherwise = tibble())
  taxonomy_list <- map(species_list, ~{ Sys.sleep(1); safe_lookup(.x) })
  taxonomy_df <- bind_rows(taxonomy_list)
  saveRDS(taxonomy_df, file = file_path)
  taxonomy_df
}

galicia_data <- galicia_data %>%
  left_join(taxonomy_df, by = "scientificname")

# ------------------ Step 6: Get Resilience from FishBase ------------------
species_data <- species(species_list, fields = c("Species", "Vulnerability", "LongevityWild", "Length")) %>%
  rename(scientificname = Species) %>%
  mutate(resilience_score = case_when(
    Vulnerability <= 20 ~ 0.8,
    Vulnerability <= 40 ~ 0.6,
    Vulnerability <= 60 ~ 0.4,
    TRUE ~ 0.2
  ))

galicia_data <- galicia_data %>%
  left_join(species_data, by = "scientificname")

# ------------------ Step 7: Catch Adjustments + Smoothing ------------------
galicia_data <- galicia_data %>%
  mutate(
    TCbest = ifelse(is.na(TCbest), 0, TCbest),
    TBbest = ifelse(is.na(TBbest), 0, TBbest),
    adjusted_catch = TCbest * resilience_score
  ) %>%
  group_by(stockid) %>%
  arrange(year) %>%
  mutate(
    smoothed_catch = rollapply(adjusted_catch, width = 3, FUN = mean, align = "right", fill = NA, na.rm = TRUE)
  ) %>%
  ungroup()

# ------------------ Step 8: Calculate Status (TB / TBmsy = B / BMSY)  Status is the biomass relative to the biomass at MSY, capped at 1
galicia_data <- galicia_data %>%
  mutate(
    status = ifelse(!is.na(TBdivTBmsy), pmin(TBdivTBmsy, 1), NA_real_)
  )
# ------------------ Step 9: Calculate Trend (Slope over Last 5 Years) ------------------
trend_data <- galicia_data %>%
  filter(!is.na(smoothed_catch)) %>%
  group_by(stockid) %>%
  arrange(year) %>%
  filter(n() >= 5) %>%
  summarise(
    trend = {
      df <- tail(cur_data(), 5)
      if (nrow(df) < 5 || all(is.na(df$smoothed_catch))) NA_real_
      else lm(smoothed_catch ~ year, data = df)$coefficients[["year"]]
    },
    .groups = "drop"
  )

galicia_data <- galicia_data %>%
  left_join(trend_data, by = "stockid")

# ------------------ Step 10: Export Species List and Final Data ------------------
species_list_out <- galicia_data %>%
  distinct(scientificname, commonname, family, genus, order, class, phylum) %>%
  arrange(scientificname)

write_csv(species_list_out, "galicia_species_list.csv")
write_csv(galicia_data, "galicia_fisheries_enriched.csv")


## FIX FAO CODES IN FINAL DATA - needed for further scripts 

asfis_raw <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/ASFIS_sp_2024.csv", encoding = "Latin1")
colnames(asfis_raw)

asfis <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/ASFIS_sp_2024.csv", encoding = "Latin1") %>%
  select(
    FAOcode = Alpha3_Code,
    scientificname = Scientific_Name,
    English_name = English_name,
    Family, Order.or.higher.taxa
  )

galicia_ram_taxo <- galicia_data %>%
  left_join(asfis, by = c("scientificname" = "scientificname"))



