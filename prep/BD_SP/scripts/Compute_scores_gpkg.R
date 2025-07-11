library(sf)
library(dplyr)
library(stringr)
library(tools)
library(readr)

# --- Settings ---
sf_use_s2(FALSE)


gpkg_files <- list.files(
     "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections/cleaned/deduplicated",
     pattern = ".gpkg$", full.names = TRUE
   )
output_species_log_dir <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/included_species_logs2"
dir.create(output_species_log_dir, showWarnings = FALSE, recursive = TRUE)


### CALCULATE SCORES PER SPECIES 


process_gpkg_species <- function(gpkg_path) {
  message("⏳ Reading: ", basename(gpkg_path))
  
  tryCatch({
    data <- st_read(gpkg_path, quiet = TRUE)
    if (!all(c("grid_id", "category", "risk_weight", "sci_name") %in% names(data))) {
      message("❌ Required columns missing in ", basename(gpkg_path))
      return(NULL)
    }
    
    data <- data %>%
      mutate(area_km2 = as.numeric(st_area(.)) / 1e6)
    
    result <- data %>%
      mutate(area_km2 = as.numeric(st_area(.)) / 1e6) %>%
      group_by(sci_name, grid_id) %>%
      summarise(
        weighted_risk = sum(risk_weight * area_km2, na.rm = TRUE),
        cell_area = sum(area_km2, na.rm = TRUE),
        category = first(category),
        .groups = "drop"
      ) %>%
      group_by(sci_name, category) %>%
      summarise(
        total_weighted_risk = sum(weighted_risk, na.rm = TRUE),
        total_area = sum(cell_area, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      mutate(
        mean_species_risk = total_weighted_risk / total_area,
        biodiversity_score = pmin(pmax((mean_species_risk - 0.25) / (1.0 - 0.25), 0), 1)
      ) %>%
      select(species = sci_name, iucn_category = category, area_km2 = total_area, biodiversity_score)
    return(result)
    
  }, error = function(e) {
    message("❌ Error in ", basename(gpkg_path), ": ", e$message)
    return(NULL)
  })
}

#Run all files
all_species_results <- lapply(gpkg_files, process_gpkg_species)
final_df <- bind_rows(all_species_results)

# Save 
write_csv(final_df, file.path(output_species_log_dir, "all_species_scores_multi_species.csv"))
final_df_no_geom <- st_drop_geometry(final_df)
final_df_no_geom_round <- final_df_no_geom
final_df_no_geom_round[sapply(final_df_no_geom_round, is.numeric)] <- 
  round(final_df_no_geom_round[sapply(final_df_no_geom_round, is.numeric)], 2)

write.csv(final_df_no_geom_round, "all_species_scores_multi_species_rounded_data.csv", row.names = FALSE)
write_csv(final_df_no_geom, file.path(output_species_log_dir, "all_species_scores_multi_species_no_geom.csv"))



#CALCULATE OVERALL SCORE WITHOUT EX SPECIES

if (nrow(final_df) > 0) {
  final_df_filtered <- final_df %>% filter(iucn_category != "EX")
  
  total_area <- sum(final_df_filtered$area_km2, na.rm = TRUE)
  
  final_df_filtered <- final_df_filtered %>%
    mutate(area_weight = area_km2 / total_area)
  
  ohi_species_condition_score <- sum(final_df_filtered$biodiversity_score * final_df_filtered$area_weight, na.rm = TRUE)
  ohi_species_condition_score <- round(ohi_species_condition_score, 4)
  
  writeLines(
    paste0("species_condition_score,", ohi_species_condition_score),
    con = file.path(output_species_log_dir, "species_condition_score.csv")
  )
  
  message("✅ OHI Species Condition Score (excluding EX): ", ohi_species_condition_score)
} else {
  message("⚠️ No valid species data to compute OHI score.")
}


