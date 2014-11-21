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

factor.list = c("season","holiday","workingday","weather")
numeric.list = c("datetime","atemp","temp","humidity","windspeed","weekday","hour")
resp.list = c("casual","registered","count")

for(i in 1:(length(factor.list) - 2)){
  this = factor.list[i]
  png(file = paste("Week4//image//pvo_",this,".png", sep = ""),
      width=1000, 
      height=400,
  )
  layout(matrix(c(1,2,3),1,3,byrow=FALSE))
  plot(x = train$count,y = train.poisson.fitted,pch = 16,cex = 0.7,col = as.numeric(train[,this])*2 ,xlab = "observation",ylab = "predicted",main = paste("Count residual vs predicted by",this))
  legend(600,300,cex = 1.5,factor.level[[this]],col=1:length(train[,this])*2,pch = 1) 
  abline(a=0,b=1,col = 1)
  plot(x = train$casual,y = casual.poisson.fitted,pch = 16,cex = 0.7,col = as.numeric(train[,this])*2 ,xlab = "observation",ylab = "predicted",main = paste("Casual residual vs predicted by",this))
  legend(250,100,cex = 1.5,factor.level[[this]],col=1:length(train[,this])*2,pch = 1) 
  abline(a=0,b=1,col = 1)
  plot(x = train$registered,y = registered.poisson.fitted,pch = 16,cex = 0.7,col = as.numeric(train[,this])*2 ,xlab = "observation",ylab = "predicted",main = paste("Casual residual vs predicted by",this))
  legend(600,300,cex = 1.5,factor.level[[this]],col=1:length(train[,this])*2,pch = 1) 
  abline(a=0,b=1,col = 1)
  dev.off()
}


library("ggplot2")
library("RColorBrewer")
for(i in 1:(length(numeric.list))){
  this = numeric.list[i]
  png(file = paste("Week4//image//pvo_",this,".png", sep = ""),
      width=1000, 
      height=400,
  )
  
  myPalette <- colorRampPalette(rev(brewer.pal(11, "Spectral")))
  sc <- scale_colour_gradientn(colours = myPalette(100), limits= range(as.numeric(train[,this])))
  p1 <- ggplot(data = train,aes(x=train$count, y=train.poisson.fitted, colour=as.numeric(train[,this]))) + 
    geom_point(size=2)+sc+ggtitle(paste("Count residual vs predicted by",this))+theme(legend.title=element_blank())+geom_abline(intercept = 0, slope = 1)
  p2 <- ggplot(data = train,aes(x=train$casual, y=casual.poisson.fitted, colour=as.numeric(train[,this]))) + 
          geom_point(size=2)+sc+ggtitle(paste("Casual residual vs predicted by",this))+theme(legend.title=element_blank())+geom_abline(intercept = 0, slope = 1)
  p3 <- ggplot(data = train,aes(x=train$registered, y=registered.poisson.fitted, colour=as.numeric(train[,this]))) + 
          geom_point(size=2)+sc+ggtitle(paste("Registered residual vs predicted by",this))+theme(legend.title=element_blank())+geom_abline(intercept = 0, slope = 1)
  multiplot(p1, p2, p3, cols=3)
  dev.off()
}

factor.list = c("season","holiday","workingday","weather","weekday","hour")
numeric.list = c("datetime","atemp","temp","humidity","windspeed")
resp.list = c("casual","registered","count")


multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  require(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}
