#### read in stations information ####

require(jsonlite)
dat <- fromJSON("stations.json")
id = as.numeric(substr(dat$network$stations$name,1,5))
name = substr(dat$network$stations$name,9,100)
latitude = dat$network$stations$latitude
longitude = dat$network$stations$longitude
stations = data.frame(id,name,latitude,longitude) 
remove(id,name,latitude,longitude,dat)
write.csv(stations, file = "stations.csv", quote=FALSE, row.names=TRUE)

