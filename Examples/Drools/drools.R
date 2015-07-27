Sys.setenv(NOAWT = "true")
library("httr")
library("rjson")
library("RCurl")
library("Rdrools6")
ls("package:Rdrools6", all = TRUE)
lsf.str("package:Rdrools6", all = TRUE)

setwd("/home/guest")
source("Withings/getWithingsWeight.R")

inputDF <- weightDF
input.columns <- colnames(inputDF)

# Set up some sample output data
output.columns <-c ("id", "rulename", "ruledate", "rulemsg", "ruledata")

# set up rules file
rules <- readLines("Drools/weight.drl")
mode <- "STREAM"

# Apply rules
rules.session <- rulesSession(mode, rules, input.columns, output.columns)
outputDF <- runRules(rules.session, inputDF)






