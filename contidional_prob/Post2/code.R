ride = read.csv("~/Google Drive/Bike Share/Introduction/2014-Q2-Trips-History-Data.csv")
# Step 0: Organize the data
## Set registered and Weekday rides in June
ride = ride[which(ride$Subscriber.Type =="Registered"),]
ride = ride[which(weekdays(as.Date(ride$Start.date,"%m/%d/%Y %H:%M")) %in% c("Monday","Tuesday","Wednesday","Thursday","Friday")),]
ride = ride[which(months(as.Date(ride$Start.date,"%m/%d/%Y %H:%M")) %in% c("June")),]
stations = stations[-c(320:345),] # remove not available stations
## Add new feature to database
rides$Start.dateWithinMonth = as.numeric(format(as.Date(ride$Start.date,"%m/%d/%Y %H:%M"),format = "%d"))

## get time Total matrix
start_by_stations = matrix(rep(0,nrow(stations)*24),nrow = nrow(stations), ncol = 24)
not_found = c() # store all not fount stations
for(i in c(1:nrow(ride))){
  temp = ride[i,]
  if(length(station.id_to_index(temp[[4]]))==0){
    not_found = c(not_found, temp[[4]])
  }else{
    start_by_stations[station.id_to_index(temp[[4]]),time_to_hour(temp[[2]])+1] = start_by_stations[station.id_to_index(temp[[4]]),time_to_hour(temp[[2]])+1]+ 1
  }
}
not_change.start_by_staions = start_by_stations

## get time matrix by day, time, stations
#### Use tips:
#### get # of rides by stations -> apply(start_day_stations,3,sum)
#### get # of rides by days -> apply(start_day_stations,1,sum)
#### get # of rides by time -> apply(start_day_stations,2,sum)
level.day = unique(rides$Start.dateWithinMonth)
level.day = sort(level.day)
start_day_stations = array(rep(0,length(level.day) * 24 * nrow(stations)), dim = c(length(level.day),24,nrow(stations))) ### Count by day, time, start.Station
not_found = c()
for(i in c(1:nrow(ride))){
  temp = ride[i,]
  if(length(station.id_to_index(temp[[4]]))==0){
    not_found = c(not_found, temp[[4]])
  }else{
    start_day_stations[which(level.day == time_to_day(temp[[2]]))[1],time_to_hour(temp[[2]])+1,station.id_to_index(temp[[4]])] =        start_day_stations[which(level.day == time_to_day(temp[[2]]))[1],time_to_hour(temp[[2]])+1,station.id_to_index(temp[[4]])]+ 1
}
}
not_change.start_day_staions = start_day_stations 

#Step 1: Get P(s)
### Total P(s) in June
#dist.ss = rowSums(start_by_stations)
#prob.ss = dist.ss/sum(dist.ss)
stations$freq = dist.ss
hist(prob.ss, main = "Distribution of P(s) in 1 month")
abline(v = 1/nrow(stations),col = "red")
boxplot(prob.ss, main = "Distribution of P(s) in 1 month")

start_by_day_stations = apply(start_day_stations,c(1,3),sum) ## (day,station)
prob_day_stations = sweep(start_by_day_stations,1,rowSums(start_by_day_stations),`/`)
plot(start_by_day_stations[1,],type = "l")
for(i in c(2:20))
{lines(start_by_day_stations[i,],col = i + 3)}

library(matrixStats)
plot(colVars(start_by_day_stations))
plot(colVars(start_by_day_stations),colSums(start_by_day_stations))
## ANOVA test - longtitude, latitude
aov1 = lm(freq~latitude * longitude,data = stations)
summary(aov1)



## sample and test
temp.sample = sample(21, 15, replace = FALSE, prob = NULL)
sample = colMeans(prob_day_stations[temp.sample,])
test = colMeans(prob_day_stations[-temp.sample,])
par(mfrow=c(2,2))
plot(sample,cex = 0.7,main = "fitted vs true(red)",xlab = "station_index")
points(test,col = 2,cex = 0.7)
residual = sample - test
standard_resid = residual/sqrt(var(residual))
plot(residual,main = "Residual",xlab = "station_index")
abline(0,0)
plot(standard_resid~sample,main = "standard residual vs fitted",xlab = "fitted")
residual = sum(residual^2)/length(residual)
## calculate mse
predict = colMeans(prob_day_stations)
error = sweep(prob_day_stations,2,colMeans(prob_day_stations),`-`)
mse = sum(error^2)/length(error)
##method 2
#### plot
plot.stations = stations
plot.stations$freq <- cut(stations$freq, 50, label = FALSE)
colr <- rev(terrain.colors(20))

plot(latitude ~ longitude,data = plot.stations,
     col = colr[freq], pch = 20,main = "Stations: # of rides vs location")
legend.col(col = colr, lev = plot.stations$freq) 

plot.stations$predict <- cut(stations$predict, 50, label = FALSE)
colr <- rev(terrain.colors(20))

  

