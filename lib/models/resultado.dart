class Resultado {
  String id;
  String idCita;
  String diagnostico;
  String indicaciones;
  List<Medicamento> receta;

  Resultado(this.id, this.idCita, this.diagnostico, this.indicaciones, this.receta);
}

class Medicamento {
  String medicamento;
  String dosis;
  String duracion;

  Medicamento({
    required this.medicamento,
    required this.dosis,
    required this.duracion,
  });
}

