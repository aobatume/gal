library(dplyr)
library(stringr)

# Define directories
input_dir <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output"
inter_dir <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections/output"

# List CSV files
input_files <- list.files(input_dir, pattern = "_unique_sci_names\\.csv$", full.names = TRUE)
inter_files <- list.files(inter_dir, pattern = "_unique_sci_names\\.csv$", full.names = TRUE)

# Initialize result list
results <- list()

# Loop through each input file
for (input_file in input_files) {
  # Extract base name (e.g., ABALONES)
  base <- str_remove(basename(input_file), "_unique_sci_names\\.csv$")
  
  # Read input species
  input_df <- read.csv(input_file, stringsAsFactors = FALSE)
  if (!"sci_name" %in% names(input_df)) next
  input_species <- unique(trimws(input_df$sci_name))
  
  # Try to find matching intersection file
  matching_inter <- inter_files[str_detect(inter_files, fixed(base, ignore_case = TRUE))]
  
  if (length(matching_inter) > 0) {
    inter_df <- read.csv(matching_inter[1], stringsAsFactors = FALSE)
    inter_species <- if ("sci_name" %in% names(inter_df)) unique(trimws(inter_df$sci_name)) else character(0)
  } else {
    inter_species <- character(0)
  }
  
  # Build output comparison
  comparison <- data.frame(
    sci_name = input_species,
    present = ifelse(input_species %in% inter_species, "yes", "no"),
    file = base,
    stringsAsFactors = FALSE
  )
  
  results[[base]] <- comparison
}

# Combine all results
final_df <- bind_rows(results)

table(final_df$present)
# Print all species where present == 1
subset(final_df, present == 1)

# Write to single CSV
write.csv(final_df, file = file.path(input_dir, "species_presence_comparison.csv"), row.names = FALSE)
