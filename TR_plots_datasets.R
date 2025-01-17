library(ggplot2)
library(dplyr)

# Visualize the wb_gdppcppp_galicia dataset
ggplot(wb_gdppcppp_galicia, aes(x = as.numeric(year), y = value, group = rgn_id, color = as.factor(rgn_id))) +
  geom_line() +
  labs(
    title = "GDP per Capita (PPP) Over Time by Region",
    x = "Year",
    y = "GDP (PPP)",
    color = "Region ID"
  ) +
  theme_minimal()

# Visualize the ttdi_galicia dataset
ggplot(ttdi_galicia, aes(x = as.numeric(year), y = score, group = rgn_id, color = as.factor(rgn_id))) +
  geom_line() +
  labs(
    title = "TTDI Sustainability Scores Over Time by Region",
    x = "Year",
    y = "Sustainability Score",
    color = "Region ID"
  ) +
  theme_minimal()

# Visualize the tr_jobs_pct_tourism dataset
ggplot(tr_jobs_pct_tourism, aes(x = as.numeric(year), y = Ep, group = rgn_id, color = as.factor(rgn_id))) +
  geom_line() +
  labs(
    title = "Employment Proportion in Tourism Over Time by Region",
    x = "Year",
    y = "Employment Proportion (Ep)",
    color = "Region ID"
  ) +
  theme_minimal()

# After merging, visualize the tr_sust dataset
tr_sust <- wb_gdppcppp_galicia %>%
  left_join(ttdi_galicia, by = c("rgn_id", "year")) %>%
  left_join(tr_jobs_pct_tourism, by = c("rgn_id", "year")) %>%
  rename(S_score = score, Ep = Ep) %>%
  mutate(S_score = as.numeric(S_score))

# Plot S_score over time
ggplot(tr_sust, aes(x = as.numeric(year), y = S_score, group = rgn_id, color = as.factor(rgn_id))) +
  geom_line() +
  labs(
    title = "Sustainability Scores After Merging",
    x = "Year",
    y = "Sustainability Score (S_score)",
    color = "Region ID"
  ) +
  theme_minimal()

# Plot Ep (employment proportion) over time
ggplot(tr_sust, aes(x = as.numeric(year), y = Ep, group = rgn_id, color = as.factor(rgn_id))) +
  geom_line() +
  labs(
    title = "Employment Proportion After Merging",
    x = "Year",
    y = "Employment Proportion (Ep)",
    color = "Region ID"
  ) +
  theme_minimal()

# Plot GDP value over time
ggplot(tr_sust, aes(x = as.numeric(year), y = value, group = rgn_id, color = as.factor(rgn_id))) +
  geom_line() +
  labs(
    title = "GDP per Capita (PPP) After Merging",
    x = "Year",
    y = "GDP (PPP)",
    color = "Region ID"
  ) +
  theme_minimal()
