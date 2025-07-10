#SCRIPT 1: FISHERIES GOAL

##Filter out Galician data from the ICES database - areas = 27.8.c & 27.9.a, and country = Spain

library(readxl)
library(dplyr)

setwd("/Users/batume/Documents/R/OHI_GAL/prep/FIS")

ices_data <- read_excel("/Users/batume/Documents/R/OHI_GAL/prep/FIS/ICESCatchDataset2006-2022.xlsx", sheet = "Dataset")
table(ices_data$Area)

species_data <- read_excel("/Users/batume/Documents/R/OHI_GAL/prep/FIS/ICESCatchDataset2006-2022.xlsx", sheet = "Species")

galicia_areas <- ices_data %>%
  filter(grepl("27.8.c|27.9.a", Area))

merged_data <- galicia_areas %>%
  left_join(species_data, by = c("Column1" = "FAO_code"))

Galicia_ices_catch <- merged_data %>%
  filter(Country == "ES")

print(Galicia_ices_catch)

# dataset to a CSV file
write.csv(Galicia_ices_catch, "Filtered_Galicia_Spain_ICES_Data.csv", row.names = FALSE)


##Download B/Bmsy data, obtained from RAM, v. 4.65 (Jun-03-24)
##https://ohi-science.org/ohiprep_v2020/globalprep/fis/v2020/catch_data_prep.html 

knitr::opts_chunk$set(fig.width = 6, fig.height = 4, fig.path = 'figs/',message = FALSE, warning = FALSE)

setwd("/Users/batume/Documents/R/OHI_GAL/prep/FIS")

load("DBdata[asmt][v4.65].RData")

write.csv(Galicia_ices_catch, "Galicia_ices_catch.csv", row.names = FALSE)



# Load necessary libraries
library(dplyr)

# Set the file path to the CSV file
file_path <- "path/to/your/Galicia_ices_catch.csv"

# Load the CSV data
data <- Galicia_ices_catch

# Inspect the first few rows to ensure columns are correct
head(data)

# Assuming the columns are named "year", "species", and "tlw"
# Summarize the data to obtain total TLW per year per species
total_tlw <- data %>%
  group_by(year, species) %>%
  summarize(total_tlw = sum(tlw, na.rm = TRUE))

# View the result
print(total_tlw)

# Save the result to a new CSV file
write.csv(total_tlw, "total_tlw_per_year_per_species.csv", row.names = FALSE)





table(top_species_data$market)



# Extract Atlantic Ocean stocks

# Data for Atlantic Ocean stocks, obtained from RAM, v. 4.65 (Jun-03-24) (List obtained fron AtlanticOceanSummary)

atlanticstocks_list <- data.frame(
  Stock_Code = c("ALBANATL", "ALBASATL", "ATBTUNAEATL", "ATBTUNAWATL", "BIGEYEATL",
                 "BLSHARNATL", "BLSHARSATL", "BMARLINATL", "SAILEATL", "SAILWATL",
                 "SFMAKONATL", "SFMAKOSATL", "SKJEATL", "SKJWATL", "SWORDNATL",
                 "SWORDSATL", "WMARLINATL", "YFINATL"),
  Stock_Name = c("Albacore tuna Northern Atlantic", "Albacore tuna South Atlantic",
                 "Atlantic bluefin tuna Eastern Atlantic", "Atlantic bluefin tuna Western Atlantic",
                 "Bigeye tuna Atlantic Ocean", "Blue shark Northern Atlantic",
                 "Blue shark South Atlantic", "Blue marlin Atlantic Ocean",
                 "Sailfish Eastern Atlantic", "Sailfish Western Atlantic",
                 "Shortfin mako Northern Atlantic", "Shortfin mako South Atlantic",
                 "Skipjack tuna Eastern Atlantic", "Skipjack tuna Western Atlantic",
                 "Swordfish Northern Atlantic", "Swordfish South Atlantic",
                 "White marlin Atlantic Ocean", "Yellowfin tuna Atlantic Ocean")
)

