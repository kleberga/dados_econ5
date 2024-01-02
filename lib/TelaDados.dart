import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:ui';
import 'package:dados_economicos/variables_class.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'back_services.dart';
import 'database_helper.dart';
import 'package:permission_handler/permission_handler.dart';

import 'descricao_series.dart';


//const Map mapPrecos = {"433": "IPCA - % mensal","188": "INPC - % mensal"};
//late Map mapEscolhido = {};
late List listaEscolhida = [];
String dropdownValue = "";
String dropdownValueMetrica = "";
String dropdownValueNivelGeog = "";
String dropdownValueLocalidade = "";
String dropdownValueCategoria = "";
String urlSerie = '';
var service;
var ultimaDataIPCA;
String? meuNumeroTeste;
List<String> listaMostrar = [];
List<String> listaMostrarMetrica = [];
List<String> listaMostrarNivelGeog = [];
List<String> listaMostrarLocalidade = [];
List<String> listaMostrarCategoria = [];
var fonte;
var cod_serie;
var initialIndex;
List<Toggle_reg>? valorToggle;
var isNotificationGranted;
var nomeSerie;
var formatoSerie;
var codAssunto;
var dataInicialSerie;
var dataFinalSerie;
var metricaValue;

class TelaDados extends StatefulWidget {
  final String assuntoSerie;
  TelaDados({required this.assuntoSerie});
  @override
  State<TelaDados> createState() => _TelaDados();
}

Future<String> getStringFromLocalStorage(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key) ?? '';
}



class _TelaDados extends State<TelaDados> {

