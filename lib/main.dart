import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "WakeApp2.0",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
