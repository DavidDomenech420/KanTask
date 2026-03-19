
class Tablero {
  int? id;
  String nombre;
  String? ownerId;

  Tablero({this.id, required this.nombre, this.ownerId});

  factory Tablero.fromJson(Map<String, dynamic> json) {
    return Tablero(
      id: json['id'],
      nombre: json['name'] ?? 'Sin nombre',
      ownerId: json['owner_id'],
    );
  }

}