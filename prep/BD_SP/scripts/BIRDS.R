library(sf)
library(dplyr)

rm(list=ls())
sf_use_s2(FALSE)

names(BIRLIFE_GPKG)


##LOAD BIRDLIFE DATA

BIRLIFE_GPKG <- all_species <- st_read("/Users/batume/Documents/R/GAL_git/prep/BD_SP/BIRDLIFE.gpkg", layer = "all_species")
buffer_grid<-st_read("/Users/batume/Documents/R/GAL_git/prep/BD_SP/buffer_grid.gpkg")

st_sf(BIRLIFE_GPKG) 

# Ensure CRS is es29
buffer_grid <- st_transform(buffer_grid, crs = 3857)
BIRLIFE_GPKG <- st_transform(BIRLIFE_GPKG, crs = 3857)

clipped_species <- st_intersection(BIRLIFE_GPKG, buffer_grid)

# Plot to verify
plot(st_geometry(buffer_grid), col = NA, border = 'gray')
plot(st_geometry(clipped_species), add = TRUE, border = 'blue')


#MERGE WITH IUCN DATA
 
# --- Constants ---
iucn_status_map <- c(
  "EX" = 0.0,
  "CR" = 0.2,
  "EN" = 0.4,
  "VU" = 0.6,
  "NT" = 0.8,
  "LC" = 1.0,
  "EW" = NA,
  "DD" = NA
)


head(clipped_species)

#OBTAIN IUCN CATEGORIES FROM DOWNLOADED CSV FILE (https://datazone.birdlife.org/about-our-science/the-iucn-red-list)

# Normalize both names (trim + lowercase to avoid mismatch)
IUCN <- read.csv("/Users/batume/Documents/R/GAL_git/prep/BD_SP/inv_sp/species-filter-results.csv")

IUCN <- IUCN %>%
  rename(sci_name = Scientific.name, category = RL.Category) %>%  # match column names
  mutate(sci_name = str_trim(tolower(sci_name)))  # normalize case/whitespace

clipped_species <- clipped_species %>%
  mutate(sci_name = str_trim(tolower(sci_name)))

clipped_species <- clipped_species %>%
  left_join(IUCN %>% select(sci_name, category), by = "sci_name")

clipped_species <- clipped_species %>%
  mutate(risk_weight = iucn_status_map[category])

output_path <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections/BIRDS_intersection_IUCN.gpkg"

st_write(clipped_species, output_path, delete_layer = TRUE)


########### CALCULATE SCORES ##################

library(sf)
library(dplyr)
library(units)
library(readr)
library(tools)
library(stringr)


# --- Settings ---
sf_use_s2(FALSE)

# --- Paths ---
intersection_gpkg_path <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections/BIRDS_intersection_IUCN.gpkg"
output_species_log_dir <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/included_species_logs"
dir.create(output_species_log_dir, showWarnings = FALSE, recursive = TRUE)

## CALCULATE 

# --- Biodiversity Scoring Function ---
process_species <- function(species_data) {
  species_name <- unique(species_data$sci_name)
  message("⏳ Processing: ", species_name)
  
  tryCatch({
    # Compute area in km² from geometry
    species_data <- species_data %>%
      mutate(area_km2 = as.numeric(st_area(.)) / 1e6)
    
    total_area <- sum(species_data$area_km2, na.rm = TRUE)
    
    # Compute area-weighted risk per grid cell
    cell_risks <- species_data %>%
      group_by(grid_id) %>%
      summarise(
        weighted_risk = sum(risk_weight * area_km2, na.rm = TRUE),
        cell_area = sum(area_km2, na.rm = TRUE),
        .groups = "drop"
      )
    
    mean_species_risk <- sum(cell_risks$weighted_risk, na.rm = TRUE) / sum(cell_risks$cell_area, na.rm = TRUE)
    
    # Normalize score between 0 (high risk) and 1 (low risk)
    min_risk <- 0.25
    max_risk <- 1.0
    score <- (mean_species_risk - min_risk) / (max_risk - min_risk)
    score <- pmin(pmax(score, 0), 1)
    
    result <- data.frame(
      species = species_name,
      iucn_category = paste(unique(species_data$category), collapse = ";"),
      area_km2 = round(total_area, 2),
      biodiversity_score = round(score, 4)
    )
    
    return(result)
    
  }, error = function(e) {
    message("❌ Failed: ", species_name, " - ", e$message)
    return(NULL)
  })
}

# --- Loop through all species ---
results <- clipped_species %>%
  group_split(sci_name) %>%
  lapply(process_species) %>%
  bind_rows()

# --- Save Outputs ---
if (nrow(results) > 0) {
  write_csv(results, file.path(output_species_log_dir, "birds_biodiversity_scores.csv"))
  message("✅ All results saved.")
} else {
  message("⚠️ No valid results generated.")
}



### ONE for the whole birds dataset

library(sf)
library(dplyr)
library(readr)

# Turn off s2 geometry processing
sf_use_s2(FALSE)

# --- Load birds data ---
birds_file <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections/BIRDS_intersection_IUCN.gpkg"
birds_data <- st_read(birds_file, quiet = TRUE)


# --- Check required columns ---
required_cols <- c("grid_id", "category", "risk_weight")
if (!all(required_cols %in% names(birds_data))) {
  stop("❌ Required columns missing: ", paste(setdiff(required_cols, names(birds_data)), collapse = ", "))
}

head(clipped_species)
# --- Calculate area in km² ---
birds_data <- birds_data %>%
  mutate(area_km2 = as.numeric(st_area(.)) / 1e6)

# --- Total area covered ---
total_area <- sum(birds_data$area_km2, na.rm = TRUE)

# --- Biodiversity score calculation ---
cell_risks <- birds_data %>%
  group_by(grid_id) %>%
  summarise(
    weighted_risk = sum(risk_weight * area_km2, na.rm = TRUE),
    cell_area = sum(area_km2, na.rm = TRUE),
    .groups = "drop"
  )

mean_species_risk <- sum(cell_risks$weighted_risk, na.rm = TRUE) / sum(cell_risks$cell_area, na.rm = TRUE)

# --- Normalize score between 0 and 1 ---
min_risk <- 0.25
max_risk <- 1.0
score <- (mean_species_risk - min_risk) / (max_risk - min_risk)
score <- pmin(pmax(score, 0), 1)

# --- Result ---
birds_result <- data.frame(
  group = "Birds",
  iucn_categories = paste(unique(birds_data$category), collapse = ";"),
  area_km2 = round(total_area, 2),
  biodiversity_score = round(score, 4)
)

# --- Save result ---
write_csv(birds_result, "whole_BIRDS_biodiversity_score.csv")
message("✅ BIRDS score saved to: whole_BIRDS_biodiversity_score.csv")

head(birds_data)
