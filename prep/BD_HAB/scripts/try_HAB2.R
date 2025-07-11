library(sf)
library(ggplot2)
library(patchwork)

# Load your habitat data
seagrasses <- st_read("/Users/batume/Documents/R/GAL_git/prep/BD_HAB/014_001_WCMC013-014_SeagrassPtPy2021_v7_1/01_Data/WCMC013_014_Seagrasses_Py_v7_1.shp")
corals <- st_read("/Users/batume/Documents/R/GAL_git/prep/BD_HAB/14_001_WCMC001_ColdCorals2017_v5_1/01_Data/WCMC001_ColdCorals2017_Py_v5_1.shp")
saltmarshes <- st_read("/Users/batume/Documents/R/GAL_git/prep/BD_HAB/WCMC027_Saltmarsh_v6_1/01_Data/WCMC027_Saltmarshes_Py_v6_1.shp")

# Buffer layer (already loaded in your script)
buffer <- st_read("/Users/batume/Documents/R/GAL_git/MAPS/EEZ_BUFFER/galicia_fromohi.shp")

# Ensure valid geometries
seagrasses <- st_make_valid(seagrasses)
corals <- st_make_valid(corals)
saltmarshes <- st_make_valid(saltmarshes)
buffer <- st_make_valid(buffer)

# Transform all layers to the same CRS
seagrasses <- st_transform(seagrasses, st_crs(buffer))
corals <- st_transform(corals, st_crs(buffer))
saltmarshes <- st_transform(saltmarshes, st_crs(buffer))
buffer <- st_transform(buffer, st_crs(seagrasses))

# Extract habitats within the buffer
seagrasses_within_buffer <- st_intersection(seagrasses, buffer)
corals_within_buffer <- st_intersection(corals, buffer)
saltmarshes_within_buffer <- st_intersection(saltmarshes, buffer)

# Save the intersected habitat data to GeoPackage files
st_write(seagrasses_within_buffer, "seagrasses_within_buffer.gpkg", driver = "GPKG", delete_dsn = TRUE)
st_write(corals_within_buffer, "corals_within_buffer.gpkg", driver = "GPKG", delete_dsn = TRUE)
st_write(saltmarshes_within_buffer, "saltmarshes_within_buffer.gpkg", driver = "GPKG", delete_dsn = TRUE)

# Create custom theme for plotting
theme_hab <- theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank()
  )

# Define output directory
output_dir <- "/Users/batume/Documents/R/GAL_git/prep/BD_HAB/"

# Plot Seagrass Habitats
p_seagrasses <- ggplot() +
  geom_sf(data = buffer, fill = NA, color = "black", linetype = "dashed") +
  geom_sf(data = seagrasses_within_buffer, fill = "lightgreen", color = "black", size = 0.1) +
  ggtitle("Seagrass Habitats") +
  theme_hab

# Plot Coral Habitats
p_corals <- ggplot() +
  geom_sf(data = buffer, fill = NA, color = "black", linetype = "dashed") +
  geom_sf(data = corals_within_buffer, fill = "coral", color = "black", size = 0.1) +
  ggtitle("Coral Habitats") +
  theme_hab

# Plot Saltmarsh Habitats
p_saltmarshes <- ggplot() +
  geom_sf(data = buffer, fill = NA, color = "black", linetype = "dashed") +
  geom_sf(data = saltmarshes_within_buffer, fill = "khaki", color = "black", size = 0.1) +
  ggtitle("Saltmarsh Habitats") +
  theme_hab

# Save individual habitat plots
ggsave(filename = file.path(output_dir, "seagrasses_habitats.png"), plot = p_seagrasses, width = 8, height = 6)
ggsave(filename = file.path(output_dir, "corals_habitats.png"), plot = p_corals, width = 8, height = 6)
ggsave(filename = file.path(output_dir, "saltmarshes_habitats.png"), plot = p_saltmarshes, width = 8, height = 6)

# Combine all habitat plots into one layout (3x1 grid)
combined_plot <- (p_seagrasses + p_corals + p_saltmarshes) +
  plot_layout(guides = "collect") +
  plot_annotation(title = "Marine Habitat Types in Galicia Region")

# Save combined plot as a single PNG (slightly smaller than A4: 11 x 7.5 inches)
ggsave(filename = file.path(output_dir, "all_habitats_combined_2.png"),
       plot = combined_plot,
       width = 11, height = 7.5, dpi = 300)