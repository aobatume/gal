#Previous script ICES_filtering

# Load required libraries
library(readxl)
library(dplyr)
library(tidyr)
library(worrms)
library(purrr)
library(stringr)
library(readr)

# Step 1: Load ASFIS list

asfis <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/ASFIS_sp_2024.csv", encoding = "Latin1") %>%
  select(
    FAOcode = Alpha3_Code,
    Scientific_name = Scientific_Name,
    English_name = English_name,
    Family, Order.or.higher.taxa
  )

# Step 2: Merge ASFIS with ICES catch data
merged_data <- filtered_ices_stocks %>%
  left_join(asfis, by = "FAOcode") %>%
  rename(scientificname = Scientific_name)

# Step 3: Extract unique species names
unique_species <- unique(merged_data$scientificname)

# Step 4: WoRMS taxonomy lookup function
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

saveRDS(taxonomy_df, file = "/Users/batume/Documents/R/GAL_git/prep/FIS/taxonomy_df.rds")

# Step 6: Merge taxonomy into main dataset
ices_tax_final <- merged_data %>%
  left_join(taxonomy_df, by = "scientificname")

### Genus level fixes

missing_species <- ices_tax_final %>%
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


genus_taxonomy_df <- genus_taxonomy_df %>%
  mutate(scientificname = paste0(genus, " spp"))

ices_tax_final_fixed <- ices_tax_final %>%
  rows_update(genus_taxonomy_df, by = "scientificname", unmatched = "ignore")

# check — how many are still unresolved
still_unresolved <- ices_tax_final_fixed %>%
  filter(is.na(phylum)) %>%
  distinct(scientificname)

nrow(still_unresolved)
print(still_unresolved)

#Fix manually

manual_taxonomy <- tibble::tribble(
  ~scientificname, ~phylum,      ~class,             ~order,              ~family,           ~genus,
  "Batoidea or Batoidimorpha (Hypotremata)", "Chordata", "Chondrichthyes", "Rajiformes",       NA,               NA,
  "Bihunichthys monopteroides",              "Chordata", "Actinopterygii", "Anguilliformes",   "Bythitidae",      "Bihunichthys",
  "Clupeiformes (=Clupeoidei)",              "Chordata", "Actinopterygii", "Clupeiformes",     NA,               NA,
  "Sepiidae, Sepiolidae",                    "Mollusca", "Cephalopoda",     NA,                "Sepiidae",        NA,
  "Natantia",                                "Arthropoda","Malacostraca",   "Decapoda",         NA,               NA,
  "Squalidae, Scyliorhinidae",               "Chordata", "Chondrichthyes", "Carcharhiniformes","Squalidae",       NA,
  "Perciformes (Others)",                    "Chordata", "Actinopterygii", "Perciformes",      NA,               NA,
  "Auxis thazard, A. rochei",                "Chordata", "Actinopterygii", "Scombriformes",    "Scombridae",      "Auxis",
  "Haemulidae (=Pomadasyidae)",              "Chordata", "Actinopterygii", "Perciformes",      "Haemulidae",      NA,
  "Invertebrata",                            "Various",  NA,               NA,                 NA,                NA,
  "Perciformes (Percoidei)",                 "Chordata", "Actinopterygii", "Perciformes",      NA,               NA,
  "Alosa alosa, A. fallax",                  "Chordata", "Actinopterygii", "Clupeiformes",     "Clupeidae",       "Alosa",
  "Selachii or Selachimorpha (Pleurotremata)","Chordata","Chondrichthyes", "Selachimorpha",    NA,               NA,
  "Salmoniformes (=Salmonoidei)",            "Chordata", "Actinopterygii", "Salmoniformes",    NA,               NA,
  "Loliginidae, Ommastrephidae",             "Mollusca", "Cephalopoda",     NA,                "Loliginidae",     NA,
  "Algae",                                   "Ochrophyta","Phaeophyceae",  NA,                 NA,               NA,
  "Thunnini",                                "Chordata", "Actinopterygii", "Scombriformes",    "Scombridae",      NA,
  "Scombriformes (Scombroidei)",             "Chordata", "Actinopterygii", "Scombriformes",    NA,               NA,
  "Perciformes (Scorpaenoidei)",             "Chordata", "Actinopterygii", "Perciformes",      "Scorpaenidae",    NA
)


ices_tax_final_filled <- ices_tax_final_fixed %>%
  rows_update(manual_taxonomy, by = "scientificname")

# check — how many are still unresolved
still_unresolved <- ices_tax_final_filled %>%
  filter(is.na(phylum)) %>%
  distinct(scientificname)

nrow(still_unresolved)
print(still_unresolved)

write.csv(ices_tax_final_filled, "/Users/batume/Documents/R/GAL_git/prep/FIS/ices_taxonomy_enriched.csv", row.names=FALSE)

summary(ices_tax_final_filled)
summary(filtered_ices_stocks)


missing_fao <- filtered_ices_stocks %>%
  filter(is.na(FAOcode) | FAOcode == "")

nrow(missing_fao)


anti_join(filtered_ices_stocks, asfis, by = "FAOcode") %>%
  distinct(FAOcode, .keep_all = TRUE)

