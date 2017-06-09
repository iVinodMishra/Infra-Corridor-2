                                        ############ File explanation ###########                                               This file uses the distance matrix to calculate an accesibility index that is used to check the relationship with the distances from GQ. The hypothesis being that the accesibility should improve as the highways are built.                                                       #########################################
## Things to discuss
        ## Only 300 of the districts of the total 648 are present in the dataset (most of them are missing, while others have been split and cannot be merged with our district dataset)
        ## 5 districts have a distance measure of zero for districts other than themselves (these were taken out of the analysis, without access to the underlying data it is not possible to determine if the entire series for these disrticts are wrong)
        ## THe key metropolitan cities like Delhi, Mumbai, Chennai and Madras are missing from the distance dataset, so we only have 4 5 million plus cities in the data
                                        

## 1. Run a regression to check relationship between change in accebility index for origin districts and the straight line to the actual GQ and nsew. (use 1996 to 2011)
        ## 648 X 648
## 2. Accessibility index (sum (pop) / dist)
        ## Do it for all districts (crude sum of all pop)
        ## Make list of million plus cities
        ## identify districts
        ## calculate accessiblility index using bilateral travel district using the population of the city (not the district)
        ## repeat with more stringent 5 million cut-off
rm(list = ls())
library(tidyverse); library(haven); library(stringr); library(stargazer)
setwd("~/Documents/Current WB Projects/Infra Corridor")

## LOAD THE DATA
load('data/1 Cleaned files for analysis/districtDistances.RDA')

## Load the district distances data
atkinsDistance <- read_dta("data/Atkins Replication Files/district_distance_dist5.dta")

## MATCH THE DISTRICT NAMES IN BOTH THE DATASETS AND REPLACE WITH DISTRICT IDS

# get the district names
atkinsDistrictNames <- sort(unique(c(atkinsDistance$district_orig, atkinsDistance$district_dest)))## Atkins names
dataDistricNames <- unique(districtDistances$district) ## the list of district names from data

# match the string template used in the district data
for(i in 1:length(atkinsDistrictNames)){ ## Matching the string template of the district names in data
        atkinsDistrictNames[i] <- paste(str_sub(atkinsDistrictNames[i], 1, 1), str_to_lower(str_sub(atkinsDistrictNames[i], 2)), sep = "")
}

# create a name match dataset
nameMatch <- tibble(atkinsName = atkinsDistrictNames, sameAsData = atkinsDistrictNames %in% dataDistricNames)
nameMatch <- left_join(nameMatch, districtDistances, by = c("atkinsName" = "district")) ## there are two names that are duplicated when joining

# fix the duplicate names (two names are repeated in the list)
duplicateNames <- nameMatch[duplicated(nameMatch$atkinsName), ]

## Remove the duplicated districts (Bijapur is from Karnataka and Pratapgarh is from uttar pradesh)
nameMatch <- nameMatch %>% 
        filter(!(state == "Chhattisgarh" & atkinsName == "Bijapur")) %>% 
        filter(!(state == "Rajasthan" & atkinsName == "Pratapgarh")) %>% 
        dplyr::select(1:3) ## get the ids of those that match

## identify those that did not match
nonMatch <- nameMatch %>% ## list of names that don't match
        filter(!sameAsData) %>% 
        dplyr::select(atkinsName)

nonMatchCorresp <- read_csv("data/Atkins Replication Files/nameMatch.csv") ## load the manually created correspondence

## get the correct names to use for extracting ids
nonMatch <- left_join(nonMatch, nonMatchCorresp) ## merge the district data names and ids based on correspondence

## separate the ones that did not match due same names
idMatch <- nonMatch %>% ## those that did not match names but matched ids (i.e. two districts with the same names)
        filter(!is.na(id)) %>% 
        dplyr::select(atkinsName, id)

## find the corresponding ids for name match        
nonMatch <- nonMatch %>% 
        filter(!is.na(dataName)) %>% ## remove those that could not be matched manually
        dplyr::select(atkinsName, dataName)

nonMatch <- left_join(nonMatch, districtDistances, by = c("dataName" = "district")) %>%
        dplyr::select(1, 3) %>% ## get the ids of those that matched
        rbind(idMatch)

nameMatch <- nameMatch %>% 
        filter(sameAsData) %>% ## remove the non-matches
        dplyr::select(atkinsName, id) %>% 
        rbind(nonMatch) %>% 
        mutate(atkinsName = str_to_upper(atkinsName)) %>%  ## converting back to original format
        arrange(atkinsName)

## match the district names to ids
originNames <- tibble(districtName = as.character(atkinsDistance$district_orig))
destNames <- tibble(districtName = atkinsDistance$district_dest)

originNames <- left_join(originNames, nameMatch, by = c("districtName" = "atkinsName"))
destNames <- left_join(destNames, nameMatch, by = c("districtName" = "atkinsName"))

## replace the district names in the distances dataset
atkinsDistance$district_orig <- originNames$id
atkinsDistance$district_dest <- destNames$id

rm(list = setdiff(ls(), c("atkinsDistance", "districtDistances")))

