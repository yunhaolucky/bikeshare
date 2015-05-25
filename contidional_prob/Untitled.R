level.day = unique(rides$Start.dateWithinMonth)
level.day = sort(level.day)
start_day_station_end = array(rep(0,length(level.day) * 24 * nrow(stations)*nrow(stations)), dim = c(length(level.day),24,nrow(stations),nrow(stations))) ### Count by day, time, start.Station
#remove(level.day)
not_found = c()
for(i in c(1:nrow(ride))){
  temp = ride[i,]
  if(length(station.id_to_index(temp[[4]]))==0){
    not_found = c(not_found, temp[[4]])
  }else{
    start_day_station_end[which(level.day == time_to_day(temp[[2]]))[1],time_to_hour(temp[[2]])+1,station.id_to_index(temp[[4]]),station.id_to_index(temp[[7]])] =        start_day_station_end[which(level.day == time_to_day(temp[[2]]))[1],time_to_hour(temp[[2]])+1,station.id_to_index(temp[[4]]),station.id_to_index(temp[[7]])]+ 1
  }
}

not_change.start_day_station_end = start_day_station_end

dist.tse = sweep(start_day_station_end,c(1,2,3),apply(start_day_station_end,c(1,2,3),sum),`/`)
dist.tse[is.na(dist.tse)] = 0
sample.tse = apply(dist.tse[temp.sample,,,],c(2,3,4),mean)
test.tse = apply(dist.tse[-temp.sample,,,],c(2,3,4),mean)

for(t in c(1:24)){
plot(latitude ~ longitude,data = plot.stations,
       pch = 20,main = paste("Stations: P(e|s,t) at",t))
colr <- rev(terrain.colors(20))
dist8 = sample.tse[t,,]
for(s in c(1:nrow(dist8))){
  sla = stations$latitude[s]
  slo = stations$longitude[s]
  for(e in c(1:nrow(dist8))){
    if(dist8[s,e] > 0 & s != e){
      ela = stations$latitude[e]
      elo = stations$longitude[e]
      arrows(slo,sla,elo,ela,col = colr[(dist8[s,e] - 0.01)*1000],length = 0.1,lwd =dist8[s,e]*100 )
      print(e)
      print(s)
    }
  }
}
}

resid = sample.tse - test.tse
st_resid = resid/sqrt(var(resid))
plot(st_resid~sample.tse,main = "Residual",cex=0.1)
mse = sum(resid^2) / length(resid)

time = rep(0:23,each = 319*319)
plot(c(st_resid)~time,main = "Residual",cex = 0.1)

#rm(list=setdiff(ls(), c("rides","stations", "not_change.start_by_staions","temp.sample","not_change.start_day_staions")))

#method1：
mse = c()
for(n in c(1:21)){
sample.all = start_day_station_end[-n,,,]
test.all = start_day_station_end[n,,,]
sample.predict = apply(start_day_station_end,c(2,3,4),mean)
sample.predict = sample.predict/sum(sample.predict)
test.all = test.all/sum(test.all)
mse.this = test.all - sample.predict
mse.this = sum(mse.this^2)/length(mse.this)
mse = c(mse,mse.this)
}
mse.final = mean(mse)

#method 2：
mse = c()
for(n in c(1:21)){
sample.all = start_day_station_end[-n,,,]
test.all = start_day_station_end[n,,,]
test.all = test.all/sum(test.all)
# P(s)
this.ride_station = apply(sample.all,c(1,3),sum)
ps = sweep(this.ride_station,1,apply(this.ride_station,1,sum),`/`)
ps[is.na(ps)] = 0
ps = apply(ps,2,mean)
# P(t|s)
this.ride_station_time = apply(sample.all,c(1,2,3),sum)
pts = sweep(this.ride_station_time,c(1,3),apply(this.ride_station_time,c(1,3),sum),`/`)
pts[is.na(pts)] = 0
pts = apply(pts,c(2,3),mean)
# P(e|t,s)
pets = sweep(sample.all,c(1,2,3),apply(sample.all,c(1,2,3),sum),`/`)
pets[is.na(pets)] = 0
pets = apply(pets,c(2,3,4),mean)
## Combine
result = rep(ps,each = 24) * pts
result = rep(result,each = 319) * pets
this.resid = result - test.all
this.mse = sum(this.resid^2)/length(this.resid)
mse = c(mse,this.mse)
}
mean_day_count = mean(apply(this.ride_station,1,sum))
m2.mse = mean(mse) * mean_day_count ^2
plot.sample = sample(24*319*319, 100000)
plot(test.all[plot.sample],resid[plot.sample])
#plot(test.all,resid)

