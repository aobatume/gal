TAC_quotas_2021 <- read_csv("TAC_quotas_2021.csv")

table(total_summary$Galician_name)

# Ensure the scientific name column exists in both dataframes
colnames(tsn_summary)
colnames(TAC_quotas_2021)

# Convert scientific names to lowercase to avoid case mismatches
tsn_summary <- tsn_summary %>%
  mutate(scientificname = tolower(scientificname))

TAC_quotas_2021 <- TAC_quotas_2021 %>%
  mutate(Scientific_Name = tolower(`Scientific Name`))  

# Filter `tsn_summary` for scientific names present in `TAC_quotas_2021`
tsn_filtered <- tsn_summary %>%
  filter(scientificname %in% TAC_quotas_2021$Scientific_Name)

# Display the filtered dataset
head(tsn_filtered)
summary(tsn_filtered)

# Save results 
write.csv(tsn_filtered, "tsn_filtered_by_TAC_2021.csv", row.names = FALSE)

table(tsn_filtered$scientificname)



#COUNT NUMBER OF STOCKS ID

# Count unique stockid per scientificname
stockid_count <- tsn_filtered %>%
  group_by(scientificname) %>%
  summarise(stockid_count = n_distinct(stockid), .groups = "drop")  # Count unique stockids

# Display results
head(stockid_count)
summary(stockid_count)

# Save to CSV (Optional)
write.csv(stockid_count, "stockid_count_per_scientificname.csv", row.names = FALSE)




