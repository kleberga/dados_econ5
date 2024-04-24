import 'package:dados_economicos/variables_class.dart';
import 'package:flutter/material.dart';
import 'TelaDados.dart';
import 'back_services.dart';
import 'configuracao.dart';
import 'database_helper.dart';
import 'home.dart';
import 'package:permission_handler/permission_handler.dart';

List<cadastroSeries> listaIBGE = [];
List<Metrica> listaMetrica = [];
List<NivelGeografico> listaNivelGeografico = [];
List<Localidades> listaLocalidades = [];
List<Categorias> listaCategorias = [];
var listaCombinada;


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
/*  void preencherDados() async {
    for(var i = 0; i<listaSeries.length; i++){
      var numeroSerie = listaSeries[i].numero;
      var fido = Toggle_reg(id: numeroSerie, valorToggle: 0, dataCompara: '');
      await DatabaseHelper.insertToggle(fido);
      progress = i/listaSeries.length;
    }
  }
  // chamar a função anterior
  preencherDados();*/

  NotificationService().initNotification();
  await Permission.notification.isDenied.then(
        (value){
      if(value){
        Permission.notification.request();
      }
    },
  );

 /* Future<String> getJsonFromRestAPI(String url_serie) async {
    String url = url_serie;
    http.Response response = await http.get(Uri.parse(url));
    return response.body;
  }

  Future loadDataIBGE() async {
    String jsonString = await getJsonFromRestAPI("https://servicodados.ibge.gov.br/api/v3/agregados/7063/metadados");
    final jsonResponse = json.decode(jsonString);
    for(var i = 0; i<jsonResponse['variaveis'].length; i++){
      listaMetrica.add(Metrica(id: jsonResponse['variaveis'][i]['id'], nome: jsonResponse['variaveis'][i]['nome']));
    }
    var urlSerie2 = jsonResponse['nivelTerritorial']['Administrativo'];
    urlSerie2 = urlSerie2.join("|");

    for(var i = 0; i<jsonResponse['classificacoes'][0]['categorias'].length; i++) {
      listaCategorias.add(Categorias(id: jsonResponse['classificacoes'][0]['categorias'][i]['id'],
          nome: jsonResponse['classificacoes'][0]['categorias'][i]['nome']));
    }

    String jsonString2 = await getJsonFromRestAPI("https://servicodados.ibge.gov.br/api/v3/agregados/7063/localidades/$urlSerie2");
    final jsonResponse2 = json.decode(jsonString2);
    // preencher a lista de nivel geografico
    for(var i = 0; i<jsonResponse2.length; i++){
      if(listaNivelGeografico.any((element) => element.id==jsonResponse2[i]['nivel']['id'])){
        continue;
      }
        listaNivelGeografico.add(NivelGeografico(id: jsonResponse2[i]['nivel']['id'], nome: jsonResponse2[i]['nivel']['nome']));
    }
    // preencher a lista de localidades
    for(var i = 0; i<jsonResponse2.length; i++){
      listaLocalidades.add(Localidades(id: int.parse(jsonResponse2[i]['id']), nome: jsonResponse2[i]['nome'], nivelGeografico: jsonResponse2[i]['nivel']['id']));
    }

    print(jsonResponse['variaveis'].firstWhere((e) => e['nome']=="INPC - Peso mensal")['id']);

  }




  loadDataIBGE();
  */

  isNotificationGranted = await Permission.notification.isGranted;


  runApp(MaterialApp(
    //home: Home(),
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}



