#Get your data from: https://takeout.google.com/settings/takeout/custom/location_history?hl=en&gl=US&expflags
#Specify JSON as the output; I went with a .zip but tgz/tbz are fine too.
#unzip("takeout-20160320T033826Z.zip")
library(rjson)
jsonFile <- "./Takeout/Location History/LocationHistory.json"
jsonData <- fromJSON(file=jsonFile)
#timestamp is unix epoch but loads as a chr so we need to coerce to a double and divide by 1000 to get seconds.
#as.POSIXct(as.double(jsonData$locations[[1]]$timestampMs)/1000, origin="1970-01-01") 