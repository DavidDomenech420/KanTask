import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MaterialApp(home: ListaTareas()));
}

class ListaTareas extends StatefulWidget {
  @override
  _ListaTareasState createState() => _ListaTareasState();
}

class _ListaTareasState extends State<ListaTareas> {
  // --- ZONA LÓGICA ---

  List<Tarea> misTareas = [];
  TextEditingController controlador = TextEditingController();
  DateTime? fechaSeleccionada;

  void agregarTarea() {
    // 1. Usamos setState para que la pantalla se actualice
    setState(() {
      // 2. Añadir a la lista.
      misTareas.add(Tarea(nombre: controlador.text));

      // 3. Limpiar el input.
      controlador.clear();
    });
    _guardarTareas();
  }

  void eliminarTarea(int index) {
    // 1. Necesitamos setState para avisar a la pantalla.
    setState(() {
      // 2. Borra el elemento usando 'index'.
      misTareas.removeAt(index);
      Navigator.of(context).pop();
    });
  }

  void completarTarea(Tarea tarea) {
    setState(() {
      tarea.completada = !tarea.completada;
    });
  }

  void _guardarTareas() async {
    SharedPreferences preferencias = await SharedPreferences.getInstance();

    final String tareasJson = jsonEncode(
      misTareas.map((e) => e.toJson()).toList(),
    );

    await preferencias.setString('mis_tareas_v1', tareasJson);

    print("Datos guardados satisfactoriamente");
  }

  void _preguntarBorrado(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("¿Estás seguro?"),
          content: Text("Vas a eliminar esta tarea de forma permanente."),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text('Cancelar'),
            ),

            TextButton(
              onPressed: () {
                eliminarTarea(index);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _leerTareas() async {
    final preferencias = await SharedPreferences.getInstance();

    // 1. Intentamos leer el texto guardado.
    final String? tareasJson = preferencias.getString('mis_tareas_v1');

    // 2. Si hay datos (no es null), los cargamos.
    if (tareasJson != null) {
      setState(() {
        List<dynamic> mapaTareas = jsonDecode(tareasJson);
        misTareas = mapaTareas.map((e) => Tarea.fromJson(e)).toList();
      });
    }
  }
  
  void _seleccionarFecha() async {
    final DateTime? fechaCogida = await showDatePicker(
      context: context, 
      firstDate: DateTime.now(),
      initialDate: DateTime.now(), 
      lastDate: DateTime(2099, 12, 31)
    );

    if (fechaCogida!= null) {
      setState(() {
        fechaSeleccionada = fechaCogida;
      });
    }
  }

  // -------------------

  @override
  void initState() {
    super.initState(); // Siempre hay que llamar al "super" primero

    _leerTareas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Tareas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: controlador)),

                SizedBox(width: 10),

                ElevatedButton(onPressed: agregarTarea, child: Text('Guardar')),
              ],
            ),
          ),

          // Aquí abajo pondremos la lista después. Por ahora dejémoslo vacío.
          Expanded(
            child: ReorderableListView.builder(
              itemCount: misTareas.length,

              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  // Ajuste necesario porque al quitar un elemento, la lista se acorta
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }

                  final Tarea item = misTareas.removeAt(oldIndex);

                  misTareas.insert(newIndex, item);
                });
                _guardarTareas();
              },

              // Este constructor se ejecuta una vez por cada tarea.
              // 'index' es la posición (0, 1, 2, 3...)
              itemBuilder: (context, index) {
                final tareaActual = misTareas[index];

                // Aquí devolvemos el diseño de la fila.
                return Card(
                  key: ValueKey(misTareas[index]),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    leading: Icon(
                      tareaActual.completada
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.deepPurple[400],
                    ),

                    // Aquí mostramos el texto que recuperaste arriba
                    title: Text(
                      tareaActual.nombre,
                      style: TextStyle(
                        decoration: tareaActual.completada
                            ? TextDecoration.lineThrough
                            : null,
                        color: tareaActual.completada
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),

                    // TRAILING: Es la parte derecha del ListTile
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _preguntarBorrado(index);
                        _guardarTareas();
                      },
                    ),

                    onTap: () {
                      completarTarea(tareaActual);
                      _guardarTareas();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Tarea {
  String nombre;
  bool completada;
  DateTime? fechaLimite;

  Tarea({required this.nombre, this.completada = false, this.fechaLimite});

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre, 
      'completada': completada,
      'fechaLimite' : fechaLimite?.toIso8601String()
    };
  }

  factory Tarea.fromJson(Map<String, dynamic> json) {
    
    return Tarea(
      nombre: json['nombre'], 
      completada: json['completada'],
      fechaLimite: json['fechaLimite']!=null ? DateTime.parse(json['fechaLimite']) : null
    );
  }
}
