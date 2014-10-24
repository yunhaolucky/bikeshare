train <- read.csv("~/Google Drive/Bike Share/train.csv", stringsAsFactors=FALSE)
test <- read.csv("~/Google Drive/Bike Share/test.csv", stringsAsFactors=FALSE)
### Set variable type ###


preprocess <- function(data){
  data$season = factor(data$season,levels = c(1,2,3,4),ordered = FALSE)
  data$holiday = factor(data$holiday,levels = c(0,1),ordered = FALSE)
  data$workingday = factor(data$workingday,levels = c(0,1),ordered = FALSE)
  data$weather = factor(data$weather,levels = c(4,3,2,1),ordered = TRUE)
  data$datetime = as.POSIXct(data$datetime, tz = "EST", format = "%Y-%m-%d %H:%M:%S")
  holiday.level = c("Not_holiday", "holiday")
  workingday.level = c("Not_workingday", "workingday")
  season.level = c("winter", "spring", "summer","fall")
  weather.level = c("heavy rain","rain","mist", "clear")
  
  ### Compute New Variable -> hour ###
  data$hour =  as.numeric(strftime(data$datetime, format="%H"))
  data$hour = factor(data$hour,ordered = TRUE)
  data$month = as.numeric(strftime(data$datetime, format="%m"))
  data$month = factor(data$month,ordered = TRUE)
  month = as.numeric(strftime(data$datetime, format="%m"))
  #month = factor(data$month,ordered = TRUE)
  data$season[month %in% c(12,1,2)] = 1
  data$season[month %in% c(3,4,5)] = 2
  data$season[month %in% c(6,7,8)] = 3
  data$season[month %in% c(9,10,11)] = 4

  ### Compute New Variable -> weekday ###
  data$weekday = factor(weekdays(data$datetime))
  ### Standardize the numeric variable ###
  scale(data$temp, center = TRUE, scale = FALSE)
  scale(data$atemp, center = TRUE, scale = FALSE)
  scale(data$humidity, center = TRUE, scale = FALSE)
  scale(data$windspeed, center = TRUE, scale = FALSE)
  return(data)
}
rmlse_evaluation <- function(benchmark, predict_value, target_value){
  predict_value[predict_value< benchmark] = benchmark
  rmsle = ((1/length(predict_value))*sum((log(predict_value+1)-log(target_value+1))^2))^0.5
  return(rmsle)
}
print_output <-function(testdata,predict_value,filename){
  output <- data.frame(datetime=testdata[,1], count=predict_value)
  write.csv(output, file=filename, quote=FALSE, row.names=FALSE)
}
set_benchmark <-function(data,benchmark){
  data[data < benchmark] = benchmark
  return(data)
}

### Preprocess the value ###
train = preprocess(train)
test = preprocess(test)

interaction_plot <- function(x_factor,trace_factor,data,trace_label,x_label){
  
  png(file=paste("Week3//image//",x_label,"_",trace_label,".png", sep = ""),
      width=1000, 
      height=400,
      )
  layout(matrix(c(1,2,3),1,3,byrow=FALSE))
  interaction.plot(x_factor,trace_factor,data$count,col=c(1,3,2,4,5:10),lt = 1,trace.label =trace_label,fixed = TRUE,xlab = x_label,main="count",legend = FALSE)
  legend("topleft",title = trace_label, legend = levels(trace_factor),lty = 1,col=c(1,3,2,4,5:10),cex = 1.5,bty = "n",pt.lwd = 0.5)
  interaction.plot(x_factor,trace_factor,data$registered,col=c(1,3,2,4,5:10),lt = 1,trace.label =trace_label,fixed = TRUE,xlab = x_label,main="registered",legend = FALSE)
  interaction.plot(x_factor,trace_factor,data$casual,col=c(1,3,2,4,5:10),lt = 1,trace.label =trace_label,fixed = TRUE,xlab = x_label,main="casual",legend = FALSE) 
  dev.off()
}

numeric_list = list(train$temp,"temp",train$atemp,"atemp",train$humidity,"humidity",train$windspeed,"windspeed",train$hour,"hour")
dim(numeric_list) = c(2,length(numeric_list)/2)
factor_list = list(train$season,"season",c("winter","spring","summer","fall"),train$holiday,"holiday",c("Not_holiday", "holiday"),train$workingday,"workingday",c("Not_workingday", "workingday"),train$weather,"weather",c("heavy rain","rain","mist", "clear"))
dim(factor_list) = c(3,length(factor_list)/3)

for(m in 1:length(factor_list)/3){
  trace.plot = factor(factor_list[[1,m]],labels=factor_list[[3,m]],ordered=TRUE)
for (n in 1:length(numeric_list)/2){
  interaction_plot(numeric_list[[1,n]], trace.plot,train,factor_list[[2,m]],numeric_list[[2,n]])
}
for(k in m+1:length(factor_list)/3){
  interaction_plot(factor_list[[1,k]], trace.plot,train,factor_list[[2,m]],factor_list[[2,k]])
}
}

