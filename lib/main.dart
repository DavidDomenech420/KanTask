import 'dart:math';
import 'data/tarea.dart';

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

  void actualizarTarea(int index){
    setState(() {
      misTareas[index].nombre = controlador.text;
      misTareas[index].fechaLimite = fechaSeleccionada;
      misTareas[index].prioridad = prioridadSeleccionada;

      controlador.clear();
      fechaSeleccionada = null;
    });
    Navigator.of(context).pop();
  }

  void eliminarTarea(int index) {
    // 1. Necesitamos setState para avisar a la pantalla.
    setState(() {
      // 2. Borra el elemento usando 'index'.
      misTareas.removeAt(index);
      Navigator.of(context).pop();
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

  void _mostrarFormTarea({int? posTarea}) {
    fechaSeleccionada = null;
    prioridadSeleccionada = 0;
    final Map<int, String> etiquetasPrioridad = {
      0: 'Sin prioridad',
      1: 'Prioridad baja',
      2: 'Prioridad media',
      3: 'Prioridad alta',
    };
    if (posTarea != null) {
      Tarea tarea = misTareas[posTarea];
      controlador.text = tarea.nombre;
      fechaSeleccionada = tarea.fechaLimite;
      prioridadSeleccionada = tarea.prioridad;
    }
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
                    if (posTarea != null) {
                      actualizarTarea(posTarea);
                    }
                    else {
                      agregarTarea();

                    }
                  },
                  child: posTarea != null ? Text("Actualizar") : Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  List<Tarea> _filtrarTareas(EstadoTarea estadoBuscado) {
    return misTareas.where((tarea) => tarea.estado == estadoBuscado).toList();
  }
  
  Widget _construirColumna(String titulo, EstadoTarea estadoDeLaColumna) {
    List<Tarea> tareasFiltradas = _filtrarTareas(estadoDeLaColumna);

    return Container(
      width: MediaQuery.of(context).size.width * 0.85, 
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Un fondo gris clarito tipo Trello
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              titulo, 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
          ),
          
          // 3. LA LISTA DE TAREAS
          Expanded(
            child: ListView.builder(
              itemCount: tareasFiltradas.length,
              itemBuilder: (context, index) {
                Tarea tareaActual = tareasFiltradas[index];
                
                // TU MISIÓN AQUÍ: 
                // Pega aquí el widget ListTile (o Card) que ya tenías hecho antes.
                // Ojo: asegúrate de que use 'tareaActual' para mostrar los datos.
                return  Card(
                  key: ValueKey(misTareas[index]),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    leading: ActionChip(
                      label: Text(tareaActual.getStringEstado()),
                      backgroundColor: tareaActual.getColorEstado(),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                      ),
                      onPressed: () {
                        setState(() {
                          tareaActual.avanzarEstado();
                        });
                        _guardarTareas();
                      },
                      avatar: CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.circle,
                          size: 10, 
                          color: Colors.white
                        ),
                      ),
                    ),

                    // Aquí mostramos el texto que recuperaste arriba
                    title: Text(
                      tareaActual.nombre,
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        tareaActual.fechaLimite != null ? Text("${tareaActual.fechaLimite!.day}/${tareaActual.fechaLimite!.month}/${tareaActual.fechaLimite!.year}",) : Text(""),
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
                      _mostrarFormTarea(posTarea: index);
                      _guardarTareas();
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
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
        onPressed: _mostrarFormTarea,
        child: Icon(Icons.add),
      ),
      body: ListView(
        scrollDirection: Axis.horizontal, 
        
        children: [
          // TU MISIÓN: Llama a la función _construirColumna 4 veces
          _construirColumna("Backlog", EstadoTarea.backlog),
          _construirColumna("En Progreso", EstadoTarea.enProgreso),
          _construirColumna("Completado", EstadoTarea.completado),
          _construirColumna("Bloqueado", EstadoTarea.bloqueado),
        ],
      ),
    );
  }
}