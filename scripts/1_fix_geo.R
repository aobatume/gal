# Load necessary library
library(sf)

# Define input and output directories
input_folder <- "/Users/batume/Documents/R/GAL_git/prep/SPP_ICO"
output_folder <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP"

# Create the output folder if it doesn't exist
if (!dir.exists(output_folder)) {
  dir.create(output_folder, recursive = TRUE)
}

# List all shapefiles in the input directory
shapefiles <- list.files(input_folder, pattern = "\\.shp$", full.names = TRUE)

# Process each shapefile
for (shp_path in shapefiles) {
  # Read the shapefile
  shp <- st_read(shp_path, quiet = TRUE)
  
  # Fix geometries
  shp_fixed <- st_make_valid(shp)
  
  # Define output path (same filename, new folder)
  shp_name <- basename(shp_path)  # Get only the filename
  output_path <- file.path(output_folder, shp_name)
  
  # Save the fixed shapefile
  st_write(shp_fixed, output_path, delete_layer = TRUE, quiet = TRUE)
  
  cat("Fixed and saved:", shp_name, "\n")
}

cat("Processing complete! All fixed shapefiles are in:", output_folder, "\n")
