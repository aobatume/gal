
# Load required libraries
library(sf)
library(lwgeom)

# Read the shapefiles
line1 <- st_read("/Users/batume/Documents/R/MAPS_R/DATA/Europe_coastline.shp") # Replace with the path to your first shapefile
line2 <- st_read("/Users/batume/Documents/R/MAPS_R/DATA/Comunidade_Autonoma_IGN_linea.shp") # Replace with the path to your second shapefile

# Ensure both layers have the same CRS
if (st_crs(line1) != st_crs(line2)) {
  line2 <- st_transform(line2, st_crs(line1))
}

# Reproject line2 to the CRS of line1
line2_reprojected <- st_transform(line2, st_crs(line1))


# Confirm CRS
print(st_crs(line1))
print(st_crs(line2_reprojected))


line2_merged <- st_union(line2_reprojected)
print(st_geometry_type(line2_merged))  # !! MULTILINESTRING


# Get the bounding box 
bbox <- st_bbox(line2_reprojected)

line1_cropped <- st_crop(line1, bbox)
line2_cropped <- st_crop(line2_reprojected, bbox)

line1_simplified <- st_simplify(line1_cropped, dTolerance = 500)  # Adjust tolerance (in meters)
line2_simplified <- st_simplify(line2_cropped, dTolerance = 500)

print(object.size(line1_simplified), units = "MB")
print(object.size(line2_simplified), units = "MB")
plot(intersection)


# Validate and repair geometries
line2_simplified <- st_make_valid(line2_simplified)
grid_cropped <- st_make_valid(grid_cropped)

# Check validity
if (!st_is_valid(line2_simplified)) stop("line2_simplified is invalid")
if (!st_is_valid(grid_cropped)) stop("grid_cropped is invalid")







line2_simplified <- st_simplify(line2_merged, dTolerance = 500)


# Find overlapping portions
overlap <- st_intersection(line1, line2_simplified)
plot(line_sf)
# Check the geometry type and size
print(st_geometry_type(overlap))
print(object.size(overlap), units = "MB")

# Snap points from multipoint_sf to the nearest location on line2_simplified
snapped_points <- st_nearest_points(overlap, line2_simplified)
# Extract the points snapped to the line
snapped_coords <- st_coordinates(snapped_points)

# Order snapped points along the template line
ordered_snapped <- snapped_coords[order(snapped_coords[, "X"]), ]
# Create a LINESTRING from the ordered points
snapped_linestring <- st_linestring(as.matrix(ordered_snapped))

# Convert to sf object
snapped_line_sf <- st_sf(geometry = st_sfc(snapped_linestring), crs = st_crs(line2_simplified))
# Plot the original line, points, and snapped line
plot(st_geometry(line2_simplified), col = 'gray', lwd = 2, main = "Snapped Line")
plot(st_geometry(multipoint_sf), col = 'red', add = TRUE, pch = 20)
plot(st_geometry(snapped_line_sf), col = 'blue', lwd = 2, add = TRUE)

# Save the snapped line as a shapefile
st_write(snapped_line_sf, "snapped_connected_line.shp")

overlap <- st_intersection(line1, snapped_line_sf)
plot(overlap)

# Merge overlapping segments into a single line
connected_line <- st_union(overlap)

# Check the final geometry type
print(st_geometry_type(connected_line))  # Should be LINESTRING or MULTILINESTRING

# Save to a shapefile
st_write(connected_line, "/Users/batume/Documents/R/MAPS_R/DATA/connected_coastline.shp")

# Plot the final connected line
plot(st_geometry(connected_line), col = "green", lwd = 3, main = "Connected Overlapping Line")
