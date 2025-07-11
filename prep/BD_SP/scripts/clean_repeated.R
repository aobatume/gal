library(sf)
library(dplyr)
library(tools)

sf_use_s2(FALSE)

# --- Paths ---
intersections_dir <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections"
cleaned_dir <- file.path(intersections_dir, "cleaned")
dir.create(cleaned_dir, showWarnings = FALSE)

# --- List all .gpkg files ---
gpkg_files <- list.files(
  path = intersections_dir,
  pattern = "\\.gpkg$",
  full.names = TRUE
)

# --- Clean all files ---
for (file_path in gpkg_files) {
  file_name <- basename(file_path)
  cleaned_path <- file.path(cleaned_dir, paste0("cleaned_", file_path_sans_ext(file_name), ".gpkg"))
  message("🔧 Processing: ", file_name)
  
  tryCatch({
    # Try to read with explicit geometry column (if 'geom' exists)
    raw <- st_read(file_path, quiet = TRUE)
    
    # Check for multiple geometry columns and force use of 'geom' if available
    geom_cols <- names(raw)[sapply(raw, inherits, what = "sfc")]
    
    if (length(geom_cols) > 1 && "geom" %in% geom_cols) {
      raw <- st_set_geometry(raw, "geom")
    } else if (length(geom_cols) == 1) {
      raw <- st_set_geometry(raw, geom_cols[1])
    } else {
      stop("❌ No valid geometry columns found.")
    }
    
    # Drop conflicting geometry-like columns (non-sfc)
    raw <- raw %>% select(!matches("(?i)^shape_.*|^geom$", perl = TRUE)) %>%
      st_set_geometry("geom")  # re-assert geometry
    
    st_write(raw, cleaned_path, delete_dsn = TRUE, quiet = TRUE)
    message("✅ Cleaned and saved: ", cleaned_path)
    
  }, error = function(e) {
    message("❌ Failed: ", file_name, " → ", e$message)
  })
}

### eliminate duplicated



sf_use_s2(FALSE)

# --- Paths ---
intersections_dir <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections"
cleaned_dir <- file.path(intersections_dir, "cleaned")
dir.create(cleaned_dir, showWarnings = FALSE)

# --- List cleaned .gpkg files ---
gpkg_files <- list.files(
  path = cleaned_dir,
  pattern = "^cleaned_.*\\.gpkg$",
  full.names = TRUE
)

# --- Read all cleaned files with 'source_file' tag ---
all_data <- lapply(gpkg_files, function(fp) {
  message("📥 Reading: ", basename(fp))
  st_read(fp, quiet = TRUE) %>%
    mutate(source_file = file_path_sans_ext(gsub("^cleaned_", "", basename(fp))))
}) %>%
  bind_rows()

# --- Deduplicate: prefer BIRDS_intersection_IUCN.gpkg if present ---
dedup_data <- all_data %>%
  group_by(sci_name) %>%
  arrange(desc(source_file == "BIRDS_intersection_IUCN")) %>%
  slice(1) %>%
  ungroup()

# --- Write per-original source file ---
cleaned_output_dir <- file.path(cleaned_dir, "deduplicated")
dir.create(cleaned_output_dir, showWarnings = FALSE)

original_files <- unique(dedup_data$source_file)

for (f in original_files) {
  subset <- dedup_data %>%
    filter(source_file == f) %>%
    select(-source_file)
  
  out_path <- file.path(cleaned_output_dir, paste0("cleaned_", f, ".gpkg"))
  st_write(subset, out_path, delete_dsn = TRUE, quiet = TRUE)
  message("✅ Saved deduplicated: ", out_path)
}




library(sf)
library(dplyr)
library(readr)
library(tools)

# --- Directory with cleaned & deduplicated GPKG files ---
cleaned_dir <- "/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections/cleaned/deduplicated"

# --- List cleaned GPKG files ---
gpkg_files <- list.files(
  path = cleaned_dir,
  pattern = "\\.gpkg$",
  full.names = TRUE,
  recursive = FALSE
)

# --- Function to extract data ---
extract_data <- function(gpkg_path) {
  tryCatch({
    data <- st_read(gpkg_path, quiet = TRUE)
    
    if (!all(c("sci_name", "category") %in% names(data))) {
      warning("⚠️ Missing required columns in: ", basename(gpkg_path))
      return(NULL)
    }
    
    data %>%
      mutate(
        sci_name = tolower(sci_name),
        area_km2 = as.numeric(st_area(.)) / 1e6,
        source_file = file_path_sans_ext(basename(gpkg_path))
      ) %>%
      select(sci_name, source_file, area_km2, category)
    
  }, error = function(e) {
    warning("❌ Failed to read ", basename(gpkg_path), ": ", e$message)
    return(NULL)
  })
}

# --- Combine all cleaned files ---
all_data <- lapply(gpkg_files, extract_data) %>%
  bind_rows()

# --- Aggregate by species ---
species_summary <- all_data %>%
  group_by(sci_name) %>%
  summarise(
    source_file = paste(unique(source_file), collapse = ";"),
    iucn_category = paste(unique(category), collapse = ";"),
    area_km2 = round(sum(area_km2, na.rm = TRUE), 2),
    .groups = "drop"
  )

any(duplicated(species_summary$sci_name))

options(max.print = nrow(species_summary))
print(species_summary$sci_name)

# --- Save CSV ---
output_csv <- file.path(cleaned_dir, "species_area_iucn_summary_deduplicated.csv")
write_csv(species_summary, output_csv)
message("✅ Species summary saved to: ", output_csv)