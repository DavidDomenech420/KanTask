import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


// Solo necesita recibir el ID del tablero al nacer
class PanelInvitadosPopUp extends StatefulWidget {
  final int boardId; 
  final String userId;
  const PanelInvitadosPopUp({Key? key, required this.boardId, required this.userId}) : super(key: key);

  @override
  State<PanelInvitadosPopUp> createState() => _PanelInvitadosPopUpState();
}

class _PanelInvitadosPopUpState extends State<PanelInvitadosPopUp> {
  
  List<Map<String, dynamic>> listaUsuarios = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios(); // Se ejecuta solo, nada más abrirse el PopUp
  }

  void _invitarUsuarioTablero(TextEditingController controladorEmail) async {
    if(controladorEmail.text.trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El correo tiene que estar lleno')),
      );
      return;
    }

    Map<String, dynamic> nuevaInvitacion = {
      'board_id': widget.boardId,
      'email': controladorEmail.text,
      'invited_by': widget.userId,
    };

    await Supabase.instance.client.from('board_invites').insert(nuevaInvitacion);
    controladorEmail.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invitación enviada')),
    );

  }
  Future<void> _cargarUsuarios() async {
    
    final respuesta = await Supabase.instance.client.rpc(
      'obtener_invitados_tablero', 
      params: {'p_board_id': widget.boardId}
    );

    if (!mounted) return; 

    setState(() {
      listaUsuarios = List<Map<String, dynamic>>.from(respuesta);
      cargando = false;
    });
  }

  Future<void> _eliminarUsuario(String id, String estado) async {
    try {
      if (estado == 'pendiente') {
        await Supabase.instance.client.from('board_invites').delete().eq('id', id);
      } else {
        await Supabase.instance.client.rpc(
        'eliminar_miembro_tablero',
        params: {
          'p_board_id': widget.boardId,
          'p_user_id': id
        }
      );
      }
      // Volvemos a cargar la lista para que desaparezca visualmente
      _cargarUsuarios(); 
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controladorEmail = TextEditingController();
    return AlertDialog(
      title: const Text('Administrar Usuarios'),
      content: cargando 
          ? const CircularProgressIndicator() // Si carga, mostramos una ruedita
          : Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controladorEmail,
                          decoration: InputDecoration(
                            labelText: "correo del usuario",
                          ),
                        )
                      ),

                      IconButton(
                        onPressed: () {
                          _invitarUsuarioTablero(controladorEmail);
                        }, 
                        icon: Icon(Icons.send_rounded)
                      )
                    ],
                  ),
                  SizedBox(height: 20,),
                  Divider(height: 10,
                  thickness: 1,
                  color: Colors.black45,),
                  SizedBox(height: 10,),
                  Text("Usuarios Invitados", style: TextStyle(
                    fontSize: 18,
                    decoration: TextDecoration.underline
                  ),),
                  SizedBox(
                    width: double.maxFinite,
                    height: 150,
                    child: ListView(
                      children: listaUsuarios.map((usuario) {
                        return ListTile(
                          leading: const Icon(Icons.account_circle, color: Colors.purple),

                          title: Text(
                            usuario['email'] , 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                          ),
                          
                          subtitle: Text(
                            usuario['estado'] == 'pendiente' ? 'Pendiente de aceptar' : 'Ya es miembro',
                            style: TextStyle(
                              color: usuario['estado'] == 'pendiente' ? Colors.orange : Colors.green,
                            ),
                          ),

                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _eliminarUsuario(usuario['id'], usuario['estado']);
                            },
                          ),
                        );
                      }).toList()
                    ),
                  )
                ],
              ),
            ),
    );
  }
}