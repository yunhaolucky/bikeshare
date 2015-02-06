ride = read.csv("~/Google Drive/Bike Share/Introduction/2014-Q2-Trips-History-Data.csv")


#### Set registered and Weekday rides in June
ride = ride[which(ride$Subscriber.Type =="Registered"),]
ride = ride[which(weekdays(as.Date(ride$Start.date,"%m/%d/%Y %H:%M")) %in% c("Monday","Tuesday","Wednesday","Thursday","Friday")),]
ride = ride[which(months(as.Date(ride$Start.date,"%m/%d/%Y %H:%M")) %in% c("June")),]
stations = stations[-c(320:345),]
##### get time matrix ######
start_by_stations = matrix(rep(0,nrow(stations)*24),nrow = nrow(stations), ncol = 24)

not_found = c()
for(i in c(1:nrow(ride))){
  temp = ride[i,]
  if(length(station.id_to_index(temp[[4]]))==0){
    not_found = c(not_found, temp[[4]])
  }else{
    start_by_stations[station.id_to_index(temp[[4]]),time_to_hour(temp[[2]])+1] = start_by_stations[station.id_to_index(temp[[4]]),time_to_hour(temp[[2]])+1]+ 1
  }
}
#start_by_stations = not_change.start_by_staions
which(rowSums(start_by_stations) == 0)
start_by_stations = start_by_stations[-c(320:345),]
#### standardize variables

# Determine number of clusters

mydata = start_by_stations
mydata = scale(mydata)
wss <- (nrow(mydata)-1)*sum(apply(mydata,i,var))
for (i in 2:50) wss[i] <- sum(kmeans(mydata,i)$withinss)
dev.off()
plot(1:50, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares",main = "group sum of squares by # of clusters")
# K-Means Cluster Analysis
k = 6
fit <- pam(mydata, k) # 5 cluster solution
# get cluster means 
cluster.means = aggregate(mydata,by=list(fit$cluster),FUN=mean)
# append cluster assignment
mydata <- data.frame(mydata, fit$cluster)
length(which(mydata$fit.cluster == 2))
library(cluster) 
clusplot(mydata, fit$cluster, color=TRUE, shade=TRUE, cex = 0.1,
         labels=2, lines=0)
library(fpc)
plotcluster(mydata, fit$cluster)
#hist(list(cluster.means[1,]))
par(mfcol = c(ceiling(k/2),2))
for(i in 1:k){
  plot(as.numeric(cluster.means[i,-c(1,26)]),type = "b",ylim = c(-1,3))
}
dev.off()

