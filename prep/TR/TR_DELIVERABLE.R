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

pib_INE<- tibble(
  year = c(2022, 2021, 2020, 2019, 2018, 2017, 2016, 2015),
  value = c(4.035, 5.900, -9.055, 1.393, 2.220, 2.914, 3.172, 5.116)
)
pib_INE<- pib_INE %>%
  slice(rep(1:n(), each = 3)) %>% 
  mutate(rgn_id = rep(c(1, 2, 3), times = nrow(.) / 3))



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
# Check the column names after the join
# Normalize S_score based on a specific logic, e.g., rescaling it to [0, 1]
tr_sust <- tr_sust %>%
  mutate(S_score_norm = scales::rescale(S_score, to = c(0, 1)))


# Step 1: Compute T_r = Ep * S_score
tr_sust <- tr_sust %>%
  mutate(T_r = Ep * S_score)

# Step 2: Compute 90th percentile of T_r per region (including all years)
T_90th_by_region <- tr_sust %>%
  group_by(rgn_id) %>%
  summarize(T_90th = quantile(T_r, 0.9, na.rm = TRUE))

# Step 3: Normalize T_r to get x_tr and cap at 1
tr_sust <- tr_sust %>%
  left_join(T_90th_by_region, by = "rgn_id") %>%
  mutate(x_tr = pmin(T_r / T_90th, 1))

# Step 4: Calculate trend over 2018–2022
recent_years <- tr_sust %>%
  filter(as.numeric(year) %in% 2018:2022)

trend <- recent_years %>%
  group_by(rgn_id) %>%
  summarize(trend = coef(lm(x_tr ~ as.numeric(year), na.action = na.exclude))[2])


##### PLOT EMPLOYMENT

# Convert year to character (if not already)
tr_jobs_pct_tourism <- tr_jobs_pct_tourism %>%
  mutate(year = as.character(year))

# Compute national average Ep by year
ep_year_summary <- tr_jobs_pct_tourism %>%
  group_by(year) %>%
  summarize(Ep_avg = mean(Ep, na.rm = TRUE)) %>%
  arrange(year)

print(ep_year_summary)



#GALICIA OVERALL SCORE

# Step 1: Aggregate the data for Galicia (regions 1, 2, and 3)
# Step 1: Aggregate T_r across all years for Galicia (regions 1, 2, and 3)
tr_sust_galicia <- tr_sust %>%
  filter(rgn_id %in% c(1, 2, 3)) %>%
  group_by(year) %>%
  summarize(
    T_r = sum(T_r, na.rm = TRUE),  # Sum of T_r across all regions for each year
    S_score = mean(S_score, na.rm = TRUE),  # Mean of S_score
    Ep = mean(Ep, na.rm = TRUE)  # Mean of Ep
  )

# Step 2: Compute the 90th percentile of T_r for the entire Galicia (all years)
T_90th_galicia <- quantile(tr_sust_galicia$T_r, 0.9, na.rm = TRUE)

# Step 3: Normalize T_r to get x_tr for Galicia (across all years) and cap at 1
tr_sust_galicia <- tr_sust_galicia %>%
  mutate(x_tr = pmin(T_r / T_90th_galicia, 1))

# Step 4: Calculate the overall trend for Galicia (slope of regression line for x_tr)
mod_galicia_trend <- lm(x_tr ~ year, data = tr_sust_galicia)
trend_galicia <- coef(mod_galicia_trend)[2]  # Slope (trend)

# Step 5: Aggregate the status value (mean of x_tr over all years)
status_galicia <- mean(tr_sust_galicia$x_tr, na.rm = TRUE)

# Display results
status_galicia
trend_galicia
