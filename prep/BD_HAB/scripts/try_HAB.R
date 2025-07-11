
library(sf)

sf::sf_use_s2(FALSE)

gdb_data <- st_read("/Users/batume/Documents/R/GAL_git/prep/BD_HAB/EUSeaMap_2023/EUSeaMap_2023.gdb")
st_layers("/Users/batume/Documents/R/GAL_git/prep/BD_HAB/EUSeaMap_2023/EUSeaMap_2023.gdb")
buffer<- st_read("/Users/batume/Documents/R/GAL_git/MAPS/EEZ_BUFFER/galicia_fromohi.shp")
gdb_data <- st_simplify(gdb_data, dTolerance = 0.01, preserveTopology = TRUE)
cat("EUSeaMap Data:")
print(st_geometry(gdb_data))
cat("\nBuffer Data:")
print(st_geometry(buffer))
#unique(gdb_data$EUNIScombD)

#unique(gdb_data$All2019D)
# 3. Fix geometries (ensure valid geometries)
gdb_data <- st_make_valid(gdb_data)
buffer <- st_make_valid(buffer)

# 4. Transform both layers to the same CRS if necessary
gdb_data <- st_transform(gdb_data, st_crs(buffer))

# 5. Extract habitat data within the buffer
habitat_within_buffer <- st_intersection(gdb_data, buffer)
# 6. Save the intersected habitat data to a GeoPackage file
st_write(habitat_within_buffer, "habitat_within_buffer.gpkg", driver = "GPKG", delete_dsn = TRUE)

cat("\nHabitat Data After Intersection:")
print(st_geometry(habitat_within_buffer))

unique(intersection$EUNIS2019C)

intersection<- st_reEUNIScombDintersection<- st_read("/Users/batume/Documents/R/GAL_git/prep/BD_HAB/habitat_within_buffer.gpkg")

# Coral habitats
coral <- intersection[intersection$EUNIScomb %in% c("A6.611"), ]

# Kelp habitats
kelp <- intersection[intersection$EUNIScomb %in% c("A3.1", "A3.2", "A3.3"), ]

# Seagrass habitats
seagrass <- intersection[intersection$EUNIScomb %in% c("A5.14", "A5.15"), ]

# Saltmarsh – if present, look for matching terms in EUNIScombD or Substrate
saltmarsh <- intersection[grepl("saltmarsh", intersection$EUNIScombD, ignore.case = TRUE), ]

# Tidal flats
tidal_flat <- intersection[grepl("A5.3|A5.2", intersection$EUNIScomb), ]

# Soft-bottom (muddy and sandy substrates)
softbottom <- intersection[grepl("A5.4|A6.6", intersection$EUNIScomb), ]

st_write(coral, "hab_coral_health.gpkg", driver = "GPKG")
st_write(kelp, "hab_kelp_health.gpkg", driver = "GPKG")
st_write(seagrass, "hab_seagrass_health.gpkg", driver = "GPKG")
st_write(saltmarsh, "hab_saltmarsh_health.gpkg", driver = "GPKG")
st_write(tidal_flat, "hab_tidal_flat_health.gpkg", driver = "GPKG")
st_write(softbottom, "hab_softbottom_health.gpkg", driver = "GPKG")

library(ggplot2)

# Create a custom theme
theme_hab <- theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank()
  )

# Define output directory
output_dir <- "/Users/batume/Documents/R/GAL_git/prep/BD_HAB/"
# Coral
p_coral <- ggplot() +
  geom_sf(data = buffer, fill = NA, color = "black", linetype = "dashed") +
  geom_sf(data = coral, fill = "coral", color = "black", size = 0.1) +
  ggtitle("Coral Habitats") +
  theme_hab
ggsave(filename = file.path(output_dir, "coral_habitats.png"), plot = p_coral, width = 8, height = 6)

# Kelp
p_kelp <- ggplot() +
  geom_sf(data = buffer, fill = NA, color = "black", linetype = "dashed") +
  geom_sf(data = kelp, fill = "darkgreen", color = "black", size = 0.1) +
  ggtitle("Kelp Habitats") +
  theme_hab
ggsave(filename = file.path(output_dir, "kelp_habitats.png"), plot = p_kelp, width = 8, height = 6)

# Seagrass
p_seagrass <- ggplot() +
  geom_sf(data = buffer, fill = NA, color = "black", linetype = "dashed") +
  geom_sf(data = seagrass, fill = "lightgreen", color = "black", size = 0.1) +
  ggtitle("Seagrass Habitats") +
  theme_hab
ggsave(filename = file.path(output_dir, "seagrass_habitats.png"), plot = p_seagrass, width = 8, height = 6)

# Saltmarsh
p_saltmarsh <- ggplot() +
  geom_sf(data = buffer, fill = NA, color = "black", linetype = "dashed") +
  geom_sf(data = saltmarsh, fill = "khaki", color = "black", size = 0.1) +
  ggtitle("Saltmarsh Habitats") +
  theme_hab
ggsave(filename = file.path(output_dir, "saltmarsh_habitats.png"), plot = p_saltmarsh, width = 8, height = 6)

# Tidal Flat
p_tidal_flat <- ggplot() +
  geom_sf(data = buffer, fill = NA, color = "black", linetype = "dashed") +
  geom_sf(data = tidal_flat, fill = "sandybrown", color = "black", size = 0.1) +
  ggtitle("Tidal Flat Habitats") +
  theme_hab
ggsave(filename = file.path(output_dir, "tidal_flat_habitats.png"), plot = p_tidal_flat, width = 8, height = 6)

# Soft-bottom
p_softbottom <- ggplot() +
  geom_sf(data = buffer, fill = NA, color = "black", linetype = "dashed") +
  geom_sf(data = softbottom, fill = "slategray", color = "black", size = 0.1) +
  ggtitle("Soft-bottom Habitats") +
  theme_hab
ggsave(filename = file.path(output_dir, "softbottom_habitats.png"), plot = p_softbottom, width = 8, height = 6)


# Load patchwork
library(patchwork)

# Arrange plots in a 3x2 grid
combined_plot <- (p_coral + p_kelp + p_seagrass) /
  (p_saltmarsh + p_tidal_flat + p_softbottom) +
  plot_layout(guides = "collect") +
  plot_annotation(title = "Marine Habitat Types in Galicia Region")

# Save to a single PNG (slightly smaller than A4: 11 x 7.5 inches)
ggsave(filename = file.path(output_dir, "all_habitats_combined.png"),
       plot = combined_plot,
       width = 11, height = 7.5, dpi = 300)



#DOWNLOADED DATA FROM https://habitats.oceanplus.org
seagrasses<-st_read("/Users/batume/Documents/R/GAL_git/prep/BD_HAB/014_001_WCMC013-014_SeagrassPtPy2021_v7_1/01_Data/WCMC013_014_Seagrasses_Py_v7_1.shp")
corals<-st_read("/Users/batume/Documents/R/GAL_git/prep/BD_HAB/14_001_WCMC001_ColdCorals2017_v5_1/01_Data/WCMC001_ColdCorals2017_Py_v5_1.shp")
satlmarshes<-st_read("/Users/batume/Documents/R/GAL_git/prep/BD_HAB/WCMC027_Saltmarsh_v6_1/01_Data/WCMC027_Saltmarshes_Py_v6_1.shp")
