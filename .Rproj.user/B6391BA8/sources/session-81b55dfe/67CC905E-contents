library(dplyr)
library(readr)
library(stringr)

PESCA_DATA<- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/total_summary_FAO_PESCADEGALICIA.csv")

# Which sp correspond to 95% of the data 

species_sales <- PESCA_DATA %>%
  mutate(scientificname_clean = str_to_lower(str_trim(Scientific_name))) %>%
  group_by(scientificname_clean) %>%
  summarise(total_sales = sum(total_euros, na.rm = TRUE)) %>%
  arrange(desc(total_sales)) %>%
  mutate(
    cum_sales = cumsum(total_sales),
    cum_percent = 100 * cum_sales / sum(total_sales)
  )

top_95_species <- species_sales %>%
  filter(cum_percent <= 95)

cat("🎯 Number of species contributing to 95% of sales:", nrow(top_95_species), "\n")

#How many sp from ICES have bmsy values?

ices_species <- ICES_DATA$scientificname %>%
  str_to_lower() %>%
  str_trim() %>%
  unique()

bbmsy_species <- bbmsy_data$scientificname %>%
  str_to_lower() %>%
  str_trim() %>%
  unique()

ices_in_bmsy <- intersect(ices_species, bbmsy_species)
ices_not_in_bmsy <- setdiff(ices_species, bbmsy_species)

cat("🔍 ICES species:", length(ices_species), "\n")
cat("✅ ICES species in B/BMSY:", length(ices_in_bmsy), "\n")
cat("❌ ICES species NOT in B/BMSY:", length(ices_not_in_bmsy), "\n")


# Of Species in B/BMSY, How Many Are in Top 95% Sales?

top_95_names <- top_95_species$scientificname_clean %>%
  str_to_lower() %>%
  str_trim() %>%
  unique()

bmsy_in_top_95 <- intersect(bbmsy_species, top_95_names)
bmsy_not_in_top_95 <- setdiff(bbmsy_species, top_95_names)

cat("💰 B/BMSY species also in top 95% sales:", length(bmsy_in_top_95), "\n")
cat("🧩 B/BMSY species NOT in top 95% sales:", length(bmsy_not_in_top_95), "\n")



# RELATION BETWEEN THE 3 DATASETS

species_union <- union(union(ices_species, bbmsy_species), top_95_names)

summary_df <- tibble(species = species_union) %>%
  mutate(
    in_ICES = species %in% ices_species,
    in_BBMSY = species %in% bbmsy_species,
    in_Top95 = species %in% top_95_names
  )

summary_df %>%
  group_by(in_ICES, in_BBMSY, in_Top95) %>%
  summarise(n_species = n(), .groups = "drop")


top95_only_species <- summary_df %>%
  filter(in_ICES == FALSE, in_BBMSY == FALSE, in_Top95 == TRUE)

print(top95_only_species$species)



# Filter for the 34 species: in_ICES = TRUE, in_Top95 = TRUE, in_BBMSY = FALSE

species_not_in_bbmsy_vec_clean <- species_not_in_bbmsy$species %>%
  str_to_lower() %>%
  str_trim()

ices_subset_not_in_bbmsy <- ICES_DATA %>%
  mutate(scientificname_clean = str_to_lower(str_trim(scientificname))) %>%
  filter(scientificname_clean %in% species_not_in_bbmsy_vec_clean)

ices_subset_not_in_bbmsy <- ices_subset_not_in_bbmsy %>%
  select(-scientificname_clean)


write_csv(
  ices_subset_not_in_bbmsy,
  "/Users/batume/Documents/R/GAL_git/prep/FIS/ICES_species_not_in_bbmsy_top95.csv"
)


#####OTHER STUFF THAT I DID

## CALCULATE FISHERIES GOAL - GALICIA + RAM LEGACY ##
library(dplyr)
library(readr)
library(stringr)
library(ramlegacy)

# ---- Load Data ----

ICES_DATA <- read_csv("/Users/batume/Documents/R/GAL_git/prep/FIS/ices_taxonomy_enriched.csv")


# Load RAM Legacy database
ram_data <- tryCatch({
  load_ramlegacy()
}, error = function(e) {
  cat("Error loading RAM data:", e$message, "\n")
  NULL
})
if (is.null(ram_data)) stop("Failed to load RAM data.")

# ---- Merge RAM + ASFIS ----

bbmsy_data <- ram_data$timeseries_values_views %>%
  filter(!is.na(BdivBmsypref)) %>%
  select(stockid, year, bbmsy = BdivBmsypref) %>%
  left_join(ram_data$stock %>% select(stockid, scientificname), by = "stockid") %>%
  mutate(scientificname = str_to_lower(scientificname)) %>%
  left_join(asfis, by = "scientificname") %>%
  filter(!is.na(FAOcode)) %>%
  mutate(FAOcode = str_to_upper(FAOcode))

# ---- Match to ICES Data ----

ices_fao_codes <- unique(ICES_DATA$FAOcode)
matched_fao <- unique(bbmsy_data$FAOcode)
unmatched_fao <- setdiff(ices_fao_codes, matched_fao)

# Summary
cat("Matched FAO codes:", length(matched_fao), "\n")
cat("Unmatched FAO codes:", length(unmatched_fao), "\n")

# Optional: Unmatched subset for CMSY prep
subset_unmatched <- ICES_DATA %>%
  filter(FAOcode %in% unmatched_fao)

# ---- Calculate % of Galicia fisheries covered ----

# Simulated pesca_tax_final (replace this with actual loaded data)
# pesca_tax_final <- read_csv("path_to_pesca_tax_final.csv")

# Clean names
bbmsy_species <- unique(bbmsy_data$scientificname)
pesca_tax_final <- pesca_tax_final %>%
  mutate(scientificname_clean = str_to_lower(str_trim(scientificname)))

# Calculate total and matched sales
total_sales <- sum(pesca_tax_final$total_euros, na.rm = TRUE)
covered_sales <- pesca_tax_final %>%
  filter(scientificname_clean %in% bbmsy_species) %>%
  summarise(covered_euros = sum(total_euros, na.rm = TRUE)) %>%
  pull(covered_euros)

percentage_covered <- (covered_sales / total_sales) * 100

cat("✅ Percentage of total sales covered by bbmsy species:", round(percentage_covered, 2), "%\n")

# ---- Optional Debug Info ----
# glimpse(bbmsy_data)
# head(unmatched_fao)
# head(subset_unmatched)