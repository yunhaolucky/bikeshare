for(i in 1:length(factor.list)){
  this = factor.list[i]
  png(file = paste("Week4//image//residual_",this,".png", sep = ""),
      width=1000, 
      height=400,
  )
  layout(matrix(c(1,2,3),1,3,byrow=FALSE))
  plot(count.feature[,this],train.poisson.resid,ylab = "Count Deviance Residual",names = factor.level[[this]],main = paste("Count residual vs",this),,ylim=c(-15,25)) 
  plot(count.feature[,this],casual.poisson.resid,ylab = "Casual Deviance Residual",names = factor.level[[this]],main = paste("Casual residual vs",this),,ylim=c(-15,25)) 
  plot(count.feature[,this],registered.poisson.resid,ylab = "Registered Deviance Residual",names = factor.level[[this]],main = paste(" Registered residual vs",this),ylim=c(-15,25)) 
  dev.off()
}

for(i in 1:length(numeric.list)){
  this = numeric.list[i]
  png(file = paste("Week4//image//residual_",this,".png", sep = ""),
      width=1000, 
      height=400,
  )
  layout(matrix(c(1,2,3),1,3,byrow=FALSE))
  plot(count.feature[,this],train.poisson.resid,ylab = "Count Deviance Residual",xlab = this,main = paste("Count residual vs",this),ylim=c(-15,25)) 
  abline(a=0,b=0,col = "red")
  plot(count.feature[,this],casual.poisson.resid,ylab = "Casual Deviance Residual",xlab = this,main = paste("Casual residual vs",this),ylim=c(-15,25)) 
  abline(a=0,b=0,col = "red")
  plot(count.feature[,this],registered.poisson.resid,ylab = "Registered Deviance Residual",xlab = this,main = paste("Registered residual vs",this),ylim=c(-15,25)) 
  abline(a=0,b=0,col = "red")
  dev.off()
}


for(i in 1:length(resp.list)){
  this = resp.list[i]
  png(file = paste("Week4//image//residual_",this,".png", sep = ""),
      width=1000, 
      height=400,
  )
  layout(matrix(c(1,2,3),1,3,byrow=FALSE))
  plot(train[,this],train.poisson.resid,ylab = "Count Deviance Residual",xlab = this,main = paste("Count residual vs",this),ylim=c(-15,25)) 
  abline(a=0,b=0,col = "red")
  plot(train[,this],casual.poisson.resid,ylab = "Casual Deviance Residual",xlab = this,main = paste("Casual residual vs",this),ylim=c(-15,25)) 
  abline(a=0,b=0,col = "red")
  plot(train[,this],registered.poisson.resid,ylab = "Registered Deviance Residual",xlab = this,main = paste("Registered residual vs",this),ylim=c(-15,25)) 
  abline(a=0,b=0,col = "red")
  dev.off()
}