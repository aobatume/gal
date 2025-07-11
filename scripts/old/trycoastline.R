library(sf)

# Step 1: Load the Galicia region and European coastline files
galicia_file <- "/Users/batume/Documents/R/MAPS_R/DATA/Comunidade_Autonoma_IGN.shp"  # Replace with actual file path
europe_coastline_file <- "/Users/batume/Documents/R/MAPS_R/DATA/Europe_coastline.shp"  # Replace with actual file path

galicia <- st_read(galicia_file)  # Load Galicia boundary
europe_coastline <- st_read(europe_coastline_file)  # Load European coastline

# Step 2: Check CRS of both layers
cat("Galicia CRS:", st_crs(galicia)$proj4string, "\n")
cat("Europe Coastline CRS:", st_crs(europe_coastline)$proj4string, "\n")

# Step 3: Transform to a common CRS (use Galicia's CRS for simplicity)
europe_coastline <- st_transform(europe_coastline, crs = st_crs(galicia))

# Step 4: Clip the European coastline to the Galicia boundary
galicia_coastline <- st_intersection(europe_coastline, galicia)

# Step 5: Validate and clean the resulting geometry
galicia_coastline <- st_make_valid(galicia_coastline)

# Step 6: Save the extracted Galicia coastline to a new file
st_write(galicia_coastline, "galicia_coastline.shp", driver = "ESRI Shapefile")

# Step 7: Plot the results for verification
plot(st_geometry(galicia), col = "lightblue", main = "Galicia Coastline")
plot(st_geometry(galicia_coastline), col = "darkblue", add = TRUE)
