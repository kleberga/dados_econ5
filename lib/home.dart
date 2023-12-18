import 'package:flutter/material.dart';
import 'TelaDados.dart';
import 'loading_overlay.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Escolha o assunto"),
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
                      child: Text("Índices de preços")
                  ),
                ),
              )
            ],
          ),
        ),


    );
  }
}








