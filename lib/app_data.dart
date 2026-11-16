import 'dart:convert';
import 'dart:core';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';

List<CameraDescription> cameras = [];
final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
final LocalAuthentication biometricAuth = LocalAuthentication(); 

// GLOBAL VARIABLES
double globalIcr = 15.0;   
double globalIsf = 50.0;   
double globalTarget = 100.0; 
// 1. Tipagem forte para evitar crashs
List globalDiary = [];
// 2. NOVA LISTA para o gráfico (simula os dados de um sensor)
List globalGlucose = []; 

bool isFirstTime = true; 
bool isLoggedIn = false; 
bool askedForNotifications = false; 
bool useBiometricsGlobal = false; 
bool isHighContrast = false; // <-- NOVA VARIÁVEL DE ACESSIBILIDADE

// ==========================================
// MOTOR DE NOTIFICAÇÕES ACIONÁVEIS (IPM)
// ==========================================
Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await notificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.actionId == 'action_juice') {
        HapticFeedback.heavyImpact();
        
        final now = DateTime.now();
        final safeTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

        // Regista automaticamente os 15g de hidratos (Regra dos 15)
        globalDiary.insert(0, {
          'title': '🧃 Sumo de Resgate (IA)', 
          'carbs': 15.0, 
          'insulin': 0.0, 
          'time': safeTime, 
          'type': 'correction', 
          'imagePath': null,
          'tags': ['⚠️ Hipo Acionada'] 
        });
        
        await saveData();
        debugPrint("✅ 15g de Sumo registados pela notificação!");
      }
    },
  );
}

Future<void> triggerHypoAlert() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'hypo_channel',
    'Hypoglycemia Alerts',
    channelDescription: 'Alertas preditivos de IA',
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
      AndroidNotificationAction(
        'action_ignore', 
        'Ignorar',
        showsUserInterface: true,
      ),
    ],
  );

  const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

  await notificationsPlugin.show(
    0,
    '🚨 Alerta Preditivo (CGM)',
    'Glicemia em queda acentuada (⬇️ 68 mg/dL estimados em 10m). Toma hidratos rápidos!',
    platformDetails,
  );
}

// ==========================================
// MOTOR MATEMÁTICO: INSULIN ON BOARD (IOB)
// ==========================================
double calculateIOB() {
  double totalIOB = 0.0;
  final now = DateTime.now();

  for (var entry in globalDiary) {
    double insulin = double.tryParse(entry['insulin'].toString()) ?? 0.0;
    if (insulin <= 0) continue;

    String timeStr = entry['time'] ?? '00:00';
    List<String> parts = timeStr.split(':');
    if (parts.length != 2) continue;

    int hour = int.tryParse(parts[0]) ?? 0;
    int minute = int.tryParse(parts[1]) ?? 0;

    DateTime entryTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (entryTime.isAfter(now)) {
      entryTime = entryTime.subtract(const Duration(days: 1));
    }

    int elapsedMinutes = now.difference(entryTime).inMinutes;

    if (elapsedMinutes >= 0 && elapsedMinutes < 240) {
      totalIOB += insulin * (1 - (elapsedMinutes / 240));
    }
  }
  return totalIOB;
}

Future<void> loadData() async {
  final prefs = await SharedPreferences.getInstance();
  globalIcr = prefs.getDouble('icr') ?? 15.0;
  globalIsf = prefs.getDouble('isf') ?? 50.0;
  globalTarget = prefs.getDouble('target') ?? 100.0;
  isFirstTime = prefs.getBool('isFirstTime') ?? true;
  isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  askedForNotifications = prefs.getBool('askedForNotifications') ?? false;
  useBiometricsGlobal = prefs.getBool('useBiometrics') ?? false; 
  isHighContrast = prefs.getBool('isHighContrast') ?? false; 

  final String? diaryString = prefs.getString('diary');
  if (diaryString != null) {
    globalDiary = (jsonDecode(diaryString) as List).map((e) => Map<String, dynamic>.from(e)).toList();
  } else {
    globalDiary = [];
  }

  final String? glucoseString = prefs.getString('glucose');
  if (glucoseString != null) {
    globalGlucose = (jsonDecode(glucoseString) as List).map((e) => Map<String, dynamic>.from(e)).toList();
  } else {
    final now = DateTime.now();
    globalGlucose = [
      {'time': now.subtract(const Duration(minutes: 60)).toIso8601String(), 'value': 110.0},
      {'time': now.subtract(const Duration(minutes: 50)).toIso8601String(), 'value': 115.0},
      {'time': now.subtract(const Duration(minutes: 40)).toIso8601String(), 'value': 130.0},
      {'time': now.subtract(const Duration(minutes: 30)).toIso8601String(), 'value': 145.0},
      {'time': now.subtract(const Duration(minutes: 20)).toIso8601String(), 'value': 135.0},
      {'time': now.subtract(const Duration(minutes: 10)).toIso8601String(), 'value': 115.0},
      {'time': now.toIso8601String(), 'value': 112.0},
    ];
  }

  String currentGlucose = globalGlucose.isNotEmpty ? globalGlucose.last['value'].toInt().toString() : '---';
  await updateHomeWidget(currentGlucose, '➡️', calculateIOB().toStringAsFixed(1));
}

Future<void> saveData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('icr', globalIcr);
  await prefs.setDouble('isf', globalIsf);
  await prefs.setDouble('target', globalTarget);
  await prefs.setBool('isFirstTime', isFirstTime);
  await prefs.setBool('isLoggedIn', isLoggedIn);
  await prefs.setBool('askedForNotifications', askedForNotifications);
  await prefs.setBool('useBiometrics', useBiometricsGlobal); 
  await prefs.setBool('isHighContrast', isHighContrast); 
  
  await prefs.setString('diary', jsonEncode(globalDiary));
  await prefs.setString('glucose', jsonEncode(globalGlucose)); 

  String currentGlucose = globalGlucose.isNotEmpty ? globalGlucose.last['value'].toInt().toString() : '---';
  await updateHomeWidget(currentGlucose, '➡️', calculateIOB().toStringAsFixed(1));
}

Future<void> updateHomeWidget(String glucose, String trend, String iob) async {
  await HomeWidget.saveWidgetData<String>('glucose_val', glucose);
  await HomeWidget.saveWidgetData<String>('trend_val', trend);
  await HomeWidget.saveWidgetData<String>('iob_val', 'IOB: $iob U');
  
  await HomeWidget.updateWidget(
    name: 'GlycoWidgetProvider', 
    iOSName: 'GlycoWidget', 
  );
}