# Filter using the stock codes in atlanticstocks_list
filtered_timeseries <- timeseries_values_views %>%
  filter(stockid %in% atlanticstocks_list$Stock_Code)

 filtered_tsmetrics <- tsmetrics %>%
  filter(stockid %in% atlanticstocks_list$Stock_Code)

filtered_metadata <- metadata %>%
  filter(stockid %in% atlanticstocks_list$Stock_Code)

## Sebastian dataset

ices_data <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/sag_extraction_ICES dataset.csv")

# Filter the dataset for the desired ICES areas (27.9.a and 27.8.c)
filtered_ices_data <- ices_data %>%
  filter(grepl("27.9.a", `ICES.Areas..splited.with.character.....`) | 
           grepl("27.8.c", `ICES.Areas..splited.with.character.....`))

# Summarize total catches per area and per stock
summary_catches <- ices_data %>%
  group_by(`ICES.Areas..splited.with.character.....`, FishStock) %>%
  summarise(Total_Catches = sum(Catches, na.rm = TRUE), .groups = "drop")

# Summarize total catches per area
summary_catches_per_area <- ices_data %>%
  group_by(`ICES.Areas..splited.with.character.....`) %>%
  summarise(Total_Catches = sum(Catches, na.rm = TRUE), .groups = "drop")

# Print the first few rows to verify
head(summary_catches)
head(summary_catches_per_area)

## Compare to pescafresca

# Function to read and clean the CSV files, Convert columns with commas as decimal separators to numeric format with dots
read_and_clean <- function(file_path, col_names) {

  data <- read.csv(file_path, sep = ";", header = FALSE)
  colnames(data) <- col_names
  data <- data %>%
    mutate(across(where(is.character), ~ ifelse(grepl("^[0-9.,-]+$", .), as.numeric(gsub(",", ".", .)), .)))
  return(data)
}

# Define the correct column names
col_names <- c("Date", "Group", "Species_Code", "Species_Name", "Province", "Area", 
               "Subarea", "Location", "X101.800", "X897.450")

summary(table(pescafresca_15$X101.800))

# Load and clean all datasets using the defined column names

pescafresca_22 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2022.csv", header=FALSE, sep=";")
pescafresca_21 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2021.csv", header=FALSE, sep=";")
pescafresca_20 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2020.csv", header=FALSE, sep=";")
pescafresca_19 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2019.csv", header=FALSE, sep=";")
pescafresca_18 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2018.csv", header=FALSE, sep=";")
pescafresca_17 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2017.csv", header=FALSE, sep=";")
pescafresca_16 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2016.csv", header=FALSE, sep=";")
pescafresca_15 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2015.csv", header=FALSE, sep=";")
pescafresca_14 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2014.csv", header=FALSE, sep=";")
pescafresca_13 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2013.csv", header=FALSE, sep=";")
pescafresca_12 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2012.csv", header=FALSE, sep=";")
pescafresca_11 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2011.csv", header=FALSE, sep=";")
pescafresca_10 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2010.csv", header=FALSE, sep=";")
pescafresca_09 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2009.csv", header=FALSE, sep=";")
pescafresca_08 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2008.csv", header=FALSE, sep=";")
pescafresca_07 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2007.csv", header=FALSE, sep=";")
pescafresca_06 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2006.csv", header=FALSE, sep=";")
pescafresca_05 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2005.csv", header=FALSE, sep=";")
pescafresca_04 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2004.csv", header=FALSE, sep=";")
pescafresca_03 <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/pescafresca2003.csv", header=FALSE, sep=";")

columns_to_convert <- c("col1", "col2", "col3")  # Replace with your actual column names
data[columns_to_convert] <- lapply(data[columns_to_convert], function(x) as.numeric(gsub(",", ".", x)))
