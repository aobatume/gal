library(sf)
library(dplyr)
library(readr)
library(tools)

# --- Set directory ---
intersections_dir <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections"

# --- List all GPKG files, excluding BIRDS_intersection.gpkg ---
gpkg_files <- list.files(
  path = intersections_dir,
  pattern = "\\.gpkg$",
  full.names = TRUE,
  recursive = FALSE
) %>%
  .[!grepl("BIRDS_intersection\\.gpkg$", .)]

# --- Function to extract species ---
extract_species <- function(gpkg_path) {
  tryCatch({
    data <- st_read(gpkg_path, quiet = TRUE)
    
    if (!"sci_name" %in% names(data)) {
      warning("⚠️ Missing 'sci_name' in: ", basename(gpkg_path))
      return(NULL)
    }
    
    data %>%
      st_drop_geometry() %>%
      distinct(sci_name) %>%
      mutate(source_file = file_path_sans_ext(basename(gpkg_path)))
    
  }, error = function(e) {
    warning("❌ Failed to read ", basename(gpkg_path), ": ", e$message)
    return(NULL)
  })
}

# --- Extract and combine ---
all_species <- lapply(gpkg_files, extract_species) %>%
  bind_rows()

# --- Save CSV ---
write_csv(all_species, file.path(intersections_dir, "all_species_by_file.csv"))
message("✅ Extracted species list saved to: all_species_by_file.csv")










########### TRY BITS ##################

library(sf)
library(dplyr)

df1 <- st_read("/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections/MARINEFISH_PART3_intersection.gpkg")
df2 <- st_read("/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections/SHARKS_RAYS_CHIMAERAS_intersection.gpkg")

head(df1)
species <- "Alopias superciliosus"

df1_sub <- df1 %>% filter(sci_name == species) %>% select(grid_id, risk_weight, category, geom)
df2_sub <- df2 %>% filter(sci_name == species) %>% select(grid_id, risk_weight, category, geom)

# Check summary stats for risk_weight
summary(df1_sub$risk_weight)
summary(df2_sub$risk_weight)

# Check categories
unique(df1_sub$category)
unique(df2_sub$category)

# Optionally, compare the areas and number of rows
nrow(df1_sub)
nrow(df2_sub)
sum(as.numeric(st_area(df1_sub)) / 1e6)
sum(as.numeric(st_area(df2_sub)) / 1e6)


#### Filter species with area less than 1 km²
# Load the CSV file
df <- read.csv("/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections/cleaned/deduplicated/species_area_iucn_summary_deduplicated.csv")


unlikely_species <- df %>%
  filter(area_km2 < 1.0) %>%
  arrange(area_km2)
print(unlikely_species$sci_name)


write.csv(unlikely_species, "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections/cleaned/deduplicated/unlikely_species_galicia_copy.csv", row.names = FALSE)

