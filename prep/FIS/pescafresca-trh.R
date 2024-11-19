
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


#
colnames(pescafresca_22) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_21) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_20) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_19) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_18) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_17) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_16) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_15) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_14) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_13) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_12) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_11) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_10) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_09) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_08) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_07) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_06) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_05) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_04) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")
colnames(pescafresca_03) <- c("sell_day", "group", "FAOcode", "Galician_name", "Province", "Admi_area", "market", "kg", "euros", "price_per_kilo")


columns_to_change <- c("kg", "euros", "price_per_kilo")

# Loop through each dataset 
for (year in years) {
  df <- pescafresca_data[[as.character(year)]]
  
  # replace ',' with '.'
  for (col in columns_to_change) {
    if (col %in% colnames(df)) {
      # Replace commas with periods in the column and convert to numeric
      df[[col]] <- as.numeric(gsub(",", ".", df[[col]]))
    }
  }
  
  # Save the modified data back to the list
  pescafresca_data[[as.character(year)]] <- df
}

