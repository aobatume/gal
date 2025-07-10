## CALCULATE FISHERIES GOAL ##
# the 90% of the data present in the pesca de Galicia database is in the ICES 
library(ramlegacy)
library(dplyr)
library(readr)


ICES_DATA <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/ices_taxonomy_enriched.csv")

ram_data <- tryCatch({
  load_ramlegacy()
}, error = function(e) {
  cat("Error loading RAM data:", e$message, "\n")
  NULL
})
if (is.null(ram_data)) stop("Failed to load RAM data. Exiting the script.")

# Normalize names
ices_species <- tolower(unique(ICES_DATA$scientificname))

# Extract B/BMSY values
bbmsy_data <- ram_data$timeseries_values_views %>%
  filter(!is.na(BdivBmsypref)) %>%
  select(stockid, year, bbmsy = BdivBmsypref) %>%
  left_join(
    ram_data$stock %>% select(stockid, scientificname),
    by = "stockid"
  ) %>%
  mutate(scientificname = tolower(scientificname)) %>%
  filter(scientificname %in% ices_species)


names(ram_data$timeseries_values_views)
glimpse(ram_data$timeseries_values_views)

summary(unique(bbmsy_data$scientificname))
summary(unique(ICES_DATA$scientificname))

matched_species <- unique(bbmsy_data$scientificname)
unmatched_species <- setdiff(tolower(unique(ICES_DATA$scientificname)), matched_species)

length(unmatched_species) 
head(unmatched_species) 

colnames(StockAssessmentGraphs)

str(matched_species)


### the same as above but using the faocode?


# Load ICES data
ICES_DATA <- read_csv("/Users/batume/Documents/R/GAL_git/prep/FIS/ices_taxonomy_enriched.csv")

# Load RAM Legacy database
ram_data <- tryCatch({
  load_ramlegacy()
}, error = function(e) {
  cat("Error loading RAM data:", e$message, "\n")
  NULL
})
if (is.null(ram_data)) stop("Failed to load RAM data. Exiting the script.")

# Ensure FAO codes exist in ICES data
if (!"FAO_CODE" %in% names(ICES_DATA)) {
  stop("FAO_CODE column missing from ICES data. Ensure your file includes FAO species codes.")
}

# Extract B/BMSY values from RAM using FAO codes
bbmsy_data <- ram_data$timeseries_values_views %>%
  filter(!is.na(BdivBmsypref)) %>%
  select(stockid, year, bbmsy = BdivBmsypref) %>%
  left_join(
    ram_data$stock %>% select(stockid, scientificname, fao = FAOcode),
    by = "stockid"
  ) %>%
  filter(!is.na(fao)) %>%
  inner_join(
    ICES_DATA %>% select(fao_ices = FAO_CODE) %>% distinct(),
    by = c("fao" = "fao_ices")
  )

# Explore the match
matched_fao <- unique(bbmsy_data$fao)
unmatched_fao <- setdiff(unique(ICES_DATA$FAO_CODE), matched_fao)

# Summary
cat("Matched FAO species codes:", length(matched_fao), "\n")
cat("Unmatched FAO species codes:", length(unmatched_fao), "\n")

# Optional: Show a few unmatched ones
head(unmatched_fao)

# Optional: Inspect final data
glimpse(bbmsy_data)



##Que % da Pesca de Galicia está representada na RAM que ten bmsy values??

##7 xullo

library(dplyr)
library(stringr)
library(readr)

# Standardise
bbmsy_species <- bbmsy_data$scientificname %>%
  str_to_lower() %>%
  str_trim() %>%
  unique()

pesca_tax_final <- pesca_tax_final %>%
  mutate(scientificname_clean = str_to_lower(str_trim(scientificname)))

# Total sales in Galicia
total_sales <- sum(pesca_tax_final$total_euros, na.rm = TRUE)

# Sales covered by bbmsy species
covered_sales <- pesca_tax_final %>%
  filter(scientificname_clean %in% bbmsy_species) %>%
  summarise(covered_euros = sum(total_euros, na.rm = TRUE)) %>%
  pull(covered_euros)


percentage_covered <- (covered_sales / total_sales) * 100
cat("✅ Percentage of total sales covered by bbmsy species:", round(percentage_covered, 2), "%\n")


## SUBSET UNMATCHED SPECIES TO PREPARE FOR CMSY CALCULATIONS

subset_unmatched <- ICES_DATA %>%
  filter(scientificname %in% unmatched_species)

str(unmatched_species)






#### WORKING SCRIPT: 


top_90_with_flags <- top_90_with_ices_flag %>%
  mutate(in_matched = paste(FAOcode, scientificname) %in% 
           paste(matched_species$FAOcode, matched_species$scientificname))



##### ATA AQUÍ #####

StockAssessmentGraphs <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/assessment_graphs_ices_2782/StockAssessmentGraphs_202574m4uogtgz4zu5odlw5hqx1ppl.csv")

b_bmsy_ices <- StockAssessmentGraphs %>%
  filter(!is.na(TBiomass) & !is.na(MSYBtrigger)) %>%
  mutate(bbmsy = TBiomass / MSYBtrigger) %>%
  select(FishStock, SpeciesName, Year, TBiomass, MSYBtrigger, bbmsy)


head(bbmsy_data)
head(b_bmsy_ices)

summary(unique(b_bmsy_data$BdivBmsypref))
summary(unique(b_bmsy_ices$bbmsy))

