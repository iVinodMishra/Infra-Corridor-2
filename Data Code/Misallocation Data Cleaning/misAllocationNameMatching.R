# Data issues and steps taken
## Merged district names. There were several instances in the misallocation dataset were the names of multiple districts had been joined together into single names. I have created a new excel file that separates out these names (so that each row only reports a single district). The values for misallocation were copied for each of these rows from the original misallocation data for the merged names.
## The paper says that there were 320 districts, but the dataset with the merged names had 364 districts in 2000 and 366 in 2010. the new data with unmerged names has 376 districts in 2000 and 378 districts in 2010
# Delhi is represented as a single district

library(tidyverse); library(readxl)
rm(list = ls())
setwd("~/Documents/Current WB Projects/Infra Corridor")

misAllocation <- read_excel("data/Misallocation data/misAllocation Names seperate.xlsx", sheet = 1)
load("data/1 Cleaned files for analysis/districtCorrespondence.RDA")

mis2000 <- misAllocation %>% 
        filter(year == 2000) %>% 
        select(misAll2000State = state, misAll2000District = district) %>% 
        mutate(id = paste(misAll2000State,  misAll2000District, sep = ""))

mis2010 <- misAllocation %>% 
        filter(year == 2010) %>% 
        select(misAll2010State = state, misAll2010District = district) %>% 
        mutate(id = paste(misAll2010State,  misAll2010District, sep = ""))
## There are only 2 non matching entries between 2010 and 2000 (new districts were added in pondichery)

districtCorrespondenceCaps <- districtCorrespondence %>% 
        mutate(nss2001State = toupper(nss2001State))
        
## Match the names and store as a raw correspondence file. The non matches will be manually matched.
nameMatching <- mis2010 %>% 
        left_join(., districtCorrespondenceCaps, by = c("misAll2010State" = "nss2001State" , "misAll2010District" = "nss2001District")) %>% 
        write_csv(., "data/Misallocation data/rawCorrespondence.csv")

##Load the manually matched correspondence file and merge in the final id variables
fullCorrespondence <- read_csv("data/Misallocation data/fullCorrespondence.csv") %>% 
        left_join(., districtCorrespondence, by = "spatialId") %>% 
        select(1:3, finalId)

#Add the id data to the misAllocation data
misAllocation <- left_join(misAllocation, fullCorrespondence, by = c("state" = "misAll2010State", "district" = "misAll2010District")) %>% 
        select(2:3, 10:11, 1, 4:9) %>% 
        arrange(state, district, year) %>% 
        write_csv(., "data/Misallocation data/misAllocationClean.csv")

save(misAllocation, file = "data/1 Cleaned files for analysis/misAllocation.RDA")
        


