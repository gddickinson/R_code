library(ggplot2)      # For plotting
library(tidycensus)   # For downloading Census data
library(tmap)         # For creating tmap
library(tmaptools)    # For reading and processing spatial data related to tmap
library(dplyr)        # For data wrangling
library(sf)           # For reading, writing and working with spatial objects

# Create shp file
shp <- st_read("C:/Users/g_dic/Dropbox/code/R_code/shiny/censusDataApp/acs_2012_2016_county_us_B27001/acs_2012_2016_county_us_B27001.shp",
               stringsAsFactors = FALSE) %>%
  rename(uninsured_2012 = un_2012,
         uninsured_2016 = un_2016,
         uninsured_diff = unnsrd_) %>%
  mutate(STFIPS = stringr::str_sub(GEOID, 1, 2))


#leaflet

# Filter to Texas and create some additional
# fields for mapping. Since we'll be using
tx <- filter(shp, STFIPS == "48") %>%
  mutate(NAME = stringr::str_remove(NAME, ", Texas"),
         `Insured Adults Ages 18-34, 2012-2016` = case_when(
           uninsured_diff < 0  ~ "Insured population increased",
           uninsured_diff > 0  ~ "Insured population decreased",
           uninsured_diff == 0 ~ "Insured population stayed the same"),
         diff2 = round(abs(uninsured_diff), 1),
         popup = ifelse(uninsured_diff != 0,
                        paste0(`Insured Adults Ages 18-34, 2012-2016`, " by ", diff2, "%"), 
                        `Insured Adults Ages 18-34, 2012-2016`),
         diffrad = as.numeric(cut(diff2, c(0, 5, 10, 20, 30, 45), 
                                  right = FALSE)))

# Remove some unnecessary fields
tx <- select(tx, -c(uninsured_2012, uninsured_2016, uninsured_diff, STFIPS))

# Basemap
carto <- "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}{r}.png"

# Create a "normal" tmap except we'll add  
# the basemap and the `popup.vars` argument.
# The symbol size of the bubbles will be
# based on the data so use our calculated
# field `diffrad` which will apply sizes
# 1 through 5. Sizes can be further adjusted
# using the `scale` argument.
mymap <- tm_basemap(carto) +  
  tm_shape(tx) +
  tm_borders(col = "azure2") +
  tm_bubbles("diffrad", 
             col = "Insured Adults Ages 18-34, 2012-2016", 
             border.col = "white", 
             scale = 1.5,
             style = "fixed",
             palette = c("coral2", "aquamarine3", "gray"),
             popup.vars = c("County: " = "NAME", "Change: " = "popup"))

tmap_leaflet(mymap) #dosen't always load first time...

