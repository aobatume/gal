
# Step 2: Filter each group for scientific names present in TAC_quotas_2021
group1_filtered <- group1_data %>%
  filter(scientificname %in% TAC_quotas_2021$scientificname)

group2_filtered <- group2_data %>%
  filter(scientificname %in% TAC_quotas_2021$scientificname)

group3_filtered <- group3_data %>%
  filter(scientificname %in% TAC_quotas_2021$scientificname)

group4_filtered <- group4_data %>%
  filter(scientificname %in% TAC_quotas_2021$scientificname)

group5_filtered <- group5_data %>%
  filter(scientificname %in% TAC_quotas_2021$scientificname)

# Step 3: Display the filtered data for each group
head(group1_filtered)
head(group2_filtered)
head(group3_filtered)
head(group4_filtered)
head(group5_filtered)

# Step 4: Save the filtered results for each group
write.csv(group1_filtered, "group1_filtered_by_TAC_2021.csv", row.names = FALSE)
write.csv(group2_filtered, "group2_filtered_by_TAC_2021.csv", row.names = FALSE)
write.csv(group3_filtered, "group3_filtered_by_TAC_2021.csv", row.names = FALSE)
write.csv(group4_filtered, "group4_filtered_by_TAC_2021.csv", row.names = FALSE)
write.csv(group5_filtered, "group5_filtered_by_TAC_2021.csv", row.names = FALSE)


# Step 5: Count the number of stockid for each scientificname in the filtered groups
stockid_count_group1 <- group1_filtered %>%
  group_by(scientificname) %>%
  summarise(stockid_count = n_distinct(stockid), .groups = "drop")

stockid_count_group2 <- group2_filtered %>%
  group_by(scientificname) %>%
  summarise(stockid_count = n_distinct(stockid), .groups = "drop")

stockid_count_group3 <- group3_filtered %>%
  group_by(scientificname) %>%
  summarise(stockid_count = n_distinct(stockid), .groups = "drop")

stockid_count_group4 <- group4_filtered %>%
  group_by(scientificname) %>%
  summarise(stockid_count = n_distinct(stockid), .groups = "drop")

stockid_count_group5 <- group5_filtered %>%
  group_by(scientificname) %>%
  summarise(stockid_count = n_distinct(stockid), .groups = "drop")

# Step 6: Display the stockid count for each group
head(stockid_count_group1)
head(stockid_count_group2)
head(stockid_count_group3)
head(stockid_count_group4)
head(stockid_count_group5)

# Step 7: Optionally, save the stockid count results for each group
write.csv(stockid_count_group1, "stockid_count_group1.csv", row.names = FALSE)
write.csv(stockid_count_group2, "stockid_count_group2.csv", row.names = FALSE)
write.csv(stockid_count_group3, "stockid_count_group3.csv", row.names = FALSE)
write.csv(stockid_count_group4, "stockid_count_group4.csv", row.names = FALSE)
write.csv(stockid_count_group5, "stockid_count_group5.csv", row.names = FALSE)




#### TROUBLESHOOTING DATA 
# Print the result
print(duplicates_check)

# Check that each stock has at least one value of total_tons per year
missing_total_tons_check <- merged_data %>%
  group_by(stockid, year) %>%
  summarise(count = sum(!is.na(total_tons)), .groups = "drop") %>%
  filter(count == 0)  # Filter for years with missing total_tons

# Print the result
print(missing_total_tons_check)

# Check for duplicates in galicia_ram_filtered
duplicates_check_galicia <- galicia_ram_filtered %>%
  group_by(stockid) %>%
  summarise(duplicates = n(), .groups = "drop") %>%
  filter(duplicates > 1)  # Filter for duplicate entries

# Print the result
print(duplicates_check_galicia)

# Check how many years are present for each stockid in tsn_summary
missing_years_check <- tsn_summary %>%
  group_by(stockid) %>%
  summarise(years_present = n_distinct(year), .groups = "drop") %>%
  mutate(missing_years = 16 - years_present) %>%
  filter(missing_years > 0)  # Filter stocks with missing years

# Print missing years check result
print(missing_years_check)

# Check the number of unique stockid in the missing years check
n_distinct(missing_years_check$stockid)

