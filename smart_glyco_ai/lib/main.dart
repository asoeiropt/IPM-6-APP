import 'package:flutter/material.dart';
import 'startup_screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartGlycoApp());
}

class SmartGlycoApp extends StatelessWidget {
  const SmartGlycoApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartGlycoAI',
      debugShowCheckedModeBanner: false, 
      themeMode: ThemeMode.dark, // Força o tema escuro que criámos
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A), // Cor de fundo base
        useMaterial3: true,
      ),
      home: const SplashScreen(), 
    );
  }
}