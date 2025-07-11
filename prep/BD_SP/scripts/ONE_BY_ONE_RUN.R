library(sf)
library(dplyr)
library(stringr)
library(tools)
library(readr)

# --- Settings ---
sf_use_s2(FALSE)

# --- Batch Processing ---
gpkg_files <- list.files("/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections/cleaned/deduplicated", pattern = ".gpkg$", full.names = TRUE)
output_species_log_dir <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/included_species_logs2"
dir.create(output_species_log_dir, showWarnings = FALSE, recursive = TRUE)


# --- Constants ---
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



# --- Process From Existing Intersection ---
process_from_intersection <- function(gpkg_path) {
  species_name <- gsub("_intersection2$", "", file_path_sans_ext(basename(gpkg_path)))
  message("⏳ Processing: ", species_name)
  
  tryCatch({
    intersection <- st_read(gpkg_path, quiet = TRUE)
    
    if (!all(c("grid_id", "category", "risk_weight") %in% names(intersection))) {
      message("❌ Required columns not found in GPKG.")
      return(NULL)
    }
    
    intersection <- intersection %>%
      mutate(area_km2 = as.numeric(st_area(.)) / 1e6)
    
    total_area <- sum(intersection$area_km2, na.rm = TRUE)
    
    # Biodiversity score
    cell_risks <- intersection %>%
      group_by(grid_id) %>%
      summarise(
        weighted_risk = sum(risk_weight * area_km2, na.rm = TRUE),
        cell_area = sum(area_km2, na.rm = TRUE),
        .groups = "drop"
      )
    
    mean_species_risk <- sum(cell_risks$weighted_risk) / sum(cell_risks$cell_area)
    min_risk <- 0.25
    max_risk <- 1.0
    score <- (mean_species_risk - min_risk) / (max_risk - min_risk)
    score <- pmin(pmax(score, 0), 1)
    
    result <- data.frame(
      species = species_name,
      iucn_category = paste(unique(intersection$category), collapse = ";"),
      area_km2 = round(total_area, 2),
      biodiversity_score = round(score, 4)
    )
    
    return(result)
    
  }, error = function(e) {
    message("❌ Failed: ", species_name, " - ", e$message)
    return(NULL)
  })
}



all_results <- lapply(gpkg_files, process_from_intersection)
final_df <- bind_rows(all_results)

write_csv(final_df, file.path(output_species_log_dir, "all_species_scores_new.csv"))



# --- Run for Existing GPKG ---
result <- process_from_intersection(intersection_gpkg_path)
if (!is.null(result)) {
  species_name <- gsub("_intersection2$", "", file_path_sans_ext(basename(intersection_gpkg_path)))
  output_csv <- file.path(output_species_log_dir, paste0(species_name, ".csv"))
  write_csv(result, output_csv)
  message("✅ Output saved to: ", output_csv)
} else {
  message("⚠️ No valid result generated.")
}