season.plot = factor(train$season,labels=c("winter","spring","summer","fall"),ordered=TRUE)
interaction_plot(train$atemp,season.plot,train,"season","atemp")
workingday.plot  = factor(train$workingday,labels=c("Not_workingday", "workingday"),ordered=TRUE)
interaction_plot(train$temp,workingday.plot,train,"workingday","temp")
interaction_plot(train$atemp,workingday.plot,train,"workingday","atemp")

interaction.plot(train$atemp,factor(train$season,labels=c("winter","spring","summer","fall"),ordered=TRUE),train$count,col=c(1,3,2,4),lt = 1,trace.label = "season",fixed = TRUE,legend = FALSE)
legend("topleft",title = "season", legend = c("winter","spring","summer","fall"),lty = 1,col=c(1,3,2,4),cex = 0.9,bty = "n")
interaction.plot(train$temp,factor(train$season,labels=c("winter","spring","summer","fall"),ordered=TRUE),train$count,col=c(1,3,2,4),lt = 1,trace.label = "season",fixed = TRUE)
interaction.plot(train$windspeed,factor(train$season,labels=c("winter","spring","summer","fall"),ordered=TRUE),train$count,col=c(1,3,2,4),lt = 1,trace.label = "season",fixed = TRUE)
interaction.plot(train$humidity,factor(train$season,labels=c("winter","spring","summer","fall"),ordered=TRUE),train$count,col=c(1,3,2,4),lt = 1,trace.label = "season",fixed = TRUE)

interaction.plot(train$humidity,factor(train$workingday,labels=c(wo),ordered=TRUE),train$count,col=c(1,3,2,4),lt = 1,trace.label = "season",fixed = TRUE)




# Exacting Features and Target
count.feature = train[,-c(10,11)]
count.target = train[,12]

### Linear Regression of COUNT ####
train.lm <- lm(count ~ ., data=count.feature)
summary(train.lm)
a = rmlse_evaluation(benchmark = 10, predict_value = predict(train.lm,count.feature ), target = count.target)
test.predict.lm = predict(train.lm, test)
test.predict.lm[test.predict.lm<10] = 10
print_output(test,test.predict.lm,filename="lm_result.csv")

### glm ###
train.glm <- glm(count ~ 1+., data=count.feature,family = poisson(link = "log"))
summary(train.glm)
predict_value = 2^predict(train.glm,count.feature )
a = rmlse_evaluation(benchmark = 10, predict_value = 2^predict(train.glm,count.feature ), target = count.target)
test.predict.glm = 2^predict(train.glm, test)
test.predict.glm[test.predict.glm<10] = 10
print_output(test,test.predict.glm,filename="glm_result.csv")

#Proportion of casual rides
prop_casual = train$casual/train$count

### Combination ###
#### Exact Feature and Target ####
casual.feature = train[,-c(11,12)]
casual.target = train[,10]
registered.feature = train[,-c(10,12)]
registered.target = train[,11]

### Linear regression casual count ####
train.casual.lm <- lm(casual ~.*., data = casual.feature)
train.predict.casual.lm = predict(train.casual.lm,casual.feature);
rmlse.casual = rmlse_evaluation(benchmark = 2,predict_value = train.predict.casual.lm, target = casual.target)
test.predict.casual.lm = predict(train.casual.lm,test)
test.predict.casual.lm = set_benchmark(data = test.predict.casual.lm,benchmark = 2)

### Linear regression registered count ####
train.lm.registered= lm(registered ~.*., data = registered.feature)
train.predict.registered.lm = predict(train.lm.registered,registered.feature)
rmlse.registered = rmlse_evaluation(benchmark = 8, predict_value = train.predict.registered.lm , target = registered.target)
test.predict.registered.lm = predict(train.lm.registered, test)
test.predict.registered.lm = set_benchmark(data = test.predict.registered.lm,benchmark = 8)

ratio = 10*train$registered/train$count
train.glm <- glm(ratio ~ .*., data=count.feature,family = poisson())
ratio.predict = predict(train.glm,count.feature)
### Combine count = casual + registered ###
train.predict.count.lm = train.predict.registered.lm + train.predict.casual.lm
rmlse.combine = rmlse_evaluation(benchmark = 10,predict_value = train.predict.count.lm, target = count.target)
test.predict.count.combine = test.predict.casual.lm + test.predict.registered.lm
test.predict.count.combine = set_benchmark(data = test.predict.count.combine,benchmark = 10)
print_output(test,test.predict.count.combine,filename="combine_result.csv")
train.predict.combine = predict(train.casual.lm,casual.feature) + predict(train.lm.registered,registered.feature)
r_squared = 1 - sum((count.target-train.predict.combine)^2)/sum((count.target-mean(count.target))^2)
