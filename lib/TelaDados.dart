import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:dados_economicos/variables_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
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
import 'dart:collection';
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
var alturaCategoria;
var valorItemHeightCategoria;
var alturaSerie;
var valorItemHeightSerie;
var periodicidade;
var alturaMetrica;
var valorItemHeightMetrica;
var formatoData;
var formatoDataGrafico;
var f = NumberFormat('#,##0.00', 'pt_BR');
var listaAnosSerieAnual = [];
var anoInicialSelecionado;
var anoFinalSelecionado;
var dtInicial;
DateTime startval1 = DateFormat(formatoData).parse('01/2021');
DateTime endval1 = DateFormat(formatoData).parse('12/2021');

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
    await prefs.setString("metricaArmaz", dropdownValueMetrica);
    await prefs.setString("localidadeArmaz", dropdownValueLocalidade);
    await prefs.setString("categoriaArmaz", dropdownValueCategoria);
    //String url = "https://api.bcb.gov.br/dados/serie/bcdata.sgs.433/dados?formato=json";
    String url = url_serie;
    http.Response response = await http.get(Uri.parse(url));
    return response.body;
  }

  List<serie_app> chartData = [];

  // essas datas para startval1 e endval1 sao apenas para iniciar as variaveis
  void atribuirValorDataInicial(){
    if(formatoData == 'dd/MM/yyyy'){
      dtInicial = '01/01/2021';
    } else {
      dtInicial = '01/2021';
    }
    startval1 = DateFormat(formatoData).parse(dtInicial);
    endval1 = DateFormat(formatoData).parse(dtInicial);
  }

  TextEditingController dateInputEnd = TextEditingController();
  TextEditingController dateInputIni = TextEditingController();

  Future loadDataSGS() async {
    String jsonString = await getJsonFromRestAPI(urlSerie);
    final jsonResponse = json.decode(jsonString);
    setState(() {
      for (Map<String, dynamic> i in jsonResponse){
        if(i['valor']!=""){
          chartData.add(serie_app.fromJson(i));
        }
      }
      endval1 = chartData.last.data;
      startval1 = chartData[chartData.length-13].data;
      chartData.sort((a, b){ //sorting in descending order
        return a.data.compareTo(b.data);
      });
      dataInicialSerie = DateFormat(formatoData).format(chartData.first.data).toString();
      dataFinalSerie = DateFormat(formatoData).format(chartData.last.data).toString();
      listaAnosSerieAnual = chartData.map((e) => e.data.toString().substring(0,4)).toSet().toList();
      anoInicialSelecionado = listaAnosSerieAnual.length-13;
      anoFinalSelecionado = listaAnosSerieAnual.length-1;
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
        var w = formatter1.format(int.parse(x.substring(4)));
        if(periodicidade=="trimestral") {
          if(w=="01"){
            w = "03";
          } else if(w=="02"){
            w = "06";
          } else if(w=="03"){
            w = "09";
          } else {
            w = "12";
          }
        }
        //x = formatter1.format(int.parse(x.substring(4))) + "/" + formatter2.format(int.parse(x.substring(0, 4)));
        x = w + "/" + formatter2.format(int.parse(x.substring(0, 4)));
        var y = item.values.toList()[i].toString();
        var periodicSerie;
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
      dataInicialSerie = DateFormat(formatoData).format(chartData.first.data).toString();
      dataFinalSerie = DateFormat(formatoData).format(chartData.last.data).toString();
      ultimaDataIPCA = chartData.last.data;
      listaAnosSerieAnual = chartData.map((e) => e.data.toString().substring(0,4)).toSet().toList();
      anoInicialSelecionado = listaAnosSerieAnual.length-13;
      anoFinalSelecionado = listaAnosSerieAnual.length-1;
    });
    endval1 = chartData.last.data;
    startval1 = chartData[chartData.length-13].data;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dataFinal', endval1.toString());
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
    initialIndex = valorToggle?.firstWhereOrNull((element) => element.id==cod_serie);
/*    if(initialIndex==null){
      return initialIndex;
    } else {
      return Text("Erro");
    }*/
    if(initialIndex==null){
      preencherDados(cod_serie);
      initialIndex = 0;
    } else {
      initialIndex = initialIndex.valorToggle;
    }
  }

