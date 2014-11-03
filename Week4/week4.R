source("Week4/helper.R")

train <- preprocess(read.csv("train.csv", stringsAsFactors=FALSE))
test <-  preprocess(read.csv("test.csv", stringsAsFactors=FALSE))

# Feature used to predict count(remove casual and registered)
count.feature =  train[,-c(10,11)]

# Linear stepwise AIC
library(MASS)
best.solution <- c(1,3,4,5,6,11,which(names(count.feature) == "count")) # Best Solution from last post
train.lm <- lm(count ~ .*., data = count.feature[best.solution])
step <- stepAIC(train.lm, direction="both")
cv.result <- crossValidation(feature = count.feature[best.solution],resp = count.feature$count,k = 5,
                             method = lm,formula = step$call$formula)

# Poisson Regression
count.feature =  train[,-c(10,11)]
train.poisson = glm(count ~ .*., family="poisson",data = count.feature)
cv.result <- crossValidation(feature = count.feature,resp = count.feature$count,k = 5,
                             method = glm,formula = formula(train.poisson),family="poisson")
print.output(train.poisson,"poisson")
test.predict.lm = exp(predict(train.poisson, test))
print.prediction(test,test.predict.lm,"poisson.csv")

## Stepwise AIC
library(MASS)
step.poisson <- stepAIC(train.poisson, direction="both")
cv.result <- crossValidation(feature = count.feature,resp = count.feature$count,k = 5,
                             method = glm,formula = step.poisson$call$formula,family="poisson")
train.step.poisson = glm(step.poisson$call$formula, family="poisson",data = count.feature)
test.predict.lm = exp(predict(train.step.poisson, test))
print.prediction(test,test.predict.lm,"stepwise_poisson.csv")


# Combined poisson
## predict casual
casual.feature =  train[,-c(11,12)]
casual.poisson = glm(casual ~ .*., family="poisson",data = casual.feature)
print.output(casual.poisson,"casual_possion")
cv.result.casual <- crossValidation(feature = casual.feature,resp = casual.feature$casual,k = 5,
                             method = glm,formula = formula(casual.poisson),family="poisson")
casual.poisson.prediction = exp(predict(casual.poisson, test))
remove(casual.feature)
## predict registered 
registered.feature = train[,-c(10,12)]
registered.poisson = glm(registered ~ .*., family="poisson",data = registered.feature)
print.output(registered.poisson,"registered_possion")
cv.result.registered <- crossValidation(feature = registered.feature,resp = registered.feature$registered,k = 5,
                             method = glm,formula = formula(registered.poisson),family="poisson")
registered.poisson.prediction = exp(predict(registered.poisson, test))
remove(registered.feature)
# combine casual+registered
test.predict.lm = registered.poisson.prediction + casual.poisson.prediction
print.prediction(test,test.predict.lm,"combine_poisson.csv")

## Plot Residual vs Predictor
train.poisson.fitted = fitted(train.poisson)
registered.poisson.fitted = fitted(registered.poisson)
casual.poisson.fitted = fitted(casual.poisson)
train.poisson.resid = resid(train.poisson,type="deviance")
registered.poisson.resid = resid(registered.poisson,type = "deviance")
casual.poisson.resid = resid(casual.poisson,type = "deviance")
## Plot
source("Week4/residual_plot.R")


for(i in 1:(length(factor.list)-2)){
  this = factor.list[i]
  plot(train.poisson.fitted,train.resid,pch = 16,cex = 0.3,col = as.numeric(count.feature[,this])+1,main = )
  legend(700,20,cex = 0.7,factor.level[[this]],col=1:length(count.feature[,this])+1,pch = 1) 
  abline(a=0,b=0,col = 1)
}



for(i in 1:length(resp.list)){
  this = resp.list[i]
  plot(train[,this],train.poisson.resid,ylab = "Deviance Residual",xlab = this,main = paste("residual vs",this)) 
  abline(a=0,b=0,col = "red")
}

# Poisson - all subset
count.feature = train[,-c(10,11)]
subset_rsquared = vector("list",length(count.feature) - 2) # list of best rsquared subset of size from 2 to len - 1
subset_rmsle = vector("list",length(count.feature) - 2) # list of best rsmle subset of size from 2 to len - 1
for(i in 2:length(count.feature) - 1){
  cb = combn(c(1:9,11:12),i) # create all subset of size i
  best_rmsle = 100 # best rmsle 
  best_r = 0 # best r squared
  cb_rmsle = c(1,1) # best rmsel of size i
  cb_r = c(1,1) # best r-squared of size i
  n = ncol(list) # number of subsets of size i
  for(j in 1:n){
    temp.feature = count.feature[,c(cb[,j],10)] # create current subset
    cv.result = crossValidation(feature = temp.feature,resp = temp.feature$count,k = 5,
                    method = glm,formula = formula(count~.*.),family="poisson") # cross_validation on current subset
    # print result row
    cat("|",i,"|",cv.result$rmsle,"|",cv.result$r_squared,"|{",names(temp.feature),"}|")
    if(best_r<cv.result$r_squared){ # compare with current best r
      best_r = cv.result$r_squared
      cb_r = list[,j]
    }
    if(best_rmsle>cv.result$rmsle){ # compare with current best r_squared
      best_rmsle = cv.result$rmsle
      cb_rmsle = list[,j]
    }
  }
  subset_rsquared[[i - 1]] = cb_r #store best rsquared subset of size i
  subset_rmsle[[i - 1]] = cb_rmsle # subset rmsle subset of size i
}

