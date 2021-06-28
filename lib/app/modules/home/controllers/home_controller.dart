import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import "package:latlong/latlong.dart";
import 'package:location/location.dart' as loc;

//player of alarm
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:location_permissions/location_permissions.dart';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

class HomeController extends GetxController {
  //to execute in background
  maps.CameraPosition initialLocation = maps.CameraPosition(
    target: maps.LatLng(-27.0, -57.0),
    zoom: 15,
  );
  Rx<maps.Marker> myMarker = Rx<maps.Marker>();
  RxBool selectedBottom = RxBool(false);
  maps.GoogleMapController mapController;
  Rx<maps.Marker> destinationMarker = Rx<maps.Marker>(
    maps.Marker(
      markerId: maps.MarkerId("Destination"),
      position: maps.LatLng(0, 0),
      infoWindow: maps.InfoWindow(title: "Destino"),
    ),
  );
  RxBool markerDestinationEnable = RxBool(false);
  StreamSubscription _streamSubscription;
  loc.Location _tracker = loc.Location();
  LatLng actualPosition = LatLng(0, 0);
  double actualZoom = 15;
  //LatLng destinationPos = LatLng(0, 0);
  RxBool destinationMarkerEnable = RxBool(false);
  maps.LatLng destinationPos = maps.LatLng(0, 0);

  //this is for the alarm
  double radiusOfAlarm = 0.5; //in km
  RxBool popUpVisible = RxBool(false);
  static SendPort uiSendPort;
  String isolateName = 'isolate';

  //player for the alarm
  Duration _duration = new Duration();
  Duration _position = new Duration();
  AudioPlayer advancedPlayer;
  AudioCache audioCache;
  String localFilePath;
  @override
  void onInit() async {
    //initialize the workmanager
    //request for permision
    PermissionStatus permission =
        await LocationPermissions().checkPermissionStatus();
    print(permission.toString());
    if (permission == PermissionStatus.unknown ||
        permission == PermissionStatus.denied) {
      PermissionStatus permissionAfterRequest =
          await LocationPermissions().requestPermissions();
      if (permissionAfterRequest == PermissionStatus.granted) {
        await getCurrentLocation();
      } else {
        Get.defaultDialog(
            title: "La app no puede ayudarte sin tu ubicación",
            content: Row(children: [
              Text("Debes de dar permisos para usar tu ubicación")
            ]),
            textConfirm: "Aceptar",
            onConfirm: () {
              Get.back();
            });
      }
    } else if (permission == PermissionStatus.granted) {
      await getCurrentLocation();
    }

    initPlayer();
    super.onInit();
  }

  @override
  void onReady() {
    Timer.periodic(Duration(seconds: 10), (timer) {
      seeLocation();
    });
    super.onReady();
  }

