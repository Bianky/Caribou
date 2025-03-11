# The Case of Caribou Movement
## *Restrictions of Caribou Migration by Road Construction*
## Bianka Fábryová
### 21.5. 2021



```{r setup, include=FALSE}
library(tidyverse)
library(lubridate)
library(osmdata)
library(ggmap)
library(plotKML)
library(gganimate)
library(tools)
```

 ![](https://images.rove.me/w_1920,q_85/clao0dacen0d1afqsiwj/alaska-caribou-spring-migration.jpg)



  In today’s world of consistently increasing human population, it is becoming ever more important to focus on our coexistence with wildlife. As a result of the significant global population growth, there is a raise in demand for human habitation developments which consequentially, as they expand to natural areas, are one of the main threats to biodiversity. This process is referred to as habitat fragmentation, a reduction of wildlife habitat into smaller, distant segments (Crooks, et al., 2017). Thus, the population size of inhabiting species declines, possibly resulting in a collapse of ecosystem and a probable local extinction. 
  One of the main causes for habitat fragmentation is road construction, necessary for economic development of a country. Infrastructure construction in natural environment has numerous negative effects on the biodiversity, including population size reductions due to decreased quality of habitat as well as increase in mortality as a result of attempts to cross a road, and declines in colonization of patches (Sijtsma, et al., 2020). All these possible outcomes are not harmful only to wild biodiversity, but there are a threat to us as well, as humans are dependent on ecosystems.
  Species that are significantly influenced by habitat fragmentation are large mammals which naturally migrate extensive distances. Caribou, from the taxon *Rangifer tarandus*, is the world’s most travelled terrestrial non-human animal (Plante, et al., 2018). It is native to Northern hemisphere inhabiting tundra and boreal forest biomes. Therefore, in my study I decided to visualize the possible impacts of habit segmentation on caribou movement regarding a question: *Does infrastructure restrict caribou movement in British Columbia, Canada?*.

# Caribou Movement

  I collected a caribou tracking data set from BC Ministri of environment (2014) and tidied it in a suitable way. Furthermore, I developed a map of British Columbia and added a top layer of highway 97 with data points collected from google maps. As a data analysis I chose to perform an animation to observe whether caribou cross the highway. 

``` r
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
```

  For a more precise visualization, I made a static map of caribou movement and eventually a facet map with one caribou per individual map. In
both visualizations we can see that only two caribou from 12 crossed the highway even though they were nearby.

```{r echo=FALSE}
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

```



Despite the negative impacts of infrastructure in natural environment there are approaches to mitigate these destructive effects on biodiversity. One of them is a construction of wildlife crossings, as seen on a picture below.



 ![](C:/Users/PC/Desktop/Caribou/Ecoduct image.jpg)


# Elk Movement


Wildlife overpasses or also known as Eco ducts are large bridges covered with vegetation which enable wildlife to freely cross through the highway lowering spatial restrictions and risk of being hit by the car. With that being said, I searched for Eco ducts in Canada through google maps, collected data of their coordinates and questioned whether there can be a correlation of increased number of animals passing through highway with higher number of Eco ducts. Moreover, I made a second animation based on elk data set and inspected whether there is an animal movement crossing the coordinates of Eco ducts. 

```{r, echo=FALSE,warning=FALSE,message=FALSE,error=FALSE, fig.keep='all'}
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

```

The results were not significant and there was minimal movement through Eco ducts coordinates. Lack of data is a significant limitation which needs to be considered.


# Conclusion

In conclusion, biodiversity is essential for human survival and it is necessary to search for the most suitable approaches how to coexist with wildlife. However, to act we first need to know the impact of any issue, such as habitat fragmentation, on wildlife. In that regard, R is an excellent tool to use to analyze and visualize the impacts of human habitat development on biodiversity. Moreover, animation of animal movement is eye catching, drawing attention of public as well as easily digestible. In addition, it enables a simple analysis of altered wildlife movement due to human development. With that being said, I believe that animation data analysis can have a significant influence on people’s effort to work toward a coexistance with the wildlife.


## List of References

BC Ministry of Environment (2014) Science update for the South Peace Northern Caribou (Rangifer tarandus caribou pop. 15) in British Columbia. Victoria, BC. 43 p. https://www2.gov.bc.ca/assets/gov/environment/plants-animals-and-ecosystems/wildlife-wildlifehabitat/caribou/science_update_final_from_web_jan_2014.pdf url:https://www2.gov.bc.ca/assets/gov/environment/plants-animals-and-ecosystems/wildlife-wildlife-habitat/caribou/science_update_final_from_web_jan_2014.pdf

Crooks, K. R., Burdett, C. L., Theobald, D. M., King, S. R., Di Marco, M., Rondinini, C., & Boitani, L. (2017). Quantification of habitat fragmentation reveals extinction risk in terrestrial mammals. Proceedings of the national Academy of Sciences, 114(29), 7635-7640.

Sijtsma, F. J., van der Veen, E., van Hinsberg, A., Pouwels, R., Bekker, R., van Dijk, R. E., ... & Wymenga, E. (2020). Ecological impact and cost-effectiveness of wildlife crossings in a highly fragmented landscape: a multi-method approach. Landscape Ecology, 35, 1701-1720.

Plante, S., Dussault, C., Richard, J. H., & Côté, S. D. (2018). Human disturbance effects and cumulative habitat loss in endangered migratory caribou. Biological Conservation, 224, 129-143. 
