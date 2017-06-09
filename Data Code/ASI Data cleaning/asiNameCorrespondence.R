                                                ############ File explanation ###########                                       This file creates the correspondence table between the district names in the spatial database with the ASI data. The first step was to map the district names to spatial datacodes. Then the names in the spatial database were mapped to those in 2010 and then 2001 ASI data. The final database will only have values for the list of districts in 2001
                                                #########################################

library(tidyverse); library(haven)
rm(list = ls())
setwd("~/Documents/Current WB Projects/Infra Corridor")

districtCorrespondence <- read_csv("data/ASI Data/Names Matching/districtCorrespondence.csv") %>% 
        mutate(finalId = ifelse(is.na(finalId), spatialId, finalId))


save(districtCorrespondence, file = "data/1 Cleaned files for analysis/districtCorrespondence.RDA")











districtCorrespondence <- dplyr::select(districtCorrespondence, spatialId, spatialState, spatialDistrict, finalId, Note)

##Join in the new NSS states from 2001
masterList2001 <- read_csv("data/ASI Data/Names Matching/masterList2001.csv") %>% 
        dplyr::select(spatialId, NSS2001_state, NSS2001_dist)
districtCorrespondence <- left_join(districtCorrespondence, masterList2001, by = "spatialId")

masterList2010 <- read_csv("data/ASI Data/Names Matching/masterList2010.csv") %>% 
        select(spatialId, NSS2010_state, NSS2010_dist)
districtCorrespondence <- left_join(districtCorrespondence, masterList2010, by = "spatialId") %>% 
        select(spatialId, spatialState, spatialDistrict, nss2001State = NSS2001_state, nss2001District = NSS2001_dist, nss2010State = NSS2010_state, nss2010District = NSS2010_dist, finalId, Note)

write_csv(districtCorrespondence, "data/ASI Data/Names Matching/districtCorrespondence.csv")













##
masterList2001 <- read_dta("data/ASI Data/Names Matching/Final_2001-1989(56th).dta") %>% 
        dplyr::select(NSS2001_state, NSS2001_dist, note) %>% 
        mutate(id = paste(NSS2001_state, NSS2001_dist, sep = "")) %>% 
        left_join(., districtCorrespondence, by = c("NSS2001_state" = "asi2001State", "NSS2001_dist" = "asi2001District")) %>% 
        left_join(., districtCorrespondence, by = c("NSS2001_state" = "spatialState", "NSS2001_dist" = "spatialDistrict"))

masterList2001 <- mutate(masterList2001, finalId = ifelse(is.na(finalId.x), finalId.y ,finalId.x), spatialId = ifelse(is.na(spatialId.x), spatialId.y , spatialId.x), Note = ifelse(is.na(Note.x), Note.y , Note.x)) %>% 
        dplyr::select(spatialId, spatialState, spatialDistrict, NSS2001_state, NSS2001_dist, finalId, note, Note) %>% 
        arrange(NSS2001_state, NSS2001_dist)

write_csv(masterList2001, "data/ASI Data/Names Matching/masterList2001.csv")



masterList2010 <- read_dta("data/ASI Data/Names Matching/Final_2010-1989(67th).dta") %>% 
        dplyr::select(NSS2010_state, NSS2010_dist, note) %>% 
        mutate(id = paste(NSS2010_state, NSS2010_dist, sep = "")) %>% 
        left_join(., districtCorrespondence, by = c("NSS2010_state" = "asi2001State", "NSS2010_dist" = "asi2001District")) %>% 
        left_join(., districtCorrespondence, by = c("NSS2010_state" = "spatialState", "NSS2010_dist" = "spatialDistrict"))

masterList2010 <- mutate(masterList2010, finalId = ifelse(is.na(finalId.x), finalId.y ,finalId.x), spatialId = ifelse(is.na(spatialId.x), spatialId.y , spatialId.x), Note = ifelse(is.na(Note.x), Note.y , Note.x)) %>% 
        dplyr::select(spatialId, spatialState, spatialDistrict, NSS2010_state, NSS2010_dist, finalId, note, Note) %>% 
        arrange(NSS2010_state, NSS2010_dist)

write_csv(masterList2010, "data/ASI Data/Names Matching/masterList2010.csv")







nonMatch2001 <- filter(masterList2001, is.na(finalId)) %>% 
        dplyr::select(NSS2001_state, NSS2001_dist, note) %>% 
        mutate(id = paste(NSS2001_state, NSS2001_dist, sep = "")) %>% 
        left_join(., districtCorrespondence, by = c("NSS2001_state" = "spatialState", "NSS2001_dist" = "spatialDistrict")) %>% dplyr::select(spatialId, spatialState, spatialDistrict, NSS2001_state, NSS2001_dist, finalId, note, Note)






asi2001 <- read_dta("data/ASI Data/ASI_2000_Clean.dta") %>% 
        select(NSS2001_state, NSS2001_dist) %>% 
        mutate(id = paste(NSS2001_state, NSS2001_dist, sep = "")) %>% 
        filter(!duplicated(id)) %>% 
        arrange(NSS2001_state, NSS2001_dist) %>% 
        left_join(., masterList2001, by = "id")
        

        
        

stataCorres2010 <- read_dta("data/ASI Data/Names Matching/Final_2010-1989(67th).dta") %>% 
        dplyr::select(NSS2010_state, NSS2010_dist, note) %>% 
        mutate(id = paste(NSS2010_state, NSS2010_dist, sep = ""))

