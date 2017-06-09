##Questions to clarify
        ##Some lines have more than one factory (number of factories = 3), line 2
        ## Summary variables

##Load the district correspondence
library(tidyverse); library(haven)
rm(list = ls())
setwd("~/Documents/Current WB Projects/Infra Corridor")
load("data/1 Cleaned files for analysis/districtCorrespondence.RDA")

##CREATE THE ASI DATASET
        #This section uses the ASI dataset. We only keep the records from 2001 and use the multiplier variable to aggregate the values based on the final set of ids. Final Ids trace a correspondence between asi 2010 districts to asi 2001 district using district codes that are in the spatial database. This allows us to link all the datasets together and aggregate them to the 2001 level.

        ##Load the asi data
load("data/1 Cleaned files for analysis/asiData.RDA")

        ##Aggregate the variables of interest by final id
asiSummaryData <- asiData %>% 
        filter(year == 2001) %>% ##Keeping only the start year
        group_by(finalId) %>% ##summarising by the final id var
        summarise(nFactories = sum(mult * x1, na.rm = T), totPersonsEngaged = sum(mult * x8, na.rm = T), totValOutput = sum(mult * x19, na.rm = T))

##CREATE THE SPATIAL DISTANCE DATASET
        #This section creates joins the final ids that are mapped to 2001 ASI master list of districts using the district correpondence file and then aggregates the distances of districts from the GQ and NSEW based on this final list.

        ##Load the dataset
load("data/1 Cleaned files for analysis/districtDistances.RDA")

        ##Converting from factor to character (not a necessary step)
districtDistances <- districtDistances %>% 
        mutate(id = as.character(id), state = as.character(state), district = as.character(district))
        
        ##Joining the final ids and aggregating based on them
districtDistances <- left_join(districtCorrespondence, districtDistances, by = c("spatialId" = "id")) %>% 
        group_by(finalId) %>% ##summarising by the final id vars mapped to 2001
        summarise(state = state[1], district = district[1], distFromGQ = mean(gqDistance), distFromNSEW = mean(nsewDistance), distFromStrGQ = mean(gqStraightDistance), distFromStrNSEW = mean(nsewStraightDistance))

##CREATE THE SPATIAL DATASETS
        #This section does creates three different files. The variables road intensity and number of stations are not recorded for the year 2001 in the spatial database, so we use the 2011 values. The values for urban outcomes like area and population requires us to take the proportion of urban/total, this is created using the spatial dataset that has all the geographies. Finally the rest of the variables at the 'total' geography level are calculated using the spatial total dataset.

        ##Creating a separate 2011 file to use for road intensity and number of stations variables (since those are              missing in 2001)
load("data/1 Cleaned files for analysis/data2011Total.RDA")
spatialTotal2011 <- left_join(districtCorrespondence, data2011Total, by = c("spatialId" = "id")) %>% 
        filter(spatial_data_yr == 2011) %>%
        group_by(finalId) %>% 
        summarise(meanRoadIntensity = mean(road_int_t, na.rm = T), meanStationDensity = mean(station_den_t))

        ##Creating rest of the variables from 2001
load("data/1 Cleaned files for analysis/spatialTotal.RDA")
spatialTotal2001 <- left_join(districtCorrespondence, spatialTotal, by = c("spatialId" = "id")) %>% 
        filter(spatial_data_yr == 2001) %>% 
        group_by(finalId) %>% 
        summarise(distrGDP = mean(gdp, na.rm = T), distrPerCapGDP = mean(gdp_pc, na.rm = T), popTotal = mean(pop, na.rm = T), under7LiteracyRate = mean(edu_lit_7_t, na.rm = T), lightIntensitybyArea = mean(ntl_a, na.rm = T), roughRoads = mean(rough, na.rm = T), nFarmers = mean(emp_fmr_t, na.rm = T), hhBankAccess = mean(bank_t, na.rm = T),  hhElectricitAccess = mean(hh_elec_t, na.rm = T), waterAccess = mean(hh_wtr_t, na.rm = T), sanitationAccess = mean(hh_snt2_t, na.rm = T))

        ##Creating the spatial dataset for urban to pull out urbanization variables
load("data/1 Cleaned files for analysis/spatialAll.RDA")
        ##The within group indexes are used to identify the values at the urban and total geography levels. Each group was checked to see if the number of geographies was 2 (ie. there were no missing records, or rather the data is balanced)
