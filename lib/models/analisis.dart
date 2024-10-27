class Analisis {
  String id;
  String idCita;
  List<ResultadoAnalisis> resultados;

  Analisis(this.id, this.idCita, this.resultados);
}

class ResultadoAnalisis {
  String indicador;
  double valor;

  ResultadoAnalisis(this.indicador, this.valor);
}