# Check if there are missing `stockid`-`year` combinations
missing_year_combinations <- tsn_summary %>%
  group_by(stockid, year) %>%
  summarise(count = n(), .groups = "drop") %>%
  filter(count == 0)

# Print the number of missing combinations
print(missing_year_combinations)

# Check the number of rows with missing values in tsn_summary
missing_rows_check <- tsn_summary %>%
  filter(if_any(everything(), is.na)) %>%
  nrow()

# Print the result
print(missing_rows_check)


## MESSY BITS TO FIX THE SPECIES NAMES

library(dplyr)

# Make sure both scientific name columns are in lowercase to avoid mismatches
total_tons_per_year_species_group5 <- total_tons_per_year_species_group5 %>%
  mutate(scientificname = tolower(scientificname))

TAC_quotas_2021 <- TAC_quotas_2021 %>%
  mutate(scientificname = tolower(scientificname))

# Perform the left join to merge the data
merged_data <- total_tons_per_year_species_group5 %>%
  left_join(TAC_quotas_2021, by = "scientificname")

table(merged_data$Species)


# Step 1: Ensure both scientific name columns are in lowercase to avoid mismatches
total_tons_per_year_species_group1 <- total_tons_per_year_species_group1 %>%
  mutate(scientificname = tolower(scientificname))

total_tons_per_year_species_group2 <- total_tons_per_year_species_group2 %>%
  mutate(scientificname = tolower(scientificname))

total_tons_per_year_species_group3 <- total_tons_per_year_species_group3 %>%
  mutate(scientificname = tolower(scientificname))

total_tons_per_year_species_group4 <- total_tons_per_year_species_group4 %>%
  mutate(scientificname = tolower(scientificname))

total_tons_per_year_species_group5 <- total_tons_per_year_species_group5 %>%
  mutate(scientificname = tolower(scientificname))

TAC_quotas_2021 <- TAC_quotas_2021 %>%
  mutate(scientificname = tolower(scientificname))

# Step 2: Perform the left join to merge each group with TAC quotas data
merged_group1 <- total_tons_per_year_species_group1 %>%
  left_join(TAC_quotas_2021, by = "scientificname")

merged_group2 <- total_tons_per_year_species_group2 %>%
  left_join(TAC_quotas_2021, by = "scientificname")

merged_group3 <- total_tons_per_year_species_group3 %>%
  left_join(TAC_quotas_2021, by = "scientificname")

merged_group4 <- total_tons_per_year_species_group4 %>%
  left_join(TAC_quotas_2021, by = "scientificname")

merged_group5 <- total_tons_per_year_species_group5 %>%
  left_join(TAC_quotas_2021, by = "scientificname",relationship = "many-to-many")

# Step 3: Create a summary table for mismatches across all groups
summary_mapping <- bind_rows(
  merged_group1 %>%
    select(scientificname, ESPECIE) %>%
    distinct() %>%
    mutate(group = 1),
  
  merged_group2 %>%
    select(scientificname, ESPECIE) %>%
    distinct() %>%
    mutate(group = 2),
  
  merged_group3 %>%
    select(scientificname, ESPECIE) %>%
    distinct() %>%
    mutate(group = 3),
  
  merged_group4 %>%
    select(scientificname, ESPECIE) %>%
    distinct() %>%
    mutate(group = 4),
  
  merged_group5 %>%
    select(scientificname, ESPECIE) %>%
    distinct() %>%
    mutate(group = 5)
)

# Step 4: Identify species that are mismatched across groups and summarize them
summary_mapping <- summary_mapping %>%
  group_by(scientificname) %>%
  summarise(
    common_names = paste(unique(ESPECIE), collapse = ", "),  # Join all common names for each scientific name
    count = n(),
    groups_involved = paste(unique(group), collapse = ", "),  # Show which groups the species appears in
    .groups = "drop"
  ) %>%
  arrange(desc(count))  # Sort by the number of occurrences across groups

# Step 5: Display the summarized mapping
print(summary_mapping)

# Save to CSV
write.csv(summary_mapping, "summary_mapping_names.csv", row.names = FALSE)

table(summary_mapping$scientificname)

# Ensure both columns are in lowercase for proper matching
merged_data <- merged_data %>%
  mutate(
    scientificname = tolower(scientificname),
    Species = tolower(Species)
  )

