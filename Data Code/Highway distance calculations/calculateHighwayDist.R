                                        ############ File explanation ###########                                               This file takes a long time to run! It calculates the distance of district centers from the GQ and NSEW highways. This file saves over the district data file, so it runs all the subsequent scripts at the end.                                                                    #########################################
library(tidyverse); library(maptools); library(rgeos); library(geosphere); library(rgdal)
rm(list = ls())
setwd("~/Documents/Current WB Projects/Infra Corridor")

## Load all the shape files and convert the NSEW shapefile to a lat/long projection
indiaShape <- readShapeSpatial("data/Shape Files/SouthAsiaBoundaries/All/India_L2_Administrative_Boundaries.shp", proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs "))
gqShape <- readShapeLines("data/Shape Files/GQ/GQ_Highway.shp", proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs "))
load("data/Shape Files/nsewComplete.RDA")
nsewComplete <- rGdal::spTransform(nsewComplete, CRS(proj4string(gqShape)))

## Calculate the centre of district (the values were crosschecked summary(subset(indiaShape, L2_NAME == 'Mumbai')))
districtCentresShape <- gCentroid(indiaShape, byid = T)

save(districtCentresShape, file = "data/Shape Files/districtCentreShape.RDA") ## For use in other scripts

# Create district data
districtDistances <- as_tibble(indiaShape@data) %>%
        dplyr::select(ID, L1_NAME, L2_NAME) %>%
        cbind(districtCentresShape@coords) %>% 
        as_tibble()
colnames(districtDistances) <- c("id", "state", "district", "long", "lat")

## calculate the distance from the GQ
gqDistance <- suppressWarnings(dist2Line(districtCentresShape, gqShape))
##Add to distric data
districtDistances$gqDistance <- gqDistance[,1]/1000

## calculate the distance from the NSEW
nsewDistance <- suppressWarnings(dist2Line(districtCentresShape, nsewComplete))
##Add to distric data
districtDistances$nsewDistance <- nsewDistance[,1]/1000

## Avoid running this file as far possible since the distance calculations take a lot of time
save(districtDistances, file = "data/Shape Files/districtDistances.RDA")

png(file = "Results/figures/gqToDistric.png", height = 800, width = 600, res = 100)
plot(gqShape)
points(districtCentresShape, pch = 20, col = 'blue', cex = 0.6)
points(gqDistance[,2], gqDistance[,3], pch = 20, cex = 0.3, col = 'red')
for (i in 1:nrow(gqDistance)) lines(gcIntermediate(districtDistances[i,4:5], gqDistance[i,2:3], 20), lwd=0.8, col='green')
dev.off()

png(file = "Results/figures/nsewToDistric.png", height = 800, width = 600, res = 100)
plot(nsewComplete)
points(districtCentresShape, pch = 20, col = 'blue', cex = 0.6)
points(nsewDistance[,2], nsewDistance[,3], pch = 20, cex = 0.3, col = 'red')
for (i in 1:nrow(nsewDistance)) lines(gcIntermediate(districtDistances[i,4:5], nsewDistance[i,2:3], 20), lwd=0.8, col='green')
dev.off()

