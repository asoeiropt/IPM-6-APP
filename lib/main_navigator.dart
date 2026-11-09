import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'constants.dart';
import 'app_data.dart';
import 'screens/home_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/care_screen.dart'; // <--- O teu ecrã Care importado
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
  
  // As tuas 4 páginas principais
  Widget get _currentScreen => [
    const HomeTab(), 
    const DiaryTab(), 
    const CareTab(), 
    const ProfileTab()
  ][_currentIndex];

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

  // --- BOTÃO DA BARRA INFERIOR ---
  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? Colors.white : const Color(0xFF64748B);
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
                if (isSelected)
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
    return Scaffold(
      extendBody: true, 
      backgroundColor: bgDark,
      
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: borderDark, width: 1)),
        centerTitle: false,
        title: const Text(
          'Olá, João 👋', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white54),
            onPressed: () {}, 
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.redAccent), 
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
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFF387A76),
                  child: Icon(Icons.person, color: Colors.white, size: 16),
                ),
              ),
            ),
          ),
        ]
      ),
      
      body: _currentScreen, 
      
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          height: 75, 
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), 
            borderRadius: BorderRadius.circular(40), 
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            boxShadow: [
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
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              _buildNavItem(1, Icons.view_list_rounded, Icons.view_list_outlined, 'Diary'),
              _buildNavItem(2, Icons.health_and_safety_rounded, Icons.health_and_safety_outlined, 'Care'), 
              _buildNavItem(3, Icons.person_rounded, Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
      
      // --- NOVO BOTÃO FLUTUANTE COM GRADIENTE ---
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFFA855F7)], // Azul para Roxo vibrante
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SpeedDial(
          backgroundColor: Colors.transparent, // Transparente para o gradiente de trás aparecer
          elevation: 0, // Tirar a sombra padrão do botão (já temos a do Container)
          icon: Icons.add,
          activeIcon: Icons.close,
          spacing: 12,
          spaceBetweenChildren: 12,
          foregroundColor: Colors.white, // Ícone do "+" a branco
          overlayColor: Colors.black,
          overlayOpacity: 0.7,
          shape: const CircleBorder(),
          children: [
            SpeedDialChild(
              child: const Icon(Icons.camera_alt_outlined, color: Colors.black),
              backgroundColor: Colors.white,
              labelWidget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
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
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderDark)),
                child: const Text('📝 Manual Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              onTap: () async { await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManualEntryScreen())); setState(() {}); },
            ),
          ],
        ),
      ), 
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}