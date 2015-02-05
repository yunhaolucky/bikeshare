station.lat <- function(id){
  return(stations[stations$id == id,]$latitude)
}

station.lon <- function(id){
  return(stations[stations$id == id,]$longitude)
}


station.id_to_index <- function(id){
  return(which(stations==id)[1])
}
station.name <- function(id){
  return(stations[stations$id == id,]$name)
}

ride.start_terminal<- function(id){
  return(ride[ride$Start.terminal == id,])
}

time_to_hour <- function(time){
  # Return num of minutes after 00:00 at the current time
  # Args:
  #   time(string): time in the format of "%m/%d/%Y %H:%M" or "%Y-%m-%d %H:%M:%S"
  # Return:
  #   number of minutes range(0-1440)
  temp = as.POSIXlt(strptime(time,"%m/%d/%Y %H:%M"))
  if(is.na(temp) == FALSE){
    return(temp[[3]])
  }else{
    temp = as.POSIXlt(strptime(time,"%Y-%m-%d %H:%M:%S"))
    return(temp[[3]])
  }
}