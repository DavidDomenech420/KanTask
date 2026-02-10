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
  int prioridadSeleccionada = 0;

  void agregarTarea() {
    // 1. Usamos setState para que la pantalla se actualice
    setState(() {
      // 2. Añadir a la lista.
      misTareas.add(
        Tarea(nombre: controlador.text, fechaLimite: fechaSeleccionada, prioridad: prioridadSeleccionada),
      );

      // 3. Limpiar el input.
      controlador.clear();
      fechaSeleccionada = null;
    });
    Navigator.of(context).pop();
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

  String assignarPrioridad(Tarea tarea){
    int prioridadTarea = tarea.prioridad;
    String prioridadString = "";
    switch (prioridadTarea) {
      case 0:
        prioridadString = "Sin prioridad";
        break;
      case 1:
        prioridadString = "Prioridad baja";
        break;
      case 2:
        prioridadString = "Prioridad media";
        break;
      case 3: 
        prioridadString = "Prioridad alta";
        break;
      default:
    }

    return prioridadString;
  }

  MaterialColor assignarColorPrioridad(Tarea tarea){
    int prioridadTarea = tarea.prioridad;
    MaterialColor colorPrioridad = Colors.lightBlue;
    switch (prioridadTarea) {
      case 1:
        colorPrioridad = Colors.green;
        break;
      case 2:
        colorPrioridad = Colors.orange;
        break;
      case 3: 
        colorPrioridad = Colors.red;
        break;
      default:
    }

    return colorPrioridad;
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

  void _agregarTarea() {
    fechaSeleccionada = null;
    prioridadSeleccionada = 0;
    final Map<int, String> etiquetasPrioridad = {
      0: 'Sin prioridad',
      1: 'Prioridad baja',
      2: 'Prioridad media',
      3: 'Prioridad alta',
    };
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDelDialogo) {
            return AlertDialog(
              title: Text('Tarea Nueva'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controlador,
                    decoration: InputDecoration(
                      labelText: "Nombre de la tarea",
                    ),
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          fechaSeleccionada != null
                              ? Text(
                                  "${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}",
                                )
                              : Text("dd/mm/yyyy"),
                          Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                    onTap: () async {
                      final DateTime? fechaCogida = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        initialDate: DateTime.now(),
                        lastDate: DateTime(2099, 12, 31),
                      );

                      if (fechaCogida != null) {
                        setStateDelDialogo(() {
                          fechaSeleccionada = fechaCogida;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<int>(
                    initialValue: prioridadSeleccionada,
                    items: [0, 1, 2, 3].map((int prioridad) {
                      return DropdownMenuItem(
                        value: prioridad,
                        child: Text(etiquetasPrioridad[prioridad]!)
                        );
                    }).toList(),
                    onChanged: (value)  {
                      if(value != null){
                        setStateDelDialogo(() {
                          prioridadSeleccionada = value;
                        });
                      }
                    },
                  )

                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    agregarTarea();
                  },
                  child: Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
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
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarTarea,
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
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

                    subtitle: Row(
                      children: [
                        tareaActual.fechaLimite != null ? Text("${tareaActual.fechaLimite!.day}/${tareaActual.fechaLimite!.month}/${tareaActual.fechaLimite!.year} - ",) : Text(""),
                        Text(assignarPrioridad(tareaActual), style: TextStyle(
                          color: assignarColorPrioridad(tareaActual)
                        ),)
                      ],
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
