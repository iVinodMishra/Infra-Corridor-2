                                        ############ File explanation ###########                                               This file calculates the distance between districts and nodes and marks those that are close to nodes. It also identifies districts that might need to be taken out of the analysis (i.e. islands and those in states India/China)                                               #########################################
library(tidyverse); library(geosphere); library(stringr)
rm(list = ls())
setwd("~/Documents/Current WB Projects/Infra Corridor")

## Load the district data
load("data/Shape Files/districtDistances.RDA")
load("data/Shape Files/districtCentreShape.RDA")

#The first task was to mark districts based on their distances from the GQ and NSEW into the following categories: Nodal, 0-40, 40-100 and > 100. After this the rest of the datasets are added to final data.

## The first task is to mark the following districts as nodal for the GQ (extended from Arti, paper)                     Delhi (all nine districts), Mumbai, Chennai, and Kolkata, Gurgaon, Faridabad, Ghaziabad, and NOIDA                       (gautam budh nagar), Thane, Mumbai Suburban. Bangalore is not included in this iteration.

gqNodalDistrictFinalIds <- c("3_7_95_0", "3_7_93_0", "3_7_94_0", "3_7_91_0", "3_7_92_0", "3_7_90_0", "3_7_98_0", "3_7_97_0", "3_7_96_0", "3_6_86_0", "3_6_88_0", "3_9_141_0", "3_9_140_0", "3_27_519_0", "3_27_518_0", "3_27_517_0", "3_33_603_0", "3_19_342_0")

## nodal districts for NSEW (extended from Arti paper) Delhi(all nine districts),NOIDA, Gurgaon,                         Faridabad, Ghaziabad,Hyderabad, and Bangalore
nsewNodalDistrictFinalIds <- c("3_7_95_0", "3_7_93_0", "3_7_94_0", "3_7_91_0", "3_7_92_0", "3_7_90_0", "3_7_98_0", "3_7_97_0", "3_7_96_0", "3_6_86_0", "3_6_88_0", "3_9_141_0", "3_9_140_0", "3_29_572_0", "3_28_536_0")

##Mark the distance types
districtDistances <- districtDistances %>% 
        mutate(gqDistType = ifelse(finalId %in% gqNodalDistrictFinalIds, "nodal", ifelse(distFromGQ > 0 & distFromGQ <= 40, "0-40", ifelse(distFromGQ > 40 & distFromGQ <= 100, "40-100", "> 100")))) %>% 
        mutate(nsewDistType = ifelse(finalId %in% nsewNodalDistrictFinalIds, "nodal", ifelse(distFromNSEW > 0 & distFromNSEW <= 40, "0-40", ifelse(distFromNSEW > 40 & distFromNSEW <= 100, "40-100", "> 100"))))


# 
# 
# ## Collection of nodal points (does not include the kink Prakasam or yavatmal)
# nodalPoints <- c("New Delhi", "Mumbai", "Bangalore", "Chennai", "Kolkata", "Jalandhar","Jhansi", "Salem", "Ernakulam", "Kanniyakumari", "Porbandar", "Jalpaiguri")
# nodalPointsCoord <- districtDistances %>% 
#         filter(district %in% nodalPoints) %>% 
#         dplyr::select(long, lat)
# 
# ## Function to calculate the shortest distance between a single point and a collection of points
# calcDist <- function(p) {
#         dist <- numeric()
#         for(i in 1:length(nodalPoints)){
#                 dist[i] <- distGeo(p, nodalPointsCoord[i, 1:2])
#         }
#         return(min(dist, na.rm = T)/1000 < 40) #return a T/F based on distance
# }
# 
# ## Create a district type variable based on distance from node
# districtType <- character()
# for(i in 1:nrow(districtDistances)) {
#         if(calcDist(districtDistances[i, 4:5])){
#                 districtType[i] <- "nodal"
#         } else {
#                 districtType[i] <- "not nodal"
#         }
# }
# districtDistances$districtType <- districtType

## Identify island and India/China districts to exclude from the analysis
# districtDistances <- districtDistances %>%
#         rowwise() %>%
#         mutate(districtType = ifelse(state %in% c("Andaman & Nicobar Islands", "Lakshadweep"),"island", districtType)) %>%
#         mutate(districtType = ifelse(str_detect(state, "India/China"), "India/China", districtType))


save(districtDistances, file = "data/1 Cleaned files for analysis/districtDistances.RDA")

## The name long is reserved in stata, so I am converting that to lon
colnames(districtDistances)[4] <- "lon"
library(haven)
write_dta(districtDistances, path = "data/1 Cleaned files for analysis/districtDistances.dta", version = 12)
rm(list = ls())

