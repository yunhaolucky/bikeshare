setwd(paste(getwd(),"/Stations",sep = ""))
source("Week6/Helper.R")
store = ridership
# input stasions information(id, name, latitude, longtitude)
stations <- read.csv("stations.csv")
# input ridership information
ridership <- read.csv("2014-Q2-Trips-History-Data.csv",)
# Use riderships on 2014-6-30 as sampmle 
ridership = ridership[c(1:10604),]
write.csv(ridership, file = "rideJune30.csv", quote=FALSE, row.names=FALSE)

### Find all replicates 
s = sort(stations$id)
for(i in 1:352){
  if (s[i] == s[i+1]){print(s[i])}
}

#### Find NA in ridership  and remove it
remove = which(is.na(ridership$End.terminal))
ridership = ridership[-remove,]
remove = c(which(is.na(s_lon)),which(is.na(e_lon)))
ridership = ridership[-remove,]

### write to json file for javescript reading
output.ridership.json(ridership,"rideJune3012")

#Add riding distance and average speed to data frame
ridership = add_distance_speed(ridership)
hist(ridership$distance,breaks = 150,main = "Histogram of Riding Distance of ridership",xlab = "distance(miles)")
casual_distance = ridership[ridership$Subscriber.Type == "Casual",]$distance
registered_distance = ridership[ridership$Subscriber.Type == "Registered",]$distance
boxplot(distance~Subscriber.Type,data = ridership,main = "Boxplot of Riding Distance(miles)")

freqs_in = aggregate(ridership$Start.terminal, by=list(ridership$Start.terminal),FUN=length)
freqs_out = aggregate(ridership$End.terminal, by=list(ridership$End.terminal),FUN=length)

# Duration #
