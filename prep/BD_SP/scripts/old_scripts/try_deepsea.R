
library(rfishbase)
library(dplyr)
library(readr)

species_df <- read_csv("/Users/batume/Documents/R/GAL_git/prep/BD_SP/output/intersections/cleaned/deduplicated/species_area_iucn_summary_deduplicated.csv")
names <- species_df$sci_name

# Standardize names
valid_names <- validate_names(names)

# Query depth and habitat info
valid_species_data <- species(valid_names, 
                              fields = c("Species", "DemersPelag", "DepthRangeShallow", "DepthRangeDeep"))

# Merge data
merged_data <- left_join(species_df, valid_species_data, by = c("sci_name" = "Species"))

View(merged_data %>% filter(DepthRangeDeep > 200 | is.na(DepthRangeDeep)))

# Filter out species with depth deeper than 200m
non_deep_sea <- merged_data %>%
  filter(DepthRangeDeep <= 200 | is.na(DepthRangeDeep))

write_csv(non_deep_sea, "/path/to/non_deep_sea_species.csv")

TRY<-non_deep_sea[is.na(non_deep_sea$DemersPelag), ]

TRY$sci_name




deep_sea_manual <- c(
  # Deep-sea cetaceans (beaked whales, sperm whales, etc.)
  "Feresa attenuata",
  "Hyperoodon ampullatus",
  "Lagenorhynchus albirostris", 
   "Mesoplodon europaeus",


  
  # Deep-sea invertebrates
  "Nephropsis atlantica", "Palinurus mauritanicus", "Polycheles typhlops",
  "Stereomastis nana", "Stereomastis sculpta", 
  
  # Deep-sea fish missed by FishBase call "Facciolella oxyrhyncha"
  "Bathophilus metallicus", "Bonapartia pedaliota", "Cyclothone pseudoacclinidens",
   "Gonostoma elongatum", "Lampanyctus gemmifer",
  "Melanostomias spilorhynchus", "Nannobrachium atrum", "Nettastoma melanurum",
  
  # Added confirmed deep-sea fish from your list:
  "Astronesthes neopogon", "Astronesthes niger",
  "Bathophilus nigerrimus", "Centroscyllium fabricii",
  "Eustomias achirus", "Eustomias filifer", "Eustomias macrurus",
  "Leptostomias haplocaulus", "Leptostomias longibarba",
  "Photonectes mirabilis", "Maurolicus amethystinopunctatus",
  "Lestidiops similis",
  
  # Rare/unexpected in Galicia and deep-sea species
  "Melamphaes falsidicus", "Diodon eydouxii", "Mugil cephalus", "Ranzania laevis",
  "Tetrapturus pfluegeri", "Diodon hystrix", "Istiophorus platypterus", "Kajikia albida"
)
  
  
  
non_deep_sea_cleaned <- non_deep_sea %>%
  filter(!sci_name %in% deep_sea_manual)

non_deep_sea_cleaned$sci_name


