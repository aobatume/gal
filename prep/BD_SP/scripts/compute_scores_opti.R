library(sf)
library(dplyr)
library(units)
library(furrr)
library(purrr)
library(readr)

# --- Settings ---
sf_use_s2(FALSE)
plan(multisession, workers = parallel::detectCores() - 1)  # Parallel processing

# --- Paths ---
species_dir <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP"
buffer_path <- "/Users/batume/Documents/R/GAL_git/MAPS/EEZ_BUFFER/galicia_fromohi.shp"
output_csv <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/biodiversity_scores_opti_basic.csv"

# --- Constants ---
cellsize_meters <- 55000
target_crs <- 3857  # Keep consistent throughout
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
# --- Load buffer and create grid ---
buffer_eez <- st_read(buffer_path, quiet = TRUE) %>%
  st_make_valid() %>%
  st_transform(target_crs)

grid <- st_make_grid(buffer_eez, cellsize = cellsize_meters, what = "polygons", square = TRUE)
grid_sf <- st_sf(grid_id = seq_along(grid), geometry = grid) %>%
  st_transform(target_crs)

grid_clipped <- st_intersection(grid_sf, buffer_eez)

# --- Processing Function ---
# --- Define where to save intersection shapefiles and logs ---
output_shp_dir <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections"
output_species_log_dir <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/included_species_logs"
dir.create(output_shp_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(output_species_log_dir, showWarnings = FALSE, recursive = TRUE)

process_species <- function(shp_path) {
  species_name <- tools::file_path_sans_ext(basename(shp_path))
  message("⏳ Processing: ", species_name)
  
  tryCatch({
    species_data <- st_read(shp_path, quiet = TRUE) %>%
      st_make_valid() %>%
      st_transform(target_crs)
    
    if (!all(c("marine", "category") %in% names(species_data))) return(NULL)
    
    species_data <- species_data %>%
      mutate(marine = tolower(marine) == "true") %>%
      filter(marine, category %in% names(iucn_status_map)) %>%
      mutate(risk_weight = iucn_status_map[category]) %>%
      filter(!is.na(risk_weight))
    
    if (nrow(species_data) == 0) return(NULL)
    
    intersection <- st_intersection(species_data, grid_clipped)
    
    if (nrow(intersection) == 0) return(NULL)
    
    intersection <- intersection %>%
      mutate(area_km2 = as.numeric(st_area(geometry)) / 1e6)
    
    # ✅ Include all species regardless of overlap size
    total_area <- sum(intersection$area_km2, na.rm = TRUE)
    
    # ✅ Save intersection GPKG
    output_path <- file.path(output_shp_dir, paste0(species_name, "_intersection2.gpkg"))
    st_write(intersection, output_path, delete_dsn = TRUE, quiet = TRUE)
    
    # ✅ Save log of species presence in this intersection
    log_df <- data.frame(
      grid_ids = unique(intersection$grid_id),
      species = species_name,
      total_area_km2 = round(total_area, 2),
      iucn_category = paste(unique(species_data$category), collapse = ";")
    )
    log_path <- file.path(output_species_log_dir, paste0(species_name, "_presence_log2.csv"))
    write_csv(log_df, log_path)
    
    # 🧮 Risk calculation
    cell_risks <- intersection %>%
      group_by(grid_id) %>%
      summarise(
        weighted_risk = sum(risk_weight * area_km2, na.rm = TRUE),
        cell_area = sum(area_km2, na.rm = TRUE),
        .groups = "drop"
      )
    
    mean_species_risk <- sum(cell_risks$weighted_risk) / sum(cell_risks$cell_area)
    min_risk <- 0.25
    max_risk <- 1.0
    score <- (mean_species_risk - min_risk) / (max_risk - min_risk)
    score <- pmin(pmax(score, 0), 1)
    
    return(data.frame(
      species = species_name,
      iucn_category = paste(unique(species_data$category), collapse = ";"),
      area_km2 = round(total_area, 2),
      biodiversity_score = round(score, 4)
    ))
    
  }, error = function(e) {
    message("❌ Failed: ", species_name, " - ", e$message)
    return(NULL)
  })
}
# --- Run in Parallel ---
shp_files <- list.files(species_dir, pattern = "\\.shp$", full.names = TRUE)
results_list <- future_map(shp_files, process_species, .progress = TRUE, .options = furrr_options(seed = TRUE))
results <- bind_rows(results_list)

# --- Save ---
write_csv(results, output_csv)
message("✅ All done. Output saved to: ", output_csv)