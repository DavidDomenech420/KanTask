import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterScreen> {
  TextEditingController nameText = TextEditingController();
  TextEditingController emailText = TextEditingController();
  TextEditingController passwordText = TextEditingController();

  void _signUp() async {
    String name = nameText.text.trim();
    String email = emailText.text.trim();
    String password = passwordText.text.trim();
    try {
      await Supabase.instance.client.auth.signUp(password: password, email: email, data: {'name':name});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("¡Registro completo! Revisa tu bandeja de entrada")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al registrarse")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: Center(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 30.0),
            color: Colors.white.withValues(alpha: 0.9),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  Text("KanTask", style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[400]
                  ),),
                  SizedBox(height: 50),
                  Column(
                    children: [
                      TextField(
                        controller: nameText,
                        decoration: InputDecoration(hintText: "Nombre Usuario",hintStyle: TextStyle(fontWeight: FontWeight.normal)),
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 30),
                      TextField(
                        controller: emailText,
                        decoration: InputDecoration(hintText: "Correo electronico",hintStyle: TextStyle(fontWeight: FontWeight.normal)),
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 30),
                      TextField(
                        controller: passwordText,
                        decoration: InputDecoration(hintText: "Contraseña",hintStyle: TextStyle(fontWeight: FontWeight.normal)),
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _signUp,
                        child: Text("Entrar", style: TextStyle(
                          fontSize: 18
                        ),)
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {Navigator.pop(context);}, 
                        child: Text("Volver al login")
                        )
                    ],
                  )
                  
                ],
              ),
            )
          )
          
        )
      
    );
  }
}