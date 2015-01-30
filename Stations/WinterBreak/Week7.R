
### stations see week6.R

## CALCULATE OVERALL RIDERSHIP EVERY MINUTE
n_in_service = 0 # Assume no bikes in service before this time range(NEEDS CHANGING)
## riderships that start/end/in_service in the ith min
start_list = c()
end_list = c()
in_service_list = c()
temp2 = riderlist

riderlist = ridership.get_day(ridelist,"7/5/2014")
riderlist$start = sapply(riderlist$Start.date,time_to_min)
riderlist$end = sapply(riderlist$End.date,time_to_min)
i = 1 # iterator
on_road_bikes= c() ### store all bikes that have not been returned yet
for (time in 0:TIME_INTERVALS){
  n_start = 0
  ### count all bikes start in 'time'th min and add them to the bike in service list
  while(riderlist$start[i]<=time & i<= nrow(riderlist)){
    n_start = n_start + 1
    on_road_bikes = c(on_road_bikes,riderlist$end[i])
    i = i + 1
  }
  ### count all bikes that end in 'time'th min and remove them from the bike list
  n_end = length(which(on_road_bikes <= time))
  if(n_end != 0){
    on_road_bikes = on_road_bikes[-which(on_road_bikes <= time)]
  }
  ### calculate number of bikes in service
  n_in_service = n_in_service + n_start - n_end
  print(paste(n_in_service, n_start, n_end))
  ### Store them to the list
  start_list = c(start_list, n_start)
  end_list = c(end_list,n_end)
  in_service_list = c(in_service_list,n_in_service)
  time = time + 1
}
remove(n_start,n_end,n_in_service,on_road_bikes,time)

### print as csv file
print.csv(file_name = "number_of_bikes", min = c(0:TIME_INTERVALS),start = start_list, end = end_list, in_service = in_service_list)
### Plot csv ###
plot(in_service_list,pch = 16,cex = 0.3,col = "green",main = "# of bikes in service on July 5th")
lines(list.mean_by_chucks(in_service_list,30)~list.range_by_list(1441,30),col="blue")
lines(list.mean_by_chucks(start_list,30)~list.range_by_list(1441,30),col="red",type = "l")
lines(list.mean_by_chucks(end_list,30)~list.range_by_list(1441,30),col="black")



points(list.mean_by_chucks(in_service_list,60)~list.range_by_list(1441,60),col="blue")
plot(start_list,pch = 16,cex = 0.3, col="red")
points(end_list,pch = 16,cex = 0.3,col="blue")
lines(list.mean_by_chucks(in_service_list,30)~list.range_by_list(1441,30),col="blue",cex = 1)
plot(in_service_list,pch = 16,cex = 0.3,col = "green",main = "# of bikes in use in service on June 30")

### PICK STATIONS THAT HAVE FULL/EMPTY INFORMATION
station.has_empty_info = vector(mode = "logical",length = nrow(stations)) ### whether a stations has full/empty information
station.has_full_info = vector(mode = "logical",length = nrow(stations))
station.empty_time = vector(mode = "numeric", length = nrow(stations))
station.full_time = vector(mode = "numeric", length = nrow(stations))
for (i in c(1:nrow(full_empty))){ # for each record in ridershiplist
  index = which(stations$id == full_empty$Terminal.Number[i])
  if(length(index) == 0){## stations Not found
    print(paste("not found",full_empty$Terminal.Number[i]))
  }else if(station.has_empty_info[index]==FALSE & full_empty$Status[i]=="empty"){
    station.has_empty_info[index] = TRUE
    station.empty_time[index] = time_to_min(time = full_empty$Start[i])
  }else if(station.has_full_info[index]==FALSE & full_empty$Status[i]=="full"){
    station.has_full_info[index] = TRUE
    station.full_time[index] = time_to_min(time = full_empty$Start[i])
  }
}
## ID of Stations list that have full/empty information
picked_stations = stations[intersect(which(station.has_empty_info == TRUE),which(station.has_full_info == TRUE)),1]
## reverse ridership 
#ridership = ridership[order(nrow(ridership):1),] 
start_by_stations = vector(mode="list",nrow(stations))
end_by_stations = vector(mode="list",nrow(stations)) 
for(i in c(1:nrow(stations))){
  start_by_stations[[i]] = vector(mode = "numeric",TIME_INTERVALS+1)
  end_by_stations[[i]] = vector(mode = "numeric",TIME_INTERVALS+1)
}
for(i in c(1:nrow(ridership))){
  temp = ridership[i,]
  start_by_stations[[station.id_to_index(temp[[4]])]][time_to_min(temp[[2]])+1] = start_by_stations[[station.id_to_index(temp[[4]])]][time_to_min(temp[[2]])+1] + 1
  end_by_stations[[station.id_to_index(temp[[7]])]][time_to_min(temp[[5]])+1] = end_by_stations[[station.id_to_index(temp[[7]])]][time_to_min(temp[[5]])+1] + 1
}

start_bikes = vector(mode = "numeric",nrow(stations))
for(i in c(1:nrow(stations))){
  if(station.empty_time[i] != 0 ){
    temp.time = station.empty_time[i]
    start_bikes[[i]] = sum(start_by_stations[[i]][c(1:temp.time)]) - sum(end_by_stations[[i]][c(1:temp.time)])
  }else{
    start_bikes[[i]]  = -1
  }
}

#sum(start_by_stations[[11]])
#lapply(ridership$Start.date, time_to_min)


### Full & Empty
full_empty <- read.csv("~/Downloads/full:empty2012april-july.csv")
full = full_empty[which(full_empty$Status == "full"),]
empty = full_empty[which(full_empty$Status == "empty"),]
boxplot(full$Duration,empty$Duration)
summary(full$Duration)
full_day = full_empty.get_day(full,"6/30/2012")
full_day$Start = sapply(full_day$Start,time_to_min)
full_day$End = sapply(full_day$End,time_to_min)
empty_day = full_empty.get_day(empty,"6/26/2012")
empty_day$Start = sapply(empty_day$Start,time_to_min)
empty_day$End = sapply(empty_day$End,time_to_min)
start_list = c()
end_list = c()
in_service_list = c()
temp2 = riderlist
n_in_service = 0
riderlist = full_day[rev(rownames(empty_day)),]
i = 1 # iterator
on_road_bikes= c() ### store all bikes that have not been returned yet
for (time in 0:TIME_INTERVALS){
  n_start = 0
  ### count all bikes start in 'time'th min and add them to the bike in service list
  while(riderlist$Start[i]<=time & i<= nrow(riderlist)){
    n_start = n_start + 1
    on_road_bikes = c(on_road_bikes,riderlist$End[i])
    i = i + 1
  }
  ### count all bikes that end in 'time'th min and remove them from the bike list
  n_end = length(which(on_road_bikes <= time))
  if(n_end != 0){
    on_road_bikes = on_road_bikes[-which(on_road_bikes <= time)]
  }
  ### calculate number of bikes in service
  n_in_service = n_in_service + n_start - n_end
  print(paste(n_in_service, n_start, n_end))
  ### Store them to the list
  start_list = c(start_list, n_start)
  end_list = c(end_list,n_end)
  in_service_list = c(in_service_list,n_in_service)
  time = time + 1
}
plot(in_service_list,pch = 16,cex = 0.3,col = "green",main = "# of empty stations in service on June 30th")
lines(list.mean_by_chucks(in_service_list,60)~list.range_by_list(1441,60),col="blue")



