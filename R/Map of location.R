library(leaflet)


leaflet(highway) %>% 
  addProviderTiles("Stamen.Terrain", group = "OSM") %>% 
  addPolylines() %>% 
  addCircleMarkers(lng = -123, lat = 55.9, radius = 250, fill = FALSE)