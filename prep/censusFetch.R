# Declare file location, per the `here` package
# More info: https://here.r-lib.org/articles/here.html
here::i_am("prep/censusFetch.R",
           uuid = "f99d57db-85af-4299-a686-8c0e2bbf7374")

# Calling needed libraries
library(here)
library(tidyverse)
library(tidycensus)
library(sf)
options(tigris_use_cache = TRUE)

# Fetch selected variables from 2021 ACS tables B02001 and #B03003 to serve as
# totals for the racial and ethnic makeup of all of the census-designated
# public use microdata areas (PUMA) in California
# more info: https://walker-data.com/tidycensus/articles/basic-usage.html
# for census table crosswalk, I use https://censusreporter.org/
raceTotals  <- get_acs(
  geography = "public use microdata area",
  state = "CA",
  variables = c(
    totWhite  = "B02001_002",
    totBlack = "B02001_003",
    totNativeAm = "B02001_004",
    totAsian = "B02001_005",
    totHawaiianPI = "B02001_006",
    totOtherRace = "B02001_007",
    totMultiracial = "B02001_008",
    totLatino = "B03003_003"
  ),
  geometry = TRUE,
  year = 2021,
  survey = "acs1"
)

# Fetch selected variables from 2021 ACS tables B08105A-I and #B08006 to serve
# as totals of work-from-home workers by racial and ethnic makeup for all of 
# the census-designated public use microdata areas (PUMA) in California
# more info: https://walker-data.com/tidycensus/articles/basic-usage.html
# for census table crosswalk, I use https://censusreporter.org/
wfhByRace  <- get_acs(
  geography = "public use microdata area",
  state = "CA",
  variables = c(
    wfhWhite  = "B08105A_007",
    wfhBlack = "B08105B_007",
    wfhNativeAm = "B08105C_007",
    wfhAsian = "B08105D_007",
    wfhHawaiianPI = "B08105E_007",
    wfhOtherRace = "B08105F_007",
    wfhMultiracial = "B08105G_007",
    wfhLatino = "B08105I_007",
    wfhTotal = "B08006_017"),
  geometry = TRUE,
  year = 2021,
  survey = "acs1"
)
