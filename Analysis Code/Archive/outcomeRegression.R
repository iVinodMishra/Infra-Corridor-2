
#http://stats.stackexchange.com/questions/117052/replicating-statas-robust-option-in-r

##LOAD LIBRARIES AND DATA
        #I am using the entire spatial database (instead of just the total gwography) so that I can create variables that represent urbanization before selecting just the total geography
library(tidyverse); library(haven); library(stringr); library(sandwich); library(lmtest); library(stargazer); library(broom)
rm(list = ls())
setwd("~/Documents/Current WB Projects/Infra Corridor")
load("data/1 Cleaned files for analysis/spatialAll.RDA")
outcomeVariables <- read_csv("data/1 Cleaned files for analysis/outcomeVariables.csv")
controlVars <- read_csv("data/1 Cleaned files for analysis/controlVariables.csv")

##GETTING THE DATA READY FOR REGRESSIONS
        #1. Create the urbanization variables
        #2. Keep only observations that we need for the regressions
        #3. Set zero values to min values and Winsorize all outcome variables in 2001 and 2011
        #4. Calc. the y var (either log(2011) - log(2001) or 2011 - 2001)
        #5. Remove India/China and islands
        #6 Add the district distance to highways for each district and recreate the district categories as in summary file (this will eventually be consolidated in identifyNodalDistrict.R)

        ##1. Create the urbanization variable
spatialData <- spatialAll %>% 
        arrange(id, spatial_data_yr, geography) %>% #imp. for later steps that used indexes
        group_by(id, spatial_data_yr) %>% #three obs. in the order rural, total, urban (since geo is sorted)
        mutate(urbanPopShare = pop[3]/pop[2]) %>% # urban/total
        ungroup()
rm("spatialAll")

        #2. Keep only observations that we need for the regressions
spatialData <- spatialData %>% 
        dplyr::select(one_of(c("id", "L1_name", "L2_name","geography", "spatial_data_yr", outcomeVariables$varNames, controlVars$varNames))) %>% 
        filter(geography == "Total")

        #3. Set zero values to min values and Winsorize all outcome variables in 2001 and 2011
winsorize <- function(x){
        minValue <- min(x[x != 0]) #calc. min non-zero value
        x[x == 0] <- minValue #set to min value if zero
        lim <- quantile(x, probs = c(0.01, 0.99), na.rm = T) ##calc. the bound [1%, 99%]
        x[ x < lim[1] ] <- lim[1] #replace with lower bound if below bound
        x[ x > lim[2] ] <- lim[2] #replace with upper bound if above bound
        x
}

spatialData <- spatialData %>% 
        mutate_at(outcomeVariables$varNames, winsorize) # winsorize all outcome variables

outcomeSummary <- dplyr::select(spatialData, one_of(outcomeVariables$varNames)) %>% 
        as.data.frame()
#stargazer(outcomeSummary, summary.stat = c("n", "min","p25", "mean", "median","p75", "max", "sd"), type = "html", out = "Results/Tables/outcomeSummary.html")
rm('outcomeSummary')

        #4. Calc. the y var (either log(2011) - log(2001) or 2011 - 2001)
logFunction <- function(x) {
        log(x[2]) - log(x[1]) #each distr only has two values 2011 and 2001
}
nonLog <- function(x){
        x[2] - x[1]
}

spatialDataOutcomes <- spatialData[,1] #create an empty dataframe for joining y vars

for(i in 1:length(outcomeVariables$varNames)){ #loop through outcomes
        varName <- outcomeVariables$varNames[i] #pull outcome var name
        
        if(outcomeVariables$logs[i] == 1){ # check if its logs or regular
                tempColumn <- spatialData %>% 
                        group_by(id) %>% #nObs 2 = 2001, 2011
                        mutate_at(varName, logFunction) %>% #use logs
                        ungroup() %>% 
                        dplyr::select(one_of(varName))
                names(tempColumn) <- paste(varName, "LogDiff", sep = "")
        } else{
                finalVarName <- paste(varName, "Diff", sep = "")
                tempColumn <- spatialData %>% 
                        group_by(id) %>% 
                        mutate_at(varName, nonLog) %>% #use non logs
                        ungroup() %>% 
                        dplyr::select(one_of(varName))
                names(tempColumn) <- paste(varName, "Diff", sep = "")
        }
        spatialDataOutcomes <- cbind(spatialDataOutcomes, tempColumn) #join together
}

