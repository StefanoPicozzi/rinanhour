# Pull down observations and apply all rules
Sys.setenv(NOAWT = "true")

library(rjson)

rooturl <- "https://nudgeserver-spicozzi.rhcloud.com/tnm/rest"
setwd("~/GitHub/tnmbatch/R/lifecoach")
source("../common/common.R")

programid <- 1
userid <- 7
obsname <- "weight"
rulename <- "weight"

# Get observations for this programid and userid
userobsDF <- getUserobsDF(rooturl, programid, userid, obsname)
if ( nrow(userobsDF) > 1000 ) { 
  userobsDF <- subset( userobsDF, regexpr( Sys.Date(), userobsDF[, "obsdate"]) > 0)
}

