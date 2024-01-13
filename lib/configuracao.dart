import 'dart:async';
import 'package:dados_economicos/variables_class.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'home.dart';


// variavel para armazenar o progresso do for
double progress = 0.0;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  void preencherDados() async {
    for(var i = 0; i<listaSeries.length; i++){
      print(i);
      var numeroSerie = listaSeries[i].numero;
      var fido = Toggle_reg(id: numeroSerie, valorToggle: 0, dataCompara: '');
      await DatabaseHelper.insertToggle(fido);
      setState(() {
        progress = i/(listaSeries.length-1);
      });
      print(progress);
      if(progress==1.0){
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => Home()));
      }
    }
  }


  @override
  void initState() {
    super.initState();
//Navigates to new screen after 5 seconds.

    preencherDados();
/*    Timer(Duration(seconds: 5), () {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => Home()));
    });*/
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/icone_economico.png'),
                fit: BoxFit.none ,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    ],
                  ),
                ),
              ),
              Text(
                "Configurando o aplicativo...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold) ,
              ),
              Padding(padding: EdgeInsets.all(10)),
              Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 100.0, left: 100.0),
                        child: LinearProgressIndicator(
                          minHeight: 25,
                          value: progress,
                          semanticsLabel: (progress * 100).toString(),
                          semanticsValue: (progress * 100).toString(),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 10.0))
                    ],
                  ))
            ],
          )
        ],
      ),
    );
  }
}