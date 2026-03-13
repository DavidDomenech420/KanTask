import 'package:flutter/material.dart';

class Tablero {
  int? id;
  String nombre;

  Tablero({this.id, required this.nombre});

  factory Tablero.fromJson(Map<String, dynamic> json) {
    return Tablero(
      id: json['id'],
      nombre: json['name'] ?? 'Sin nombre',
    );
  }

}