import 'package:camera/camera.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

List<CameraDescription> cameras = [];
final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
final LocalAuthentication biometricAuth = LocalAuthentication(); 

// GLOBAL VARIABLES
double globalIcr = 15.0;   
double globalIsf = 50.0;   
double globalTarget = 100.0; 
List<Map<String, dynamic>> globalDiary = [];
bool isFirstTime = true; 
bool isLoggedIn = false; 
bool askedForNotifications = false; 
bool useBiometricsGlobal = false; 

Future<void> loadData() async {
  final prefs = await SharedPreferences.getInstance();
  globalIcr = prefs.getDouble('icr') ?? 15.0;
  globalIsf = prefs.getDouble('isf') ?? 50.0;
  globalTarget = prefs.getDouble('target') ?? 100.0;
  isFirstTime = prefs.getBool('isFirstTime') ?? true;
  isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  askedForNotifications = prefs.getBool('askedForNotifications') ?? false;
  useBiometricsGlobal = prefs.getBool('useBiometrics') ?? false; 

  final String? diaryString = prefs.getString('diary');
  if (diaryString != null) {
    globalDiary = (jsonDecode(diaryString) as List).map((e) => Map<String, dynamic>.from(e)).toList();
  } else {
    globalDiary = [
      {'title': 'Almoço: Bife', 'carbs': 45.0, 'insulin': 3.5, 'time': '13:00', 'type': 'meal', 'imagePath': null},
      {'title': 'Correção', 'carbs': 0.0, 'insulin': 2.0, 'time': '10:30', 'type': 'correction', 'imagePath': null},
    ];
  }
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
  await prefs.setString('diary', jsonEncode(globalDiary));
}