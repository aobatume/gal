# FORGET ABOT THE INTIAL BIT AND JUMP TO # This is the efficient way:

#Set wd and load libraries
setwd("/Users/batume/Documents/R/OHI_GAL/prep/FIS")
library(ramlegacy)
library(dplyr)

#Ram data already from RAM package (check version)
#download_ramlegacy(version = "4.44")
ram_data <- load_ramlegacy(version = "4.44")

names(ram_data)
stock_data <- ram_data$stock

#Filter data for Galicia - use northeast atlantic region and spain.
galicia_data_ram <- ram_data$stock %>%
  filter(grepl("Northeast Atlantic", region, ignore.case = TRUE) | 
           grepl("Spain", areaid, ignore.case = TRUE) |
           grepl("ICES", areaid, ignore.case = TRUE))


table(galicia_data_ram$commonname)


galicia_ram_filtered <- filtered_data <- galicia_data_ram[grepl("VII", galicia_data_ram$areaid), ]

table(unique(galicia_ram_filtered$commonname))
summary(galicia_ram_filtered)

#List of species mentioned in the ALTAS DE FLOTA DE BAIXURA DA XUNTA
#sp_galicia<-read.csv("/Users/batume/Documents/R/OHI_GAL/prep/FIS/ALL_SPECIES_FISHED_IN_COASTAL_GALICIA.CSV")
#Export to compare to sp_galicia
#write.csv(galicia_data$scientificname, "/Users/batume/Documents/galicia_data_scientificname.csv", row.names = FALSE)
# List of common species identified (used chatgpt)
#common_species <- c(
#  "trachurus picturatus",
# "micromesistius poutassou",
# "dicentrarchus labrax",
# "platichthys flesus",
# "pollachius pollachius"
#)
#scientificname<-galicia_data$scientificname


# Filter rows where the scientificname is in the list of common species
filtered_data <- galicia_data %>%
  filter(scientificname %in% common_species)

unique(ram_data$area)

commonname_scientificname_table <- galicia_data %>%
  group_by(commonname, scientificname) %>%
  summarize(frequency = n()) %>%
  ungroup()
write.csv(commonname_scientificname_table, "commonname_scientificname_frequency.csv", row.names = FALSE)


# Save the frequency table as a CSV
write.csv(commonname_df, "commonname_frequency.csv", row.names = FALSE)


scientificname <- galicia_data$scientificname


# Filter rows where the scientificname is in the list of common species - pay attention to format and modify everything so that its lowercase
filtered_data <- galicia_data %>%
  filter(tolower(scientificname) %in% tolower(common_species))


colnames(pescafresca_2022) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2021) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2020) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2019) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2018) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2017) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2016) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2015) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2014) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2013) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2012) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2011) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2010) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2009) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2008) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2007) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2006) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2005) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2004) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_2003) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")



# This is the efficient way:


library(dplyr)


file_paths <- list.files(path = "/Users/batume/Documents/R/OHI_GAL/prep/FIS/", 
                         pattern = "pescafresca\\d{4}.csv", full.names = TRUE)
col_names <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", 
               "Admi_area", "market", "kg", "euros", "price_per_kilo")

read_and_prepare <- function(file_path) {
  data <- read.csv(file_path, header = FALSE, sep = ";", col.names = col_names)
  
  # Convert specific columns from comma to period and to numeric
  data <- data %>%
    mutate(across(c(kg, euros, price_per_kilo), ~as.numeric(gsub(",", ".", .))))
  
  return(data)
}


pescafresca_data <- lapply(file_paths, read_and_prepare)
all_years_data <- bind_rows(pescafresca_data)
head(all_years_data)


table(try$market)
try<-all_years_data[all_years_data$Province == "Pontevedra",]

try<-all_years_data[all_years_data$market == c("Redondela", "Arcade", "Vilaboa" , "Moaña", "Vigo", "Cangas", "Baiona", "Aldán-Hio", "Vigo (Canido)"),]
"Redondela", "Arcade", "Vilaboa" , "Moaña", "Vigo", "Cangas", "Baiona", "Aldán-Hio", "Vigo (Canido)"

# Filter rows where 'market' matches any of the specified values
sansimon_lonxas<- all_years_data[all_years_data$market %in% c("Redondela", "Arcade", "Vilaboa", "Moaña", "Vigo", "Cangas", "Baiona", "Aldán-Hio", "Vigo (Canido)"), ]

write.csv(sansimon_lonxas, "sansimon_lonxas.csv", row.names = FALSE)












library(dplyr)

data<-try
# Group by species and calculate total euros and kg for each
top_species <- data %>%
  group_by(Galician_name) %>%
  summarise(
    total_euros = sum(euros, na.rm = TRUE),
    total_kg = sum(kg, na.rm = TRUE)
  ) %>%
  # Arrange by descending total euros and total kg
  arrange(desc(total_euros), desc(total_kg)) %>%
  # Select the top 10 species
  slice_head(n = 10)

# Display the result
print(top_species)











# Load necessary libraries
library(dplyr)

# Calculate total euros and kg for each species, then filter the original data
top_species <- data %>%
  group_by(Galician_name) %>%
  summarise(
    total_euros = sum(euros, na.rm = TRUE),
    total_kg = sum(kg, na.rm = TRUE)
  ) %>%
  # Arrange by descending total euros and total kg
  arrange(desc(total_euros), desc(total_kg)) %>%
  # Select the top 10 species based on euros and kg
  slice_head(n = 10) %>%
  # Select only the Galician_name for filtering
  pull(Galician_name)

# Filter the original data to keep only rows for the top 10 species
top_species_data <- data %>%
  filter(Galician_name %in% top_species)

# Display the result

print(top_species_data)
table(top_species_data$Galician_name)

