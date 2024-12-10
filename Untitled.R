# Fix missing predict issues in the linear model section
mod_gdp <- lm(S_score ~ value, data = tr_sust %>% filter(!is.na(value)), na.action = na.exclude)
tr_sust <- tr_sust %>%
  mutate(S_score_pred = ifelse(is.na(S_score), predict(mod_gdp, newdata = tr_sust), NA_real_))

# Ensure proper numeric vs character type handling for `year`
tr_sust <- tr_sust %>%
  mutate(year = as.numeric(year))  




#

trend_filtered <- recent_years_filtered %>%
  group_by(rgn_id) %>%
  summarize(
    trend = if (sum(!is.na(x_tr)) > 1) {
      coef(lm(x_tr ~ as.numeric(year), na.action = na.exclude))[2]
    } else {
      NA_real_
    }
  )


#

plot_trend_before <- ggplot(tr_sust, aes(x = as.numeric(year), y = x_tr, group = rgn_id, color = as.factor(rgn_id))) +
  geom_line() +
  labs(title = "Trend Before Filtering",
       x = "Year", y = "x_tr") +
  theme_minimal()

plot_trend_after <- ggplot(tr_sust_filtered, aes(x = as.numeric(year), y = x_tr, group = rgn_id, color = as.factor(rgn_id))) +
  geom_line() +
  labs(title = "Trend After Filtering (Excluding 2020-2022)",
       x = "Year", y = "x_tr") +
  theme_minimal()







final_plot <- (plot_T_r_before + plot_T_r_after) 

