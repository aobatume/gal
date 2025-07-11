library(sf)
library(dplyr)
library(readr)
library(tools)

# --- Settings ---
sf_use_s2(FALSE)

# --- Paths ---
intersections_dir <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections"
output_file <- file.path(intersections_dir, "species_area_risk_scores2.csv")

gpkg_files <- list.files(
  path = intersections_dir,
  pattern = "\\.gpkg$",
  full.names = TRUE
)

# --- Processing function ---
process_file <- function(gpkg_path) {
  file_name <- file_path_sans_ext(basename(gpkg_path))
  message("⏳ Processing: ", file_name)
  
  tryCatch({
    data <- st_read(gpkg_path, quiet = TRUE)
    
    if (!all(c("sci_name", "grid_id", "risk_weight", "category") %in% names(data))) {
      warning("⚠️ Missing required columns in: ", file_name)
      return(NULL)
    }
    
    data <- data %>%
      mutate(
        sci_name = tolower(sci_name),
        area_km2 = as.numeric(st_area(.)) / 1e6
      ) %>%
      st_drop_geometry()
    
    result <- data %>%
      group_by(sci_name) %>%
      summarise(
        source_file = file_name,
        iucn_category = paste(unique(category), collapse = ";"),
        area_km2 = sum(area_km2, na.rm = TRUE),
        mean_risk = {
          cell_risks <- group_by(., grid_id) %>%
            summarise(
              weighted_risk = sum(risk_weight * area_km2, na.rm = TRUE),
              cell_area = sum(area_km2, na.rm = TRUE),
              .groups = "drop"
            )
          sum(cell_risks$weighted_risk, na.rm = TRUE) / sum(cell_risks$cell_area, na.rm = TRUE)
        },
        .groups = "drop"
      ) %>%
      mutate(
        biodiversity_score = round(
          pmin(pmax((mean_risk - 0.25) / (1.0 - 0.25), 0), 1),
          4
        ),
        area_km2 = round(area_km2, 2)
      ) %>%
      select(sci_name, source_file, iucn_category, area_km2, biodiversity_score)
    
    return(result)
    
  }, error = function(e) {
    warning("❌ Error in ", file_name, ": ", e$message)
    return(NULL)
  })
}

# --- Apply to all files ---
all_scores <- lapply(gpkg_files, process_file) %>%
  bind_rows()

# --- Write output ---
write_csv(all_scores, output_file)
message("✅ Output saved to: ", output_file)


dropped <- anti_join(all_scores, all_scores_dedup, by = "sci_name")
print(dropped)


# e.g., areas that are suspiciously large
all_scores %>% filter(area_km2 > quantile(area_km2, 0.99))  # top 1% largest areas
all_scores %>% filter(area_km2 < quantile(area_km2, 0.01))
all_scores %>%
  mutate(z_area = (area_km2 - mean(area_km2)) / sd(area_km2)) %>%
  filter(abs(z_area) > 3)

repeated_species <- all_scores %>%
  group_by(sci_name) %>%
  filter(n() > 1) %>%
  arrange(sci_name)

# View results
print(repeated_species)

options(max.print = nrow(all_scores))
print(all_scores$sci_name)
