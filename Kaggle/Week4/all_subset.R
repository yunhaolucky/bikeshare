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