# Quasi-poisson
count.feature = train[,-c(10,11)]
cv.quasipoisson.result <- crossValidation(feature = count.feature,resp = count.feature$count,k = 5,
                             method = glm,formula = formula(count~.*.),family="quasipoisson")
train.quasipoisson = glm(count ~ .*., family="quasipoisson",data = count.feature)
sink("Week4/quasipoisson_output.txt")
summary(train.quasipoisson)
sink()
test.predict.lm = exp(predict(train.quasipoisson, test))
print.prediction(test,test.predict.lm,"quasipoisson.csv")

# Negative Binomial
count.feature = train[,-c(10,11)]
cv.nb.result <- crossValidation(feature = count.feature,resp = count.feature$count,k = 5,
                                          method = glm.nb,formula = formula(count~.*.))
train.nb = glm.nb(count ~ .*., data = count.feature)
sink("Week4/negative_binominal_output.txt")
summary(train.nb)
sink()
test.predict.nb = exp(predict(train.nb, test))
print.prediction(test,test.predict.nb,"nb.csv")

#Hurdle - Notworking
library("pscl")
count.feature = train[,-c(10,11)]
count.feature$count[count.feature$count  == 1] = 0
train.hurdle = hurdle(count~.*.,data = count.feature)
cv.hurdle.result <- crossValidation(feature = count.feature,resp = count.feature$count,k = 5,
                                method = hurdle,formula = formula(count~.*.),dist = "negbin")

# Zero-inflated
count.feature = train[,-c(10,11)]
count.feature$count[count.feature$count  == 1] = 0
train.zeroinfl = zeroinfl(count~.*.,data = count.feature)
cv.hurdle.result <- crossValidation(feature = count.feature,resp = count.feature$count,k = 5,
                                    method = hurdle,formula = formula(count~.*.),dist = "negbin")


# blc.glm
library("BMA")
fa = formula(count ~ .)
a = bic.glm(f = fa,data = count.feature,glm.family = poisson)



plot(cv.result$actual,exp(cv.result$predict.value),pch = 16,cex = 0.3)
lines(x = cv.result$actual,y=cv.result$actual,col = "red")

#Combined



# Plot: predicted vs observsed
factor.list = c("season","holiday","workingday","weather","weekday","hour")
numeric.list = c("datetime","atemp","temp","humidity","windspeed")
resp.list = c("casual","registered","count")
train.resid <- cv.result$predict.value - cv.result$actual

for(i in 1:(length(factor.list)-2)){
  this = factor.list[i]
  plot(cv.result$actual,train.resid,pch = 16,cex = 0.3,col = as.numeric(count.feature[,this])+1)
  legend(700,200,cex = 0.7,factor.level[[this]],col=1:length(count.feature[,this])+1,pch = 1) 
  lines(x = cv.result$actual,y=0,col = 1)
}


legend(700,200,c("workingday","notworkingday"),cex = 0.7,unique(count.feature$workingday),col=1:length(count.feature$workingday),pch=1,)


## Observation vs Prediction ##

train.resid <- rstandard(train.lm)
train.resid  <- resid(train.lm)
hist(train.resid,breaks=80)

plot(train$count,train.resid,cex = 0.5)
#abline(lm(train.resid~train$count), col="red")
lines(lowess(train$count,train.resid, f = 0.1), col = "red")
for(i in 2:length(count.feature)){
this = count.feature[,i]
plot(this,train.resid,cex = 0.5,main = paste("Residual vs",names(count.feature)[i]))
lines(lowess(this,train.resid, f = 0.1), col = "red")
}

for(i in 1:length(count.feature)){
  this = count.feature[,i]
  plot(this,train.resid,cex = 0.5,main = paste("Residual vs",names(count.feature)[i]))
  lines(lowess(this,train.resid, f = 0.1), col = "red")
}

count = count.feature$count
plot(count,train.resid,cex = 0.1,main = paste("Line Residual vs",names(count.feature)[i]), col=this)
lines(lowess(count[this==1],train.resid[this==1], f = 0.1), col = 1)
lines(lowess(count[this==2],train.resid[this==2], f = 0.1), col = 2)
lines(lowess(count[this==3],train.resid[this==3], f = 0.1), col = 3)
lines(lowess(count[this==4],train.resid[this==4], f = 0.1), col = 4)
legend(900,0,unique(this),col=1:length(this),pch=1)


#### poisson distribution
hist(log(train$count), main="Distribution of count",breaks = 100,prob = T)
lines(x<-seq(0,7,1),dpois(x,lambda=mean(log(train$count))),lty=1,col="red")
marginal.plot(train$count)


train.poisson.resid = resid(train.poisson,type="deviance")
train.poisson.fitted = fitted(train.poisson)
plot(train.poisson.fitted ,train.poisson.resid,pch = 16,cex = 0.3,main = "deviance residual plot")
abline(a=0, b=0, col = "red")
plot(train$count,train.poisson.fitted ,pch = 16,cex = 0.3,main = "predicted vs observed")
abline(a=0,b=1,col = "red")


