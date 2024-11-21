### NOT USEFUL ANYMORE ####

# 2.1: Read the raw data
ttdi_file <- "WEF_TTDI_2021_data_for_download.xlsx"
ttdi_raw <- read_excel(ttdi_file, skip = 2)

# 2.2: Move up column names from the first row while keeping the full country names as columns too
names(ttdi_raw)[1:9] <- as.character(ttdi_raw[1, 1:9])

# 2.3 Filter for sustainability scores, select needed columns, and pivot to tidy format
ttdi <- ttdi_raw %>%
  filter(Title == "T&T Sustainability subindex, 1-7 (best)",
         Attribute == "Score") %>%
  select(year = Edition, Albania:Zambia) %>%
  pivot_longer(cols = Albania:Zambia, names_to = "country", values_to = "score") %>%
  mutate(score = as.numeric(score))

# 2.4: Filter only for Spain
ttdi_spain <- ttdi %>%
  filter(country == "Spain") %>%
  select(year, country, score)

