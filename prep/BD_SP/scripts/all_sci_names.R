library(sf)
library(dplyr)

# Set your working directory to where the .gpkg files are located
setwd("/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections/cleaned/deduplicated")  # Change this to your actual path

# List all GPKG files in the directory
gpkg_files <- list.files(pattern = "\\.gpkg$")

# Initialize a list to collect sci_names
sci_names_list <- list()

# Loop through each file and extract sci_name
for (file in gpkg_files) {
  message("Processing: ", file)
  try({
    data <- st_read(file, quiet = TRUE)
    if ("sci_name" %in% names(data)) {
      sci_names <- data %>% select(sci_name) %>% distinct()
      sci_names$source_file <- file  # Optionally keep track of the source file
      sci_names_list[[file]] <- sci_names
    } else {
      warning("sci_name column not found in: ", file)
    }
  })
}

# Combine all sci_names into a single data frame
all_sci_names <- bind_rows(sci_names_list)

# Optionally write to CSV
#write.csv(all_sci_names, "all_sci_names_deduplicated.csv", row.names = FALSE)

# Print a preview
print(head(all_sci_names))


# Drop geometry after combining
all_sci_names_df <- all_sci_names %>% st_drop_geometry()
write.csv(all_sci_names_df, "all_sci_names_deduplicated.csv", row.names = FALSE)