asi2010 <- read_dta("data/ASI Data/ASI_2009_Clean.dta") %>% 
        select(NSS2010_state, NSS2010_dist) %>% 
        mutate(id = paste(NSS2010_state, NSS2010_dist, sep = "")) %>% 
        filter(!duplicated(id)) %>% 
        arrange(NSS2010_state, NSS2010_dist) %>% 
        left_join(., stataCorres2010, by = "id")

stataCorres2001 <- left_join(stataCorres2001, districtCorrespondence, by = c(asi))


##Loading ASI 2001 raw data and the district correspondence files
asi2001 <- read_dta("data/ASI Data/ASI_2000_Clean.dta")
asi2010 <- read_dta("data/ASI Data/ASI_2009_Clean.dta")
load("data/1 Cleaned files for analysis/districtCorrepondence.RDA")
nDistricts2010 <- n_distinct(paste(asi2010$NSS2010_dist, asi2010$NSS2010_state, sep = ""))
nDist2001Corres <- n_distinct(paste(districtCorrespondence$asi2001District, districtCorrespondence$asi2001State, sep = ""))

















districtCorrespondence <- read_csv("data/ASI Data/Names Matching/districtCorrespondence.csv")

districtCorrespondence <- districtCorrespondence %>% 
        mutate(finalId = ifelse(is.na(finalId), spatialId, finalId))
save(districtCorrespondence, file = "data/ASI Data/Names Matching/districtCorrepondence.RDA")



load("data/1 Cleaned files for analysis/districtMeta.RDA")

##join the 2010 data to the spatial data file
asi2010Names <- read_csv("data/ASI Data/asi2010ToSpatialNamesCorresp.csv")
districtCorrespondence <- left_join(districtMeta, asi2010Names, by = "id")

##join the 2001 data
asi2001Names <- read_csv("data/ASI Data/asi2001ToSpatialNamesCorresp.csv")
districtCorrespondence <- left_join(districtCorrespondence, asi2001Names, by = "id")
colnames(districtCorrespondence) <- c("spatialId", "spatialState", "spatialDistrict", "asi2010State", "asi2010District", "asi2001State", "asi2001District")
write_csv(districtCorrespondence, "data/ASI Data/districtCorrespondence.csv")
















asi2001Names <- read_csv("data/ASI Data/nameCorrespondence2001.csv")
asi2001Names <- asi2001Names %>% 
        group_by(asiState) %>% 
        filter(!duplicated(id))

write_csv(asi2001Names, "data/ASI Data/asi2001ToSpatialNamesCorresp.csv")        
##











asi2001 <- read_dta("data/ASI Data/ASI_2000_Clean.dta")













##create the asi names
asiNames2001 <- asi2001 %>% 
        dplyr::select(asiState = NSS2001_state, asiDistrict = NSS2001_dist) %>% 
        mutate(uniqueId = paste(asiState, asiDistrict, sep = "")) %>% 
        filter(!duplicated(uniqueId)) %>% 
        dplyr::select(1:3)

asiNames2001 <- left_join(asiNames2001, districtMeta, by = c("asiDistrict" = "district"))
write_csv(asiNames2001, "data/ASI Data/names2001.csv")














## Load the name correspondence
names2010 <- read_csv("data/ASI Data/namesCorrepondence2010.csv")

##Remove duplicates
names2010 <- names2010 %>% 
        filter(!duplicated(id))

write_csv(names2010, "data/ASI Data/asi2010ToSpatialNamesCorresp.csv")








##Loading the Asi 2010 data
asi2010 <- read_dta("data/ASI Data/ASI_2009_Clean.dta")

load("data/districtData.RDA")
##load("data/districtDitances.RDA")
spatialData <- read_csv("data/Spatial Database/SpatialData.csv") 

%>% 
        select(state = L1_name, district = L2_name) %>% 
        mutate(uniqueId = paste(state, district, sep = "")) %>% 
        filter(!duplicated(uniqueId))
districtNames <- districtData %>% 
        select(1:3)

asiNames2010 <- asi2010 %>% 
        select(asiState = NSS2010_state, asiDistrict = NSS2010_dist) %>% 
        mutate(uniqueId = paste(asiState, asiDistrict, sep = ""))

##remove duplicate i.e select the unique rows
asiNames2010 <- asiNames2010[!duplicated(asiNames2010$uniqueId), ]
rm(list = setdiff(ls(), c("asiNames2001", "districtNames", "asiNames2010")))
nameList <- (asiNames2010$uniqueId)
asiNames2010 <- left_join(asiNames2010, districtNames, by = c("asiDistrict"="district")) ## some district names are the same across states, so those rows will be duplicated to show all the combinations.
nonMatches <- asiNames2010 %>% 
        filter(duplicated(uniqueId))


write_csv(asiNames2010, "data/ASI Data/namesCorrepondence2010.csv")





## Created a correspondence table by manually checking the district names
nameCorresp2001 <- read_csv("data/ASI Data/nameCorrespondence2001.csv")
nameCorresp2001 <- nameCorresp2001 %>% 
        mutate(uniqueId = paste(asiState, asiDistrict, sep = ""))

nameCorresp2001 <- nameCorresp2001[!duplicated(nameCorresp2001$uniqueId), ]


##join the asiNames with correspondence
asiNames2001 <- left_join(asiNames2001, nameCorresp2001, by = "uniqueId")


## Repeating same steps for 2011
asi2001 <- read_dta("data/ASI Data/ASI_2000_Clean.dta")


##create the asi names
asiNames2001 <- asi2001 %>% 
        select(asiState = NSS2001_state, asiDistrict = NSS2001_dist) %>% 
        mutate(uniqueId = paste(asiState, asiDistrict, sep = ""))

##remove duplicate i.e select the unique rows
asiNames2001 <- asiNames2001[!duplicated(asiNames2001$uniqueId), ]

