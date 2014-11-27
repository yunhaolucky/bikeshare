post 5

#### Stations ####
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
