import 'package:flutter/material.dart';

class Tarea {
  String nombre;
  EstadoTarea estado;
  DateTime? fechaLimite;
  int prioridad;

  Tarea({required this.nombre, this.estado = EstadoTarea.backlog, this.fechaLimite, this.prioridad = 0});

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'estado': estado.name,
      'fechaLimite': fechaLimite?.toIso8601String(),
      'prioridad': prioridad,
    };
  }

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      nombre: json['nombre'],
      estado: EstadoTarea.values.byName(json['estado'] ?? 'backlog'),
      fechaLimite: json['fechaLimite'] != null
          ? DateTime.parse(json['fechaLimite'])
          : null,
      prioridad: json['prioridad'],
    );
  }

  String getStringEstado(){
    String estadoTexto;
    switch (estado) {
      case EstadoTarea.backlog:
        estadoTexto = "Backlog";
        break;
      case EstadoTarea.enProgreso:
        estadoTexto = "En progreso";
        break;
      case EstadoTarea.bloqueado:
        estadoTexto = "Bloqueado";
        break;
      case EstadoTarea.completado:
        estadoTexto = "Completado";
        break;
    }

    return estadoTexto;
  }

  Color getColorEstado(){
    Color estadoColor;
    switch (estado) {
      case EstadoTarea.backlog:
        estadoColor = Colors.blue;
        break;
      case EstadoTarea.enProgreso:
        estadoColor = Colors.orange;
        break;
      case EstadoTarea.bloqueado:
        estadoColor = Colors.red;
        break;
      case EstadoTarea.completado:
        estadoColor = Colors.green;
        break;
    }

    return estadoColor;
  }

  void avanzarEstado(){
    switch (estado) {
      case EstadoTarea.backlog:
        estado = EstadoTarea.enProgreso;
        break;
      case EstadoTarea.enProgreso:
        estado = EstadoTarea.completado;
        break;
      case EstadoTarea.bloqueado:
        estado = EstadoTarea.backlog;
        break;
      case EstadoTarea.completado:
        estado = EstadoTarea.bloqueado;
        break;
    }

  }

}

enum EstadoTarea{
  backlog,
  enProgreso,
  bloqueado,
  completado
}
