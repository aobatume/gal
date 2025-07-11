# Load libraries
library(worrms)
library(dplyr)
library(purrr)
library(readr)
library(stringr)
library(tibble)

# Read and clean original data
pesca_galicia <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/total_summary_FAO_PESCADEGALICIA.csv") %>%
  mutate(source = "pesca_galicia")

pesca_galicia_clean <- pesca_galicia %>%
  mutate(
    FAOcode = toupper(FAOcode),
    catch_tonnes = total_kg / 1000
  ) %>%
  select(FAOcode, year, catch_tonnes, Galician_name, FAOcode, total_kg, total_euros, 
         Scientific_name, English_name, Family, Order.or.higher.taxa, source) %>%
  filter(!is.na(FAOcode), !is.na(catch_tonnes), catch_tonnes > 0) %>%
  rename(scientificname = Scientific_name)

# --- FUNCTION 1: Species-level lookup ---
unique_species <- unique(pesca_galicia_clean$scientificname)

get_worms_taxonomy <- function(species_name) {
  res <- wm_records_name(name = species_name)
  
  if (length(res) == 0 || (is.data.frame(res) && nrow(res) == 0)) return(tibble())
  
  entry <- if (is.data.frame(res)) res[1, ] else res[[1]]
  
  tibble(
    scientificname = entry$scientificname,
    kingdom        = entry$kingdom,
    phylum         = entry$phylum,
    class          = entry$class,
    order          = entry$order,
    family         = entry$family,
    genus          = entry$genus,
    AphiaID        = entry$AphiaID
  )
}

# Step 5: Safe version with delay
safe_lookup <- possibly(get_worms_taxonomy, otherwise = tibble())

taxonomy_list <- map(unique_species, ~{
  Sys.sleep(1)  # avoid rate-limiting
  safe_lookup(.x)
})

taxonomy_df <- bind_rows(taxonomy_list)

# Merge to assign taxonomy
pesca_tax <- pesca_galicia_clean %>%
  left_join(taxonomy_df, by = "scientificname")

# --- STEP 2: Find unresolved ---
missing_species <- pesca_tax %>%
  filter(is.na(phylum)) %>%
  distinct(scientificname) %>%
  pull(scientificname)

# --- FUNCTION 2: Genus-level lookup ---
get_genus_taxonomy <- function(genus_name) {
  res <- wm_records_name(name = genus_name)
  
  if (length(res) == 0 || (is.data.frame(res) && nrow(res) == 0)) return(tibble())
  
  entry <- if (is.data.frame(res)) res[1, ] else res[[1]]
  
  tibble(
    scientificname = paste0(genus_name, " spp"),
    kingdom        = entry$kingdom,
    phylum         = entry$phylum,
    class          = entry$class,
    order          = entry$order,
    family         = entry$family,
    genus          = entry$genus,
    AphiaID        = entry$AphiaID
  )
}

safe_genus_lookup <- possibly(get_genus_taxonomy, otherwise = tibble())

# --- STEP 3: Genus-level match for "xxx spp" ---
genus_only <- sub(" spp$", "", missing_species)
genus_tax_list <- map(genus_only, ~{
  Sys.sleep(1)
  safe_genus_lookup(.x)
})
genus_taxonomy_df <- bind_rows(genus_tax_list)
saveRDS(taxonomy_df, file = "/Users/batume/Documents/R/GAL_git/prep/FIS/taxonomy_df_pesgal.rds")

# --- STEP 4: Manual fixes for known names ---
manual_fixes <- tribble(
  ~scientificname,              ~kingdom, ~phylum, ~class,           ~order,         ~family,      ~genus,     ~AphiaID,
  "Barbus barbus",              "Animalia", "Chordata", "Actinopterygii", "Cypriniformes", "Cyprinidae", "Barbus",   154294,
  "Algae",                      "Plantae", "Chlorophyta", NA, NA, NA, NA, NA,
  "Gelidium spp",               "Plantae", "Rhodophyta", NA, NA, "Gelidiaceae", "Gelidium", NA,
  "Porphyra spp",               "Plantae", "Rhodophyta", NA, NA, "Bangiaceae", "Porphyra", NA,
  "Patella spp",               "Animalia", "Mollusca", "Gastropoda", "Patellogastropoda", "Patellidae", "Patella", 138718,
  "Munida spp",                "Animalia", "Arthropoda", "Malacostraca", "Decapoda", "Munididae", "Munida", 106826,
  "Holothuria spp",            "Animalia", "Echinodermata", "Holothuroidea", "Holothuriida", "Holothuriidae", "Holothuria", 123453
)