spatialDataOutcomes <- dplyr::select(spatialDataOutcomes, -id) #remove the id column

spatialData <- cbind(spatialData, spatialDataOutcomes)
yVarNames <- names(spatialDataOutcomes) # for use in the regression loop

rm("spatialDataOutcomes")

spatialData <- spatialData %>% 
        filter(spatial_data_yr == 2001) #keep only 2001 year (since we finshed calc for diff between 2001 and 2011)

        #5. Remove India/China and islands
spatialData <- spatialData %>% 
        filter(!str_detect(L1_name, "India/China|Andaman & Nicobar|Lakshadweep"))
      
        #6 Add the district distance to highways for each district and recreate the district categories as in summary            file
load("data/1 Cleaned files for analysis/districtDistances.RDA")

districtDistances <- districtDistances %>% 
        mutate(id = as.character(id))
gqNodalDistrictFinalIds <- c("3_7_95_0", "3_7_93_0", "3_7_94_0", "3_7_91_0", "3_7_92_0", "3_7_90_0", "3_7_98_0", "3_7_97_0", "3_7_96_0", "3_6_86_0", "3_6_88_0", "3_9_141_0", "3_9_140_0", "3_27_519_0", "3_27_518_0", "3_27_517_0", "3_33_603_0", "3_19_342_0")

nsewNodalDistrictFinalIds <- c("3_7_95_0", "3_7_93_0", "3_7_94_0", "3_7_91_0", "3_7_92_0", "3_7_90_0", "3_7_98_0", "3_7_97_0", "3_7_96_0", "3_6_86_0", "3_6_88_0", "3_9_141_0", "3_9_140_0", "3_29_572_0", "3_28_536_0")

districtDistances <- districtDistances %>% 
        mutate(gqDistType = ifelse(id %in% gqNodalDistrictFinalIds, "nodal", ifelse(gqDistance > 0 & gqDistance <= 40, "0-40", ifelse(gqDistance > 40 & gqDistance <= 100, "40-100", "> 100")))) %>% 
        mutate(nsewDistType = ifelse(id %in% nsewNodalDistrictFinalIds, "nodal", ifelse(nsewDistance > 0 & nsewDistance <= 40, "0-40", ifelse(nsewDistance > 40 & nsewDistance <= 100, "40-100", "> 100")))) %>% 
        dplyr::select(id, gqDistType, nsewDistType)

spatialData <- left_join(spatialData, districtDistances, by = "id")

##RUN THE REGRESSIONS
        #1. Identify the variables used for the regression
        #2. Get the data ready
        #3. Create variables for the tables
        #4. Specify the models
        #5. Create the table

