import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:dados_economicos/variables_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:dados_economicos/TelaDados.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;


class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings('app_icone');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  Future showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.show(
        id, title, body, await notificationDetails());
  }
}

var service;

Future<void> initializeService() async {
  service = FlutterBackgroundService();
  await service.configure(iosConfiguration: IosConfiguration(
    autoStart: true,
    onForeground: onStart,
    onBackground: onIosBackground,
  ),
      androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          isForegroundMode: true,
          autoStart: true
      )
  );
}

Future<String> getJsonFromRestAPI2() async {
  String? numeroSGS = await getStringFromLocalStorage("numeroSerieSGS");
  String url = "https://api.bcb.gov.br/dados/serie/bcdata.sgs.$numeroSGS/dados?formato=json";
  http.Response response = await http.get(Uri.parse(url));
  return response.body;
}

@pragma('vm:registry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

List<serieSGS> listaBack = [];
var ultimaDataIPCA;
Future loadIPCAData2() async {
  String jsonString = await getJsonFromRestAPI2();
  final jsonResponse = json.decode(jsonString);
  for (Map<String, dynamic> i in jsonResponse){
    listaBack.add(serieSGS.fromJson(i));
  }
  ultimaDataIPCA = listaBack.last.data;
}

@pragma('vm:registry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();
  if(service is AndroidServiceInstance){
    service.on("setAsForeground").listen((event) {
      service.setAsForegroundService();
    });
    service.on("setAsBackground").listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on("stopService").listen((event) {
    service.stopSelf();
  });

  //NotificationService().initNotification();
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if(service is AndroidServiceInstance){
      if(await service.isForegroundService()){
        service.setForegroundNotificationInfo(title: "SCRIPT ACADEMY", content: "sub my channel");
      }
    }
      // perfom some operation on background which is not noticeable to the user everytime
      //print("background service running");

    loadIPCAData2();

    print("background service running $ultimaDataIPCA");

    String? numeroSGS = await getStringFromLocalStorage("numeroSerieSGS");
    String? dataFinal = await getStringFromLocalStorage("dataFinal");

/*    getStringFromLocalStorage("meuNumero").then((String ret) {
      print("ret: $ret");
      numeroTeste = ret;
    });*/
    print("numeroTeste: $numeroSGS");
    print("data final: $dataFinal");

/*    if(numeroSGS=="433"){
      NotificationService().showNotification(title: 'Sample title', body: '$numeroSGS');
    }*/

    });

}
