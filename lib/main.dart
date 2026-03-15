import 'dart:async';

import 'package:todo_list/data/tablero.dart';

import 'data/tarea.dart';
import './screens/login_screen.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!, 
  );


  runApp(MaterialApp(home: LoginScreen()));
}


