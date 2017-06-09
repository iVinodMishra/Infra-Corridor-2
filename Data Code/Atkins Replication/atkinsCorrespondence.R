rm(list = ls())
library(tidyverse); library(haven); library(stringr); library(stargazer)
setwd("~/Documents/Current WB Projects/Infra Corridor")

load('data/1 Cleaned files for analysis/districtCorrespondence.RDA')

## Load the district distances data
atkinsDistance <- read_dta("data/Atkins Replication Files/district_distance_dist5.dta")

atkinsNames <- atkinsDistance %>% 
        select(state = state_orig, district = district_orig) %>% 
        mutate_all(str_to_lower) %>% 
        distinct() %>% 
        arrange(state, district)


        
