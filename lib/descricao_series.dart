import 'package:dados_economicos/TelaDados.dart';
import 'package:dados_economicos/variables_class.dart';
import 'package:flutter/material.dart';

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
              subtitle: Text("\nDescrição: "+listaSeries.firstWhere((element) => element.numero==cod_series).descricao +
                  "\n"+
                  "\nAbrangência: "+listaSeries.firstWhere((element) => element.numero==cod_series).nivelGeografico +
                  "\n"+
                  "\nPeriodicidade: "+listaSeries.firstWhere((element) => element.numero==cod_series).periodicidade +
                  "\n"+
                  "\nFormato: "+listaSeries.firstWhere((element) => element.numero==cod_series).formato+
                  "\n"+
                  "\nForma de cálculo: "+listaSeries.firstWhere((element) => element.numero==cod_series).metrica+
                  "\n"+
                  "\nFonte: "+listaSeries.firstWhere((element) => element.numero==cod_series).fonte+
                  "\n"+
                  "\nPeríodo disponível: entre $dataInicialSerie e $dataFinalSerie."

              ),

            );
          },
        ),
      )

    );
  }
}
