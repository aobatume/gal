library(sf)
library(dplyr)

##CREATE GRID FOR THE BUFFER 

# Clean the environment
rm(list=ls())

# Additional base steps 
sf_use_s2(FALSE) # solves problems with latest version of sf for st_as_sf()

ABALONES <- st_read("/Users/batume/Documents/R/GAL_git/prep/BD_SP/BLENNIES.shp")
buffer_eez <- st_read("/Users/batume/Documents/R/GAL_git/MAPS/EEZ_BUFFER/galicia_fromohi.shp")

buffer_eez <- st_make_valid(buffer_eez)

# Ensure CRS is es29
buffer_eez <- st_transform(buffer_eez, crs = 3857)
ABALONES <- st_transform(ABALONES, crs = 3857)
# Get the bounding box
bbox <- st_bbox(buffer_eez)

# 0.5 degree ≈ ~55,000 meters (at equator)
cellsize_meters <- 55000

grid <- st_make_grid(
  buffer_eez,
  cellsize = cellsize_meters,
  what = "polygons",
  square = TRUE
)

# Convert to an sf object
grid_sf <- st_sf(grid_id = seq_along(grid), geometry = grid)

# Optionally clip the grid to the EEZ buffer (intersecting only)
grid_clipped <- st_intersection(grid_sf, buffer_eez)

# Plot to verify
plot(st_geometry(grid_clipped), col = NA, border = 'gray')
plot(st_geometry(buffer_eez), add = TRUE, border = 'blue')

# Save if needed
#st_write(grid_clipped, "grid_0.5deg_within_eez.gpkg")


## Calculate risks score (WE CALCULATED THE SCORES USING OTHER SCRIPT (ONE BY ONE))

# Step 1: Define IUCN status mapping
iucn_status_map <- c(
  "EX" = 0.0,
  "CR" = 0.2,
  "EN" = 0.4,
  "VU" = 0.6,
  "NT" = 0.8,
  "LC" = 1.0,
  "EW" = NA,
  "DD" = NA
)
species_data<-ABALONES
species_data <- species_data %>%
  mutate(marine = tolower(marine) == "true")

# Step 2: Filter and map risk weights
species_filtered <- species_data %>%
  filter(marine == TRUE, category %in% names(iucn_status_map)) %>%
  mutate(risk_weight = iucn_status_map[category]) %>%
  filter(!is.na(risk_weight))

# Step 3: Transform CRS to match grid (if needed)
species_filtered <- st_transform(species_filtered, st_crs(grid_clipped))

# Step 4: Intersect species with grid to find overlaps
intersection <- st_intersection(species_filtered, grid_clipped)

# Step 5: Compute intersection area (in km²)
intersection <- intersection %>%
  mutate(area_km2 = st_area(.) %>% units::set_units("km^2") %>% as.numeric())

# Step 6: Compute total weighted risk per grid cell
cell_risks <- intersection %>%
  group_by(grid_id) %>%
  summarise(
    weighted_risk = sum(risk_weight * area_km2, na.rm = TRUE),
    cell_area = sum(area_km2, na.rm = TRUE),
    .groups = "drop"
  )

# Step 7: Compute area-weighted mean species risk across the region
mean_species_risk <- sum(cell_risks$weighted_risk) / sum(cell_risks$cell_area)

# Step 8: Rescale to biodiversity score (1 = all LC, 0 = catastrophic at 75% extinct)
max_risk <- 0.75  # scaling floor (catastrophic threshold)
score <- (max_risk - mean_species_risk) / max_risk
score <- pmin(pmax(score, 0), 1)  # clamp between 0–1

# Final output
cat("Area-weighted mean species risk:", round(mean_species_risk, 4), "\n")
cat("Rescaled biodiversity status score:", round(score, 4), "\n")


#### MESSING 

table(species_data$marine, useNA = "ifany")
unique(species_data$category)

# Check result after filtering
nrow(species_filtered)
summary(st_is_empty(species_filtered))



##PLOTS 


library(ggplot2)

# Merge grid geometry with risk scores
# Remove geometry from cell_risks, then join
risk_map <- grid_clipped %>%
  left_join(st_drop_geometry(cell_risks), by = "grid_id")

# Replace NA risk values with 0 or NA (depending on intent)
# Uncomment next line to show 0 for cells with no species
# risk_map$weighted_risk[is.na(risk_map$weighted_risk)] <- 0

# Plot with ggplot2
ggplot() +
  geom_sf(data = risk_map, aes(fill = weighted_risk), color = "gray40", size = 0.1) +
  geom_sf(data = buffer_eez, fill = NA, color = "blue", size = 0.3) +
  scale_fill_viridis_c(option = "plasma", direction = -1, na.value = "white", name = "Risk") +
  coord_sf() +
  labs(
    title = "Grid-based Biodiversity Risk Map",
    subtitle = paste("Species:", unique(species_data$binomial)[1]),  # or use species name manually
    caption = "Risk score = Area-weighted by IUCN threat category"
  ) +
  theme_minimal()


# Plot the grid over the buffer zone
ggplot() +
  geom_sf(data = grid_in_buffer, fill = NA, color = "black", size = 0.3) +
  geom_sf(data = buffer_eez, fill = NA, color = "blue", size = 1) +
  ggtitle("0.5° Grid over Buffer Zone") +
  theme_minimal()


# Plot the grid and species distribution together
ggplot() +
  geom_sf(data = grid_in_buffer, fill = NA, color = "gray30", size = 0.3) +  # Grid
  geom_sf(data = buffer_eez, fill = NA, color = "blue", size = 1) +           # Buffer
  geom_sf(data = abalones_in_buffer, aes(fill = category), color = NA, alpha = 0.6) + # Abalone polygons colored by IUCN category
  scale_fill_viridis_d(option = "plasma", name = "IUCN Category") +          # Nice color scale
  theme_minimal() +
  labs(
    title = "Abalone Species Distribution inside 0.5° Grid",
    subtitle = "Colored by IUCN Category",
    caption = "Source: Your project data"
  ) +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12),
    plot.caption = element_text(size = 8),
    panel.grid.major = element_line(color = "transparent"),
    panel.background = element_rect(fill = "aliceblue")
  )






table(species_filtered$category)
table(species_filtered$risk_weight, useNA = "ifany")
summary(intersection$area_km2)
nrow(intersection)
hist(cell_risks$weighted_risk / cell_risks$cell_area)
