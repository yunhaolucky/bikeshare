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
plot(train.poisson.fitted,train$count,pch = 16,cex = 0.3)

# Poisson - all subset
source("Week4/all_subset.R")

# Quasi-poisson
count.feature = train[,-c(10,11)]
cv.quasipoisson.result <- crossValidation(feature = count.feature,resp = count.feature$count,k = 5,
                             method = glm,formula = formula(count~.*.),family="quasipoisson")
train.quasipoisson = glm(count ~ .*., family="quasipoisson",data = count.feature)
print.output(train.quasipoisson,"quasipoisson")
test.predict.lm = exp(predict(train.quasipoisson, test))
print.prediction(test,test.predict.lm,"quasipoisson.csv")

# Negative Binomial
library("MASS")
count.feature = train[,-c(10,11)]
cv.nb.result <- crossValidation(feature = count.feature,resp = count.feature$count,k = 5,
                                          method = glm.nb,formula = formula(count~.*.))
train.nb = glm.nb(count ~ .*., data = count.feature)
print.output(train.nb,"nb")
test.predict.nb = exp(predict(train.nb, test))
print.prediction(test,test.predict.nb,"nb.csv")

#Hurdle - Notworking
library("pscl")
count.feature = train[,-c(10,11)]
count.feature$count[count.feature$count  == 1] = 0
train.hurdle = hurdle(count~.*.,data = count.feature)
cv.hurdle.result <- crossValidation(feature = count.feature,resp = count.feature$count,k = 5,
                                method = hurdle,formula = formula(count~.*.),dist = "negbin")

# Zero-inflated Not working
count.feature = train[,-c(10,11)]
count.feature$count[count.feature$count  == 1] = 0
train.zeroinfl = zeroinfl(count~.*.,data = count.feature)
cv.hurdle.result <- crossValidation(feature = count.feature,resp = count.feature$count,k = 5,
                                    method = hurdle,formula = formula(count~.*.),dist = "negbin")


# blc.glm
library("BMA")
count.feature = train[,-c(10,11)]
fa = formula(count ~ .)
a = bic.glm(f = fa,data = count.feature,glm.family = poisson)












