# Load required libraries
library(sf)

# Read the shapefiles
line1 <- st_read("path_to_line1.shp") # Replace with your first shapefile path
line2 <- st_read("path_to_line2.shp") # Replace with your second shapefile path

# Check the CRS of both layers
crs_line1 <- st_crs(line1)
crs_line2 <- st_crs(line2)

# Print the CRS to ensure they match or to know the target CRS
print(crs_line1)
print(crs_line2)

# If the CRS do not match, project one layer to the CRS of the other
if (crs_line1 != crs_line2) {
  # Project line2 to the CRS of line1
  line1 <- st_transform(line1, crs_line2)
}

# Optional: Save the reprojected shapefile (only if needed)
st_write(line2, "path_to_output/reprojected_line2.shp") # Replace with your output path

# Optional: Save both layers to confirm they share the same CRS
st_write(line1, "path_to_output/reprojected_line1.shp") # Replace with your output path if you reproject both

# Final confirmation of matching CRS
print(st_crs(line1))
print(st_crs(line2))




# Load required libraries
library(sf)
library(lwgeom)

# Read the shapefiles
line1 <- st_read("/Users/batume/Documents/R/MAPS_R/DATA/Europe_coastline.shp") # Replace with the path to your first shapefile
line2 <- st_read("/Users/batume/Documents/R/MAPS_R/DATA/COSTA.shp") # Replace with the path to your second shapefile

# Ensure both layers have the same CRS
if (st_crs(line1) != st_crs(line2)) {
  line2 <- st_transform(line2, st_crs(line1))
}

# Find the intersection of the two line shapefiles
intersection <- st_intersection(line1, line2)

# Combine all overlapping segments into a single line
connected_line <- st_union(intersection)

# Save the result to a new shapefile
st_write(connected_line, "path_to_output/connected_line.shp") # Replace with the desired output path

# Optional: Plot the result
plot(st_geometry(connected_line), col = "blue", lwd = 2, main = "Connected Overlapping Line")
