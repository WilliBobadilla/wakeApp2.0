import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// The [SharedPreferences] key to access the alarm fire count.
  const String countKey = 'count';

  /// The name associated with the UI isolate's [SendPort].
  const String isolateName = 'isolate';
  // Register the UI isolate's SendPort to allow for communication from the
  // background isolate.
  final ReceivePort port = ReceivePort();

  /// Global [SharedPreferences] object.
  SharedPreferences prefs;
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );
  prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(countKey)) {
    await prefs.setInt(countKey, 0);
  }
  await AndroidAlarmManager.initialize();
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "WakeApp2.0",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
