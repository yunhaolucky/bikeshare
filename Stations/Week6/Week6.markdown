---
layout: post
title:  "Week 6"
date:   2014-11-27 08:27
categories: bikeshare
---

### Stations ###
Get the station information from [citBike](http://citybik.es/). The System has 354 stations and each station should have an unique id, name, latitude and longtitude.

#### Remove replicates ####
In the data provided citBike, several different stations share the same id. This happens when bikeshare system make changes to its station configuration. For example,
```
index      id                         name latitude longitude
104 31232 7th & F St NW / National Portrait Gallery 38.89732 -77.02232
352 31232 8th & F St NW / National Portrait Gallery 38.89689 -77.02292
```
But in the ridership in 2nd quarter of 2014, all `31232` terminals are refered as `7th & F St NW / National Portait Gallery`.
All changes(2012 Jan - Dec) are listed below:
```
31013 23rd & Eads St
31074 Thomas Jefferson Cmty Ctr / 2nd St S & Ivy
31083 No data available
31086 No data available
31216 McPherson Square / 14th & H St NW
31232 7th & F St NW / National Portrait Gallery
31268 13th & U St NW
31500 4th St & Rhode Island Ave NE
31615 6th & H St NE
31633 Independence Ave & L'Enfant Plaza SW/DOE
```
All stations in the [map](https://a.tiles.mapbox.com/v4/yunhaocs.kb529eif/page.html?access_token=pk.eyJ1IjoieXVuaGFvY3MiLCJhIjoiaXBjOFctNCJ9.4JGjv-vwZz_ERyR5empKRg#13/38.9135/-77.0452)

### Rideship ###
I pick `Jun 30 2012(Saturday)` as an example of the ridership. There are `10604` rides ends `before Jul 1 2012` or starts `after June 30 2012`.  
As ridership `8678` never returns, I remove this ridership.   
Also, Station `White House [17th & State Pl NW]` location information is not included in the station xml file, I remove all the ridership starts or ends at this station(`1088  2206  2293  2860  2983  7697  7321  7870  8433 10037`). Therefore, There are `10595` riderships in total.

* `8524(80.45%)` rides are from registered riders while `2069(19.55%)` are from casual riders.
* There are `7.357639` rides per minute.
* `302` stations have out-rides while `304` stations have in-rides.

[Animation of Riderships](http://nameless-mountain-3948.herokuapp.com/)
* Stations
  * Most riderships are in the Washington D.C area. Most stations in Arlington area has no rides.
  * Lots of bikes get into Washington D.C area in the morning(6 - 8am) and out of town in the evening(5 - 9pm)
* Casual vs Registered
   * Lots casual rideships have companions.
   * Most casual rideships are in the area of Washiton Monument and West Potomac Park, while most registered riderships are in-town and out-town traffic.
   * Most casual rideships happens during morning and evening, while most casual rideships happens during the day.

#### Distance ####
I use [Haversine formula](http://en.wikipedia.org/wiki/Haversine_formula) to calculate the distance between two stations.
summary of distance(miles):
```
Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
0.0000  0.5557  0.9308  1.1090  1.4870  8.1630
```

![](https://googledrive.com/host/0B47woKFE0zXeaTJqc01sQjRrWU0/hist_distance.png)
* The most common riding distance are about 1 mile.
* Most (`7404`) rides have distance smaller than 2 miles.
* Short Trips
  * `distance < 0.5 mile`:`2191` in total (`1665(76%)` are from registered registered)
  * `distance < 0.1 mile`:`436` in total (`244(56%)` are from registered registered)
![](https://googledrive.com/host/0B47woKFE0zXeaTJqc01sQjRrWU0/box_distance.png)
* There is no big difference in riding distance between casual and registered riders `p = 3.2e-13`.

#### Travelling Time ####
Summary of travelling time(seconds):
```
Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
2     389     657    1004    1101   65190
```
![](https://googledrive.com/host/0B47woKFE0zXeaTJqc01sQjRrWU0/hist_time.png)
* Most rides ends within 30 minutes.
* `188` rides last less than 1 minute.
* `384` rides last longer than 1 hour.
![](https://googledrive.com/host/0B47woKFE0zXeaTJqc01sQjRrWU0/boxplot_time.png)

The travelling time of casual riders is generally longer than registered riders.(but `p = 2e-16`)

#### Speed ####
`speed` = `distance`/`travelling time`. Summary of speed(mph):
```
Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
0.000   4.236   5.952   5.601   7.300  13.710
```
Even the maximum is smaller than the average biking speed maximum limit by New York city Bike(I use shortest distance between two stations to calculate.)
![](https://googledrive.com/host/0B47woKFE0zXeaTJqc01sQjRrWU0/hist_speed.png)
* The speed histogram looks pretty normal,expcept the peak at 0.
* `Potential round-trip`(speed < 3)`: There are `1687` trips.

![](https://googledrive.com/host/0B47woKFE0zXeaTJqc01sQjRrWU0/boxplot_speed.png)
Casual riders is generally slower than registered riders.(but `p < 2e-16`)

#### Speed and Distance ####
![](https://googledrive.com/host/0B47woKFE0zXeaTJqc01sQjRrWU0/plot_dist_speed.png)
We see a big range of speed when distance is small. But when distance becomes larger, the speed converges to about 8mph.

Probably useful links:

* https://github.com/dssg/bikeshare
* "Car traffic predicton"
https://who.rocq.inria.fr/Jean-Marc.Lasgouttes/workshop/iwi-loubes.pdf
* "New York Traffic data"
http://www.nyc.gov/html/dot/html/about/datafeeds.shtml#Bikes
* "Computer networks traffic prediction"
http://dept.stat.lsa.umich.edu/~gmichail/nkrig_rev1.pdf
