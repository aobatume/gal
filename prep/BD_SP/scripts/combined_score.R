library(readr)
library(dplyr)

# --- Directory with individual CSVs ---
csv_dir <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/included_species_logs/CSV_STATUS"

# --- List all CSV files ---
csv_files <- list.files(csv_dir, pattern = "\\.csv$", full.names = TRUE)

# --- Read and combine all CSVs ---
combined_df <- csv_files %>%
  lapply(read_csv, show_col_types = FALSE) %>%
  bind_rows()

# --- Make sure numeric columns are correctly typed ---
combined_df <- combined_df %>%
  mutate(
    area_km2 = as.numeric(area_km2),
    biodiversity_score = as.numeric(biodiversity_score)
  )

# --- Compute area-weighted biodiversity score ---
overall_score <- with(combined_df, sum(biodiversity_score * area_km2, na.rm = TRUE) / sum(area_km2, na.rm = TRUE))
overall_score <- round(overall_score, 4)

# --- Output the result ---
cat("✅ Overall Biodiversity Status Score:", overall_score, "\n")

write_csv(combined_df, file.path(csv_dir, "combined_biodiversity_scores.csv"))
