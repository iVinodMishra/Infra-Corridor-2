                                        ############ File explanation ###########                                               This file creates the spatial dataset from the 2001 and 2011 data downloaded from the south asia spatial database.                                          #########################################
library(tidyverse); library(stringr); library(readxl)
rm(list = ls())
setwd("~/Documents/Current WB Projects/Infra Corridor")

## Create the combined dataset
allFiles2001 <- list.files(path = "data/Spatial Database/All Files/2001/")
allFiles2011 <- list.files(path = "data/Spatial Database/All Files/2011/")

dataString2001 <- str_c("data/Spatial Database/All Files/2001/", allFiles2001[1])
dataString2011 <- str_c("data/Spatial Database/All Files/2011/", allFiles2011[1])

data2001 <- read_csv(dataString2001)
data2011 <- read_csv(dataString2011)

## Note: There are a few files that have incomplete coverage (one which only has a subset of the district. While 7 others have only totals and urban/rural)
for (i in 2:length(allFiles2001)){
        dataString2001 <- str_c("data/Spatial Database/All Files/2001/", allFiles2001[i])
        temp <- read_csv(dataString2001) %>% 
                dplyr::select(-spatial_data_yr, -L0_code, -L0_name, -L1_name, -L1_code, -L2_code, -L2_name)
        
        data2001 <- left_join(data2001, temp, by = c("id", "geography"))
}

for (i in 2:length(allFiles2011)){
        dataString2011 <- str_c("data/Spatial Database/All Files/2011/", allFiles2011[i])
        temp <- read_csv(dataString2011) %>% 
                dplyr::select(-spatial_data_yr, -L0_code, -L0_name, -L1_name, -L1_code, -L2_code, -L2_name)
        
        data2011 <- left_join(data2011, temp, by = c("id", "geography"))
}

## Create variable coverage list
# variablesForAnalysis <- variablesForAnalysis %>% 
#         mutate(in2001 = as.integer(Variable %in% varNames2001), in2011 = as.integer(Variable %in% varNames2011)) %>% 
#         select(Variable, Description, in2001, in2011)
# write_csv(variablesForAnalysis, "data/Spatial Database/variableCoverage.csv")
# data2011Total <- data2011 %>% 
#         filter(geography == "Total")
# 
# save(data2011Total, file = "data/1 Cleaned files for analysis/data2011Total.RDA")

##Matching column names
varNames2001 <- colnames(data2001)
varNames2011 <- colnames(data2011)
varNamesCommon <- varNames2011[varNames2011 %in% varNames2001] ##this does not check for order in which these columns are present in the dataframe (there are difference between the two)

colNums2011 <- match(varNamesCommon,names(data2011)) ##gives the posiion of the column in the data frame
colNums2001 <- match(varNamesCommon,names(data2001)) ##gives the posiion of the column in the data frame

data2011 <- data2011 %>% 
        dplyr::select(colNums2011) ## selects and orders columns based on the varNamesCommon order

data2001 <- data2001 %>% 
        dplyr::select(colNums2001) ## selects and orders columns based on the varNamesCommon order



dataAll <- rbind(data2001, data2011)

#save(dataAll, file = "data/1 Cleaned files for analysis/spatialDataEverything.RDA")
## Creating the final dataset with variables we are interested in
# variablesForAnalysis <- read_excel("data/Spatial Database/variablesForAnalysis.xlsx", sheet = 1, skip = 1)
# 
# variablesForAnalysis <- variablesForAnalysis %>% 
#         filter(!is.na(forAnalysis)) %>%  ## There are 136 variables of interest
#         filter(Variable %in% names(dataAll)) ## There are 67 that match with the data
# 
# colNumsAll <- match(variablesForAnalysis$Variable, names(dataAll))
# dataAll <- dataAll %>% 
#         dplyr::select(id, spatial_data_yr, geography, L0_code, L0_name, L1_code, L1_name, L2_code, L2_name, colNumsAll)

# write_csv(dataAll, "data/Spatial Database/SpatialData.csv")
# write_csv(variablesForAnalysis, "data/Spatial Database/SpatialDataVarDesc.csv")


##Separating spatial data into the three geographies
spatialUrban <- dataAll %>% 
        filter(geography == "Urban")

spatialRural <- dataAll %>% 
        filter(geography == "Rural") 

spatialTotal<- dataAll %>% 
        filter(geography == "Total")

spatialAll <- dataAll

##Saving the datasets
#save(districtMeta, file = "data/1 Cleaned files for analysis/districtMeta.RDA")
save(spatialRural, file = "data/1 Cleaned files for analysis/spatialRural.RDA")
save(spatialUrban, file = "data/1 Cleaned files for analysis/spatialUrban.RDA")
save(spatialTotal, file = "data/1 Cleaned files for analysis/spatialTotal.RDA")
save(spatialAll, file = "data/1 Cleaned files for analysis/spatialAll.RDA")







## Create the variable descriptions
# allFileDesc <- list.files(path = "data/Spatial Database/All Descriptions")
# 
# dataString <- str_c("data/Spatial Database/All Descriptions/", allFileDesc[1])
# 
# dataDesc <- read_excel(dataString, sheet = 2)
# 
# for (i in 2:length(allFiles)){
#         dataString <- str_c("data/Spatial Database/All Descriptions/", allFileDesc[i])
#         temp <- read_excel(dataString, sheet = 2)
#         
#         dataDesc <- rbind(dataDesc, temp)
# }
# 
# dataDesc <- dataDesc %>% arrange(Variable)
# 
#
# write_csv(dataDesc, "data/SpatialDataDesc.csv")

