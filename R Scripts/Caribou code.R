library(tidyverse)
library(lubridate)
library(osmdata)
library(ggmap)
library(plotKML)
library(gganimate)
library(tools)

# Load Data --------------------------------------------------------------------

caribou <- read.csv("C:\\Users\\PC\\Downloads\\Mountain caribou in British Columbia-gps.csv", header = TRUE)

# Tidy Data --------------------------------------------------------------------

caribou <- caribou %>% mutate(datetime = as_datetime(timestamp))
caribou <- tidyr::separate(caribou, timestamp, c("date", "time"), sep = " ")
caribou <- tidyr::separate(caribou, date, c("year", "month", "day"), sep = "-")

caribou <- caribou %>% 
  mutate(location.long = as.double(location.long),
         location.lat = as.double(location.lat),
         year = as.numeric(year),
         month = as.numeric(month),
         day = as.numeric(day),
         time = parse_time(time, "%H:%M:%S"))

caribou <- caribou %>% rename(AnimalID = individual.local.identifier)


#selecting year 2014 - 2016 (last accessible years in data set)
caribou <- caribou %>% 
  filter(year == "2014" | year == "2015" | year == "2016")

#adjusting data points along the highway
caribou <- caribou %>%
  filter(location.long > -123 & location.long < - 122)

# Background Map ---------------------------------------------------------------

coordinates <- c(-124, 55, -121.5, 55.75)

query <- coordinates %>%
  opq() 
#%>%
# add_osm_feature("amenity") 

str(query)

BC <- get_stamenmap(coordinates, maptype = "watercolor")

# Highway map layer ------------------------------------------------------------

#loading data from google earth
lst.rd <- readGPX('C://Users//PC//Downloads//Directions_from_57_-122_to_54_-123.gpx')
df <- lst.rd$tracks[[1]][[1]] 


ggplot(df, aes(x = lon, y = lat)) +
  coord_quickmap() +
  geom_point()

ggmap(BC, extent = "device") +
  geom_point(aes(x = lon,
                 y = lat),
             data = df,
             colour = "red4",
             size = .2) +
  labs(x = "Longtitude", y = "Latitude", title = "Caribou movement", caption = "Caribou movement (color indicating individual caribou) in British Columbia, Canada")

# Animation --------------------------------------------------------------------

points <- ggmap(BC) +
  geom_path(aes(x = lon,
                y = lat),
            data = df,
            colour = "red4",
            size = .2) +
  geom_point(data = caribou, 
             aes(x = location.long, y = location.lat, color = AnimalID),
             size = 2.5, show.legend = NA,inherit.aes = FALSE) +
  geom_text(aes(x = -121.9, y = 55.688), label = "Highway 97", color = "red4") +
  labs(x = "Longtitude", y = "Latitude", title = "Caribou movement", caption = "Caribou movement (color indicating individual caribou) in British Columbia, Canada") +
  theme_minimal() +
  theme(legend.position = "none") +
  transition_time(datetime) +
  labs(subtitle = "Datetime: {frame_time}") +
  shadow_wake(wake_length = 0.1, alpha = FALSE) 

animate(points, renderer = gifski_renderer(), duration = 25, fps = 8)

# Save animation ---------------------------------------------------------------

anim_a + exit_shrink()
anim_save("Caribou.gif")

# Static Map -------------------------------------------------------------------

ggmap(BC, extent = "device") +
  geom_path(aes(x = lon,
                y = lat),
            data = df,
            colour = "red4",
            size = .2) +
  geom_point(data = caribou, 
             aes(x = location.long, y = location.lat, color = AnimalID),
             size = 1, show.legend = NA,inherit.aes = FALSE) +
  geom_path(data = caribou, aes(x = location.long, y = location.lat, color = AnimalID)) +
  labs(x = "Longtitude", y = "Latitude") +
  theme(legend.position = "bottom")

# Plotting wildlife crossing ---------------------------------------------------

individual_crossing <- function(d) {
  ggmap(BC, extent = "device") +
    geom_path(aes(x = lon,
                  y = lat),
              data = df,
              colour = "red4",
              size = .2) +
    geom_point(data = d, 
               aes(x = location.long, y = location.lat, color = AnimalID),
               size = 1, show.legend = NA,inherit.aes = FALSE) +
    geom_path(data = d, aes(x = location.long, y = location.lat, color = AnimalID)) +
    labs(x = "Longtitude", y = "Latitude") +
    theme(legend.position = "bottom") +
    facet_wrap(vars(AnimalID)) +
    labs(title = "Individual Crossing")
}

individual_crossing(caribou)


