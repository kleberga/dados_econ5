import 'package:flutter/material.dart';
import 'TelaDados.dart';

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
        backgroundColor: Colors.blue[100],
      ),
      body: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: Center(
                  child:
                  Container(
                    height: 40,
                    width: 250,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30), //border raiuds of dropdown button
                        boxShadow: <BoxShadow>[ //apply shadow on Dropdown button
                          BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                              blurRadius: 5) //blur radius of shadow
                        ]
                    ),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all(Size(200, 40)),
                        backgroundColor: MaterialStateProperty.all(Colors.grey[200]),
                      ),
                      onPressed: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TelaDados(assuntoSerie: 'Índice de preços',)
                            )
                        );
                      },
                      child: Text("Índices de preços", style: TextStyle(fontSize: 16),)
                  ),
                ),
              )
              )
            ],
          ),
        ),


    );
  }
}








