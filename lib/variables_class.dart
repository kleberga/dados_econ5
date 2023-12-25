
import 'package:intl/intl.dart';

class serie_app {
  final DateTime data;
  final double valor;
  serie_app(this.data, this.valor);
  factory serie_app.fromJson(Map<String, dynamic> parsedJson){
    return serie_app(
      DateFormat('MM/yyyy').parse(parsedJson['data'].substring(3)),
      double.parse(parsedJson['valor']),
    );
  }
}

/*class serieIBGE {
  final DateTime data;
  final double valor;
  serieIBGE(this.data, this.valor);
}*/

class cadastroSeries {
  final int numero;
  final String nome;
  final String nomeCompleto;
  final String descricao;
  final String formato;
  final String fonte;
  final String urlAPI;

  cadastroSeries(
      this.numero, this.nome, this.nomeCompleto, this.descricao, this.formato, this.fonte, this.urlAPI);
}

List<cadastroSeries> listaSeries = [
  cadastroSeries(1, "IPCA - Variação mensal", "Índice Nacional de Preços ao Consumidor Amplo", "Aponta a variação do custo de vida médio de famílias com renda mensal de 1 e 40 salários mínimos.",  "%", "SISTEMA GERENCIADOR DE SÉRIES TEMPORAIS (SGS). Banco Central do Brasil", "https://api.bcb.gov.br/dados/serie/bcdata.sgs.433/dados?formato=json"),
  cadastroSeries(2, "INPC - Variação mensal", "Índice Nacional de Preços ao Consumidor", "Verifica a variação apenas para famílias com renda mensal entre 1 e 5 salários mínimos. São grupos mais sensíveis às variações de preço, pois tendem a gastar todo o seu rendimento em itens básicos, como alimentação, medicamentos, transporte, etc.", "%", "IBGE", "https://servicodados.ibge.gov.br/api/v3/agregados/1736/periodos/all/variaveis/44?localidades=N1")
];

// "https://servicodados.ibge.gov.br/api/v3/agregados/1736/periodos/all/variaveis/44?localidades=N1[all]"

/*class notificaSerie{
  final int numero;
  final int toggleValue;

  notificaSerie(this.numero, this.toggleValue);
}*/



class NotificaSerie {
  int value;
  NotificaSerie(this.value);
  NotificaSerie.fromJson(Map<int, dynamic> json) : this.value = json['value'];
  Map<int, dynamic> toJson() => {1: 0};
}