/*  void atualizarAnoInicial() async {
      //listaAnosSerieAnual = await chartData.map((e) => e.data.toString().substring(0,4)).toSet().toList();
    listaAnosSerieAnual = [2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014];
      anoInicialSelecionado = await listaAnosSerieAnual.length-13;
  }*/

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    codAssunto = listaAssunto.firstWhere((element) => element.nome==widget.assuntoSerie).id;

    listaEscolhida = listaSeries.where((element) => element.idAssunto==codAssunto).toList();

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

    periodicidade = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
        element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
        element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).periodicidade;

    if(periodicidade=="anual"){
      formatoData = "yyyy";
      formatoDataGrafico = "yyyy";
    } else if(periodicidade=="diária"){
      formatoData = "dd/MM/yyyy";
      formatoDataGrafico = "dd/MM/yy";
    } else {
      formatoData = "MM/yyyy";
      formatoDataGrafico = "MM/yy";
    }

    chartData.clear();
    if(fonte=="Banco Central do Brasil"){
      loadDataSGS();
    } else {
      loadDataIBGE();
    }
  }


  void _showDialog(Widget child) async {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }


  void preencherDados(int numero_serie) async {
      var fido = Toggle_reg(id: numero_serie, valorToggle: 0, dataCompara: '');
      await DatabaseHelper.insertToggle(fido);
  }

  Widget metodoSelecaoInicial(String periodicidadeSerie){
    if(listaAnosSerieAnual.isNotEmpty){
      if (periodicidadeSerie == "mensal" || periodicidadeSerie == "trimestral") {
        return Column(
          children: [
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
                    firstDate: DateFormat(formatoData).parse(dataInicialSerie),
                    lastDate: DateFormat(formatoData).parse(dataFinalSerie));
                if (pickedDate != null) {
                  String formattedDate =
                  DateFormat(formatoData).format(pickedDate);
                  setState(() {
                    dateInputIni.text = formattedDate;
                    startval1 = DateFormat(formatoData).parse(formattedDate);
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
                    firstDate: DateFormat(formatoData).parse(dataInicialSerie),
                    lastDate: DateFormat(formatoData).parse(dataFinalSerie));
                if (pickedDate != null) {
                  String formattedDate =
                  DateFormat(formatoData).format(pickedDate);
                  setState(() {
                    dateInputEnd.text = formattedDate;
                    endval1 = DateFormat(formatoData).parse(formattedDate);
                  });
                } else {}
              },
            ),
          ],
        );
      } else if (periodicidadeSerie == "diária") {
          return Column(
            children: [
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
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: startval1,
                      firstDate: DateFormat(formatoData).parse(dataInicialSerie),
                      lastDate: DateFormat(formatoData).parse(dataFinalSerie));
                  if (pickedDate != null) {
                    String formattedDate =
                    DateFormat(formatoData).format(pickedDate);
                    setState(() {
                      dateInputIni.text = formattedDate;
                      startval1 = DateFormat(formatoData).parse(formattedDate);
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
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: endval1,
                      firstDate: DateFormat(formatoData).parse(dataInicialSerie),
                      lastDate: DateFormat(formatoData).parse(dataFinalSerie));
                  if (pickedDate != null) {
                    String formattedDate =
                    DateFormat(formatoData).format(pickedDate);
                    setState(() {
                      dateInputEnd.text = formattedDate;
                      endval1 = DateFormat(formatoData).parse(formattedDate);
                    });
                  } else {}
                },
              ),
            ],
          );
      } else {
        return Column(
          children: <Widget>[
            Text("Data inicial:"),
            CupertinoButton(
              padding: EdgeInsets.zero,
              // Display a CupertinoPicker with list of fruits.
              onPressed: () async => _showDialog(await
              CupertinoPicker(
                magnification: 1.22,
                squeeze: 1.2,
                useMagnifier: true,
                itemExtent: 32,
                // This sets the initial item.
                scrollController: FixedExtentScrollController(
                  initialItem: anoInicialSelecionado,
                ),
                // This is called when selected item is changed.
                onSelectedItemChanged: (int selectedItem) {
                  String formattedDate = DateFormat("MM/yyyy").parse("01/"+listaAnosSerieAnual[(selectedItem)]).toString();
                  setState(() {
                    anoInicialSelecionado = selectedItem;
                    dateInputIni.text = formattedDate;
                    //startval1 = DateFormat("MM/yyyy").parse(formattedDate);
                    startval1 = DateFormat("yyyy-MM-dd").parse(formattedDate);
                  });
                },
                children:
                List<Widget>.generate(listaAnosSerieAnual.length, (int index) {
                  return Center(child: Text(listaAnosSerieAnual[index]));
                }),
              ),
              ),
              // This displays the selected fruit name.
              child: Text(
                listaAnosSerieAnual[anoInicialSelecionado],
                style: const TextStyle(
                    fontSize: 18.0, color: Colors.black, decoration: TextDecoration.underline
                ),
              ),
            ),
            Text("Data final:"),
            CupertinoButton(
              padding: EdgeInsets.zero,
              // Display a CupertinoPicker with list of fruits.
              onPressed: () async => _showDialog(await
              CupertinoPicker(
                magnification: 1.22,
                squeeze: 1.2,
                useMagnifier: true,
                itemExtent: 32,
                // This sets the initial item.
                scrollController: FixedExtentScrollController(
                  initialItem: anoFinalSelecionado,
                ),
                // This is called when selected item is changed.
                onSelectedItemChanged: (int selectedItem) {
                  String formattedDate = DateFormat("MM/yyyy").parse("01/"+listaAnosSerieAnual[(selectedItem)]).toString();
                  setState(() {
                    anoFinalSelecionado = selectedItem;
                    dateInputEnd.text = formattedDate;
                    //startval1 = DateFormat("MM/yyyy").parse(formattedDate);
                    endval1 = DateFormat("yyyy-MM-dd").parse(formattedDate);
                  });
                },
                children:
                List<Widget>.generate(listaAnosSerieAnual.length, (int index) {
                  return Center(child: Text(listaAnosSerieAnual[index]));
                }),
              ),
              ),
              // This displays the selected fruit name.
              child: Text(
                listaAnosSerieAnual[anoFinalSelecionado],
                style: const TextStyle(
                    fontSize: 18.0, color: Colors.black, decoration: TextDecoration.underline
                ),
              ),
            ),
          ],
        );
      }
    } else {
      return CircularProgressIndicator();
    }
  }


  @override
  Widget build(BuildContext context) {
    filtrarDados(){
      dateInputIni.text = DateFormat(formatoData).format(startval1).toString();
      dateInputEnd.text = DateFormat(formatoData).format(endval1).toString();
      DateTime dataIni = DateFormat(formatoData).parse(dateInputIni.text.toString());
      DateTime dataFim = DateFormat(formatoData).parse(dateInputEnd.text.toString());
      late var lista_filtrada = itemsBetweenDates(lista: chartData, start: dataIni, end: dataFim);
      lista_filtrada.sort((a, b){ //sorting in descending order
        return a.data.compareTo(b.data);
      });
      return lista_filtrada;
    }

    Size _textSize(String text, TextStyle style) {
      final TextPainter textPainter = TextPainter(
          text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
        ..layout(minWidth: 0, maxWidth: double.infinity);
      return textPainter.size;
    }

    if(_textSize(dropdownValueCategoria, TextStyle(fontWeight: FontWeight.normal, fontSize: 15)).width<=300){
      alturaCategoria = 40.0;
    } else if(_textSize(dropdownValueCategoria, TextStyle(fontWeight: FontWeight.normal, fontSize: 15)).width>300&&
        _textSize(dropdownValueCategoria, TextStyle(fontWeight: FontWeight.normal, fontSize: 15)).width<=525){
      alturaCategoria = 60.0;
    } else if(_textSize(dropdownValueCategoria, TextStyle(fontWeight: FontWeight.normal, fontSize: 15)).width>525&&
        _textSize(dropdownValueCategoria, TextStyle(fontWeight: FontWeight.normal, fontSize: 15)).width<=750){
      alturaCategoria = 80.0;
    } else {
      alturaCategoria = 100.0;
    }

    if(_textSize(dropdownValueCategoria, TextStyle(fontWeight: FontWeight.normal, fontSize: 15)).width>300) {
      valorItemHeightCategoria = 60.0;
    } else {
      valorItemHeightCategoria = 50.0;
    }

    if(_textSize(dropdownValue, TextStyle(fontWeight: FontWeight.normal, fontSize: 15)).width<=327){
      alturaSerie = 40.0;
    } else if(_textSize(dropdownValue, TextStyle(fontWeight: FontWeight.normal, fontSize: 15)).width>327&&
        _textSize(dropdownValue, TextStyle(fontWeight: FontWeight.normal, fontSize: 15)).width<=525){
      alturaSerie = 60.0;
    } else if(_textSize(dropdownValue, TextStyle(fontWeight: FontWeight.normal, fontSize: 15)).width>525&&
        _textSize(dropdownValue, TextStyle(fontWeight: FontWeight.normal, fontSize: 15)).width<=750){
      alturaSerie = 80.0;
    } else {
      alturaSerie = 100.0;
    }

    if(_textSize(dropdownValue, TextStyle(fontWeight: FontWeight.normal, fontSize: 15)).width>300) {
      valorItemHeightSerie = 60.0;
    } else {
      valorItemHeightSerie = 50.0;
    }

    if(_textSize(dropdownValueMetrica, TextStyle(fontWeight: FontWeight.normal, fontSize: 15)).width<=327){
      alturaMetrica = 40.0;
    } else if(_textSize(dropdownValueMetrica, TextStyle(fontWeight: FontWeight.normal, fontSize: 15)).width>327&&
        _textSize(dropdownValueMetrica, TextStyle(fontWeight: FontWeight.normal, fontSize: 15)).width<=525){
      alturaMetrica = 60.0;
    } else  {
      alturaMetrica = 80.0;
    }
    if(_textSize(dropdownValueMetrica, TextStyle(fontWeight: FontWeight.normal, fontSize: 15)).width>300) {
      valorItemHeightMetrica = 60.0;
    } else {
      valorItemHeightMetrica = 50.0;
    }

/*
    if((anoInicialSelecionado==null||anoInicialSelecionado<0)&&chartData.isNotEmpty){
      listaAnosSerieAnual = chartData.map((e) => e.data.toString().substring(0,4)).toSet().toList();
      anoInicialSelecionado = listaAnosSerieAnual.length-13;
    }

*/
    print("listaSeries: ${listaSeries.length}");


    return Scaffold(
        appBar: AppBar(
          title: Text("Visualize os dados", style: TextStyle(color: Colors.white) ),
          backgroundColor: Color.fromRGBO(63, 81, 181, 20),
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
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
                                height: alturaSerie,
                                width: 200,
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(63, 81, 181, 20),
                                    borderRadius: BorderRadius.circular(30), //border raiuds of dropdown button
                                    boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                      BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                                          blurRadius: 5) //blur radius of shadow
                                    ]
                                ),
                                child: Center(
                                  child: DropdownButton<String>(
                                    iconEnabledColor: Colors.white,
                                    itemHeight: valorItemHeightSerie,
                                    padding: EdgeInsets.all(10),
                                    isExpanded: true,
                                    value: dropdownValue,
                                    icon: const Icon(Icons.arrow_downward),
                                    elevation: 16,
                                    dropdownColor: Color.fromRGBO(63, 81, 181, 20),
                                    style: const TextStyle(color: Colors.white, fontSize: 15),
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

                                        //initialIndex = valorToggle?.firstWhere((element) => element.id==cod_serie).valorToggle;
                                        initialIndex = valorToggle!.firstWhereOrNull((element) => element.id==cod_serie);
                                        if(initialIndex==null){
                                          initialIndex = 0;
                                          preencherDados(cod_serie);
                                        } else {
                                          initialIndex = initialIndex.valorToggle;
                                        }
                                        nomeSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                            element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                            element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).nome;
                                        formatoSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                            element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                            element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).formato;
                                        periodicidade = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                            element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                            element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).periodicidade;
                                        if(periodicidade=="anual"){
                                          formatoData = "yyyy";
                                          formatoDataGrafico = "yyyy";
                                        } else if(periodicidade=="diária"){
                                          formatoData = "dd/MM/yyyy";
                                          formatoDataGrafico = "dd/MM/yy";
                                        } else {
                                          formatoData = "MM/yyyy";
                                          formatoDataGrafico = "MM/yy";
                                        }
                                        chartData.clear();
                                        if(fonte=="Banco Central do Brasil"){
                                          loadDataSGS();
                                        } else {
                                          loadDataIBGE();
                                        }
                                        //atualizarAnoInicial();
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
                            height: alturaMetrica,
                            width: 400,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(63, 81, 181, 20),
                                borderRadius: BorderRadius.circular(30), //border raiuds of dropdown button
                                boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                  BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                                      blurRadius: 5) //blur radius of shadow
                                ]
                            ),
                            child: Center(
                              child: DropdownButton<String>(
                                padding: EdgeInsets.all(10),
                                iconEnabledColor: Colors.white,
                                itemHeight: valorItemHeightMetrica,
                                isExpanded: true,
                                value: dropdownValueMetrica,
                                icon: const Icon(Icons.arrow_downward),
                                elevation: 16,
                                dropdownColor: Color.fromRGBO(63, 81, 181, 20),
                                style: const TextStyle(color: Colors.white, fontSize: 15),
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
                                            //initialIndex = valorToggle?.firstWhere((element) => element.id==cod_serie).valorToggle;
                                            initialIndex = valorToggle!.firstWhereOrNull((element) => element.id==cod_serie);
                                            if(initialIndex==null){
                                              initialIndex = 0;
                                              preencherDados(cod_serie);
                                            } else {
                                              initialIndex = initialIndex.valorToggle;
                                            }
                                            formatoSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).formato;
                                            periodicidade = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).periodicidade;
                                            if(periodicidade=="anual"){
                                              formatoData = "yyyy";
                                              formatoDataGrafico = "yyyy";
                                            } else if(periodicidade=="diária"){
                                              formatoData = "dd/MM/yyyy";
                                              formatoDataGrafico = "dd/MM/yy";
                                            } else {
                                              formatoData = "MM/yyyy";
                                              formatoDataGrafico = "MM/yy";
                                            }
                                            chartData.clear();
                                            if(fonte=="Banco Central do Brasil"){
                                              loadDataSGS();
                                            } else {
                                              loadDataIBGE();
                                            }
                                            //atualizarAnoInicial();
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
                              color: Color.fromRGBO(63, 81, 181, 20),
                              borderRadius: BorderRadius.circular(30), //border raiuds of dropdown button
                              boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                                    blurRadius: 5) //blur radius of shadow
                              ]
                          ),
                          child: Center(
                            child: DropdownButton<String>(
                              iconEnabledColor: Colors.white,
                              isExpanded: true,
                              value: dropdownValueNivelGeog,
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 16,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              focusColor: Colors.grey,
                              dropdownColor: Color.fromRGBO(63, 81, 181, 20),
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
                                            //initialIndex = valorToggle?.firstWhere((element) => element.id==cod_serie).valorToggle;
                                            initialIndex = valorToggle!.firstWhereOrNull((element) => element.id==cod_serie);
                                            if(initialIndex==null){
                                              initialIndex = 0;
                                              preencherDados(cod_serie);
                                            } else {
                                              initialIndex = initialIndex.valorToggle;
                                            }
                                            formatoSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).formato;
                                            periodicidade = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).periodicidade;
                                            if(periodicidade=="anual"){
                                              formatoData = "yyyy";
                                              formatoDataGrafico = "yyyy";
                                            } else if(periodicidade=="diária"){
                                              formatoData = "dd/MM/yyyy";
                                              formatoDataGrafico = "dd/MM/yy";
                                            } else {
                                              formatoData = "MM/yyyy";
                                              formatoDataGrafico = "MM/yy";
                                            }
                                            chartData.clear();
                                            if(fonte=="Banco Central do Brasil"){
                                              loadDataSGS();
                                            } else {
                                              loadDataIBGE();
                                            }
                                            //atualizarAnoInicial();
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
                              color: Color.fromRGBO(63, 81, 181, 20),
                              borderRadius: BorderRadius.circular(30), //border raiuds of dropdown button
                              boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                                    blurRadius: 5) //blur radius of shadow
                              ]
                          ),
                          child: Center(
                            child: DropdownButton<String>(
                              iconEnabledColor: Colors.white,
                              isExpanded: true,
                              value: dropdownValueLocalidade,
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 16,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              focusColor: Colors.grey,
                              dropdownColor: Color.fromRGBO(63, 81, 181, 20),
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
                                            //initialIndex = valorToggle?.firstWhere((element) => element.id==cod_serie).valorToggle;
                                            initialIndex = valorToggle!.firstWhereOrNull((element) => element.id==cod_serie);
                                            if(initialIndex==null){
                                              initialIndex = 0;
                                              preencherDados(cod_serie);
                                            } else {
                                              initialIndex = initialIndex.valorToggle;
                                            }
                                            formatoSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).formato;
                                            periodicidade = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                                element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                                element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).periodicidade;
                                            if(periodicidade=="anual"){
                                              formatoData = "yyyy";
                                              formatoDataGrafico = "yyyy";
                                            } else if(periodicidade=="diária"){
                                              formatoData = "dd/MM/yyyy";
                                              formatoDataGrafico = "dd/MM/yy";
                                            } else {
                                              formatoData = "MM/yyyy";
                                              formatoDataGrafico = "MM/yy";
                                            }
                                            chartData.clear();
                                            if(fonte=="Banco Central do Brasil"){
                                              loadDataSGS();
                                            } else {
                                              loadDataIBGE();
                                            }
                                            //atualizarAnoInicial();
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
                           height: alturaCategoria,
                            width: 400,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(63, 81, 181, 20),
                                borderRadius: BorderRadius.circular(30), //border raiuds of dropdown button
                                boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                                      blurRadius: 5) //blur radius of shadow
                                ]
                            ),
                            child: Center(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  iconEnabledColor: Colors.white,
                                  itemHeight: valorItemHeightCategoria,
                                  padding: EdgeInsets.all(10),
                                  //isDense: true,
                                  isExpanded: true,
                                  value: dropdownValueCategoria,
                                  icon: const Icon(Icons.arrow_downward),
                                  elevation: 16,
                                  style: const TextStyle(color: Colors.white, fontSize: 15),
                                  focusColor: Colors.grey,
                                  dropdownColor: Color.fromRGBO(63, 81, 181, 20),
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
                                      //initialIndex = valorToggle?.firstWhere((element) => element.id==cod_serie).valorToggle;
                                      initialIndex = valorToggle!.firstWhereOrNull((element) => element.id==cod_serie);
                                      if(initialIndex==null){
                                        initialIndex = 0;
                                        preencherDados(cod_serie);
                                      } else {
                                        initialIndex = initialIndex.valorToggle;
                                      }
                                      formatoSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                          element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                          element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).formato;
                                      periodicidade = listaEscolhida.firstWhere((element) => element.nome==dropdownValue &&
                                          element.metrica==dropdownValueMetrica && element.nivelGeografico==dropdownValueNivelGeog &&
                                          element.localidades==dropdownValueLocalidade && element.categoria==dropdownValueCategoria).periodicidade;
                                      // salvar as variaveis para serem mostradas no notificacao, caso o usuario escolha receber notificacao
                                      if(periodicidade=="anual"){
                                        formatoData = "yyyy";
                                        formatoDataGrafico = "yyyy";
                                      } else if(periodicidade=="diária"){
                                        formatoData = "dd/MM/yyyy";
                                        formatoDataGrafico = "dd/MM/yy";
                                      } else {
                                        formatoData = "MM/yyyy";
                                        formatoDataGrafico = "MM/yy";
                                      }
                                      chartData.clear();
                                      if(fonte=="Banco Central do Brasil"){
                                        loadDataSGS();
                                      } else {
                                        loadDataIBGE();
                                      }
                                      //atualizarAnoInicial();
                                    });
                                  },
                                  items: listaMostrarCategoria.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                        value: value,
                                        child: Center(
                                            child: Text(value),
                                        )
                                    );
                                  }).toList(),
                                ),
                              )
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
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      FutureBuilder(
                          future: toggleDatabase(),
                          builder: (ctx, snapshot) {
                            if(initialIndex!=null){
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
                      metodoSelecaoInicial(periodicidade),
                      /*TextField(
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
                              firstDate: DateFormat(formatoData).parse(dataInicialSerie),
                              lastDate: DateFormat(formatoData).parse(dataFinalSerie)
                          );
                          if (pickedDate != null) {
                            String formattedDate = DateFormat(formatoData).format(pickedDate);
                            setState(() {
                              dateInputIni.text = formattedDate;
                              startval1 = DateFormat(formatoData).parse(formattedDate);
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
                              firstDate: DateFormat(formatoData).parse(dataInicialSerie),
                              lastDate: DateFormat(formatoData).parse(dataFinalSerie)
                          );
                          if (pickedDate != null) {
                            String formattedDate = DateFormat(formatoData).format(pickedDate);
                            setState(() {
                              dateInputEnd.text = formattedDate;
                              endval1 = DateFormat(formatoData).parse(formattedDate);
                            });
                          } else {}
                        },
                      ),*/
                      //metodoSelecaoFinal(periodicidade),
                      Padding(
                        padding: EdgeInsets.only(top: 20, bottom: 10),
                        child: Text(
                          "Gráfico: $nomeSerie - $dropdownValueLocalidade - $dropdownValueCategoria - $formatoSerie",
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
                                text = DateFormat(formatoDataGrafico).format(DateTime.parse(args.text)).toString();
                                return ChartAxisLabel(text, args.textStyle);
                              },
                            ),
                            primaryYAxis: NumericAxis(
                              //Formatting the labels in locale’s currency pattern with symbol.
                                numberFormat: NumberFormat.decimalPattern('pt_BR'),
                            ),
                            series: <ChartSeries<serie_app, String>>[
                              // Renders line chart
                              LineSeries<serie_app, String>(
                                  dataSource: filtrarDados(),
                                  xValueMapper: (serie_app variavel, _) => variavel.data.toString(),
                                  yValueMapper: (serie_app variavel, _) => variavel.valor,
                                  dataLabelMapper: (serie_app data, _) => f.format(data.valor),
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
                                  DateFormat(formatoData).format(e.data).toString(),
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  //e.valor.toStringAsFixed(2).replaceAll('.', ','),
                                  f.format(e.valor),
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
