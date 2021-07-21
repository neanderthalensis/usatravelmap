library(shiny)
library(rnaturalearth)
library(tidyverse)
library(sf)
library(albersusa)

mapplot <- function(states, visparks, vistown, visstates){
    map <- usa_sf()
    parks <- st_read("./ne_10m_parks_and_protected_lands", layer = "ne_10m_parks_and_protected_lands_area") %>% select(-note)
    smallparks <- st_read("./ne_10m_parks_and_protected_lands", layer = "ne_10m_parks_and_protected_lands_point")
    longparks <- st_read("./ne_10m_parks_and_protected_lands", layer = "ne_10m_parks_and_protected_lands_line") %>% select(-note)
    allcities <- st_read("./ne_10m_populated_places_simple")
    allcities$comb <- paste0(allcities$name, ", ",allcities$adm1name)
    
    
    
    map$visited <- if_else(map$name %in% visstates, TRUE, FALSE)
    
    parks <- filter(parks, name %in% visparks)
    smallparks <- filter(smallparks, name %in% visparks)
    longparks <- filter(longparks, name %in% visparks)
    cities <- filter(allcities, comb %in% vistown)
    
    ggplot() +
        geom_sf(data = map, aes(fill = visited)) +
        geom_sf(data = points_elided_sf(parks), fill = "blue", color = "blue") +
        geom_sf(data = points_elided_sf(smallparks), fill = "blue", color = "blue",size = 3) +
        geom_sf(data = points_elided_sf(longparks), fill = "blue", color = "blue") +
        geom_sf(data = points_elided_sf(cities), color = "red", size = 3) +
        scale_fill_manual(values = c("#f4f4f4","#e8e5e5"), guide = FALSE) +
        theme_void()
}

shinyServer(function(input, output) {
        output$map <- renderPlot({
            mapplot(states, input$parks, input$cities, input$states)
        })
        output$downloadmap <- downloadHandler(
            filename = "usatravelmap.png",
            content = function(file){
                ggsave(file, plot = mapplot(states, input$parks, input$cities, input$states), device = "png")
            }
            
        )
})
