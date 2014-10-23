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
  #data$month = as.numeric(strftime(data$datetime, format="%m"))
  #data$month = factor(data$month,ordered = TRUE)
  month = as.numeric(strftime(data$datetime, format="%m"))
  #month = factor(data$month,ordered = TRUE)
  data$season[month %in% c(12,1,2)] = "winter"
  #data$season[month == 3] = 2
  #data$season[month %in% c(6,7,8)] = 3
  #data$season[month %in% c(9,10,11)] = 4

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

### Preprocess the value ###
train = preprocess(train)
test = preprocess(test)

interaction_plot <- function(x_factor,trace_factor,data,trace_label,x_label){
  layout(matrix(c(1,2,3),1,3,byrow=FALSE))
  interaction.plot(x_factor,trace_factor,data$count,col=c(1,3,2,4,5:10),lt = 1,trace.label =trace_label,fixed = TRUE,xlab = x_label,main="count")
  interaction.plot(x_factor,trace_factor,data$registered,col=c(1,3,2,4,5:10),lt = 1,trace.label =trace_label,fixed = TRUE,xlab = x_label,main="registered")
  interaction.plot(x_factor,trace_factor,data$casual,col=c(1,3,2,4,5:10),lt = 1,trace.label =trace_label,fixed = TRUE,xlab = x_label,main="casual") 
}

numeric_list = list(train$temp,"temp",train$atemp,"atemp",train$humidity,"humidity",train$windspeed,"windspeed",train$hour,"hour")
dim(numeric_list) = c(2,length(numeric_list)/2)

for (n in 1:length(numeric_list)/2){
  season.plot = factor(train$season,labels=c("winter","spring","summer","fall"),ordered=TRUE)
  interaction_plot(numeric_list[[1,n]],season.plot,train,"season",numeric_list[[2,n]])
}

season.plot = factor(train$season,labels=c("winter","spring","summer","fall"),ordered=TRUE)
interaction_plot(train$atemp,season.plot,train,"season","atemp")
workingday.plot  = factor(train$workingday,labels=c("Not_workingday", "workingday"),ordered=TRUE)
interaction_plot(train$temp,workingday.plot,train,"workingday","temp")
interaction_plot(train$atemp,workingday.plot,train,"workingday","atemp")
interaction.plot(train$atemp,factor(train$season,labels=c("winter","spring","summer","fall"),ordered=TRUE),train$count,col=c(1,3,2,4),lt = 1,trace.label = "season",fixed = TRUE)
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
train.glm <- glm(count ~ ., data=count.feature,family = poisson())
summary(train.glm)
a = rmlse_evaluation(benchmark = 10, predict_value = predict(train.glm,count.feature ), target = count.target)
test.predict.glm = predict(train.glm, test)
#test.predict.glm[test.predict.glm<10] = 10
print_output(test,test.predict.glm,filename="glm_result.csv")
#### Interpration of linear regression output
#train.resid = resid(train.lm)
library("MASS")
train.studres = studres(train.lm)
train.studres
plot(train$datetime ~ train.studres)
influence(train.lm)

# Diagnosis of Linear Regression
layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page 
plot(train.lm)


#Proportion of casual rides
prop_casual = train$casual/train$count

### SVM Regressin of COUNT ####
library(e1071)
train.svm = svm(count ~ ., data=count.feature,kernel = "radial")
summary(train.svm)
a = rmlse_evaluation(benchmark = 10, predict_value = predict(train.svm,count.feature), target = count.target)
test.predict.svm = predict(train.svm,test)

print_output(test,test.predict.svm,filename="svm_result.csv")

### Combination ###
#### Exact Feature and Target ####
casual.feature = train[,-c(11,12)]
casual.target = train[,10]
registered.feature = train[,-c(10,12)]
registered.target = train[,11]

### Linear regression casual count ####
train.casual.lm <- lm(casual ~., data = casual.feature)
train.predict.casual.lm = predict(train.casual.lm,casual.feature);
rmlse.casual = rmlse_evaluation(benchmark = 2,predict_value = train.predict.casual.lm, target = casual.target)
test.predict.casual.lm = predict(train.casual.lm,test)
test.predict.casual.lm = set_benchmark(data = test.predict.casual.lm,benchmark = 2)

### Linear regression registered count ####
train.lm.registered= lm(registered ~., data = registered.feature)
train.predict.registered.lm = predict(train.lm.registered,registered.feature)
rmlse.registered = rmlse_evaluation(benchmark = 8, predict_value = train.predict.registered.lm , target = registered.target)
test.predict.registered.lm = predict(train.lm.registered, test)
test.predict.registered.lm = set_benchmark(data = test.predict.registered.lm,benchmark = 8)

### Combine count = casual + registered ###
train.predict.count.lm = train.predict.registered.lm + train.predict.casual.lm
rmlse.combine = rmlse_evaluation(benchmark = 10,predict_value = train.predict.count.lm, target = count.target)
test.predict.count.combine = test.predict.casual.lm + test.predict.registered.lm
test.predict.count.combine = set_benchmark(data = test.predict.count.combine,benchmark = 10)
print_output(test,test.predict.count.combine,filename="combine_result.csv")

#### Pair-wise plot ####
#pairs(~count+season+hour+weather+temp+humidity+windspeed,
#      data=train, 
#      main="Bike Sharing",  
#)

### Evaluation ###
p <- seq(0,1000, by=1)
rmsle <- ((log(p+1)-log(200+1))^2)^0.5
plot(p,rmsle, type="l", main="Basic RMSLE Pattern", xlab="Predicted")

### Count ###
### count in different levels ###
layout(matrix(c(1,2,3),1,3,byrow=FALSE))
hist(train$count, main="Distribution of count",breaks = 100)
hist(train$registered, main="Distribution of registered count",breaks = 100)
hist(train$casual, main="Distribution of casual count",breaks = 100)
summary(train$count)

layout(matrix(c(1,2),1,2,byrow=FALSE))
plot(train$casual ~ train$weekday, main="Casual grouped by weekday")
plot(train$registered ~ train$weekday, main="Registered grouped by weekday")