source("Week5/helper.R")

train <- preprocess(read.csv("train.csv", stringsAsFactors=FALSE))
test <-  preprocess(read.csv("test.csv", stringsAsFactors=FALSE))
data$hour <-  as.numeric(strftime(data$datetime, format="%H"))

casual.feature = train[,-c(11,12)]
fit <- princomp(~.,casual.feature[,c(6,7,8,9)], cor=TRUE)
summary(fit) # print variance accounted for 
loadings(fit) # pc loadings 
plot(fit,type="lines") # scree plot 
fit$scores # the principal components
biplot(fit)

registered.feature = train[,-c(10,12)]
casual.feature = train[,-c(11,12)]



casualts <- ts(casual.feature$casual,frequency = 12 * 30)

require(xts)
require(forecast)

time_index <- seq(from = casual.feature$datetime[1], 
                  to =  casual.feature$datetime[10086], by = "hour")
set.seed(1)
#value <- rnorm(n = length(time_index))

eventdata <- xts(casual.feature$casual, order.by = casual.feature$datetime)
ets(eventdata)

library(randomForest)
casual.rf = rf <- randomForest(casual ~ ., data=casual.feature, ntree=100)

casual.predicted = predict(casual.rf, test)
registered.rf = rf <- randomForest(registered ~ ., data=registered.feature, ntree=100)
registered.predicted = predict(registered.rf, test)
combined.predict = casual.predicted + registered.predicted
print.prediction(test,combined.predict,"combined")
count.feature$hour <-  as.numeric(strftime(train$datetime, format="%H"))
train.poisson = glm(count ~ (hour+ hour^2 + hour^3 + hour^4 +. )*., family="poisson",data = count.feature)
summary(train.poisson)
plot(resid(train.poisson)~fitted(train.poisson))

library(party)
casual.rf = rf <- cforest(casual ~ ., data=casual.feature, cforest_unbiased(mtry=2,ntree=100))
casual.predicted = predict(casual.rf, test)
registered.rf = rf <- cforest(registered ~ ., data=registered.feature, cforest_unbiased(mtry=2,ntree=50))
registered.predicted = predict(registered.rf, test)
reg.feature = train[,-c(10,12)]
reg.feature$hour <-  as.numeric(strftime(train$datetime, format="%H"))
reg.poisson = glm(registered ~ (hour+ hour^2 + hour^3 + hour^4 +. )*., family="poisson",data = reg.feature)
summary(reg.poisson)
plot(resid(reg.poisson)~fitted(reg.poisson))
plot(fitted(reg.poisson)~reg.feature$hour)
plot(reg.feature$registered~reg.feature$hour)

plot(train$hour,train$count)
train$hour[train$hour %in% c(0:4,23)] <- 1
train$hour[train$hour %in% c(5,19:22)] <- 2
train$hour[train$hour %in% c(6,7,15,18)] <- 4
train$hour[train$hour %in% c(8:14)] <-3
train$hour[train$hour %in% c(16,17)] <-5
train$hour = as.factor(train$hour)
plot(test$hour,test$count)
test$hour[test$hour %in% c(0:4,23)] <- 1
test$hour[test$hour %in% c(5,19:22)] <- 2
test$hour[test$hour %in% c(6,7,15,18)] <- 4
test$hour[test$hour %in% c(8:14)] <-3
test$hour[test$hour %in% c(16,17)] <-5

count.feature =  train[,-c(10,11,14)]
train.poisson = glm(count ~ .*., family="poisson",data = count.feature)
cv.result <- crossValidation(feature = count.feature,resp = count.feature$count,k = 5,
                             method = glm,formula = formula(train.poisson),family="poisson")

plot(train$weekday,train$casual)
plot(train$datetime,train$count)
