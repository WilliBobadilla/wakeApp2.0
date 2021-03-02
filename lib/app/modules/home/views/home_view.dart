import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import "package:latlong/latlong.dart";
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      //floatingActionButton: SideBarCustom(),
      body: Stack(
        children: <Widget>[
          FlutterMap(
            options: MapOptions(
              center: LatLng(-25.3389, -57.5210),
              zoom: 13.0,
            ),
            layers: [
              TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']),
              MarkerLayerOptions(
                markers: [
                  Marker(
                    width: 30.0,
                    height: 30.0,
                    point: LatLng(51.5, -0.09),
                    builder: (ctx) => Container(
                      child: FlutterLogo(),
                    ),
                  ),
                ],
              ),
            ],
          ),

          /*Obx(
            () => Visibility(
              visible: controller.markerDestinationEnable.value,
              child: Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.place,
                  color: Get.theme.primaryColor,
                ),
              ),
            ),
          ),*/
          Positioned(
            bottom: 40,
            right: 20,
            child: FloatingActionButton(
              child: Center(child: Icon(Icons.add)),
              onPressed: () {},
            ),
          ),
          Positioned(
            bottom: 110,
            right: 20,
            child: FloatingActionButton(
              child: Center(child: Icon(Icons.minimize_sharp)),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
