$(function() {
  var map, point;
  map = void 0;
  if ($("#map-container")[0]) {
    map = new BMap.Map("map-container");
    point = new BMap.Point(116.404, 39.915);
    map.addControl(new BMap.NavigationControl());
    map.addControl(new BMap.ScaleControl());
    map.addControl(new BMap.OverviewMapControl());
    map.addControl(new BMap.MapTypeControl());
    map.centerAndZoom(point, 15);
  }
});
