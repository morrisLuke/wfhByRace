# Declare file location, per the `here` package
# More info: https://here.r-lib.org/articles/here.html
here::i_am("prep/datasetManipulate.R", 
           uuid = "d295d5ac-b6bc-4ba7-9cef-3a42871ea36e")

# Run our previous file, censusFetch, and add all its libraries and objects
# to the environment
source(here::here("prep/censusFetch.R"))

# Pivot `raceTotals` dataset (created in the censusFetch file) wider to allow 
# for a count for each race or ethnicity in a row. Then, use  mutate to add
# together the race counts (not including Latino ethnicity figures, which would 
# lead to double-counting)
raceTotalsWide <- raceTotals %>%
  as_tibble() %>%
  pivot_wider(
    id_cols = c(GEOID, NAME, geometry),
    names_from = variable, 
    values_from = estimate
  ) %>%
  mutate(
    totOverall = totWhite +
      totBlack +
      totNativeAm +
      totAsian +
      totHawaiianPI +
      totOtherRace +
      totMultiracial
    )

# Pivot `wfhByRace` dataset (created in the censusFetch file) wider to allow 
# for a count for each race or ethnicity in a row
wfhByRaceWide <- wfhByRace %>%
  as_tibble() %>%
  pivot_wider(
    id_cols = c(GEOID, NAME, geometry),
    names_from = variable, 
    values_from = estimate
  )

# create proportions to show what share of the work-from-home total each
# race or ethnicity accounts for
wfhRaceShare <-  wfhByRaceWide %>%
  mutate(
    white = wfhWhite/wfhTotal,
    black = wfhBlack/wfhTotal,
    nativeAm = wfhNativeAm/wfhTotal,
    asian = wfhAsian/wfhTotal,
    hawaiianPI = wfhHawaiianPI/wfhTotal,
    otherRace = wfhOtherRace/wfhTotal,
    multiracial = wfhMultiracial/wfhTotal,
    latino = wfhLatino/wfhTotal,
    .keep = "unused"
  )

# join our two wide datasets together to allow us to create proportions within
# races and ethnicities of those who work from home
wfhPropByRace <-  wfhByRaceWide %>%
  left_join(raceTotalsWide,
            by = c("GEOID", "NAME", "geometry")
            )%>%
  mutate(
    white = wfhWhite/totWhite,
    black =  wfhBlack/totBlack,
    nativeAm  = wfhNativeAm/totNativeAm,
    asian = wfhAsian/totAsian,
    hawaiianPI =  wfhHawaiianPI/totHawaiianPI,
    otherRace =  wfhOtherRace/totOtherRace,
    multiracial  = wfhMultiracial/totMultiracial,
    latino = wfhLatino/totLatino,
    overall =  wfhTotal/totOverall,
    .keep  = "unused"
  ) %>% 
  pivot_longer(
    cols = "white":"overall",
    names_to = "race",
    values_to = "prop"
  )

# We've got data for all PUMAs in California, but let's narrow in to just those
# in Los Angeles County (with the exception of Catalina and San Clemente
#islands, which really mess up the zoom level of our maps all for the sake of
#some NA values related to wfh)
laCoWfhPropByRace <- wfhPropByRace %>%
  filter(
    grepl("Los Angeles County", NAME)
         & !grepl("Palos Verdes Peninsula", NAME)
    )

# These PUMA names are lengthy and messy. Let's make them more reader-friendly
# Also, if you know how to do the first part with `stringr` rather than 
#`gsub()`, please clue me in!
laCoWfhPropByRace$NAME <- gsub(".*--","",laCoWfhPropByRace$NAME)
laCoWfhPropByRace$NAME <- str_remove_all(laCoWfhPropByRace$NAME, " PUMA, California")
laCoWfhPropByRace$NAME <- str_remove_all(laCoWfhPropByRace$NAME, " PUMA; California")
laCoWfhPropByRace$race <- str_to_title(laCoWfhPropByRace$race)

# Let's make racial and ethnic makeup proportions from our totals, then we'll
# pivot the data long to aid with our coming mapping functions
raceProps <- raceTotalsWide %>%
  mutate(
    propWhite = totWhite/totOverall,
    propBlack = totBlack/totOverall,
    propNativeAm = totNativeAm/totOverall,
    propAsian = totAsian/totOverall,
    propHawaiianPI = totHawaiianPI/totOverall,
    propOtherRace = totOtherRace/totOverall,
    propMultiracial = totMultiracial/totOverall,
    propLatino = totLatino/totOverall,
    .keep = "unused"
    ) %>% 
  pivot_longer(
    cols = starts_with("prop"),
    names_to = "race",
    values_to = "prop"
  )

# Similar to what we did before, let's pare this down to the mainland areas of
# Los Angeles County
laCoRaceProps <- raceProps %>%
  filter(grepl("Los Angeles County", NAME)
         & !grepl("Palos Verdes Peninsula", NAME))

# Trim those pesky PUMA names again
laCoRaceProps$NAME <- gsub(".*--","",laCoRaceProps$NAME)
laCoRaceProps$NAME <- str_remove_all(laCoRaceProps$NAME, " PUMA, California")
laCoRaceProps$NAME <- str_remove_all(laCoRaceProps$NAME, " PUMA; California")
laCoRaceProps$race <- str_remove_all(laCoRaceProps$race, "prop")
