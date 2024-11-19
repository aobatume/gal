# devtools is needed for installing packages from Github
# install.packages("devtools")

# install OHICORE
devtools::install_github('ohi-science/ohicore')
library(ohicore)
library(tidyverse)
library(stringr)
library(zoo)
library(here)
library(ohicore)
library(dplyr)


setwd("/Users/batume/Documents/R/OHI_GAL/prep/TR")


#LOAD ALL THE CSV AT THE SAME TIME

# Function to load all CSV 
  # List of all CSV 
  csv_files <- list.files(directory, pattern = "\\.csv$", recursive = TRUE, full.names = TRUE)

  for (csv_file in csv_files) {
    df_name <- make.names(gsub("\\.csv$", "", basename(csv_file)))
    assign(df_name, read_csv(csv_file), envir = .GlobalEnv)
  }
}


directory <- "/Users/batume/Documents/R/OHI_GAL"
all_csv_data <- load_all_csvs_as_dataframes(directory)


# Function to download a single CSV file from a URL
download_csv <- function(url, destfile) {
  download.file(url, destfile, method = "auto")
  cat("Downloaded:", destfile, "\n")
}

url <- "https://www.ige.gal/igebdt/igeapi/datos/6328"
destfile <- "/Users/batume/Documents/R/OHI_GAL/Downloaded/pernoctas_costeiros.csv"
download_csv(url, destfile)



# Read a CSV file with ISO-8859-1 encoding
read_csv_iso88591 <- function(file_path) {
  indicadores_costa <- read.csv("/Users/batume/Documents/R/OHI_GAL/prep/TR/TR_IGE_indicadores_COSTA.csv", locale = locale(encoding = "ISO-8859-1"))
  return(data)
}


coastal_indicators <- subset(indicadores_costa, Indicadores == "Indicador Estacional (1)")
coastal_indicators <- coastal_indicators %>% select(-DatoT&-CodTempo)

write.csv(coastal_indicators, "/Users/batume/Documents/R/OHI_GAL/coastal_indic.csv", row.names = FALSE)

## NORMALIZE DATA

# Min-Max normalization function
min_max_normalize <- function(x) {
  (x - min(x)) / (max(x) - min(x))
}

# Apply Min-Max normalization to the 'DatoN' column
coastal_indicators <- coastal_indicators %>%
  mutate(DatoN_normalized = min_max_normalize(DatoN))

head(coastal_indicators)

write.csv(coastal_indicators, "/Users/batume/Documents/R/OHI_GAL/region/layers_gal/coastal_indicators_norm.csv", row.names = FALSE)









# Filter AO_ACCESS AND AO_NEED
ao_access <- read.csv("/Users/batume/Documents/R/OHI_GAL/Downloaded/sdg_14_b_1_ao.csv", header=TRUE, sep=",")
ao_need <- read.csv("/Users/batume/Documents/R/OHI_GAL/Downloaded/wb_gdppcppp_rescaled.csv", header=TRUE, sep=",")

head(ao_need)

ao_access <- subset(ao_access,rgn_id  == "182")
ao_need <- subset(ao_need,rgn_id  == "182")

write.csv(ao_need, "/Users/batume/Documents/R/OHI_GAL/region/layers_gal/ao_need.csv", row.names = FALSE)


