library(readxl)
library(dplyr)
library(stringr)
library(tidyr)

##Started with the data obtained from Compute_scores_gpkg.R

final_df <- final_df %>%
  rename(sci_name = species) %>%
  rename_with(tolower)

tabla_ceeei_or <- read_excel("/Users/batume/Documents/R/GAL_git/prep/BD_SP/inv_sp/Tabla_CEEEIcompleta.xlsx")

# species identified manually
odd_manual_sp <- c(
  "Bulweria bulwerii",
  "Morone saxatilis",
  "Sphyraena viridensis",
  "Pinguinus impennis",
  "Kaupichthys hyoproroides",
  "Merluccius senegalensis",
  "Scyllarides latus",
  "Pycnonotus jocosus",
  "Sphyrna mokarran",
  "spatula querquedula"
  
)

odd_manual_sp<-tolower(odd_manual_sp)

# Check for marine invasive species in Galicia -> https://redogal.xunta.gal/sites/default/files/publicacions/2020-12/66_Monografía_Esp_Exoticas_2012_V1.0.pdf
#(https://www.researchgate.net/publication/259194561_ESPECIES_EXOTICAS_MARINAS_DE_GALIZA)

invasive_bañon<-c("Sargassum muticum","Undaria pinnatífida","Corella eumyota","Limnoperna securis",
                  "Crepidula fornicata","Crepipatella dilatata","Bolinus brandaris","Rapana venosa","Seriola rivoliana","Kyphosus saltatrix")
invasive_bañon<-tolower(invasive_bañon)

#Clean tabla_ceeei scientific names


tabla_ceeei <- tabla_ceeei_or %>%
  filter(`Rango taxonómico` == "especie") %>%
  select(`Nombre científico CEEEI /BOE`)

tabla_ceeei_filt <- tabla_ceeei %>%
  mutate(
    sci_name = `Nombre científico CEEEI /BOE` %>%
      replace_na("") %>%
      str_remove_all("[\\[\\]\\(\\)\\.,|]") %>%
      str_trim() %>%
      str_extract("^[A-Z][a-z]+\\s[a-z\\-]+") %>%
      tolower()  # convert after extraction
  ) %>%
  filter(!is.na(sci_name)) %>%
  select(sci_name)


str(tabla_ceeei_filt)

# Combine 
merged_species <- c(
  odd_manual_sp,
  invasive_bañon,
  tabla_ceeei_filt$sci_name
)

merged_species <- unique(merged_species) %>% sort()
merged_species_df <- tibble(sci_name = merged_species)

# match now to iconic and eliminate sp

matched_species <- merged_species_df %>%
  semi_join(final_df, by = "sci_name")

# Check if any of the families/genus... present 

keywords <- c("Vespa", "Euplectes", "Estrilda", "Acridotheres", "Monochamis",
              "Salvinia", "Ludwigia", "Cortaderia", "Azolla", "Cylindropuntia",
              "Channa", "Ploceus", "Nasua", "Herpestidae", "Sciuridae", "Colubridae")

keywords <- c("vesp", "euplect", "estrild", "acridother", "monocham",
              "salvini", "ludwig", "cortader", "azoll", "cylindropunti",
              "channa", "ploceus", "nasua", "herpestid", "sciurid", "colubrid")

pattern <- str_c(keywords, collapse = "|")
matching_names <- final_df %>%
  filter(str_detect(sci_name, regex(pattern, ignore_case = TRUE)))


#MARCH TO ICONIC SPECIES
iconic_sp <- read_csv("/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/iconic_sp_Classified_complete.csv") 


iconic_sp_filt <- iconic_sp %>%
  mutate(
    sci_name = `Scientific name_accepted` %>%
      tolower()  # convert after extraction
  ) %>%
  filter(!is.na(sci_name)) %>%
  select(sci_name)

head(iconic_sp_filt)

matched_species_ICO <- iconic_sp_filt %>%
  semi_join(final_df, by = "sci_name")

write.csv(matched_species_ICO,"/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/iconic_matches.csv", row.names = FALSE)


