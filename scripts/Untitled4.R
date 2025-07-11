library(dplyr)
library(ggplot2)
library(patchwork)

# 1. Calculate T_r for both datasets (unfiltered and filtered)
tr_sust <- tr_sust %>%
  mutate(T_r = Ep * S_score)

tr_sust_filtered <- tr_sust %>%
  filter(!year %in% c("2020", "2021", "2022")) %>%
  mutate(T_r = Ep * S_score)

# 2. Calculate 90th percentiles **by region** for both datasets
T_90th_by_region <- tr_sust %>%
  group_by(rgn_id) %>%
  summarize(T_90th = quantile(T_r, 0.9, na.rm = TRUE))

T_90th_filtered_by_region <- tr_sust_filtered %>%
  group_by(rgn_id) %>%
  summarize(T_90th_filtered = quantile(T_r, 0.9, na.rm = TRUE))

# 3. Normalize and cap x_tr **by region** for both datasets
tr_sust <- tr_sust %>%
  left_join(T_90th_by_region, by = "rgn_id") %>%
  mutate(x_tr = T_r / T_90th) %>%
  mutate(x_tr = ifelse(x_tr > 1, 1, x_tr))  # Cap values at 1

tr_sust_filtered <- tr_sust_filtered %>%
  left_join(T_90th_filtered_by_region, by = "rgn_id") %>%
  mutate(x_tr = T_r / T_90th_filtered) %>%
  mutate(x_tr = ifelse(x_tr > 1, 1, x_tr))  # Cap values at 1

# 4. Calculate trends **by region** for both datasets
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

# . side-by-side plots
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

# 7. Display plots side-by-side
final_plot <- (plot_T_r_before + plot_T_r_after) / (plot_trend_before + plot_trend_after)
print(final_plot)

# 8. Print trends and percentiles for both datasets
print("Trend (Unfiltered):")
print(trend)

print("Trend (Filtered):")
print(trend_filtered)

print("90th Percentiles by Region (Unfiltered):")
print(T_90th_by_region)

print("90th Percentiles by Region (Filtered):")
print(T_90th_filtered_by_region)
