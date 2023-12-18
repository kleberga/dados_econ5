import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
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
import 'package:loading_animation_widget/loading_animation_widget.dart';

//const Map mapPrecos = {"433": "IPCA - % mensal","188": "INPC - % mensal"};
//late Map mapEscolhido = {};
late List listaEscolhida = [];
String dropdownValue = "";
String urlSerie = '';
var service;
var ultimaDataIPCA;
String? meuNumeroTeste;
List<String> listaMostrar = <String>[];
var fonte;


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

var ultimaDataIPCA_nova;

class _TelaDados extends State<TelaDados> {

  Future<String> getJsonFromRestAPI() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('numeroSerieSGS', urlSerie);
    //String url = "https://api.bcb.gov.br/dados/serie/bcdata.sgs.433/dados?formato=json";
    String url = urlSerie;
    http.Response response = await http.get(Uri.parse(url));
    return response.body;
  }

  List<serieSGS> chartData = [];

  DateTime startval1 = DateFormat('MM/yyyy').parse('01/2021');
  DateTime endval1 = DateFormat('MM/yyyy').parse('12/2021');

  TextEditingController dateInputEnd = TextEditingController();
  TextEditingController dateInputIni = TextEditingController();

  Future loadDataSGS() async {
    String jsonString = await getJsonFromRestAPI();
    final jsonResponse = json.decode(jsonString);
    setState(() {
      for (Map<String, dynamic> i in jsonResponse){
        chartData.add(serieSGS.fromJson(i));
      }
      endval1 = chartData.last.data;
      startval1 = chartData[chartData.length-13].data;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dataFinal', endval1.toString());
  }

  NumberFormat formatter1 = new NumberFormat("00");
  NumberFormat formatter2 = new NumberFormat("0000");

  Future loadDataIBGE() async {
    String jsonString = await getJsonFromRestAPI();
    final jsonResponse = json.decode(jsonString);
    final item = jsonResponse[0]['resultados'][0]['series'][0]['serie'];
    setState(() {
      for (var i = 0; i<item.keys.toList().length; i++){
        var x = item.keys.toList()[i];
        x = formatter1.format(int.parse(x.substring(4))) + "/" + formatter2.format(int.parse(x.substring(0, 4)));
        var y = item.values.toList()[i].toString();
        if(y!="..."){
          chartData.add(
              serieSGS(
                  DateFormat('MM/yyyy').parse(x),
                  double.parse(y)
              )
          );
        }
      }
    });
  }

  List<serieSGS> itemsBetweenDates({
    required List<serieSGS> lista,
    required DateTime start,
    required DateTime end,
  }) {
    var output = <serieSGS>[];
    for (var i = 0; i < lista.length; i += 1) {
      DateTime date = lista[i].data;
      if (date.compareTo(start) >= 0 && date.compareTo(end) <= 0) {
        output.add(lista[i]);
      }
    }
    return output;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.assuntoSerie=="Índice de preços"){
      listaEscolhida = listaPrecos;
    }
    //Iterable values = listaEscolhida.where((element) => element['nome']);
    listaMostrar.clear();
 /*   for(final value in values) {
      listaMostrar.add(value);
    }*/
    for(var i = 0; i<listaEscolhida.length; i++) {
      listaMostrar.add(listaEscolhida[i].nome);
    }
    dropdownValue = listaMostrar.first;
    urlSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue).urlAPI;
    fonte = listaEscolhida.firstWhere((element) => element.nome==dropdownValue).fonte;


    if(fonte=="SISTEMA GERENCIADOR DE SÉRIES TEMPORAIS (SGS). Banco Central do Brasil"){
      loadDataSGS();
    } else {
      loadDataIBGE();
    }

  }

  var initialIndex = 0;

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

    var _category;

    return Scaffold(
        appBar: AppBar(
          title: Text("$dropdownValue"),
        ),
        body: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                Center(
                  child: FutureBuilder(
                      future: getJsonFromRestAPI(),
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Text(
                              ''
                          );
                        }
                        else {
                          return CircularProgressIndicator();
                        }
                      }
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Selecione a série:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(
                            child: DropdownButton<String>(
                              value: dropdownValue,
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 16,
                              style: const TextStyle(color: Colors.deepPurple),
                              underline: Container(
                                height: 2,
                                color: Colors.deepPurpleAccent,
                              ),
                              onChanged: (String? value) {
                                // This is called when the user selects an item.
                                setState(() {
                                  dropdownValue = value!;
                                  urlSerie = listaEscolhida.firstWhere((element) => element.nome==dropdownValue).urlAPI;
                                  fonte = listaEscolhida.firstWhere((element) => element.nome==dropdownValue).fonte;
                                  chartData.clear();
                                  if(fonte=="SISTEMA GERENCIADOR DE SÉRIES TEMPORAIS (SGS). Banco Central do Brasil"){
                                    loadDataSGS();
                                  } else {
                                    loadDataIBGE();
                                  }
                                });
                              },
                              items: listaMostrar.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )
                        ),

                      ),
                      ToggleSwitch(
                        initialLabelIndex: initialIndex,
                        totalSwitches: 2,
                        labels: [
                          'Não',
                          'Sim',
                        ],
                        onToggle: (index) async {
                          final service = FlutterBackgroundService();
                          if(index==1){
                            await initializeService();
                            service.startService();
                          } else {
                            service.invoke("stopService");
                          }
                          setState(() {
                            initialIndex = index!;
                          });
                        },
                      ),
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
                              firstDate: DateFormat('MM/yyyy').parse("01/1980"),
                              lastDate: DateFormat('MM/yyyy').parse("12/2100")
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
                              firstDate: DateFormat('MM/yyyy').parse("01/1980"),
                              lastDate: DateFormat('MM/yyyy').parse("12/2100")
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
                          "Gráfico",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SfCartesianChart(
                        margin: EdgeInsets.only(left: 5),
                        primaryXAxis: CategoryAxis(
                          axisLabelFormatter: (AxisLabelRenderDetails args) {
                            late String text;
                            text = DateFormat('MM/yy').format(DateTime.parse(args.text)).toString();
                            return ChartAxisLabel(text, args.textStyle);
                          },
                        ),
                        series: <ChartSeries<serieSGS, String>>[
                          // Renders line chart
                          LineSeries<serieSGS, String>(
                              dataSource: filtrarDados(),
                              xValueMapper: (serieSGS variavel, _) => variavel.data.toString(),
                              yValueMapper: (serieSGS variavel, _) => variavel.valor,
                              dataLabelMapper: (serieSGS data, _) => data.valor.toString().replaceAll(".", ","),
                              dataLabelSettings: DataLabelSettings(isVisible: true,
                                  textStyle: TextStyle(fontSize: 11)),
                              markerSettings: MarkerSettings(isVisible: true)
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: Text(
                          "Fonte: BANCO CENTRAL DO BRASIL. Séries Temporais (SGS).",
                          style: TextStyle(fontSize: 10),
                        ),
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
                                  e.valor.toString().replaceAll('.', ','),
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
