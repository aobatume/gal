

#UNTITLED 3

library(readr)
library(dplyr)
library(tidyr)
library(stringr)

accomodation_INDIC <- read.delim("/Users/batume/Documents/R/OHI_GAL/prep/TR/INDICADORES_NOITE_DESTINO.csv",sep=",", header=TRUE)
head(accomodation_INDIC)

accomodation_stays <- accomodation_stays %>%
  separate(col = YEAR.MONTH, into = c("Year", "Month"), sep = "/")

# Function to download a single CSV file from a URL
download_csv <- function(url, destfile) {
  download.file(url, destfile, method = "auto")
  cat("Downloaded:", destfile, "\n")
}

url <- "https://www.ige.gal/igebdt/igeapi/datos/6327"
destfile <- "/Users/batume/Documents/R/OHI_GAL/Downloaded/noites_destinos.csv"
download_csv(url, destfile)


# Read a CSV file with ISO-8859-1 encoding
read_csv_iso88591 <- function(file_path) {
  noites_destinos <- read_csv("/Users/batume/Documents/R/OHI_GAL/Downloaded/noites_destinos.csv", locale = locale(encoding = "ISO-8859-1"))
  return(data)
}


# Select all columns except for DatoT.
noites_destinos <- noites_destinos %>% select(-DatoT)


library(dplyr)

# Convert DatoN to numeric, removing any commas
noites_destinos <- noites_destinos %>%
  mutate(DatoN = as.numeric(gsub(",", "", DatoN)))

# Min-Max normalization function
min_max_normalize <- function(x) {
  (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}

# Apply Min-Max normalization to the 'DatoN' column
noites_destinos <- noites_destinos %>%
  mutate(DatoN_normalized = min_max_normalize(DatoN))

# View the result
head(noites_destinos)

write.csv(noites_destinos, "/Users/batume/Documents/R/OHI_GAL/region/layers_gal/noites_destinos.csv", row.names = FALSE)



#UNTITLED 4


# Function to download a single CSV file from a URL
download_csv <- function(url, destfile) {
  download.file(url, destfile, method = "auto")
  cat("Downloaded:", destfile, "\n")
}

url <- "https://www.ige.gal/igebdt/igeapi/datos/3477/"
destfile <- "/Users/batume/Documents/R/OHI_GAL/Downloaded/viaxeiros_noites_estadías.csv"
download_csv(url, destfile)


# Read a CSV file with ISO-8859-1 encoding
read_csv_iso88591 <- function(file_path) {
  viaxeiros_noites_estadías <- read_csv("/Users/batume/Documents/R/OHI_GAL/Downloaded/viaxeiros_noites_estadías.csv", locale = locale(encoding = "ISO-8859-1"))
  return(data)
}


viaxeiros_noites_estadías <- viaxeiros_noites_estadías %>%
  separate(col = Tempo, into = c("Year", "Month"), sep = "/")



# Select all columns except for DatoT.
viaxeiros_noites_estadías <- viaxeiros_noites_estadías %>% select(-DatoT)

# Rename the column
viaxeiros_noites_estadías <- viaxeiros_noites_estadías %>%
  rename(Viaxeiros_Noites_Estadia_media = `Viaxeiros/Noites/Estadía media`)

# Subset the dataframe where the renamed column equals "Noites"
viaxeiros_noites_estadías <- viaxeiros_noites_estadías %>%
  filter(Viaxeiros_Noites_Estadia_media == "Noites")

noites_todaspro <- subset(viaxeiros_noites_estadías, Procedencia == "Todas as procedencias")

library(dplyr)

# Group by Year and Zona Turistica and summarize DatoN
summarized_data <- noites_todaspro %>%
  group_by(Year, `Zonas turísticas`) %>%  # Replace `Tempo` with the correct column name if different
  summarize(total_DatoN = sum(DatoN, na.rm = TRUE))

# View the summarized data
print(summarized_data)


# Convert DatoN to numeric, removing any commas
viaxeiros_noites_estadías <- viaxeiros_noites_estadías %>%
  mutate(DatoN = as.numeric(gsub(",", "", DatoN)))

# Min-Max normalization function
min_max_normalize <- function(x) {
  (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}

# Apply Min-Max normalization to the 'DatoN' column
viaxeiros_noites_estadías <- viaxeiros_noites_estadías %>%
  mutate(DatoN_normalized = min_max_normalize(DatoN))

# View the result
head(viaxeiros_noites_estadías)

write.csv(viaxeiros_noites_estadías, "/Users/batume/Documents/R/OHI_GAL/region/layers_gal/viaxeiros_noites_estadías.csv", row.names = FALSE)

#UNTITLED 5


# Function to download a single CSV file from a URL
download_csv <- function(url, destfile) {
  download.file(url, destfile, method = "auto")
  cat("Downloaded:", destfile, "\n")
}

url <- "https://www.ige.gal/igebdt/igeapi/datos/3476"
destfile <- "/Users/batume/Documents/R/OHI_GAL/Downloaded/viaxeiros_noites_estadías_prov.csv"
download_csv(url, destfile)


# Read a CSV file with ISO-8859-1 encoding
viaxeiros_noites_estadías_prov <- read_csv("/Users/batume/Documents/R/OHI_GAL/Downloaded/viaxeiros_noites_estadías_prov.csv", locale = locale(encoding = "ISO-8859-1"))



viaxeiros_noites_estadías_prov <- viaxeiros_noites_estadías_prov %>%
  separate(col = Tempo, into = c("Year", "Month"), sep = "/")



# Select all columns except for DatoT.
viaxeiros_noites_estadías_prov <- viaxeiros_noites_estadías_prov %>% select(-DatoT)

# Rename the column
viaxeiros_noites_estadías_prov <- viaxeiros_noites_estadías_prov %>%
  rename(Viaxeiros_Noites_Estadia_media = `Viaxeiros/Noites/Estadía media`)

# Subset the dataframe where the renamed column equals "Noites"
viaxeiros_noites_estadías_prov <- viaxeiros_noites_estadías_prov %>%
  filter(Viaxeiros_Noites_Estadia_media == "Noites")

noites_todaspro <- subset(viaxeiros_noites_estadías_prov, Procedencia == "Todas as procedencias")

library(dplyr)

# Group by Year and Zona Turistica and summarize DatoN
summarized_data <- noites_todaspro %>%
  group_by(Year, `Espazo`) %>%  # Replace `Tempo` with the correct column name if different
  summarize(total_DatoN = sum(DatoN, na.rm = TRUE))

# View the summarized data
print(summarized_data)

# Filter out specific values from the Espazo column
summarized_data <- summarized_data %>%
  mutate(Espazo = str_trim(as.character(Espazo)))

filtered_data <- summarized_data %>%
  filter(!Espazo %in% c("32 ", "15 ", "27 ", "12 ", "36 ", "108"))

# Convert DatoN to numeric, removing any commas
viaxeiros_noites_estadías_prov <- viaxeiros_noites_estadías_prov %>%
  mutate(DatoN = as.numeric(gsub(",", "", DatoN)))

# Min-Max normalization function
min_max_normalize <- function(x) {
  (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}

# Apply Min-Max normalization to the 'DatoN' column
viaxeiros_noites_estadías_prov <- viaxeiros_noites_estadías_prov %>%
  mutate(DatoN_normalized = min_max_normalize(DatoN))

# View the result
head(viaxeiros_noites_estadías_prov)

write.csv(viaxeiros_noites_estadías_prov, "/Users/batume/Documents/R/OHI_GAL/region/layers_gal/viaxeiros_noites_estadías_prov.csv", row.names = FALSE)

