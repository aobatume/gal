library(dplyr)
library(readr)


# Define column names for all datasets
column_names <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", 
                  "market", "kg", "euros", "price_per_kilo")

# Read CSV files with defined column names
pescafresca_22 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2022.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_21 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2021.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_20 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2020.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_19 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2019.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_18 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2018.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_17 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2017.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_16 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2016.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_15 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2015.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_14 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2014.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_13 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2013.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_12 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2012.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_11 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2011.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_10 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2010.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_09 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2009.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_08 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2008.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_07 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2007.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_06 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2006.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_05 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2005.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_04 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2004.csv", 
                           header=FALSE, sep=";", col.names=column_names)
pescafresca_03 <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/pescafresca2003.csv", 
                           header=FALSE, sep=";", col.names=column_names)


# List of datasets with corresponding years
datasets <- list(
  "2022" = pescafresca_22, "2021" = pescafresca_21, "2020" = pescafresca_20, "2019" = pescafresca_19,
  "2018" = pescafresca_18, "2017" = pescafresca_17, "2016" = pescafresca_16, "2015" = pescafresca_15,
  "2014" = pescafresca_14, "2013" = pescafresca_13, "2012" = pescafresca_12, "2011" = pescafresca_11,
  "2010" = pescafresca_10, "2009" = pescafresca_09, "2008" = pescafresca_08, "2007" = pescafresca_07,
  "2006" = pescafresca_06, "2005" = pescafresca_05, "2004" = pescafresca_04, "2003" = pescafresca_03
)

# Add year column and combine all data
combined_data <- bind_rows(
  lapply(names(datasets), function(year) {
    df <- datasets[[year]]
    df$year <- as.numeric(year)  
    return(df)
  })
)

# Ensure columns are correct
colnames(combined_data) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", 
                             "Admi_area", "market", "kg", "euros", "price_per_kilo", "year")

# Convert kg and euros to numeric (fixing potential character issues)
combined_data <- combined_data %>%
  mutate(
    kg = as.numeric(gsub(",", ".", kg)),  
    euros = as.numeric(gsub(",", ".", euros))
  )

# Summarize total kg and euros per species and year
total_summary_PESCA <- combined_data %>%
  group_by(year, Galician_name) %>%
  summarise(
    total_kg = sum(kg, na.rm = TRUE),
    total_euros = sum(euros, na.rm = TRUE)
  ) %>%
  arrange(desc(year))  

# Print the summary
print(total_summary_PESCA)




"FAOcode"






galician_spanish_scientific_names <- read_csv("prep/FIS/galician_spanish_scientific_names.csv")



# Rename and convert 'Galician Name' to lowercase 

nomes_sp <- read_csv("prep/FIS/galician_spanish_scientific_names.csv", col_names = c("Galician_name", "Spanish_name", "scientificname"))

nomes_sp <- nomes_sp %>% 
  mutate(Galician_name = tolower(Galician_name))


total_summary_PESCA <- total_summary_PESCA %>%
  mutate(Galician_name = tolower(Galician_name))


# Save to CSV
#write.csv(total_summary_PESCA, "total_summary_per_year_PESCADEGALICIA.csv", row.names = FALSE)


# Merge datasets based on Galician names
merged_data <- total_summary_PESCA %>%
  left_join(nomes_sp, by = c("Galician_name" = "Galician_name"))

# Summarize total tons per scientific name per year
tons_per_scientific_year <- merged_data %>%
  group_by(year, Scientific_Name) %>%
  summarise(total_tons = sum(total_tons, na.rm = TRUE), .groups = "drop")  

# Display results
head(tons_per_scientific_year)
summary(tons_per_scientific_year)




