import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'fcm_notification_service.dart';
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
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'action_juice',
              '🧃 Registar 15g Sumo',
              showsUserInterface: true,
            ),
          ],
        );
        var platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

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

  try {
    // Lê automaticamente o android/app/google-services.json (e GoogleService-Info.plist no iOS)
    await Firebase.initializeApp().timeout(const Duration(seconds: 5));
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    debugPrint("✅ FIREBASE LIGADO COM SUCESSO!");
  } catch (e) {
    debugPrint("⚠️ Erro ou timeout ao iniciar Firebase: $e");
  }

  // Arranca a interface IMEDIATAMENTE para nunca ficar presa no ecrã branco
  runApp(const SmartGlycoApp());

  // Inicializa o FCM e o Workmanager em segundo plano sem bloquear a UI
  _initBackgroundServices();
}

Future<void> _initBackgroundServices() async {
  try {
    await FcmNotificationService.instance.init();
    debugPrint("✅ FCM NOTIFICATIONS PRONTO!");
  } catch (e) {
    debugPrint("⚠️ Erro ao iniciar FCM: $e");
  }

  try {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
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
  } catch (e) {
    debugPrint("⚠️ Erro ao iniciar Workmanager: $e");
  }
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
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}