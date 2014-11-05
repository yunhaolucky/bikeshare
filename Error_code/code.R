source("helper.R")

train <- preprocess(read.csv("train.csv", stringsAsFactors=FALSE))

# blc.glm
library("BMA")
count.feature = train[,-c(10,11)]
a = bic.glm(f = formula(count ~ .),data = count.feature,glm.family = poisson)

