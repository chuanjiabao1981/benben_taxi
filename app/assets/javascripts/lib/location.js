var LocationUtil={
  buildMarker: function(location,title,icon,showlabel){
    if (location == null) {
      return;
    }
    showlabel = showlabel || false;
    marker = new BMap.Marker(new BMap.Point(location.lng, location.lat));
    label = void 0;
    if (showlabel && (location.desc != null) && location.desc !== "") {
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
    marker.setIcon(icon);
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
    return marker;
  },
  removeLocation: function(map,title){
    _all_overlays = map.getOverlays();
    i = 0;
    while (i < _all_overlays.length) {
      if ((_all_overlays[i] != null) && _all_overlays[i] instanceof BMap.Marker && _all_overlays[i].getTitle() == title ) {
        map.removeOverlay(_all_overlays[i]);
      }
      i++;
    }
  }
}