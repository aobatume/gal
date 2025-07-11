head(ices_tax_final_filled)
head(pesca_tax_final)
head(galicia_data)

library(dplyr)
library(tidyr)


pesca_tax_final<-read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pesca_galicia_with_taxonomy.csv")
ices_tax_final_filled <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/ices_taxonomy_enriched.csv")

# 1. Filter and summarize ICES data
ices_summary <- ices_tax_final_filled %>%
  filter(Year >= 2018, Year <= 2022) %>%
  group_by(FAOcode, Year) %>%
  summarise(total_ices_catch = sum(as.numeric(Catch), na.rm = TRUE), .groups = "drop")

# 2. Filter and summarize pesca data
pesca_summary <- pesca_tax_final %>%
  filter(year >= 2018, year <= 2022) %>%
  group_by(FAOcode, year) %>%
  summarise(total_pesca_catch = sum(as.numeric(catch_tonnes), na.rm = TRUE), .groups = "drop")

# 3. Join and calculate percent represented
catch_comparison <- left_join(
  ices_summary,
  pesca_summary,
  by = c("FAOcode" = "FAOcode", "Year" = "year")
) %>%
  mutate(
    total_pesca_catch = replace_na(total_pesca_catch, 0),
    percent_represented =  (total_ices_catch/total_pesca_catch) * 100
  )


top_species <- pesca_tax_final %>%
       filter(year >= 2018, year <= 2022) %>%
       group_by(scientificname, English_name) %>%
       summarise(
             total_kg = sum(as.numeric(total_kg), na.rm = TRUE),
             total_euros = sum(as.numeric(total_euros), na.rm = TRUE),
             .groups = "drop"
         ) %>%
       arrange(desc(total_euros))  
 top_species %>% slice_head(n = 10)

top_species %>% slice_head(n = 10)

# Which sp in pescadegalicia correspond to the 90% of the total sold

top_90_species <- pesca_tax_final %>%
  filter(year >= 2018, year <= 2022) %>%
  group_by(FAOcode,scientificname, English_name) %>%
  summarise(
    total_euros = sum(as.numeric(total_euros), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(total_euros)) %>%
  mutate(
    cumulative_euros = cumsum(total_euros),
    percent_cumulative = cumulative_euros / sum(total_euros) * 100
  ) %>%
  filter(percent_cumulative <= 90)



#Check if they're present in the Ices database:

# 1. Extract top 90% species (from previous step)
top_90_species_faocode <- pesca_tax_final %>%
  filter(year >= 2018, year <= 2022) %>%
  group_by(FAOcode, scientificname, English_name) %>%
  summarise(
    total_euros = sum(as.numeric(total_euros), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(total_euros)) %>%
  mutate(
    cumulative_euros = cumsum(total_euros),
    percent_cumulative = cumulative_euros / sum(total_euros) * 100
  ) %>%
  filter(percent_cumulative <= 90)

# 2. Unique FAOcode + species in ICES dataset
ices_species_faocode <- ices_tax_final_filled %>%
  select(FAOcode, scientificname) %>%
  distinct()

# 3. Join to see which are represented
top_90_with_ices_flag <- top_90_species_faocode %>%
  left_join(ices_species_faocode, by = c("FAOcode", "scientificname")) %>%
  mutate(
    in_ices = !is.na(FAOcode.y)
  ) %>%
  select(FAOcode = FAOcode.x, scientificname, English_name, total_euros, percent_cumulative, in_ices)


in_ices = !is.na(ices_species_faocode$scientificname)


#ARE THEY PRESENT IN THT ICES???

# Step 1: Unique FAOcode + species from ICES
ices_species_faocode <- ices_tax_final_filled %>%
  select(FAOcode, scientificname) %>%
  distinct()

# Step 2: Join with top-selling species
top_90_with_ices_flag <- top_90_species_faocode %>%
  left_join(ices_species_faocode %>%
              rename(scientificname_ices = scientificname),
            by = "FAOcode") %>%
  mutate(
    in_ices = scientificname == scientificname_ices
  ) %>%
  select(
    FAOcode,
    scientificname,
    English_name,
    total_euros,
    percent_cumulative,
    in_ices
  )

# Re-do join with both keys and check presence
top_90_with_ices_flag <- top_90_species_faocode %>%
  mutate(key = paste(FAOcode, scientificname)) %>%
  left_join(
    ices_species_faocode %>%
      mutate(key = paste(FAOcode, scientificname)) %>%
      select(key),
    by = "key"
  ) %>%
  mutate(in_ices = !is.na(key)) %>%
  select(FAOcode, scientificname, English_name, total_euros, percent_cumulative, in_ices)

write.csv(top_90_with_ices_flag, 
          file = "/Users/batume/Documents/R/GAL_git/prep/FIS/top_90_species_with_ices_pesca.csv", 
          row.names = FALSE)


##### COMPARE THE 3 DATABASES (previous script pasted gher, not much use) #####

head(pesca_tax_final)
head(ices_tax_final_filled)
head(galicia_ram_taxo)
# ------------------ STEP 1: Prepare Pesca (group by scientificname) ------------------
pesca_by_species <- pesca_tax_final %>%
  group_by(FAOcode) %>%
  summarise(
    total_weight = sum(total_kg, na.rm = TRUE) / 1000,  # convert to tonnes
    total_value = sum(total_euros, na.rm = TRUE)
  )

# ------------------ STEP 2: ICES by scientificname in 27.8.c / 27.9.a ------------------
ices_by_species <- ices_tax_final_fixed %>%
  filter(Area %in% c("27.8.c", "27.9.a")) %>%
  group_by(FAOcode) %>%
  summarise(total_catch = sum(Catch, na.rm = TRUE))

# ------------------ STEP 3: RAM ------------------
ram_by_species <- galicia_ram_taxo %>%
  group_by(FAOcode, scientificname) %>%
  summarise(status = mean(status, na.rm = TRUE), .groups = "drop")

# ------------------ STEP 4: Merge by scientificname ------------------
unified_species <- pesca_by_species %>%
  full_join(ices_by_species, by = "FAOcode") %>%
  full_join(ram_by_species, by = "FAOcode") %>%
  mutate(
    in_pesca = !is.na(total_weight),
    in_ices = !is.na(total_catch),
    in_ram = !is.na(status)
  )

# ------------------ STEP 5: View species in all 3 sources ------------------
unified_species %>%
  filter(in_pesca & in_ices & in_ram) %>%
  arrange(desc(total_weight)) %>%
  print(n = 20)


tail(unified_FAOcode)
