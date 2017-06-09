                                        ############ File explanation ###########                                               This file creates straight lines between nodal cities and calculates the distances of districts from the lines. The file saves over the districtDistances file and changes to this file would require to be reflected in the final version of the dataset. The subsequent script file is run at the end of this to make sure that the final file is updated.                                                        #########################################
library(tidyverse); library(maptools); library(rgeos); library(geosphere); library(rgdal)
rm(list = ls())
setwd("~/Documents/Current WB Projects/Infra Corridor")

## Load the district data and the spatial data on district centres
load("data/Shape Files/districtDistances.RDA")
load("data/Shape Files/districtCentreShape.RDA")

## Function to create nodes
createLineObject <- function(districtNames) {
        filter(districtDistances, district %in% districtNames) %>% 
                dplyr::select(long, lat) %>%
                Line()
}

##GQ Highway nodes coordinate
delhiMumbai <- createLineObject(c("New Delhi", "Mumbai"))
mumbaiBangalore <- createLineObject(c("Mumbai", "Bangalore"))
bangaloreChennai <- createLineObject(c("Bangalore", "Chennai"))
chennaiPrakasam <- createLineObject(c("Chennai", "Prakasam"))
prakasamCalcutta <- createLineObject(c("Prakasam", "Kolkata"))
calcuttaDelhi <- createLineObject(c("Kolkata", "New Delhi"))

gqStraightLines <- Lines(list(delhiMumbai, mumbaiBangalore, bangaloreChennai, chennaiPrakasam, prakasamCalcutta, calcuttaDelhi), "gq")
gqStraightLines <- SpatialLines(list(gqStraightLines))
proj4string(gqStraightLines) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

## NSEW highway coordinates
jalandharDelhi <- createLineObject(c("Jalandhar", "New Delhi")) #Called Gurdaspur in the data (new district not reflected in the spatial data)
delhiJhansi <- createLineObject(c("New Delhi", "Jhansi"))
yavatmalSalem<- createLineObject(c("Yavatmal", "Salem"))
salemCochin <- createLineObject(c("Salem", "Ernakulam"))
salemKanniyakumari <- createLineObject(c("Salem", "Kanniyakumari"))

porbandarJhansi <- createLineObject(c("Porbandar", "Jhansi")) ## Siliguri spans between darjeeling and jalpaiguri, chose jalpaiguri
#jhansiSiliguri <- createLineObject(c("Jhansi", "Jalpaiguri")) ## Siliguri spans between darjeeling and jalpaiguri, chose jalpaiguri


nsewStraightLines <- Lines(list(jalandharDelhi, delhiJhansi, yavatmalSalem, salemCochin, salemKanniyakumari, porbandarJhansi), "nsew")
nsewStraightLines <- SpatialLines(list(nsewStraightLines))
proj4string(nsewStraightLines) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")


##Calculate the distance from gq straight lines
## calculate the distance from the GQ
gqStraightDistance <- suppressWarnings(dist2Line(districtCentresShape, gqStraightLines))
##Add to distric data
districtDistances$gqStraightDistance <- gqStraightDistance[,1]/1000

##Calculate the distance from nsew straight lines
## calculate the distance from the GQ
nsewStraightDistance <- suppressWarnings(dist2Line(districtCentresShape, nsewStraightLines))
##Add to distric data
districtDistances$nsewStraightDistance <- nsewStraightDistance[,1]/1000

save(districtDistances, file = "data/Shape Files/districtDistances.RDA")

##Plots
png(file = "Results/figures/gqToDistrictStraightLine.png", height = 800, width = 600, res = 100)
plot(gqStraightLines)
points(districtCentresShape, pch = 20, col = 'blue', cex = 0.6)
points(gqStraightDistance[,2], gqStraightDistance[,3], pch = 20, cex = 0.3, col = 'red')
for (i in 1:nrow(gqStraightDistance)) lines(gcIntermediate(districtDistances[i,4:5], gqStraightDistance[i,2:3], 20), lwd=0.8, col='green')
dev.off()

png(file = "Results/figures/nsewToDistrictStraightLine.png", height = 800, width = 600, res = 100)
plot(nsewStraightLines)
points(districtCentresShape, pch = 20, col = 'blue', cex = 0.6)
points(nsewStraightDistance[,2], nsewStraightDistance[,3], pch = 20, cex = 0.3, col = 'red')
for (i in 1:nrow(nsewStraightDistance)) lines(gcIntermediate(districtDistances[i,4:5], nsewStraightDistance[i,2:3], 20), lwd=0.8, col='green')
dev.off()

