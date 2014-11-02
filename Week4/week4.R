source("Week4/helper.R")
library(MASS)

train <- preprocess(read.csv("train.csv", stringsAsFactors=FALSE))
test <-  preprocess(read.csv("test.csv", stringsAsFactors=FALSE))

# Feature used to predict count(remove casual and registered)
count.feature =  train[,-c(10,11)]
#temp = (count.feature$weather != 4)
#count.feature = count.feature[temp,]
#count.feature$count = count.feature$count[temp]
#remove(temp)

# Linear stepwise AIC
best.solution <- c(1,3,4,5,6,11,which(names(count.feature) == "count")) # Best Solution from last post
train.lm <- lm(count ~ .*., data = count.feature[best.solution])
step <- stepAIC(train.lm, direction="both")
cv.result <- crossValidation(feature = count.feature[best.solution],resp = count.feature$count,k = 5,
                             method = lm,formula = step$call$formula)

# Poisson Regression 
train.possion = glm(count ~ .*., family="poisson",data = count.feature)
summary(train.possion)
step.possion <- stepAIC(train.possion, direction="both")
cv.result <- crossValidation(feature = count.feature,resp = count.feature$count,k = 5,
                             method = glm,formula = step.possion$call$formula,family="poisson")
#                             method = glm,formula = formula(train.possion),family="poisson")
train.step.possion = glm(step.possion$call$formula, family="poisson",data = count.feature)
test.predict.lm = exp(predict(train.step.possion, test))
print.prediction(test,test.predict.lm,"possion.cvs")

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
cv.quasipossion.result <- crossValidation(feature = count.feature,resp = count.feature$count,k = 5,
                             method = glm,formula = formula(count~.*.),family="quasipoisson")
train.quasipossion = glm(count ~ .*., family="quasipoisson",data = count.feature)
summary(train.quasipossion)
test.predict.lm = exp(predict(train.quasipossion, test))
print.prediction(test,test.predict.lm,"possion.cvs")

# blc.glm
library("BMA")
fa = formula(count ~ .)
a = bic.glm(f = fa,data = count.feature,glm.family = poisson)


data(UScrime)
f <- formula(log(y) ~ log(M)+So+log(Ed)+log(Po1)+log(Po2)+log(LF)+
               log(M.F)+ log(Pop)+log(NW)+log(U1)+log(U2)+
               log(GDP)+log(Ineq)+log(Prob)+log(Time))
glm.out.crime <- bic.glm(f, data = UScrime, glm.family = gaussian())
summary(glm.out.crime)

plot(cv.result$actual,exp(cv.result$predict.value),pch = 16,cex = 0.3)
lines(x = cv.result$actual,y=cv.result$actual,col = "red")

#Combined
casual.feature =  train[,-c(11,12)]
registered.feature = train[,-c(10,12)]
casual.possion = glm(casual ~ .*., family="poisson",data = casual.feature)
registered.possion = glm(registered ~ .*., family="poisson",data = registered.feature)
test.predict.lm = exp(predict(casual.possion, test))+exp(predict(registered.possion, test))
print.prediction(test,test.predict.lm,"possion.cvs")


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