plot(latitude ~ longitude,data = plot.stations,
     col = colr[predict], pch = 20,main = "Predict # of rides vs location")
legend.col(col = colr, lev = plot.stations$predict) 

temp$latitude = scale(temp$latitude)
temp$longitude = scale(temp$longitude)
aov1 = lm(freq~latitude + I(latitude ^ 2) +  longitude + I(longitude ^ 2) + latitude * longitude,data = stations)
summary(aov1)
stations$predict = predict(aov1, temp)

#### Step2: Get P(t|s)
##### method 1:empirical proportion
dist.ts = sweep(start_day_stations,c(1,3),apply(start_day_stations,c(1,3),sum),`/`)
dist.ts[which(is.na(dist.ts))] = 0
#### test
sample.ts = apply(dist.ts[temp.sample,,],c(2,3),mean)
colSums(sample.ts)
sample.ts= sweep(sample.ts,2,colSums(sample.ts),`/`)
sample.ts[which(is.na(sample.ts))] = 0
test.ts = apply(dist.ts[-temp.sample,,],c(2,3),mean)
colSums(test.ts)
test.ts= sweep(test.ts,2,colSums(test.ts),`/`)
test.ts[which(is.na(test.ts))] = 0
residual = sample.ts - test.ts
par(mfrow=c(2,2))
plot(rep(c(1:24),319),residual,cex = 0.5, xlab = "Time",main = "residual vs time")
plot(rep(1:319, each = 24),residual,cex = 0.1, main = "residual vs station index",xlab = "station_index")
residual = c(residual)
standard_resid = residual/sqrt(var(residual))
sample = c(sample.ts)
plot(standard_resid~sample,main = "standard residual vs fitted",xlab = "fitted",cex = 0.5)

## calculate mse
predict =apply(dist.ts,c(2,3),mean)
error = c(sweep(dist.ts,c(2,3),predict,`-`))
mse = sum(error^2)/length(error)

### method 2: cluster:
cluster_set = apply(start_day_stations,c(2,3),sum)
cluster.prob = sweep(cluster_set,2,colSums(cluster_set),`/`)
sample = sample(319,100)
plot(c(1:24),cluster.prob[,253],type = "l",main = "P(t|s) for all stations",xlab = "time",ylab = "p(t|s)")
for(i in c(1:length(sample))){
  lines(c(1:24),cluster.prob[,i])
}
### get k value
matplot(cluster.prob,)
mydata = t(cluster.prob[,-36])
wss <- (nrow(mydata)-1)*sum(apply(mydata,2,var))
for (i in 2:10) wss[i] <- sum(kmeans(mydata,centers=i)$withinss)
plot(1:10, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares",main = "group sum of squares by # of clusters")
### k = 3
sse_list = c()
max_k = 50
for(i in c(2:max_k)){
  remove(fit,sse,fit2)
  k = i
  fit = kmeans(mydata,k)
  sse = fit$tot.withinss
  for(j in c(1:1000)){
    mydata = t(cluster.prob[,-36])
    fit2 <- kmeans(mydata,k)
    if(fit2$tot.withinss < sse){
      fit = fit2
      sse = fit2$tot.withinss
      print(sse)
    }
  }
  sse_list = c(sse_list, sse)
}

plot(c(2:max_k)[1:50],sse_list[1:50],type = "b",xlab="Number of Clusters",
     ylab="Within groups sum of squares",main = "group sum of squares by # of clusters",ylim = c(0,15))

par(mfrow=c(3,2))
for(i in c(11:13)){
  remove(fit,sse)
  k = i
  fit <- kmeans(mydata, k) # 5 cluster solution
  sse = fit$tot.withinss
  for(j in c(1:1000)){
    mydata = t(cluster.prob[,-36])
    fit2 <- kmeans(mydata,k)
    if(fit2$tot.withinss < sse){
      fit = fit2
      sse = fit2$tot.withinss
      print(sse)
    }
  }
  # get cluster means 
  cluster.means = aggregate(mydata,by=list(fit$cluster),FUN=mean)
  # append cluster assignment
  mydata <- data.frame(mydata, fit$cluster)
  matplot(t(cluster.means[c(2:25)]),type = "l",lty = 1, main = paste("k =",k, "errors =",format(sse,nsmall = 2,digits = 2)),xlab = "time", ylab = "cluster means")
  legend("top",legend=c(1:k),lty=1,col = c(1:k),bty="n",y.intersp = 0.2)
  length(which(mydata$fit.cluster == 2))
  cluster.length = aggregate(mydata,by=list(fit$cluster),FUN=length)$fit.cluster
  barplot(cluster.length,xlim = c(0,13),ylim = c(0,200), main = "# of stations in each cluster",names.arg=c(1:k),xlab = "cluster",ylab = "# of stations")
}
mydata$cluster = fit$cluster

#png(filename="a.png")
par(mfcol = c(5,1))
for(i in  c(1:7)){
  this.cluster = mydata[mydata$cluster == i,]
  matplot(t(this.cluster[c(1:24)]),type = "l",col = i)
}
dev.off()

