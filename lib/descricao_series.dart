import 'package:dados_economicos/TelaDados.dart';
import 'package:dados_economicos/variables_class.dart';
import 'package:flutter/material.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toLowerCase()}${this.substring(1)}";
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
        title: Text("Descrição da série"),
        backgroundColor: Colors.blue[100],
      ),
      body: Container(
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(listaSeries.firstWhere((element) => element.numero==cod_series ).nomeCompleto),
              subtitle: Text("\nDescrição: "+listaSeries.firstWhere((element) => element.numero==cod_series).descricao.capitalize() +
                  "\n"+
                  "\nNível geográfico: "+listaSeries.firstWhere((element) => element.numero==cod_series).nivelGeografico +
                  "\n"+
                  "\nLocalidade: "+listaSeries.firstWhere((element) => element.numero==cod_series).localidades +
                  "\n"+
                  "\nGrupo: "+listaSeries.firstWhere((element) => element.numero==cod_series).categoria.toLowerCase() +
                  "\n"+
                  "\nForma de cálculo: "+listaSeries.firstWhere((element) => element.numero==cod_series).metrica.capitalize()+
                  "\n"+
                  "\nFormato da série: "+listaSeries.firstWhere((element) => element.numero==cod_series).formato+
                  "\n"+
                  "\nPeriodicidade de divulgação: "+listaSeries.firstWhere((element) => element.numero==cod_series).periodicidade +
                  "\n"+
                  "\nPeríodo disponível: entre $dataInicialSerie e $dataFinalSerie" +
                  "\n"+
                  "\nFonte: "+listaSeries.firstWhere((element) => element.numero==cod_series).fonte+
                  "\n"),
            );
          },
        ),
      )

    );
  }
}
