## Different way of checking the data matches:

# One FAO code with multiple scientific names?
asfis %>%
  group_by(FAOcode) %>%
  summarise(n_species = n_distinct(scientificname)) %>%
  filter(n_species > 1)

# One scientific name with multiple FAO codes?
asfis %>%
  group_by(scientificname) %>%
  summarise(n_fao = n_distinct(FAOcode)) %>%
  filter(n_fao > 1)


# Species in RAM that match ASFIS-clean
ram_fao_match <- ram_data$stock %>%
  mutate(scientificname = tolower(trimws(scientificname))) %>%
  inner_join(asfis_clean %>%
               mutate(scientificname = tolower(trimws(scientificname))),
             by = "scientificname")

length(unique(ram_fao_match$FAOcode)) 



## Compare the matched species from the RAM database bmsy values to the 33 sp that explain 90% of the pesca de Galicia database

matched_species_clean <- tolower(trimws(matched_species))
bbmsy_species <- tolower(trimws(unique(bbmsy_data$scientificname)))

matched_in_bbmsy <- intersect(matched_species_clean, bbmsy_species)

# Species missing from bbmsy_data
missing_from_bbmsy <- setdiff(matched_species_clean, bbmsy_species)

cat("✅ Species in both matched list and bbmsy_data:", length(matched_in_bbmsy), "\n")
print(matched_in_bbmsy)
cat("\n❌ Species in matched list but NOT in bbmsy_data:", length(missing_from_bbmsy), "\n")
print(missing_from_bbmsy)



## Check the percentage that is explained by the bmsy species present

matched_in_bbmsy <- tolower(matched_in_bbmsy) 
PESCA_DATA$scientificname_lower <- tolower(PESCA_DATA$scientificname)
matched_sales <- PESCA_DATA[PESCA_DATA$scientificname_lower %in% matched_in_bbmsy, ]

sales_summary <- PESCA_DATA %>%
  group_by(year) %>%
  summarise(total_sales_all = sum(total_euros, na.rm = TRUE))

matched_summary <- matched_sales %>%
  group_by(year) %>%
  summarise(total_sales_matched = sum(total_euros, na.rm = TRUE))

final_summary <- left_join(sales_summary, matched_summary, by = "year") %>%
  mutate(percent_sales_matched = (total_sales_matched / total_sales_all) * 100)

print(final_summary)


#Which sp are 95% of the sales in PESCA DE GALICIA?

pesca_tax_final <- pesca_tax_final %>%
  mutate(scientificname_clean = str_to_lower(str_trim(scientificname)))


species_sales <- pesca_tax_final %>%
  group_by(scientificname_clean) %>%
  summarise(species_euros = sum(total_euros, na.rm = TRUE)) %>%
  arrange(desc(species_euros))


total_sales <- sum(species_sales$species_euros, na.rm = TRUE)

species_sales <- species_sales %>%
  mutate(
    cum_euros = cumsum(species_euros),
    cum_percent = (cum_euros / total_sales) * 100
  )


top_species_95 <- species_sales %>%
  filter(cum_percent <= 95)

cat("✅ Number of species covering 95% of sales:", nrow(top_species_95), "\n")
print(top_species_95)

species_names_95 <- top_species_95$scientificname_clean



## 32.7 % of the sales in Galicia - after eliminating mariculture we get 34% coverage

# After eliminating the mariculture species?

# Define mariculture species to exclude
mariculture_species <- c(
  "dicentrarchus labrax",       # sea bass
  "scophthalmus maximus",       # turbot
  "solea solea",                # sole
  "ruditapes philippinarum",    # manila clam
  "ruditapes decussatus",       # fina clam
  "venerupis rhomboides",       # rubia clam
  "cerastoderma edule",         # cockle
  "paracentrotus lividus"       # sea urchin
)


top_species_95_clean <- top_species_95 %>%
  filter(!(scientificname_clean %in% mariculture_species))


bbmsy_species <- bbmsy_data$scientificname %>%
  str_to_lower() %>%
  str_trim() %>%
  unique()


top_species <- top_species_95_clean$scientificname_clean

matched_species <- intersect(top_species, bbmsy_species)
n_matched <- length(matched_species)
n_total <- length(top_species)

cat("✅", n_matched, "of", n_total, "species in the top 95% sales are covered by B/BMSY data.\n")
cat("🧾 Coverage:", round((n_matched / n_total) * 100, 2), "%\n")

