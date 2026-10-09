import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'constants.dart';
import 'app_data.dart';
import 'screens/home_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/manual_entry_screen.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});
  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0; 
  Widget get _currentScreen => [const HomeTab(), const DiaryTab(), const ProfileTab()][_currentIndex];

  @override
  void initState() {
    super.initState();
    if (!askedForNotifications) { WidgetsBinding.instance.addPostFrameCallback((_) => _askForNotifications()); }
  }

  Future<void> _askForNotifications() async {
    showDialog(
      context: context, barrierDismissible: false, 
      builder: (ctx) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderDark)), 
        title: Row(children: const [Icon(Icons.notifications_active, color: accentBlue, size: 24), SizedBox(width: 12), Text('🔔 Enable Alerts?', style: TextStyle(color: textMain, fontSize: 18))]), 
        content: Text('For SmartGlycoAI to warn you of rapid drops and prevent hypoglycemia, we need to send you notifications.\n\nDo you want to enable predictive alerts?', style: TextStyle(fontSize: 14, color: textMuted)), 
        actions: [
          TextButton(onPressed: () { askedForNotifications = true; saveData(); Navigator.pop(ctx); }, child: Text('Not Now', style: TextStyle(color: textMuted))), 
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: accentBlue, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () async { askedForNotifications = true; saveData(); Navigator.pop(ctx); final androidPlatform = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>(); if (androidPlatform != null) { await androidPlatform.requestNotificationsPermission(); } }, child: const Text('✅ Yes, Enable'))
        ]
      )
    );
  }

  Future<void> _showPredictiveAlert() async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails('ai_alerts', 'AI Alerts', importance: Importance.max, priority: Priority.high, icon: '@mipmap/ic_launcher', color: Colors.red, enableVibration: true);
      const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
      dynamic magicPlugin = notificationsPlugin;
      await magicPlugin.show(id: 0, title: '🚨 Predictive Alert', body: 'Prediction: 65 mg/dL in 20 min. Suggested: 15g carbs.', notificationDetails: notificationDetails);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ NOTIFICATION ERROR: $e'), backgroundColor: Colors.red));
    }
    if (!mounted) return;
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderDark)), 
        title: Row(children: const [Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24), SizedBox(width: 12), Text('🚨 Predictive Alert', style: TextStyle(color: Colors.redAccent, fontSize: 18))]), 
        content: Text('The algorithm detected a rapid drop.\n\n📉 Prediction: 65 mg/dL in 20 min.\n\n💡 Suggestion: Consume 15g of fast-acting carbs.', style: TextStyle(fontSize: 14, color: textMuted)), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Ignore', style: TextStyle(color: textMuted))), 
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () { globalDiary.insert(0, {'title': 'Preventive Correction', 'carbs': 15.0, 'insulin': 0.0, 'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}', 'type': 'correction', 'imagePath': null}); saveData(); Navigator.pop(ctx); setState(() {}); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🧃 Correction logged!', style: TextStyle(color: textMain)), backgroundColor: Colors.green)); }, child: const Text('Log Correction'))
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: const Text('💙 SmartGlycoAI', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.5, color: textMain)), 
        centerTitle: true, 
        backgroundColor: bgDark,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: borderDark, width: 1)),
        iconTheme: const IconThemeData(color: textMain),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.redAccent), onPressed: _showPredictiveAlert)
        ]
      ),
      body: _currentScreen, 
      bottomNavigationBar: Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: borderDark, width: 1))),
        child: NavigationBar(
          backgroundColor: bgDark,
          indicatorColor: Colors.white.withOpacity(0.1),
          selectedIndex: _currentIndex, 
          onDestinationSelected: (int index) => setState(() => _currentIndex = index), 
          destinations: [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined, color: textMuted), selectedIcon: const Icon(Icons.dashboard, color: textMain), label: 'Home'), 
            NavigationDestination(icon: Icon(Icons.view_list_outlined, color: textMuted), selectedIcon: const Icon(Icons.view_list, color: textMain), label: 'Diary'), 
            NavigationDestination(icon: Icon(Icons.person_outline, color: textMuted), selectedIcon: const Icon(Icons.person, color: textMain), label: 'Profile')
          ]
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 12,
        spaceBetweenChildren: 12,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        overlayColor: Colors.black,
        overlayOpacity: 0.7,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50), 
          side: BorderSide(color: borderDark)
        ),
        animationCurve: Curves.elasticInOut,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.camera_alt_outlined, color: Colors.black),
            backgroundColor: Colors.white,
            labelWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderDark)
              ),
              child: const Text('📸 Analyze Meal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
            ),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CameraScreen())),
          ),
          SpeedDialChild(
            child: const Icon(Icons.edit_note, color: Colors.white),
            backgroundColor: cardDark,
            labelWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderDark)
              ),
              child: const Text('📝 Manual Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            onTap: () async { 
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManualEntryScreen())); 
              setState(() {}); 
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.water_drop_outlined, color: Colors.white),
            backgroundColor: accentBlue,
            labelWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: accentBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('💧 Fast Correction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            onTap: () async { 
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManualEntryScreen())); 
              setState(() {}); 
            },
          ),
        ],
      ), 
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}