spatialAll2001 <- spatialAll %>% 
        arrange(id, geography) %>% 
        filter(spatial_data_yr == 2001, geography != "Rural") %>% 
        select(id, geography, area, area_bu, area_lit, pop, pop_bu, pop_lit) %>% 
        group_by(id) %>% 
        mutate(areaUbyT = area[2]/area[1], area_buUbyT = area_bu[2]/area_bu[1], area_litUbyT = area_lit[2]/area_lit[1], popUbyT = pop[2]/pop[1], pop_buUbyT = pop_bu[2]/pop_bu[1], pop_litUbyT = pop_lit[2]/pop_lit[1]) %>% 
        filter(geography == "Total") %>% 
        select(id, 9:14)

        ##Merging to aggregate using the final id and using the summarise_if command, the results were compared with the regular summarise + mean commands and they match.
spatialAll2001 <- left_join(districtCorrespondence, spatialAll2001, by = c("spatialId" = "id")) %>% 
        group_by(finalId) %>% 
        summarise_if(is.numeric, mean)


##CREATE THE FINAL DATASET
        #The first task was to mark districts based on their distances from the GQ and NSEW into the following categories: Nodal, 0-40, 40-100 and > 100. After this the rest of the datasets are added to final data.

        ## The first task is to mark the following districts as nodal for the GQ (extended from Arti, paper)                     Delhi (all nine districts), Mumbai, Chennai, and Kolkata, Gurgaon, Faridabad, Ghaziabad, and NOIDA                       (gautam budh nagar), Thane, Mumbai Suburban. Bangalore is not included in this iteration.

gqNodalDistrictFinalIds <- c("3_7_95_0", "3_7_93_0", "3_7_94_0", "3_7_91_0", "3_7_92_0", "3_7_90_0", "3_7_98_0", "3_7_97_0", "3_7_96_0", "3_6_86_0", "3_6_88_0", "3_9_141_0", "3_9_140_0", "3_27_519_0", "3_27_518_0", "3_27_517_0", "3_33_603_0", "3_19_342_0")

        ## nodal districts for NSEW (extended from Arti paper) Delhi(all nine districts),NOIDA, Gurgaon,                         Faridabad, Ghaziabad,Hyderabad, and Bangalore
nsewNodalDistrictFinalIds <- c("3_7_95_0", "3_7_93_0", "3_7_94_0", "3_7_91_0", "3_7_92_0", "3_7_90_0", "3_7_98_0", "3_7_97_0", "3_7_96_0", "3_6_86_0", "3_6_88_0", "3_9_141_0", "3_9_140_0", "3_29_572_0", "3_28_536_0")

        ##Mark the distance types
finalSummaryData <- districtDistances %>% 
        mutate(gqDistType = ifelse(finalId %in% gqNodalDistrictFinalIds, "nodal", ifelse(distFromGQ > 0 & distFromGQ <= 40, "0-40", ifelse(distFromGQ > 40 & distFromGQ <= 100, "40-100", "> 100")))) %>% 
        mutate(nsewDistType = ifelse(finalId %in% nsewNodalDistrictFinalIds, "nodal", ifelse(distFromNSEW > 0 & distFromNSEW <= 40, "0-40", ifelse(distFromNSEW > 40 & distFromNSEW <= 100, "40-100", "> 100"))))

        ##Join the other datasets
finalSummaryData <- left_join(finalSummaryData, asiSummaryData, by = c("finalId")) %>% 
        left_join(., spatialTotal2001, by = "finalId") %>% 
        left_join(., spatialTotal2011, by = "finalId") %>% 
        left_join(., spatialAll2001, by = "finalId")

rm(list = setdiff(ls(), c("finalSummaryData")))

##CREATING THE SUMMARY STAT TABLES
        #For the purpose of readability I have split the different summaries into categories. The custom round mean function is to summarise variables within distance groups.

        ##Creating the helper table and function
distTemplate <- tibble(districtType = c("nodal", "0-40", "40-100", "> 100"))
roundMean <- function(x){
        round(mean(x, na.rm = T), 2)
}

        ##Demographic summary for the GQ
gqDemoSumm <- finalSummaryData %>% 
        select(gqDistType, distrGDP, distrPerCapGDP, popTotal, under7LiteracyRate) %>% 
        group_by(gqDistType) %>%
        summarise_if(is.numeric, roundMean)

