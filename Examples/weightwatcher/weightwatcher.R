Sys.setenv(NOAWT = "true")
library('httr')
library('rjson')
library('RCurl')
library('XML')

setwd("/home/guest/")
source("weightwatcher/common/common.R")

username <- "stefano"
userid <- 7
fitbitkey <- "a7dd1c18a2a64dbcbd11e10482c8d5ef"                          
fitbitsecret <- "ff877fa1f54741ae93a549bdb2d7e900"
fitbitappname <- "TheNudgeMachine" 
pushoveruser <- "u8JjTgEDJxz2zkkHaK5VM57iDZJsz6"

weightDF <- getWeightObservations( username, fitbitkey, fitbitsecret, fitbitappname )

#url <- "http://localhost:8080"
url <- "http://192.168.59.103:8080"
#url <- "http://127.0.0.1:8080"
#url <- "http://54.153.151.37:8080"

url <- paste(url, "/kie-server/services/rest/server/containers/watch", sep = "")

request <- buildNudgeRequest( userid = userid, username, weightDF )
list <- postNudgeRequest( url, request )

length <- length(list)-2
for ( i in 2:length ) {
  msgtxt <- as.character( list[[i]]$com.redhat.weightwatcher.Fact$facttxt )
  msgtxt <- paste(msgtxt, ". To opt-out from nudges visit: ", "http://www.thenudgemachine.com/rulesettings.php", sep = "")       
  sendPushover(pushoveruser, msgtxt)  
  print( msgtxt )  
}
