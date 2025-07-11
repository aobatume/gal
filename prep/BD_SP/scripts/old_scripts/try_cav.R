library(sf)
library(dplyr)

# Set your working directory
setwd("/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections")

# List all .gpkg files
gpkg_files <- list.files(pattern = "\\.gpkg$")

# Create an output directory if it doesn't exist
dir.create("output", showWarnings = FALSE)

# Loop through each GeoPackage file
for (gpkg in gpkg_files) {
  # Get all layers in the GPKG
  layers <- st_layers(gpkg)$name
  
  for (layer in layers) {
    # Read the layer
    data <- st_read(gpkg, layer = layer, quiet = TRUE)
    
    # Check if 'sci_name' column exists
    if ("sci_name" %in% names(data)) {
      unique_names <- unique(data$sci_name)
      df <- data.frame(sci_name = unique_names)
      
      # Output file name
      out_file <- paste0("output/", tools::file_path_sans_ext(gpkg), "_", layer, "_unique_sci_names.csv")
      write.csv(df, out_file, row.names = FALSE)
      
      cat("Extracted from", gpkg, "layer:", layer, "\n")
    } else {
      cat("Column 'sci_name' not found in", gpkg, "layer:", layer, "\n")
    }
  }
}

# Print working directory at the end
getwd()

