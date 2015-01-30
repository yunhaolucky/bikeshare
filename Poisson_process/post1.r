ride = read.csv("~/Google Drive/Bike Share/Introduction/2014-Q2-Trips-History-Data.csv")
all.ride = ride
ride$Duration =  as.difftime(as.character(ride$Duration),"%Hh %Mm %Ss",units="secs")
ride$Duration = as.numeric(ride$Duration)
ride = ride[which(ride$Subscriber.Type =="Registered"),]
ride = ride[which(weekdays(as.Date(ride$Start.date,"%m/%d/%Y %H:%M")) %in% c("Monday","Tuesday","Wednesday","Thursday","Friday")),]
hist(ride$Duration,xlim=c(0,2500),main="Distribution of Duration",breaks=8000)
a = qqnorm(ride$Duration)
qqplot(ride$Duration)
library(MASS)
duration_no_outlier = ride$Duration[which(ride$Duration <= 2500)]


#### get distribution of S ####
freqs_in = aggregate(ride$Start.terminal, by=list(ride$Start.terminal),FUN=length)
summary(freqs_in$x)
boxplot(freqs_in$x,main = "# of rides starting from each station")
hist(freqs_in$x,breaks = 100,xlim=c(0,7000),xlab = "# of rides starting from station", main = "# of rides starting from each station(w/o outliers)")
par(mfrow=c(1,2))
plot(x = as.list(sapply(freqs_in$Group.1, function(x)station.lon(x))),freqs_in$x,cex = 0.1,xlab = "longitude",ylab = "# of rides",main = "# of rides vs longitude")
plot(x = as.list(sapply(freqs_in$Group.1, function(x)station.lat(x))),freqs_in$x,cex = 0.1,xlab = "latitude",ylab = "# of rides",main = "# of rides vs latitude")


freqs_in[ order(-freqs_in[,2]), ][c(1:10),]

top2 = c(31623,31200)
station.name(31623)
station.name(31200)
id = 31623
library(ggplot2)

par(mfcol = c(2,1))
a= station.get_hour_distribution(31623)
station.get_hour_distribution<- function(id){
temp.ride = ride.start_terminal(id)
temp.hour = format(strptime(temp.ride$Start.date,"%m/%d/%Y %H:%M"),"%H")
freq_hour = aggregate(temp.hour, by=list(temp.hour),FUN=length)
#plot hisrogram of hour
print(ggplot(freq_hour, aes(x=Group.1,y=x)) + geom_bar(stat = "identity")+xlab("Hour")+ylab("Frequency")+ggtitle(paste(station.name(id),":(",round(station.lat(id),digits = 4),",",round(station.lon(id),digit = 4),")",sep = "")))
return(freq_hour)
}
#Function : get hour field of a DATETIME instance

temp.ride = ride.start_terminal(id)
hist(temp.ride$Duration,breaks = 100)
temp.end_count = aggregate(temp.ride$End.terminal, by=list(temp.ride$End.terminal),FUN=length)
temp.end_count[ order(-temp.end_count[,2]), ]
station.name(31258)
