import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import "package:latlong/latlong.dart";
import 'package:location/location.dart' as loc;

class HomeController extends GetxController {
  RxBool selectedBottom = RxBool(false);
  Rx<Marker> myMarker = Rx<Marker>(Marker(
    width: 30.0,
    height: 30.0,
    point: LatLng(0, 0),
    builder: (ctx) => Container(
      child: Icon(Icons.accessibility),
    ),
  ));
  StreamSubscription _streamSubscription;
  loc.Location _tracker = loc.Location();
  MapController mapController = MapController();
  LatLng actualPosition = LatLng(0, 0);
  double actualZoom = 15;
  LatLng destinationPos = LatLng(0, 0);
  RxBool destinationMarkerEnable = RxBool(false);
  Rx<Marker> destinationMarker = Rx<Marker>(Marker(
    width: 30.0,
    height: 30.0,
    point: LatLng(0, 0),
    builder: (ctx) => Container(
      child: Icon(Icons.flag),
    ),
  ));

  //this is for the alarm
  double radiusOfAlarm = 0.5; //in km
  RxBool popUpVisible = RxBool(false);

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
      //updateMyPositionMarker(location);

      if (_streamSubscription != null) {
        _streamSubscription.cancel();
      }
      _streamSubscription = _tracker.onLocationChanged.listen((location) {
        print(location.toString());
        print("estado" + destinationMarkerEnable.value.toString());
        actualPosition = LatLng(location.latitude, location.longitude);
        if (mapController != null &&
            !destinationMarkerEnable.value &&
            location != null &&
            destinationPos == LatLng(0, 0)) {
          //_centerView(location);
          print("actualizando destination " + destinationPos.toString());
          centerView(location);
          updateMyPositionMarker(location);
        } else if (!destinationMarkerEnable.value) {
          //navigation mode activated
          print("With bounds");
          updateMyPositionMarker(location);
          centerWithBound();
          verifyDestination();
        }
      });
    } catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print("Permission Denied");
      } else {
        print(e.code);
      }
    }
  }

  void verifyDestination() {
    var distance = calculateDistance(actualPosition, destinationPos);
    print("DISTANCIA: " + distance.toString());
    if (distance < radiusOfAlarm && !popUpVisible.value) {
      popUpVisible.value = true;
      Get.defaultDialog(
          title: "Cerca de tu destino",
          content: Text("Deberias de ir hacia la parada y bajarte en breve"),
          textConfirm: "Aceptar",
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back();
          });
      print("------------estas cerca de tu destino----------");
    } else {
      print("verificando en trafico, aun no estas cerca ");
    }
  }

  ///Calculate distance between lat long
  ///input: lat1, lon1, lat2, lon2
  ///output: distance in km
  double calculateDistance(LatLng location1, LatLng location2) {
    var lat1 = location1.latitude;
    var lon1 = location1.longitude;
    var lat2 = location2.latitude;
    var lon2 = location2.longitude;
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void centerView(loc.LocationData locationData) {
    LatLng center = LatLng(locationData.latitude, locationData.longitude);
    double degree = 0;
    mapController.moveAndRotate(center, actualZoom, degree);
  }

  ///input: String mode, it can be in, out
  void zoom({String mode}) {
    if (mode == "out" && actualZoom > 5) {
      actualZoom--;
    } else if (mode == "in" && actualZoom < 18) {
      actualZoom++;
    }
    double degree = 0;
    mapController.moveAndRotate(actualPosition, actualZoom, degree);
  }

  void updateMarkerDestination() {
    print("actualizandoEnController: " + destinationPos.toString());
    destinationMarker.value = Marker(
      width: 30.0,
      height: 30.0,
      point: destinationPos,
      builder: (ctx) => Container(
        child: Icon(Icons.flag),
      ),
    );
  }

  void enableMarkerDestination() {
    destinationMarkerEnable.toggle();
  }

  void cleanDestination() {
    destinationPos = LatLng(0, 0);
    destinationMarker.value = Marker(
      width: 30.0,
      height: 30.0,
      point: destinationPos,
      builder: (ctx) => Container(
        child: Icon(Icons.flag),
      ),
    );
  }

  void centerWithBound() {
    var left = min(actualPosition.latitude, destinationPos.latitude);
    var right = max(actualPosition.latitude, destinationPos.latitude);
    var top = max(actualPosition.longitude, destinationPos.longitude);
    var bottom = min(actualPosition.longitude, destinationPos.longitude);

    var bounds = LatLngBounds(LatLng(left, bottom), LatLng(right, top));
    mapController.fitBounds(bounds);
  }
}
