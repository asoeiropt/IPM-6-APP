import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
        
        var android = const AndroidInitializationSettings('@mipmap/launcher_icon');
        var settings = InitializationSettings(android: android);
        
        await flip.initialize(settings);

        var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
          'cgm_alerts_channel', 
          'CGM Alerts', 
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFFF43F5E),
          enableVibration: true,
        );
        var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

        // Os 4 argumentos passados DIRETAMENTE, sem qualquer texto/nome antes
        await flip.show(
          0,
          '🚨 Alerta Preditivo (CGM)',
          'A tua glicose desceu para $simulatedGlucose mg/dL. Ingere hidratos rápidos!',
          platformChannelSpecifics,
        );
      }
    }
    return Future.value(true); // Indica ao Android que a task teve sucesso
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // Mantém-se true para disparar logo a notificação de teste
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