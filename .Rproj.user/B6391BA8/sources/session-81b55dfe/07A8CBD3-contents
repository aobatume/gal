library(rfishbase)
library(dplyr)
library(stringr)
install.packages("remotes")
remotes::install_github("datalimited/datalimited")

knitr::opts_chunk$set(fig.width = 6, fig.height = 4, fig.path = 'figs/',message = FALSE, warning = FALSE)

devtools::install_github("datalimited/datalimited")
library(datalimited) 
library(tidyverse)
library(doParallel)
library(here)
library(dplyr)

ICES_species_not_in_bbmsy_top95<-read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/ICES_species_not_in_bbmsy_top95.csv")
unique(ICES_species_not_in_bbmsy_top95$scientificname)


#Remove mariculture sp
mariculture_species <- c(
  "Ruditapes philippinarum",
  "Ruditapes decussatus",
  "Cerastoderma edule",
  "Scophthalmus maximus",
  "Paracentrotus lividus"
)


ICES_species_filtered <- ICES_species_not_in_bbmsy_top95 %>%
  filter(!scientificname %in% mariculture_species)
unique(ICES_species_filtered$scientificname)


head(ICES_species_filtered)

#REMOVE MARICULTURE SP with missing resilience

species_to_remove <- c(
  "Ensis ensis", "Ensis magnus", "Necora puber",
  "Maja squinado","Polititapes rhomboides"
)

ICES_species_filtered <- ICES_species_filtered %>%
  filter(!scientificname %in% species_to_remove)

unique(ICES_species_filtered$scientificname)
head(ICES_species_filtered)


# Run resiliences scores in fishbase

ICES_species_filtered <- ICES_species_filtered %>%
  mutate(scientificname = str_squish(scientificname))

species_list <- unique(ICES_species_filtered$scientificname)


species_data <- species(species_list, fields = c("Species", "Vulnerability", "LongevityWild", "Length")) %>%
  rename(scientificname = Species)

species_data <- species_data %>%
  mutate(resilience_score = case_when(
    Vulnerability <= 20  ~ 0.8,
    Vulnerability <= 40  ~ 0.6,
    Vulnerability <= 60  ~ 0.4,
    TRUE                 ~ 0.2
  ))

ICES_species_filtered <- left_join(ICES_species_filtered, species_data, by = "scientificname")
ICES_species_filtered <- ICES_species_filtered %>%
  mutate(scientificname = str_squish(scientificname))

print(species_data)

head(unique(ICES_species_filtered$scientificname), 10)

#Check unmatched species
unmatched <- ICES_species_filtered %>% filter(is.na(resilience_score))
print(unique(unmatched$scientificname))


# Add missing sp resilience scores manually 

manual_resilience <- tibble::tibble(
  scientificname = c(
    "Palaemon serratus", "Sepia officinalis", "Eledone cirrhosa",
    "Octopus vulgaris", "Pollicipes pollicipes", "Raja spp",
    "Illex illecebrosus", "Loligo vulgaris", "Todaropsis eblanae"
  ),
  resilience_score = c(0.8, 0.8, 0.8, 0.8, 0.6, 0.2, 0.8, 0.8, 0.8)
)

print(manual_resilience)

ICES_species_filtered <- ICES_species_filtered %>%
  left_join(manual_resilience, by = "scientificname") %>%
  mutate(
    resilience_score_final = coalesce(resilience_score.x, resilience_score.y)
  ) %>%
  select(-resilience_score.x, -resilience_score.y)  

print(ICES_species_filtered %>% select(scientificname, resilience_score_final) %>% distinct())


head(ICES_species_filtered)


