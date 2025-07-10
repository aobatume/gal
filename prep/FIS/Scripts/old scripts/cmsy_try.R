# Load necessary library
R.version
install.packages("CMSY")
library("CMSY") 

resilience_levels <- c("Very Low", "Low", "Medium", "High") 

cmsy_results <- list()

unique_species <- unique(all_years_data$FAOcode)
for (species in unique_species) {
  species_data <- all_years_data %>%
    filter(FAOcode == species) %>%
    group_by(year = as.integer(format(as.Date(sell_day, format="%d/%m/%Y"), "%Y"))) %>%
    summarize(total_catch = sum(kg, na.rm = TRUE))
  
  
  resilience <- "Medium"  
  
  # Run CMSY++ calculation (replace `cmsy_function` with the actual function name)
  # Example: cmsy_results[[species]] <- cmsy_function(species_data$total_catch, species_data$year, resilience = resilience)
  
  # Store result (this will vary based on CMSY++ function output)
  # cmsy_results[[species]] <- cmsy_function_output
}

