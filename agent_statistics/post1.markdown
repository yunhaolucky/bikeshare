#### Data
I use the Capital Bikeshare ride data collected from June to August 2014.
Only rides by registered users are included.
I pick the top 50 most popular rides by the count of rides.

![](https://googledrive.com/host/0B47woKFE0zXeM2ZiekF3MFdPVmM/popu1.png)

I only included the top 10000 most popular rides. The rest of the rides count are all smaller than 2.
The real distribution should be more skewed than this one.

[Demo](https://stormy-earth-4387.herokuapp.com/popularRide)

#### Google Map and Directions
Google map provide a bike map and bike direction service.The green lines on the map are bike friendly roads including trails and roads with bike lanes.
It is unclear that how routes are chosen by Google Map.
According to [How accurate are Google Maps cycling time estimates?](http://www.betterbybicycle.com/2014/09/how-accurate-are-google-maps-cycling.html), Google choose roads with following factors:
1. Roads with bicycling infrastructure
2. Roads that it estimate to take less time
3. don't involve significant elevations

The effect of factor 1 and factor 2 can be observed from my experiment.(Factor 3 is not clear).
As estimated time is one of the key factors of choosing routes, it is important to understand how Google estimate time:
1. Most bike speeds are in the range of (0.15 - 0.22) mile/min. (Bikeshare speed limit 20mph = 0.33 mile/min).
2. I think google include the intersection stopped time.(Path with more intersects generally takes longer).（Ride \#7 \#40)

#### Ride Time Distribution
The riding time from the bikeshare history data always include some unusual rides that take much more time. So I remove those outliers if its difference with the mean is larger than 4 times of standard deviation.  
##### The distribution of ride time
1. Most of rides in top 50 have single peak.  
Some ride have 2 peaks(Ride \#47 \#33)
2. The estimated time of routes are on the same side of the peak in general (in most cases, the estimated time is larger than the real peak.)  
Examples:  
estimated time is bigger than real peak:(Ride \# 4 \#23)  
estimated time describes the data well:(Ride \#6 \# 10)  
estimated time is smaller than real peak:(Ride \# 19 #20)  
For Long rides(rides takes more than 10min), the estimated time is longer than the real peak in general.
