station.id_to_index <- function(id){
  return(which(stations==id))
}

insertRow <- function(DF, newrow) {
  DF[nrow(DF) + 1,] = newrow
 return (DF)
}

distance_by_index <- function(s1, s2,u = "mile",popular = F){
  # calculate distance between station1 and station2
  # Args:
  #   s1: station1's index
  #   s2: station2's index
  #   units: result's units in {"mile", "km"}
  # Returns:
  #   distance between s1 and s2
  t1 = stations[s1,]
  if(popular){
    t2 = popular_station[s2,]
  }else{
  t2 = stations[s2,]
  }
  return(calculate_distance(t1$latitude,t1$longitude,t2$latitude,t2$longitude,u))
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


station.lat <- function(id){
  return(stations[id,]$latitude)
}

station.lon <- function(id){
  return(stations[id,]$longitude)
}
