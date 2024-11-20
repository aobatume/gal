# Load necessary libraries
library(dplyr)
setwd("prep/TR/")
tourism_data <- read.csv("Empregoturismo_AFILIACIONS_Mes.csv")


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

write.csv(tr_jobs_pct_tourism, "/Users/batume/Documents/R/OHI_GAL/region/layers/tr_jobs_pct_tourism.csv", row.names = FALSE)