## remove the observations with missing district ids (the ones that could not be matched)
atkinsDistance <- atkinsDistance %>% 
        filter(!is.na(district_dest) & !is.na(district_orig)) %>% 
        dplyr::select(district_orig, district_dest, distance_1996, distance_2011)


## BASIC REGRESSIONS:
        #deltaTime(i, j) ~ GQ(i) + NSEW (i) + GQ(j) + NSEW(j)

## adding the data on distance to gq and nsew for origin districts
atkinsDistance <- left_join(atkinsDistance, districtDistances, by = c("district_orig" = "id")) %>% 
        mutate(deltaTime = distance_2011 - distance_1996) %>% 
        dplyr::select(districtOrigin = district_orig, districtDest = district_dest, distance1996 = distance_1996, distance2011 = distance_2011,deltaTime, gqOrigin = gqDistance, nsewOrgin = nsewDistance)

## Adding the data on gq and nsew distance for dest districts
atkinsDistance <- left_join(atkinsDistance, districtDistances, by = c("districtDest" = "id")) %>% 
        dplyr::select(1:7, gqDest = gqDistance, nsewDest = nsewDistance)

model1 <- atkinsDistance %>% 
        lm(deltaTime ~ gqOrigin + nsewOrgin, .)

model2 <- atkinsDistance %>% 
        lm(deltaTime ~ gqOrigin + nsewOrgin + gqDest + nsewDest, .)

stargazer(model1, model2, dep.var.caption = "Change in Time taken (2011 - 1996)", out = "Results/Tables/Table1.html")

##Summary stats of variables used

## THE BASIC CALCULATION OF ACCESSIBILITY INDEX

# load the spatial dataset for population data
spatialData <- read_csv('data/Spatial Database/SpatialData.csv')

## keep only the total numbers (instead of rural/urban) and select vars of interest
spatialData <- filter(spatialData, geography == "Total") %>%
        dplyr::select(id, spatial_data_yr, pop) %>% 
        arrange(id, spatial_data_yr) %>%
        spread(spatial_data_yr, pop)
colnames(spatialData) <- c('id', 'pop2001', 'pop2011')

## Add the population data to atkins data
atkinsDistance <- left_join(atkinsDistance, spatialData, by = c('districtDest' = 'id'))

##Calculate the accesibility index
basicAccesibility <- atkinsDistance %>% 
        filter(deltaTime != 0) %>% 
        mutate(accessibility1996 = pop2001/distance1996, accessibility2011 = pop2011/distance2011) %>% 
        group_by(districtOrigin) %>% 
        summarise(accessibilityIndex1996 = sum(accessibility1996), accessibilityIndex2011 = sum(accessibility2011), gqOrigin = unique(gqOrigin), nsewOrgin = unique(nsewOrgin))

## REGRESSION WITH ACCESIBILITY

## Calculating the delta accessibility
basicAccesibility <- basicAccesibility %>% 
        mutate(deltaAccess = accessibilityIndex2011 - accessibilityIndex1996)

model1 <- basicAccesibility %>% 
        lm(deltaAccess ~ gqOrigin + nsewOrgin, .)

stargazer(model1, dep.var.caption = "Change in Accessiility (2011 - 1996)", out = "Results/Tables/Table2.html")


## CALCULATE THE ACCESIBILITY INDEX FOR MILLION PLUS CITIES

## read in the data
millionPlusCities <- read_csv("data/Atkins Replication Files/millionPlusCities.csv")
millionPlusCities <- millionPlusCities %>% 
        na.omit()

millionPlusCities <- millionPlusCities %>% 
        mutate(matchingIds = district %in% unique(atkinsDistance$districtDest))

#tempList <- millionPlusCities$district[millionPlusCities$district %in% unique(atkinsDistance$district_dest)]
## only keep the districts in the million plus city file and join the pop data
atkinsDistance <- atkinsDistance %>% 
        dplyr::select(1:4, 6:9)


atkinsDistance <- left_join(atkinsDistance, millionPlusCities, by = c("districtDest" = "district")) %>% 
        na.omit()

## calculate the accessibility index
millionPlusAccesibility <- atkinsDistance %>%
        filter(distance1996 != 0 | distance2011 != 0) %>% 
        mutate(accessibility1996 = pop2001/distance1996, accessibility2011 = pop2011/distance2011) %>% 
        group_by(districtOrigin) %>% 
        summarise(accessibilityIndex1996 = sum(accessibility1996), accessibilityIndex2011 = sum(accessibility2011), gqOrigin = unique(gqOrigin), nsewOrgin = unique(nsewOrgin))



## REGRESSION WITH ACCESIBILITY

## Calculating the delta accessibility
millionPlusAccesibility <- millionPlusAccesibility %>% 
        mutate(deltaAccess = accessibilityIndex2011 - accessibilityIndex1996)

model1 <- millionPlusAccesibility %>% 
        lm(deltaAccess ~ gqOrigin + nsewOrgin, .)

stargazer(model1, dep.var.caption = "Change in Accessiility to Million plus cities (2011 - 1996)", out = "Results/Tables/Table3.html")

