import 'dart:convert';
import 'dart:core';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';

List<CameraDescription> cameras = [];
final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();
final LocalAuthentication biometricAuth = LocalAuthentication();

// GLOBAL VARIABLES
double globalIcr = 15.0;
double globalIsf = 50.0;
double globalTarget = 100.0;

List globalDiary = [];
List globalGlucose = [];

bool isFirstTime = true;
bool isLoggedIn = false;
bool askedForNotifications = false;
bool useBiometricsGlobal = false;
bool isHighContrast = false;
bool useBiometrics = false;

// --- VARIÁVEIS DE IDENTIDADE E PERFIL (FIREBASE & LOCAL) ---
String currentUserId = '';
String currentUserName = '';
String currentUserEmail = '';
String currentUserPhone = '';
String currentUserDob = '';
String currentDiabetesType = 'Diabetes Tipo 1';
String currentDiagnosisYear = '';

// --- IDIOMA GLOBAL (PT / EN) ---
bool isPortuguese = false;
String tr(String pt, String en) => isPortuguese ? pt : en;

// ==========================================
// SEED DE UTILIZADORES DE DEMONSTRAÇÃO NO FIRESTORE
// ==========================================
Future<void> seedDemoUsersIfMissing() async {
  final firestore = FirebaseFirestore.instance;
  final usersCol = firestore.collection('users');
  final apptCol = firestore.collection('appointments');

  final Map<String, Map<String, dynamic>> demoAccounts = {
    'paciente_joao': {
      'name': 'João Antunes',
      'email': 'joao@smartglyco.pt',
      'password': '123',
      'phone': '+351 912 345 678',
      'dob': '15/08/1998',
      'diabetesType': 'Type 1 Diabetes',
      'diagnosisYear': '2021',
      'role': 'patient',
      'initials': 'JA',
      'icr': 15.0,
      'isf': 50.0,
    },
    'paciente_maria': {
      'name': 'Maria Silva',
      'email': 'maria@smartglyco.pt',
      'password': '123',
      'phone': '+351 963 852 741',
      'dob': '22/03/1995',
      'diabetesType': 'Type 1 Diabetes',
      'diagnosisYear': '2019',
      'role': 'patient',
      'initials': 'MS',
      'icr': 12.0,
      'isf': 45.0,
    },
    'medica_joana': {
      'name': 'Dra. Joana Sílvia',
      'email': 'joana@smartglyco.pt',
      'password': '123',
      'phone': '+351 217 805 000',
      'dob': '12/04/1984',
      'diabetesType': 'Type 1 Diabetes',
      'diagnosisYear': '',
      'role': 'doctor',
      'initials': 'JS',
    },
  };

  for (final entry in demoAccounts.entries) {
    try {
      final docRef = usersCol.doc(entry.key);
      final snap = await docRef.get();
      if (!snap.exists) {
        await docRef.set({
          ...entry.value,
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ Conta demo criada no Firestore: ${entry.key}');
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao verificar/criar ${entry.key} no Firestore: $e');
    }
  }

  // Garante também consultas iniciais para o João e a Maria se ainda não existirem
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  final formattedDate = DateFormat('dd/MM/yyyy').format(tomorrow);

  final Map<String, Map<String, dynamic>> demoAppointments = {
    'paciente_joao': {
      'patientId': 'paciente_joao',
      'patientName': 'João Antunes',
      'initials': 'JA',
      'date': formattedDate,
      'time': '9:30 AM',
      'type': 'Seguimento Trimestral',
      'isCompleted': false,
    },
    'paciente_maria': {
      'patientId': 'paciente_maria',
      'patientName': 'Maria Silva',
      'initials': 'MS',
      'date': formattedDate,
      'time': '11:00 AM',
      'type': 'Ajuste de Insulina',
      'isCompleted': false,
    },
  };

  for (final entry in demoAppointments.entries) {
    try {
      final apptRef = apptCol.doc(entry.key);
      final apptSnap = await apptRef.get();
      if (!apptSnap.exists) {
        await apptRef.set(entry.value);
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao criar consulta inicial para ${entry.key}: $e');
    }
  }
}

// ==========================================
// MOTOR DE NOTIFICAÇÕES ACIONÁVEIS (IPM)
// ==========================================
Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await notificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.actionId == 'action_juice') {
        HapticFeedback.heavyImpact();

        final now = DateTime.now();
        final safeTime =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

        globalDiary.insert(0, {
          'title': tr('🧃 Sumo de Resgate (IA)', '🧃 Rescue Juice (AI)'),
          'carbs': 15.0,
          'insulin': 0.0,
          'time': safeTime,
          'type': 'correction',
          'imagePath': null,
          'tags': [tr('⚠️ Hipo Acionada', '⚠️ Hypo Triggered')]
        });

        await saveData();
        debugPrint("✅ 15g de Sumo registados pela notificação!");
      }
    },
  );
}

