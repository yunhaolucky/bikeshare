add_distance_speed <- function(data){
  distance = apply(data[,c('Start.terminal','End.terminal')], 1, function(x) distance(x[1],x[2]))
  duration = as.numeric(as.difftime(as.character(data$Duration),"%Hh %Mm %Ss",units="secs"))
  speed = distance/duration
  return(data.frame(data,distance,speed))
}

output.ridership.json <- function(ridership,filename){
  json = ""
  minstart = as.numeric(as.POSIXlt(ridership$Start.date[length(ridership[,1])],format = "%m/%d/%Y %H:%M"))
  start = (as.numeric(as.POSIXlt(ridership$Start.date,format = "%m/%d/%Y %H:%M"))-minstart)/60
  end = (as.numeric(as.POSIXlt(ridership$End.date,format = "%m/%d/%Y %H:%M"))-minstart)/60
  s_lat =to.list(lapply(ridership$Start.terminal, function(x)station.lat(x)))
  s_lon =to.list(lapply(ridership$Start.terminal, function(x)station.lon(x)))
  e_lat = to.list(lapply(ridership$End.terminal, function(x)station.lat(x)))
  e_lon = to.list(lapply(ridership$End.terminal, function(x)station.lon(x)))
  riderlist = data.frame(start = rev(start),end = rev(end),s_lat = rev(s_lat),s_lon = rev(s_lon),e_lat = rev(e_lat),e_lon = rev(e_lon))
  #json = json.add_property(json,"start_time",ridership$Start.date[length(ridership[,1])])
  json = json.add_property(json,"ridership",json.toarray(riderlist))
  sink(paste('data/',filename,'.json',sep = ''))
  cat('{',json,'}')
  sink()
  }

station.lat <- function(id){
  return(stations[stations$id == id,]$latitude)
}

station.lon <- function(id){
  return(stations[stations$id == id,]$longitude)
}

to.list <- function(old){
  res = c()
  for(i in c(1:length(old))){
    res = c(res,old[[i]][1])
  }
  return(res)
}
json.add_property <- function(json, name,value){
  res = paste(json,'"',name,'":',value,sep = "")
  return(res)
}
json.toarray <- function(dtf){
  clnms <- colnames(dtf)
  name.value <- function(i){
    quote <- '';
    if(!class(dtf[, i]) %in% c('numeric', 'integer')){
      quote <- '"';
    }
    paste('"', i, '" : ', quote, dtf[,i], quote, sep='')
  }
  objs <- apply(sapply(clnms, name.value), 1, function(x){paste(x, collapse=', ')})
  objs <- paste('{', objs, '}')
  res <- paste('[', paste(objs, collapse=', '), ']')
  return(res)
}



distance <- function(s1, s2,u = "mile"){
  # calculate distance between station1 and station2
  # Args:
  #   s1: station1's id
  #   s2: station2's id
  #   units: result's units in {"mile", "km"}
  # Returns:
  #   distance between s1 and s2
  t1 = stations[stations$id == s1,]
  t2 = stations[stations$id == s2,]
  return(calculate_distance(t1$latitude,t1$longitude,t2$latitude,t2$longitude,u)[1])
}



calculate_distance <- function(p1.lat,p1.lon,p2.lat,p2.lon,units = "mile"){
  # calculate distance between p1 and p2
  # Args:
  #   p1.lat: point1's latitude
  #   p1.lon : point1's longtitude
  #   p2.lat:
  #   p2.lon:
  #   units: result's units in {"mile", "km"}
  # Returns:
  #   distance between p1 and p2
  rad = pi/180
  dlon = p2.lon - p1.lon 
  dlat = p2.lat - p1.lat 
  a = (sin(dlat*rad/2))^2 + cos(p1.lat*rad) * cos(p2.lat*rad) * (sin(dlon*rad/2))^2 
  c = 2 * atan2( sqrt(a), sqrt(1-a) )
  #The values used for the radius of the Earth (3961 miles & 6373 km) are optimized for locations around 39 degrees from the equator (roughly the Latitude of Washington, DC, USA).
  if(units == "mile"){R = 3931}
  if(units == "km"){R = 6373}
  d = R * c
  return(d)
}

add_distance_speed <- function(data){
  distance = apply(data[,c('Start.terminal','End.terminal')], 1, function(x) distance(x[1],x[2]))
  duration = as.numeric(as.difftime(as.character(data$Duration),"%Hh %Mm %Ss",units="secs"))
  speed = distance/duration
  return(data.frame(data,distance,speed))
}