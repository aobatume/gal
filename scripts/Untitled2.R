library(tidyr)
library(dplyr)

# Step 1: Define the base employment value for 2010 (replace with actual value)
employment_2010 <- 1000  # Replace with the actual base employment value
growth_rate <- 0.022
years <- 10

# Calculate the reference point (employment_ref for 2020)
employment_ref <- employment_2010 * (1 + growth_rate)^years

# Step 2: Add employment_ref to the dataset
tr_sust <- tr_sust %>%
  mutate(employment_ref = ifelse(year == "2020", employment_ref, NA)) %>%
  fill(employment_ref, .direction = "downup")  # Fill reference point for all rows

# Step 3: Calculate x_tr (status)
tr_sust <- tr_sust %>%
  mutate(
    x_tr = employment_current / employment_ref,
    x_tr = ifelse(x_tr > 1, 1, x_tr)  # Cap x_tr at 1
  )

# Step 4: Inspect the results
head(tr_sust)
