library(tidyverse); library(haven)
rm(list = ls())
setwd("~/Documents/Current WB Projects/Infra Corridor")

## Load the district correspondence data
load("data/1 Cleaned files for analysis/districtCorrespondence.RDA")

##Final Matching
dsCorresp <- read_csv("data/DS1 Names Matching/ds1DistCorresp.csv")

dsCorresp <- left_join(dsCorresp, districtCorrespondence, by = "spatialId") %>% 
        select(distCode, spatialId, finalId = finalId.x, distName, spatialState, spatialDistrict, nss2001State, nss2001District, nss2010State, nss2010District, Note) %>% 
        arrange(spatialState, spatialDistrict)
write_dta(dsCorresp, "data/DS1 Names Matching/DS1Correspondence.dta")
write_csv(dsCorresp, "data/DS1 Names Matching/DS1Correspondence.csv")

nonMatch <- filter(dsCorresp, finalId.x != finalId.y)

## Load the raw names
rawDistNames <- read_csv("data/DS1 Names Matching/rawDistNames.csv")

##Rough matches with district correspondence names
rawDistNames <- left_join(rawDistNames, districtCorrespondence, by = c("distName" = "spatialDistrict"))



duplicateRows <- rawDistNames %>% 
        filter(duplicated(distName))