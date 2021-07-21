library(shiny)
library(tidyverse)
library(rnaturalearth)
library(sf)
library(albersusa)


map <- usa_sf()
parks <- st_read("./ne_10m_parks_and_protected_lands", layer = "ne_10m_parks_and_protected_lands_area") %>% select(-note)
smallparks <- st_read("./ne_10m_parks_and_protected_lands", layer = "ne_10m_parks_and_protected_lands_point")
longparks <- st_read("./ne_10m_parks_and_protected_lands", layer = "ne_10m_parks_and_protected_lands_line") %>% select(-note)
allcities <- st_read("./ne_10m_populated_places_simple") %>% filter(adm0_a3 == "USA")
allparks <- bind_rows(parks, smallparks, longparks)

allcities$comb <- paste0(allcities$name, ", ",allcities$adm1name)

shinyUI(fluidPage(

    titlePanel("USA Travel Map Generator"),

    sidebarLayout(
        sidebarPanel(
            selectInput("parks", "Add Parks...", width = NULL, choices = allparks$name, multiple = TRUE),
            selectInput("cities", "Add Cities...", width = NULL, choices = allcities$comb, multiple = TRUE),
            selectInput("states", "Add States...", width = NULL, choices = map$name, multiple = TRUE),
            downloadButton('downloadmap', 'Download Map')
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("map")
        )
    )
))
