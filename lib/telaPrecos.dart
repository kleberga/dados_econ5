import 'package:dados_economicos/TelaDados.dart';
import 'package:flutter/material.dart';

class TelaPrecos extends StatefulWidget {

  const TelaPrecos({super.key});
  @override
  State<TelaPrecos> createState() => _TelaPrecosState();
}

class _TelaPrecosState extends State<TelaPrecos> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Índices de preços"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Center(
                child: ElevatedButton(
                    style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(Size(200, 40))
                    ),
                    onPressed: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TelaDados(assuntoSerie: 'Índice de preços',)
                          )
                      );
                    },
                    child: Text("IPCA - var. mensal")
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Center(
                child: ElevatedButton(
                    style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(Size(200, 40))
                    ),
                    onPressed: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TelaDados(assuntoSerie: 'Índice de preços',)
                          )
                      );
                    },
                    child: Text("INPC - var. mensal")
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
