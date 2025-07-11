library(sf)
library(dplyr)
library(ggplot2)
library(units)

# Define IUCN status mapping
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

# Define file path
dir_path <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections"
gpkg_files <- list.files(path = dir_path, pattern = "\\.gpkg$", full.names = TRUE)

# Load your clipped grid (update this path if necessary)
# grid_clipped <- st_read("/path/to/your/grid_clipped.gpkg")

# Create output directory for plots
output_dir <- file.path(dir_path, "plots/deduplicated/")
dir.create(output_dir, showWarnings = FALSE)

# Loop through files and generate plots
for (file in gpkg_files) {
  message("Processing: ", basename(file))
  
  # Try-catch block to avoid full script failure
  try({
    species_data <- st_read(file, quiet = TRUE) %>%
      mutate(marine = tolower(marine) == "true")
    
    species_filtered <- species_data %>%
      filter(marine == TRUE, category %in% names(iucn_status_map)) %>%
      mutate(risk_weight = iucn_status_map[category]) %>%
      filter(!is.na(risk_weight))
    
    if (nrow(species_filtered) == 0) {
      message("  No valid marine species with risk data.")
      next
    }
    
    species_filtered <- st_transform(species_filtered, st_crs(grid_clipped))
    
    intersection <- st_intersection(species_filtered, grid_clipped)
    
    if (nrow(intersection) == 0) {
      message("  No spatial intersection with grid.")
      next
    }
    
    intersection <- intersection %>%
      mutate(area_km2 = st_area(.) %>% set_units("km^2") %>% as.numeric())
    
    cell_risks <- intersection %>%
      group_by(grid_id) %>%
      summarise(
        weighted_risk = sum(risk_weight * area_km2, na.rm = TRUE),
        cell_area = sum(area_km2, na.rm = TRUE),
        .groups = "drop"
      )
    
    mean_species_risk <- sum(cell_risks$weighted_risk) / sum(cell_risks$cell_area)
    
    max_risk <- 0.75
    score <- (max_risk - mean_species_risk) / max_risk
    score <- pmin(pmax(score, 0), 1)
    
    # Create plot
    plot_title <- tools::file_path_sans_ext(basename(file))
    p <- ggplot(data = data.frame(score, mean_species_risk), aes(x = "", y = score)) +
      geom_col(fill = "steelblue") +
      ylim(0, 1) +
      labs(
        title = paste0("Biodiversity Score: ", plot_title),
        subtitle = paste0("Mean species risk: ", round(mean_species_risk, 4)),
        y = "Rescaled Biodiversity Score",
        x = NULL
      ) +
      theme_minimal() +
      theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
    
    # Save plot
    output_file <- file.path(output_dir, paste0(plot_title, "_score_plot.png"))
    ggsave(output_file, plot = p, width = 6, height = 4)
    message("  Saved plot to: ", output_file)
    
  }, silent = TRUE)
}



## PLOTS FOR DEDUPLICATED


buffer_grid<-st_read("/Users/batume/Documents/R/GAL_git/prep/BD_SP/buffer_grid.gpkg")

# Load your buffer grid
buffer_grid <- st_read("/Users/batume/Documents/R/GAL_git/prep/BD_SP/buffer_grid.gpkg")

# Create output directory for plots
output_dir <- file.path(dir_path, "plots/deduplicated/")
dir.create(output_dir, showWarnings = FALSE)

# Loop through files and generate plots
for (file in gpkg_files) {
  message("Processing: ", basename(file))
  
  try({
    species_data <- st_read(file, quiet = TRUE)
    
    species_filtered <- species_data %>%
      filter(category %in% names(iucn_status_map)) %>%
      mutate(risk_weight = iucn_status_map[category]) %>%
      filter(!is.na(risk_weight))
    
    if (nrow(species_filtered) == 0) {
      message("  No valid species with risk data.")
      next
    }
    
    species_filtered <- st_transform(species_filtered, st_crs(buffer_grid))
    
    intersection <- st_intersection(species_filtered, buffer_grid)
    
    if (nrow(intersection) == 0) {
      message("  No spatial intersection with grid.")
      next
    }
    
    intersection <- intersection %>%
      mutate(area_km2 = st_area(.) %>% set_units("km^2") %>% as.numeric())
    
    cell_risks <- intersection %>%
      group_by(grid_id) %>%
      summarise(
        weighted_risk = sum(risk_weight * area_km2, na.rm = TRUE),
        cell_area = sum(area_km2, na.rm = TRUE),
        .groups = "drop"
      )
    
    mean_species_risk <- sum(cell_risks$weighted_risk) / sum(cell_risks$cell_area)
    
    max_risk <- 0.75
    score <- (max_risk - mean_species_risk) / max_risk
    score <- pmin(pmax(score, 0), 1)
    
    # Create plot
    plot_title <- tools::file_path_sans_ext(basename(file))
    p <- ggplot(data = data.frame(score, mean_species_risk), aes(x = "", y = score)) +
      geom_col(fill = "steelblue") +
      ylim(0, 1) +
      labs(
        title = paste0("Biodiversity Score: ", plot_title),
        subtitle = paste0("Mean species risk: ", round(mean_species_risk, 4)),
        y = "Rescaled Biodiversity Score",
        x = NULL
      ) +
      theme_minimal() +
      theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
    
    # Save plot
    output_file <- file.path(output_dir, paste0(plot_title, "_score_plot.png"))
    ggsave(output_file, plot = p, width = 6, height = 4)
    message("  Saved plot to: ", output_file)
    
  }, silent = FALSE)  # Recommend disabling silent while debugging
}
