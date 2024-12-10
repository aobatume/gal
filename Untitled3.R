library(dplyr)
library(ggplot2)
library(patchwork)
library(tibble)
library(readr)

#1.1Load wb_gdppcpp file to gapfill

tr_jobs_pct_tourism<-read_csv( "/Users/batume/Documents/R/GAL_git/region/layers/tr_jobs_pct_tourism.csv")     

ttdi_galicia <- read_csv("~/Documents/R/GAL_git/prep/AO/ttdi_galicia.csv")

wb_gdppcppp_rescaled <- read_csv("~/Documents/R/GAL_git/prep/AO/wb_gdppcppp_rescaled.csv")

# Calculate T_r for both datasets (unfiltered and filtered)
tr_sust <- tr_sust %>%
  mutate(T_r = Ep * S_score)

tr_sust_filtered <- tr_sust %>%
  filter(!year %in% c("2020", "2021", "2022")) %>%
  mutate(T_r = Ep * S_score)

# Calculate 90th percentile for both datasets
T_90th <- quantile(tr_sust$T_r, 0.9, na.rm = TRUE)
T_90th_filtered <- quantile(tr_sust_filtered$T_r, 0.9, na.rm = TRUE)

# Normalize and cap x_tr for both datasets
tr_sust <- tr_sust %>%
  mutate(x_tr = T_r / T_90th) %>%
  mutate(x_tr = ifelse(x_tr > 1, 1, x_tr))  

tr_sust_filtered <- tr_sust_filtered %>%
  mutate(x_tr = T_r / T_90th_filtered) %>%
  mutate(x_tr = ifelse(x_tr > 1, 1, x_tr))  

# Calculate trends for both datasets
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

# Compare T_r percentiles
T_90th_label <- paste("90th Percentile (Unfiltered):", round(T_90th, 2))
T_90th_filtered_label <- paste("90th Percentile (Filtered):", round(T_90th_filtered, 2))

plot_T_r_before <- ggplot(tr_sust, aes(x = as.numeric(year), y = T_r, group = rgn_id, color = as.factor(rgn_id))) +
  geom_line() +
  geom_hline(yintercept = T_90th, linetype = "dashed", color = "black") +
  annotate("text", x = max(as.numeric(tr_sust$year)), y = T_90th + 1, label = T_90th_label, hjust = 1) +
  labs(title = "T_r Before Filtering",
       x = "Year", y = "T_r") +
  theme_minimal()

plot_T_r_after <- ggplot(tr_sust_filtered, aes(x = as.numeric(year), y = T_r, group = rgn_id, color = as.factor(rgn_id))) +
  geom_line() +
  geom_hline(yintercept = T_90th_filtered, linetype = "dashed", color = "black") +
  annotate("text", x = max(as.numeric(tr_sust_filtered$year)), y = T_90th_filtered + 1, label = T_90th_filtered_label, hjust = 1) +
  labs(title = "T_r After Filtering (Excluding 2020-2022)",
       x = "Year", y = "T_r") +
  theme_minimal()

final_plot <- (plot_T_r_before + plot_T_r_after) 
