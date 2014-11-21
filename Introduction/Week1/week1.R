############ Read Data from .csv ############
q2data = read.csv("~/Downloads/2014-Q2-Trips-History-Data.csv")

############ Duration #############
duration = q2data$Duration
duration = as.difftime(duration,"%Hh %Mm %Ss",units="secs")
#sum of duration
sum(duration, na.rm = TRUE)
#histogram of duration
duration_numeric = as.numeric(duration)
hist(duration_numeric, breaks=8000,xlim=c(0,8000),main="Distribution of Duration")


########## Date ##############
# get the date of all rides
startdate = as.Date(starttime,"%m/%d/%Y %H:%M")
# create distribution table
freqs = aggregate(startdate, by=list(startdate),FUN=length)
#histogram
ggplot(freqs, aes(x=Group.1,y=x)) + geom_bar(stat = "identity") + scale_x_date(breaks="1 month")+xlab("Date")+ylab("Frequency")+ggtitle("Distribution of Start time")
#Get the outliers
upperoutliers = freqs[1][which(freqs[2] > 13000),1]
loweroutliers = freqs[1][which(freqs[2] < 5000),1]

######## Weekday #########
barplot(table(factor(weekdays(startdate),levels=c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"))))

######## Time ##########
hour = format(strptime(starttime,"%m/%d/%Y %H:%M"),"%H")
freq_hour = aggregate(hour, by=list(hour),FUN=length)
#plot hisrogram of hour
ggplot(freq_hour, aes(x=Group.1,y=x)) + geom_bar(stat = "identity")+xlab("Hour")+ylab("Frequency")+ggtitle("Distribution of Ride Start time")

#Function : get hour field of a DATETIME instance
gethour = function(datetime){ hour = as.numeric(format(strptime(datetime,"%m/%d/%Y %H:%M"),"%H"));return(hour)}

######## Station ########
instation = q2data$Start.terminal
outstation = q2data$Start.terminal
freqs_in = aggregate(instation, by=list(instation),FUN=length)
freqs_out = aggregate(outstation, by=list(outstation),FUN=length)
in_out = cbind(freqs_in,freqs_out)
in_out[3] = NULL
in_out[4] = in_out[3] - in_out[2]
l = list(in_out[4])
hist(unlist(l),breaks = 100, main = "Histogram of #(In - Out)",xlab = "#(In - Out)")
