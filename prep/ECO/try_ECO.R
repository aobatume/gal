# Load libraries
library(tidyverse)
library(dplyr)
library(tidyr)
library(ggplot2)

# Read the data files
peso <- read.csv("/Users/batume/Documents/R/GAL_git/prep/ECO/PESO_NO_PIB.csv", header=FALSE,stringsAsFactors = FALSE)
vab <- read.csv("/Users/batume/Documents/R/GAL_git/prep/ECO/VALOR_ENGADIDO_BRUTO.csv", stringsAsFactors = FALSE)


# Inspect structure (optional)
str(peso)
str(vab)


# Sample format: sector-year revenue data
revenue_data <- data.frame(
  Sector = rep(c("Fishing", "Tourism", "Shipping"), each = 5),
  Year = rep(2018:2022, times = 3),
  Revenue = c(120, 130, 125, 140, 150,  # Fishing
              300, 320, 310, 350, 360,  # Tourism
              90, 100, 95, 110, 115)    # Shipping
)

# ---- STATUS ----

# Step 1: Select current and reference years
current_year <- max(revenue_data$Year)
preferred_gaps <- c(5, 6, 4, 7, 3, 8, 2, 9, 1, 10)
available_years <- sort(unique(revenue_data$Year))
reference_year <- NA

for (gap in preferred_gaps) {
  ref_candidate <- current_year - gap
  if (ref_candidate %in% available_years) {
    reference_year <- ref_candidate
    break
  }
}

if (is.na(reference_year)) stop("No valid reference year found.")

# Step 2: Sum revenues across all sectors
current_revenue <- revenue_data %>%
  filter(Year == current_year) %>%
  summarise(Total = sum(Revenue)) %>%
  pull(Total)

reference_revenue <- revenue_data %>%
  filter(Year == reference_year) %>%
  summarise(Total = sum(Revenue)) %>%
  pull(Total)

status <- current_revenue / reference_revenue

# ---- TREND ----

# Step 3: Linear model per sector for last 5 years
trend_data <- revenue_data %>%
  group_by(Sector) %>%
  filter(Year >= (current_year - 4)) %>%
  do({
    model <- lm(Revenue ~ Year, data = .)
    data.frame(Slope = coef(model)["Year"],
               LatestRevenue = tail(.$Revenue, 1))
  }) %>%
  ungroup()

# Step 4: Weighted average of slopes
trend <- sum(trend_data$Slope * trend_data$LatestRevenue) / sum(trend_data$LatestRevenue)
trend <- max(min(trend, 1), -1)  # Bound between -1 and 1

# ---- RESULTS ----
cat("Economies Subgoal for Galicia\n")
cat(sprintf("Status (relative to %d): %.2f\n", reference_year, status))
cat(sprintf("Trend (avg annual change): %.4f\n", trend))