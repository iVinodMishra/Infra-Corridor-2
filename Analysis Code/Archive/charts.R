library(tidyverse); library(ggthemes); library(stringr); library(maptools); library(viridis)
rm(list = ls())
setwd("~/Documents/Current WB Projects/Infra Corridor")

##IMPACT OF HIGHWAY ON GROWTH RATE OF GDP PER CAP

gdpPcData <- read_csv("data/2 Chart Data/gdpPerCapGrowthRate.csv") %>% 
        gather(key = valueType, value = value, 3:4) %>% 
        mutate(valueType = factor(valueType, levels = c("Effect", "Baseline"), labels = c("Effect" = "Highway Effect", "Baseline"), ordered = T))

gdpPcDataChart <- ggplot(gdpPcData, aes(x = distanceType, y = value, fill = (valueType))) +
        geom_bar(stat = "identity", width = 0.3) +
        geom_hline(aes(yintercept = 4.37), color="black", linetype="dashed") +
        scale_fill_manual(name= "", values=c("Baseline"="grey40","Highway Effect"="blue")) + 
        scale_y_continuous(breaks = c(1, 2, 3, 4, 4.37, 5)) +
        scale_x_discrete(labels = function(x) str_wrap(x, width = 12)) +
        ylab("Annual Growth Rate\n of GDP per Capita") +
        theme_tufte() +
        guides(fill=guide_legend(nrow=2,byrow=TRUE)) +
        theme(axis.title.x = element_blank(), axis.text.x = element_text(size = 16), axis.text.y = element_text(size = 12), axis.title.y = element_text(size = 18), legend.text = element_text(size = 18), legend.position = "top")

png(file = "Results/figures/gdpPcDataChart.png", height = 1200, width = 1500, res = 300)
gdpPcDataChart
dev.off()

##TRADE OFFS AND IMPACTS
tradeOffsImpacts <- read_csv("data/2 Chart Data/trade offs and impacts.csv") %>% 
        gather(key = valueType, value = value, 4:5) %>% 
        arrange(variableOrder) %>%
        mutate(colorVar = ifelse(valueType == "Baseline", "grey40", ifelse(impactType == "negative", "firebrick3", "blue")))

        

tradeOffsChart <- ggplot(tradeOffsImpacts, aes(x = variableOrder, y = value)) +
        geom_bar(stat = "identity", width = 0.4, fill = c("grey40", "blue", "grey40", "blue", "grey40", "blue", "grey40", "firebrick3","grey40", "firebrick3")) +
        scale_x_discrete(labels = str_wrap(c("GDP Per Capita", "Proportion of female regular wage earners", "Proportion of total regular wage earners", "Aerosol optical thickness", "Decline in Forest cover"), width = 12)) + 
        ylab("Impact of GQ") +
        theme_tufte() +
        theme(
                axis.title.x = element_blank(), 
                axis.text.x = element_text(size = 16), 
                axis.text.y = element_text(size = 14), 
                axis.title.y = element_text(size = 16))
tradeOffsChart

png(file = "Results/figures/tradeOff.png", height = 1350, width = 2200, res = 300)
tradeOffsChart
dev.off()
        
##EFFECT OF LITERACY ON HIGHWAY IMPACT
litEffect <- read_csv("data/2 Chart Data/litEffect.csv") %>% 
        mutate(literacy = factor(literacy, levels = c("Below", "Above"), labels = c("Below" = "Below median literacy", "Above" = "Above median literacy"), ordered = TRUE))

litEffectChart <- ggplot(litEffect, aes(x = literacy, y = effect, fill = literacy)) +
        geom_bar(stat = "identity", position = "dodge", width = 0.6) +
        scale_fill_manual(name= "", values=c("Below median literacy" = "grey40", "Above median literacy" = "blue")) +
        facet_wrap(~variable, strip.position = "bottom", labeller = labeller(variable = label_wrap_gen(14))) +
        ylab("Normalized Impact \n(as % of control group growth)") + 
        theme_tufte() +
        guides(fill=guide_legend(nrow=2,byrow=TRUE)) +
        theme(panel.spacing = unit(1, "lines"), axis.ticks.x = element_blank(), axis.title.x = element_blank(), strip.text.x = element_text(size = 18), axis.text.x = element_blank(), axis.text.y = element_text(size = 14), axis.title.y = element_text(size = 16), legend.text = element_text(size = 16), legend.position = "top")