for(i in 1:length(outcomeVariables$varNames)){
        #1. Identify the variables used for the regression
        yControl <- outcomeVariables$varNames[i]
        yVar <- yVarNames[i]
        
        #2. Get the data ready
        yControlPosition <- match(yControl, names(spatialData))
        yColumnPosition <- match(yVar, names(spatialData))
        
        regressData <- spatialData %>% 
                filter(is.finite(.[[yColumnPosition]])) %>% #[[]]notation to reference var based on position
                mutate(L1_name = gsub("&", "and", L1_name)) # special chars interfere with formatting on stargazer
        
        gqDistance <- factor(regressData$gqDistType, levels = c("> 100", "nodal", "0-40", "40-100"))
        nsewDistance <- factor(regressData$nsewDistType, levels = c("> 100", "nodal", "0-40", "40-100"))
        
        yValues <- regressData[, yColumnPosition]
        yControlValues <- regressData[, yControlPosition]
        
        #3. Create variables for the tables
        stateLabels <- levels(as.factor(regressData$L1_name))[2:length(levels(as.factor(regressData$L1_name)))] #names of states
        depVarLabel <- outcomeVariables[outcomeVariables$varNames == yControl,]$varDescription
        title <- outcomeVariables$title[i]
        outString <- paste("Results/Tables/Regressions Feb 8th/", title, ".html", sep = "")
        
        #4. Specify the models
        model0 <- lm(yValues ~ gqDistance + nsewDistance)
        cov0 <- vcovHC(model0, type = "HC1")
        robust_se0 <- sqrt(diag(cov0))
        
        model1 <- lm(yValues ~ gqDistance + nsewDistance + yControlValues)
        cov1 <- vcovHC(model1, type = "HC1")
        robust_se1 <- sqrt(diag(cov1))
        
        model2 <- lm(yValues ~ gqDistance + nsewDistance + yControlValues + as.factor(regressData$L1_name)) 
        cov2 <- vcovHC(model2, type = "HC1")
        robust_se2 <- sqrt(diag(cov2))
        
        if(yVar == "urbanPopShareDiff"){
                model3 <- lm(yValues ~ gqDistance + nsewDistance + yControlValues + regressData$dens + regressData$edu_lit_7_t + regressData$hh_elec_t + regressData$bank_t +log(regressData$elev) + log(regressData$pop) + regressData$sc + as.factor(regressData$L1_name)) 
                cov3 <- vcovHC(model3, type = "HC1")
                robust_se3 <- sqrt(diag(cov3))   
                #covariateLabels <- c("GQ[Nodal]", "GQ[0-40]", "GQ[40-100]", "NSEW[40-100]", "NSEW[0-40]", "NSEW[Nodal]", gsub("_","",yControl), "Pop. Density", "Tot. Literacy Rate (7 plus yrs)",  "HH Access to Electricity", "HH Access to Banks", "Log(pop.)", "Scheduled Caste (percent)", stateLabels)
                
                model5 <- lm(yValues ~ gqDistance + nsewDistance + yControlValues + regressData$dens  + gqDistance * regressData$edu_lit_7_t + nsewDistance * regressData$edu_lit_7_t + gqDistance * regressData$bank_t + nsewDistance * regressData$bank_t + regressData$hh_elec_t + log(regressData$pop) + regressData$sc + as.factor(regressData$L1_name)) 
                cov5 <- vcovHC(model5, type = "HC1")
                robust_se5 <- sqrt(diag(cov5))
                
                model6 <- lm(yValues ~ gqDistance + nsewDistance + yControlValues + gqDistance * regressData$edu_lit_7_t + nsewDistance * regressData$edu_lit_7_t + gqDistance * regressData$bank_t + nsewDistance * regressData$bank_t + gqDistance * regressData$dens + nsewDistance * regressData$dens + gqDistance * regressData$hh_elec_t + nsewDistance * regressData$hh_elec_t + gqDistance * log(regressData$pop) + nsewDistance * log(regressData$pop) + gqDistance * regressData$sc + nsewDistance * regressData$sc + as.factor(regressData$L1_name))
                cov6 <- vcovHC(model6, type = "HC1")
                robust_se6 <- sqrt(diag(cov6))
        }
        
        model3 <- lm(yValues ~ gqDistance + nsewDistance + yControlValues + regressData$urbanPopShare + regressData$edu_lit_7_t + regressData$hh_elec_t + regressData$bank_t + log(regressData$pop) + regressData$sc + as.factor(regressData$L1_name)) 
        cov3 <- vcovHC(model3, type = "HC1")
        robust_se3 <- sqrt(diag(cov3))
        #covariateLabels <- c("GQ[Nodal]", "GQ[0-40]", "GQ[40-100]", "NSEW[40-100]", "NSEW[0-40]", "NSEW[Nodal]", gsub("_","",yControl), "Share of Urban Pop.", "Tot. Literacy Rate (7 plus yrs)", "HH Access to Electricity", "HH Access to Banks", "Log(pop.)", "Scheduled Caste (percent)", stateLabels)
        
        model4 <- lm(yValues ~ gqDistance + nsewDistance + yControlValues + gqDistance * regressData$edu_lit_7_t + nsewDistance * regressData$edu_lit_7_t + gqDistance * regressData$bank_t + nsewDistance * regressData$bank_t + as.factor(regressData$L1_name)) 
        cov4 <- vcovHC(model4, type = "HC1")
        robust_se4 <- sqrt(diag(cov4))
        
        model5 <- lm(yValues ~ gqDistance + nsewDistance + yControlValues + gqDistance * regressData$edu_lit_7_t + nsewDistance * regressData$edu_lit_7_t + gqDistance * regressData$bank_t + nsewDistance * regressData$bank_t + regressData$urbanPopShare + regressData$hh_elec_t + log(regressData$pop) + regressData$sc + as.factor(regressData$L1_name)) 
        cov5 <- vcovHC(model5, type = "HC1")
        robust_se5 <- sqrt(diag(cov5))
        
        model6 <- lm(yValues ~ gqDistance + nsewDistance + yControlValues + gqDistance * regressData$edu_lit_7_t + nsewDistance * regressData$edu_lit_7_t + gqDistance * regressData$bank_t + nsewDistance * regressData$bank_t + gqDistance * regressData$urbanPopShare + nsewDistance * regressData$urbanPopShare + gqDistance * regressData$hh_elec_t + nsewDistance * regressData$hh_elec_t + gqDistance * log(regressData$pop) + nsewDistance * log(regressData$pop) + gqDistance * regressData$sc + nsewDistance * regressData$sc + as.factor(regressData$L1_name))
        cov6 <- vcovHC(model6, type = "HC1")
        robust_se6 <- sqrt(diag(cov6))
        
        stargazer(model0, model1, model2, model3, model4, model5, model6, se = list(robust_se0, robust_se1, robust_se2, robust_se3, robust_se4, robust_se5, robust_se6),  dep.var.labels = depVarLabel, omit = "L1", type = "html", out = outString)
        
}

