import 'package:flutter/material.dart';
import 'back_services.dart';
import 'home.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  await Permission.notification.isDenied.then(
        (value){
      if(value){
        Permission.notification.request();
      }
    },
  );

  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}



