Sys.setenv(NOAWT = "true")
library('httr')
library('rjson')
library('RCurl')

setwd("/Users/stefanopicozzi/Dropbox/Red Hat/RHTE2015/Examples/Withings")

fitbitkey <- "a7dd1c18a2a64dbcbd11e10482c8d5ef"                          
fitbitsecret <- "ff877fa1f54741ae93a549bdb2d7e900"
fitbitappname <- "TheNudgeMachine" 

token_url <- "https://api.fitbit.com/oauth/request_token"
access_url <- "https://api.fitbit.com/oauth/access_token"
auth_url <- "https://www.fitbit.com/oauth/authorize"

fbr <- oauth_app(fitbitappname, fitbitkey, fitbitsecret)
fitbit <- oauth_endpoint(token_url, auth_url, access_url)
#token = oauth1.0_token(fitbit, fbr)
#saveRDS(token, file = paste("user/", username, "/fitbit-token.RDS", sep = ""))
token <- readRDS("fitbit-token.RDS")
sig <- sign_oauth1.0(app=fbr, token=token$oauth_token, token_secret=token$oauth_token_secret)

startdate <- Sys.Date()-30
enddate <- paste(Sys.Date()+1, ".json", sep="")   

getURL <- "https://api.fitbit.com/1/user/-/body/log/weight/date/"
getURL <- paste(getURL, startdate, "/", enddate, sep = "")
print(getURL)
   
weightJSON <- tryCatch({
   GET(getURL, sig)
}, warning = function(w) {
   print("Warning weight")
   stop()
}, error = function(e) {
   print(geterrmessage())
   print("Error GET fitbit weight")
   stop()
}, finally = {
})

if ( length(content(weightJSON)$`weight`) == 0 ) { stop("No fitbit weight records") }

weightDF <- NULL

for (i in 1:length(content(weightJSON)$`weight`)) {
   row <- c( "stefano", paste(content(weightJSON)$`weight`[i][[1]][['date']], " 07:15:00", sep=""), content(weightJSON)$`weight`[i][[1]][['weight']] )
   weightDF <- rbind(weightDF, c(row))
}

colnames(weightDF) = c("username", "obsdate", "obsvalue")
