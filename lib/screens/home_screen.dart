import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo_list/data/tablero.dart';
import 'package:todo_list/screens/login_screen.dart';

import '../data/tarea.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ListaTareas extends StatefulWidget {
  @override
  _ListaTareasState createState() => _ListaTareasState();
}


class _ListaTareasState extends State<ListaTareas> {
  // --- ZONA LÓGICA ---

  List<Tarea> tareasTablero = [];
  List<Tablero> misTableros = [];
  Tablero? tableroActual;
  String userId = Supabase.instance.client.auth.currentUser!.id;

  TextEditingController controlador = TextEditingController();
  DateTime? fechaSeleccionada;
  int prioridadSeleccionada = 0;
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  void _cerrarSesion() async {
    await GoogleSignIn.instance.signOut();

    await Supabase.instance.client.auth.signOut();

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()),(route) => false);
  }

  void _cargarTableros() async {
    var tableros = await Supabase.instance.client.from('board').select();
    List<Tablero> tablerosTipados = tableros.map((diccionario) {
        return Tablero.fromJson(diccionario);
      }).toList();
    setState(() {
      if (tablerosTipados.isNotEmpty) {
        misTableros = tablerosTipados;
        tableroActual = misTableros.first;
        _cargarTareas();
      }
    });
  }

  void _crearTablero() async {
    Map<String, dynamic> nuevoTablero = {
      'name': controlador.text,
      'user_id': userId,
    };

    await Supabase.instance.client.from('board').insert(nuevoTablero);
    _cargarTableros();
  }

  void _actualizarTablero(int? boardId) async {
    Map<String, dynamic> tableroActualizado = {
      'name': controlador.text,
    };

    await Supabase.instance.client.from('board').update(tableroActualizado).eq('id', boardId!);
    _cargarTableros();
  }

  void _eliminarTablero(int? boardId) async {
    await Supabase.instance.client.from("board").delete().eq("id", boardId!);
    tableroActual = misTableros.first;
    _cargarTableros();
  }

  void _cargarTareas() async {
    if (tableroActual != null) {
      int? boardId = tableroActual?.id;
      final List<dynamic> tareas = await Supabase.instance.client.from('task').select().eq('board_id', boardId!);
      List<Tarea> tareasTipadas = tareas.map((diccionario) {
        return Tarea.fromJson(diccionario);
      }).toList();
      setState(() {
        tareasTablero = tareasTipadas;
      });
    }
  }

  void _crearTarea(EstadoTarea estadoTarea) async {
    Map<String, dynamic> nuevaTarea = {
      'title': controlador.text,
      'due_date': fechaSeleccionada?.toIso8601String(),
      'priority': prioridadSeleccionada,
      'status': estadoTarea.name, 
      'board_id': tableroActual?.id,
      'user_id': userId,
    };

    await Supabase.instance.client.from('task').insert(nuevaTarea);
    _cargarTareas();
  }

  void _actualizarTarea(int? taskId) async {
    Map<String, dynamic> tareaActualizada = {
      'title': controlador.text,
      'due_date': fechaSeleccionada?.toIso8601String(),
      'priority': prioridadSeleccionada,
    };

    await Supabase.instance.client.from('task').update(tareaActualizada).eq('id', taskId!);
    _cargarTareas();
  }

  void _cambiarEstado(Tarea tareaArrastrada, EstadoTarea estadoDeLaColumna) async {
     Map<String, dynamic> estado = {
      'status': estadoDeLaColumna.name 
    };
    await Supabase.instance.client.from('task').update(estado).eq('id', tareaArrastrada.id!);
    _cargarTareas();
  }

  void _eliminarTarea(int? taskId) async {
    await Supabase.instance.client.from("task").delete().eq("id", taskId!);
    _cargarTareas();
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


  void _preguntarBorrado(int? id, bool esTarea) {
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
                if(esTarea){
                  _eliminarTarea(id);
                }
                else{
                  _eliminarTablero(id);
                }
                Navigator.of(context).pop();

              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarFormTarea(EstadoTarea estadoDeLaColumna, {int? posTarea}) {
    fechaSeleccionada = null;
    prioridadSeleccionada = 0;
    
    final Map<int, String> etiquetasPrioridad = {
      0: 'Sin prioridad',
      1: 'Prioridad baja',
      2: 'Prioridad media',
      3: 'Prioridad alta',
    };
    controlador.text = "";
    if (posTarea != null) {
      Tarea tarea = tareasTablero[posTarea];
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
              title: posTarea != null? Text('Actualizar Tarea') : Text('Tarea Nueva'),
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
                      _actualizarTarea(tareasTablero[posTarea].id);
                    }
                    else {
                      _crearTarea(estadoDeLaColumna);
                    }
                    // Limpiar el input.
                    controlador.clear();
                    fechaSeleccionada = null;
                    Navigator.of(context).pop();
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

  void _mostrarFormTablero(bool actualizar, {Tablero? tablero}) {
    controlador.text="";
    if (actualizar) {
      controlador.text=tablero!.nombre;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDelDialogo) {
            return AlertDialog(
              title: actualizar ? Text('Actualizar Tablero') : Text('Tablero Nuevo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controlador,
                    decoration: InputDecoration(
                      labelText: "Nombre del tablero",
                    ),
                  ),
                  SizedBox(height: 20),

                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if(actualizar){
                      _actualizarTablero(tablero!.id);
                    }
                    else{
                      _crearTablero();
                    }
                    
                    // Limpiar el input.
                    controlador.clear();
                    fechaSeleccionada = null;
                    Navigator.of(context).pop();
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
  
  List<Tarea> _filtrarTareas(EstadoTarea estadoBuscado) {
    return tareasTablero.where((tarea) => tarea.estado == estadoBuscado).toList();
  }
  

  Widget _construirColumna(String titulo, EstadoTarea estadoDeLaColumna) {
    List<Tarea> tareasFiltradas = _filtrarTareas(estadoDeLaColumna);

    return DragTarget(

      onAcceptWithDetails: (DragTargetDetails<Tarea> detalles){
        Tarea tareaArrastrada = detalles.data;
        _cambiarEstado(tareaArrastrada, estadoDeLaColumna);
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
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
                child: TextButton.icon(
                  onPressed: () {
                    // TU MISIÓN: Llama a tu función para abrir el formulario
                    _mostrarFormTarea(estadoDeLaColumna); 
                  },
                  icon: Icon(Icons.add, color: Colors.black, size: 25,),
                  label: Text("Añadir tarea", style: TextStyle(color: Colors.black, fontSize: 18)),
                  
                  style: TextButton.styleFrom(
                    // Esto hace que el botón ocupe todo el ancho de la columna
                    minimumSize: Size(double.infinity, 50), 
                    alignment: Alignment.centerLeft, // Alineamos el texto a la izquierda
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    backgroundColor: const Color.fromARGB(106, 14, 14, 14)
                  ),
                ),
              ),              
            ],
          ),
        );
      }
    );
    
  }
  
  Widget _construirTarea(Tarea tarea, int index){
    return  Card(
      key: ValueKey(tareasTablero[index]),
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
            _preguntarBorrado(tarea.id, true);
          },
        ),

        onTap: () {
          _mostrarFormTarea(posTarea: tareasTablero.indexOf(tarea), tarea.estado);
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

      tareasTablero.remove(tareaArrastrada);      
      int indiceTareaObj = tareasTablero.indexOf(tareaObjetivo);
      tareasTablero.insert(indiceTareaObj, tareaArrastrada);
    });
    
  }
  // -------------------

  @override
  void initState() {
    super.initState(); // Llamamos al "super"
    _cargarTableros();

    
  }

  @override
  Widget build(BuildContext context) {
    if(tableroActual == null){
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    else {
      return Scaffold(
        appBar: AppBar(
          title: Text(tableroActual!.nombre),
          titleTextStyle: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold
          ),
          backgroundColor: Colors.purple[800],
          actions: [
            PopupMenuButton<String>(
              iconColor: Colors.white,
              onSelected: (String opcion) {
                if (opcion == "salir") {
                  _cerrarSesion();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'salir',
                    child: Text('Cerrar Sesión'),
                  ),
                ];
              },
            )
          ],
        ),
        backgroundColor: Colors.grey[850],
        drawer: Drawer(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  "Mis tableros", 
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold
                    
                  ),
                ),
              ),
              
              Expanded(
                child: ListView.builder(
                  itemCount: misTableros.length,
                  itemBuilder: (context, index) {
                    // Obtenemos el tablero actual del bucle
                    var tablero = misTableros[index]; 
                    
                    return ListTile(
                      leading: Icon(Icons.dashboard),
                      title: Text(tablero.nombre), 
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.black),
                            onPressed: () {
                              _mostrarFormTablero(true, tablero: tablero);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: misTableros.length == 1 ? Colors.grey[700] : Colors.red),
                            onPressed: () {
                              if (misTableros.length > 1) {
                                _preguntarBorrado(tablero.id, false);
                                
                              }
                            },
                          ),
                        ],
                      ),
                      
                      onTap: () {
                        setState(() {
                          tableroActual = tablero;
                          _cargarTareas();
                          Navigator.pop(context);
                        });
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _mostrarFormTablero(false);
                  },
                  icon: Icon(Icons.add, color: Colors.black, size: 25,),
                  label: Text("Añadir tablero", style: TextStyle(color: Colors.black, fontSize: 18)),
                  
                  style: TextButton.styleFrom(
                    // Esto hace que el botón ocupe todo el ancho de la columna
                    minimumSize: Size(double.infinity, 50), 
                    alignment: Alignment.centerLeft, // Alineamos el texto a la izquierda
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    backgroundColor: const Color.fromARGB(106, 14, 14, 14)
                  ),
                ),
              ),
            ],
          )
          
        ),
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
  
  
}

