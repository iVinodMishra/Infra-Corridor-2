# use Asi state code with NSS/Asi district code to idenitfy unique instances
# Do a sanity check on number of firms in districts
# Do a sanity check on number of districts in states
# Check for district splits in 2011 and add the values to get the same district list as 2001
        # Use statoids.com india districts link to identify splits
# Output a panel dataset with spatial dataset district codes and Asi data

## Extra sanity check on the spatial dataset: Check how they handle district splits

library(tidyverse); library(haven)
rm(list = ls())
setwd("~/Documents/Current WB Projects/Infra Corridor")

## Load the district correspondence data
load("data/1 Cleaned files for analysis/districtCorrespondence.RDA")

##Create the ASI 2001 dataset
asi2001 <- districtCorrespondence %>% 
        select(finalId, nss2001State, nss2001District) %>% 
        left_join(., read_dta("data/ASI Data/ASI_2000_Clean.dta"), by = c("nss2001State" = "NSS2001_state", "nss2001District" = "NSS2001_dist")) %>% 
        select(-id, -(6:14), -nss2001State, -nss2001District) %>% 
        mutate(year = 2001)

##Create the ASI 2010 raw data 
asi2010 <- districtCorrespondence %>% 
        select(finalId, nss2010State, nss2010District) %>% 
        left_join(., read_dta("data/ASI Data/ASI_2009_Clean.dta"), by = c("nss2010State" = "NSS2010_state", "nss2010District" = "NSS2010_dist")) %>% 
        select(-id, -(6:16), -nss2010State, -nss2010District) %>% 
        mutate(year = 2010)

##Keeping only the columns common to both datasets (ordered based on 2001)
asi2001 <- select(asi2001, match(intersect(names(asi2001), names(asi2010)), names(asi2001)))
asi2010 <- select(asi2010, match(intersect(names(asi2001), names(asi2010)), names(asi2010)))
        
##Joining the two datasets (after checking names(asi2001) == names(asi2010))
asiData <- rbind(asi2001, asi2010) %>% 
        select(1, 37, 2:36) %>% 
        arrange(finalId, year)

save(asiData, file = "data/1 Cleaned files for analysis/asiData.RDA")