  Future<String> getJsonFromRestAPI(String url_serie) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('urlSerieArmaz', urlSerie);
    await prefs.setString('fonteSerieArmaz', fonte);
    await prefs.setInt("codigoArmaz", cod_serie);
    //String url = "https://api.bcb.gov.br/dados/serie/bcdata.sgs.433/dados?formato=json";
    String url = url_serie;
    http.Response response = await http.get(Uri.parse(url));
    return response.body;
  }

  List<serie_app> chartData = [];

  DateTime startval1 = DateFormat('MM/yyyy').parse('01/2021');
  DateTime endval1 = DateFormat('MM/yyyy').parse('12/2021');

  TextEditingController dateInputEnd = TextEditingController();
  TextEditingController dateInputIni = TextEditingController();

  Future loadDataSGS() async {
    String jsonString = await getJsonFromRestAPI(urlSerie);
    final jsonResponse = json.decode(jsonString);
    setState(() {
      for (Map<String, dynamic> i in jsonResponse){
        chartData.add(serie_app.fromJson(i));
      }
      endval1 = chartData.last.data;
      startval1 = chartData[chartData.length-13].data;
      chartData.sort((a, b){ //sorting in descending order
        return a.data.compareTo(b.data);
      });
      dataInicialSerie = DateFormat('MM/yyyy').format(chartData.first.data).toString();
      dataFinalSerie = DateFormat('MM/yyyy').format(chartData.last.data).toString();
    });
    ultimaDataIPCA = chartData.last.data;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dataFinal', endval1.toString());
  }

  NumberFormat formatter1 = new NumberFormat("00");
  NumberFormat formatter2 = new NumberFormat("0000");

  Future loadDataIBGE() async {
    String jsonString = await getJsonFromRestAPI(urlSerie);
    final jsonResponse = json.decode(jsonString);
    final item = jsonResponse[0]['resultados'][0]['series'][0]['serie'];
    setState(() {
      for (var i = 0; i<item.keys.toList().length; i++){
        var x = item.keys.toList()[i];
        x = formatter1.format(int.parse(x.substring(4))) + "/" + formatter2.format(int.parse(x.substring(0, 4)));
        var y = item.values.toList()[i].toString();
        if(y!="..."&&y!="-"){
          chartData.add(
              serie_app(
                  DateFormat('MM/yyyy').parse(x),
                  double.parse(y)
              )
          );
        }
      }
      chartData.sort((a, b){ //sorting in descending order
        return a.data.compareTo(b.data);
      });
      dataInicialSerie = DateFormat('MM/yyyy').format(chartData.first.data).toString();
      dataFinalSerie = DateFormat('MM/yyyy').format(chartData.last.data).toString();
    });
    endval1 = chartData.last.data;
    startval1 = chartData[chartData.length-13].data;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dataFinal', endval1.toString());
    ultimaDataIPCA = chartData.last.data;
  }


  List<serie_app> itemsBetweenDates({
    required List<serie_app> lista,
    required DateTime start,
    required DateTime end,
  }) {
    var output = <serie_app>[];
    for (var i = 0; i < lista.length; i += 1) {
      DateTime date = lista[i].data;
      if (date.compareTo(start) >= 0 && date.compareTo(end) <= 0) {
        output.add(lista[i]);
      }
    }
    return output;
  }


  Future toggleDatabase() async {
    valorToggle = await DatabaseHelper.getAllToggle();
    initialIndex = valorToggle?.firstWhere((element) => element.id==cod_serie).valorToggle;
    if(initialIndex!=null){
      return initialIndex;
    } else {
      return Text("Erro");
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
/*    if(widget.assuntoSerie=="Índice de preços"){
      listaEscolhida = listaSeries;
    }*/
    // filtrar o codigo do assunto
    codAssunto = listaAssunto.firstWhere((element) => element.nome==widget.assuntoSerie).id;
    // escolher as series que pertencem ao assunto escolhido
    listaEscolhida = listaSeries.where((element) => element.idAssunto==codAssunto).toList();
    // limpar a lista para evitar duplicidade quando a tela for recarregada
    // criar a lista
/*    for(var i = 0; i<listaEscolhida.length; i++) {
      if(listaEscolhida.any((element) => element==listaEscolhida[i].nome)){
        continue;
      }
      listaMostrar.add(listaEscolhida[i].nome);
    }*/


    listaMostrar = listaEscolhida.map((element) => element.nome.toString()).toList().toSet().toList();
    dropdownValue = listaMostrar.first;

    listaMostrarMetrica = listaEscolhida.where((element) => element.nome==dropdownValue).map((e) => e.metrica.toString()).toSet().toList();
    dropdownValueMetrica = listaMostrarMetrica.first;

    listaMostrarNivelGeog = listaEscolhida.where((element) => element.nome==dropdownValue &&
    element.metrica==dropdownValueMetrica).map((e) => e.nivelGeografico.toString()).toSet().toList();
    dropdownValueNivelGeog = listaMostrarNivelGeog.first;

    listaMostrarLocalidade = listaEscolhida.where((element) => element.nome==dropdownValue &&
        element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog).map((e) => e.localidades.toString()).toSet().toList();
    dropdownValueLocalidade = listaMostrarLocalidade.first;

    listaMostrarCategoria = listaEscolhida.where((element) => element.nome==dropdownValue &&
        element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
    element.localidades==dropdownValueLocalidade).map((e) => e.categoria.toString()).toSet().toList();
    dropdownValueCategoria = listaMostrarCategoria.first;

    urlSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
        element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
        element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).urlAPI;

    fonte = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
        element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
        element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).fonte;

    cod_serie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
        element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
        element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).numero;

    nomeSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
        element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
        element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).nome;

    formatoSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
        element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
        element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).formato;

    chartData.clear();
    if(fonte=="Banco Central do Brasil"){
      loadDataSGS();
    } else {
      loadDataIBGE();
    }
  }

  @override
  Widget build(BuildContext context) {

    filtrarDados(){
      dateInputIni.text = DateFormat('MM/yyyy').format(startval1).toString();
      dateInputEnd.text = DateFormat('MM/yyyy').format(endval1).toString();
      DateTime dataIni = DateFormat('MM/yyyy').parse(dateInputIni.text.toString());
      DateTime dataFim = DateFormat('MM/yyyy').parse(dateInputEnd.text.toString());
      late var lista_filtrada = itemsBetweenDates(lista: chartData, start: dataIni, end: dataFim);
      lista_filtrada.sort((a, b){ //sorting in descending order
        return a.data.compareTo(b.data);
      });
      return lista_filtrada;
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Visualize os dados"),
          backgroundColor: Colors.blue[100],
        ),
        body: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Selecione a série:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 5)),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                                height: 40,
                                width: 200,
                                decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(30), //border raiuds of dropdown button
                                    boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                      BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                                          blurRadius: 5) //blur radius of shadow
                                    ]
                                ),
                                child: Center(
                                  child: DropdownButton<String>(
                                    value: dropdownValue,
                                    icon: const Icon(Icons.arrow_downward),
                                    elevation: 16,
                                    style: const TextStyle(color: Colors.deepPurple, fontSize: 15),
                                    focusColor: Colors.grey,
                                    underline: Container(
                                      height: 0,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    onChanged: (String? value) {
                                      // This is called when the user selects an item.
                                      setState(() {
                                        dropdownValue = value!;
                                        listaMostrarMetrica = listaEscolhida.where((element) => element.nome==dropdownValue).map((e) => e.metrica.toString()).toSet().toList();
                                        dropdownValueMetrica = listaMostrarMetrica.first;
                                        listaMostrarNivelGeog = listaEscolhida.where((element) => element.nome==dropdownValue &&
                                            element.metrica==dropdownValueMetrica).map((e) => e.nivelGeografico.toString()).toSet().toList();
                                        dropdownValueNivelGeog = listaMostrarNivelGeog.first;
                                        listaMostrarLocalidade = listaEscolhida.where((element) => element.nome==dropdownValue &&
                                            element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog).map((e) => e.localidades.toString()).toSet().toList();
                                        dropdownValueLocalidade = listaMostrarLocalidade.first;
                                        listaMostrarCategoria = listaEscolhida.where((element) => element.nome==dropdownValue &&
                                            element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                            element.localidades==dropdownValueLocalidade).map((e) => e.categoria.toString()).toSet().toList();
                                        dropdownValueCategoria = listaMostrarCategoria.first;
                                        urlSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                            element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                            element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).urlAPI;
                                        fonte = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                            element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                            element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).fonte;
                                        cod_serie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                            element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                            element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).numero;
                                        initialIndex = valorToggle?.firstWhere((element) => element.id==cod_serie).valorToggle;
                                        nomeSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                            element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                            element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).nome;
                                        formatoSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                            element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                            element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).formato;
                                        chartData.clear();
                                        if(fonte=="Banco Central do Brasil"){
                                          loadDataSGS();
                                        } else {
                                          loadDataIBGE();
                                        }
                                      });
                                    },
                                    items: listaMostrar.map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Center(
                                          child: Text(value),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      Text(
                        "Selecione a métrica:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 5)),
                      Container(
                            height: 40,
                            width: 400,
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(30), //border raiuds of dropdown button
                                boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                  BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                                      blurRadius: 5) //blur radius of shadow
                                ]
                            ),
                            child: Center(
                              child: DropdownButton<String>(
                                value: dropdownValueMetrica,
                                icon: const Icon(Icons.arrow_downward),
                                elevation: 16,
                                style: const TextStyle(color: Colors.deepPurple, fontSize: 15),
                                focusColor: Colors.grey,
                                underline: Container(
                                  height: 0,
                                  color: Colors.deepPurpleAccent,
                                ),
                                onChanged: (String? value) {
                                  // This is called when the user selects an item.
                                          setState(() {
                                            dropdownValueMetrica = value!;
                                            listaMostrarNivelGeog = listaEscolhida.where((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica).map((e) => e.nivelGeografico.toString()).toSet().toList();
                                            dropdownValueNivelGeog = listaMostrarNivelGeog.first;
                                            listaMostrarLocalidade = listaEscolhida.where((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog).map((e) => e.localidades.toString()).toSet().toList();
                                            dropdownValueLocalidade = listaMostrarLocalidade.first;
                                            listaMostrarCategoria = listaEscolhida.where((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade).map((e) => e.categoria.toString()).toSet().toList();
                                            dropdownValueCategoria = listaMostrarCategoria.first;
                                            urlSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).urlAPI;
                                            fonte = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).fonte;
                                            cod_serie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).numero;
                                            initialIndex = valorToggle?.firstWhere((element) => element.id==cod_serie).valorToggle;
                                            nomeSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).nome;
                                            formatoSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).formato;
                                            chartData.clear();
                                            if(fonte=="Banco Central do Brasil"){
                                              loadDataSGS();
                                            } else {
                                              loadDataIBGE();
                                            }
                                          });
                                },
                                items: listaMostrarMetrica.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Center(
                                      child: Text(value),
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                        ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      Text(
                        "Selecione o nível geográfico:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 5)),
                      Container(
                          height: 40,
                          width: 400,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(30), //border raiuds of dropdown button
                              boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                                    blurRadius: 5) //blur radius of shadow
                              ]
                          ),
                          child: Center(
                            child: DropdownButton<String>(
                              value: dropdownValueNivelGeog,
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 16,
                              style: const TextStyle(color: Colors.deepPurple, fontSize: 15),
                              focusColor: Colors.grey,
                              underline: Container(
                                height: 0,
                                color: Colors.deepPurpleAccent,
                              ),
                              onChanged: (String? value) {
                                // This is called when the user selects an item.
                                          setState(() {
                                            dropdownValueNivelGeog = value!;
                                            listaMostrarLocalidade = listaEscolhida.where((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog).map((e) => e.localidades.toString()).toSet().toList();
                                            dropdownValueLocalidade = listaMostrarLocalidade.first;
                                            listaMostrarCategoria = listaEscolhida.where((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade).map((e) => e.categoria.toString()).toSet().toList();
                                            dropdownValueCategoria = listaMostrarCategoria.first;
                                            urlSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).urlAPI;
                                            fonte = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).fonte;
                                            cod_serie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).numero;
                                            initialIndex = valorToggle?.firstWhere((element) => element.id==cod_serie).valorToggle;
                                            nomeSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).nome;
                                            formatoSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).formato;
                                            chartData.clear();
                                            if(fonte=="Banco Central do Brasil"){
                                              loadDataSGS();
                                            } else {
                                              loadDataIBGE();
                                            }
                                          });
                              },
                              items: listaMostrarNivelGeog.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Center(
                                    child: Text(value),
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      Text(
                        "Selecione a localidade:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 5)),
                      Container(
                          height: 40,
                          width: 400,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(30), //border raiuds of dropdown button
                              boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                                    blurRadius: 5) //blur radius of shadow
                              ]
                          ),
                          child: Center(
                            child: DropdownButton<String>(
                              value: dropdownValueLocalidade,
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 16,
                              style: const TextStyle(color: Colors.deepPurple, fontSize: 15),
                              focusColor: Colors.grey,
                              underline: Container(
                                height: 0,
                                color: Colors.deepPurpleAccent,
                              ),
                              onChanged: (String? value) {
                                // This is called when the user selects an item.
                                          setState(() {
                                            dropdownValueLocalidade = value!;
                                            listaMostrarCategoria = listaEscolhida.where((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade).map((e) => e.categoria.toString()).toSet().toList();
                                            dropdownValueCategoria = listaMostrarCategoria.first;
                                            urlSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).urlAPI;
                                            fonte = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).fonte;
                                            cod_serie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).numero;
                                            initialIndex = valorToggle?.firstWhere((element) => element.id==cod_serie).valorToggle;
                                            nomeSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).nome;
                                            formatoSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).formato;
                                            chartData.clear();
                                            if(fonte=="Banco Central do Brasil"){
                                              loadDataSGS();
                                            } else {
                                              loadDataIBGE();
                                            }
                                          });
                              },
                              items: listaMostrarLocalidade.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Center(
                                    child: Text(value),
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      Text(
                        "Selecione o grupo:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 5)),
                      Container(
                          height: 40,
                          width: 400,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(30), //border raiuds of dropdown button
                              boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                                    blurRadius: 5) //blur radius of shadow
                              ]
                          ),
                          child: Center(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: dropdownValueCategoria,
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 16,
                              style: const TextStyle(color: Colors.deepPurple, fontSize: 15),
                              focusColor: Colors.grey,
                              underline: Container(
                                height: 0,
                                color: Colors.deepPurpleAccent,
                              ),
                              onChanged: (String? value) {
                                // This is called when the user selects an item.
                                          setState(() {
                                            dropdownValueCategoria = value!;
                                            urlSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).urlAPI;
                                            fonte = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).fonte;
                                            cod_serie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).numero;
                                            initialIndex = valorToggle?.firstWhere((element) => element.id==cod_serie).valorToggle;
                                            nomeSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).nome;
                                            formatoSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).formato;
                                            chartData.clear();
                                            if(fonte=="Banco Central do Brasil"){
                                              loadDataSGS();
                                            } else {
                                              loadDataIBGE();
                                            }
                                          });
                              },
                              items: listaMostrarCategoria.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Center(
                                    child: Center(
                                      child: Text(value.toLowerCase()),
                                    ),
                                  )
                                );
                              }).toList(),
                            ),
                          )
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 32, right: 32, top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Deseja receber notificação quando esta série receber novos valores?",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      FutureBuilder(
                          future: toggleDatabase(),
                          builder: (ctx, snapshot) {
                            if(snapshot.hasData){
                              return ToggleSwitch(
                                //initialLabelIndex: initialIndex,
                                borderColor: <Color>[Colors.grey],
                                borderWidth: 1,
                                activeBgColor: <Color>[Colors.green.shade500],
                                inactiveBgColor: Colors.white,
                                initialLabelIndex: initialIndex,
                                totalSwitches: 2,
                                labels: [
                                  'Não',
                                  'Sim',
                                ],
                                onToggle: (index) async {
                                  if(isNotificationGranted==false){
                                    //_dialogBuilder(ctx);
                                    await Permission.notification.isDenied.then(
                                          (value){
                                        if(value){
                                          Permission.notification.request();
                                        }
                                      },
                                    );
                                  }
                                  var novoToggle = Toggle_reg(id: cod_serie, valorToggle: index, dataCompara: ultimaDataIPCA.toString());
                                  void atualizarToggle() async {
                                    await DatabaseHelper.updateToggle(novoToggle);
                                  }
                                  setState(() {
                                    initialIndex = index!;
                                    atualizarToggle();
                                  });
                                  print("valorToggle: $valorToggle");
                                  final service1 = FlutterBackgroundService();
                                  service1.invoke("stopService");
                                  await initializeService1();
                                  service1.startService();
                                },
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          }
                      ),
                      Padding(padding: EdgeInsets.all(10)),
                      Text(
                        "Selecione o intervalo:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: dateInputIni,
                        //editing controller of this TextField
                        decoration: InputDecoration(
                            icon: Icon(Icons.calendar_today), //icon of text field
                            labelText: "Data Inicial:" //label text of field
                        ),
                        readOnly: true,
                        //set it true, so that user will not able to edit text
                        onTap: () async {
                          DateTime? pickedDate = await showMonthPicker(
                              context: context,
                              initialDate: startval1,
                              firstDate: DateFormat('MM/yyyy').parse(dataInicialSerie),
                              lastDate: DateFormat('MM/yyyy').parse(dataFinalSerie)
                          );
                          if (pickedDate != null) {
                            String formattedDate = DateFormat('MM/yyyy').format(pickedDate);
                            setState(() {
                              dateInputIni.text = formattedDate;
                              startval1 = DateFormat('MM/yyyy').parse(formattedDate);
                            });
                          } else {}
                        },
                      ),
                      TextField(
                        controller: dateInputEnd,
                        //editing controller of this TextField
                        decoration: InputDecoration(
                            icon: Icon(Icons.calendar_today), //icon of text field
                            labelText: "Data Final:" //label text of field
                        ),
                        readOnly: true,
                        //set it true, so that user will not able to edit text
                        onTap: () async {
                          DateTime? pickedDate = await showMonthPicker(
                              context: context,
                              initialDate: endval1,
                              firstDate: DateFormat('MM/yyyy').parse(dataInicialSerie),
                              lastDate: DateFormat('MM/yyyy').parse(dataFinalSerie)
                          );
                          if (pickedDate != null) {
                            String formattedDate = DateFormat('MM/yyyy').format(pickedDate);
                            setState(() {
                              dateInputEnd.text = formattedDate;
                              //endval1 = DateFormat('dd/MM/yyyy').parse(formattedDate);
                              endval1 = DateFormat('MM/yyyy').parse(formattedDate);
                            });
                          } else {}
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 10),
                        child: Text(
                          "Gráfico: $nomeSerie - $dropdownValueLocalidade - ${dropdownValueCategoria.toLowerCase()} - $formatoSerie",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Stack(
                        children: <Widget>[
                          Center(child:
                          SfCartesianChart(
                            margin: EdgeInsets.only(left: 5),
                            primaryXAxis: CategoryAxis(
                              axisLabelFormatter: (AxisLabelRenderDetails args) {
                                late String text;
                                text = DateFormat('MM/yy').format(DateTime.parse(args.text)).toString();
                                return ChartAxisLabel(text, args.textStyle);
                              },
                            ),
                            series: <ChartSeries<serie_app, String>>[
                              // Renders line chart
                              LineSeries<serie_app, String>(
                                  dataSource: filtrarDados(),
                                  xValueMapper: (serie_app variavel, _) => variavel.data.toString(),
                                  yValueMapper: (serie_app variavel, _) => variavel.valor,
                                  dataLabelMapper: (serie_app data, _) => data.valor.toStringAsFixed(2).replaceAll(".", ","),
                                  dataLabelSettings: DataLabelSettings(isVisible: true,
                                      textStyle: TextStyle(fontSize: 11)),
                                  markerSettings: MarkerSettings(isVisible: true)
                              ),
                            ]
                          ),
                          ),
                          Container(height: 250,
                            alignment: AlignmentDirectional.bottomCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                FutureBuilder(
                                    future: getJsonFromRestAPI(urlSerie),
                                    builder: (ctx, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done) {
                                        return Text(
                                            ''
                                        );
                                      } else
                                        return CircularProgressIndicator();
                                    }
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Text(
                          "Fonte: $fonte",
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      OutlinedButton(
                          onPressed: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DescricaoSeries(cod_series: cod_serie,))
                            );
                          },
                            child: Text("Descrição da série")
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          "Dados do gráfico",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataTable(
                        columnSpacing: 50,
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text(
                              'Data',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Valor',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                        rows: filtrarDados()
                            .map(
                              (e) => DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  DateFormat('MM/yyyy').format(e.data).toString(),
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  e.valor.toStringAsFixed(2).replaceAll('.', ','),
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            )
        )
    );
  }
}
