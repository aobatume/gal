
library(sf)
library(dplyr)
library(purrr)

# List all .gpkg files
gpkg_files <- list.files("/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections/cleaned", pattern = "\\.gpkg$", full.names = TRUE)




inspect_species_trends <- function(file) {
  message("Processing: ", basename(file))
  
  data <- st_read(file, quiet = TRUE)
  
  if (!all(c("sci_name", "yrcompiled") %in% colnames(data))) {
    warning("Missing required columns in: ", file)
    return(NULL)
  }
  
  data_df <- data %>%
    st_drop_geometry() %>%
    filter(!is.na(yrcompiled)) %>%
    mutate(yrcompiled = as.integer(yrcompiled))  # ensure numeric
  
  # Summarize counts per species per year
  yearly_summary <- data_df %>%
    group_by(sci_name, yrcompiled) %>%
    summarize(count = n(), .groups = "drop")
  
  # Filter for species with data from 2+ years AND more than 1 total count
  species_trends <- yearly_summary %>%
    group_by(sci_name) %>%
    filter(n_distinct(yrcompiled) >= 2) %>%
    summarize(
      n_years = n_distinct(yrcompiled),
      total_records = sum(count),
      years = paste(sort(unique(yrcompiled)), collapse = ", "),
      slope = if (sum(count) > 1) {
        tryCatch({
          coef(lm(count ~ yrcompiled))[["yrcompiled"]]
        }, error = function(e) NA_real_)
      } else {
        NA_real_
      },
      .groups = "drop"
    ) %>%
    mutate(file = basename(file))
  
  # Add species with only 1 year of data
  single_year_species <- setdiff(unique(data_df$sci_name), unique(species_trends$sci_name))
  single_entries <- tibble(
    sci_name = single_year_species,
    n_years = 1,
    total_records = NA,
    years = NA,
    slope = NA_real_,
    file = basename(file)
  )
  
  all_trends <- bind_rows(species_trends, single_entries)
  
  # Scale slopes only if valid values exist (do this later in your workflow)
  all_trends <- all_trends %>%
    mutate(slope_scaled = NA_real_)  # placeholder, can scale later globally
  
  return(all_trends)
}



species_trends <- map_dfr(gpkg_files, inspect_species_trends)

# Scale slopes later — only on valid ones
valid_slopes <- species_trends %>%
  filter(!is.na(slope)) %>%
  mutate(slope_scaled = as.numeric(scale(slope)))

# Merge back
species_trends <- species_trends %>%
  left_join(valid_slopes %>% select(sci_name, file, slope_scaled), by = c("sci_name", "file"))

# Summary
species_trends %>%
  filter(!is.na(slope)) %>%
  mutate(trend_direction = case_when(
    slope >  0 ~ "increasing",
    slope <  0 ~ "decreasing",
    slope == 0 ~ "flat"
  )) %>%
  count(trend_direction)

# Count species with >1 year of data and valid slope
species_trends %>%
  filter(n_years > 1, !is.na(slope)) %>%
  summarize(n_species_with_trend = n())