gqDemoSumm <- left_join(distTemplate, gqDemoSumm, by = c("districtType" = "gqDistType"))

names(gqDemoSumm) <- c("GQ District Types", "Avg GDP (million USD)", "Avg GDP Per cap.", "Total Population", "Under 7 literacy rate")

        ##Urbanization summary for GQ
gqUrbanSummary <- finalSummaryData %>% 
        select(gqDistType, areaUbyT, area_buUbyT, area_litUbyT, popUbyT, pop_buUbyT, pop_litUbyT) %>%
        group_by(gqDistType) %>%
        summarise_if(is.numeric, roundMean)

gqUrbanSummary <- left_join(distTemplate, gqUrbanSummary, by = c("districtType" = "gqDistType"))

names(gqUrbanSummary) <- c("GQ District Types", "Avg urban area (% total)", "Avg urban area built up(% total)", "Avg urban area lit (% total)", "Avg urban pop. (% total)", "Avg urban pop. built up (% total)", "Avg urban pop. lit (% total)")

        ##Infra Ind Summary for the GQ
gqInfrIndSumm <- finalSummaryData %>% 
        group_by(gqDistType) %>% 
        summarise(factories = round(mean(nFactories, na.rm = T)), workers = round(mean(totPersonsEngaged)), output = round(mean(totValOutput)/1000000,1), lightIntensitybyArea = round(mean(lightIntensitybyArea, na.rm = T), 1), meanRoadIntensity = round(mean(meanRoadIntensity, na.rm = T), 1), meanStationDensity = round(mean(meanStationDensity, na.rm = T), 1),nFarmers = round(mean(nFarmers, na.rm = T)))

gqInfrIndSumm <- left_join(distTemplate, gqInfrIndSumm, by = c("districtType" = "gqDistType"))

names(gqInfrIndSumm) <- c("GQ District Types", "Avg Number of Factories (ASI)", "Avg. of Total Workers (ASI)", "Avg. of Total Output (million INR?) (ASI)", "Avg light intensity (by area)", "Avg road intensity", "Avg Station Density","Avg Percent of farmers (% tot emp.)")

        ## Household access summary for the GQ
gqHhAccess <- finalSummaryData %>% 
        group_by(gqDistType) %>% 
        summarise(bankAccess = round(mean(hhBankAccess, na.rm = T), 1), electricityAccess = round(mean(hhElectricitAccess, na.rm = T), 1), waterAccess = round(mean(waterAccess, na.rm = T), 1), sanitationAccess = round(mean(sanitationAccess, na.rm = T), 1))

gqHhAccess <- left_join(distTemplate, gqHhAccess, by = c("districtType" = "gqDistType"))

names(gqHhAccess) <- c("GQ District Types", "Avg access to banks (percent of households)", "Avg access to electricity (percent of households)", "Avg access to water (percent of households)", "Avg access to sanitation (percent of households)")
        ##Creating a joint table
gqJoint <- left_join(distTemplate, gqDemoSumm, by = c("districtType" = "GQ District Types")) %>% 
        left_join(., gqUrbanSummary, by = c("districtType" = "GQ District Types")) %>% 
        left_join(., gqInfrIndSumm, by = c("districtType" = "GQ District Types")) %>% 
        left_join(., gqHhAccess, by = c("districtType" = "GQ District Types"))
gqJoint <- gqJoint %>% 
        gather(variable, val, 2:ncol(gqJoint)) %>% 
        spread(districtType, val) %>% 
        select(1, 5, 3, 4, 2)

        ##Demographic summary for the NSEW
nsewDemoSumm <- finalSummaryData %>% 
        group_by(nsewDistType) %>% 
        summarise(gdp = round(mean(distrGDP, na.rm = T), 1), gdpPC = round(mean(distrPerCapGDP, na.rm = T), 1), totPopulation = round(mean(popTotal, na.rm = T)), under7LiteracyRate = round(mean(under7LiteracyRate, na.rm = T), 1))

nsewDemoSumm <- left_join(distTemplate, nsewDemoSumm, by = c("districtType" = "nsewDistType"))

names(nsewDemoSumm) <- c("NSEW District Types", "Avg GDP (million USD)", "Avg GDP Per cap.", "Total Population", "Under 7 literacy rate")

        ##Urbanization summary for GQ
