                                        ############ File explanation ###########                                               This file calculates the intersection of points from the nsew completion file and the nsew shapelines. The goal is to create a new nsew shape lines dataset that only includes portions that were completed by 2011                                                                  #########################################
library(tidyverse); library(maptools); library(rgeos); library(geosphere); library(rgdal); library(raster); library(foreign); library(readstata13)
rm(list = ls())
setwd("~/Documents/Current WB Projects/Infra Corridor")

## Load the NSEW shape file
nsewShape <- readShapeLines("data/Shape Files/NS EW/NS_EW.shp", proj4string = CRS("+proj=eqdc +lat_0=-15 +lon_0=125 +lat_1=7 +lat_2=-32 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs "))

## Convert projection to lat/lon from UTM
nsewShape <- spTransform(nsewShape, CRS("+proj=longlat +datum=WGS84"))

## Load the nsew points data from
nsewPoints <- read_csv("data/Shape Files/nsewPoints.csv")

## Create a spatial points object of all the starting points
nsewFromPoints <- nsewPoints %>% 
        dplyr::select(from) %>% 
        separate(from, c("lon", "lat"), sep = ",") %>% 
        mutate_all(as.numeric) %>% 
        SpatialPoints()

proj4string(nsewFromPoints) <- proj4string(nsewShape)

## Create a spatial points object of all the end points
nsewToPoints <- nsewPoints %>% 
        dplyr::select(to) %>% 
        separate(to, c("lon", "lat"), sep = ",") %>% 
        mutate_all(as.numeric) %>% 
        SpatialPoints()
proj4string(nsewToPoints) <- proj4string(nsewShape)

## Calculate the distance matrix of the from points to the nsew
fromDistance <- suppressWarnings(dist2Line(nsewFromPoints, nsewShape))
toDistance <- suppressWarnings(dist2Line(nsewToPoints, nsewShape))

## Use the points of intersection in the distance matrix to outline a bounding box and use that to clip line segments in the nsew highway spatial lines

for(i in 1:length(nsewFromPoints)){
        ## Create the line segments and calculate bounding boxes
        fromToLine <- Line(rbind(c(fromDistance[i, 2], fromDistance[i, 3]), c(toDistance[i, 2], toDistance[i, 3])))
        bb <- bbox(fromToLine)
        
        ## Create a temporary bounding box polygon to cut the nsew
        temp_poly <- as(extent(as.vector(t(bb))), "SpatialPolygons")
        proj4string(temp_poly) <- proj4string(nsewShape)
        
        ## Clip the nsew shape line with the bounding box polygon
        tempClip <- gIntersection(nsewShape, temp_poly)
        proj4string(tempClip) <- proj4string(nsewShape)
        
        ## if it is the first one
        if(i == 1) {
                nsewComplete <- tempClip
        } else if(class(tempClip) == "SpatialCollections"){ ## Sometimes the output of gintersection is a spatial collection of which we only need the line object
                nsewComplete <- gUnion(nsewComplete, tempClip@lineobj)        
        } else {
                nsewComplete <- gUnion(nsewComplete, tempClip)
        }
}

save(nsewComplete, file = "data/Shape Files/nsewComplete.RDA")
