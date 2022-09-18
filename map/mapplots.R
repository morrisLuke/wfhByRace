# Declare file location, per the `here` package
# More info: https://here.r-lib.org/articles/here.html
here::i_am("map/mapplots.R",
           uuid = "4bb1f986-6d31-474f-9dd9-24c3842fb273")

# Let's pull in everything we've done so far
source(here::here("prep/datasetManipulate.R"))

# Calling needed libraries we haen't used yet
library(plotly)

# The first map we're making is looking at the overall proportion of
# people working from home in different parts of Los Angeles County
# I reversed the direction of the viridis colors to make more sense for a
# chloropleth map, which most often use light colors for low proportions and
# dark colors for higher proportions
# The use of the text aesthetic and `glue` relates to the next step
map_laCoWfhOverallProp <- laCoWfhPropByRace %>%
  filter(race == "Overall") %>%
  ggplot(aes(
    fill = prop,
    geometry = geometry,
    text = glue::glue("{NAME}
                       Work From Home Rate: {round(prop * 100, 1)}%")
    )
    ) + 
  geom_sf(color = "#9c9b9a") + 
  theme_void(base_size = 16) +
  scale_fill_viridis_c(direction = -1,
                       na.value = "white",
                       labels = scales::percent) +
  labs(
    title = "Rate of LA County residents working from home"
  )

# Let's add some interactivity with `plotly`! We've set up our text aesthetic
# to show what we want readers to see in the tooltip.
# COLLATERAL DAMAGE ALERT: Shapes with NA figures unforturnately show up with
# a "trace XX" tooltip that I struggled to troubleshoot. I'm living with it for
# now, but reach out if you know a fix
int_map_laCoWfhOverallProp <- ggplotly(map_laCoWfhOverallProp,
         tooltip = "text") %>%
  style(hoveron = "fill")

# In this map, we're going to show (part of) the racial and ethnic makeup of 
# different parts of LA County. The sheer number of NAs in the dataset made
# paring down to four of the most prominent groups a necessity
# I reversed the direction of the viridis colors to make more sense for a
# chloropleth map, which most often use light colors for low proportions and
# dark colors for higher proportions
# The use of the text aesthetic and `glue` relates to the next step
map_laCoRaceProps <- laCoRaceProps %>%
  filter(race %in% c("White", "Black", "Asian", "Latino")) %>%
  ggplot(aes(fill = prop,
             geometry = geometry,
             text = glue::glue("{NAME}
                                 {round(prop * 100, 1)}% {race}")
             )
         ) +
  geom_sf(color = "#9c9b9a") +
  facet_wrap(vars(race),
             ncol = 2) +
  theme_void(base_size = 16) +
  scale_fill_viridis_c(direction = -1,
                       na.value = "white",
                       labels = scales::percent) +
  labs(
    title = glue::glue("LA County by race/ethnicity")
  )

# Let's add some interactivity with `plotly`! We've set up our text aesthetic
# to show what we want readers to see in the tooltip.
# COLLATERAL DAMAGE ALERT: Shapes with NA figures unforturnately show up with
# a "trace XX" tooltip that I struggled to troubleshoot. I'm living with it for
# now, but reach out if you know a fix
int_map_laCoRaceProps <- ggplotly(map_laCoRaceProps,
         tooltip = "text") %>%
  style(hoveron = "fill")

# This map will closely resemble the last one but instead of racial and ethnic
# makeup of the area, it shows what proportion of different groups are able
# to  work  from home by area. Again, The sheer number of NAs in the dataset 
#  made paring down to four of the most prominent groups a necessity
# I reversed the direction of the viridis colors to make more sense for a
# chloropleth map, which most often use light colors for low proportions and
# dark colors for higher proportions
# The use of the text aesthetic and `glue` relates to the next step
# I'll probably end up using a tabset to let people compare and contrast this
# map with the previous one easily
map_laCoWfhPropByRace <- laCoWfhPropByRace %>%
  filter(race %in% c("White", "Black", "Asian", "Latino")) %>%
  ggplot(aes(fill = prop,
             geometry = geometry,
             text = glue::glue("{NAME}
                                 {round(prop * 100, 1)}% of {str_to_title(race)} residents work from home")
             )
         ) +
  geom_sf(color = "#9c9b9a") +
  facet_wrap(vars(race),
             ncol = 2) +
  theme_void(base_size = 16) +
  scale_fill_viridis_c(direction = -1,
                       na.value = "white",
                       labels = scales::percent) +
  labs(
    title = "WFH rate by race/ethnicity across LA County"
  )

# Let's add some interactivity with `plotly`! We've set up our text aesthetic
# to show what we want readers to see in the tooltip.
# COLLATERAL DAMAGE ALERT: Shapes with NA figures unforturnately show up with
# a "trace XX" tooltip that I struggled to troubleshoot. I'm living with it for
# now, but reach out if you know a fix
int_map_laCoWfhPropByRace <- ggplotly(map_laCoWfhPropByRace,
         tooltip = "text") %>%
  style(hoveron = "fill")