## REGRESSIONS WITH LITERACY RATE INTERACTIONS FOR GDP PER CAP
spatialDataLit <- spatialData %>% 
        mutate(medianLit = median(edu_lit_7_t, na.rm = T), literacy = factor(ifelse(edu_lit_7_t > medianLit, "Cbove", "Below")))

litModel1 <- lm(gdp_pcLogDiff ~ gqDistType + nsewDistType + gdp_pc + gqDistType * literacy + nsewDistType * literacy + as.factor(L1_name), data = spatialDataLit)

litCov1 <- vcovHC(litModel1, type = "HC1")
litRobust_se1 <- sqrt(diag(litCov1))

litModel2 <- lm(gdp_pcLogDiff ~ gqDistType + nsewDistType + gdp_pc + gqDistType * literacy + nsewDistType * literacy + as.factor(L1_name) + urbanPopShare + edu_lit_7_t + hh_elec_t + bank_t + log(pop) + sc, data = spatialDataLit)

litCov2 <- vcovHC(litModel2, type = "HC1")
litRobust_se2 <- sqrt(diag(litCov2))

stargazer(litModel1, litModel2, se = list(litRobust_se1, litRobust_se2),  dep.var.labels = "GDP Per Capita", omit = "L1", type = "html", out = "Results/Tables/literacySpec1Strt.html")


## REGRESSIONS WITH LITERACY RATE INTERACTIONS FOR FEMALE REGULAR WAGE

litModel1 <- lm(emp_rwg_fDiff ~ gqDistType + nsewDistType + gdp_pc + gqDistType * literacy + nsewDistType * literacy + as.factor(L1_name), data = spatialDataLit)

litCov1 <- vcovHC(litModel1, type = "HC1")
litRobust_se1 <- sqrt(diag(litCov1))

litModel2 <- lm(emp_rwg_fDiff ~ gqDistType + nsewDistType + gdp_pc + gqDistType * literacy + nsewDistType * literacy + as.factor(L1_name) + urbanPopShare + edu_lit_7_t + hh_elec_t + bank_t + log(pop) + sc, data = spatialDataLit)

litCov2 <- vcovHC(litModel2, type = "HC1")
litRobust_se2 <- sqrt(diag(litCov2))

stargazer(litModel1, litModel2, se = list(litRobust_se1, litRobust_se2),  dep.var.labels = "Female Regular Wage Earners", omit = "L1", type = "html", out = "Results/Tables/literacySpec2Strt.html")

