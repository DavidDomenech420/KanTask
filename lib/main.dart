import 'dart:async';

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
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  void agregarTarea() {
    // Usamos setState para que la pantalla se actualice
    setState(() {
      // Añadir a la lista.
      misTareas.add(
        Tarea(nombre: controlador.text, fechaLimite: fechaSeleccionada, prioridad: prioridadSeleccionada),
      );

      // Limpiar el input.
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
    setState(() {
      // Borra el elemento usando 'index'.
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

  Color assignarColorEstado(EstadoTarea estado){
    Color colorEstado;
    switch (estado) {
      case EstadoTarea.backlog:
        colorEstado = Colors.blue[200]!;
        break;
      case EstadoTarea.enProgreso:
        colorEstado = Colors.orange[200]!;
        break;
      case EstadoTarea.completado: 
        colorEstado = Colors.green[200]!;
        break;
      case EstadoTarea.bloqueado:
        colorEstado =  Colors.red[200]!;
    }

    return colorEstado;
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

    // Intentamos leer el texto guardado.
    final String? tareasJson = preferencias.getString('mis_tareas_v1');

    // Si hay datos, los cargamos.
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

    return DragTarget(

      onAcceptWithDetails: (DragTargetDetails<Tarea> detalles){
        Tarea tareaArrastrada = detalles.data;
        setState(() {
          tareaArrastrada.estado = estadoDeLaColumna;
        });
        _guardarTareas();
      },

      builder: (context, candidateData, rejectedData) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.85, 
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(
            color: assignarColorEstado(estadoDeLaColumna),
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
              
              // LISTA DE TAREAS
              Expanded(
                child: ListView.builder(
                  itemCount: tareasFiltradas.length,
                  itemBuilder: (context, index) {
                    Tarea tareaActual = tareasFiltradas[index];
                    return DragTarget<Tarea>(
                      onAcceptWithDetails: (detalles) {
                        Tarea arrastrada = detalles.data;
                        
                        // Solo reordenamos si no estamos soltando la tarea sobre sí misma
                        if (arrastrada != tareaActual) {
                          _reordenarTarea(arrastrada, tareaActual);
                        }
                      },

                      builder: (context, candidateData, rejectedData) {
                        return Draggable(
                          data: tareaActual,
                          feedback: Material(
                            elevation: 6,
                            color: Colors.transparent,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8, // Ancho columna (No completa para que se vea la siguiente)
                              child: _construirTarea(tareaActual, index),
                            ),
                          ),
                          onDragUpdate: (DragUpdateDetails detalles) {
                            _comprobarBordes(detalles.globalPosition);
                          },
                          onDragEnd: (DraggableDetails detalles) {
                            _detenerAutoScroll();
                          },
                          onDraggableCanceled: (Velocity velocidad, Offset offset) {
                            _detenerAutoScroll();
                          },

                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _construirTarea(tareaActual, index),
                          ),
                          child: _construirTarea(tareaActual, index), 
                        );
                      }
                    );
                  },
                ),
              )
            ],
          ),
        );
      }
    );
    
  }
  
  Widget _construirTarea(Tarea tarea, int index){
    return  Card(
      key: ValueKey(misTareas[index]),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(

        title: Text(
          tarea.nombre,
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tarea.fechaLimite != null ? Text("${tarea.fechaLimite!.day}/${tarea.fechaLimite!.month}/${tarea.fechaLimite!.year}",) : Text(""),
            Text(assignarPrioridad(tarea), style: TextStyle(
              color: assignarColorPrioridad(tarea)
            ),)
          ],
        ),
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
  }
  
  
  void _iniciarAutoScroll(int direccion) {
    // Si ya se está moviendo, no hacemos nada
    if (_scrollTimer != null && _scrollTimer!.isActive) return; 

    // Cada 50 milisegundos, movemos la pantalla un poco
    _scrollTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      // Calculamos la nueva posición (15 píxeles por cada "tic" del reloj)
      double nuevaPosicion = _scrollController.offset + (15.0 * direccion);

      // Evitamos superar los limites
      if (nuevaPosicion < 0) nuevaPosicion = 0;
      if (nuevaPosicion > _scrollController.position.maxScrollExtent) {
        nuevaPosicion = _scrollController.position.maxScrollExtent;
      }

      // Le decimos al controlador que salte a la nueva posición
      _scrollController.jumpTo(nuevaPosicion);
    });
  }

  void _detenerAutoScroll() {
    _scrollTimer?.cancel();
  }

  // Comprobamos donde esta el dedo
  void _comprobarBordes(Offset posicionDelDedo) {
    final anchoPantalla = MediaQuery.of(context).size.width;
    final zonaSensible = 70.0; // Píxeles de margen en los bordes

    if (posicionDelDedo.dx > anchoPantalla - zonaSensible) {
      // Dedo en el borde derecho -> Movemos hacia adelante
      _iniciarAutoScroll(1);
    } else if (posicionDelDedo.dx < zonaSensible) {
      // Dedo en el borde izquierdo -> Movemos hacia atrás
      _iniciarAutoScroll(-1);
    } else {
      _detenerAutoScroll();
    }
  }
  
  void _reordenarTarea(Tarea tareaArrastrada, Tarea tareaObjetivo) {
    setState(() {
      // Cambiamos el estado de la tarea arrastrada por si viene de otra columna distinta
      tareaArrastrada.estado = tareaObjetivo.estado;

      misTareas.remove(tareaArrastrada);      
      int indiceTareaObj = misTareas.indexOf(tareaObjetivo);
      misTareas.insert(indiceTareaObj, tareaArrastrada);
    });
    
    _guardarTareas();
  }
  // -------------------

  @override
  void initState() {
    super.initState(); // Llamamos al "super"

    _leerTareas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tareas'),
        titleTextStyle: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.bold
        ),
        backgroundColor: Colors.purple[800],
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormTarea,
        child: Icon(Icons.add),
      ),
      backgroundColor: Colors.grey[850],
      body: ListView(
        scrollDirection: Axis.horizontal, 
        controller: _scrollController,
        
        children: [
          // Construimos las 4 diferentes columnas segun el estado
          _construirColumna("Backlog", EstadoTarea.backlog),
          _construirColumna("En Progreso", EstadoTarea.enProgreso),
          _construirColumna("Completado", EstadoTarea.completado),
          _construirColumna("Bloqueado", EstadoTarea.bloqueado),
        ],
      ),
    );
  }
}