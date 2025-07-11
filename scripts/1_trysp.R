# Load necessary libraries
library(sf)        # For spatial data manipulation
library(dplyr)     # For data manipulation



# Step 1: Define file paths and initialize logging
species_folder <- setwd("/Users/batume/Documents/R/GAL_git/prep/SPP_ICO")  # Folder containing species shapefiles
buffer_file <- "/Users/batume/Documents/R/GAL_git/prep/SPP_ICO/Buffers.shp"              # Path to the buffer shapefile
log_file <- "overlap_process.log"                               # Log file to record progress

