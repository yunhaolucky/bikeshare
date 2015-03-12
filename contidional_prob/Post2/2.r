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
par(mfrow = c(3,2))
k = 5
mydata = start_by_stations
mydata = scale(mydata)
for(i in c(2:4)){
k = i
fit <- kmeans(mydata, k) # 5 cluster solution
# get cluster means 
cluster.means = aggregate(mydata,by=list(fit$cluster),FUN=mean)
# append cluster assignment
mydata <- data.frame(mydata, fit$cluster)
matplot(t(cluster.means[c(2:25)]),type = "l",lty = 1)
legend("top",legend=c(1:k),lty=1,col = c(1:k),bty="n")
length(which(mydata$fit.cluster == 2))
cluster.length = aggregate(mydata,by=list(fit$cluster),FUN=length)$fit.cluster
barplot(cluster.length,xlim = c(0,8),ylim = c(0,200), main = "# of stations in each cluster",names.arg=c(1:k),xlab = "cluster",ylab = "# of stations")
}

library(cluster) 
clusplot(mydata, fit$cluster, color=TRUE, shade=TRUE,cex = 0.3, 
         labels=2, lines=0)
library(fpc)
plotcluster(mydata, fit$cluster)
#hist(list(cluster.means[1,]))
par(mfcol = c(ceiling(k/2),2))
for(i in 1:k){
  plot(as.numeric(cluster.means[i,-c(1,26)]),type = "b",ylim = c(-1,3),ylab = "# of bikes",xlab = "time",xlim = c(0,24),main = paste("cluster",i))
}

lmr = vector(length = k,mode="list")
poisson = vector(length = k,mode="list")
for(i in 1:k){
  temp = mydata[which(mydata$fit.cluster == i),c(1:24)]
  time = c()
  rides = c()
  for(j in 1:24){
    rides = c(rides,c(temp)[[j]])
    time = c(time,rep(j - 1,length(c(temp[[j]]))))
  }
  temp = data.frame(time,rides)
  crossValidation(feature = temp,resp = temp$rides,k = 5)
 # poisson[[i]] = glm(rides~poly(time, 3, raw=TRUE), data = temp,family = "poisson")
 # lmr[[i]] = lm(rides~poly(time, 3, raw=TRUE), data = temp)
}
summary(lmr[[1]])
summary(poisson[[5]])

i = 3
temp = mydata[which(mydata$fit.cluster == i),c(1:24)]
crossValidation(feature = temp,resp = temp$rides,k = 5)

crossValidation <-function(feature,resp,k = 5, ...){
  # cross validation
  # Args:
  #   feature : (dataframe) features used to predict resp
  #   resp : (table) actual response values
  #   k : (int) number of folds
  #   method : (function) method use to train and predict 
  #   ... : other arguments of method
  # Returns:
  #   rmsle : rmsle of predict and actual response value
  #   rsquared : rsquared of predict and actual response value
  
  n = nrow(feature)
  fold.size= trunc(n/k) # round size of fold
  order = sample(1:n) # reorder the sample
  
  # split order into k groups
  groups = vector("list",k) 
  for (i in 1:(k - 1)){
    start = (1 + (i - 1) * fold.size)
    groups[[i]] = (order[start:(start + fold.size - 1)])
  }
  groups[[k]] <- order[(1 + (k - 1) * fold.size):n]
  
  # predict using cross_validation 
  models = vector("list",k) ## list of models
  predict.value = rep(NA,n) ## predict values
  for(i in 1:k){
    models[[i]] = glm(rides~poly(time, 3, raw=TRUE),data = feature[-groups[[i]],],family = "poisson")
    predict.value[groups[[i]]] = predict(models[[i]],feature[groups[[i]],])
  }
  r_squared <- evaluate.rsquared(predict = exp(predict.value),actual = resp)
  rmsle <- evaluate.rmsle(predict = exp(predict.value),actual = resp,predict.min = 10)
  #return(list(r_squared = r_squared,rmsle = rmsle,predict.value = predict.value,actual = resp))
  return(list(r_squared = r_squared,rmsle = rmsle))
}

evaluate.rmsle <- function(predict, actual,predict.min = 0){
  # Calculate rmsle of the prediction
  # Args:
  #   predict : a column of dataframe stores the prediced value
  #   actual : a column of dataframe stores the actual value
  # Returns:
  #   rmsle of predict and actual
  rmsle <- ((1/length(predict))*sum((log(predict+1)-log(actual+1))^2))^0.5
  return(rmsle)
}

evaluate.rsquared <- function(predict, actual){
  # Calculate rsquaredof the prediction
  # Args:
  #   predict : a column of dataframe stores the prediced value
  #   actual : a column of dataframe stores the actual value
  # Returns:
  #   r-squared of predict and actual
  a <- 1 - sum((predict - actual)^2)/sum((actual - mean(actual))^2)
  return(a)
}
