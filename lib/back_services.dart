import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:dados_economicos/TelaDados.dart';
import 'package:dados_economicos/variables_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'database_helper.dart';

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



//====================================================================================

var service1;

Future<void> initializeService1() async {
  service1 = FlutterBackgroundService();
  await service1.configure(iosConfiguration: IosConfiguration(
    autoStart: true,
    onForeground: onStart1,
    onBackground: onIosBackground1,
  ),
      androidConfiguration: AndroidConfiguration(
          onStart: onStart1,
          isForegroundMode: true,
          autoStart: true
      )
  );
}

var urlSerie;
var cod_serie;
var fonte;
var valorToggleDB;
var metricaArmaz;
var localidadeArmaz;
var categoriaArmaz;

Future<String> getJsonFromRestAPI2() async {
  //String? urlSerie = await getStringFromLocalStorage("urlSerieArmaz");
  String url = urlSerie;
  http.Response response = await http.get(Uri.parse(url));
  return response.body;
}

@pragma('vm:registry-point')
Future<bool> onIosBackground1(ServiceInstance service1) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}



List<serie_app> listaBack = [];
//var ultimaData;

Future loadDataSGS2() async {
  String jsonString = await getJsonFromRestAPI2();
  final jsonResponse = json.decode(jsonString);
  for (Map<String, dynamic> i in jsonResponse){
    listaBack.add(serie_app.fromJson(i));
  }
}

Future loadDataIBGE2() async {
  String jsonString = await getJsonFromRestAPI2();
  final jsonResponse = json.decode(jsonString);
  final item = jsonResponse[0]['resultados'][0]['series'][0]['serie'];
  for (var i = 0; i<item.keys.toList().length; i++){
    var x = item.keys.toList()[i];
    x = formatter1.format(int.parse(x.substring(4))) + "/" + formatter2.format(int.parse(x.substring(0, 4)));
    var y = item.values.toList()[i].toString();
    if(y!="..."&&y!="-"){
      listaBack.add(
          serie_app(
              DateFormat('MM/yyyy').parse(x),
              double.parse(y)
          )
      );
    }
  }
}

NumberFormat formatter1 = new NumberFormat("00");
NumberFormat formatter2 = new NumberFormat("0000");

//List<Toggle_reg>? valorToggleBack;
var dataArmazenada;
List<Toggle_reg>? valorData;

@pragma('vm:registry-point')
void onStart1(ServiceInstance service1) {
  DartPluginRegistrant.ensureInitialized();
  if(service1 is AndroidServiceInstance){
    service1.on("setAsForeground").listen((event) {
      service1.setAsForegroundService();
    });
    service1.on("setAsBackground").listen((event) {
      service1.setAsBackgroundService();
    });
  }
  service1.on("stopService").listen((event) {
    service1.stopSelf();
  });

  Future recuperaData() async {
    valorData = await DatabaseHelper.getAllToggle();
  }
  recuperaData();



  //NotificationService().initNotification();
  Timer.periodic(const Duration(seconds: 1), (timer) async {
/*    if(service1 is AndroidServiceInstance){
      if(await service1.isForegroundService()){
        service1.setForegroundNotificationInfo(title: "SCRIPT ACADEMY", content: "sub my channel");
      }
    }*/
      // perfom some operation on background which is not noticeable to the user everytime
      //print("background service running");

    var ultimaData;


    //print("valorData: $valorData");

    for(var i = 0; i< valorData!.length; i++){
      if(valorData![i].valorToggle==1){
        cod_serie = valorData![i].id;
        urlSerie = listaSeries.firstWhere((element) => element.numero==cod_serie).urlAPI;
        fonte = listaSeries.firstWhere((element) => element.numero==cod_serie).fonte;
        if(fonte=="IBGE"){
          loadDataIBGE2();
        } else {
          loadDataSGS2();
        }
        // ultima data recuperada da API
        if(listaBack.isNotEmpty){
          ultimaData = listaBack.last.data.toString();
        } else {
          print("lista vazia");
        }


        dataArmazenada = valorData?.firstWhere((element) => element.id==cod_serie).dataCompara;

        //dataArmazenada = '2023-12-01 00:00:00.000';

        valorToggleDB = valorData?.firstWhere((element) => element.id==cod_serie).valorToggle;

        print("background service running $ultimaData");
        print("url da serie: $urlSerie");
        print("dataArmazenada: $dataArmazenada");

        var nomeSerie = listaSeries.firstWhere((element) => element.numero==cod_serie).nome;

        metricaArmaz = await getStringFromLocalStorage("metricaArmaz");
        localidadeArmaz = await getStringFromLocalStorage("localidadeArmaz");
        categoriaArmaz = await getStringFromLocalStorage("categoriaArmaz");

        print("ultimaData: $ultimaData");
        if(dataArmazenada!=null && ultimaData!=null && (ultimaData!=dataArmazenada)){
          NotificationService().showNotification(title: 'Atualização de série', body: "A série  '$nomeSerie - $metricaArmaz - $localidadeArmaz - $categoriaArmaz' foi atualizada!");
          await DatabaseHelper.insertToggle(Toggle_reg(id: cod_serie, valorToggle: valorToggleDB, dataCompara: ultimaData.toString()));
        }
      }
    }
    });
}

