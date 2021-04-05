import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:wake_app_2_0/app/modules/home/controllers/home_controller.dart';

class BottomAnimatedContainer extends GetView<HomeController> {
  final double cardsWidth = Get.width * 0.40;
  final TextEditingController textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedContainer(
        width: controller.selectedBottom.value ? 50 : 180,
        duration: Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
        height: controller.selectedBottom.value ? 50 : 180,
        child: content()));
  }

  Widget content() {
    return Container(
        width: Get.width,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 6,
                onPressed: () {
                  controller.selectedBottom.value =
                      !controller.selectedBottom.value;
                },
                child: controller.selectedBottom.value
                    ? Icon(
                        Icons.arrow_circle_up,
                        color: Get.theme.primaryColor,
                      )
                    : Icon(
                        Icons.arrow_circle_down,
                        color: Get.theme.primaryColor,
                      ),
                mini: true,
                backgroundColor: Colors.white,
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                          height: 50,
                          width: cardsWidth,
                          child: GestureDetector(
                              onTap: controller.enableMarkerDestination,
                              //let's enable our marker
                              child: Card(
                                elevation: 3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Elegir Destino"),
                                    Icon(
                                      Icons.place,
                                      color: Get.theme.primaryColor,
                                    ),
                                  ],
                                ),
                              ))),
                      Container(
                          height: 50,
                          width: cardsWidth,
                          child: GestureDetector(
                              onTap: controller.cleanDestination,
                              child: Card(
                                elevation: 3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(" Eliminar destino"),
                                    Icon(
                                      Icons.restore_from_trash_rounded,
                                      color: Get.theme.primaryColor,
                                    ),
                                  ],
                                ),
                              ))),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                          height: 50,
                          width: cardsWidth,
                          child: GestureDetector(
                              onTap: () {
                                //if marker not set, you can not find a route
                              },
                              child: Card(
                                elevation: 3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("   Info   "),
                                    Icon(
                                      Icons.info,
                                      color: Get.theme.primaryColor,
                                    ),
                                  ],
                                ),
                              ))),
                      Container(
                          height: 50,
                          width: cardsWidth,
                          child: GestureDetector(
                              onTap: () {
                                Get.defaultDialog(
                                    title: "Configuracion",
                                    content: configAlarm(),
                                    textConfirm: "Aceptar",
                                    confirmTextColor: Colors.white,
                                    onConfirm: () {
                                      // update the distante for the alarm
                                      //we have to convert from meters to km, so we divide by 1000
                                      controller.radiusOfAlarm =
                                          int.parse(textController.text) / 1000;
                                      print("new value is" +
                                          controller.radiusOfAlarm.toString());
                                      textController.text =
                                          "Distancia en metros"; //clean input
                                      Get.back();
                                    },
                                    onCancel: () {
                                      Get.back();
                                    });

                                print("-----markers length------");
                              },
                              child: Card(
                                elevation: 3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Configurar Alarma"),
                                    Icon(
                                      Icons.surround_sound,
                                      color: Get.theme.primaryColor,
                                    ),
                                  ],
                                ),
                              ))),
                    ],
                  ),
                ],
              )
            ]));
  }

  Widget configAlarm() {
    return Column(
      children: [
        Text("Inserte la distancia a la que desea que el recordatorio suene: "),
        Text("La distancia actual es: " +
            controller.radiusOfAlarm.toString() +
            " KM"),
        Card(
          elevation: 4,
          child: TextField(
              controller: textController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Distancia en metros')),
        )
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
        //   children: [],
        // ),
      ],
    );
  }
}
