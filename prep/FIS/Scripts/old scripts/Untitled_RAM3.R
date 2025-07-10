# List objects in the package to see what data is available
library(ramlegacy)
ls("package:ramlegacy")

# Check the structure of the object containing the data
str(download_ramlegacy)

# Assuming the object you found is called ram_data
missing_TBbest <- ram_data[is.na(ram_data$TBbest), ]

# View the missing data
head(missing_TBbest)

names(ram_data)
str(ram_data)

str(ram_data$stock)  # Check if the 'stock' component has the TBbest column
str(ram_data$biometrics)  # Check if the 'biometrics' component has the TBbest column

missing_TBbest <- ram_data$stock[is.na(ram_data$stock$TBbest), ]
head(missing_TBbest)

str(ram_data$taxonomy)

# Search for 'TBbest' column in all components
found_TBbest <- lapply(ram_data, function(x) which(names(x) == "TBbest"))
found_TBbest


str(ram_data$timeseries_assessments_views)
str(ram_data$timeseries_ids_views)
str(ram_data$timeseries_sources_views)
str(ram_data$timeseries_values_views)


missing_TBbest <- ram_data$timeseries_values_views[is.na(ram_data$timeseries_values_views$TBbest), ]
head(missing_TBbest)


sum(is.na(ram_data$timeseries_values_views$TBbest))

missing_TBbest <- ram_data$timeseries_values_views[is.na(ram_data$timeseries_values_views$TBbest), ]
head(missing_TBbest)

table(missing_TBbest$stocklong)

