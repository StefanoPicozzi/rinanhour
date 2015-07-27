Sys.setenv(NOAWT = "true")
library('httr')
library('rjson')
library('RCurl')

setwd("/home/guest")

#url <- "http://localhost:8080"
url <- "http://192.168.59.103:8080"
#url <- "http://127.0.0.1:8080"
#url <- "http://54.153.151.37:8080"

url <- paste(url, "/kie-server/services/rest/server/containers/watch", sep = "")
print(url)

fileName <- 'weightwatcher/put-KIEcontainer.xml';
request <- readChar( fileName, file.info(fileName)$size )

header=c(Connection="close", 'Content-Type'="application/xml", 'Content-length'=nchar(request))

response <- tryCatch({
  PUT(url, body=request, content_type_xml(), header=header, verbose(), authenticate("erics", "jbossbrms1!", type="basic"))
}, warning = function(w) {
  print("Warning PUT")
  stop()
}, error = function(e) {
  print(geterrmessage())
  print("Error PUT")
  stop()
}, finally = {
})

print( content(response, type="application/xml") )