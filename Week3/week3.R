source("Week3/helper.R")

train <- preprocess(read.csv("train.csv", stringsAsFactors=FALSE))
test <-  preprocess(read.csv("test.csv", stringsAsFactors=FALSE))

#Change datetime to hour number since the start of the year
#train$datetime = unclass(train$datetime)/3600 
#train$datetime = train$datetime - train$datetime[1]
#test$datetime = unclass(test$datetime)/3600 
#test$datetime = test$datetime - test$datetime[1]

# Exacting Features and Target #
count.feature = train[,-c(10,11)]
count.target = train[,12]

## Pairwise lm ##
train.lm <- lm(count ~ .*., data=count.feature)
summary(train.lm)
anova(train.lm)
train.rmsle = rmlse_evaluation(benchmark = 10, predict_value = predict(train.lm,count.feature ), target = count.target)

test.predict.lm = predict(train.lm, test)
print_output(test,set_benchmark(test.predict.lm,10),filename="lm_result.csv")
cross_validation(count.feature, count.target,5,formula(train.lm))
## 3-variable lm ##
train.lm <- lm(count ~ .^3, data=count.feature)
## Remove temp
temp.feature = count.feature[,-c(6)]
temp.lm <- lm(count ~ .*., data=temp.feature)
summary(temp.lm)
cross_validation(temp.feature, count.target,5,formula(temp.lm))
test.predict.lm = predict(temp.lm, test)
print_output(test,set_benchmark(test.predict.lm,10),filename="lm_result.csv")


#### Test all set size with 2-pair regression ####

u = vector("list",4)
w = vector("list",4)
for(i in 2:5){
  list = combn(c(1:9,11:12),i)
  best_rmsle = 100
  best_r = 0
  cb_rmsle = c(1,1)
  cb_r = c(1,1)
  n = ncol(list)
  for(j in 1:n){
    count.feature = train[,-c(10,11)]
    count.target = train[,12]
    temp.feature = count.feature[,c(list[,j],10)]
    temp.lm = lm(count ~ .*., data=temp.feature)
    cv.result = cross_validation(temp.feature, count.target,5,formula(temp.lm))
    if(best_r<cv.result$r_squared){
      best_r = cv.result$r_squared
      cb_r = list[,j]
    }
    if(best_rmsle>cv.result$rmsle){
      best_rmsle = cv.result$rmsle
      cb_rmsle = list[,j]
    }
  }
  u[[i - 1]] = cb_r
  w[[i - 1]] = cb_rmsle
}

count.feature = train[,-c(10,11)]
count.target = train[,12]
u2_5 = u
w2_5 = w
#u6_11 = u
#w6_11 = w


a = 6
temp.feature = count.feature[,c(w6_11[[5]],10)]
names(count.feature)[w6_11[[5]]]
library(MASS)
temp.lm = lm(count~.*., data=temp.feature)
step <- stepAIC(temp.lm, direction="both")
cv.result = cross_validation(temp.feature, count.target,5,step$call$formula,lm)
test.predict.lm = predict(temp.lm, test)
print_output(test,set_benchmark(test.predict.lm,10),filename="lm_result.csv")


### Possion ###

train.glm <- glm(count ~ 1+., data=count.feature,family = poisson(link = "log"))summary(train.glm)
predict_value = 2^predict(train.glm,count.feature )
a = rmlse_evaluation(benchmark = 10, predict_value = 2^predict(train.glm,count.feature ), target = count.target)
test.predict.glm = 2^predict(train.glm, test)
test.predict.glm[test.predict.glm<10] = 10
print_output(test,test.predict.glm,filename="possion_result.csv")


train.glm <- glm(count ~ ., data=count.feature,family = poisson(link = "log"))
summary(train.glm)
cv.result = cross_validation(count.feature, count.target,5,formula(train.glm),train.glm)


### 
library("MASS")
count.feature = train[,-c(10,11)]
count.target = train[,12]
train.nb <- glm.nb(count ~ .*., data=temp.feature)
summary(train.nb)
temp.feature = count.feature[,c(w6_11[[1]],10)]
cv.result = cross_validation(temp.feature, count.target,5,formula(train.nb),glm.nb)

