getLocationIssueInfoWindow = function(location) {
  var infoWindow;
  infoWindow = void 0;
  if (location == null) {
    return null;
  }
  if (location.issue_info != null) {
    infoWindow = new BMap.InfoWindow(location.issue_info, {
      title: "<div style='border-bottom:2px dotted'>" + location.name + "</div>",
      height: 0,
      width: 0
    });
    return infoWindow;
  }
  return null;
};
showLocationList = function(map,locations,title) {
  if (locations != null) {
    i = 0;
    _results = [];
    while (i < locations.length) {
      showLocation(map, locations[i],title);
      _results.push(i++);
    }
    return _results;
  }
};
showLocation = function(map, location,title) {
  var label, marker;
  marker = buildMaker(location,title);
  return map.addOverlay(marker);
};

showLatestTaxi=function(map)
{
  LocationUtil.removeLocation(map,'taxi');
  $.ajax({
        url:    '/api/v1/driver_track_points',
        dataType: "json",
        success: function(data,status,jqXHR){
          if (data != null){
            markerClusterMananger.ShowMakersAsCluster('taxi',data);
          }
        }
      })
}

showLatesTaxiRequests=function(map)
{
  LocationUtil.removeLocation(map,'taxi_request');
  $.ajax({
    url:     '/api/v1/taxi_requests/latest',
    dataType: "json",
    beforeSend: function(jqXHR,settings){
    },
    error:  function(jqXHR, textStatus, errorThrown ){
    },
    success : function(data,status,jqXHR){
      if (data != null){
        markerClusterMananger.ShowMakersAsCluster('taxi_request',data);
      }else{
      }
    }
  }
  )
}


var markerClusterMananger;

MarkerClusterMananger = function(map)
{
  this._cluster = {}
  this._map     = map;
}

MarkerClusterMananger.prototype.ShowMakersAsCluster = function(title,locations)
{

  var markers = [];
  if (locations != null) {
    i = 0;
    while (i < locations.length) {
      markers.push(LocationUtil.buildMarker(locations[i],title,Icons[title]));
      i++;
    }
  }
  if (this._cluster[title] == null){
      this._cluster[title] = new BMapLib.MarkerClusterer(this._map, {markers:markers,styles: ClusterStyle[title]});
  }else{
      this._cluster[title].clearMarkers();
      this._cluster[title] = new BMapLib.MarkerClusterer(this._map, {markers:markers,styles: ClusterStyle[title]});
  }
}




var Icons = {
  "taxi"          : new BMap.Icon('assets/cluster/steering.png',new BMap.Size(32,32)),
  "taxi_request"  : new BMap.Icon('assets/cluster/passenger.png',new BMap.Size(32, 32))
}
var ClusterStyle={
  "taxi"          :[{
    url: 'assets/cluster/m2.png',
    size: new BMap.Size(66,66)
  }],
  "taxi_request"  :[{
    url: 'assets/cluster/m0.png',
    size: new BMap.Size(53,53)
  }]
}

$(function() {
  var map, point;
  map = void 0;
  if ($("#map-container")[0]) {
    map = new BMap.Map("map-container");
    //point = new BMap.Point(113.959845,22.540555);
    point = new BMap.Point(113.600712,37.854455)
    map.addControl(new BMap.NavigationControl());
    map.addControl(new BMap.ScaleControl());
    map.addControl(new BMap.OverviewMapControl());
    map.addControl(new BMap.MapTypeControl());
    map.centerAndZoom(point, 11);
    markerClusterMananger = new MarkerClusterMananger(map);

    setInterval(function(){showLatestTaxi(map)},2000);
    setInterval(function(){showLatesTaxiRequests(map)},2000);
  }
});
