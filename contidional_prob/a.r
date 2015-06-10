ride
json = ""
library("rjson")
date = as.Date(as.POSIXlt(ride$Start.date,format = "%m/%d/%Y %H:%M"))
range = which(date == unique(date)[1])
temp.ride = ride[range,]
json = json.add_property(json,"date",unique(date)[1])
json = output.ridership.json(temp.ride,json)

sink("ride.json")
cat('{',json,'}')
sink()
output.ridership.json <- function(ridership,json,filename){
  minstart = as.numeric(as.POSIXlt(ridership$Start.date[length(ridership[,1])],format = "%m/%d/%Y %H:%M"))
  start = (as.numeric(as.POSIXlt(ridership$Start.date,format = "%m/%d/%Y %H:%M"))-minstart)/60
  end = (as.numeric(as.POSIXlt(ridership$End.date,format = "%m/%d/%Y %H:%M"))-minstart)/60
  duration = end - start
  station_s = ridership$Start.terminal
  station_e = ridership$End.terminal
  riderlist = data.frame(start = rev(start),duration = rev(duration),station_s = rev(station_s),station_e = rev(station_e))
  #json = json.add_property(json,"start_time",ridership$Start.date[length(ridership[,1])])
  json = json.add_property(json,"trips",json.toarray(riderlist))
  #sink(paste('data/',filename,'.json',sep = ''))
  #cat('{',json,'}')
  #sink()
  }