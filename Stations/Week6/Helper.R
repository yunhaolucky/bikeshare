distance <- function(p1.lat,p1.lon,p2.lat,p2.lon,units = "mile"){
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

d_to_r <- function(degree){
  
}