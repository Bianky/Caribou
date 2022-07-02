# Packages used ----------------------------------------------------------------

library(tidyverse)
library(RColorBrewer)
library(xts)
library(rgdal)
library(osrm)
library(lubridate)
library(plotKML)
library(gganimate)
library(transformr)

# Load Data --------------------------------------------------------------------

elk <- read.csv("C:\\Users\\PC\\Downloads\\Ya Ha Tinda elk project, Banff National Park, 2001-2020 (females).csv", header = TRUE)

# Tidy Data --------------------------------------------------------------------

elk <- elk %>% mutate(datetime = as_datetime(timestamp))
elk <- tidyr::separate(elk, timestamp, c("date", "time"), sep = " ")
elk <- tidyr::separate(elk, date, c("year", "month", "day"), sep = "-")

elk <- elk %>% 
  mutate(location.long = as.double(location.long),
         location.lat = as.double(location.lat),
         year = as.numeric(year),
         month = as.numeric(month),
         day = as.numeric(day),
         time = parse_time(time, "%H:%M:%S"))

# selecting years 2018, 2019, 2020 (last accessible years in data set)
elk <- elk %>% 
  filter(year == "2018" | year == "2019" | year == "2020")

elk <- elk %>% rename(AnimalID = individual.local.identifier)

# Bacground map ----------------------------------------------------------------

coordinates <- c(-117, 51, -115, 52)

query <- coordinates %>%
  opq() %>%
  add_osm_feature("amenity") 

str(query)

Alberta <- get_stamenmap(coordinates, maptype = "watercolor")

# Highway map layer ------------------------------------------------------------

lst.rd <- readGPX('C://Users//PC//Downloads//Directions_from_Ozada_AB_Canada_to_Saskatchewan_River_Crossing_AB_Canada.gpx')
df <- lst.rd$tracks[[1]][[1]] 

ggplot(df, aes(x = lon, y = lat)) +
  coord_quickmap() +
  geom_point()

ggmap(Alberta, extent = "device") +
  geom_point(aes(x = lon,
                 y = lat),
             data = df,
             colour = "red4",
             size = .2) 

# Ecoduct Data frame -----------------------------------------------------------
# data gathered from google maps

ecoduct <- data.frame("ecoduct" = c(1:6),
                      "lon" = c(-115.71, -115.80, -115.96, -116.01, -116.11, -116.19),
                      "lat" = c(51.16, 51.22, 51.27, 51.30, 51.37, 51.43))

# Animation --------------------------------------------------------------------

points <- ggmap(Alberta) +
  geom_point(aes(x = lon,
                 y = lat),
             data = df,
             colour = "red4",
             size = .2) +
  geom_point(data = elk, 
             aes(x = location.long, y = location.lat, color = AnimalID),
             size = 2.5, show.legend = NA,inherit.aes = FALSE) +
  geom_point(data = ecoduct, aes(lon, lat), size = 5, color = "green4") + 
  geom_text(aes(x = -116.5, y = 51.89), label = "Highway 93", color = "red4") +
  geom_text(aes(x = -116.35, y = 51.40), label = "Ecoducts", color = "green4") +
  labs(x = "Longtitude", y = "Latitude", title = "Elk movement", caption = "Elk movement (color indicating individual elk) in Alberta, Canada") +
  theme_minimal() +
  theme(legend.position = "none") +
  transition_time(datetime) +
  labs(subtitle = "Datetime: {frame_time}") +
  shadow_wake(wake_length = 0.1, alpha = FALSE)

animate(points, renderer = gifski_renderer(), duration = 25, fps = 8)

# Save animation ---------------------------------------------------------------

anim_a + exit_shrink()
anim_save("Elk.gif")

# Plotting wildlife crossing ---------------------------------------------------

individual_crossing(elk)
