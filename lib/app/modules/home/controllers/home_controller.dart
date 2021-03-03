import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import "package:latlong/latlong.dart";
import 'package:location/location.dart' as loc;

class HomeController extends GetxController {
  RxBool selectedBottom = RxBool(false);
  Rx<Marker> myMarker = Rx<Marker>();
  StreamSubscription _streamSubscription;
  loc.Location _tracker = loc.Location();
  MapController mapController = MapController();

  @override
  void onInit() async {
    await getCurrentLocation();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
  void updateMyPositionMarker(loc.LocationData dataPos) async {
    LatLng newPos = LatLng(dataPos.latitude, dataPos.longitude);
    myMarker.value = Marker(
      width: 30.0,
      height: 30.0,
      point: newPos,
      builder: (ctx) => Container(
        child: Icon(Icons.accessibility),
      ),
    );
  }

  Future<void> getCurrentLocation() async {
    try {
      loc.LocationData location = await _tracker.getLocation();
      updateMyPositionMarker(location);
      print("updating");
      if (_streamSubscription != null) {
        _streamSubscription.cancel();
      }
      _streamSubscription = _tracker.onLocationChanged.listen((location) {
        print("hola");
        if (mapController != null) {
          //_centerView(location);
          print("actualizando");
          centerView(location);
          updateMyPositionMarker(location);
        }
        /*else if (navigationMode.value) {
          //navigation mode activated
          updateMyPositionMarker(data);
          _centerViewInNavigation(lastRotation, whoIsCalling: "location");
          var position = maps.LatLng(data.latitude, data.longitude);
          // in each trigger, we have to calculate the next direction
          findNextDirection(position);
        }*/
      });
    } catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print("Permission Denied");
      } else {
        print(e.code);
      }
    }
  }

  Future<void> centerView(loc.LocationData locationData) async {
    LatLng center = LatLng(locationData.latitude, locationData.longitude);
    double zoom = 15;
    double degree = 0;
    mapController.moveAndRotate(center, zoom, degree);
  }
}
