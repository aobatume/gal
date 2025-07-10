# Input data for this script comes from Ram resilience 2 (ICES DATA BECAOMES GALICIA_SUMMARY_TAX_FINAL)

install.packages("worrms")
install.packages("dplyr")
install.packages("purrr")

library(worrms)
library(dplyr)
library(purrr)


species_list <- unique(galicia_summary$scientificname)
length(species_list)  
         
         
get_worms_taxonomy <- function(species_name) {
  res <- wm_records_name(name = species_name)
  
  # If no results, return empty tibble
  if (length(res) == 0 || (is.data.frame(res) && nrow(res) == 0)) {
    return(tibble())
  }
  
  # If result is a data.frame with rows, take the first row
  if (is.data.frame(res)) {
    entry <- res[1, ]
  } else if (is.list(res)) {
    # if result is a list, take the first element (which should be a list or df)
    entry <- res[[1]]
  } else {
    # unexpected result type, return empty tibble
    return(tibble())
  }
  
  # Construct data frame safely from entry
  tibble(
    scientificname = entry$scientificname,
    kingdom        = entry$kingdom,
    phylum         = entry$phylum,
    class          = entry$class,
    order          = entry$order,
    family         = entry$family,
    genus          = entry$genus,
    AphiaID        = entry$AphiaID
  )
}


safe_worms_lookup <- possibly(get_worms_taxonomy, otherwise = tibble())



taxonomy_list <- map(species_list, ~{
  Sys.sleep(1)  # to avoid API throttling
  safe_worms_lookup(.x)
})

taxonomy_df <- bind_rows(taxonomy_list)

galicia_summary_tax <- galicia_summary %>%
  left_join(taxonomy_df, by = "scientificname")

# Check for species without taxonomy info
galicia_summary_tax %>%
  filter(is.na(phylum)) %>%
  distinct(scientificname)




# Extract species with missing taxonomy
missing_species <- galicia_summary_tax %>%
  filter(is.na(phylum)) %>%
  distinct(scientificname) %>%
  pull(scientificname)

# Remove ' spp' to extract genus names
genus_only <- sub(" spp$", "", missing_species)

# New taxonomy function for genus-level lookup
get_genus_taxonomy <- function(genus_name) {
  res <- wm_records_name(name = genus_name)
  
  if (length(res) == 0 || (is.data.frame(res) && nrow(res) == 0)) {
    return(tibble())
  }
  
  if (is.data.frame(res)) {
    entry <- res[1, ]
  } else if (is.list(res)) {
    entry <- res[[1]]
  } else {
    return(tibble())
  }
  
  tibble(
    scientificname = paste0(genus_name, " spp"),
    kingdom        = entry$kingdom,
    phylum         = entry$phylum,
    class          = entry$class,
    order          = entry$order,
    family         = entry$family,
    genus          = entry$genus,
    AphiaID        = entry$AphiaID
  )
}

# Safe version
safe_genus_lookup <- possibly(get_genus_taxonomy, otherwise = tibble())

# Run the genus-level lookup
genus_tax_list <- map(genus_only, ~{
  Sys.sleep(1)
  safe_genus_lookup(.x)
})

# Combine results
genus_taxonomy_df <- bind_rows(genus_tax_list)

# Merge genus-level results into your main taxonomy table
taxonomy_df_final <- bind_rows(taxonomy_df, genus_taxonomy_df)

# Final merge with galicia summary
galicia_summary_tax_final <- galicia_summary %>%
  left_join(taxonomy_df_final, by = "scientificname")


galicia_summary_tax_final %>%
  filter(is.na(phylum)) %>%
  distinct(scientificname)


head(galicia_summary_tax_final)

## PESCA DE GALICIA 
