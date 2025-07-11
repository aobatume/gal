library(dplyr)
library(readr)
library(stringr)
library(purrr)

# Path to input files and iconic species file
input_dir <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections/output"
iconic_file <-  "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/iconic_sp_Classified_complete.csv"

# List all input species CSVs (exclude intersections etc.)
input_files <- list.files(input_dir, pattern = "_unique_sci_names\\.csv$", full.names = TRUE)
input_files <- input_files[!str_detect(input_files, "intersection")]

# Load and clean iconic species
iconic_df <- read_csv(iconic_file, show_col_types = FALSE) %>%
  rename(sci_name = `Scientific name_accepted`) %>%
  mutate(sci_name = trimws(sci_name))

# Function to read each input file and label its source
read_input <- function(file) {
  df <- read_csv(file, show_col_types = FALSE) %>%
    mutate(
      sci_name = trimws(sci_name),
      file = tools::file_path_sans_ext(basename(file))
    )
  return(df)
}

# Read and bind all input files
all_inputs_df <- map_dfr(input_files, read_input)

# Find which iconic species are present
iconic_matches <- all_inputs_df %>%
  filter(sci_name %in% iconic_df$sci_name)

# Optional: Summary of how many iconic species were found
summary_stats <- iconic_matches %>%
  summarise(
    total_iconic_species = n_distinct(sci_name),
    total_files_with_iconic = n_distinct(file)
  )

# Save the matched iconic species table
write_csv(iconic_matches, file.path(input_dir, "iconic_species_found_in_inputs.csv"))



library(dplyr)
library(readr)
library(stringdist)
library(fuzzyjoin)

# Load iconic species file and rename column
iconic_df <- read_csv("/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/iconic_sp_Classified_complete.csv") %>%
  rename(sci_name = `Scientific name_accepted`)

# List all input CSV files with unique species
input_files <- list.files("/Users/batume/Documents/R/GAL_git/prep/BD_SP/output", pattern = "_unique_sci_names.csv$", full.names = TRUE)

# Read and combine all input files into a single data frame
all_inputs_df <- lapply(input_files, function(file) {
  df <- read_csv(file, show_col_types = FALSE)
  df$file <- tools::file_path_sans_ext(basename(file))
  return(df)
}) %>%
  bind_rows()

# Fuzzy join based on sci_name using Jaro-Winkler distance
fuzzy_matches <- stringdist_inner_join(iconic_df, all_inputs_df, by = "sci_name", max_dist = 0.10, method = "jw")

# Clean and rename columns
fuzzy_matches_clean <- fuzzy_matches %>%
  rename(iconic_sci_name = sci_name.x, matched_sci_name = sci_name.y) %>%
  select(iconic_sci_name, matched_sci_name, file)

# Save results
write_csv(fuzzy_matches_clean, "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/fuzzy_iconic_matches.csv")




unique(iconic_df$sci_name)


# Load the necessary libraries
library(dplyr)

# Load the datasets
species_presence_comparison <- read.csv("/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/species_presence_comparison.csv")
iconic_df <- read.csv("/path/to/your/iconic_sp_Classified_complete.csv")

# Rename the column in iconic_df to match the one in the comparison file (if necessary)
colnames(iconic_df)[colnames(iconic_df) == "Scientific name_accepted"] <- "sci_name"

# Find how many iconic species are present in the comparison file
matched_species <- iconic_df$sci_name %in% species_presence_comparison$sci_name

# Count how many iconic species appear in the comparison file
sum(matched_species)
