import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './register_screen.dart';
import './home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  TextEditingController emailText = TextEditingController();
  TextEditingController passwordText = TextEditingController();

  void _iniciarSesion() async {
    String email = emailText.text.trim();
    String password = passwordText.text.trim();
    try {
      await Supabase.instance.client.auth.signInWithPassword(password: password, email: email);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ListaTareas()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al inciar sesion")));
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
                        onPressed: _iniciarSesion,
                        child: Text("Entrar", style: TextStyle(
                          fontSize: 18
                        ),)
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                        }, 
                        child: Text("¿No tienes cuenta? Registrate")
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