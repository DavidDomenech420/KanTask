import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: ListaTareas()));
}

class ListaTareas extends StatefulWidget {
  @override
  _ListaTareasState createState() => _ListaTareasState();
}

class _ListaTareasState extends State<ListaTareas> {
  
  // --- ZONA LÓGICA ---
  
  List<String> misTareas = [];
  TextEditingController controlador = TextEditingController();

  // TODO: Completa esta función
  void agregarTarea() {
    // 1. Usamos setState para que la pantalla se actualice
    setState(() {
      // 2. Añadir a la lista. 
      misTareas.add(controlador.text);
    
      // 3. Limpiar el input.
      controlador.clear();

    });
  }
  // -------------------

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
                Expanded(
                  child: TextField(controller: controlador,),
                ),
                
                SizedBox(width: 10),
                
                ElevatedButton(
                  // TODO: Aquí ya no queremos el print.
                  onPressed: agregarTarea,
                  child: Text('Guardar'),
                ),
              ],
            ),
          ),

          // Aquí abajo pondremos la lista después. Por ahora dejémoslo vacío.
          Expanded(
            child: ListView.builder(
              // TODO 1: Dile al constructor cuántos elementos hay en total.
              itemCount: misTareas.length,

              // Este constructor se ejecuta una vez por cada tarea.
              // 'index' es la posición (0, 1, 2, 3...)
              itemBuilder: (context, index) {
                
                // TODO 2: Obtén el texto de la tarea actual.
                final tareaActual = misTareas[index]; // <--- CAMBIA ESTO

                // Aquí devolvemos el diseño de la fila.
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    leading: Icon(Icons.check_circle_outline, color: Colors.deepPurple[400]),
                    
                    // Aquí mostramos el texto que recuperaste arriba
                    title: Text(tareaActual),

                    // TRAILING: Es la parte derecha del ListTile (perfecto para botones de acción)
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // TODO: Aquí ocurre la magia del borrado.
                        
                        // 1. Necesitamos setState para avisar a la pantalla.
                        setState(() {
                           // 2. Borra el elemento usando 'index'.
                           misTareas.removeAt(index);
                           
                        });
                      },
                    ),
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