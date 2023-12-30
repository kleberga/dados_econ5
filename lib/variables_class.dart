
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

class Assunto {
  final int id;
  final String nome;
  Assunto(this.id, this.nome);
}

List<Assunto> listaAssunto = [
  Assunto(1, "Índice de preços"),
  Assunto(2, "Atividade econômica")
];


class cadastroSeries {
  final int numero;
  final String nome;
  final String nomeCompleto;
  final String descricao;
  final String formato;
  final String fonte;
  final String urlAPI;
  final int idAssunto;
  final String periodicidade;
  final String metrica;
  final String nivelGeografico;
  final String localidades;
  final String categoria;
  cadastroSeries(
      this.numero, this.nome, this.nomeCompleto, this.descricao, this.formato,
      this.fonte, this.urlAPI, this.idAssunto, this.periodicidade, this.metrica,
      this.nivelGeografico, this.localidades, this.categoria);
  @override
  toString(){
    return "numero $numero, nome: $nome, nomeCompleto: $nomeCompleto, urlAPI: $urlAPI";
  }
}


List<cadastroSeries> listaSeries = [
  cadastroSeries(1,
      "IPCA - Variação mensal",
      "Índice Nacional de Preços ao Consumidor Amplo (IPCA)",
      "indica a variação do custo de vida médio de famílias com renda mensal de 1 e 40 salários mínimos.",
      "%",
      "IBGE",
      "https://servicodados.ibge.gov.br/api/v3/agregados/1737/periodos/all/variaveis/63?localidades=N1[all]",
      1,
      "mensal",
      "44",
      "Brasil",
      "1",
      "7169")
];

class Metrica{
  int id;
  String nome;
  Metrica({required this.id, required this.nome});
  @override
  toString(){
    return "id: $id nome: $nome";
  }

}

class NivelGeografico{
  String id;
  String nome;
  NivelGeografico({required this.id, required this.nome});
  @override
  toString(){
    return "id: $id, nome: $nome";
  }
}

class Localidades{
  int id;
  String nome;
  String nivelGeografico;
  Localidades({required this.id, required this.nome, required this.nivelGeografico});
  @override
  toString(){
    return "id: $id, nome: $nome, nivelGeografico: $nivelGeografico";
  }
}

class Categorias{
  int id;
  String nome;
  Categorias({required this.id, required this.nome});
  @override
  toString(){
    return "id: $id, nome: $nome";
  }
}