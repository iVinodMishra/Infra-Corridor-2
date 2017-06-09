
## This file creates a new shape file for nsew that reflects completion as of 2011
source("Data Code/Highway distance calculations/nsewCompleted.R")

## This file calculates the distance of districts from the GQ and NSEW (Takes a long time to run)
source("Data Code/Highway distance calculations/calculateHighwayDist.R")

##This file creates a straight lines between nodal points on GQ and NSEW and calculates distance to district centers
source("Data Code/Highway distance calculations/calculateStraightLineDist.R")

##This file identifies the different district types.
source("Data Code/Highway distance calculations/identifyNodalDistricts.R")