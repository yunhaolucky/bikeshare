### # of Bikes in use
I calculate the number of bikes still in use at the end of every minute. (That is to say, if a ride start and end within the same minute, it will not be counted.)  

![](https://googledrive.com/host/0B47woKFE0zXeZUN1Rkp2bTdneWs/inservicejune30.png)
(Green points -- every minute. Blue line -- every 30 minute. Redline - number of Bike)

## Properties of Start and End nodes
* \#bikes, \# of empty slots
* time (time interval from empty & full)


### Feature: Current \# of Bikes for each station
As the API of Capital Bikeshare does not provide historical data, I have to calculate from other data sources.

#### Solution 1: Calcualted from Full_Empty information
I plan to calculate \# of bikes using the followng method:
* Step 1: Set \# of bikes = 0 when marked as Empty.
* Step 2: Calculate \# of bikes
  * if time > empty_time, bikes = 0 + in - out
  * if time < empty_time, bikes = 0 - in + out
* Step 3: Set \# of slots =  \# of bikes when marked as Full.

However, this method will not work because of rebalancing in the system.


#### Solution 2 : Scraper of Station Status
As the API of Capital Bikeshare does not provide historical data, I developed a scraper. I called the the scraper very minute and store all station status in a postgresql database.
```
Table "public.station_status"
Column   |            Type             |       Modifiers
-----------+-----------------------------+------------------------
tfl_id    | integer(station_id)         | not null
bikes     | integer(number of bikes)    | not null
spaces    | integer(number of spaces)   | not null
timestamp | timestamp without time zone | not null default now()
```
```
bikeshare=# SELECT * FROM station_status;
tfl_id | bikes | spaces |      timestamp      | key
--------+-------+--------+---------------------+-----
1 |     5 |      6 | 2015-01-23 05:17:00 |
2 |     4 |      7 | 2015-01-23 05:17:00 |
3 |     9 |      6 | 2015-01-23 05:17:00 |
4 |     8 |      3 | 2015-01-23 05:17:00 |
5 |     8 |      3 | 2015-01-23 05:17:00 |
```
The problem is I only have the station status data from Jan.16th, but the ridership data during this time will only be available at the end of this March. Also the weather information needs scraping.

I also sent an email to Oliver O'Brien who had a website that keep track of the historical data.

### Feature: Empty & Full of each station
This data is from Capital Bikeshare's Data Dashboard. It records all the full/empty status in 2014 April - June.

## Properties between Stations
* distance between stations

* frequency in historical data
