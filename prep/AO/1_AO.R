# Filter AO_ACCESS AND AO_NEED
ao_access <- read.csv("/Users/batume/Documents/R/OHI_GAL/Downloaded/sdg_14_b_1_ao.csv", header=TRUE, sep=",")
ao_need <- read.csv("/Users/batume/Documents/R/OHI_GAL/Downloaded/wb_gdppcppp_rescaled.csv", header=TRUE, sep=",")

head(ao_need)

ao_access <- subset(ao_access,rgn_id  == "182")
ao_need <- subset(ao_need,rgn_id  == "182")

write.csv(ao_need, "/Users/batume/Documents/R/OHI_GAL/region/layers_gal/ao_need.csv", row.names = FALSE)

