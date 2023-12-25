import 'package:flutter/material.dart';
import 'TelaDados.dart';
import 'back_services.dart';
import 'database_helper.dart';
import 'home.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  // inicializar uma instancia de WidgetsFlutterBinding. In the Flutter framework,
  // the WidgetsFlutterBinding class plays a crucial role. It is responsible for
  // the application's lifecycle, handling input gestures, and triggering the build
  // and layout of widgets. It also manages the widget tree, a hierarchy of widgets
  // that Flutter uses to choose which widgets to render and how to render them.
  // The WidgetsFlutterBinding class also interacts with the native code of the
  // platform it's running on.
  WidgetsFlutterBinding.ensureInitialized();
  // função para preencher a tabela SQL com os dados das séries
  void preencherDados() async {
    var fido = const Toggle_reg(id: 1, valorToggle: 0, dataCompara: '');
    var fido2 = const Toggle_reg(id: 2, valorToggle: 0, dataCompara: '');
    await DatabaseHelper.insertToggle(fido);
    await DatabaseHelper.insertToggle(fido2);
  }
  // chamar a função anterior
  preencherDados();

  NotificationService().initNotification();
  await Permission.notification.isDenied.then(
        (value){
      if(value){
        Permission.notification.request();
      }
    },
  );

  isNotificationGranted = await Permission.notification.isGranted;

  print("isNotificationGranted: $isNotificationGranted");


  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}



