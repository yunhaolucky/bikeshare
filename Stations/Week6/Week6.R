setwd(paste(getwd(),"/Stations",sep = ""))
source("Week6/Helper.R")
store = ridership
# input stasions information(id, name, latitude, longtitude)
stations <- read.csv("stations.csv")
# input ridership information
ridership <- read.csv("2014-Q2-Trips-History-Data.csv")
# Use riderships on 2014-6-30 as sampmle 
ridership = ridership[c(1:10604),]
#Add riding distance and average speed to data frame
ridership = add_distance_speed(ridership)
write.csv(ridership, file = "rideJune30.csv", quote=FALSE, row.names=FALSE)

### Find all replicates 
s = sort(stations$id)
for(i in 1:352){
  if (s[i] == s[i+1]){print(s[i])}
}

#### Find NA in ridership  and remove it
which(is.na(ridership$End.terminal))
ridership = ridership[c(1:8677,8679:10604),]

### write to json file for javescript reading
output.ridership.json(ridership,"rideJune3012")
