# Load necessary libraries
library(dplyr)
library(tidyr)

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

# 1.6 Merge the result with province_rgn_id to include rgn_id and handle missing values

result_with_ids <- result %>%
  left_join(province_rgn_id, by = "PROVINCIA") %>%
  select(rgn_id, year = ANO, Ep = PERCENT_TOURISM) 

all_years <- unique(result_with_ids$year)
all_rgn_ids <- unique(result_with_ids$rgn_id)

complete_data <- expand.grid(
  rgn_id = all_rgn_ids,
  year = all_years
)

tr_jobs_pct_tourism <- complete_data %>%
  left_join(result_with_ids, by = c("rgn_id", "year")) %>%
  mutate(Ep = ifelse(is.na(Ep), NA, Ep))

#Remove data from 2024 because the data is not complete: 
plot(tr_jobs_pct_tourism_filtered)
 tr_jobs_pct_tourism_filtered <- tr_jobs_pct_tourism %>%
  filter(year != 2024)

#write.csv(tr_jobs_pct_tourism_filtered, "/Users/batume/Documents/R/GAL_git/region/layers/tr_jobs_pct_tourism.csv", row.names = FALSE)
tr_jobs_pct_tourism<-tr_jobs_pct_tourism_filtered

#2 PREPARE SUSTENTABILITY INDEX LAYER - https://www.weforum.org/publications/travel-tourism-development-index-2024/

# Create the data
ttdi_spain <- data.frame(
  year = c(2013, 2015, 2017, 2018, 2019, 2021, 2024),
  country = c("Spain", "Spain", "Spain", "Spain", "Spain", "Spain", "Spain"),
  score = c(5.38, 5.31, 5.43, 5.4, 5.4, 5.2, 5.18)
)

# Save the data as a CSV file
write.csv(ttdi_spain, "spain_ttdi_scores.csv", row.names = FALSE)

#2.6: Order by year and round decimals
ttdi_spain <- ttdi_spain %>%
  mutate(score = round(score, 2)) %>% 
  arrange(year) 

#2.7: Remove `country` and expand for all `rgn_id` values
ttdi_galicia <- ttdi_spain %>%
  select(-country) %>%        
  crossing(rgn_id = 1:4) 

#2.8: Save the expanded dataset
write_csv(ttdi_galicia, "~/Documents/R/GAL_git/prep/AO/ttdi_galicia.csv")







# Remove data from 2024 because the data is not complete
tr_jobs_pct_tourism_filtered <- tr_jobs_pct_tourism %>%
  filter(year != 2024)

# Load ggplot2 for better plotting
library(ggplot2)

# Plot the percentage of tourism employment by province over the years

# Filter for years 2013–2024 (excluding 2024 if incomplete)
filtered_data <- tr_jobs_pct_tourism_filtered %>%
  filter(year >= 2013 & year <= 2023)  # Assuming 2024 is incomplete

# Calculate Galician average per year
galicia_avg <- filtered_data %>%
  group_by(year) %>%
  summarise(avg_Ep = mean(Ep, na.rm = TRUE))

# Barplot with average line
ggplot(filtered_data, aes(x = factor(year), y = Ep, fill = factor(rgn_id))) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.8)) +
  geom_line(data = galicia_avg, aes(x = factor(year), y = avg_Ep, group = 1), 
            inherit.aes = FALSE, color = "black", linewidth = 1.2) +
  geom_point(data = galicia_avg, aes(x = factor(year), y = avg_Ep), 
             inherit.aes = FALSE, color = "black", size = 2) +
  scale_fill_manual(
    values = c("1" = "#009ACD", "2" = "#CDC673", "3" = "#7570b3", "4" = "#CD6090"),
    labels = c("A Coruña", "Lugo", "Pontevedra", "Ourense"),
    name = "Province"
  ) +
  labs(
    title = "Tourism Employment (% of Total) by Province – Galicia (2013–2023)",
    x = "Year",
    y = "Tourism Employment (%)"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )
