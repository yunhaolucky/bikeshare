station.lat <- function(id){
  return(stations[stations$id == id,]$latitude)
}

station.lon <- function(id){
  return(stations[stations$id == id,]$longitude)
}

station.name <- function(id){
  return(stations[stations$id == id,]$name)
}

ride.start_terminal<- function(id){
  return(ride[ride$Start.terminal == id,])
}