# Create a table mapping scientific names to common names
scientific_to_common <- merged_data %>%
  select(scientificname, Species) %>%
  distinct()  # Remove duplicate mappings

# Display the mapping table
print(scientific_to_common)

# If you want to summarize the number of species for each scientific name
summary_mapping <- scientific_to_common %>%
  group_by(scientificname) %>%
  summarise(
    common_names = paste(unique(Species), collapse = ", "),  # Join all common names for each scientific name
    count = n()
  ) %>%
  arrange(desc(count))  # Sort by count to see which species have multiple common names

# Display the summarized mapping
print(summary_mapping)

###. SCRIPT RAM THAT I THOUGHT WOULD WORK (21/02/2025

library(ramlegacy)
library(dplyr)
library(readr)

# Load RAM database (Ensure that you are using a correct version)
ram_data <- load_ramlegacy()

# Define the correct year column based on inspection
year_col <- "year"

# Step 1: Filter stock data for Galicia (Northeast Atlantic, Spain, ICES)
galicia_ram_filtered <- ram_data$stock %>%
  filter(grepl("Northeast Atlantic", region, ignore.case = TRUE) | 
           grepl("Spain", areaid, ignore.case = TRUE) |
           grepl("ICES", areaid, ignore.case = TRUE))

# Step 2: Create a new column assigning groups based on the areaid
galicia_ram_filtered <- galicia_ram_filtered %>%
  mutate(group = case_when(
    grepl("VIIIc|IXa", areaid) ~ 1,  # Group 1: VIIIC or XIA
    grepl("VIIIa|VIIIb|VIIId|VIIIe|IXb", areaid) ~ 2,  # Group 2: VIIIA, VIIIB, VIIID, VIIIE, IXB
    grepl("VII", areaid) ~ 3,  # Group 3: VII
    grepl("VIIIc|XIa|VIIIa|VIIIb|VIIId|VIIIe|IXb", areaid) ~ 4,  # Group 4: Areas in Group 1 or 2
    grepl("VIIIc|IXa|VIIIa|VIIIb|VIIId|VIIIe|IXb|VII|VIIIc|XIa|VIIIa|VIIIb|VIIId|VIIIe|IXb", areaid) ~ 4  # Group 5: All other areas
  ))

summary(galicia_ram_filtered)



head(galicia_ram_filtered)







# Step 3: Merge with timeseries data to get TSN and other relevant columns
tsn_per_year <- ram_data$timeseries_values_views %>%
  inner_join(galicia_ram_filtered, by = "stockid") %>%
  select(all_of(year_col), tsn, everything())  # Keep all columns

# Step 4: Filter for years between 2003 and 2022 and keep only relevant variables
selected_vars <- c("year", "tsn", "stockid", "scientificname", 
                   "commonname", "areaid", "stocklong.y", 
                   "region", "inmyersdb", "myersstockid", "group")

tsn_per_year_filtered <- tsn_per_year %>%
  filter(between(.data[[year_col]], 2003, 2022)) %>%
  select(all_of(selected_vars))

# Convert TSN to numeric
tsn_per_year_filtered <- tsn_per_year_filtered %>%
  mutate(tsn = as.numeric(tsn))  # Convert to numeric

# Step 5: Summarize total TSN per year per stockid, while keeping other variables
tsn_summary <- tsn_per_year_filtered %>%
  group_by(year, stockid, group) %>%  # Include group in the grouping
  summarise(
    total_tons = sum(tsn, na.rm = TRUE),  # Sum TSN per stock per year
    scientificname = first(scientificname),  # Keep species name
    commonname = first(commonname),  # Keep common name
    areaid = first(areaid),  # Keep area ID
    stocklong = first(stocklong.y),  # Keep full stock name
    region = first(region),  # Keep region info
    inmyersdb = first(inmyersdb),  # Keep database flag
    myersstockid = first(myersstockid),  # Keep Myers stock ID
    .groups = "drop"
  )

# Display the summarized results
head(tsn_summary)

summary(tsn_summary)


# Step 5 (again): Ensure that 'group' is assigned in the 'tsn_per_year_filtered' dataset
tsn_per_year_filtered <- tsn_per_year_filtered %>%
  left_join(galicia_ram_filtered %>% select(stockid, group), by = "stockid")

