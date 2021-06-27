import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:get/get.dart';
import 'package:wake_app_2_0/app/modules/widgets/bottom_sheet_widget.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Obx(() => maps.GoogleMap(
                zoomControlsEnabled: false,
                zoomGesturesEnabled: true,
                mapToolbarEnabled: true,
                compassEnabled: false,
                myLocationButtonEnabled: true,
                initialCameraPosition: controller.initialLocation,
                markers: Set.of(
                  (controller.myMarker.value == null)
                      ? []
                      : [
                          controller.myMarker.value,
                          //controller.destinationMarker.value,
                        ],
                ),
                onMapCreated: controller.onMapCreated,
                onCameraMove: (position) {
                  if (controller.markerDestinationEnable.value) {
                    controller.destinationPos = position.target;
                    print("moviendo" + position.target.toString());
                  }
                },
                onCameraIdle: () async {
                  // you can use the captured location here. when the user stops moving the map.

                  if (controller.markerDestinationEnable.value) {
                    //call to update the marker
                    controller.updateDestinationPositionMarker(
                      controller.destinationPos,
                    );
                  }
                },
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
              heroTag: 1,
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
              heroTag: 2,
              child: Center(child: Icon(Icons.minimize_sharp)),
              onPressed: () {
                controller.zoom(mode: "out");
              },
            ),
          ),
          Positioned(
            bottom: 40,
            left: 30,
            right: 30,
            //width: Get.width,
            child: BottomAnimatedContainer(),
          ),
        ],
      ),
    );
  }
}
