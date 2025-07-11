# 1 TOURISM AND RECREATION
library(tibble)
library(readr)
library(dplyr)
library(ggplot2)
#1.1Load wb_gdppcpp file to gapfill

tr_jobs_pct_tourism<-read_csv( "/Users/batume/Documents/R/GAL_git/region/layers/tr_jobs_pct_tourism.csv")     

ttdi_galicia <- read_csv("~/Documents/R/GAL_git/prep/AO/ttdi_galicia.csv")

wb_gdppcppp_rescaled <- read_csv("~/Documents/R/GAL_git/prep/AO/wb_gdppcppp_rescaled.csv")


# OPTION A- USE gdppcppp DATA 

#1.2 Filter GDP data for region ID 182
wb_gdppcppp_spain <- wb_gdppcppp_rescaled %>%
  filter(rgn_id == 182)

#1.3 Duplicate the data for regions 1, 2, and 3
wb_gdppcppp_galicia <- wb_gdppcppp_spain %>%
  filter(rgn_id == 182) %>%              
  slice(rep(1:n(), each = 3)) %>%        
  mutate(rgn_id = rep(c(1, 2, 3), times = nrow(.) / 3))            

# Save the updated data to a CSV file
#write_csv(PIB_GDP, "~/Documents/R/GAL_git/prep/AO/PIB_GDP.csv")

#OPTION B - USE IGE DATA (https://www.ige.gal/dba/esq.jsp?idioma=es&paxina=002008&ruta=indicadores.jsp)

#pib_galicia <- tibble(
#  rgn_id = 1,  # Initial region ID for Galicia
#  year = c(2020, 2021, 2022, 2023, 2024),
#  value = c(-8.9, 7.6, 4.1, 1.8, 2.2)
#)

# Duplicate the data for regions 1, 2, and 3
#pib_galicia<- pib_galicia %>%
#  slice(rep(1:n(), each = 3)) %>% 
#  mutate(rgn_id = rep(c(1, 2, 3), times = nrow(.) / 3))
#getwd()
#print(pib_galicia)
#write.csv(pib_galicia, "/Users/batume/Documents/R/GAL_git/prep/TR/pib_galicia.csv", row.names = FALSE)

#pib_galicia<-read_csv( "/Users/batume/Documents/R/GAL_git/prep/TR/pib_galicia.csv")     

# SETECTED!!! OPTION C USE INE DATA (https://www.ine.es/jaxiT3/Datos.htm?t=45599)

pib_INE<- tibble(
  year = c(2022, 2021, 2020, 2019, 2018, 2017, 2016, 2015),
  value = c(4.035, 5.900, -9.055, 1.393, 2.220, 2.914, 3.172, 5.116)
)
pib_INE<- pib_INE %>%
  slice(rep(1:n(), each = 3)) %>% 
  mutate(rgn_id = rep(c(1, 2, 3), times = nrow(.) / 3))

write.csv(pib_INE, "/Users/batume/Documents/R/GAL_git/prep/TR/pib_INE.csv", row.names = FALSE)

pib_INE<-read_csv( "/Users/batume/Documents/R/GAL_git/prep/TR/pib_INE.csv")     


######## 2 Gapfilling - USE INE DATA, BETTER MODEL

# 2.1 `year` to character 
  pib_INE <- pib_INE %>%
    mutate(year = as.character(year))
  
  
  ttdi_galicia <- ttdi_galicia %>%
    mutate(year = as.character(year))
  
  tr_jobs_pct_tourism <- tr_jobs_pct_tourism %>%
    mutate(year = as.character(year))

# 2.2 Merge 
tr_sust <- pib_INE %>%
  left_join(ttdi_galicia, by = c("rgn_id", "year")) %>%
  left_join(tr_jobs_pct_tourism, by = c("rgn_id", "year")) %>%
  rename(S_score = score, Ep = Ep) %>%
  mutate(S_score = as.numeric(S_score))  


head(tr_sust)


#2.3 gapfill flags
tr_sust <- tr_sust %>%
  mutate(
    gapfilled = ifelse(is.na(S_score) & !is.na(Ep), "gapfilled", NA),
    method = case_when(
      is.na(S_score) & !is.na(Ep) & is.na(value) ~ "lm georegion + estimated GDP",
      is.na(S_score) & !is.na(Ep) ~ "lm georegion + GDP",
      TRUE ~ NA_character_
    )
  )


#2.4 Simple linear model using GDP (value) to predict S_score
mod_gdp <- lm(S_score ~ value, data = tr_sust, na.action = na.exclude)
sum(is.na(tr_sust$value))  

summary(mod_gdp)


plot(tr_sust$value, tr_sust$S_score, main = "S_score vs. value",
     xlab = "value", ylab = "S_score", pch = 19)
abline(mod_gdp, col = "blue", lwd = 2)


#NEW BITS 

# Filter the rows for the years of interest (2020, 2022, 2023)
years_to_predict <- c("2020", "2022", "2023")
tr_sust_gapfilled <- tr_sust %>%
  filter(year %in% years_to_predict & is.na(S_score)) %>%
  mutate(S_score_predicted = predict(mod_gdp, newdata = .))

# Merge predictions back to the original dataset
tr_sust <- tr_sust %>%
  left_join(tr_sust_gapfilled %>% select(year, rgn_id, S_score_predicted), 
            by = c("year", "rgn_id"))

