# Get stations
install.packages("jsonlite")
install.packages('curl')
require(jsonlite)
dat <- fromJSON("http://api.citybik.es/v2/networks/capital-bikeshare?fields=stations")
id = as.numeric(substr(dat$network$stations$name,1,5))
name = substr(dat$network$stations$name,9,100)
latitude = dat$network$stations$latitude
longitude = dat$network$stations$longitude
stations = data.frame(id,name,latitude,longitude) 
remove(id,name,latitude,longitude,dat)
#write.csv(stations, file = "stations.csv", quote=FALSE, row.names=FALSE)

stations