print(matched_species)

unmatched_species <- setdiff(top_species, bbmsy_species)


#CHECK IF THE UNMATCHED SPECIES HAVE A TIMESERIES IN THE ICESDATA

head(ICES_DATA)
ICES_DATA_N <- ICES_DATA %>%
  mutate(scientificname_clean = str_to_lower(str_trim(scientificname)))


species_years_ICES <- ICES_DATA_N %>%
  filter(scientificname_clean %in% unmatched_species) %>%
  group_by(scientificname_clean) %>%
  summarise(n_years = n_distinct(Year)) %>%
  arrange(desc(n_years))


sufficient_data <- species_years_ICES %>%
  filter(n_years >= 10)
cat("📊 Species with ≥10 years of data:\n")
print(sufficient_data)

insufficient_data <- setdiff(unmatched_species, sufficient_data$scientificname_clean)
cat("⚠️ Species with <10 years of time series data:\n")
print(insufficient_data)



## What percentage of the sales per year are the missing sp?


# Define your target species (make sure all are lowercase and clean)
target_species <- c(
  "scomber japonicus",
  "ensis magnus",
  "ensis ensis",
  "maja brachydactyla"
)

PESCA_DATA$scientificname_lower <- tolower(PESCA_DATA$scientificname)

# Filter rows that match the selected species
target_sales <- PESCA_DATA %>%
  filter(scientificname_lower %in% target_species)

sales_summary <- PESCA_DATA %>%
  group_by(year) %>%
  summarise(total_sales_all = sum(total_euros, na.rm = TRUE), .groups = "drop")


target_summary <- target_sales %>%
  group_by(year) %>%
  summarise(total_sales_target = sum(total_euros, na.rm = TRUE), .groups = "drop")

final_summary <- left_join(sales_summary, target_summary, by = "year") %>%
  mutate(percent_sales_target = (total_sales_target / total_sales_all) * 100)

print(final_summary)

# Total sales across all years for all species
total_all_years <- sum(PESCA_DATA$total_euros, na.rm = TRUE)

total_target_species <- sum(target_sales$total_euros, na.rm = TRUE)
percent_total_target <- (total_target_species / total_all_years) * 100

cat("💰 Total sales (all species): €", format(round(total_all_years, 0), big.mark = ","), "\n")
cat("🎯 Total sales (target species): €", format(round(total_target_species, 0), big.mark = ","), "\n")
cat("📊 Percent of total sales from target species:", round(percent_total_target, 2), "%\n")




# COMPARE NOW SPECIES WITH BMSY AND TOP SPECIES

bbmsy_species <- bbmsy_data$scientificname %>%
  str_to_lower() %>%
  str_trim() %>%
  unique()

top_95_species <- top_species_95$scientificname_clean %>%
  str_to_lower() %>%
  str_trim() %>%
  unique()

# Count how many match
matched_species <- intersect(top_95_species, bbmsy_species)
n_matched <- length(matched_species)
n_total <- length(top_95_species)


cat("✅", n_matched, "of", n_total, "top 95% sales species are present in B/BMSY dataset.\n")
cat("📊 Coverage:", round((n_matched / n_total) * 100, 2), "%\n")



# Get unmatched species
unmatched_species <- setdiff(top_95_species, bbmsy_species)

cat("❌ Species in top 95% sales NOT present in B/BMSY dataset:\n")
print(unmatched_species)
cat("\n🔢 Total unmatched species:", length(unmatched_species), "\n")


# RAM BMSY AND Ices data

# Clean species names
ices_species <- ICES_DATA$scientificname %>%
  str_to_lower() %>%
  str_trim() %>%
  unique()

bbmsy_species <- bbmsy_data$scientificname %>%
  str_to_lower() %>%
  str_trim() %>%
  unique()

# Match
matched_species <- intersect(ices_species, bbmsy_species)
unmatched_species <- setdiff(ices_species, bbmsy_species)

# Stats
n_matched <- length(matched_species)
n_total <- length(ices_species)
percent_matched <- round((n_matched / n_total) * 100, 2)

# Output
cat("✅", n_matched, "of", n_total, "ICES species are present in the RAM B/BMSY dataset.\n")
cat("📊 Coverage:", percent_matched, "%\n")

cat("\n❌ Species in ICES but NOT in RAM B/BMSY:\n")
print(unmatched_species)
cat("\n🔢 Total unmatched species:", length(unmatched_species), "\n")

