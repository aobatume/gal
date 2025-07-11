# Load necessary library
library(data.table)

# Define the file path
file_path <- "/Users/batume/Downloads/0027248-241126133413365/occurrence.txt"
"~/Downloads/"
# Read the data
occurrence_data <- fread(file_path, sep = "\t", header = TRUE)

# Preview the data
print(head(occurrence_data))
