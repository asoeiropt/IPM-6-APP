import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart'; // <-- Import do Firebase
import 'startup_screens.dart'; 

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "cgm_sync_task") {
      debugPrint("====================================================");
      debugPrint("🔄 CGM BACKGROUND TASK: A ler sensor...");
      
      int simulatedGlucose = 65; 
      
      if (simulatedGlucose < 70) {
        debugPrint("🚨 ALERTA PREDITIVO: Glicose a $simulatedGlucose mg/dL!");
        debugPrint("====================================================");
        
        FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();
        
        var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
        var settings = InitializationSettings(android: android);
        
        await flip.initialize(settings);

        var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
          'cgm_alerts_channel', 
          'CGM Alerts', 
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFFF43F5E),
          enableVibration: true,
          // --- AÇÃO CONTEXTUAL (IPM: Eficiência e Flexibilidade) ---
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'action_juice', 
              '🧃 Registar 15g Sumo', 
              showsUserInterface: true, 
            ),
          ],
        );
        var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

        await flip.show(
          0,
          '🚨 Alerta Preditivo (CGM)',
          'A tua glicose desceu para $simulatedGlucose mg/dL. Ingere hidratos rápidos!',
          platformChannelSpecifics,
        );
      }
    }
    return Future.value(true); 
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // <-- LIGAÇÃO AO FIREBASE COM AS TUAS CHAVES
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDsnKprN107vKBUOFIDcILMI_Pd7NGjTJ0",
      authDomain: "smartglycoai.firebaseapp.com",
      projectId: "smartglycoai",
      storageBucket: "smartglycoai.firebasestorage.app",
      messagingSenderId: "358595848241",
      appId: "1:358595848241:web:40a050e8b4ab48f1204d10",
    ),
  );

  debugPrint("✅ FIREBASE LIGADO COM SUCESSO! A base de dados está pronta.");

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, 
  );

  await Workmanager().registerPeriodicTask(
    "cgm_sync_task_1",
    "cgm_sync_task",
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.notRequired,
      requiresBatteryNotLow: false,
    ),
  );

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.light), 
        useMaterial3: true
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark), 
        useMaterial3: true
      ),
      home: const SplashScreen(), 
    );
  }
}