# Add the 'group' column from 'galicia_ram_filtered' to 'tsn_per_year_filtered'
tsn_per_year_filtered <- tsn_per_year_filtered %>%
  left_join(galicia_ram_filtered %>% select(stockid, group), by = "stockid")

# Now summarize total TSN per year, per stockid, and per group
tsn_summary <- tsn_per_year_filtered %>%
  group_by(year, stockid, group) %>%  # Group by year, stockid, and group
  summarise(
    total_tons = sum(tsn, na.rm = TRUE),  # Sum TSN per stock per year
    scientificname = first(scientificname),  # Keep species name
    commonname = first(commonname),  # Keep common name
    areaid = first(areaid),  # Keep area ID
    stocklong = first(stocklong.y),  # Keep full stock name
    region = first(region),  # Keep region info
    inmyersdb = first(inmyersdb),  # Keep database flag
    myersstockid = first(myersstockid),  # Keep Myers stock ID
    .groups = "drop"  # Avoid nesting
  )

# Display the summarized results
head(tsn_summary)


# Display the summarized results
head(tsn_summary)
summary(tsn_summary)

# Extract data for each group
group1_data <- tsn_summary %>%
  filter(group == 1)

group2_data <- tsn_summary %>%
  filter(group == 2)

group3_data <- tsn_summary %>%
  filter(group == 3)

group4_data <- tsn_summary %>%
  filter(group == 4)

group5_data <- tsn_summary %>%
  filter(group == 5)

# Step 6: Compare if the stockid is repeated across groups
# Combine all groups data into one dataset for easier comparison
all_groups_data <- bind_rows(
  group1_data %>% mutate(group = 1),
  group2_data %>% mutate(group = 2),
  group3_data %>% mutate(group = 3),
  group4_data %>% mutate(group = 4),
  group5_data %>% mutate(group = 5)
)

# Initialize merged dataframe with Group 1 data
merged_data <- group1_data

# Merge Group 2, excluding those already in Group 1
group2_not_in_group1 <- setdiff(group2_data$stockid, group1_data$stockid)
merged_data <- bind_rows(merged_data, group2_data %>% filter(stockid %in% group2_not_in_group1))

# Merge Group 3, excluding those already in Group 1 or Group 2
group3_not_in_group1_2 <- setdiff(group3_data$stockid, merged_data$stockid)
merged_data <- bind_rows(merged_data, group3_data %>% filter(stockid %in% group3_not_in_group1_2))

# Merge Group 4, excluding those already in Groups 1, 2, or 3
group4_not_in_group1_2_3 <- setdiff(group4_data$stockid, merged_data$stockid)
merged_data <- bind_rows(merged_data, group4_data %>% filter(stockid %in% group4_not_in_group1_2_3))

# Merge Group 5, excluding those already in Groups 1, 2, 3, or 4
group5_not_in_group1_2_3_4 <- setdiff(group5_data$stockid, merged_data$stockid)
merged_data <- bind_rows(merged_data, group5_data %>% filter(stockid %in% group5_not_in_group1_2_3_4))

# Display the final merged data
head(merged_data)

# Check for duplicates in merged_data
duplicates_check <- merged_data %>%
  group_by(stockid, year) %>%
  summarise(duplicates = n()) %>%
  filter(duplicates > 1)  # Filter for duplicate entries where more than one row exists

unique(merged_data$scientificname)


TAC_quotas_2021 <- read.csv("TAC_2021_SP.csv", fileEncoding = "UTF-8",   na.strings = c("NA", "na", "", "NULL"))

TAC_quotas_2021 <- TAC_quotas_2021 %>%
  mutate(
    TAC_2021 = str_trim(TAC_2021),  # Remove leading and trailing spaces
    TAC_2021 = str_replace_all(TAC_2021, " ", ""),  # Remove internal spaces
    TAC_2021 = as.numeric(TAC_2021)  # Convert to numeric, non-numeric becomes NA
  )


#write.csv(TAC_quotas_2021, "cleaned_TAC_2021.csv", row.names = FALSE)

colnames(TAC_quotas_2021)[colnames(TAC_quotas_2021) == "SP"] <- "scientificname"

