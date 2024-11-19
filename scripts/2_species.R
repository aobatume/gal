library(dplyr)

#MODIFYING SPECIES LIST 

# Read the CSV file
species_data <- read.csv("/Users/batume/Documents/R/OHI_GAL/species.csv", header=TRUE, sep=";")

# Create new columns based on S1, S2, S3, and S4
species_data <- species_data %>%
  mutate(
    C = ifelse(S1 == "C" | S2 == "C" | S3 == "C" | S4 == "C", "YES", "NO"),
    LU = ifelse(S1 == "LU" | S2 == "LU" | S3 == "LU" | S4 == "LU", "YES", "NO"),
    PO = ifelse(S1 == "PO" | S2 == "PO" | S3 == "PO" | S4 == "PO", "YES", "NO"),
    OU = ifelse(S1 == "OU" | S2 == "OU" | S3 == "OU" | S4 == "OU", "YES", "NO")
  )

# Remove the original S1, S2, S3, S4 columns
species_data <- species_data %>%
  select(-S1, -S2, -S3, -S4)

# View the transformed data
print(species_data)

species_data$Scientific.Name <- gsub("\\*", "", species_data$Scientific.Name)

# Save the transformed data back to a CSV file
write.csv(species_data, "/Users/batume/Documents/R/OHI_GAL/transformed_species.csv", row.names = FALSE)
