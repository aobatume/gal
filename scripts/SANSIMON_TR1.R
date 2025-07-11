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

pib_INE_ss <- tibble(
  year = c(2022, 2021, 2020, 2019, 2018, 2017, 2016, 2015),
  value = c(4.035, 5.900, -9.055, 1.393, 2.220, 2.914, 3.172, 5.116),
  rgn_id = c(3,3,3,3,3,3,3,3)
)

## 2. GAPFILLING - USE INE DATA, BETTER MODEL

# Convert year to character
pib_INE_ss <- pib_INE_ss %>%
  mutate(year = as.character(year))

ttdi_galicia_ss <- ttdi_galicia_ss %>%
  mutate(year = as.character(year))

tr_jobs_pct_tourism_ss <- tr_jobs_pct_tourism_ss %>%
  mutate(year = as.character(year))

# Merge datasets
tr_sust_ss <- pib_INE_ss %>%
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

# 2.4 Simple linear model using GDP (value) to predict S_score
mod_gdp <- lm(S_score ~ value, data = tr_sust_ss, na.action = na.exclude)
sum(is.na(tr_sust_ss$value))  

summary(mod_gdp)

# Plot relationship
plot(tr_sust_ss$value, tr_sust_ss$S_score, main = "S_score vs. value",
     xlab = "value", ylab = "S_score", pch = 19)
abline(mod_gdp, col = "blue", lwd = 2)

# 2.5 Predict S_score for missing values
years_to_predict <- c("2020", "2022", "2023")

tr_sust_ss_gapfilled <- tr_sust_ss %>%
  filter(year %in% years_to_predict & is.na(S_score)) %>%
  mutate(S_score_predicted = predict(mod_gdp, newdata = .))

# Merge predictions back
tr_sust_ss <- tr_sust_ss %>%
  left_join(tr_sust_ss_gapfilled %>% select(year, rgn_id, S_score_predicted), 
            by = c("year", "rgn_id")) %>%
  mutate(S_score = ifelse(is.na(S_score), S_score_predicted, S_score)) %>%
  select(-S_score_predicted) # Remove temporary column

# 3 STATUS CALCULATION AND TREND - BY REGION

# Extract years of interest
tr_sust_ss <- tr_sust_ss %>%
  filter(year %in% c("2018", "2019", "2020", "2021", "2022"))

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

trend <- recent_years %>%
  group_by(rgn_id) %>%
  summarize(trend = coef(lm(x_tr ~ as.numeric(year), na.action = na.exclude))[2])

# 3.5 Plot before & after filtering
plot_T_r_before <- ggplot(tr_sust_ss, aes(x = as.numeric(year), y = T_r, group = rgn_id, color = as.factor(rgn_id))) +
  geom_line() +
  geom_hline(data = T_90th_by_region, aes(yintercept = T_90th, color = as.factor(rgn_id)), linetype = "dashed") +
  labs(title = "T_r Before Filtering",
       x = "Year", y = "T_r") +
  theme_minimal()

plot_T_r_after <- ggplot(tr_sust_ss_filtered, aes(x = as.numeric(year), y = T_r, group = rgn_id, color = as.factor(rgn_id))) +
  geom_line() +
  geom_hline(data = T_90th_by_region, aes(yintercept = T_90th, color = as.factor(rgn_id)), linetype = "dashed") +
  labs(title = "T_r After Filtering (Excluding 2020-2022)",
       x = "Year", y = "T_r") +
  theme_minimal()

# Print plots
print(plot_T_r_before)
print(plot_T_r_after)

# 3.6 Print results
print("Trend (Unfiltered):")
print(trend)

print("90th Percentiles by Region:")
print(T_90th_by_region)
