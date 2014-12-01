---
layout: post
title:  "Week 6"
date:   2014-11-27 08:27
categories: bikeshare
---

### Stations ###
Get the station information from [citBike](citybike.us). The System has 354 stations and each station should have an unique id, name, latitude and longtitude.

In the data provided citBike, several different stations share the same id. This happens when  bikeshare system make changes to its station configuration. For example,
```
index      id                         name latitude longitude
104 31232 7th & F St NW / National Portrait Gallery 38.89732 -77.02232
352 31232 8th & F St NW / National Portrait Gallery 38.89689 -77.02292
```
But in the ridership in 2014Q2, all `31232` terminals are refered to `7th & F St NW / National Portait Gallery`.
All replicates are(2012 Jan - Dec):
```
31013 23rd & Eads St
31074 Thomas Jefferson Cmty Ctr / 2nd St S & Ivy
31083
31086
31216 McPherson Square / 14th & H St NW
31232 7th & F St NW / National Portrait Gallery
31268 13th & U St NW
31500 4th St & Rhode Island Ave NE
31615 6th & H St NE
31633 Independence Ave & L'Enfant Plaza SW/DOE
```
All stations can be checked in this [map](https://a.tiles.mapbox.com/v4/yunhaocs.kb529eif/page.html?access_token=pk.eyJ1IjoieXVuaGFvY3MiLCJhIjoiaXBjOFctNCJ9.4JGjv-vwZz_ERyR5empKRg#13/38.9135/-77.0452)

### Rideship ###
I pick `Jun 30 2012` as an example of the ridership. There are `10604` rides ends `before Jul 1 2012` or starts `after June 30 2012`  
As ridership`8678` never returns, I remove this ridership. Also, Station `White House [17th & State Pl NW]` location information is not included in the station xml file, I remove all the ridership starts or ends at this station(`1088  2206  2293  2860  2983  7697  7321  7870  8433 10037`. Therefore, There are `10595` riderships in total.
* `8524(80.45%)` rides are from registered riders while `2069(19.55%)` are from casual riders.
* There are `7.357639` rides per minute.
* `302` stations have out-rides while `304` stations have in-rides.

[Animation of Riderships](http://nameless-mountain-3948.herokuapp.com/)

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
