library(sf)
library(dplyr)
library(units)

# Step 1: Define IUCN status mapping
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

# Step 2: List all GPKG files in your working directory (adjust path if needed)
getwd()
dir_path <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections"
gpkg_files <- list.files(path = dir_path, pattern = "_intersection.*\\.gpkg$", full.names = TRUE)

# Print the list of files
print(gpkg_files)
# Initialize empty list to store all risk data
all_cell_risks <- list()

# Load the grid 
 grid_clipped 

# Step 3: Loop through each GPKG file
for (file in gpkg_files) {
  message("Processing: ", file)
  
  # Read species data
  species_data <- st_read(file, quiet = TRUE) %>%
    mutate(marine = tolower(marine) == "true")
  
  # Filter and map risk
  species_filtered <- species_data %>%
    filter(marine == TRUE, category %in% names(iucn_status_map)) %>%
    mutate(risk_weight = iucn_status_map[category]) %>%
    filter(!is.na(risk_weight))
  
  # Skip empty datasets
  if (nrow(species_filtered) == 0) next
  
  # Transform CRS if needed
  species_filtered <- st_transform(species_filtered, st_crs(grid_clipped))
  
  # Intersect with grid
  intersection <- st_intersection(species_filtered, grid_clipped)
  
  if (nrow(intersection) == 0) next
  
  # Compute area
  intersection <- intersection %>%
    mutate(area_km2 = st_area(.) %>% set_units("km^2") %>% as.numeric())
  
  # Compute weighted risk per grid cell
  cell_risks <- intersection %>%
    group_by(grid_id) %>%
    summarise(
      weighted_risk = sum(risk_weight * area_km2, na.rm = TRUE),
      cell_area = sum(area_km2, na.rm = TRUE),
      .groups = "drop"
    )
  
  # Append to the list
  all_cell_risks[[file]] <- cell_risks
}

# Step 4: Combine all cell risk data
combined_risks <- bind_rows(all_cell_risks)

# Step 5: Aggregate to total weighted risk per grid cell (in case of overlap)
total_risks <- combined_risks %>%
  group_by(grid_id) %>%
  summarise(
    weighted_risk = sum(weighted_risk, na.rm = TRUE),
    cell_area = sum(cell_area, na.rm = TRUE),
    .groups = "drop"
  )

# Step 6: Compute area-weighted mean risk
mean_species_risk <- sum(total_risks$weighted_risk) / sum(total_risks$cell_area)

# Step 7: Rescale to biodiversity score (1 = all LC, 0 = 75% extinction)
max_risk <- 0.75
score <- (max_risk - mean_species_risk) / max_risk
score <- pmin(pmax(score, 0), 1)

# Step 8: Final output
cat("Overall area-weighted mean species risk:", round(mean_species_risk, 4), "\n")
cat("Overall rescaled biodiversity status score:", round(score, 4), "\n")
