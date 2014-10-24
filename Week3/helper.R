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
  data$season[month %in% c(12,1,2)] = 1
  data$season[month %in% c(3,4,5)] = 2
  data$season[month %in% c(6,7,8)] = 3
  data$season[month %in% c(9,10,11)] = 4
  data$season = factor(data$season,levels = c(1,2,3,4),ordered = FALSE)
  
  ### Compute New Variable -> weekday ###
  data$weekday = factor(weekdays(data$datetime))
  ### Standardize the numeric variable ###
  scale(data$temp, center = TRUE, scale = TRUE)
  scale(data$atemp, center = TRUE, scale = TRUE)
  scale(data$humidity, center = TRUE, scale = TRUE)
  scale(data$windspeed, center = TRUE, scale = TRUE)
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
set_benchmark <-function(data,benchmark){
  data[data < benchmark] = benchmark
  return(data)
}
r_squared <- function(actual, predict){
  a = 1 - sum((predict - actual)^2)/sum((actual - mean(actual))^2)
  return(a)
}
cross_validation <-function(x,y,k=5,formula_lm){
  if("weather" %in% colnames(x)){
  temp = x$weather != 4
  x = x[temp,]
  y = y[temp]
  }
  n=nrow(x)
  k = trunc(k)
  leave.out= trunc(n/k)
  o = sample(1:n)
  groups = vector("list",k)
  for (j in 1:(k - 1)){
    s_p = (1 + (j - 1) * leave.out)
    groups[[j]] = (o[s_p:(s_p+leave.out - 1)])
  }
  groups[[k]] <- o[(1 + (k - 1) * leave.out):n]
  u = vector("list",k)
  cv.fit = rep(NA,n)
  for(j in 1:k){
    u[[j]] = lm(formula = formula_lm,data = x[-groups[[j]],])
    cv.fit[groups[[j]]] = predict(u[[j]],x[groups[[j]],])
  }
  return(list(r_squared = r_squared(y,cv.fit), rmsle = rmlse_evaluation(10,cv.fit,y)))
}