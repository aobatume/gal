# Load necessary libraries
library(dplyr)
library(readr)
library(readr)

# Define column names
column_names <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", 
                  "Admi_area", "market", "kg", "euros", "price_per_kilo")

# Define years of datasets
years <- 2003:2022

# Read CSV files dynamically and store in a list
datasets <- lapply(years, function(year) {
  file_path <- paste0("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca", year, ".csv")
  if (file.exists(file_path)) {
    df <- read.csv(file_path, header=FALSE, sep=";", col.names=column_names)
    df$year <- year  # Add year column
    return(df)
  } else {
    return(NULL)
  }
})

# Remove NULL values (for missing years) and bind datasets into one dataframe
combined_data <- bind_rows(datasets)

# Ensure numeric conversion (fixing potential character encoding issues)
combined_data <- combined_data %>%
  mutate(
    kg = as.numeric(gsub(",", ".", kg)),  
    euros = as.numeric(gsub(",", ".", euros))
  )

# Summarize total kg and euros per species and year

total_summary_PESCA <- combined_data %>%
  group_by(year, Galician_name, FAOcode) %>%  # Add FAOcode to group_by
  summarise(
    total_kg = sum(kg, na.rm = TRUE),
    total_euros = sum(euros, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(year))


#Check FAO CODES https://www.fao.org/fishery/en/collection/asfis/en

asfis_raw <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/ASFIS_sp_2024.csv", encoding = "Latin1")
colnames(asfis_raw)

asfis <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/ASFIS_sp_2024.csv", encoding = "Latin1") %>%
  select(
    FAOcode = Alpha3_Code,
    Scientific_name = Scientific_Name,
    English_name = English_name,
    Family, Order.or.higher.taxa
  )


head(asfis)

merged_data <- total_summary_PESCA %>%
  left_join(asfis, by = "FAOcode")

# Missing species: CTS - Venerupis corrugata , HK0 - Merluccius merluccius*, LA5 - Saccorhiza polyschides, LI0 - Molva molva*, BL0 - X, PO0 - Brama brama*











################## MESSY BITS ##################################################################################

### Fix names from Galician and Spanish data 


# Load species names reference table
nomes_sp <- read_csv("/Users/batume/Documents/R/GAL_git/prep/FIS/nomes_sp.csv") %>%
  rename(Galician_name = `Galicia`) %>%
  mutate(Galician_name = tolower(Galician_name))

nomes_gal <- read_csv(
  "/Users/batume/Documents/R/GAL_git/prep/FIS/especies.csv",
  locale = locale(encoding = "Latin1"),
  col_types = cols(.default = "c")
)

nomes_gal<- nomes_gal %>% rename(Galician_name = `nombreGallego`, Scientific_Name = nombreCientifico,  FAOcode = codigo) %>%
  mutate(Galician_name = tolower(Galician_name))

# Now merge with nomes_gal using FAOcode
merged_data <- total_summary_PESCA %>%
  left_join(nomes_gal, by = "FAOcode")  # Join by FAOcode instead of Galician_name

# Print summary
print(total_summary_PESCA)

# Save to CSV
write.csv(total_summary_PESCA, "total_summary_per_year_PESCADEGALICIA.csv", row.names = FALSE)










# Convert Galician_name in the summary table to lowercase for consistency
total_summary_PESCA <- total_summary_PESCA %>%
  mutate(Galician_name = tolower(Galician_name))

# Keep only unique species in nomes_sp based on Galician_name
nomes_sp <- nomes_sp %>%
  group_by(Galician_name) %>%
  summarise(across(everything(), first))  # Keep the first occurrence for each species


# Merge datasets based on Galician names
merged_data <- total_summary_PESCA %>%
  left_join(nomes_sp, by = "Galician_name")

# Check for many-to-many relationships and correct if needed
merged_data <- merged_data %>%
  distinct()  # Remove potential duplicates from the join

# Count unique species before and after
nrow(total_summary_PESCA)  # Before join
nrow(merged_data)  # After join

# Display results
head(merged_data)

#Show the species that still have Nombre científico = NA and modify the columnname

sennome<- merged_data %>% 
  filter(is.na(Scientific_Name))
  
  
table(sennome$Galician_name)
  

# Save merged dataset
write.csv(merged_data, "merged_summary_PESCADEGALICIA.csv", row.names = FALSE)


#Check for missing data (no FAO CODE)

# Rename columns
colnames(merged_data) <- c("year", "Galician_name", "total_kg", "total_euros", 
                           "Spanish_name", "Scientific_Name", "Andalucia", "Asturias", 
                           "Baleares", "Canarias", "Cantabria", "Cataluna", 
                           "Valencia", "Murcia", "Pais_Vasco", "FAO")

# Remove unnecessary columns
merged_data <- merged_data %>%
  select(-c(Andalucia, Asturias, Baleares, Canarias, Cantabria, Cataluna, 
            Valencia, Murcia, Pais_Vasco))

# Print the updated dataframe structure
print(colnames(merged_data))


species_without_fao <- merged_data %>%
  filter(is.na(FAO) | FAO == "")  # Filter species without an FAO code

# Print to verify
print(unique(species_without_fao$Galician_name))

# Save the dataset to CSV
write.csv(species_without_fao, "species_without_fao_full.csv", row.names = FALSE)




file_path <- "~/Downloads/species_pescagal.txt"  # Change this to the actual file location
species_pescagal <- read_delim(file_path, delim = ";", col_types = cols(), locale = locale(encoding = "UTF-8"))
head(merged_data)
head(species_pescagal)

# Ensure Galician_name is lowercase in both datasets to match names correctly
merged_data <- merged_data %>%
  mutate(Galician_name = tolower(Galician_name))

species_pescagal <- species_pescagal %>%
  mutate(Galician_name = tolower(Galician_name))

# Merge datasets, ensuring missing values in merged_data are filled from species_pescagal
merged_data_2 <- merged_data %>%
  left_join(species_pescagal, by = "Galician_name") %>%
  mutate(
    FAO = coalesce(FAO.x, FAO.y),  # Fill missing FAO codes from species_pescagal
    Scientific_Name = coalesce(Scientific_Name.x, Scientific_Name.y)  # Fill missing scientific names
  ) %>%
  select(-FAO.x, -FAO.y, -Scientific_Name.x, -Scientific_Name.y)  # Remove redundant columns

# Save the updated dataset
write.csv(merged_data_2, "merged_data_filled.csv", row.names = FALSE)

# Display summary of missing FAO values after merging
sum(is.na(merged_data_2$FAO))
summary(unique(merged_data_2$FAO))
# Print the first few rows to verify the merge
head(merged_data_2)













######################################################################################################################################################TRY ## 2

# Load necessary libraries
library(dplyr)
library(readr)


file_path <- "~/Downloads/species_pescagal.txt"  # Change this to the actual file location
species_pescagal <- read_delim(file_path, delim = ";", col_types = cols(), locale = locale(encoding = "UTF-8"))
head(merged_data)
head(species_pescagal)

# Ensure Galician_name is lowercase in both datasets to match names correctly
merged_data <- merged_data %>%
  mutate(Galician_name = tolower(Galician_name))

species_pescagal <- species_pescagal %>%
  mutate(Galician_name = tolower(Galician_name))

# Merge datasets, ensuring missing values in merged_data are filled from species_pescagal
merged_data_2 <- merged_data %>%
  left_join(species_pescagal, by = "Galician_name") %>%
  mutate(
    FAO = coalesce(FAO.x, FAO.y),  # Fill missing FAO codes from species_pescagal
    Scientific_Name = coalesce(Scientific_Name.x, Scientific_Name.y)  # Fill missing scientific names
  ) %>%
  select(-FAO.x, -FAO.y, -Scientific_Name.x, -Scientific_Name.y)  # Remove redundant columns

# Save the updated dataset
write.csv(merged_data_2, "merged_data_filled.csv", row.names = FALSE)

# Display summary of missing FAO values after merging
sum(is.na(merged_data_2$FAO))
summary(unique(merged_data$FAO))
# Print the first few rows to verify the merge
head(merged_data_2)







######################################################################################################################################################TRY ## 3

# Load necessary libraries
library(dplyr)
library(readr)


file_path <- "~/Downloads/species_pescagal.txt"  # Change this to the actual file location
species_pescagal <- read_delim(file_path, delim = ";", col_types = cols(), locale = locale(encoding = "UTF-8"))
head(merged_data)
head(species_pescagal)

# Ensure Galician_name is lowercase in both datasets to match names correctly
merged_data <- merged_data %>%
  mutate(Galician_name = tolower(Galician_name))

species_pescagal <- species_pescagal %>%
  mutate(Galician_name = tolower(Galician_name))

# Merge datasets, ensuring missing values in merged_data are filled from species_pescagal
merged_data_2 <- merged_data %>%
  left_join(species_pescagal, by = "Galician_name") %>%
  mutate(
    FAO = coalesce(FAO.x, FAO.y),  # Fill missing FAO codes from species_pescagal
    Scientific_Name = coalesce(Scientific_Name.x, Scientific_Name.y)  # Fill missing scientific names
  ) %>%
  select(-FAO.x, -FAO.y, -Scientific_Name.x, -Scientific_Name.y)  # Remove redundant columns

# Save the updated dataset
write.csv(merged_data_2, "merged_data_filled.csv", row.names = FALSE)

# Display summary of missing FAO values after merging
sum(is.na(merged_data_2$FAO))
summary(unique(merged_data$FAO))
# Print the first few rows to verify the merge
head(merged_data_2)

#########################################################################################################################################TRY ## 4 (clean names)

library(dplyr)
library(stringr)  # Ensure string functions are available


# Apply cleaning function
merged_data <- merged_data %>%
  mutate(Galician_name = clean_name(Galician_name))

species_pescagal <- species_pescagal %>%
  mutate(Galician_name = clean_name(Galician_name))

clean_name <- function(name) {
  name %>%
    tolower() %>%  
    str_trim() %>%  # Remove leading/trailing spaces
    str_replace_all("[^a-zñáéíóúü]", "")  # Remove special characters except for letters
}

# Apply cleaning function
merged_data <- merged_data %>%
  mutate(Galician_name = clean_name(Galician_name))

species_pescagal <- species_pescagal %>%
  mutate(Galician_name = clean_name(Galician_name))
missing_names <- setdiff(unique(merged_data$Galician_name), unique(species_pescagal$Galician_name))
print(missing_names)  # These species still have no FAO codes

extra_names <- setdiff(unique(species_pescagal$Galician_name), unique(merged_data$Galician_name))
print(extra_names)  # These species exist in species_pescagal but not in merged_data

merged_data_2 <- merged_data %>%
  left_join(species_pescagal, by = "Galician_name") %>%
  mutate(
    FAO = coalesce(FAO.x, FAO.y),  # Fill missing FAO codes
    Spanish_name = coalesce(Spanish_name.x, Spanish_name.y),
    Scientific_Name = coalesce(Scientific_Name.x, Scientific_Name.y)
  ) %>%
  select(-FAO.x, -FAO.y, -Spanish_name.x, -Spanish_name.y, -Scientific_Name.x, -Scientific_Name.y)  # Remove redundant columns

sum(is.na(merged_data_2$FAO))  # Check missing FAO codes again

#########################################################################################################################################TRY ## 5 (clean names)

library(dplyr)
library(stringr)

# Improved function to clean names (preserving accents and spaces)
clean_name <- function(name) {
  name %>%
    tolower() %>%  
    str_trim() %>%  # Remove leading/trailing spaces
    str_replace_all("[^a-zñáéíóúü ]", "")  # Remove unwanted characters except spaces and accents
}

# Apply function to both datasets
merged_data <- merged_data %>%
  mutate(Galician_name = clean_name(Galician_name))

species_pescagal <- species_pescagal %>%
  mutate(Galician_name = clean_name(Galician_name))

# Merge datasets and fill missing FAO codes and scientific names
merged_data_2 <- merged_data %>%
  left_join(species_pescagal, by = "Galician_name") %>%
  mutate(
    FAO = coalesce(FAO.x, FAO.y),  # Fill FAO codes
    Scientific_Name = coalesce(Scientific_Name.x, Scientific_Name.y)  # Fill scientific names
  ) %>%
  select(-FAO.x, -FAO.y, -Scientific_Name.x, -Scientific_Name.y)  # Remove redundant columns

# Check remaining missing FAO codes
sum(is.na(merged_data_2$FAO))

species_still_missing_fao <- merged_data_2 %>%
  filter(is.na(FAO) | FAO == "")

print(unique(species_still_missing_fao$Galician_name))  # Verify missing species