Future<void> triggerHypoAlert() async {
  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'hypo_channel',
    tr('Alertas de Hipoglicemia', 'Hypoglycemia Alerts'),
    channelDescription:
        tr('Alertas preditivos de IA', 'AI predictive glucose alerts'),
    importance: Importance.max,
    priority: Priority.high,
    color: const Color(0xFFF43F5E),
    enableVibration: true,
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction(
        'action_juice',
        tr('🧃 Registar 15g Sumo', '🧃 Log 15g Juice'),
        showsUserInterface: true,
      ),
      AndroidNotificationAction(
        'action_ignore',
        tr('Ignorar', 'Ignore'),
        showsUserInterface: true,
      ),
    ],
  );

  final NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);

  await notificationsPlugin.show(
    0,
    tr('🚨 Alerta Preditivo (CGM)', '🚨 Predictive Alert (CGM)'),
    tr(
      'Glicemia em queda acentuada (⬇️ 68 mg/dL estimados em 10m). Toma hidratos rápidos!',
      'Rapid glucose drop detected (⬇️ est. 68 mg/dL in 10m). Take fast-acting carbs!',
    ),
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
  useBiometrics = useBiometricsGlobal;
  isHighContrast = prefs.getBool('isHighContrast') ?? false;
  isPortuguese = prefs.getBool('isPortuguese') ?? false;

  // CARREGA A IDENTIDADE E DADOS CLÍNICOS GRAVADOS
  currentUserId = prefs.getString('currentUserId') ?? '';
  currentUserName = prefs.getString('currentUserName') ?? '';
  currentUserEmail = prefs.getString('currentUserEmail') ?? '';
  currentUserPhone = prefs.getString('currentUserPhone') ?? '';
  currentUserDob = prefs.getString('currentUserDob') ?? '';
  currentDiabetesType =
      prefs.getString('currentDiabetesType') ?? 'Diabetes Tipo 1';
  currentDiagnosisYear = prefs.getString('currentDiagnosisYear') ?? '';

  final String? diaryString = prefs.getString('diary');
  if (diaryString != null) {
    globalDiary = (jsonDecode(diaryString) as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  } else {
    globalDiary = [];
  }

  final String? glucoseString = prefs.getString('glucose');
  if (glucoseString != null) {
    globalGlucose = (jsonDecode(glucoseString) as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  } else {
    final now = DateTime.now();
    globalGlucose = [
      {
        'time': now.subtract(const Duration(minutes: 60)).toIso8601String(),
        'value': 110.0
      },
      {
        'time': now.subtract(const Duration(minutes: 50)).toIso8601String(),
        'value': 115.0
      },
      {
        'time': now.subtract(const Duration(minutes: 40)).toIso8601String(),
        'value': 130.0
      },
      {
        'time': now.subtract(const Duration(minutes: 30)).toIso8601String(),
        'value': 145.0
      },
      {
        'time': now.subtract(const Duration(minutes: 20)).toIso8601String(),
        'value': 135.0
      },
      {
        'time': now.subtract(const Duration(minutes: 10)).toIso8601String(),
        'value': 115.0
      },
      {'time': now.toIso8601String(), 'value': 112.0},
    ];
  }

  String currentGlucose = globalGlucose.isNotEmpty
      ? globalGlucose.last['value'].toInt().toString()
      : '---';
  await updateHomeWidget(
      currentGlucose, '➡️', calculateIOB().toStringAsFixed(1));
}

Future<void> saveData() async {
  final prefs = await SharedPreferences.getInstance();
  useBiometricsGlobal = useBiometrics;

  await prefs.setDouble('icr', globalIcr);
  await prefs.setDouble('isf', globalIsf);
  await prefs.setDouble('target', globalTarget);
  await prefs.setBool('isFirstTime', isFirstTime);
  await prefs.setBool('isLoggedIn', isLoggedIn);
  await prefs.setBool('askedForNotifications', askedForNotifications);
  await prefs.setBool('useBiometrics', useBiometricsGlobal);
  await prefs.setBool('isHighContrast', isHighContrast);
  await prefs.setBool('isPortuguese', isPortuguese);

  // GRAVA A IDENTIDADE E DADOS CLÍNICOS NO TELEMÓVEL
  await prefs.setString('currentUserId', currentUserId);
  await prefs.setString('currentUserName', currentUserName);
  await prefs.setString('currentUserEmail', currentUserEmail);
  await prefs.setString('currentUserPhone', currentUserPhone);
  await prefs.setString('currentUserDob', currentUserDob);
  await prefs.setString('currentDiabetesType', currentDiabetesType);
  await prefs.setString('currentDiagnosisYear', currentDiagnosisYear);

  await prefs.setString('diary', jsonEncode(globalDiary));
  await prefs.setString('glucose', jsonEncode(globalGlucose));

  String currentGlucose = globalGlucose.isNotEmpty
      ? globalGlucose.last['value'].toInt().toString()
      : '---';
  await updateHomeWidget(
      currentGlucose, '➡️', calculateIOB().toStringAsFixed(1));
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