install.packages("future")
install.packages("furrr")
# Load libraries
library(sf)
library(dplyr)
library(readr)
library(ggplot2)
library(furrr)
colnames(ABALONES)
# 1. Read buffer shapefile
buffer_eez <- st_read("/Users/batume/Documents/R/GAL_git/MAPS/EEZ_BUFFER/galicia_fromohi.shp")

# 2. Fix buffer geometry and reproject to UTM (EPSG:25829)
buffer_eez <- st_make_valid(buffer_eez) %>%
  st_transform(crs = 25829)

# 3. List only the first two species shapefiles for testing
species_files <- list.files(
  "/Users/batume/Documents/R/GAL_git/prep/BD_SP/",
  pattern = "\\.shp$",
  full.names = TRUE
)

# Select only the first two files for testing
species_files <- species_files[1:2]

# 4. IUCN weights table
iucn_status_map <- c(
  "LC" = 1.0,   # Least Concern
  "NT" = 0.75,  # Near Threatened
  "VU" = 0.5,   # Vulnerable
  "EN" = 0.25,  # Endangered
  "CR" = 0.0,   # Critically Endangered
  "EX" = NA,    # Extinct
  "EW" = NA,    # Extinct in the Wild
  "DD" = NA     # Data Deficient
)
# 5. Create empty dataframe to store CSV info
species_summary <- data.frame(
  species = character(),
  category = character(),
  score = numeric(),
  stringsAsFactors = FALSE
)

# 6. Output folder for shapefiles
output_folder <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/"
# 10. Process each species shapefile
# 10. Process each species shapefile
for (file in species_files) {
  
  # 10.1. Read species file
  message("Processing: ", basename(file))
  sp_data <- st_read(file, quiet = TRUE)
  
  # 10.2. Reproject species shapefile to the same CRS as buffer
  sp_data <- st_transform(sp_data, crs = st_crs(buffer_eez))  # Ensure both have the same CRS
  
  # 10.3. Fix geometries
  sp_data <- st_make_valid(sp_data)
  
  # 10.4. Clip species shapefile to buffer
  sp_buffered <- st_intersection(sp_data, buffer_eez)
  
  # 10.5. Check if intersection is not empty
  if (nrow(sp_buffered) > 0) {
    
    # 10.6. Add risk scores based on 'category' column
    if (!"category" %in% colnames(sp_buffered)) {
      warning("File ", basename(file), " does not have a 'category' column, skipping...")
      next  # Skip this file and go to the next one
    }
    
    # Ensure 'category' exists and match to IUCN status
    sp_buffered <- sp_buffered %>%
      mutate(
        risk_score = iucn_status_map[category],  # Access map correctly
        species = sci_name  # Assuming 'sci_name' is the scientific name
      )
    
    # 10.7. Save the clipped shapefile
    output_name <- paste0(output_folder, tools::file_path_sans_ext(basename(file)), "_buffered.shp")
    st_write(sp_buffered, output_name, delete_layer = TRUE, quiet = TRUE)
    
    # 10.8. Extract relevant columns for CSV summary
    summary_info <- sp_buffered %>%
      st_drop_geometry() %>%
      select(species, category, risk_score) %>%
      distinct()
    
    # 10.9. Append the summary info to the overall dataframe
    species_summary <- bind_rows(species_summary, summary_info)
    
  } else {
    # 10.10. If there's no intersection, just log and continue to the next file
    message("No intersection for file: ", basename(file))
    next  # Skip this file and continue to the next one
  }
}

# 11. Save the final summary CSV file
write_csv(species_summary, paste0(output_folder, "species_risk_summary.csv"))

message("All files processed and outputs saved!")