  @override
  void onClose() {}

//-------------------background task------------------
  Future<void> seeLocation() async {
    print("----------------------loking for location-----------------------");
    loc.LocationData location = await _tracker.getLocation();
    var newLocation = LatLng(location.latitude, location.longitude);
    actualPosition = LatLng(location.latitude, location.longitude);
    updateMyPositionMarker(newLocation);
    centerWithBound();
    verifyDestination();
  }

/*------normal tasks-----*/
  Future<void> getCurrentLocation() async {
    try {
      //loc.LocationData location = await _tracker.getLocation();
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
            destinationPos == maps.LatLng(0, 0)) {
          //_centerView(location);
          print("actualizando destination " + destinationPos.toString());
          //centerView(actualPosition);
          updateMyPositionMarker(actualPosition);
        } else if (!destinationMarkerEnable.value &&
            destinationPos != maps.LatLng(0, 0)) {
          //navigation mode activated
          print("DESTINATIOM" + destinationPos.toString());
          updateMyPositionMarker(actualPosition);
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

  void initPlayer() {
    advancedPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: advancedPlayer);

    advancedPlayer.durationHandler = (d) => () {
          _duration = d;
        };

    advancedPlayer.positionHandler = (p) => () {
          _position = p;
        };
  }

  void onMapCreated(maps.GoogleMapController controller) {
    mapController = controller;
  }

  void updateDestinationPositionMarker(maps.LatLng destinationPos) {
    destinationMarker.value = maps.Marker(
        markerId: maps.MarkerId("Destination"),
        position: destinationPos,
        infoWindow: maps.InfoWindow(title: "Destino"));
  }

  void updateMyPositionMarker(LatLng dataPos) async {
    maps.LatLng latlng = maps.LatLng(dataPos.latitude, dataPos.longitude);
    myMarker.value = maps.Marker(
      markerId: maps.MarkerId("MyMarker"),
      position: latlng,
      draggable: false,
      zIndex: 2,
      anchor: Offset(0.5, 0.5),
      infoWindow: maps.InfoWindow(title: "Posicion Actual"),
    );
  }

  void verifyDestination() {
    var distance = calculateDistance(myMarker.value.position, destinationPos);
    print("DISTANCIA: " + distance.toString());
    if (distance < radiusOfAlarm && !popUpVisible.value) {
      popUpVisible.value = true;
      // shotAlarm();
      audioCache.play('audios/alarm.mp3');
      Get.defaultDialog(
          title: "Cerca de tu destino",
          content: Column(
            children: [
              Text("Deberias de ir hacia la parada y bajarte en breve"),
              Text("Pula aceptar para parar la alarma")
            ],
          ),
          textConfirm: "Aceptar",
          confirmTextColor: Colors.white,
          onConfirm: () {
            advancedPlayer.stop();
            Get.back();
          });
      print("------------estas cerca de tu destino----------");
    } else {
      print("verificando en trafico, aun no estas cerca ");
    }
  }

  Future<void> callback() async {
    print('Alarm fired!');
    // This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
  }

  ///Calculate distance between lat long
  ///input: lat1, lon1, lat2, lon2
  ///output: distance in km
  double calculateDistance(maps.LatLng location1, maps.LatLng location2) {
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

  centerView(maps.LatLng dataActualPos) async {
//in case of destination marker not setted
    print("el valor del destino es");
    print(destinationPos.toJson());
    if (destinationPos == maps.LatLng(0, 0)) {
      mapController.animateCamera(
        maps.CameraUpdate.newCameraPosition(
          maps.CameraPosition(
            bearing: 0,
            target: dataActualPos,
            tilt: 0,
            zoom: 15.00,
          ),
        ),
      );
    } else {
      await mapController.getVisibleRegion(); //wait to load the map
      //let's draw a rectangle for our centerView
      var left = min(dataActualPos.latitude, destinationPos.latitude);
      var right = max(dataActualPos.latitude, destinationPos.latitude);
      var top = max(dataActualPos.longitude, destinationPos.longitude);
      var bottom = min(dataActualPos.longitude, destinationPos.longitude);

      var bounds = maps.LatLngBounds(
          southwest: maps.LatLng(left, bottom),
          northeast: maps.LatLng(right, top));
      var cameraUpdate = maps.CameraUpdate.newLatLngBounds(bounds, 80);
      mapController.animateCamera(cameraUpdate);
    }
  }

  ///input: String mode, it can be in, out
  void zoom({String mode}) {
    if (mode == "out" && actualZoom > 5) {
      actualZoom--;
    } else if (mode == "in" && actualZoom < 18) {
      actualZoom++;
    }
    double degree = 0;
    //mapController.moveAndRotate(actualPosition, actualZoom, degree);
  }

  void enableMarkerDestination() {
    markerDestinationEnable.toggle();
    //destinationMarkerEnable.toggle();
  }

  void cleanDestination() {
    //popUpVisible.value = false; // to launch again the popUp on a new pos
    destinationPos = maps.LatLng(0, 0);
    destinationMarker = Rx<maps.Marker>(
      maps.Marker(
        markerId: maps.MarkerId("Destination"),
        position: maps.LatLng(0, 0),
        infoWindow: maps.InfoWindow(title: "Destino"),
      ),
    );
  }

  void centerWithBound() {
    var left = min(actualPosition.latitude, destinationPos.latitude);
    var right = max(actualPosition.latitude, destinationPos.latitude);
    var top = max(actualPosition.longitude, destinationPos.longitude);
    var bottom = min(actualPosition.longitude, destinationPos.longitude);

    var bounds = LatLngBounds(LatLng(left, bottom), LatLng(right, top));
    //mapController.fitBounds(bounds);
  }
}
