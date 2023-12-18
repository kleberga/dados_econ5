
import 'package:intl/intl.dart';

class serieSGS {
  final DateTime data;
  final double valor;
  serieSGS(this.data, this.valor);
  factory serieSGS.fromJson(Map<String, dynamic> parsedJson){
    return serieSGS(
      DateFormat('MM/yyyy').parse(parsedJson['data'].substring(3)),
      double.parse(parsedJson['valor']),
    );
  }
}

class serieIBGE {
  final DateTime data;
  final double valor;
  serieIBGE(this.data, this.valor);
}

class cadastroSeries {
  final int numero;
  final String nome;
  final String formato;
  final String fonte;
  final String urlAPI;

  cadastroSeries(
      this.numero, this.nome, this.formato, this.fonte, this.urlAPI);
}

List<cadastroSeries> listaPrecos = [
  cadastroSeries(1, "IPCA - Variação mensal", "%", "SISTEMA GERENCIADOR DE SÉRIES TEMPORAIS (SGS). Banco Central do Brasil", "https://api.bcb.gov.br/dados/serie/bcdata.sgs.433/dados?formato=json"),
  cadastroSeries(2, "INPC - Variação mensal", "%", "IBGE", "https://servicodados.ibge.gov.br/api/v3/agregados/1736/periodos/all/variaveis/44?localidades=N1[all]")
];