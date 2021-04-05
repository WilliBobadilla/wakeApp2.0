import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'dart:core';
import 'package:url_launcher/url_launcher.dart';
import 'package:wake_app_2_0/app/modules/about/controllers/about_controller.dart';

class AboutView extends GetView<AboutController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acerca'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            height: 30,
          ),
          Text(
            'WakeApp 2.0',
            style: TextStyle(fontSize: 35),
          ),
          Container(
            height: 20,
          ),
          Text(
            'Una misión, una visión',
            style: TextStyle(fontSize: 25),
          ),
          Container(
            height: 30,
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Williams Bobadilla"),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Martin Encina"),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Victor Gallardo"),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text("Email del desarollador:"),
          ),
          ListTile(
            leading: Icon(Icons.verified_sharp),
            title: Text("Version 2.0 "),
          ),
          Padding(
              padding: EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("willi1997.1@gmail.com"),
                  Text("Enviar mail: "),
                  GestureDetector(
                    onTap: () async {
                      await launch(
                          "mailto:willi1997.1@gmail.com?subject=Soporte&body=Hola%20Williams,");
                    },
                    child: Icon(Icons.mail),
                  )
                ],
              ))
        ]),
      ),
      //Row(children: [Text("willi1997.1@gmail.com")],)
    );
  }
}
