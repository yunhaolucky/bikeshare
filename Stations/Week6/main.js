function ridership(stime,etime,lat1,lon1,lat2,lon2){
    this.stime = stime;
    this.etime = etime;
    this.lat1 = lat1;
    this.lon1 = lon1;
    this.lat2 = lat2;
    this.lon2 = lon2;
    this.marker = L.marker([lat1, lat2], {
        icon: L.mapbox.marker.icon({
        'marker-color': '#f86767'
        })
    });
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
  .setView([38.91114, -77.04754], 18);

var layers = document.getElementById('menu-ui');

addLayer(L.mapbox.tileLayer('examples.map-i87786ca'), 'Base Map', 1);
addLayer(L.mapbox.tileLayer('examples.bike-lanes'), 'Bike Lanes', 2);
addLayer(L.mapbox.tileLayer('yunhaocs.kb529eif'), 'Bike Stations', 3);

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

var r = [];
r.push(new ridership(1,10,38.91114, -77.04754,38.9113,-77.04654)); 
r.push(new ridership(10,17,38.9113,-77.04654,38.9116,-77.04665));
var t = 0;
window.setInterval(function() {
    var p;
    var status;
    for(var i = 0; i < r.length; i ++){
        //alert("t"+r[i].isRunning(t));
        status = r[i].isRunning(t);
        //alert(status);
        if( status == 1){
            p = r[i].position(t);
            //alert(p);
            r[i].marker.setLatLng(L.latLng(p[0],p[1]));
        }else if (status == 2) {
            map.removeLayer(r[i].marker);
        }
    }
    t += 1;
}, 50);
L.marker([38.91114, -77.04754]).addTo(map);
L.marker([38.9113,-77.04654]).addTo(map);
for(var i = 0; i < r.length; i ++){
    r[i].marker.addTo(map);
}


