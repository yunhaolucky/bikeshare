import requests
from bs4 import BeautifulSoup
from types import NoneType
import os
import datetime
import calendar
import psycopg2 

def extract_str(element):
    if type(element) is NoneType:
        return element
    else:
        return element.string

class EST(datetime.tzinfo):
    def utcoffset(self, dt):
      return datetime.timedelta(hours=-5)

    def dst(self, dt):
        return datetime.timedelta(0)


def main():
    conn = psycopg2.connect(database='bikeshare',user='yunhao')
    cur = conn.cursor()
    url = 'http://www.capitalbikeshare.com/data/stations/bikeStations.xml'
    r = requests.get(url)
    timestamp = datetime.datetime.now(EST())
    timestamp = timestamp.replace(second = 0, microsecond = 0)
    fulltext = r.text
   
    soup = BeautifulSoup(fulltext)

    for station in soup.find_all("station"):
        ident = long(extract_str(station.find("id")))
        bikes = long(extract_str(station.find("nbbikes")))
        stations = long(extract_str(station.find("nbemptydocks")))

        cur.execute("""INSERT INTO station_status (tfl_id, bikes, spaces, timestamp) VALUES (%s, %s,%s,%s);""",(ident, bikes,stations,timestamp))
    conn.commit()

if __name__ == '__main__':
	main()
