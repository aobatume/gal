install.packages("remotes")
remotes::install_github("LifeWatch/eurobis")  # eurobis package from GitHub

library(eurobis)
library(sf)
library(dplyr)

# Load your shapefile
buffer_path <- "/Users/batume/Documents/R/GAL_git/MAPS/EEZ_BUFFER/galicia_fromohi.shp"
buffer <- st_read(buffer_path)

# Check the CRS to make sure it matches with the one used in EurOBIS data (likely WGS84 - EPSG:4326)
st_crs(buffer)  # Check the CRS

# Ensure the buffer is in the same CRS as the EurOBIS data (WGS84)
buffer <- st_transform(buffer, crs = 4326)  # WGS84: EPSG:4326

# Initialize a list to store results
species_in_buffer <- list()

# Loop through the species list
for (sp in species_list) {
  cat("Checking:", sp, "\n")
  
  # Query the occurrence data for each species
  occ <- tryCatch({
    eurobis_search(scientificname = sp)
  }, error = function(e) return(NULL))
  
  if (!is.null(occ) && "longitude" %in% names(occ) && "latitude" %in% names(occ)) {
    # Create a spatial object for the occurrences
    occ_sf <- st_as_sf(occ, coords = c("longitude", "latitude"), crs = 4326)
    
    # Check if the occurrence points are within the buffer region
    within_buffer <- st_intersects(occ_sf, buffer, sparse = FALSE)
    
    # Store species that have occurrences within the buffer region
    if (any(within_buffer)) {
      species_in_buffer[[sp]] <- occ[within_buffer, ]
    }
  }
}

# View the species found in the buffer
species_in_buffer

# Check CRS of the buffer shapefile
st_crs(buffer)  # Should return EPSG:4326 for WGS84

# Example: Check the CRS of occurrence data (just checking the first one)
occ <- eurobis_search(scientificname = species_list[1])
occ_sf <- st_as_sf(occ, coords = c("longitude", "latitude"), crs = 4326)
st_crs(occ_sf)  # Should also return EPSG:4326


#######

species_presence_comparison <- read.csv("/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/species_presence_comparison.csv")
head(species_presence_comparison)
table(species_presence_comparison$present)

species_absent <- subset(species_presence_comparison, present == "yes")
install.packages("readxl")
library(readxl)
# Load the Excel file
tabla_ceeei <- read_excel("/Users/batume/Documents/R/GAL_git/prep/BD_SP/inv_sp/Tabla_CEEEIcompleta.xlsx")

# View the first rows and column names to identify the scientific name column
head(tabla_ceeei)
colnames(tabla_ceeei)

tabla_ceeei$sci_name_clean <- gsub("^([A-Za-z]+\\s+[a-z-]+).*", "\\1", tabla_ceeei[["Nombre científico actualizado"]])

# Lowercase and trim
tabla_ceeei$sci_name_clean <- tolower(trimws(tabla_ceeei$sci_name_clean))

# Also clean the absent species names
species_absent$sci_name_clean <- tolower(trimws(species_absent$sci_name))


# Find intersection: species in tabla_ceeei that are also absent
overlap_absent <- tabla_ceeei[tabla_ceeei$sci_name_clean %in% species_absent$sci_name, ]

# View result
head(overlap_absent)
nrow(overlap_absent)


#########