nsewUrbanSummary <- finalSummaryData %>% 
        select(nsewDistType, areaUbyT, area_buUbyT, area_litUbyT, popUbyT, pop_buUbyT, pop_litUbyT) %>%
        group_by(nsewDistType) %>%
        summarise_if(is.numeric, roundMean)

nsewUrbanSummary <- left_join(distTemplate, nsewUrbanSummary, by = c("districtType" = "nsewDistType"))

names(nsewUrbanSummary) <- c("NSEW District Types", "Avg urban area (% total)", "Avg urban area built up(% total)", "Avg urban area lit (% total)", "Avg urban pop. (% total)", "Avg urban pop. built up (% total)", "Avg urban pop. lit (% total)")
##Infra Ind Summary for the GQ
nsewInfrIndSumm <- finalSummaryData %>% 
        group_by(nsewDistType) %>% 
        summarise(factories = round(mean(nFactories, na.rm = T)), workers = round(mean(totPersonsEngaged)), output = round(mean(totValOutput)/1000000,1), lightIntensitybyArea = round(mean(lightIntensitybyArea, na.rm = T), 1), meanRoadIntensity = round(mean(meanRoadIntensity, na.rm = T), 1), meanStationDensity = round(mean(meanStationDensity, na.rm = T), 1),nFarmers = round(mean(nFarmers, na.rm = T)))

nsewInfrIndSumm <- left_join(distTemplate, nsewInfrIndSumm, by = c("districtType" = "nsewDistType"))

names(nsewInfrIndSumm) <- c("NSEW District Types", "Avg Number of Factories (ASI)", "Avg. of Total Workers (ASI)", "Avg. of Total Output (million INR?) (ASI)", "Avg light intensity (by area)", "Avg road intensity", "Avg Station Density","Avg Percent of farmers (% tot emp.)")

## Household access summary for the GQ
nsewHhAccess <- finalSummaryData %>% 
        group_by(nsewDistType) %>% 
        summarise(bankAccess = round(mean(hhBankAccess, na.rm = T), 1), electricityAccess = round(mean(hhElectricitAccess, na.rm = T), 1), waterAccess = round(mean(waterAccess, na.rm = T), 1), sanitationAccess = round(mean(sanitationAccess, na.rm = T), 1))

nsewHhAccess <- left_join(distTemplate, nsewHhAccess, by = c("districtType" = "nsewDistType"))

names(nsewHhAccess) <- c("NSEW District Types", "Avg access to banks (percent of households)", "Avg access to electricity (percent of households)", "Avg access to water (percent of households)", "Avg access to sanitation (percent of households)")
        ##Creating a joint table
nsewJoint <- left_join(distTemplate, nsewDemoSumm, by = c("districtType" = "NSEW District Types")) %>% 
        left_join(., nsewUrbanSummary, by = c("districtType" = "NSEW District Types")) %>% 
        left_join(., nsewInfrIndSumm, by = c("districtType" = "NSEW District Types")) %>% 
        left_join(., nsewHhAccess, by = c("districtType" = "NSEW District Types"))

nsewJoint <- nsewJoint %>% 
        gather(variable, val, 2:ncol(nsewJoint)) %>% 
        spread(districtType, val) %>% 
        select(1, 5, 3, 4, 2)




## Create a joint distribution table between gq and nsew district types
jointNodal <- finalSummaryData %>% 
        filter(nsewDistType == "nodal") %>% 
        group_by(gqDistType) %>% 
        summarise(nodal = n())

jointTen <- finalSummaryData %>% 
        filter(nsewDistType == "0-40") %>% 
        group_by(gqDistType) %>% 
        summarise(ten = n())

jointTenFifty <- finalSummaryData %>% 
        filter(nsewDistType == "40-100") %>% 
        group_by(gqDistType) %>% 
        summarise(tenFifty = n())

jointFifty <- finalSummaryData %>% 
        filter(nsewDistType == "> 100") %>% 
        group_by(gqDistType) %>% 
        summarise(fifty = n())

jointDistTable <- tibble(districtType = c("nodal", "0-40", "40-100", "> 100")) %>% 
        left_join(., jointNodal, by = c("districtType" = "gqDistType")) %>% 
        left_join(., jointTen, by = c("districtType" = "gqDistType")) %>% 
        left_join(., jointTenFifty, by = c("districtType" = "gqDistType")) %>% 
        left_join(., jointFifty, by = c("districtType" = "gqDistType"))

names(jointDistTable) <- c("District Type", "nodal", "0-40", "40-100", "> 100")
