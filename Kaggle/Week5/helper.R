
# Define level of factors for plotting
factor.level = list()
factor.level$"holiday" = c("Not_holiday", "holiday")
factor.level$"workingday" = c("Not_workingday", "workingday")
factor.level$"season" = c("winter", "spring", "summer","fall")
factor.level$"weather" = c("heavy rain","rain","mist", "clear")
factor.level$"weekday" = c("Mon","Tue","Wed", "Thur","Fri","Sat","Sun")
factor.level$"hour" = c(0:23)
# Define type of variable



preprocess <- function(data){
  # Preprocess data 
  # Args:
  #   data : dataframe of bikeshare table
  # Returns:
  #   dataframe after preprocessing.
  
  # Set factor Variable 
  data$season <- factor(data$season,levels = c(1,2,3,4),ordered = FALSE)
  data$holiday <- factor(data$holiday,levels = c(0,1),ordered = FALSE)
  data$workingday <- factor(data$workingday,levels = c(0,1),ordered = FALSE)
  data$weather <- factor(data$weather,levels = c(4,3,2,1),ordered = TRUE)
  data$datetime <- as.POSIXct(data$datetime, tz = "EST", format = "%Y-%m-%d %H:%M:%S")
 
  # Define Level for Plotting 

  
  # Compute New Variable : hour 
  data$hour <-  as.numeric(strftime(data$datetime, format="%H"))
  data$hour <- factor(data$hour,ordered = TRUE)
  
  # recompute varaible : season ###
  month <- as.numeric(strftime(data$datetime, format="%m"))
  data$season[month %in% c(12,1,2)] <- 1
  data$season[month %in% c(3,4,5)] <- 2
  data$season[month %in% c(6,7,8)] <- 3
  data$season[month %in% c(9,10,11)] <- 4
  remove(month)
  data$season <- factor(data$season,levels = c(1,2,3,4),ordered = FALSE)
  
  # Compute New Variable : weekday ###
  data$weekday <- factor(weekdays(data$datetime))
  
  # Standardize the numeric variable ###
  scale(data$temp, center = TRUE, scale = TRUE)
  scale(data$atemp, center = TRUE, scale = TRUE)
  scale(data$humidity, center = TRUE, scale = TRUE)
  scale(data$windspeed, center = TRUE, scale = TRUE)
  return(data)
}


evaluate.rmsle <- function(predict, actual,predict.min = 0){
  # Calculate rmsle of the prediction
  # Args:
  #   predict : a column of dataframe stores the prediced value
  #   actual : a column of dataframe stores the actual value
  # Returns:
  #   rmsle of predict and actual
  predict = setMinimum(predict,predict.min)
  rmsle <- ((1/length(predict))*sum((log(predict+1)-log(actual+1))^2))^0.5
  return(rmsle)
}

evaluate.rsquared <- function(predict, actual){
  # Calculate rsquaredof the prediction
  # Args:
  #   predict : a column of dataframe stores the prediced value
  #   actual : a column of dataframe stores the actual value
  # Returns:
  #   r-squared of predict and actual
  a <- 1 - sum((predict - actual)^2)/sum((actual - mean(actual))^2)
  return(a)
}


crossValidation <-function(feature,resp,k = 5, method ,...){
  # cross validation
  # Args:
  #   feature : (dataframe) features used to predict resp
  #   resp : (table) actual response values
  #   k : (int) number of folds
  #   method : (function) method use to train and predict 
  #   ... : other arguments of method
  # Returns:
  #   rmsle : rmsle of predict and actual response value
  #   rsquared : rsquared of predict and actual response value
  
  #   remove row which weather = 4
  if("weather" %in% colnames(feature)){
  temp = (feature$weather != 4)
  feature = feature[temp,]
  resp = resp[temp]
  }
  
  n = nrow(feature)
  fold.size= trunc(n/k) # round size of fold
  order = sample(1:n) # reorder the sample
  
  # split order into k groups
  groups = vector("list",k) 
  for (i in 1:(k - 1)){
    start = (1 + (i - 1) * fold.size)
    groups[[i]] = (order[start:(start + fold.size - 1)])
  }
  groups[[k]] <- order[(1 + (k - 1) * fold.size):n]
  
  # prsumedict using cross_validation 
  models = vector("list",k) ## list of models
  predict.value = rep(NA,n) ## predict values
  for(i in 1:k){
    models[[i]] = method(data = feature[-groups[[i]],],...)
    predict.value[groups[[i]]] = predict(models[[i]],feature[groups[[i]],])
  }
  r_squared <- evaluate.rsquared(predict = exp(predict.value),actual = resp)
  rmsle <- evaluate.rmsle(predict = exp(predict.value),actual = resp,predict.min = 10)
  #return(list(r_squared = r_squared,rmsle = rmsle,predict.value = predict.value,actual = resp))
  return(list(r_squared = r_squared,rmsle = rmsle))
}

setMinimum <-function(data,min){
  data[data < min] = min
  return(data)
}

print.prediction <-function(test,predict,filename){
  # Print prediction to a cvs file
  # Args:
  #   test : (data frame) test data
  #   predict : (list) predict value
  #   filename : (str) file name 
  # Returns:
  #   print first column of test
  #   print predict as the second column
  #   save to a cvs file
  output <- data.frame(datetime = test[,1], count = predict)
  write.csv(output, file = filename, quote=FALSE, row.names=FALSE)
}

print.output <- function(model,model_name){
  sink(paste("Week5/output/",model_name,"_summary_output.txt",sep = ""))
  print(summary(model))
  sink()
  sink(paste("Week5/output/",model_name,"_anova_output.txt",sep = ""))
  print(anova(model))
  sink()
  sink(paste("Week5/output/",model_name,"_exp_output.txt",sep = ""))
  print(exp(coefficients(model)))
  sink()
}