### method 3:
mse3 = c()
for(n in c(1:21)){
  sample.all = start_day_station_end[-n,,,]
  test.all = start_day_station_end[n,,,]
  test.all = test.all/sum(test.all)
  # P(t)
  this.ride_time = apply(sample.all,c(1,2),sum)
  pt = sweep(this.ride_time,1,apply(this.ride_time,1,sum),`/`)
  pt[is.na(pt)] = 0
  pt = apply(pt,2,mean)
  # P(s|t)
  this.ride_time_station = apply(sample.all,c(1,2,3),sum)
  pts = sweep(this.ride_time_station,c(1,2),apply(this.ride_time_station,c(1,2),sum),`/`)
  pts[is.na(pts)] = 0
  pts = apply(pts,c(2,3),mean)
  # P(e|t,s)
  pets = sweep(sample.all,c(1,2,3),apply(sample.all,c(1,2,3),sum),`/`)
  pets[is.na(pets)] = 0
  pets = apply(pets,c(2,3,4),mean)
  ## Combine
  result = rep(pt,319) * pts
  result = rep(result,319) * pets
  this.resid = result - test.all
  this.mse = sum(this.resid^2)/length(this.resid)
  mse3 = c(mse3,this.mse)
}


list_count_ride = data.frame(day = numeric(), time = numeric(), start_station= numeric(),end_station= numeric(),count =numeric() )
for(day in c(1:21)){
  for(time in c(1:24)){
    for(start in c(1:319)){
      for(end in c(1:319)){
        if(start_day_station_end[day,time,start,end]> 0){
          list_count_ride = insertRow(list_count_ride, c(day,time,start,end,start_day_station_end[day,time,start,end]))
        }
      }
    }
  }
}

popular_station = data.frame(name = character(), lat = numeric(), long = numeric(),stringsAsFactors = FALSE)

colnames(popular_station) = c("name","latitude","longitude") 
popular_station = insertRow(popular_station,c("Galary Palace",38.898740, -77.021459))
popular_station = insertRow(popular_station,c("Union Station",38.896993, -77.006422))
popular_station = insertRow(popular_station,c("Capitol Hill",38.8897, -77.0111))

popular_station$latitude = as.numeric(popular_station$latitude)
popular_station$longitude = as.numeric(popular_station$longitude)

stations
distance = matrix(rep(0,nrow(stations)^2),nrow = nrow(stations), ncol = nrow(stations))
for(s in 1:318){
  for (e in (s + 1): 319){
    distance[s,e] = distance_by_index(s,e)
    distance[e,s] = distance[s,e]
    print(e)
  }
}
distance_by_index()
hist(distance)
list_count_ride

for(i in c(1:nrow(popular_station))){
  popular_station_name = paste("start.",popular_station$name[i],sep = "")
  list_count_ride[,popular_station_name]=distance_by_index(list_count_ride$start_station[c(1:nrow(list_count_ride))],i,popular = T)
}

for(i in c(1:nrow(popular_station))){
  popular_station_name = paste("end.",popular_station$name[i],sep = "")
  list_count_ride[,popular_station_name]=distance_by_index(list_count_ride$end_station[c(1:nrow(list_count_ride))],i,popular = T)
}

summary(lm(count~.,data = list_count_ride))
summary(lm(count~.,data = list_count_ride))
apply(list_count_ride,2,sum)
list_count_not_end = aggregate(list_count_ride$count, by=list(list_count_ride$start_station,list_count_ride$time,list_count_ride$day), FUN=sum)
colnames(list_count_not_end) = c("start","time","day","count")
list_count_ride$prob = rep(0, nrow(list_count_ride))
list_count_not_end[order(list_count_not_end$day,list_count_not_end$time,list_count_not_end$start),]
temp.j = 1  
for(i in c(1:nrow(list_count_ride))){
  if(list_count_not_end$start[temp.j] != list_count_ride$start_station[i]){
    temp.j = temp.j + 1
  }
  list_count_ride$prob[i] = list_count_ride$count[i]/list_count_not_end$count[temp.j]
}
list_count_not_end[order(list_count_not_end$day),]
hist(list_count_ride$prob)
colnames(list_count_ride)

list_count_ride$start_station = as.factor(list_count_ride$start_station)
list_count_ride$end_station = as.factor(list_count_ride$end_station)
list_count_ride$s_lat = station.lat(list_count_ride$start_station)
list_count_ride$s_lon = station.lon(list_count_ride$start_station)
list_count_ride$e_lat = station.lat(list_count_ride$end_station)
list_count_ride$e_lon = station.lon(list_count_ride$end_station)

summary(glm(prob~(.-start_station-end_station - count),data = list_count_ride))

list_count_ride$popular_station_name
