library(sf)
library(dplyr)

# Clean the environment
rm(list=ls())

# Additional base steps 
sf_use_s2(FALSE) # solves problems with latest version of sf for st_as_sf()

ABALONES <- st_read("/Users/batume/Documents/R/GAL_git/prep/BD_SP/ABALONES.shp")
buffer_eez <- st_read("/Users/batume/Documents/R/GAL_git/MAPS/EEZ_BUFFER/galicia_fromohi.shp")

# Step 1: Fix any invalid geometries
ABALONES <- st_make_valid(ABALONES)
buffer_eez <- st_make_valid(buffer_eez)

# Step 2: Clip abalones to inside the buffer
# Use st_intersection to keep attributes and geometries
abalones_in_buffer <- st_intersection(ABALONES, buffer_eez)

# Step 3: Save the result as a new shapefile
st_write(abalones_in_buffer, "/Users/batume/Documents/R/GAL_git/prep/BD_SP/ABALONES_in_buffer.shp", delete_layer = TRUE)

# Optional: Check results
print(abalones_in_buffer)
library(ggplot2)

colnames(ABALONES)
# Plot only the abalones clipped inside buffer
ggplot() +
  geom_sf(data = buffer_eez, fill = NA, color = "blue", size = 1.2) +
  geom_sf(data = abalones_in_buffer, fill = "green", color = "darkgreen", alpha = 0.7) +
  ggtitle("Abalones inside Buffer Zone") +
  theme_minimal()

head(species_data)
