import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import "package:latlong/latlong.dart";
import 'package:get/get.dart';
import 'package:wake_app_2_0/app/modules/widgets/bottom_sheet_widget.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      //floatingActionButton: SideBarCustom(),
      body: Stack(
        children: <Widget>[
          Obx(() => FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  onPositionChanged: (MapPosition position, bool isOk) {
                    print("changing: " + position.center.toString());
                    if (controller.destinationMarkerEnable.value) {
                      controller.destinationMarker.value = Marker(
                        width: 30.0,
                        height: 30.0,
                        point: position.center,
                        builder: (ctx) => Container(
                          child: Icon(Icons.flag),
                        ),
                      );
                    }
                  },
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
                      controller.myMarker.value,
                      controller.destinationMarker.value
                    ],
                  ),
                ],
              )),
          Obx(
            () => Visibility(
              visible: controller.destinationMarkerEnable.value,
              child: Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.place,
                  color: Get.theme.primaryColor,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 110,
            right: 20,
            child: FloatingActionButton(
              child: Center(child: Icon(Icons.add)),
              onPressed: () {
                controller.zoom(mode: "in");
              },
            ),
          ),
          Positioned(
            bottom: 40,
            right: 20,
            child: FloatingActionButton(
              child: Center(child: Icon(Icons.minimize_sharp)),
              onPressed: () {
                controller.zoom(mode: "out");
              },
            ),
          ),
          Positioned(
            bottom: 40,
            left: 35,
            right: 30,
            child: BottomAnimatedContainer(),
          ),
        ],
      ),
    );
  }
}