png(file = "Results/figures/litEffect.png", height = 1500, width = 1200, res = 300)
litEffectChart
dev.off()


##MAPPING CONTROLS
load("data/1 Cleaned files for analysis/spatialAll.RDA")
spatialAll <- spatialAll %>% 
        filter(geography == "Total", spatial_data_yr == 2001) %>% 
        mutate(gdp_pc = cut(gdp_pc, breaks = c(0, 250, 400, 600, 1500), ordered_result = T), emp_rwg_f = cut(emp_rwg_f, breaks = c(0, 10, 20, 50, 100), ordered_result = T)) %>% 
        dplyr::select(id, gdp_pc, emp_rwg_f)
        
indiaShape <- readShapeSpatial("data/Shape Files/SouthAsiaBoundaries/All/India_L2_Administrative_Boundaries.shp", proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs "))
gqShape <- readShapeLines("data/Shape Files/GQ/GQ_Highway.shp", proj4string = CRS("+proj=longlat +datum=WGS84 +no_defs "))
load("data/Shape Files/nsewComplete.RDA")
nsewComplete <- spTransform(nsewComplete, CRS(proj4string(gqShape)))

gqShape <- fortify(gqShape)
indiaShape <- fortify(indiaShape, region = "ID")
indiaShape <- left_join(indiaShape, spatialAll, by = "id")

png(file = "Results/figures/gdpMap.png", height = 800, width = 800, res = 200)
ggplot() + 
        geom_polygon(data = indiaShape, 
                     aes(fill = gdp_pc, x = long, y = lat, group = group)) + 
        geom_path(data = gqShape, 
                  aes(x = long, y = lat, group = group), 
                  color = "white", 
                  size = 1) +
        coord_equal() +
        scale_fill_viridis(alpha = 0.9,
                           discrete = T, 
                           na.value = "grey60") +
        labs(x = NULL, 
             y = NULL,
             title = "GDP Per Capita", 
             subtitle = "As of 2001, in current USD") +
        theme_tufte() +
        theme(
                plot.title = element_text(hjust = 0),
                plot.subtitle = element_text(hjust = 0),
                legend.text = element_text(size = 10),
                legend.title = element_blank(),
                legend.justification = c(0,0), 
                legend.position = c(0.5, 0),
                legend.background = element_rect(fill="transparent", linetype = 0),
                axis.line = element_blank(),
                axis.text.x = element_blank(),
                axis.text.y = element_blank(),
                axis.ticks = element_blank(),
                axis.title.x = element_blank(),
                axis.title.y = element_blank(),
                panel.grid.major = element_blank(),
                panel.grid.minor = element_blank(),
                panel.border = element_blank()
        )
dev.off()

png(file = "Results/figures/femaleRegWageMap.png", height = 800, width = 800, res = 200)
ggplot() + 
        geom_polygon(data = indiaShape, aes(fill = emp_rwg_f, x = long, y = lat, group = group)) + 
        geom_path(data = gqShape, aes(x = long, y = lat, group = group), color = "white", size = 1) +
        coord_equal() +
        scale_fill_viridis(alpha = 0.9,
                           discrete = T, 
                           na.value = "grey60") +
        labs(x = NULL, 
             y = NULL,
             title = "Female Regular Wage Earners", 
             subtitle = "As a percentage of total employment in 2001") +
        theme_tufte() +
        theme(
                plot.title = element_text(hjust = 0),
                plot.subtitle = element_text(hjust = 0),
                legend.title = element_blank(),
                legend.text = element_text(size = 10),
                legend.justification = c(0,0), 
                legend.position = c(0.5, 0),
                legend.background = element_rect(fill="transparent", linetype = 0),
                axis.line = element_blank(),
                axis.text.x = element_blank(),
                axis.text.y = element_blank(),
                axis.ticks = element_blank(),
                axis.title.x = element_blank(),
                axis.title.y = element_blank(),
                panel.grid.major = element_blank(),
                panel.grid.minor = element_blank(),
                panel.border = element_blank()
        )
dev.off()

