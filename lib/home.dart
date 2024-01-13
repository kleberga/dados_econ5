import 'package:dados_economicos/variables_class.dart';
import 'package:flutter/material.dart';
import 'TelaDados.dart';
import 'configuracao.dart';
import 'database_helper.dart';
import 'main.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

/*  void preencherDados() async {
    for(var i = 0; i<listaSeries.length; i++){
      var numeroSerie = listaSeries[i].numero;
      var fido = Toggle_reg(id: numeroSerie, valorToggle: 0, dataCompara: '');
      await DatabaseHelper.insertToggle(fido);
      setState(() {
        progress = i/listaSeries.length;
      });
    }
  }*/


  @override
  void initState() {
    // chamar a função anterior
    //preencherDados();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Escolha o assunto", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(63, 81, 181, 20),
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      body: Container(
          child: Column(
            children: <Widget>[
/*            LinearProgressIndicator(
              minHeight: 25,
              value: progress,
              semanticsLabel: (progress * 100).toString(),
              semanticsValue: (progress * 100).toString(),
          ),*/
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 10),
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
                        //backgroundColor: MaterialStateProperty.all(Colors.grey[200],
                        backgroundColor: MaterialStateProperty.all(Color.fromRGBO(63, 81, 181, 20),
                        ),
                      ),
                      onPressed: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TelaDados(assuntoSerie: 'Índice de preços',)
                            )
                        );
                      },
                      child: Text("Índices de preços", style: TextStyle(fontSize: 16, color: Colors.white),)
                  ),
                ),
              )
              ),
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
                            //backgroundColor: MaterialStateProperty.all(Colors.grey[200],
                            backgroundColor: MaterialStateProperty.all(Color.fromRGBO(63, 81, 181, 20),
                            ),
                          ),
                          onPressed: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TelaDados(assuntoSerie: 'Setor real',)
                                )
                            );
                          },
                          child: Text("Setor real", style: TextStyle(fontSize: 16, color: Colors.white),)
                      ),
                    ),
                  )
              ),
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
                            //backgroundColor: MaterialStateProperty.all(Colors.grey[200],
                            backgroundColor: MaterialStateProperty.all(Color.fromRGBO(63, 81, 181, 20),
                            ),
                          ),
                          onPressed: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TelaDados(assuntoSerie: 'Mercado de trabalho',)
                                )
                            );
                          },
                          child: Text("Mercado de trabalho", style: TextStyle(fontSize: 16, color: Colors.white),)
                      ),
                    ),
                  )
              ),
            ],
          ),
        ),


    );
  }
}








