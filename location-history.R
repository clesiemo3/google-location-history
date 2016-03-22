#Get your data from: https://takeout.google.com/settings/takeout/custom/location_history?hl=en&gl=US&expflags
#Specify JSON as the output; I went with a .zip but tgz/tbz are fine too.
#unzip("takeout-20160320T033826Z.zip")
library(jsonlite)
library(data.table)
library(reshape)
library(ggplot2)
library(scales)
jsonFile <- "./Takeout/Location History/LocationHistory.json"
#this will take some time...
jsonData <- fromJSON(jsonFile,flatten=T)
history <- data.table(timestamp=as.double(jsonData$locations$timestampMs)/1000 #convert to seconds so we can convert to timestamp from epoch
                      ,latitude=jsonData$locations$latitudeE7/1E7
                      ,longitude=jsonData$locations$longitudeE7/1E7)
history[,dt := as.Date(as.POSIXct(timestamp, origin="1970-01-01"),tz = "America/Chicago")] #timestamp is unix epoch

#filter to work loc data
workLat <- 38.666522
workLong <- -90.557984
#draw a box around work
latMin <- workLat - .005
latMax <- workLat + .005
longMin <- workLong - .01
longMax <- workLong + .01
#filter data table
workHistory <- subset(history,latitude < latMax & latitude > latMin & longitude < longMax & longitude > longMin)

#we need to bucket our data into time ranges
#sort earliest first
workHistory <- workHistory[order(timestamp)]

#day from dt
#workHistory$julianDay <- floor(julian(workHistory$dt, origin = as.Date("1970-01-01")))

#pseudo melt
workHistory$value <- workHistory$timestamp

#for each day, take min and max values at work and return the delta
workCast <- cast(workHistory,dt ~ .,c(min,max))
workCast$hours <- (workCast$max - workCast$min)/(60*60) #60sec/min, 60min/hr

#shave off weekends to avoid times I drive through/go to the mall nearby
workCast <- workCast[weekdays(workCast$dt) != "Saturday" & weekdays(workCast$dt) != "Sunday",]

#interesting to see but dropping for this analysis
#tours in 2013, interview in July '14, and town hall in august '14
#dt        min        max    hours
#1  2013-06-13 1371149458 1371159229 2.714005
#2  2013-06-20 1371753381 1371760428 1.957387
#3  2014-07-09 1404935647 1404941357 1.586099
#4  2014-08-07 1407436369 1407450224 3.848583
workCast <- workCast[workCast$dt > as.Date("2014-08-07"),]

#plot(workCast$dt,workCast$hours) #quick and dirty graph to look at the data
ggplot(workCast,aes(dt,hours)) + 
    geom_point() + geom_smooth() + 
    xlab("Date") + ylab("Hours at Work") + ggtitle("Hours spent at work over time") +
    scale_y_continuous(breaks=round(seq(min(workCast$hours),max(workCast$hours),by=1))) +
    scale_x_date(labels = date_format("%b\n%Y"),breaks=date_breaks("months"))