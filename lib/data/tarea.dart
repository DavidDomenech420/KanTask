class Tarea {
  String nombre;
  bool completada;
  DateTime? fechaLimite;
  int prioridad;

  Tarea({required this.nombre, this.completada = false, this.fechaLimite, this.prioridad = 0});

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'completada': completada,
      'fechaLimite': fechaLimite?.toIso8601String(),
      'prioridad': prioridad,
    };
  }

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      nombre: json['nombre'],
      completada: json['completada'],
      fechaLimite: json['fechaLimite'] != null
          ? DateTime.parse(json['fechaLimite'])
          : null,
      prioridad: json['prioridad'],
    );
  }
}
