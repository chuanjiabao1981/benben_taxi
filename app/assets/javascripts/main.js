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
removeLocation = function(map,title)
{
  _all_overlays = map.getOverlays();
  i = 0;
  while (i < _all_overlays.length) {
    if ((_all_overlays[i] != null) && _all_overlays[i] instanceof BMap.Marker && _all_overlays[i].getTitle() == title ) {
      map.removeOverlay(_all_overlays[i]);
    }
  i++;
  }
}
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
  label = void 0;
  marker = void 0;
  label = void 0;
  marker = void 0;
  if (location == null) {
    return;
  }
  marker = new BMap.Marker(new BMap.Point(location.lng, location.lat));
  //marker.location_info = getLocationIssueInfoWindow(location);
  label = void 0;
  if ((location.desc != null) && location.desc !== "") {
    label = new BMap.Label(location.desc);
    label.setOffset(new BMap.Size(15, -20));
    label.setStyle({
      position: "relative",
      border: "1px solid",
      padding: "2px",
      fontSize: "80%",
      color: "white",
      backgroundColor: "#C0605F"
    });
    label.enableMassClear();
    marker.setLabel(label);
  }
  marker.setTitle(title);


  marker.addEventListener("mouseover", function(e) {
    return e.target.setTop(true);
  });
  marker.addEventListener("mouseout", function(e) {
    return e.target.setTop(false);
  });
  marker.addEventListener("click", function(e) {
    if (e.target.location_info != null) {
      return e.target.openInfoWindow(e.target.location_info);
    }
  });
  return map.addOverlay(marker);
};

showLatestDriverLocation=function(map,driver_ids)
{
  removeLocation(map,'taxi');
  if (driver_ids == null || driver_ids.length == 0){
    return;
  }

  $.ajax({
        url:    '/api/v1/driver_track_points',
        dataType: "json",
        data: {"driver_ids[]":driver_ids},
        success: function(data,status,jqXHR){
          if (data != null){
            showLocationList(map,data,'taxi');
          }
        }
      })
}

showLatesTaxiRequests=function(map)
{
  removeLocation(map,'taxi_request');

  $.ajax({
    url:     '/api/v1/taxi_requests',
    dataType: "json",
    success : function(data,status,jqXHR){
      if (data != null){
        showLocationList(map,data,'taxi_request');
      }
    }
  }
  )
}


$(function(){
  $('#drivers_list input:checkbox').click(function(){
    var driver_ids = $('div#driver_ids').data('driver-ids')
    if (driver_ids == null){
      driver_ids = new Array();
    }
    check_value = this.value;
    driver_ids = $.grep(driver_ids,function(value,i){
      return value != check_value;
    });
    if (this.checked == true){
     driver_ids.push(this.value) 
    }
    $('div#driver_ids').data('driver-ids',driver_ids);
  });
}
)
$(function() {
  var map, point;
  map = void 0;
  if ($("#map-container")[0]) {
    map = new BMap.Map("map-container");
    point = new BMap.Point(113.959845,22.540555);
    map.addControl(new BMap.NavigationControl());
    map.addControl(new BMap.ScaleControl());
    map.addControl(new BMap.OverviewMapControl());
    map.addControl(new BMap.MapTypeControl());
    map.centerAndZoom(point, 11);
    setInterval(function(){
      showLatestDriverLocation(map,$('div#driver_ids').data('driver-ids'))
    },
    1000);
    setInterval(function(){showLatesTaxiRequests(map)},5000);
  }
});
