import 'package:dados_economicos/TelaDados.dart';
import 'package:dados_economicos/variables_class.dart';
import 'package:flutter/material.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toLowerCase()}${this.substring(1)}";
  }
}

extension StringExtension2 on String {
  String capitalize2() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

class DescricaoSeries extends StatelessWidget {

  final int cod_series;
  const DescricaoSeries({Key? key, required this.cod_series}) : super(key: key);
  const DescricaoSeries.otherConstructor(this.cod_series);

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text("Descrição da série", style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: Color.fromRGBO(63, 81, 181, 20),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(listaSeries.firstWhere((element) => element.numero==cod_series ).nomeCompleto,
              style: TextStyle(fontWeight: FontWeight.bold),),
              subtitle: Text("\nDescrição: "+listaSeries.firstWhere((element) => element.numero==cod_series).descricao+
                  "\n"+
                  "\nNível geográfico: "+listaSeries.firstWhere((element) => element.numero==cod_series).nivelGeografico +
                  "\n"+
                  "\nLocalidade: "+listaSeries.firstWhere((element) => element.numero==cod_series).localidades +
                  "\n"+
                  "\nGrupo: "+listaSeries.firstWhere((element) => element.numero==cod_series).categoria +
                  "\n"+
                  "\nForma de cálculo: "+listaSeries.firstWhere((element) => element.numero==cod_series).metrica+
                  "\n"+
                  "\nFormato da série: "+listaSeries.firstWhere((element) => element.numero==cod_series).formato+
                  "\n"+
                  "\nPeriodicidade de divulgação: "+listaSeries.firstWhere((element) => element.numero==cod_series).periodicidade +
                  "\n"+
                  "\nPeríodo disponível: entre $dataInicialSerie e $dataFinalSerie" +
                  "\n"+
                  "\nFonte dos dados (local onde os dados são obtidos): "+listaSeries.firstWhere((element) => element.numero==cod_series).fonte+
                  "\n",
                textAlign: TextAlign.justify,
              ),
            );
          },
        ),
      )

    );
  }
}