TAC_quotas_2021 <- TAC_quotas_2021 %>%
  mutate(scientificname = tolower(`scientificname`))

group1_data <- group1_data %>%
  mutate(scientificname = tolower(scientificname))

group2_data <- group2_data %>%
  mutate(scientificname = tolower(scientificname))

group3_data <- group3_data %>%
  mutate(scientificname = tolower(scientificname))

group4_data <- group4_data %>%
  mutate(scientificname = tolower(scientificname))

group5_data <- group5_data %>%
  mutate(scientificname = tolower(scientificname))


# Summarize total tons per year per scientificname per group
total_tons_per_year_species_group1 <- group1_data %>%
  group_by(year, scientificname) %>%  
  summarise(
    total_tons = sum(total_tons, na.rm = TRUE),  
    .groups = "drop"  
  )

total_tons_per_year_species_group2 <- group2_data %>%
  group_by(year, scientificname) %>%
  summarise(
    total_tons = sum(total_tons, na.rm = TRUE),
    .groups = "drop"
  )

total_tons_per_year_species_group3 <- group3_data %>%
  group_by(year, scientificname) %>%
  summarise(
    total_tons = sum(total_tons, na.rm = TRUE),
    .groups = "drop"
  )

total_tons_per_year_species_group4 <- group4_data %>%
  group_by(year, scientificname) %>%
  summarise(
    total_tons = sum(total_tons, na.rm = TRUE),
    .groups = "drop"
  )

total_tons_per_year_species_group5 <- group5_data %>%
  group_by(year, scientificname) %>%
  summarise(
    total_tons = sum(total_tons, na.rm = TRUE),
    .groups = "drop"
  )

# Merge each group with TAC_quotas_2021 based on the scientific name
group1_with_TAC <- total_tons_per_year_species_group1 %>%
  inner_join(TAC_quotas_2021, by = c("scientificname" = "scientificname"), relationship = "many-to-many")

group2_with_TAC <- total_tons_per_year_species_group2 %>%
  inner_join(TAC_quotas_2021, by = c("scientificname" = "scientificname"), relationship = "many-to-many")

group3_with_TAC <- total_tons_per_year_species_group3 %>%
  inner_join(TAC_quotas_2021, by = c("scientificname" = "scientificname"), relationship = "many-to-many")

group4_with_TAC <- total_tons_per_year_species_group4 %>%
  inner_join(TAC_quotas_2021, by = c("scientificname" = "scientificname"), relationship = "many-to-many")

group5_with_TAC <- total_tons_per_year_species_group5 %>%
  inner_join(TAC_quotas_2021, by = c("scientificname" = "scientificname"), relationship = "many-to-many")

head(group2_with_TAC)


# Calculate the TAC_2021 / total_tons ratio per row for group1_with_TAC
group1_with_TAC_ratio <- group1_with_TAC %>%
  mutate(
    TAC_2021 = as.numeric(TAC_2021),  # Ensure TAC_2021 is numeric
    ratio_TAC_total = TAC_2021 / total_tons  # Calculate the ratio for each row
  )

# Calculate the TAC_2021 / total_tons ratio per row for group2_with_TAC
group2_with_TAC_ratio <- group2_with_TAC %>%
  mutate(
    TAC_2021 = as.numeric(TAC_2021),  # Ensure TAC_2021 is numeric
    ratio_TAC_total = TAC_2021 / total_tons  # Calculate the ratio for each row
  )

# Calculate the TAC_2021 / total_tons ratio per row for group3_with_TAC
group3_with_TAC_ratio <- group3_with_TAC %>%
  mutate(
    TAC_2021 = as.numeric(TAC_2021),  # Ensure TAC_2021 is numeric
    ratio_TAC_total = TAC_2021 / total_tons  # Calculate the ratio for each row
  )

# Check the updated data
table(group1_with_TAC_ratio)
head(group2_with_TAC_ratio)
head(group3_with_TAC_ratio)

# Optionally, save the final datasets to CSV files
write.csv(group1_with_TAC_ratio, "group1_with_TAC_ratio.csv", row.names = FALSE)
write.csv(group2_with_TAC_ratio, "group2_with_TAC_ratio.csv", row.names = FALSE)
write.csv(group3_with_TAC_ratio, "group3_with_TAC_ratio.csv", row.names = FALSE)

