import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'constants.dart';
import 'app_data.dart';
import 'screens/home_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/care_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/manual_entry_screen.dart';
import 'screens/chat_screen.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});
  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  Widget get _currentScreen => [
        const HomeTab(),
        const DiaryTab(),
        const CareTab(),
        ProfileTab(onContrastChanged: () => setState(() {})),
      ][_currentIndex];

  String get _firstName {
    final name = currentUserName.trim();
    if (name.isEmpty) return tr('Utilizador', 'User');
    return name.split(' ').first;
  }

  @override
  void initState() {
    super.initState();
    if (!askedForNotifications) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _askForNotifications());
    }
  }

  Future<void> _askForNotifications() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderDark)),
        title: Row(children: [
          const Icon(Icons.notifications_active, color: accentBlue, size: 24),
          const SizedBox(width: 12),
          Text(tr('🔔 Ativar Alertas?', '🔔 Enable Alerts?'),
              style: const TextStyle(color: textMain, fontSize: 18))
        ]),
        content: Text(
            tr(
              'Para que a SmartGlycoAI te avise de quedas rápidas e previna hipoglicemias, precisamos de enviar notificações.\n\nQueres ativar os alertas preditivos?',
              'For SmartGlycoAI to warn you of rapid drops and prevent hypoglycemia, we need to send you notifications.\n\nDo you want to enable predictive alerts?',
            ),
            style: TextStyle(fontSize: 14, color: textMuted)),
        actions: [
          TextButton(
              onPressed: () {
                askedForNotifications = true;
                saveData();
                Navigator.pop(ctx);
              },
              child: Text(tr('Agora Não', 'Not Now'),
                  style: TextStyle(color: textMuted))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                askedForNotifications = true;
                saveData();
                Navigator.pop(ctx);
                final androidPlatform = notificationsPlugin
                    .resolvePlatformSpecificImplementation<
                        AndroidFlutterLocalNotificationsPlugin>();
                if (androidPlatform != null) {
                  await androidPlatform.requestNotificationsPermission();
                }
              },
              child: Text(tr('✅ Sim, Ativar', '✅ Yes, Enable')))
        ],
      ),
    );
  }

  Future<void> _showPredictiveAlert() async {
    try {
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
              'ai_alerts', tr('Alertas IA', 'AI Alerts'),
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              color: Colors.red,
              enableVibration: true);
      final NotificationDetails notificationDetails = NotificationDetails(
          android: androidDetails, iOS: const DarwinNotificationDetails());
      await notificationsPlugin.show(
        0,
        tr('🚨 Alerta Preditivo', '🚨 Predictive Alert'),
        tr(
          'Previsão: 65 mg/dL em 20 min. Sugestão: 15g de hidratos.',
          'Prediction: 65 mg/dL in 20 min. Suggested: 15g carbs.',
        ),
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Notification notice: $e');
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isHighContrast ? Colors.black : cardDark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
                color:
                    isHighContrast ? const Color(0xFFFFD600) : borderDark,
                width: isHighContrast ? 2 : 1)),
        title: Row(children: [
          Icon(Icons.warning_amber_rounded,
              color: isHighContrast
                  ? const Color(0xFFFFD600)
                  : Colors.redAccent,
              size: 24),
          const SizedBox(width: 12),
          Text(tr('🚨 Alerta Preditivo', '🚨 Predictive Alert'),
              style: TextStyle(
                  color: isHighContrast
                      ? const Color(0xFFFFD600)
                      : Colors.redAccent,
                  fontSize: 18))
        ]),
        content: Text(
            tr(
              'O algoritmo detetou uma queda rápida.\n\n📉 Previsão: 65 mg/dL em 20 min.\n\n💡 Sugestão: Consome 15g de hidratos de absorção rápida.',
              'The algorithm detected a rapid drop.\n\n📉 Prediction: 65 mg/dL in 20 min.\n\n💡 Suggestion: Consume 15g of fast-acting carbs.',
            ),
            style: TextStyle(
                fontSize: 14,
                color: isHighContrast ? Colors.white : textMuted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('Ignorar', 'Ignore'),
                  style: TextStyle(
                      color: isHighContrast ? Colors.white : textMuted))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: isHighContrast
                      ? const Color(0xFFFFD600)
                      : Colors.redAccent,
                  foregroundColor:
                      isHighContrast ? Colors.black : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                globalDiary.insert(0, {
                  'title':
                      tr('Correção Preventiva', 'Preventive Correction'),
                  'carbs': 15.0,
                  'insulin': 0.0,
                  'time':
                      '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                  'type': 'correction',
                  'imagePath': null
                });
                saveData();
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        tr('🧃 Correção registada!', '🧃 Correction logged!'),
                        style: const TextStyle(color: textMain)),
                    backgroundColor: Colors.green));
              },
              child: Text(tr('Registar Correção', 'Log Correction')))
        ],
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? (isHighContrast ? const Color(0xFFFFD600) : Colors.white)
        : (isHighContrast ? Colors.white70 : const Color(0xFF64748B));
    final icon = isSelected ? activeIcon : inactiveIcon;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (isSelected && !isHighContrast)
                  Container(
                    width: 20,
                    height: 35,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.85),
                          blurRadius: 15,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                Icon(icon, color: color, size: 26),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color unifiedBg =
        isHighContrast ? Colors.black : const Color(0xFF090C10);
    final Color titleColor =
        isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final Color navBg =
        isHighContrast ? Colors.black : const Color(0xFF0F172A);
    final Color navBorder = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.05);

    return Scaffold(
      extendBody: true,
      backgroundColor: unifiedBg,
      appBar: AppBar(
          backgroundColor: unifiedBg,
          elevation: 0,
          centerTitle: false,
          title: Text(
            '${tr('Olá', 'Hello')}, $_firstName 👋',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 22, color: titleColor),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search,
                  color: isHighContrast ? titleColor : Colors.white54),
              onPressed: () {
                setState(() => _currentIndex = 1);
              },
            ),
            IconButton(
              icon: Icon(Icons.chat_bubble_outline, color: titleColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.notifications_outlined,
                  color: isHighContrast ? titleColor : Colors.redAccent),
              onPressed: _showPredictiveAlert,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0, left: 4.0),
              child: GestureDetector(
                onTap: () => setState(() => _currentIndex = 3),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isHighContrast ? titleColor : Colors.white24,
                        width: 1),
                  ),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: isHighContrast
                        ? const Color(0xFFFFD600)
                        : const Color(0xFF387A76),
                    child: Icon(Icons.person,
                        color: isHighContrast ? Colors.black : Colors.white,
                        size: 16),
                  ),
                ),
              ),
            ),
          ]),
      body: _currentScreen,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          height: 75,
          decoration: BoxDecoration(
            color: navBg,
            borderRadius: BorderRadius.circular(40),
            border:
                Border.all(color: navBorder, width: isHighContrast ? 2 : 1),
            boxShadow: isHighContrast
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined,
                  tr('Início', 'Home')),
              _buildNavItem(1, Icons.view_list_rounded,
                  Icons.view_list_outlined, tr('Diário', 'Diary')),
              _buildNavItem(2, Icons.health_and_safety_rounded,
                  Icons.health_and_safety_outlined, tr('Saúde', 'Care')),
              _buildNavItem(3, Icons.person_rounded, Icons.person_outline,
                  tr('Perfil', 'Profile')),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isHighContrast ? const Color(0xFFFFD600) : null,
          gradient: isHighContrast
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          boxShadow: isHighContrast
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: SpeedDial(
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: Icons.add,
          activeIcon: Icons.close,
          spacing: 16,
          spaceBetweenChildren: 12,
          foregroundColor: isHighContrast ? Colors.black : Colors.white,
          overlayColor: const Color(0xFF090C10),
          overlayOpacity: 0.85,
          shape: const CircleBorder(),
          children: [
            SpeedDialChild(
              child: Icon(Icons.camera_alt_outlined,
                  color: isHighContrast ? Colors.black : Colors.white),
              backgroundColor: isHighContrast
                  ? const Color(0xFFFFD600)
                  : const Color(0xFF3B82F6),
              shape: const CircleBorder(),
              labelWidget: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                    color: isHighContrast ? Colors.black : null,
                    gradient: isHighContrast
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.circular(16),
                    border: isHighContrast
                        ? Border.all(
                            color: const Color(0xFFFFD600), width: 2)
                        : null,
                    boxShadow: isHighContrast
                        ? null
                        : [
                            BoxShadow(
                                color:
                                    const Color(0xFF3B82F6).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4))
                          ]),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome,
                        color: isHighContrast
                            ? const Color(0xFFFFD600)
                            : Colors.white,
                        size: 16),
                    const SizedBox(width: 8),
                    Text(tr('Analisar Refeição', 'Analyze Meal'),
                        style: TextStyle(
                            color: isHighContrast
                                ? const Color(0xFFFFD600)
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ],
                ),
              ),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CameraScreen())),
            ),
            SpeedDialChild(
              child: Icon(Icons.edit_note,
                  color: isHighContrast ? Colors.black : Colors.white),
              backgroundColor: isHighContrast
                  ? const Color(0xFFFFD600)
                  : const Color(0xFF141923),
              shape: const CircleBorder(),
              labelWidget: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: isHighContrast
                      ? Colors.black
                      : const Color(0xFF141923),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isHighContrast
                          ? const Color(0xFFFFD600)
                          : Colors.white.withOpacity(0.1),
                      width: isHighContrast ? 2 : 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit,
                        color: isHighContrast
                            ? const Color(0xFFFFD600)
                            : Colors.white70,
                        size: 16),
                    const SizedBox(width: 8),
                    Text(tr('Registo Manual', 'Manual Entry'),
                        style: TextStyle(
                            color: isHighContrast
                                ? const Color(0xFFFFD600)
                                : Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ],
                ),
              ),
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ManualEntryScreen()));
                setState(() {});
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}