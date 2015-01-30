function ridership(stime,etime,lat1,lon1,lat2,lon2,type){
    this.stime = stime;
    this.etime = etime;
    this.lat1 = lat1;
    this.lon1 = lon1;
    this.lat2 = lat2;
    this.lon2 = lon2;
    if(type == 0){
        this.marker = L.marker([lat1, lat2], {
            icon: L.mapbox.marker.icon({
            'marker-size': 'small',
            'marker-symbol': 'bicycle',
            'marker-color': '#fa0'
            })
        });
    }else{
        this.marker = L.marker([lat1, lat2], {
            icon: L.mapbox.marker.icon({
            'marker-size': 'small',
            'marker-symbol': 'bicycle',
            'marker-color': '#af0'
            })
        }); 
    }
    // 0: before 1:running 2:after
    this.isRunning = function(current_time){
        if(current_time < this.stime){
            return 0;
        }else if (current_time > this.etime){
            return 2;
        }return 1;
    }
    this.position = function(current_time){
        c = (current_time - stime)/(etime - stime);
        cur_lat = lat1 + (lat2 - lat1) * c;
        cur_lon = lon1 + (lon2 - lon1) * c;
        return [cur_lat,cur_lon];
    }
}

L.mapbox.accessToken = 'pk.eyJ1IjoieXVuaGFvY3MiLCJhIjoiaXBjOFctNCJ9.4JGjv-vwZz_ERyR5empKRg';
var map = L.mapbox.map('map', 'examples.map-h67hf2ic')
  .setView([38.91114, -77.04754], 14);

var layers = document.getElementById('menu-ui');

addLayer(L.mapbox.tileLayer('examples.bike-lanes'), 'Bike Lanes', 1);
addLayer(L.mapbox.tileLayer('examples.bike-locations'), 'Bike Stations', 2);

function addLayer(layer, name, zIndex) {
    layer
        .setZIndex(zIndex)
        .addTo(map);

    // Create a simple layer switcher that
    // toggles layers on and off.
    var link = document.createElement('a');
        link.href = '#';
        link.className = 'active';
        link.innerHTML = name;

    link.onclick = function(e) {
        e.preventDefault();
        e.stopPropagation();

        if (map.hasLayer(layer)) {
            map.removeLayer(layer);
            this.className = '';
        } else {
            map.addLayer(layer);
            this.className = 'active';
        }
    };

    layers.appendChild(link);
}
var ridelist;
var isLoadingJson = true;
var url = "https://rawgit.com/yunhaolucky/bikeshare/master/Stations/data/rideJune3012.json";
$.get(url, function(data) { 
       ridelist = JSON.parse(data).ridership;
       isLoadingJson = false;
}, 'text');

var index = 0;
    var r = [];
    var t = 0;
function setLocation(){
    if(isLoadingJson){
        setTimeout(setLocation, 250);
    }else{
while(index < ridelist.length && ridelist[index].start == t){
        cur = ridelist[index];
            console.log(index);
        if(cur.start != cur.end){
        r.push(new ridership(cur.start,cur.end,cur.s_lat,cur.s_lon,cur.e_lat,cur.e_lon,cur.type));
        }
        index ++;
}
        var p;
        var status;
        var cur;
    for(var i = 0; i < r.length; i ++){
        status = r[i].isRunning(t);
        if( status == 1){
            p = r[i].position(t);
            if(t > 150){
            console.log(r[i].stime+"-" + r[i].etime +": "+p);
            }
            r[i].marker.setLatLng(L.latLng(p[0],p[1]));
            r[i].marker.addTo(map);
        }else if (status == 2) {
            map.removeLayer(r[i].marker);
            r.splice(i,1);
        }
    }
    t += 1;
    info.update(t);
    }
}
var interval = window.setInterval(setLocation, 100);
for(var i = 0; i < r.length; i ++){
    r[i].marker.addTo(map);
}

var info = L.control({position: 'bottomleft'});

info.onAdd = function (map) {
    this._div = L.DomUtil.create('div', 'info'); // create a div with a class "info"
    this.update();
    return this._div;
};

// method that we will use to update the control based on feature properties passed
info.update = function (t) {
    var hours   = Math.floor(t / 60);
    var minutes = t - (hours * 60);

    if (hours   < 10) {hours   = "0"+hours;}
    if (minutes < 10) {minutes = "0"+minutes;}
    var time    = hours+':'+minutes;
    this._div.innerHTML = 'bikes on roads:'+r.length+'     <p>time:'+time+'';
};

info.addTo(map);
