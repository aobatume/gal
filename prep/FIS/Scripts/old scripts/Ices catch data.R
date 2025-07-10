# Load necessary libraries
library(dplyr)
library(tidyr)

# Set the file path to the CSV file
file_path <- "path/to/Galicia_ices_catch.csv"

# Load the CSV data
data <- read.csv(file_path, encoding = "UTF-8")

# Inspect the first few rows to understand the structure
head(data)
colnames(data)

# Reshape the data from wide to long format
# Assuming "Species" is the column with species names
long_data <- data %>%
  pivot_longer(
    cols = -"Latin species name",                # Select all columns except "Species" to pivot
    names_to = "Year",               # New column for years
    values_to = "TLW"                # New column for TLW values
  )

# Convert the "Year" column to numeric if it's currently character
long_data$Year <- as.numeric(long_data$Year)

# Calculate total TLW per year per species (in this case, summing across entries if necessary)
# If each species/year combination is unique, this step may be unnecessary
total_tlw <- long_data %>%
  group_by(Species, Year) %>%
  summarize(total_tlw = sum(TLW, na.rm = TRUE))

# View the result
print(total_tlw)

# Save the result to a new CSV file
write.csv(total_tlw, "total_tlw_per_year_per_species.csv", row.names = FALSE)


library(dplyr)
library(tidyr)

# Reshape the data from wide to long format
long_data <- data %>%
  pivot_longer(
    cols = -species_name,  # Replace 'species_name' with the actual column name
    names_to = "Year",
    values_to = "TLW"
  )

# Convert Year to numeric, if necessary
long_data$Year <- as.numeric(long_data$Year)

# Calculate total TLW per year per species
total_tlw <- long_data %>%
  group_by(species_name, Year) %>%  # Replace 'species_name' with the actual column name
  summarize(total_tlw = sum(TLW, na.rm = TRUE))

# View the result
print(total_tlw)

