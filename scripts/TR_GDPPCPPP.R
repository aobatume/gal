# 1 TOURISM AND RECREATION
library(tibble)
library(readr)
library(dplyr)
library(ggplot2)
#1.1Load wb_gdppcpp file to gapfill

tr_jobs_pct_tourism<-read_csv( "/Users/batume/Documents/R/GAL_git/region/layers/tr_jobs_pct_tourism.csv")     

ttdi_galicia <- read_csv("~/Documents/R/GAL_git/prep/AO/ttdi_galicia.csv")

wb_gdppcppp_rescaled <- read_csv("~/Documents/R/GAL_git/prep/AO/wb_gdppcppp_rescaled.csv")


#1.2 Filter GDP data for region ID 182
wb_gdppcppp_spain <- wb_gdppcppp_rescaled %>%
  filter(rgn_id == 182)

#1.3 Duplicate the data for regions 1, 2, and 3
wb_gdppcppp_galicia <- wb_gdppcppp_spain %>%
  filter(rgn_id == 182) %>%              
  slice(rep(1:n(), each = 3)) %>%        
  mutate(rgn_id = rep(c(1, 2, 3), times = nrow(.) / 3))            


######## 2 Gapfilling 

# 2.1 `year` to character 

wb_gdppcppp_galicia <- wb_gdppcppp_galicia %>% mutate(year = as.character(year))
ttdi_galicia <- ttdi_galicia %>% mutate(year = as.character(year))
tr_jobs_pct_tourism <- tr_jobs_pct_tourism %>% mutate(year = as.character(year))

# 2.2 Merge 

tr_sust <- wb_gdppcppp_galicia %>%
  full_join(ttdi_galicia, by = c("rgn_id", "year")) %>%
  full_join(tr_jobs_pct_tourism, by = c("rgn_id", "year"))


#2.3 gapfill flags
tr_sust <- tr_sust %>%
  mutate(
    gapfilled = ifelse(is.na(score) & !is.na(Ep), "gapfilled", NA),
    method = case_when(
      is.na(score) & !is.na(Ep) & is.na(value) ~ "lm georegion + estimated GDP",
      is.na(score) & !is.na(Ep) ~ "lm georegion + GDP",
      TRUE ~ NA_character_
    )
  )


#2.4 Simple linear model using GDP (value) to predict S_score
mod_gdp <- lm(score ~ value, data = tr_sust, na.action = na.exclude)
sum(is.na(tr_sust$value))  

summary(mod_gdp)


# Filter the rows for the years of interest (2020, 2022, 2023)
years_to_predict <- c("2020", "2022")
tr_sust_gapfilled <- tr_sust %>%
  filter(year %in% years_to_predict & is.na(score)) %>%
  mutate(S_score_predicted = predict(mod_gdp, newdata = .))

# Merge predictions back to the original dataset
tr_sust <- tr_sust %>%
  left_join(tr_sust_gapfilled %>% select(year, rgn_id, S_score_predicted), 
            by = c("year", "rgn_id"))

# Fill missing S_score with predictions
tr_sust <- tr_sust %>%
  mutate(S_score = ifelse(is.na(score), S_score_predicted, score))

# Subset 
tr_sust_subset <- tr_sust %>%
  select(S_score, Ep, rgn_id, value, year)

tr_sust_filtered <- tr_sust_subset %>%
  filter(year %in% c(2018, 2019, 2020, 2021, 2022))

tr_sust_filtered <- tr_sust_filtered %>%
  filter(rgn_id != 4)


###CALCUALTE STATUS 

# Step 1: Calculate T_r
tr_sust <- tr_sust %>%
  mutate(T_r = Ep * S_score)

# Step 2: Calculate T_90th (90th percentile of T_r by year or globally)
T_90th <- tr_sust %>%
  summarize(T_90th = quantile(T_r, 0.9, na.rm = TRUE)) %>%
  pull(T_90th)

# Step 3: Calculate x_tr
tr_sust <- tr_sust %>%
  mutate(
    x_tr = T_r / T_90th,       # Calculate x_tr
    x_tr = ifelse(x_tr > 1, 1, x_tr)  # Cap x_tr at 1
  )

print(tr_sust)

T_90th_by_rgn_id <- tr_sust %>%
  group_by(rgn_id) %>%
  summarize(T_90th = quantile(T_r, 0.9, na.rm = TRUE))

#CALCULATE TREND

# Step 4: Filter for the most recent 5 years
recent_years <- tr_sust %>%
  filter(as.numeric(year) >= (max(as.numeric(year)) - 4))

# Step 5: Calculate Trend for each region
trend <- recent_years %>%
  group_by(rgn_id) %>%
  summarize(
    slope = coef(lm(x_tr ~ as.numeric(year), na.action = na.exclude))[2],  # Slope of x_tr over time
    x_start = first(x_tr, order_by = as.numeric(year)),  # x_tr value of the earliest year
    trend = (slope * 5) / x_start  # Proportional change over 5 years
  ) %>%
  mutate(
    trend = pmax(pmin(trend, 1.0), -1.0)  # Clamp trend to [-1.0, 1.0]
  )


# View the calculated trends
print(trend)
