library(readr)
library(dplyr)
library(ggplot2)

## 1. LOAD DATA
tr_jobs_pct_tourism <- read_csv("/Users/batume/Documents/R/GAL_git/region/layers/tr_jobs_pct_tourism.csv")     
ttdi_galicia <- read_csv("~/Documents/R/GAL_git/prep/AO/ttdi_galicia.csv")

tr_jobs_pct_tourism_ss <- tr_jobs_pct_tourism %>%
  filter(rgn_id == "3")
ttdi_galicia_ss <- ttdi_galicia %>%
  filter(rgn_id == "3")

# 📌 USE PIB_GALICIA INSTEAD OF PIB_INE
pib_galicia <- tibble(
  rgn_id = 1,  # Initial region ID for Galicia
  year = c(2020, 2021, 2022, 2023, 2024),
  value = c(-8.9, 7.6, 4.1, 1.8, 2.2)
)

# Replicate for regions 1, 2, and 3
pib_galicia <- pib_galicia %>%
  slice(rep(1:n(), each = 3)) %>% 
  mutate(rgn_id = rep(c(1, 2, 3), times = nrow(.) / 3))

## 2. GAPFILLING - USE PIB_GALICIA

# Convert year to character
pib_galicia <- pib_galicia %>%
  mutate(year = as.character(year))

ttdi_galicia_ss <- ttdi_galicia_ss %>%
  mutate(year = as.character(year))

tr_jobs_pct_tourism_ss <- tr_jobs_pct_tourism_ss %>%
  mutate(year = as.character(year))

# Merge datasets
tr_sust_ss <- pib_galicia %>%
  left_join(ttdi_galicia_ss, by = c("rgn_id", "year")) %>%
  left_join(tr_jobs_pct_tourism_ss, by = c("rgn_id", "year")) %>%
  rename(S_score = score, Ep = Ep) %>%
  mutate(S_score = as.numeric(S_score))  

# 2.3 Gapfill flags
tr_sust_ss <- tr_sust_ss %>%
  mutate(
    gapfilled = ifelse(is.na(S_score) & !is.na(Ep), "gapfilled", NA),
    method = case_when(
      is.na(S_score) & !is.na(Ep) & is.na(value) ~ "lm georegion + estimated GDP",
      is.na(S_score) & !is.na(Ep) ~ "lm georegion + GDP",
      TRUE ~ NA_character_
    )
  )

# Check if there are enough valid S_score values for regression
valid_obs <- sum(!is.na(tr_sust_ss$S_score))
if (valid_obs >= 3) {
  mod_gdp <- lm(S_score ~ value, data = tr_sust_ss, na.action = na.exclude)
  print(summary(mod_gdp))
} else {
  print("⚠️ Not enough data for regression (need at least 3 non-NA values). Skipping regression.")
}

# Plot relationship if regression is successful
if (valid_obs >= 3) {
  plot(tr_sust_ss$value, tr_sust_ss$S_score, main = "S_score vs. value",
       xlab = "value", ylab = "S_score", pch = 19)
  abline(mod_gdp, col = "blue", lwd = 2)
}

# 2.5 Predict S_score for missing values
years_to_predict <- c("2020", "2022", "2023")

if (valid_obs >= 3) {
  tr_sust_ss_gapfilled <- tr_sust_ss %>%
    filter(year %in% years_to_predict & is.na(S_score)) %>%
    mutate(S_score_predicted = predict(mod_gdp, newdata = .))
  
  # Merge predictions back
  tr_sust_ss <- tr_sust_ss %>%
    left_join(tr_sust_ss_gapfilled %>% select(year, rgn_id, S_score_predicted), 
              by = c("year", "rgn_id")) %>%
    mutate(S_score = ifelse(is.na(S_score), S_score_predicted, S_score)) %>%
    select(-S_score_predicted) # Remove temporary column
}

# 3 STATUS CALCULATION AND TREND - BY REGION

# Extract years of interest
tr_sust_ss <- tr_sust_ss %>%
  filter(year %in% c("2020", "2021", "2022"))

# 3.1 Compute T_r (Regional tourism and recreation value)
tr_sust_ss <- tr_sust_ss %>%
  mutate(T_r = Ep * S_score)

# Filter out 2020-2022 for 90th percentile calculation
tr_sust_ss_filtered <- tr_sust_ss %>%
  filter(!year %in% c("2020", "2021", "2022"))

# 3.2 Compute 90th percentile of T_r **by region**
T_90th_by_region <- tr_sust_ss_filtered %>%
  group_by(rgn_id) %>%
  summarize(T_90th = quantile(T_r, 0.9, na.rm = TRUE))

# 3.3 Normalize and cap x_tr **by region**
tr_sust_ss <- tr_sust_ss %>%
  left_join(T_90th_by_region, by = "rgn_id") %>%
  mutate(x_tr = T_r / T_90th) %>%
  mutate(x_tr = ifelse(x_tr > 1, 1, x_tr))  # Cap values at 1

# 3.4 Calculate trends **by region**
recent_years <- tr_sust_ss %>%
  filter(as.numeric(year) >= (max(as.numeric(year)) - 4))

if (sum(!is.na(recent_years$x_tr)) > 0) {
  trend <- recent_years %>%
    group_by(rgn_id) %>%
    summarize(trend = coef(lm(x_tr ~ as.numeric(year), na.action = na.exclude))[2])
  print("Trend (Unfiltered):")
  print(trend)
} else {
  print("⚠️ No valid x_tr values in recent years, cannot calculate trend.")
}

# 3.5 Print 90th Percentile Values
print("90th Percentiles by Region:")
print(T_90th_by_region)
