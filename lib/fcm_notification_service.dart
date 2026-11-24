import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'app_data.dart';

/// Handler obrigatório de topo para acordar o telemóvel com a app FECHADA
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint("📩 Push recebido com a app fechada: ${message.notification?.title}");
  } catch (e) {
    debugPrint("⚠️ Erro no background handler: $e");
  }
}

class FcmNotificationService {
  FcmNotificationService._();
  static final FcmNotificationService instance = FcmNotificationService._();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      await _localNotifications.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
      );

      final channel = AndroidNotificationChannel(
        'smartglyco_fcm_channel',
        tr('Mensagens Clínicas Push', 'Clinical Push Messages'),
        description: tr(
          'Notificações instantâneas entre médico e paciente',
          'Instant notifications between doctor and patient',
        ),
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Mostra banner no topo mesmo quando a app está aberta em primeiro plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null) {
          _localNotifications.show(
            DateTime.now().millisecondsSinceEpoch ~/ 1000,
            notification.title ?? 'SmartGlycoAI',
            notification.body ?? '',
            NotificationDetails(
              android: AndroidNotificationDetails(
                'smartglyco_fcm_channel',
                tr('Mensagens Clínicas Push', 'Clinical Push Messages'),
                importance: Importance.max,
                priority: Priority.high,
                color: const Color(0xFF3B82F6),
                playSound: true,
                enableVibration: true,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
          );
        }
      });

      _initialized = true;
    } catch (e) {
      debugPrint("⚠️ Erro ao inicializar FcmNotificationService: $e");
    }
  }

  /// Guarda o token deste telemóvel no Firestore ligado ao utilizador que entrou
  Future<void> registerUserDeviceToken() async {
    if (currentUserId.isEmpty) return;

    try {
      await init();

      final token =
          await _messaging.getToken().timeout(const Duration(seconds: 6));
      if (token != null) {
        await _firestore.collection('users').doc(currentUserId).set({
          'fcmToken': token,
          'name': currentUserName,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint("✅ FCM Token registado para $currentUserId");
      }

      _messaging.onTokenRefresh.listen((newToken) async {
        if (currentUserId.isNotEmpty) {
          await _firestore.collection('users').doc(currentUserId).set({
            'fcmToken': newToken,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      });
    } catch (e) {
      debugPrint("⚠️ Falha ao registar FCM Token: $e");
    }
  }

  /// Envia notificação push real para o destinatário (ex.: 'medica_joana' ou 'paciente_joao')
  Future<void> sendPushToUser({
    required String targetUserId,
    required String senderName,
    required String messageText,
  }) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(targetUserId).get();
      final targetToken = userDoc.data()?['fcmToken'] as String?;

      if (targetToken == null || targetToken.isEmpty) {
        debugPrint("⚠️ Utilizador $targetUserId ainda não tem fcmToken registado.");
        return;
      }

      final jsonString =
          await rootBundle.loadString('assets/service_account.json');
      final serviceAccountMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final projectId = serviceAccountMap['project_id'] as String;

      final credentials =
          ServiceAccountCredentials.fromJson(serviceAccountMap);
      const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      final client = await clientViaServiceAccount(credentials, scopes);

      try {
        final url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
        );

        final payload = {
          'message': {
            'token': targetToken,
            'notification': {
              'title': senderName,
              'body': messageText,
            },
            'android': {
              'priority': 'HIGH',
              'notification': {
                'channel_id': 'smartglyco_fcm_channel',
                'sound': 'default',
              },
            },
            'apns': {
              'payload': {
                'aps': {
                  'sound': 'default',
                },
              },
            },
          },
        };

        final response = await client.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          debugPrint("🚀 Push enviado com sucesso para $targetUserId!");
        } else {
          debugPrint("❌ Erro FCM (${response.statusCode}): ${response.body}");
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint("❌ Falha ao enviar push FCM: $e");
    }
  }
}