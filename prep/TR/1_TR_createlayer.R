# Load necessary libraries
library(dplyr)
setwd("prep/TR/")
tourism_data <- read.csv("Empregoturismo_AFILIACIONS_Mes.csv")

#1 PREPARE EMPLOYMENT DATA LAYER

#1.1: Define tourism-related categories
tourism_categories <- c(
  "Actividades de axencias de viaxes, operadores turísticos, servizos de reservas e actividades relacionadas con estes",
  "Servizos de aloxamento",
  "Servizos de comidas e bebidas"
)

# 1.2: Calculate the total affiliations per year and province
total_affiliations_per_year_province <- tourism_data %>%
  group_by(ANO, PROVINCIA) %>%
  summarise(TOTAL_AFILIACIONS = sum(as.numeric(AFILIACIONS), na.rm = TRUE), .groups = "drop")

# 1.3: Aggregate the specified categories per year and province
tourism_affiliations_per_year_province <- tourism_data %>%
  filter(RAMA %in% tourism_categories) %>%
  group_by(ANO, PROVINCIA) %>%
  summarise(TOURISM_AFILIACIONS = sum(as.numeric(AFILIACIONS), na.rm = TRUE), .groups = "drop")

      #Confirm Covid gap in employment
      plot(tourism_affiliations_per_year_province$ANO,tourism_affiliations_per_year_province$TOURISM_AFILIACIONS)

# 1.4: Merge the total affiliations and tourism affiliations datasets
result <- tourism_affiliations_per_year_province %>%
  left_join(total_affiliations_per_year_province, by = c("ANO", "PROVINCIA")) %>%
  mutate(PERCENT_TOURISM = (TOURISM_AFILIACIONS / TOTAL_AFILIACIONS) * 100)

# 1.5: Change column names to meet rgid

province_rgn_id <- data.frame(
  PROVINCIA = c("A Coruña", "Lugo", "Pontevedra", "Ourense"),
  rgn_id = c(1, 2, 3, 4)
)

# 1.6 Merge the result with province_rgn_id to include rgn_id
result_with_ids <- result %>%
  left_join(province_rgn_id, by = "PROVINCIA") %>%
  select(rgn_id, year = ANO, Ep = PERCENT_TOURISM) # Rename columns as required

tr_jobs_pct_tourism <- complete_data %>%
  left_join(result_with_ids, by = c("rgn_id", "year")) %>%
  mutate(Ep = ifelse(is.na(Ep), NA, Ep))

#Remove data from 2023 because the data is not complete: 

tr_jobs_pct_tourism_filtered <- tr_jobs_pct_tourism %>%
  filter(year != 2024)
write.csv(tr_jobs_pct_tourism_filtered, "/Users/batume/Documents/R/GAL_git/region/layers/tr_jobs_pct_tourism.csv", row.names = FALSE)

#2 PREPARE SUSTENTABILITY INDEX LAYER - https://www.weforum.org/publications/travel-tourism-development-index-2024/
# 2.1: Read the raw data
ttdi_file <- "WEF_TTDI_2021_data_for_download.xlsx"
ttdi_raw <- read_excel(ttdi_file, skip = 2)

# 2.2: Move up column names from the first row while keeping the full country names as columns too
names(ttdi_raw)[1:9] <- as.character(ttdi_raw[1, 1:9])

# 2.3 Filter for sustainability scores, select needed columns, and pivot to tidy format
ttdi <- ttdi_raw %>%
  filter(Title == "T&T Sustainability subindex, 1-7 (best)",
         Attribute == "Score") %>%
  select(year = Edition, Albania:Zambia) %>%
  pivot_longer(cols = Albania:Zambia, names_to = "country", values_to = "score") %>%
  mutate(score = as.numeric(score))

# 2.4: Filter only for Spain
ttdi_spain <- ttdi %>%
  filter(country == "Spain") %>%
  select(year, country, score)

#2.5: Add the 2024 value:

spain_2024 <- data.frame(
  year = 2024,
  country = "Spain",
  score = 5.18
)

ttdi_spain <- rbind(ttdi_spain, spain_2024)

write.csv(ttdi_spain, "wef_ttdi_spain.csv", row.names = FALSE)