# Lookup and fix for compound name
auxis_tax <- safe_genus_lookup("Auxis") %>%
  mutate(scientificname = "Auxis thazard, A. rochei")

# Combine all taxonomy info
taxonomy_df_final <- bind_rows(
  taxonomy_df,
  genus_taxonomy_df,
  manual_fixes,
  auxis_tax
)

# --- STEP 5: Merge full final taxonomy ---
pesca_tax_final <- pesca_galicia_clean %>%
  left_join(taxonomy_df_final, by = "scientificname")

# --- STEP 6: Final unresolved check ---
unresolved_final <- pesca_tax_final %>%
  filter(is.na(phylum) | is.na(AphiaID)) %>%
  distinct(scientificname)

cat("\n❗ Still unresolved species:\n")
print(unresolved_final)

# Optional: inspect unresolved rows
unresolved_full <- pesca_tax_final %>%
  filter(scientificname %in% unresolved_final$scientificname)

cat("\n🔍 Full rows for unresolved species:\n")
print(unresolved_full)

unique(unresolved_full$Galician_name)


# Second round of manual fixes 

galician_fixes <- tribble(
  ~Galician_name,         ~scientificname,               ~kingdom,   ~phylum,       ~class,             ~order,             ~family,         ~genus,        ~AphiaID,
  "Ameixa babosa",        "Venerupis rhomboides",        "Animalia", "Mollusca",    "Bivalvia",         "Venerida",         "Veneridae",     "Venerupis",   141941,
  "Algas NP",             "Macroalgae spp",              "Plantae",  "Chlorophyta", NA,                 NA,                 NA,              NA,           NA,
  "Argazo bravo",         "Fucus spp",                   "Plantae",  "Ochrophyta",  "Phaeophyceae",     "Fucales",          "Fucaceae",      "Fucus",       144486,
  "Carromeiro",           "Carcinus maenas",             "Animalia", "Arthropoda",  "Malacostraca",     "Decapoda",         "Portunidae",    "Carcinus",    107372,
  "Touca",                "Callionymus spp",             "Animalia", "Chordata",    "Actinopterygii",   "Perciformes",      "Callionymidae", "Callionymus", 126926,
  "Ovas de Maruca",       "Fish Roe (Molva molva)",      "Animalia", "Chordata",    NA,                 NA,                 NA,              NA,           NA,
  "Ovas de abadexo",      "Fish Roe (Pollachius pollachius)", "Animalia", "Chordata", NA,              NA,                 NA,              NA,           NA,
  "Ovas de pescada",      "Fish Roe (Merluccius merluccius)", "Animalia", "Chordata", NA,              NA,                 NA,              NA,           NA,
  "Ovas de peixe pau",    "Fish Roe (Raniceps raninus)", "Animalia", "Chordata",    NA,                 NA,                 NA,              NA,           NA,
  "Outras",               "Unidentified spp",            NA,         NA,            NA,                 NA,                 NA,              NA,           NA
)

# Join based on Galician_name where taxonomy is missing
pesca_tax_final <- pesca_tax_final %>%
  rows_update(galician_fixes, by = c("Galician_name"))

# Recheck unresolved cases
unresolved_final2 <- pesca_tax_final %>%
  filter(is.na(phylum) | is.na(AphiaID)) %>%
  distinct(Galician_name, scientificname)

cat("\n🔍 Remaining unmatched (if any):\n")
print(unresolved_final2)



write.csv( pesca_tax_final, "/Users/batume/Documents/R/GAL_git/prep/FIS/pesca_galicia_with_taxonomy.csv", row.names = FALSE)

