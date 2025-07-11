# Load libraries
library(sf)
library(dplyr)
library(readr)
library(ggplot2)

# 1. Read buffer shapefile
buffer_eez <- st_read("/Users/batume/Documents/R/GAL_git/MAPS/EEZ_BUFFER/galicia_fromohi.shp")

# 2. Fix buffer geometry
buffer_eez <- st_make_valid(buffer_eez)

# 3. List all species shapefiles
species_files <- list.files(
  "/Users/batume/Documents/R/GAL_git/prep/BD_SP/",
  pattern = "\\.shp$",
  full.names = TRUE
)

# 4. Remove the buffer file itself from the list
species_files <- species_files[!grepl("Buffers", species_files)]

# 5. IUCN weights table
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
# 6. Create empty dataframe to store CSV info
species_summary <- data.frame(
  species = character(),
  category = character(),
  score = numeric(),
  stringsAsFactors = FALSE
)

# 7. Output folder for shapefiles
output_folder <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/"

# 8. Process each species shapefile
for (file in species_files) {
  
  # Read file
  message("Processing: ", basename(file))
  sp_data <- st_read(file, quiet = TRUE)
  
  # Fix geometries
  sp_data <- st_make_valid(sp_data)
  
  # Clip to buffer
  sp_buffered <- st_intersection(sp_data, buffer_eez)
  
  # Check if clipped result is not empty
  if (nrow(sp_buffered) > 0) {
    
    # Add risk weights based on 'category' column
    if (!"category" %in% colnames(sp_buffered)) {
      warning("File ", basename(file), " does not have a 'category' column, skipping...")
      next
    }
    sp_buffered <- sp_buffered %>%
      mutate(
        risk_score = iucn_weights[category],
        species = sci_name  # assuming sci_name is the scientific name
      )
    
    # Save the clipped shapefile
    output_name <- paste0(output_folder, tools::file_path_sans_ext(basename(file)), "_buffered.shp")
    st_write(sp_buffered, output_name, delete_layer = TRUE, quiet = TRUE)
    
    # Extract required columns for CSV summary
    summary_info <- sp_buffered %>%
      st_drop_geometry() %>%
      select(species, category, risk_score) %>%
      distinct()
    
    # Append to overall summary
    species_summary <- bind_rows(species_summary, summary_info)
    
  } else {
    message("No intersection for file: ", basename(file))
  }
}

# 9. Save the final CSV
write_csv(species_summary, paste0(output_folder, "species_risk_summary.csv"))

message("All files processed and outputs saved!")