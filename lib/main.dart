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
      themeMode: ThemeMode.system, 
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.light), useMaterial3: true),
      darkTheme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark), useMaterial3: true),
      home: const SplashScreen(), 
    );
  }
}