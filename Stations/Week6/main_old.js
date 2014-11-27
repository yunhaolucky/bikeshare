
var line;
var line2;

function initialize() {
  var mapOptions = {
 center: { lat: 38.91114, lng: -77.04754},
          zoom: 13
  };

  var map = new google.maps.Map(document.getElementById('map-canvas'),
      mapOptions);

  var lineCoordinates = [
    new google.maps.LatLng(38.91, -77.01),
    new google.maps.LatLng(38.89, -77.05)
  ];
   var lineCoordinates2 = [
    new google.maps.LatLng(38.93, -77.04),
    new google.maps.LatLng(38.95, -77.06)
  ];

  // Define the symbol, using one of the predefined paths ('CIRCLE')
  // supplied by the Google Maps JavaScript API.
  var lineSymbol = {
    path: google.maps.SymbolPath.FORWARD_OPEN_ARROW,
    scale: 3,
    strokeColor: '#393'
  };

  // Create the polyline and add the symbol to it via the 'icons' property.
  line = new google.maps.Polyline({
    path: lineCoordinates,
    icons: [{
      icon: lineSymbol,
      offset: '100%'
    }],
    map: map
  });
    line2 = new google.maps.Polyline({
    path: lineCoordinates2,
    icons: [{
      icon: lineSymbol,
      offset: '100%'
    }],
    map: map
  });

  animateCircle();
  animateCircle2();
}

// Use the DOM setInterval() function to change the offset of the symbol
// at fixed intervals.
function animateCircle() {
    var count = 0;
    window.setInterval(function() {
      count = (count + 1) % 200;

      var icons = line.get('icons');
      var icons2 = line2.get('icons');
      icons[0].offset = (count / 2) + '%';
      icons[0].offset = (count / 3) + '%';
      line.set('icons', icons);
      line2.set('icons', icons);
  }, 10);





}

google.maps.event.addDomListener(window, 'load', initialize);