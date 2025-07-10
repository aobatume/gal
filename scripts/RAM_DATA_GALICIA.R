
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


species_list <- c(
  "Merluccius merluccius",
  "Lophius piscatorius",
  "Lepidorhombus whiffiagonis",
  "Trachurus trachurus",
  "Sardina pilchardus",
  "Engraulis encrasicolus",
  "Scomber scombrus",
  "Pagellus bogaraveo",
  "Nephrops norvegicus"
)

galicia_ram_filtered <- galicia_data_ram[
  grepl("VIII|IX", galicia_data_ram$areaid) & galicia_data_ram$scientificname %in% species_list,
]

galicia_ram_filtered_AREA <- galicia_data_ram[grepl("VIII", galicia_data_ram$areaid), ]

table((galicia_ram_filtered_AREA$commonname))



galicia_ram_filtered_AREA <- galicia_data_ram[grepl("VIIIabc|VIIIc|IXa", galicia_data_ram$areaid), ]



stock_data <- stock_data[grepl("Horse mackerel", stock_data$commonname), ]











######### MESSY BITS ################

# Load necessary libraries
library(dplyr)
library(tidyr)

setwd("/Users/batume/Documents/R/GAL_git/prep/FIS")
galicia_ices_data <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/Galicia_ices_catch.csv", encoding = "UTF-8")
sag_extraction_ices_data <- read.csv("/Users/batume/Documents/R/GAL_git/prep/FIS/sag_extraction_ICES dataset.csv", encoding = "UTF-8")

table(sag_extraction_ices_data$ICES.Areas..splited.with.character.....)
