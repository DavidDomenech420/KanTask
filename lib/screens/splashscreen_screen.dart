import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> {

  Future<void> _comprobarSesion() async {
    await Future.delayed(Duration(seconds: 2));

    final sesionActual = Supabase.instance.client.auth.currentSession;

    if (!mounted) {
      return;
    }

    if (sesionActual == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
    else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ListaTareas()));
    }
  }
  @override
  void initState() {
    super.initState();
    
    _comprobarSesion();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}