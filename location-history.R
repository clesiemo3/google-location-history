#unzip("takeout-20160320T033826Z.zip")
library(rjson)
jsonFile <- "./Takeout/Location History/LocationHistory.json"
jsonData <- fromJSON(file=jsonFile)
#as.double(jsonData$locations[[1]]$timestampMs)/1000