Food Provision (FP) - Wild-Caught Fisheries (FIS) Subgoal / Natural
Products (NP) Goal Data Preparation
================

``` r
loc <- here::here("prep", "FIS")

source(here::here("R", "setup.R"))
source(here::here("R", "prep.R"))
source(here::here("R", "spatial.R"))
knitr::opts_chunk$set(message = FALSE, warning = FALSE, results = "hide", fig.width = 9.5)

bkgd_path <- here::here("supplement", "goal_summaries", "FIS.Rmd")
data_path <- here::here("data", "FIS", version_year, "fis_np_data.rmd")
refs_path <- file.path(loc, "fis_references.Rmd")

stocks_cols <- RColorBrewer::brewer.pal(6, "Paired") %>% str_replace("#1F78B4", "#065BCB") %>% str_replace("#33A02C", "#73BD65")
```

<br>

## 1\. Background

### 1.1 Goal Description

The Fisheries sub-goal of Food Provision describes the ability to
maximize the sustainable yield of wild-caught seafood for human
consumption. **For the BHI cod and herring stocks in the Baltic Sea were
included as wild-caught fisheries**.

### 1.2 Model & Data

The data used for this goal are cod and herring spawning biomass (SSB)
and fishing mortality (F) data. The current status is calculated as a
function of the ratio between the single species current biomass at sea
(B) and the reference biomass at maximum sustainable yield (BMSY), as
well as the ratio between the single species current fishing mortality
(F) and the fishing mortality at maximum sustainable yield (FMSY). These
ratios (B/Bmsy and F/Fmsy) are converted to scores between 0 and 1 using
as one component this [general
relationship](https://github.com/OHI-Science/bhi-prep/blob/master/prep/FIS/Fscoresformula.png).
This piecewise equation simply converts the F/FMSY value to an F’ score
that will fall between 0-1 (this function applies a penalty when B/BMSY
scores indicate good/underfishing but F/FMSY scores indicate high
fisheries related mortality).

[Cod and herring data can be found
here](http://standardgraphs.ices.dk/stockList.aspx). Search for cod or
herring, then specify the ecoregion as Baltic Sea and search for the
most current assessment.

### 1.3 Reference points

The reference point used for the computation are based on the MSY
principle and are described as a functional relationship. MSY means the
highest theoretical equilibrium yield that can be continuously taken on
average from a stock under existing average environmental conditions
without significantly affecting the reproduction process *(European
Union 2013, World Ocean Review 2013).*

### 1.4 Other information

External advisors/goalkeepers. Christian Möllmann

<br/>

## 2\. Data

This prep document is used to generate and explore the following data
layers:

  - `fis_bbmsy_bhi2019.csv`
  - `fis_ffmsy_bhi2019.csv`
  - `fis_landings_bhi2019.csv`
  - `fis_cod_bbmsy_bhi2019.csv`
  - `fis_cod_ffmsy_bhi2019.csv`
  - `fis_cod_landings_bhi2019.csv`
  - `np_bbmsy_bhi2019.csv`
  - `np_ffmsy_bhi2019.csv`
  - `np_landings_bhi2019.csv`

These are saved to the `layers/v2019` folder. Intermediate datasets
saved to `data/FIS/v2019/intermediate` include:
`fis_full_merged_dataset.csv` and`fis_cod_fultonsK.csv`. All these are
derived from or informed by the following raw datasets.

### 2.1 Datasets with Sources

#### 2.1.1 Landings (for F/FMSY) and SSB (for B/BMSY) Data

**Cod in subdivisions 22-24, western Baltic
stock**  
<!-- dataset save location BHI_share/BHI 2.0/Goals/FP/FIS/cod_SDs22_24/cod_SDs22_24.csv -->

<table class="table" style="">

<caption>

Source: [ICES
database](http://standardgraphs.ices.dk/ViewCharts.aspx?key=10446) <br>
Downloaded 2019-10-07 by Andrea De Cervo

</caption>

<thead>

<tr>

<th style="text-align:left;">

Option

</th>

<th style="text-align:left;">

Specification

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Species:

</td>

<td style="text-align:left;">

Gadus morhua

</td>

</tr>

<tr>

<td style="text-align:left;">

EcoRegion (Fishstock):

</td>

<td style="text-align:left;">

Baltic Sea

</td>

</tr>

<tr>

<td style="text-align:left;">

Assessment year:

</td>

<td style="text-align:left;">

2019

</td>

</tr>

<tr>

<td style="text-align:left;">

FishStock:

</td>

<td style="text-align:left;">

cod.27.22-24

</td>

</tr>

<tr>

<td style="text-align:left;">

Assessment Key:

</td>

<td style="text-align:left;">

10446

</td>

</tr>

</tbody>

</table>

<br>

**Cod in subdivisions 24-32, eastern Baltic
stock**  
<!-- dataset save location BHI_share/BHI 2.0/Goals/FP/FIS/cod_SDs24_32/cod_SDs24_32.csv -->

<table class="table" style="">

<caption>

Source: [ICES
database](http://standardgraphs.ices.dk/ViewCharts.aspx?key=12941) <br>
Downloaded 2019-10-07 by Andrea De Cervo

</caption>

<thead>

<tr>

<th style="text-align:left;">

Option

</th>

<th style="text-align:left;">

Specification

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Species:

</td>

<td style="text-align:left;">

Gadus morhua

</td>

</tr>

<tr>

<td style="text-align:left;">

EcoRegion (Fishstock):

</td>

<td style="text-align:left;">

Baltic Sea

</td>

</tr>

<tr>

<td style="text-align:left;">

Assessment year:

</td>

<td style="text-align:left;">

2019

</td>

</tr>

<tr>

<td style="text-align:left;">

FishStock:

</td>

<td style="text-align:left;">

cod.27.24-32

</td>

</tr>

<tr>

<td style="text-align:left;">

Assessment Key:

</td>

<td style="text-align:left;">

12941

</td>

</tr>

</tbody>

</table>

<br>

**Herring in subdivisions 20-24 -Skagerrak, Kattegat and western
Batic-**  
<!-- dataset save location BHI_share/BHI 2.0/Goals/FP/FIS/herring_SDs20_24/herring_SDs20_24.csv -->

<table class="table" style="">

<caption>

Source: [ICES
database](http://standardgraphs.ices.dk/ViewCharts.aspx?key=12592) <br>
Downloaded 2019-10-07 by Andrea De Cervo

</caption>

<thead>

<tr>

<th style="text-align:left;">

Option

</th>

<th style="text-align:left;">

Specification

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Species:

</td>

<td style="text-align:left;">

Clupea harengus

</td>

</tr>

<tr>

<td style="text-align:left;">

EcoRegion (Fishstock):

</td>

<td style="text-align:left;">

Baltic Sea

</td>

</tr>

<tr>

<td style="text-align:left;">

Assessment year:

</td>

<td style="text-align:left;">

2019

</td>

</tr>

<tr>

<td style="text-align:left;">

FishStock:

</td>

<td style="text-align:left;">

her.27.20-24

</td>

</tr>

<tr>

<td style="text-align:left;">

Assessment Key:

</td>

<td style="text-align:left;">

12592

</td>

</tr>

</tbody>

</table>

<br>

**Herring in subdivisions 25-29,32 -central Baltic Sea (excluding Gulf
of
Riga)-**  
<!-- dataset save location BHI_share/BHI 2.0/Goals/FP/FIS/herring_SDs25_29_32/herring_SDs25_29_32.csv -->

<table class="table" style="">

<caption>

Source: [ICES
database](http://standardgraphs.ices.dk/ViewCharts.aspx?key=10408) <br>
Downloaded 2019-10-07 by Andrea De Cervo

</caption>

<thead>

<tr>

<th style="text-align:left;">

Option

</th>

<th style="text-align:left;">

Specification

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Species:

</td>

<td style="text-align:left;">

Clupea harengus

</td>

</tr>

<tr>

<td style="text-align:left;">

EcoRegion (Fishstock):

</td>

<td style="text-align:left;">

Baltic Sea

</td>

</tr>

<tr>

<td style="text-align:left;">

Assessment year:

</td>

<td style="text-align:left;">

2019

</td>

</tr>

<tr>

<td style="text-align:left;">

FishStock:

</td>

<td style="text-align:left;">

her.27.25-2932

</td>

</tr>

<tr>

<td style="text-align:left;">

Assessment Key:

</td>

<td style="text-align:left;">

10408

</td>

</tr>

</tbody>

</table>

<br>

**Herring in subdivision 28.1 (Gulf of
Riga)**  
<!-- dataset save location BHI_share/BHI 2.0/Goals/FP/FIS/herring_SD_28.1/herring_SD_28.1.csv -->

<table class="table" style="">

<caption>

Source: [ICES
database](http://standardgraphs.ices.dk/ViewCharts.aspx?key=10404) <br>
Downloaded 2019-10-08 by Andrea De Cervo

</caption>

<thead>

<tr>

<th style="text-align:left;">

Option

</th>

<th style="text-align:left;">

Specification

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Species:

</td>

<td style="text-align:left;">

Clupea harengus

</td>

</tr>

<tr>

<td style="text-align:left;">

EcoRegion (Fishstock):

</td>

<td style="text-align:left;">

Baltic Sea

</td>

</tr>

<tr>

<td style="text-align:left;">

Assessment year:

</td>

<td style="text-align:left;">

2019

</td>

</tr>

<tr>

<td style="text-align:left;">

FishStock:

</td>

<td style="text-align:left;">

her.27.28

</td>

</tr>

<tr>

<td style="text-align:left;">

Assessment Key:

</td>

<td style="text-align:left;">

10404

</td>

</tr>

</tbody>

</table>

<br>

**Herring in subdivisions 30-31 (Gulf of
Bothnia)**  
<!-- dataset save location BHI_share/BHI 2.0/Goals/FP/FIS/herring_SDs30_31/herring_SDs30_31.csv -->

<table class="table" style="">

<caption>

Source: [ICES
database](http://standardgraphs.ices.dk/ViewCharts.aspx?key=12738) <br>
Downloaded 2019-10-08 by Andrea De Cervo

</caption>

<thead>

<tr>

<th style="text-align:left;">

Option

</th>

<th style="text-align:left;">

Specification

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Species:

</td>

<td style="text-align:left;">

Clupea harengus

</td>

</tr>

<tr>

<td style="text-align:left;">

EcoRegion (Fishstock):

</td>

<td style="text-align:left;">

Baltic Sea

</td>

</tr>

<tr>

<td style="text-align:left;">

Assessment year:

</td>

<td style="text-align:left;">

2019

</td>

</tr>

<tr>

<td style="text-align:left;">

FishStock:

</td>

<td style="text-align:left;">

her.27.3031

</td>

</tr>

<tr>

<td style="text-align:left;">

Assessment Key:

</td>

<td style="text-align:left;">

12738

</td>

</tr>

</tbody>

</table>

<br>

**Sprat in subdivisions 22-32 (Baltic
Sea)**  
<!-- dataset save location BHI_share/BHI 2.0/Goals/NP/sprat_SDs22_32/sprat_SDs22_32.csv -->

<table class="table" style="">

<caption>

Source: [ICES
database](http://standardgraphs.ices.dk/ViewCharts.aspx?key=12942) <br>
Downloaded 2019-10-08 by Andrea De Cervo

</caption>

<thead>

<tr>

<th style="text-align:left;">

Option

</th>

<th style="text-align:left;">

Specification

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Species:

</td>

<td style="text-align:left;">

Sprattus sprattus

</td>

</tr>

<tr>

<td style="text-align:left;">

EcoRegion (Fishstock):

</td>

<td style="text-align:left;">

Baltic Sea

</td>

</tr>

<tr>

<td style="text-align:left;">

Assessment year:

</td>

<td style="text-align:left;">

2019

</td>

</tr>

<tr>

<td style="text-align:left;">

FishStock:

</td>

<td style="text-align:left;">

spr.27.22-32

</td>

</tr>

<tr>

<td style="text-align:left;">

Assessment Key:

</td>

<td style="text-align:left;">

12942

</td>

</tr>

</tbody>

</table>

<br>

#### 2.1.2 Cod Trawl Survey

**Baltic International Trawl Survey (BITS) Cod Length and Weight - ICES
subdivisions
21-29**  
<!-- dataset save location BHI_share/2.0/Goals/FP/FIS/SMALK_2019-10-22 16_34_01/SMALK_2019-10-22_16_34_01.csv -->

<table class="table" style="">

<caption>

Source: [ICES DATRAS
database](https://datras.ices.dk/Data_products/Download/Download_Data_public.aspx)
<br> Downloaded 2019-10-22 by Eleanore Campbell

</caption>

<thead>

<tr>

<th style="text-align:left;">

Option

</th>

<th style="text-align:left;">

Specification

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Data Product:

</td>

<td style="text-align:left;">

SMALK

</td>

</tr>

<tr>

<td style="text-align:left;">

Survey:

</td>

<td style="text-align:left;">

BITS (Baltic International Trawl Survey)

</td>

</tr>

<tr>

<td style="text-align:left;">

Quarters:

</td>

<td style="text-align:left;">

4

</td>

</tr>

<tr>

<td style="text-align:left;">

Years:

</td>

<td style="text-align:left;">

All

</td>

</tr>

<tr>

<td style="text-align:left;">

Species:

</td>

<td style="text-align:left;">

All species -\> Gadus morhua

</td>

</tr>

</tbody>

</table>

<br>

**Baltic International Trawl Survey (BITS) Cod CPUE - ICES subdivisions
21-29**  
<!-- dataset save location BHI_share/2.0/Goals/FP/FIS/CPUE_per_length_per_haul_per_hour_2019-11-07_13_36_17/CPUE_per_length_per_haul_per_hour_2019-11-07_13_36_17.csv -->

<table class="table" style="">

<caption>

Source: [ICES DATRAS
database](https://datras.ices.dk/Data_products/Download/Download_Data_public.aspx)
<br> Downloaded 2019-11-07 by Eleanore Campbell

</caption>

<thead>

<tr>

<th style="text-align:left;">

Option

</th>

<th style="text-align:left;">

Specification

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Data Product:

</td>

<td style="text-align:left;">

CPUE per length per haul per hour

</td>

</tr>

<tr>

<td style="text-align:left;">

Survey:

</td>

<td style="text-align:left;">

BITS (Baltic International Trawl Survey)

</td>

</tr>

<tr>

<td style="text-align:left;">

Quarters:

</td>

<td style="text-align:left;">

All

</td>

</tr>

<tr>

<td style="text-align:left;">

Years:

</td>

<td style="text-align:left;">

All

</td>

</tr>

<tr>

<td style="text-align:left;">

Ships:

</td>

<td style="text-align:left;">

All

</td>

</tr>

<tr>

<td style="text-align:left;">

Gear:

</td>

<td style="text-align:left;">

All

</td>

</tr>

<tr>

<td style="text-align:left;">

Areas:

</td>

<td style="text-align:left;">

All

</td>

</tr>

<tr>

<td style="text-align:left;">

Species:

</td>

<td style="text-align:left;">

Standard species -\> Gadus morhua

</td>

</tr>

</tbody>

</table>

<br>

#### 2.1.3 FMSY and BMSY Reference Points

**Cod (Gadus morhua) in subdivisions 22–24, western Baltic stock
(western Baltic Sea)** [Reference
points](http://ices.dk/sites/pub/Publication%20Reports/Advice/2019/2019/cod.27.22-24.pdf):
BMSY: 21 876 ; FMSY (Ftotal 2020): 0.26

**Cod (Gadus morhua) in subdivisions 24–32, eastern Baltic stock
(eastern Baltic Sea)** [Reference
points](http://ices.dk/sites/pub/Publication%20Reports/Advice/2019/2019/cod.27.24-32.pdf):
BMSY (Bpa): 108 035 ; FMSY: 0.3

**Herring (Clupea harengus) in Subdivisions 20-24 (Skagerrak, Kattegat
and western Baltic)** [Reference
points](http://ices.dk/sites/pub/Publication%20Reports/Advice/2019/2019/her.27.20-24.pdf):
BMSY 150 000 ; FMSY 0.31

**Herring (Clupea harengus) in Subdivisions 25-29,32 (excluding Gulf of
Riga)** [Reference
points](http://ices.dk/sites/pub/Publication%20Reports/Advice/2019/2019/her.27.25-2932.pdf):
BMSY 600 000 ; FMSY 0.22

**Herring (Clupea harengus) in Subdivision 28.1 (Gulf of Riga)**
[Reference
points](http://ices.dk/sites/pub/Publication%20Reports/Advice/2019/2019/her.27.28.pdf):
BMSY 60 000 ; FMSY 0.32

**Herring (Clupea harengus) in Subdivisions 30 and 31 (Gulf of
Bothnia)** [Reference
points](http://ices.dk/sites/pub/Publication%20Reports/Advice/2019/2019/her.27.3031.pdf):
BMSY 140 998 ; FMSY 0.15

**Sprat (Sprattus sprattus) in Subdivisions 22-32 (Baltic Sea)**
[Reference
points](http://ices.dk/sites/pub/Publication%20Reports/Advice/2019/2019/spr.27.22-32.pdf):
BMSY 570 000 ; FMSY 0.26

### 2.2 Centralization & Normalization

Each assessed stock has its own raw datafile. Cod and herring data are
saved under `Goals/FP/FIS` and sprat data are saved in the `Goals/NP`
folder.

The MSY values (FMSY and BMSY for each assessed stock) are taken from
the ICES advice reports, linked in the `standardgraphs.ices.dk` aspx
pages. No table is saved with these values- they are entered directly
into a dataframe in the code below.

``` r
## root location of the raw data
dir_rawdata <- file.path(dir_B, "Goals", "FP", "FIS") # list.files(dir_rawdata)

## Fisheries data from ICES
## if csvs are saved w/ semicolons:
# source(file.path(here::here(), "R", "semicolon_to_comma.R"))
# lapply(
#   list("cod_SDs22_24", "cod_SDs24_32",
#        "herring_SD_28.1", "herring_SDs20_24",
#        "herring_SDs25_29_32", "herring_SDs30_31"),
#   function(x){
#      fp <- file.path(dir_rawdata, x, paste0(x, "_reformat.csv"))
#      semicolon_to_comma(fp, remove_na_cols = TRUE, overwrite = TRUE)
#   }
# )
# semicolon_to_comma(file.path(dir_B,"Goals","NP","sprat_SDs22_32","sprat_SDs22_32_reformat.csv"), TRUE, TRUE)


## cod data
cod1raw <- read_csv(file.path(dir_rawdata, "cod_SDs22_24", "cod_SDs22_24_reformat.csv"))
cod2raw <- read_csv(file.path(dir_rawdata, "cod_SDs24_32", "cod_SDs24_32_reformat.csv"))

## herring data
herring1raw <- read_csv(file.path(dir_rawdata, "herring_SD_28.1", "herring_SD_28.1_reformat.csv"))
herring2raw <- read_csv(file.path(dir_rawdata, "herring_SDs20_24", "herring_SDs20_24_reformat.csv"))
herring3raw <- read_csv(file.path(dir_rawdata, "herring_SDs25_29_32", "herring_SDs25_29_32_reformat.csv"))
herring4raw <- read_csv(file.path(dir_rawdata, "herring_SDs30_31", "herring_SDs30_31_reformat.csv"))

## sprat data
sprat1raw <- read_csv(file.path(dir_B, "Goals", "NP", "sprat_SDs22_32", "sprat_SDs22_32_reformat.csv"))


## make MSY values table
## these values are obtained from ICES reports, see data/FIS/fis_np_data.rmd for more details
msy_data <- t(data.frame(
  c("cod", "22-24", "cod_SDs22_24", 21876, 0.26),
  c("cod", "24-32", "cod_SDs24_32", 108035, 0.3),
  c("herring", "28.1", "herring_SD_28.1", 60000, 0.32),
  c("herring", "20-24", "herring_SDs20_24", 150000, 0.31),
  c("herring", "25-29,32", "herring_SDs25_29_32", 600000, 0.22),
  c("herring", "30-31", "herring_SDs30_31", 140998, 0.15),
  c("sprat", "22-32", "sprat_SDs22_32", 570000, 0.26)
))
## for testing effect of using 2013 values...
# msy_2013_data <- t(data.frame(
#   c("cod", "22-24", "cod_SDs22_24", 36400, 0.26),
#   c("cod", "24-32", "cod_SDs24_32", 88200, 0.46),
#   c("herring", "28.1", "herring_SD_28.1", 60000, 0.35),
#   c("herring", "20-24", "herring_SDs20_24", 110000, 0.28),
#   c("herring", "25-29,32", "herring_SDs25_29_32", 600000, 0.26),
#   c("herring", "30-31", "herring_SDs30_31", 316000, 0.15),
#   c("sprat", "22-32", "sprat_SDs22_32", 570000, 0.29)
# ))
# msy_data <- msy_2013_data
colnames(msy_data) <- c("species", "SDs", "stockname", "BMSY", "FMSY")
rownames(msy_data) <- NULL
msy_data <- as_tibble(msy_data)
```

#### 2.2.0 Merge datasets and calculate F/FMSY and B/BMSY ratios

``` r
combined_rawdata <- rbind(
  ## cod
  cod1raw %>% 
    dplyr::mutate(catch_tonnes = ifelse(
      !is.na(discards_tonnes), 
      landings_tonnes + discards_tonnes,
      landings_tonnes
    )) %>%
    dplyr::select(
      year, ssb, 
      fis_mort = fishing_mortality_age3_5, 
      catch = catch_tonnes
      # landings = landings_tonnes
    ) %>%
    mutate(stockname = "cod_SDs22_24"),
  cod2raw %>% 
    dplyr::mutate(catch_tonnes = ifelse(
      !is.na(discards_tonnes), 
      landings_tonnes + discards_tonnes,
      landings_tonnes
    )) %>%
    dplyr::select(
      year, ssb, 
      fis_mort = fishing_mortality_age4_6, 
      catch = catch_tonnes
      # landings = landings_tonnes
    ) %>% 
    mutate(stockname = "cod_SDs24_32"),
  ## herring
  herring1raw %>% 
    dplyr::select(
      year, ssb = ssb_tonnes, 
      fis_mort = `F`, 
      catch = catches_tonnes # no data on discards, only catch...
    ) %>% 
    mutate(stockname = "herring_SD_28.1"),
  herring2raw %>% 
    dplyr::select(
      year, ssb = ssb_tonnes, 
      fis_mort = F_age3_6, 
      catch = catches_tonnes
    ) %>% 
    mutate(stockname = "herring_SDs20_24"),
  herring3raw %>% 
    dplyr::select(
      year, ssb = ssb_tonnes, 
      fis_mort = F_age3_6, 
      catch = catches_tonnes
    ) %>% 
    mutate(stockname = "herring_SDs25_29_32"),
  herring4raw %>% 
    dplyr::select(
      year, ssb = ssb, 
      fis_mort = F_age3_7, 
      catch = catches_tonnes
    ) %>% 
    mutate(stockname = "herring_SDs30_31"),
  ## sprat
  sprat1raw %>% 
    dplyr::select(
      year, ssb = ssb_tonnes, 
      fis_mort = F_age3_5, 
      catch = catches_tonnes
    ) %>% 
    mutate(stockname = "sprat_SDs22_32")) %>% 
  ## join with msy data
  filter(!is.na(year)) %>% 
  left_join(msy_data, by = c("stockname")) %>% 
  mutate(bbmsy = ssb/as.numeric(BMSY), ffmsy = fis_mort/as.numeric(FMSY)) %>% 
  arrange(species, stockname, year)
```

<br>

#### 2.2.1 Standardize Units: Match BHI Regions to ICES Subdivisions

[Map of ICES
regions.](https://www.ices.dk/marine-data/Documents/Maps/ICES-Ecoregions-hybrid-statistical-areas.png)
The map below shows the overlap between ICES subdivisions and the BHI
regions:

``` r
source(here::here("R", "spatial.R"))
regions_shape() # loads spatial features objects

## ICES shapefile has crs EPSG:3035
## https://spatialreference.org/ref/epsg/etrs89-etrs-laea/
## transform to match BHI crs of EPSG:4326, and simplify

ices_transform <- rmapshaper::ms_simplify(input = ICES_rgns_shp) %>% 
  sf::st_as_sf() %>% 
  sf::st_transform(crs = 4326)
bhi_rgns_simple <- rmapshaper::ms_simplify(input = BHI_rgns_shp) %>% 
  sf::st_as_sf() # also simplify BHI shp for plotting

map_bhi_ices <- ggplot2::ggplot() + 
  ## baltic countries borders
  geom_sf(
    data = rnaturalearth::ne_countries(scale = "medium", returnclass = "sf") %>%
      st_crop(xmin = 0, xmax = 40, ymin = 53, ymax = 67),
    fill = "ivory", 
    size = 0.1
  ) +
  ## ICES areas
  geom_sf(
    data = ices_transform, 
    aes(fill = ICES_area), 
    color = NA,
    alpha = 0.5
  ) +
  scale_fill_manual(values = colorRampPalette(RColorBrewer::brewer.pal(9, "Set3"))(14)) +
  # scale_fill_manual(values = as.vector(pals::kelly(n = 14))) + # library(pals)
  # scale_fill_manual(values = colorRampPalette(beyonce_palette(127))(14)) + # library(beyonce)
  labs(fill = "ICES Subdivisions", x = NULL, y = NULL) +
  ## BHI regions with ID numbers
  geom_sf(data = bhi_rgns_simple, fill = NA, size = 0.15, color = "grey40") +
  scale_x_continuous(limit = c(5, 37)) +
  scale_y_continuous(limit = c(53.5, 66)) +
  theme(
    panel.background = element_rect(fill = "#F8FBFC", color = "#E2EEF3"),
    legend.position = c(0.9, 0.6)
  )
map_bhi_ices + geom_sf_text(data = bhi_rgns_simple, aes(label = BHI_ID)) 
```

![](fis_np_prep_files/figure-gfm/map%20how%20the%20ICES%20and%20BHI%20regions%20overlap-1.png)<!-- -->

A lookup table derived from the overlap between ICES subdivisions and
BHI regions as shown in the map above, is used in the code below to
match BHI region IDs to the raw
dataset:

``` r
## based on 'prep/FIS/raw/DataOrganization.R' by Melanie Frazier March 16 2016, in bhi-1.0-archive
## table for matching ICES to BHI regions
regions <- read_csv(
  here::here("supplement", "lookup_tabs", "ices_to_bhi_lookup.csv"), 
  col_types = cols()) %>% 
  mutate(ices_numeric = ifelse(ices_numeric == 3, 21, ices_numeric)) # 3a.21 overlaps BHI rgn 1 & 2

## convert ICES stock assessments to BHI regions
combined_w_rgns <- combined_rawdata %>% 
  
  ## expand ices subdivisions categories to one row per subdiv
  rowwise() %>% 
  mutate(
    ## check unique(combined_rawdata$SDs) to make sure this string parsing will work
    sd_from = as.numeric(str_split(SDs, "-|,")[[1]][1]),
    sd_to = as.numeric(str_split(SDs, "-|,")[[1]][2]),
    sd_extra = as.numeric(str_split(SDs, "-|,")[[1]][3])
  ) %>% 
  mutate(
    sd_to = ifelse(is.na(sd_to), sd_from, sd_to),
    sd_extra = ifelse(is.na(sd_extra), sd_from, sd_extra),
    incl28.2 = sd_from <= 28 & sd_to >= 28,
    incl28.1 = sd_from <= 28 & sd_to >= 28 & species != "herring"
  ) %>% 
  ## ICES regions 28.1 for Riga and 28.2 elsewhere but no 28
  mutate(SDs = list(
    unique(
      c(sd_from:sd_to, sd_extra)[c(sd_from:sd_to, sd_extra)!=28] %>% 
        c(ifelse(incl28.2, 28.2, sd_from)) %>% 
        c(ifelse(incl28.1, 28.1, sd_from))
    )
  )) %>% 
  tidyr::unnest(ices_subdiv = SDs) %>% 
  ## NOTE:
  ## using catches instead of landings, because herring landings were not reported, just catch
  ## but i dont want to go back through code and change everything to from 'landings' to 'catch'
  dplyr::select(year, species, stockname, ssb, BMSY, bbmsy, fis_mort, FMSY, ffmsy, landings = catch, ices_subdiv) %>%
  filter(ices_subdiv != 20) %>% # filter because no BHI region assigned to SD 20 and will cause NA means...
  
  ## add BHI regions info using ices_to_bhi_lookup
  left_join(dplyr::select(regions, region_id, ices_numeric, area_km2), by = c("ices_subdiv" = "ices_numeric"))

## ICES subdivs 20 and 21 are North Sea and left out of BHI1.0, but herring in 3a.21 for rgn 1 & 2
# combined_w_rgns <- combined_w_rgns %>% filter(!ices_subdiv %in% c(20, 21))
```

<br>

``` r
surveyBITS_cod <- read_csv(file.path(dir_rawdata, "SMALK_2019-10-22_16_34_01", "SMALK_2019-10-22_16_34_01.csv"))
# unique(surveyBITS_cod$Country) # no data for Finland, or really any areas north of North Baltic Proper

q4_fultonsK <- surveyBITS_cod %>%
  mutate(length_cm = LngtClass/10) %>% 
  dplyr::select(year = Year, ices_subdiv = Area, eez = Country, length_cm, wgt_gram = IndWgt) %>% 
  mutate(
    ## revise country EEZ codes to be consistent with codes used elsewhere by BHI
    eez = ifelse(eez == "GFR", "DEU", ifelse(eez == "DEN", "DNK", ifelse(eez == "LAT", "LVA", eez))),
    ## calculate fultons K and assign length classes
    fultonsK = wgt_gram/(length_cm^3)*100,
    length_group = floor(length_cm/10)
  ) %>% 
  filter(!is.na(fultonsK), fultonsK < 2) %>% 
  ## per Casini et al exclude lengths < 10cm and ≥60cm-- not enough data:
  filter(length_group %in% 1:5) %>% 
  mutate(
    length_group = ifelse(
      length_group == 1, "10-20cm", ifelse(
         length_group == 2, "20-30cm", ifelse(
           length_group == 3, "30-40cm", "40-60cm"
         )
      )
    )
  ) %>% 
  ## join BHI regions
  ## area 28 includes both 28.2 and gulf of Riga 28.1 
  ## http://www.ices.dk/marine-data/Documents/DATRAS/Survey_Maps_Datras.pdf
  mutate(ices_subdiv = ifelse(ices_subdiv == 28, list(28.1, 28.2), ices_subdiv)) %>% 
  tidyr::unnest(ices_subdiv = ices_subdiv) %>% 
  right_join(
    regions %>% 
      dplyr::select(region_id, eez, ices_subdiv = ices_numeric) %>% 
      filter(ices_subdiv %in% c(unique(surveyBITS_cod$Area), 28.1, 28.2)),
    by = c("ices_subdiv", "eez")
  )

# filter(q4_fultonsK, is.na(fultonsK)) # NA check
q4_fultonsK <- filter(q4_fultonsK, !is.na(fultonsK))
## will give BHI region 1 have same penalty as 2, BHI 5 same as 6, and BHI 29 same as 26
## as these regions are small, close, and/or share overlapping ICES areas; see ICES vs BHI regions map above
```

**No cod in Northern part of the Baltic Sea\! Filter combined fisheries
dataset to reflect this.**

``` r
cpue_sf <- read_csv(file.path(
  dir_rawdata, 
  "CPUE_per_length_per_haul_per_hour_2019-11-07_13_36_17", 
  "CPUE_per_length_per_haul_per_hour_2019-11-07_13_36_17.csv")) %>% 
  dplyr::select(Year, DateTime, Ship, Gear, ShootLat, ShootLong, rateCPUE = CPUE_number_per_hour) %>% 
  filter(Year >= 2008) %>% 
  distinct() %>% 
  sf::st_as_sf(coords = c("ShootLong", "ShootLat"), crs = 4326)

map_bhi_ices + 
  geom_sf(aes(size = rateCPUE), color = "royalblue3", alpha = 0.02, shape = 16, data = cpue_sf) + 
  labs(size = "Number/Hour", x = NULL, y = NULL) +
  guides(fill = FALSE) + 
  theme(legend.position = c(0.15, 0.85))
```

<img src="fis_np_prep_files/figure-gfm/distributions of cod from BITS surveys CPUE-1.png" width="120%" />

``` r
combined_w_rgns <- combined_w_rgns %>% 
  filter(!(species == "cod" & region_id %in% 27:42))
```

<br>

#### 2.2.2 Save Datasets

``` r
## full merged dataset with MSY and raw data, as well as calculated ratios
## this will be used for the shiny app among other things!
write_csv(
  combined_w_rgns %>% rename(catch = landings), 
  here::here("data", "FIS", version_year, "intermediate", "fis_full_merged_dataset.csv")
)
```

``` r
## full merged dataset with MSY and raw data, as well as calculated ratios
## this will be used for the shiny app among other things!
write_csv(
  q4_fultonsK, 
  file.path(here::here(), "data", "FIS", version_year, "intermediate", "fis_cod_fultonsK.csv")
)
```

<br/>

## 3\. Prep: Wrangling & Derivations, Checks/Evaluation, Gapfilling

### 3.1 Reorganizing/wrangling

This section prepares data layers for FIS and NP at the same time,
separating the fish stocks for each:

  - FIS stocks: cod\_22-24, cod\_25-32, her\_28.1, her\_20-24,
    her\_25-29,32, her\_30-31
  - NP stocks: spr\_22-32

#### 3.1.1 Wrangle and save layers for FIS and NP Goals

The F/FMSY, B/BMSY, and landings data are the ICES stock assessment area
values, expanded to have all years rows per BHI region within the stock
assessment area, and row-bound to include all stocks in one table.

``` r
combined_w_rgns <- read_csv(
  here::here("data", "FIS", version_year, "intermediate", "fis_full_merged_dataset.csv")
) %>% 
  
  ## NOTE: what is called 'landings' throughout this script is actually catch
  ## this decision was made late in the analysis; at this time i'm not going back through to change all instances...
  rename(landings = catch) %>%
  group_by(stockname, year) %>% 
  mutate(
    assessArea = sum(area_km2), # stocks assessment areas
    landings_rate = landings/assessArea # per unit area
  ) %>%  
  group_by(region_id) %>% 
  ## without better information, assuming landings are uniform across stock assessment area, 
  ## then landings within BHI rgn are proportional to rgn area fraction of total stock area
  mutate(rgn_landings = landings_rate*area_km2) %>% 
  ungroup() %>% 
  rename(stock = stockname, area_rgn_km2 = area_km2) %>% 
  filter(year < assess_year) # current yr fish. mort. data won't be complete

## UNCOMMENT LINE BELOW FOR SCORES BASED ON ONLY COD STOCKS...
# combined_w_rgns <- combined_w_rgns %>% filter(species == "cod") 

## full dataset in long format with calculated ratios, for plotting
plot_format_msy_metrics <- combined_w_rgns %>% 
  dplyr::select(region_id, stock, species, year, bbmsy, ffmsy) %>% 
  tidyr::gather(key = metric, value = value, -year, -stock, -species, -region_id) %>% 
  filter(year >= 1970, !str_detect(stock, "spr"))

msy_metrics_plot <- ggplot(data = plot_format_msy_metrics)  +
  geom_abline(slope = 0, intercept = 1, color = "grey40") +
  geom_line(aes(x = year, y = value, color = stock), size = 0.5) +
  scale_color_brewer(palette = "Paired") +
  ylab("value \n")+
  facet_grid(vars(metric), vars(species)) + 
  theme(legend.position = "none")

## landings data formatted for plotting
plot_format_landings <- combined_w_rgns %>% 
  dplyr::select(region_id, stock, species,  year, landings, rgn_landings) %>% 
  tidyr::gather(key = "metric", value = "value", -year, -stock, -species, -region_id) %>% 
  filter(year >= 1970, !str_detect(stock, "spr"))

landings_plot <- ggplot(filter(plot_format_landings, metric == "landings")) +
  geom_line(aes(x = year, y = value, color = stock), size = 0.5) +
  scale_color_brewer(palette = "Paired") +
  ylab(NULL) +
  facet_grid(vars(metric), vars(species)) + 
  guides(color = guide_legend(nrow = 1)) +
  theme(legend.position = "top")
# landings_plot <- ggplot(filter(plot_format_landings, metric == "rgn_landings")) +
#   geom_point(aes(x = year, y = value, color = stock), size = 2, alpha = 0.1) +
#   geom_line(
#     data = summarize(filter(landings_all, metric == "rgn_landings"), mn = mean(value)),
#     aes(x = year, y = mn, color = stock)) +
#   scale_color_brewer(palette = "Paired") +
#   ylab(NULL) +
#   facet_grid(vars(stock))


## TIMESERIES PLOT
## F/FMSY, B/BMSY, and Landings (msy_metrics_plot and landings_plot)
gridExtra::grid.arrange(msy_metrics_plot, landings_plot, nrow = 2, heights = c(1.8, 1.2))
```

<img src="fis_np_prep_files/figure-gfm/fis_ffmsy_bbmsy and fis_landings plots-1.png" width="850px" />

``` r
## same preparation of data for fis and np, just different stocks used:
## cod and herring are used in the FIS goal
## sprat are used for the NP goal
long_format <- combined_w_rgns %>% 
  dplyr::select(region_id, stock, species, year, landings, rgn_landings, bbmsy, ffmsy) %>% 
  tidyr::gather(key = "metric", value = "value", -year, -stock, -species, -region_id) %>% 
  filter(year >= 1970)

goal_stocks <- c("FIS", "NP")
for(g in goal_stocks){
  if(g == "FIS"){
    fis_data <- long_format %>% filter(!str_detect(stock, "spr"))
    msy_dat <- fis_data %>% filter(metric %in% c("ffmsy", "bbmsy"))
    landings <- fis_data %>% filter(metric %in% c("landings", "rgn_landings"))
    
    ## UNCOMMENT LINE BELOW FOR SCORES BASED ON ONLY COD STOCKS...
    # g <- "FIS_COD"
    
  } else {
    np_data <- long_format %>% filter(str_detect(stock, "spr"))
    msy_dat <- np_data %>% filter(metric %in% c("ffmsy", "bbmsy"))
    landings <- np_data %>% filter(metric %in% c("landings", "rgn_landings"))
  }
  ## filter to save by metric: bbmsy, ffmsy, landings
  msy_dat %>% 
    filter(metric == "bbmsy") %>% 
    dplyr::select(-metric, -species) %>% 
    write_csv(
      file.path(
        dir_layers, 
        sprintf("%s_bbmsy_bhi%s.csv", str_to_lower(g), assess_year)
      )
    )
  msy_dat %>% 
    filter(metric == "ffmsy") %>% 
    dplyr::select(-metric, -species) %>% 
    write_csv(
      file.path(
        dir_layers, 
        sprintf("%s_ffmsy_bhi%s.csv", str_to_lower(g), assess_year)
      )
    )
  landings %>%
    # filter(metric == "rgn_landings") %>% # should match whats used to calculate wgts below!
    filter(metric == "landings") %>%
    rename(landings = value) %>% 
    dplyr::select(-metric, -species) %>% 
    write_csv(
      file.path(
        dir_layers, 
        sprintf("%s_landings_bhi%s.csv", str_to_lower(g), assess_year)
      )
    )
}
```

### 3.2 Evaluate data & sampling patterns

#### 3.2.1 Comparing with previous BHI Assessment

The code below loads FIS layers from current and prior BHI assessments
so the raw metrics can be compared before scores are calculated– an
early check which can help catch data quality issues, and helpful to
suss out how changes in original data might be reflected in final goal
scores.

This involves matching current and prior ICES stock assessment areas,
joining the datasets, and plotting values of one BHI version against the
other, per metric and stock. These plots can be used to e.g. identify
outliers. Values for which the ICES areas changed are highlighted so as
to effects of this can be visually inspected.

``` r
## load layers
fis_bbmsy <- read_csv(file.path(
  dir_layers, 
  sprintf("fis_bbmsy_bhi%s.csv", assess_year)
)) %>% rename(bbmsy = value)

fis_ffmsy <- read_csv(file.path(
  dir_layers, 
  sprintf("fis_ffmsy_bhi%s.csv", assess_year)
)) %>% rename(ffmsy = value)

fis_landings <- read_csv(file.path(
  dir_layers, 
  sprintf("fis_landings_bhi%s.csv", assess_year)
))

## previous assessment layers
prev_fis_bbmsy <- read_csv(
  file.path(dirname(dir_assess), "bhi-1.0-archive", "baltic2015", "layers",
            sprintf("fis_bbmsy_bhi%s.csv", 2015))) %>% 
  rename(prev_bbmsy = score, region_id = rgn_id)

prev_fis_ffmsy <- read_csv(
  file.path(dirname(dir_assess), "bhi-1.0-archive", "baltic2015", "layers",
            sprintf("fis_ffmsy_bhi%s.csv", 2015))) %>% 
  rename(prev_ffmsy = score, region_id = rgn_id)

prev_fis_landings <- read_csv(
  file.path(dirname(dir_assess), "bhi-1.0-archive", "baltic2015", "layers",
            sprintf("fis_landings_bhi%s.csv", 2015))) %>% 
  rename(prev_landings = landings, region_id = rgn_id)


## join and plot to identify differences
## ICES assessment areas for each stock change sometimes between ICES and BHI Assessments...
matchtab <- data.frame(
  from = c(
    "cod_SDs22_24", "cod_SDs24_32", 
    "herring_SD_28.1", "herring_SDs20_24", 
    "herring_SDs25_29_32", "herring_SDs30_31"
  ),
  to = c("cod_2224", "cod_2532", "her_riga", "her_3a22", "her_2532", "her_30")
)
matchtab$from <- as.character(matchtab$from)
matchtab$to <- as.character(matchtab$to)

## mapping between/matching previous CES stock assess. areas and most recent
stockareas_match <- function(tab, jointab, matchtab){
  for(i in 1:nrow(matchtab)){
    tab <- tab %>% 
      mutate(stock = str_replace(stock, pattern = matchtab[i, "from"], replacement = matchtab[i, "to"]))
  }
  revisedtab <- tab %>% 
    left_join(jointab, by = c("stock", "year", "region_id")) %>% 
    ## create logical column highlighting where stock assessment area changes occured
    mutate(changed_assess_area = ifelse(stock %in% c("cod_2532", "her_3a22", "her_30"), TRUE, FALSE)) %>% 
    dplyr::select(-region_id) %>% 
    distinct()
  return(revisedtab)
}
compare_bbmsy <- stockareas_match(fis_bbmsy, prev_fis_bbmsy, matchtab)
compare_ffmsy <- stockareas_match(fis_ffmsy, prev_fis_ffmsy, matchtab)


## plot to investigate effects of these changes...
compare_bbmsy_plot <- ggplot(compare_bbmsy) +
  geom_abline(slope = 1, intercept = 0, color = "grey85", alpha = 0.5)  + 
  geom_point(
    aes(x = prev_bbmsy, y = bbmsy, color = changed_assess_area, shape = stock), 
    size = 2, alpha = 0.6
  ) + 
  labs(
    shape = "ICES Stocks, \n previous ICES categories", 
    color = "ICES Stock Areas Changed\nbetween current and previous\nassessments",
    x = "B/BMSY from Previous Assessment", 
    y = "B/BMSY from Current Assessment"
  )
compare_ffmsy_plot <- ggplot(compare_ffmsy) +
  geom_abline(slope = 1, intercept = 0, color = "grey85", alpha = 0.5)  + 
  geom_point(
    aes(x = prev_ffmsy, y = ffmsy, color = changed_assess_area, shape = stock), 
    size = 2, alpha = 0.6
  ) + 
  labs(
    x = "F/FMSY from Previous Assessment", 
    y = "F/FMSY from Current Assessment"
  ) + 
  theme(legend.position = "none")

gridExtra::grid.arrange(compare_ffmsy_plot, compare_bbmsy_plot, nrow = 1, widths = c(0.6, 1))
```

![](fis_np_prep_files/figure-gfm/compare%20to%20fis%20data%20used%20in%20last%20assessment-1.png)<!-- -->

<br>

#### 3.2.2 Proportions of total catch over time

Of all the fisheries landings that occurred in a given area and year,
what proportion is made up by each stock?  
How have these proportions changed over time?

**Note:** different stocks are assessed in different groupings of ICES
areas/subdivisions and do not neatly overlap. Without more information
(regardless of how catches may in reality be spatially distributed
across the assessment areas and BHI regions), the partitioning of
catches by BHI regions assumed uniform catch rate over the area, and
thus regional:total catch fraction was assumed to be the same as rgn
area:total stock area fraction.

``` r
## proportions of stocks by BHI region and year
yearly_rgn_props <- combined_w_rgns %>% 
  dplyr::select(region_id, stock, year, landings, rgn_landings, landings_rate, area_rgn_km2) %>%
  filter(!str_detect(stock, "spr")) %>%
  group_by(region_id, year) %>% 
  mutate(rgn_yr_totCatch = sum(rgn_landings)) %>% 
  ungroup() %>%
  ## proportion a given stock makes up of total catch in region, by year
  mutate(rgn_yr_propCatch = rgn_landings/rgn_yr_totCatch)

## catch proportions of total landings plots
## filter e.g. region_id %in% c(1, 3, 11, 14, 27, 37) to rep. 6 distinct zones created by assessment overlap
ggplot(filter(yearly_rgn_props, year >= 1995)) +
  geom_area(
    aes(x = year, y = rgn_yr_propCatch, fill = stock), # y = rgn_yr_totCatch
    position = "stack", 
    alpha =  0.5
  ) +
  guides(fill = guide_legend(nrow = 1))  +
  theme(legend.position = "bottom") + 
  scale_fill_manual(values = stocks_cols) +
  facet_wrap(~region_id, nrow = 6) +
  labs(
    title = "Cumulative Catch with Stock Proportions of Total",
    x = NULL,
    y = "Cumulative catches, by region and stock \n", 
    fill = "Stock"
  ) +
  scale_x_continuous(breaks = c(1995, 2005, 2015))
```

![](fis_np_prep_files/figure-gfm/catch%20proportions%20plots-1.png)<!-- -->

<br>
<br>

#### 3.2.3 Regions map for stock proportions (most recent year) of total catch

These proportions are the weights used for combining statuses of
multiple stock into one status value for the region.

``` r
## combine wrangled data with spatial info for mapping
map_format_data <- yearly_rgn_props %>% 
      filter(year == max(yearly_rgn_props$year)) %>%
      dplyr::select(region_id, rgn_yr_totCatch) %>% 
      distinct() %>% 
  left_join(
    yearly_rgn_props %>% 
      filter(year == max(yearly_rgn_props$year)) %>%
      dplyr::select(region_id, stock, rgn_yr_propCatch) %>% 
      tidyr::spread(key = "stock", value = "rgn_yr_propCatch"),
    by = "region_id"
  ) %>% 
  arrange(region_id)
## if have NA regions, e.g. when checking with just cod...
if(any(!1:42 %in% map_format_data$region_id)){
  na_rgn <- setdiff(1:42, map_format_data$region_id)
  map_format_data <- rbind(
    data.frame(
      region_id = na_rgn,
      rgn_yr_totCatch = rep(NA, length.out = length(na_rgn)),
      cod_SDs22_24 = rep(NA, length.out = length(na_rgn)),
      cod_SDs24_32 = rep(NA, length.out = length(na_rgn))
    ),
    map_format_data %>% filter(!region_id %in% na_rgn)
  ) %>% arrange(region_id)
}

## need to rerun this bit of code if fis_np_data.rmd wasn't run before...
## creates BHI spatial objects in environment include simplified polygons for mapping
if(!exists("bhi_rgns_simple")){
  if(!exists("BHI_rgns_shp")){
    source(file.path(here::here(), "R", "spatial.R"))
    regions_shape() # loads spatial features objects
  }
  bhi_rgns_simple <- rmapshaper::ms_simplify(input = BHI_rgns_shp) %>% 
    sf::st_as_sf() # also simplify BHI shp for plotting
}
bhi_rgns_shp <- bhi_rgns_simple %>% 
  left_join(map_format_data, by = c("BHI_ID" = "region_id")) %>% 
  arrange(BHI_ID)

## extract centroid lat lon from BHI region sf geometries and make table
piechart_coords <- do.call(rbind, sf::st_geometry(bhi_rgns_shp %>% sf::st_centroid())) %>% 
  as_tibble() %>% setNames(c("long", "lat")) %>% 
  cbind(
    map_format_data %>% 
      mutate(radius = log(rgn_yr_totCatch/2000 + 1)) %>% # for when checking results with just cod...
      # mutate(radius = log(rgn_yr_totCatch/20000 + 1)) %>% # comment out when checking results with just cod...
      dplyr::select(-rgn_yr_totCatch)
  ) %>% 
  mutate_all(coalesce, 0) %>% 
  mutate(region_id = as.factor(as.character(region_id)))

rgns_sp <- as(bhi_rgns_shp, "Spatial")
rgns_sp_df <- left_join(
  fortify(rgns_sp, region = "BHI_ID"),
  rgns_sp@data %>% mutate(BHI_ID = as.character(BHI_ID)),
  by = c("id" = "BHI_ID")
)

## map with piecharts showing stock catch proportions of total catch by region
ggplot2::ggplot(rgns_sp_df) + 
  geom_polygon(aes(long, lat, group = group), alpha = 0.01, size = 0.1, color = "slategray") +
  ## https://www.r-bloggers.com/scatterpie-for-plotting-pies-on-ggplot/
  ## install.packages("scatterpie")
  scatterpie::geom_scatterpie(
    ## note: radii of piecharts are log transformed total regional catch
    aes(x = long, y = lat, group = region_id, r = radius/4), 
    data = piechart_coords,
    cols = c(names(piechart_coords)[str_detect(names(piechart_coords), "cod|herring")]),
    
    legend_name = "Stock",
    alpha = 0.6, color = NA
  ) + 
  scale_fill_manual(values = stocks_cols) +
  theme(legend.position = "top") +  
  theme_bw() +
  labs(x = NULL, y = NULL, subtitle = "Radii represent log-transformed total regional catch.") +
  theme(legend.position = c(0.15, 0.75), plot.caption = element_text(hjust = 0)) +  
  coord_fixed()
```

![](fis_np_prep_files/figure-gfm/map%20stock%20values%20by%20bhi%20and%20ICES%20regions-1.png)<!-- -->

<br>

### 3.3 Status and trend

Calculating status consists of the following steps: - derive Eastern
Baltic cod penalty factor - calculate F-scores and B-scores - take mean
of F and B scores, with data grouped by region\_id, stock, year - derive
weights from landings data (proportions of catch made up of different
stocks in each region) - apply penalty for cod condition in the Eastern
Baltic - calculate status as a geometric mean weighted by proportion of
catch in each region

The formulas for calculating F and B scores are based on [this
paper](https://doi.org/10.1371/journal.pone.0098995).

<br>

#### 3.3.1 Eastern Baltic cod condition penalty factor

Biomass and mortality are not sufficient to characterize the status of
the Eastern Baltic cod, as it is condition not just populations which
have significantly declined. Fulton’s K is used as a measure of
condition. The following method based on [Casini et
al. 2016](https://doi.org/10.1098/rsos.160416) :

  - Individual body condition (Fulton’s K) estimated as K = W/(L^3) ×
    100
  - W = the total weight (g) of the fish
  - L = total length (cm) of the fish
  - condition averaged per length-class for each region, year
  - lengths \< 10 cm and ≥60 cm excluded– not enough data
  - focused on quarter 4 as it corresponds to the main feeding season

The original metric considered for this penalty factor was proportion of
surveyed cod in length category 40-60cm (the most commercially
important) with Fulton’s K less than 0.8. However, due to small sample
sizes per survey area in this length class (n = 1 some cases,
increasingly common in more recent years), this metric will not suffice.
Including smaller size classes 20-30cm and 30-40cm will help increase
sample size, especially for future asssessments as fewer larger fish may
be caught in the future.

Within ICES survey areas, country was found to have significant effect
on condition. So, rather than grouping by ICES area and matching
resulting penalty factors to BHI regions in the same way as with
mortality and biomass data, country information was retained and used in
matching to BHI regions.

<br>

``` r
q4_fultonsK <- read_csv(
  file.path(
    here::here(), "data", "FIS", version_year, "intermediate", 
    "fis_cod_fultonsK.csv"
  )
)

## are K values significantly different within ICES areas by country/eez?
## i.e. ok to calculate these penalties by ICES area and assign to BHI regions in the same way as w/ F and B data?
## consistency is preferable and also,
## taking only lengths 40-60, grouping by region (vs ICES area) and yr leaves few data pts in each group
## e.g in last 10 years, 27% (vs 10%) have 1 or2, 35% (vs 18%) with <6, 45% (vs 38%) <11
n_eez <- dplyr::select(q4_fultonsK, ices_subdiv, eez) %>% distinct() %>% count(ices_subdiv)
for(i in filter(n_eez, n > 1)$ices_subdiv){
  tmp <- filter(q4_fultonsK, ices_subdiv == i, length_group != "10-20cm")
  print(summary.aov(aov(fultonsK ~ year + eez, data = tmp)))
  
  # print(count(tmp, year, eez) %>% spread(eez, n) %>% filter(year > 2008))
  # ggplot(q4_fultonsK %>% filter(ices_subdiv == i, length_group != "10-20cm", year > 2008)) + 
  #   geom_histogram(aes(fultonsK)) + 
  #   facet_grid(rows = vars(eez), scales =  "free_y")
}
## conclusion: eez has signif. effect on K except for rgns 28.1 28.2, so should group by BHI not ICES areas...


## further evaluating effect of grouping by BHI region vs ICES subdivisions,
## test with both region_id and ices_subdiv...
spatial_group <- "region_id" # "ices_subdiv"
spID <- sym(spatial_group)

## averages per region, year, and length group
## aggregate length classes 20-40 and 40-60cm
q4_fultonsK_avgs <- q4_fultonsK %>% 
  group_by(!!spID, year, length_group) %>% 
  summarize(avg_cond = mean(fultonsK)) %>% 
  mutate(length_group = as.character(length_group))

## trends per length class in each region
## about !! notation see:
## https://shipt.tech/https-shipt-tech-advanced-programming-and-non-standard-evaluation-with-dplyr-e043f89deb3d
q4K_wTrends <- q4_fultonsK_avgs %>% 
  group_by(!!spID, length_group) %>%
  do(
    yr_coeff = lm(avg_cond ~ year, data = .)$coefficients["year"] %>% unlist(),
    yr_int = lm(avg_cond ~ year, data = .)$coefficients["(Intercept)"] %>% unlist()
  ) %>% 
  tidyr::unnest(yr_coeff, yr_int) %>% 
  right_join(q4_fultonsK_avgs, by = c(spatial_group, "length_group")) %>% 
  group_by(year) %>% 
  mutate(mean_yr_condition = mean(avg_cond)) %>% 
  ungroup()
q4K_wTrends$length_group <- as.factor(q4K_wTrends$length_group)

## all together with yearly average K
# ggplot(q4K_wTrends, aes(x = year, y = avg_cond)) +
#   geom_point(size = 2, alpha = 0.5, aes(color = length_group, shape = length_group)) +
#   geom_line(aes(x = year, y = mean_yr_condition), size = 0.5) +
#   scale_color_manual(values = RColorBrewer::brewer.pal(9, "Spectral")[c(4,5,7,9)]) +
#   labs(
#     title = sprintf(
#       "Average Condition of Eastern Baltic Cod by %s Region", 
#       ifelse(spatial_group == "region_id", "BHI", "ICES")
#     ),
#     x = NULL, y = "Condition (Fulton's K)\n", 
#     color = "Length Group", shape = "Length Group"
#   )

## plot of trends by region and length group
ggplot(data = q4K_wTrends) +
  geom_abline(aes(slope = yr_coeff, intercept = yr_int, color = length_group), size = 0.2) +
  geom_point(aes(x = year, y = avg_cond, color = length_group, shape = length_group), size = 1.2, alpha = 0.8) +
  # geom_line(aes(x = year, y = avg_cond, color = length_group), size = 0.3) +
  scale_color_manual(values = RColorBrewer::brewer.pal(9, "Spectral")[c(4,5,7,9)]) +
  geom_abline(slope = 0, intercept = 1, alpha = 0.5) +
  geom_abline(slope = 0, intercept = 0.8, alpha = 0.5) +
  facet_wrap(vars(!!spID), nrow = 4) +
  theme_grey() +
  labs(
    title = sprintf(
      "Condition trends of Eastern Baltic Cod by %s Region", 
      ifelse(spatial_group == "region_id", "BHI", "ICES")
    ), 
    x = NULL, y = "Condition (Fulton's K)\n", 
    color = "Length Group", shape = "Length Group"
  )
```

![](fis_np_prep_files/figure-gfm/eastern%20baltic%20cod%20penalty%20factor%20wrangling-1.png)<!-- -->

<br>

**Penalty factor as proportion of fish in class 40-60cm with K \> 0.8**

``` r
## penalty factor as proportion of fish in class 40-60cm with K > 0.8
cod_penalty <- q4_fultonsK %>% 
  filter(length_group != "10-20cm") %>%
  dplyr::select(!!spID, year, fultonsK) %>% 
  group_by(!!spID, year) %>% 
  summarize(
    prop_above_pt8 = sum(fultonsK > 0.8)/n(), 
    num_samp = n(),
    meanK = mean(fultonsK, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(stock = "cod_SDs24_32")


## GAPFILLING ALERT
## for completeness, need to assign penalty factors for regions 1, 5, (11?) 29, 30, 32-42
## though actually are no cod in North Baltic Proper and northwards because of too-low salinity...
gapfill_penalty <- function(use_rgns, for_rgns){
  gf_rows <- cod_penalty %>% 
    filter(region_id %in% use_rgns) %>% 
    group_by(year) %>% 
    mutate(
      prop_above_pt8 = mean(prop_above_pt8, na.rm = TRUE), 
      num_samp = mean(num_samp, na.rm = TRUE), 
      region_id = list(for_rgns),
      meanK = mean(meanK, na.rm = TRUE)
    ) %>% 
    tidyr::unnest(region_id = region_id) %>% 
    ungroup() %>% 
    distinct() %>% 
    dplyr::select(region_id, year, prop_above_pt8, num_samp, meanK, stock)
  return(gf_rows)
}

cod_penalty_gf <- cod_penalty %>% 
  rbind(
    gapfill_penalty(2, 1),
    gapfill_penalty(6, 5),
    gapfill_penalty(26, 29),
    gapfill_penalty(c(6, 12), 11)
  )

cod_penalty_rollmean <- cod_penalty_gf %>% 
  arrange(region_id, year) %>% 
  group_by(region_id) %>% 
  mutate(ma5 = zoo::rollapply(prop_above_pt8, 5, mean, na.rm = TRUE, align = "right", fill = NA)) %>% 
  ungroup() %>% 
  filter(!is.na(ma5)) 

## this will be another BHI layer
write_csv(
  cod_penalty_rollmean %>% 
    dplyr::filter(num_samp > 3) %>% 
    dplyr::select(region_id, year, penalty_factor = ma5),
  file.path(dir_layers, sprintf("fis_cod_penalty_bhi%s.csv", assess_year))
)
```

<br>

``` r
## gapfilled for all 42 BHI regions and with 5 year rolling mean
ggplot(cod_penalty_rollmean) +  
  geom_line(aes(x = year, y = ma5), color = stocks_cols[2], size = 0.3) + 
  geom_line(aes(x = year, y = prop_above_pt8), color = stocks_cols[2], size = 2, alpha = 0.1) + 
  facet_wrap(vars(!!spID), ncol = 5) +
  labs(
    title = sprintf(
      "Proportion Eastern Baltic Cod with K > 0.8 (by %s Region, 5 year Rolling Mean)",
      ifelse(spatial_group == "region_id", "BHI", "ICES")
    ),
    x = NULL, 
    y = "Proportion in Length Classes 20-60cm with K > 0.8 
        (yearly data, dark overlying line represents 5yr rolling mean)\n"
  ) +
  scale_x_continuous(breaks = c(1995, 2005, 2015))
```

![](fis_np_prep_files/figure-gfm/cod%20penalty%20rolling%20mean%20plot-1.png)<!-- -->

<br>

#### 3.3.2 F-Scores, B-Scores, Weights

Status and trend are calculated by `functions.R` when the full BHI index
is calculated. The calculations are included here also, so that
parameters and results (sensitivity) can be explored. Scores are
calculated in two ways (B-scores and F-scores) for each stock in a
region, which are then averaged, weighted by a penalty factor if they
correspond to Eastern Baltic cod, and combined for all stocks in a
region as the geometric mean using catch proportions of
total.

``` r
metric_scores <- left_join(fis_bbmsy, fis_ffmsy,  by = c("region_id", "stock", "year"))

## B-SCORES
## calculate B-scores

## note: these parameters can be changed!
## BHI1.0 assessment used values: lowerB = 0.8, upperB1 = 1.5, upperB2 ≈ 3.3
## view Bscores plot to evaluate/test different parameter values...
lowerB <- 0.95
upperB1 <- 1.3
upperB2 <- 5

B_scores <- metric_scores %>%
  mutate(
    score_type = "B_score",
    
    score = ifelse(
      bbmsy < lowerB, (1/lowerB)*bbmsy,
      ifelse(
        lowerB <= bbmsy & bbmsy < upperB1, 1, 
        ifelse(
          bbmsy >= upperB1, 
          (bbmsy - upperB2)/(upperB1-upperB2), NA
        )
      )
    )
  ) %>% 
  mutate(
    score = ifelse(
      score <= 0.1, 0.1, 
      ifelse(score > 1, 1, score)
    )
  )

B_plot <- ggplot(data = B_scores, aes(bbmsy, score, color = score)) + geom_line(size = 2) + 
  labs(title = "B-scores vs. B/BMSY values", x = "B/BMSY", y = "B-Score") +
  theme(legend.position = "none")
```

<br>

Calculating F-scores is slightly more complicated, using both B/BMSY and
F/FMSY ratios:

F-scores are base off both F/FMSY and B/BMSY values. The piecewise
function used here is derived so that parameters are bounds on F and B
which can be conceptualized/are more intuitive and adjustable. See 3.5
Methods discussion section for more details on this function. The
important thing to note here is that these values are adjustable and
should be tested and reviewed if necessary during the calculation and
comparison to the data.

``` r
## F-SCORES
## calculate F-scores
## kind of an ugly function,
## derived so that parameters are bounds on F and B which can be conceptualized, and adjusted

## note: these parameters can be adjusted, as can the B-score parameters above 
## BHI1.0 assessment used values: lowerB = 0.8, lowerF = 0.8, upperF1 = 1.2, upperF2 = 2.5
## view Bscores and Fscores plots to evaluate/test different parameter values...
## low lowerF ~ tolerance for low catch: doesn't differentiate whether to allow recovery, or despite high effort...
lowerF <- 0.5
upperF1 <- 1
upperF2 <- 4.5

## make this a function so it's easier to explore parameters...
calcFscores <- function(input_data, lowB = 0.8, lowF = 0.8, uppF1 = 1.2, uppF2 = 2.5){
  
  # install.packages("pracma")
  norm1 = pracma::cross(
    c(lowB, uppF1, 1) - c(0, 1, 0),
    c(lowB, uppF2, 0) - c(0, 1, 0)
  )
  norm2 = pracma::cross(
    c(lowB, 0, (uppF2-lowF-1)/(uppF2-1)) - c(lowB, lowF, 1),
    c(0, 1-(uppF2-lowF), 1) - c(lowB, lowF, 1)
  )
  
  ## PIECEWISE FORMULA...
  ## note input_data must have 'bbmsy' and 'ffmsy' columns
  m = (uppF2-1)/lowB
  result <- input_data %>%
    mutate(
      score_type = "F_score",
      
      score = ifelse(
        ## when bbmsy < lowB :
        bbmsy < lowB,
        
        ## will be space near zero where scores start going back down from 1:
        ## on y-axis towards zero if uppF2-lowF < 1, on x-axis towards zero if uppF2-uppF1 > 1
        ifelse(
          ffmsy > m*bbmsy + 1, 0,
          ifelse(
            m*bbmsy + 1 >= ffmsy & ffmsy > m*bbmsy + (1-(uppF2-uppF1)),
            ## http://mathworld.wolfram.com/Plane.html n1x + n2y + n3z - (n1x0 + n2y0 + n3z0) = 0
            (norm1[2] - norm1[1]*bbmsy - norm1[2]*ffmsy)/norm1[3],
            ifelse(
               m*bbmsy + (1-(uppF2-uppF1)) >= ffmsy & ffmsy > m*bbmsy + (1-(uppF2-lowF)), 1,
               ((norm2[1]*lowB + norm2[2]*lowF + norm2[3]) - (norm2[1]*bbmsy + norm2[2]*ffmsy))/norm2[3]
            )
          )
        ),
        ## when bbmsy >= lowB :
        ifelse(
           ffmsy > uppF1,
           (uppF2-ffmsy)/(uppF2-uppF1),
           ifelse(
             uppF1 >= ffmsy & ffmsy > lowF, 
             1,
             ffmsy/(uppF2-1) + (uppF2-lowF-1)/(uppF2-1)
           )
        )
      )
    ) %>% 
    ## set scores less than 0.1 to 0.1, greater than 1 to 1
    mutate(
      score = ifelse(
        score <= 0.1, 0.1,
        ifelse(score > 1, 1, score)
      )
    )
  return(result)
}

## create heatplot showing now ffmsy and bbmsy map to scores
ffmsy_bbmsy_score <- calcFscores(
  input_data = expand.grid(
    ffmsy = seq(0, 6, length.out = 120), 
    bbmsy = seq(0, 5, length.out = 120)
  ),
  lowB = lowerB, lowF = lowerF, uppF1 = upperF1, uppF2 = upperF2
)

## calculate F-scores
F_scores <- calcFscores(metric_scores, lowB = lowerB, lowF = lowerF, uppF1 = upperF1, uppF2 = upperF2)

## how do sample points overlay Fscores, can use this to check values for F and B parameters
## where biomass is sufficiently high, high mortality can still correspond to higher Fscore
## where biomass is very low, low mortality (even with F < FMSY value) will not result in  high Fscore
fscore_plot <- ggplot(data = ffmsy_bbmsy_score) +
  geom_tile(aes(bbmsy, ffmsy, fill = score), alpha = 0.8) +
  xlab("B/BMSY") + ylab("F/FMSY") + labs(fill = "F-Score\n") + 
  theme(legend.position = c(0.8, 0.7))
ggsave(file.path(loc, "Fscoresformula.png"), fscore_plot, dpi = 120, width = 5, height = 4)

F_plot <- fscore_plot + 
  geom_point(aes(bbmsy, ffmsy), F_scores, shape = 15, size = 3, alpha = 0.01) +
  labs(title = "F-scores vs. B/BMSY and F/FMSY values")

gridExtra::grid.arrange(B_plot, F_plot, nrow = 1)
```

![](fis_np_prep_files/figure-gfm/calculate%20score%20component%20F-1.png)<!-- -->

<br>

Use F and B scores to calculate overall `FIS` goal status:

1.  Use the average catch for each stock/region across the last 15 years
    to obtain weights
2.  Apply Eastern Baltic cod condition penalty factor
3.  Take geometric mean weighted by proportion each stock comprises of
    total catch in each region

<!-- end list -->

``` r
## WEIGHTS
## calculate weights with landing data
## we use the average catch for each stock/region across the last 25 years to obtain weights
weights <- yearly_rgn_props %>%
  filter(year > max(year) - 26) %>%
  dplyr::select(region_id, stock, year, landings) %>% # BHI1.0 used ICES area, alt.: rgn_landings values
  ## each region/stock will have same avg catch across years, timeseries mean
  group_by(region_id, stock) %>% 
  mutate(avgCatch = mean(landings)) %>% 
  group_by(region_id, year) %>%
  mutate(totCatch = sum(avgCatch)) %>% # total (i.e. all stock) catch on average (across years)
  ungroup() %>%
  ## average prop. of catch each stock accounts for, over last 25yr
  mutate(propCatch = avgCatch/totCatch)

# chk <- weights %>%
#   group_by(region_id, year) %>%
#   summarise(sumProps = sum(propCatch))
# unique(chk$sumProps) # sum of proportions of landings for each region/year sums to one

## visualize for example region three
# ggplot(filter(weights, region_id == 3)) + 
#   geom_line(aes(x = year, y = avgCatch)) + 
#   geom_line(aes(x = year, y = landings), color = stocks_cols[1]) +
#   facet_grid(vars(stock))  +
#   labs(
#     x = "Year", y = "Catch (with 25 year average) by Stock\n", 
#     title = "Example catch by Stock w/ time series average"
#   )
```

<br>

#### 3.3.3 Status

``` r
## geometric mean weighted by proportion (hence the weights df) of catch in each region
status_with_penalty <- weights %>% 
  
  ## start with overall score as an average of B-scores and F-scores
  ## these averages will be weighted by stock landings and have cod condition penalty applied
  left_join(
    rbind(B_scores, F_scores) %>%
      group_by(region_id, stock, year) %>%
      summarize(score = mean(score, na.rm = TRUE)) %>% # hist(scores$score)
      left_join(
        tidyr::spread(rbind(B_scores, F_scores), key = "score_type", value = "score"),
        by = c("year", "stock", "region_id")
      ),
    by =  c("region_id", "year", "stock")) %>%
  filter(!is.na(score)) %>% # remove missing data
  
  ## apply penalty because bad cod condition in eastern baltic
  left_join(cod_penalty_rollmean, by = c("year", "region_id", "stock")) %>% 
  mutate(penalty = ifelse(
    is.na(prop_above_pt8) & !str_detect(stock, "cod.*32"), 
    1, prop_above_pt8
  )) %>% 
  dplyr::select(-prop_above_pt8, -num_samp) %>% 
  mutate(score = penalty*score)

## calculate BHI scores, geometric means of different stocks by region
scores <- status_with_penalty %>% 
  group_by(region_id, year) %>% 
  summarize(status_prop = prod(score^propCatch)) %>%
  ungroup()
```

<br>

``` r
## visualize scores/status results
ggplot(status_with_penalty, aes(x = year)) + 
  geom_ribbon(aes(ymin = F_score, ymax = B_score, fill = stock), alpha = 0.3) + 
  geom_line(aes(y = score, color = stock), size =  0.4) +
  facet_wrap(vars(region_id), nrow = 7) + 
  scale_fill_manual(values = stocks_cols) +
  scale_color_manual(values = stocks_cols) +
  # guides(fill = guide_legend(nrow = 1)) +
  # guides(color = guide_legend(nrow = 1)) +
  # theme(legend.position = "bottom") +
  labs(x = "Year", y = "Score", color = "Stock", fill = "Stock")
```

![](fis_np_prep_files/figure-gfm/evaluate%20fis%20goal%20model%20and%20data-1.png)<!-- -->

### 3.4 Gapfilling

The F/FMSY and B/BMSY data processing for FIS and NP goals do not
include any gapfilling or interpolation. However, the matching ICES
subdivisions to BHI regions is not exact, and…

The calculation of the Eastern Baltic Cod penalty factor does involve
some gapfilling. Specifically, no data was reported in for cod in the
[Baltic International Trawl survey
(BITS)](https://datras.ices.dk/Data_products/Download/Download_Data_public.aspx)
for ICES areas 30, 31, 32 or in ICES area 29 except for Estonia. While…

### 3.5 Methods discussion

<br>

#### 3.5.1 Adjustment of Cod scores Based on Body Weight and Length

Source: [Casini M et
al. 2016](http://dx.doi.org/10.1098/rsos.160416)

#### 3.5.2 Matching ICES stock assessment areas to BHI Regions

<br>

#### 3.5.3 Setting F-Score and B-score parameters

<img src="/Users/andreadecervo/github/bhi-prep/prep/FIS/fis-fscores-formula.png" width="70%" />

<br>

## 4\. Considerations for `BHI3.0`

Implement strong sustainability concept e.g. with a BMSY reference
representing ‘ideal’ (near pristine) environmental conditions
(e.g. historic extent of anoxic bottom) Also, aim to use survey and
effort data to improve the goal calculations.

<br>

## 5\. References

[Casini M et al. 2016](http://dx.doi.org/10.1098/rsos.160416) Hypoxic
areas, density-dependence and food limitation drive the body condition
of a heavily exploited marine sh predator. R. Soc. open sci. 3: 160416.
<http://dx.doi.org/10.1098/rsos.160416>

**Cod (Gadus morhua) in subdivisions 22–24, western Baltic stock
(western Baltic Sea)** [Reference
points](http://ices.dk/sites/pub/Publication%20Reports/Advice/2019/2019/cod.27.22-24.pdf)

**Cod (Gadus morhua) in subdivisions 24–32, eastern Baltic stock
(eastern Baltic Sea)** [Reference
points](http://ices.dk/sites/pub/Publication%20Reports/Advice/2019/2019/cod.27.24-32.pdf)

**Herring (Clupea harengus) in Subdivisions 20-24 (Skagerrak, Kattegat
and western Baltic)** [Reference
points](http://ices.dk/sites/pub/Publication%20Reports/Advice/2019/2019/her.27.20-24.pdf)

**Herring (Clupea harengus) in Subdivisions 25-29,32 (excluding Gulf of
Riga)** [Reference
points](http://ices.dk/sites/pub/Publication%20Reports/Advice/2019/2019/her.27.25-2932.pdf)

**Herring (Clupea harengus) in Subdivision 28.1 (Gulf of Riga)**
[Reference
points](http://ices.dk/sites/pub/Publication%20Reports/Advice/2019/2019/her.27.28.pdf)

**Herring (Clupea harengus) in Subdivisions 30 and 31 (Gulf of
Bothnia)** [Reference
points](http://ices.dk/sites/pub/Publication%20Reports/Advice/2019/2019/her.27.3031.pdf)

**Sprat (Sprattus sprattus) in Subdivisions 22-32 (Baltic Sea)**
[Reference
points](http://ices.dk/sites/pub/Publication%20Reports/Advice/2019/2019/spr.27.22-32.pdf)

<br>
