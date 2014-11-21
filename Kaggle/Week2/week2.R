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
season.level = c("spring", "summer", "fall","winter")
weather.level = c("heavy rain","rain","mist", "clear")

### Compute New Variable -> hour ###
data$hour =  as.numeric(strftime(data$datetime, format="%H"))
data$hour = factor(data$hour,ordered = TRUE)

### Compute New Variable -> weekday ###
data$weekday = factor(weekdays(data$datetime))
return(data)
}
firstlook <-function(data,resp){
  layout(matrix(c(1,2,3,4),2,2,byrow=FALSE))
  boxplot(resp ~ data$weather, names= weather.level,main="weather")
  boxplot(resp ~ data$season, names= season.level,main="season")
  boxplot(resp ~ data$holiday, names= holiday.level,main="holiday")
  boxplot(resp ~ data$workingday, names= workingday.level,main="workingday")
  
  layout(matrix(c(1,2,3,4),2,2,byrow=FALSE))
  plot(resp ~ data$temp,main="temp")
  plot(resp ~ data$atemp,main="atemp")
  plot(resp ~ data$humidity,main="humidity")
  plot(resp ~ data$windspeed, main="windspeed")
  
 
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


multiple.regression.with.ci <- function(regress.out, level=0.95){
  usual.output <- summary(regress.out)
  t.quantile <- qt(1-(1-level)/2, df=regress.out$df)
  number.vars <- length(regress.out$coefficients)
  temp.store.result <- matrix(rep(NA, number.vars*2), nrow=number.vars)
  for(i in 1:number.vars)
  {
    temp.store.result[i,] <- summary(regress.out)$coefficients[i] +
      c(-1, 1) * t.quantile * summary(regress.out)$coefficients[i+number.vars]
  }
  intercept.ci <- temp.store.result[1,]
  slopes.ci <- temp.store.result[-1,]
  output <- list(regression.table = usual.output, intercept.ci = intercept.ci,
                 slopes.ci = slopes.ci)
  return(output)
}

### Preprocess the value ###
train = preprocess(train)
test = preprocess(test)

### First look ###
summary(train)
#firstlook(train,train$count)

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
train.glm <- glm(count ~ ., data=count.feature)
summary(train.glm)
a = rmlse_evaluation(benchmark = 10, predict_value = predict(train.glm,count.feature ), target = count.target)
test.predict.glm = predict(train.glm, test)
test.predict.glm[test.predict.glm<10] = 10
print_output(test,test.predict.glm,filename="glm_result.csv")
#### Interpration of linear regression output
#train.resid = resid(train.lm)
library("MASS")
train.studres = studres(train.lm)
train.studres
plot(train$datetime ~ train.studres)
#influence(train.lm)

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
library(DAAG)
cv.lm(df=casual.feature, train.casual.lm,casual.target, m=3)
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