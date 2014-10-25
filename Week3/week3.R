source("Week3/helper.R")

train <- preprocess(read.csv("train.csv", stringsAsFactors=FALSE))
test <-  preprocess(read.csv("test.csv", stringsAsFactors=FALSE))

#Change datetime to hour number since the start of the year
train$datetime = unclass(train$datetime)/3600 
train$datetime = train$datetime - train$datetime[1]
test$datetime = unclass(test$datetime)/3600 
test$datetime = test$datetime - test$datetime[1]

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


af = formula(train.lm)
## All subsets size > 5 ##

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
temp.feature = count.feature[,c(w[[1]],10)]

temp.lm = lm(count ~ .*., data=temp.feature)
cv.result = cross_validation(temp.feature, count.target,5,formula(temp.lm))

u6_11 = u
w6_11 = w


### Possion ###
train.glm <- glm(count ~ 1+., data=count.feature,family = poisson(link = "log"))
summary(train.glm)
predict_value = 2^predict(train.glm,count.feature )
a = rmlse_evaluation(benchmark = 10, predict_value = 2^predict(train.glm,count.feature ), target = count.target)
test.predict.glm = 2^predict(train.glm, test)
test.predict.glm[test.predict.glm<10] = 10
print_output(test,test.predict.glm,filename="possion_result.csv")



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
cv.casual = cross_validation(x=casual.feature,y = casual.target,formula_lm = formula(train.casual.lm))
### Linear regression registered count ####
train.lm.registered= lm(registered ~.*., data = registered.feature)
train.predict.registered.lm = predict(train.lm.registered,registered.feature)
rmlse.registered = rmlse_evaluation(benchmark = 8, predict_value = train.predict.registered.lm , target = registered.target)
test.predict.registered.lm = predict(train.lm.registered, test)
test.predict.registered.lm = set_benchmark(data = test.predict.registered.lm,benchmark = 8)
cv.registered = cross_validation(x=registered.feature,y = registered.target,formula_lm = formula(train.lm.registered))


### Combine count = casual + registered ###
train.predict.count.lm = train.predict.registered.lm + train.predict.casual.lm
rmlse.combine = rmlse_evaluation(benchmark = 10,predict_value = train.predict.count.lm, target = count.target)
test.predict.count.combine = test.predict.casual.lm + test.predict.registered.lm
test.predict.count.combine = set_benchmark(data = test.predict.count.combine,benchmark = 10)
print_output(test,test.predict.count.combine,filename="combine_result.csv")
train.predict.combine = predict(train.casual.lm,casual.feature) + predict(train.lm.registered,registered.feature)
cv.registered = cross_validation(x=casual.feature,y = casual.target,formula_lm = formula(train.lm))