# Fill missing S_score with predictions
tr_sust <- tr_sust %>%
  mutate(S_score = ifelse(is.na(S_score), S_score_predicted, S_score))






# Step 2.5: Predict S_score for rows with missing values (NOT WORKING)
is.na(tr_sust$S_score)
predict(mod_gdp, newdata = tr_sust)

tr_sust <- tr_sust %>%
  mutate(S_score_pred = ifelse(is.na(S_score), predict(mod_gdp, newdata = tr_sust), NA))

# Step 2.6: Gapfill flag
tr_sust <- tr_sust %>%
  mutate(
    gapfilled = ifelse(is.na(S_score) & !is.na(S_score_pred), "gapfilled", NA),
    S_score = ifelse(is.na(S_score), S_score_pred, S_score)
  )

# Drop the temporary S_score_pred 
tr_sust <- tr_sust %>%
  select(-S_score_pred)

(tr_sust)


#pib_galicia <- pib_galicia %>%
#mutate(value = scales::rescale(value, to = c(0, 1)))


tr_sust_backup<-tr_sust

# 3 STATUS CALCULATION AND TREND - by region

# Extract the years 2018 to 2022 from tr_sust
tr_sust <- tr_sust %>%
  filter(year %in% c("2018", "2019", "2020", "2021", "2022"))

# 3.1. Calculate T_r for both datasets (unfiltered and filtered)
tr_sust <- tr_sust %>%
  mutate(T_r = Ep * S_score)

tr_sust_filtered <- tr_sust %>%
  filter(!year %in% c("2020", "2021", "2022")) %>%
  mutate(T_r = Ep * S_score)

T_90th_by_region <- tr_sust %>%
  group_by(rgn_id) %>%
  summarize(T_90th = quantile(T_r, 0.9, na.rm = TRUE))

T_90th_filtered_by_region <- tr_sust_filtered %>%
  group_by(rgn_id) %>%
  summarize(T_90th = quantile(T_r, 0.9, na.rm = TRUE))

# 3.3 Normalize and cap x_tr **by region** for both datasets

tr_sust <- tr_sust %>%
  left_join(T_90th_by_region, by = "rgn_id") %>%
  mutate(x_tr = T_r / T_90th_filtered) %>%
  mutate(x_tr = ifelse(x_tr > 1, 1, x_tr))  # Cap values at 1

tr_sust_filtered <- tr_sust_filtered %>%
  left_join(T_90th_filtered_by_region, by = "rgn_id") %>%
  mutate(x_tr = T_r / T_90th_filtered) %>%
  mutate(x_tr = ifelse(x_tr > 1, 1, x_tr))  # Cap values at 1


# First for the unfiltered data
tr_sust <- tr_sust %>%
  left_join(T_90th_by_region, by = "rgn_id") %>%
  mutate(x_tr = T_r / T_90th) %>%   # Use T_90th, not filtered
  mutate(x_tr = pmin(x_tr, 1))      # Ensure cap at 1

# Then for filtered data
tr_sust_filtered <- tr_sust_filtered %>%
  left_join(T_90th_filtered_by_region, by = "rgn_id") %>%
  mutate(x_tr = T_r / T_90th) %>%
  mutate(x_tr = pmin(x_tr, 1))

# 3.4 Calculate trends **by region** for both datasets
recent_years <- tr_sust %>%
  filter(year >= (max(as.numeric(year)) - 4))
trend <- recent_years %>%
  group_by(rgn_id) %>%
  summarize(trend = coef(lm(x_tr ~ as.numeric(year), na.action = na.exclude))[2])

recent_years_filtered <- tr_sust_filtered %>%
  filter(year >= (max(as.numeric(year)) - 4))
trend_filtered <- recent_years_filtered %>%
  group_by(rgn_id) %>%
  summarize(trend = coef(lm(x_tr ~ as.numeric(year), na.action = na.exclude))[2])

# 3.5 side-by-side plots
plot_T_r_before <- ggplot(tr_sust, aes(x = as.numeric(year), y = T_r, group = rgn_id, color = as.factor(rgn_id))) +
  geom_line() +
  geom_hline(data = T_90th_by_region, aes(yintercept = T_90th, color = as.factor(rgn_id)), linetype = "dashed") +
  labs(title = "T_r Before Filtering",
       x = "Year", y = "T_r") +
  theme_minimal()

plot_T_r_after <- ggplot(tr_sust_filtered, aes(x = as.numeric(year), y = T_r, group = rgn_id, color = as.factor(rgn_id))) +
  geom_line() +
  geom_hline(data = T_90th_filtered_by_region, aes(yintercept = T_90th_filtered, color = as.factor(rgn_id)), linetype = "dashed") +
  labs(title = "T_r After Filtering (Excluding 2020-2022)",
       x = "Year", y = "T_r") +
  theme_minimal()

final_plot <- (plot_T_r_before + plot_T_r_after) / (plot_trend_before + plot_trend_after)
print(final_plot)

# 3.6 Print trends and percentiles for both datasets
print("Trend (Unfiltered):")
print(trend)
print("90th Percentiles by Region (Unfiltered):")
print(T_90th_by_region)

print("Trend (Filtered):")
print(trend_filtered)


print("90th Percentiles by Region (Filtered):")
print(T_90th_filtered_by_region)



# Check if all regions in tr_sust_filtered have a match in T_90th_filtered_by_region
setdiff(unique(tr_sust_filtered$rgn_id), unique(T_90th_filtered_by_region$rgn_id))
