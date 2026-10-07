import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'app_data.dart';
import 'startup_screens.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

// --- CONSTANTES DE ESTILO VERCEL DARK --- COlab
const Color bgDark = Color(0xFF0A0A0A);
const Color cardDark = Color(0xFF111111);
final Color borderDark = Colors.white.withOpacity(0.1);
const Color accentBlue = Color(0xFF0070F3); // Destaques em azul
const Color textMain = Colors.white;
final Color textMuted = Colors.grey.shade500;

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
      const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);
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
      
      // --- AQUI ENTRA O NOVO BOTÃO ANIMADO (SPEED DIAL) ---
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
            backgroundColor: accentBlue, // Azul Vercel para dar destaque à correção
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Mudei para a direita (endFloat) porque o SpeedDial funciona e fica melhor no canto
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  
  double _calculateIOB() {
    double totalIob = 0.0; DateTime now = DateTime.now();
    for (var item in globalDiary) {
      if (item['insulin'] != null && item['insulin'] > 0) {
        List<String> timeParts = item['time'].split(':');
        if (timeParts.length == 2) {
          DateTime recordTime = DateTime(now.year, now.month, now.day, int.parse(timeParts[0]), int.parse(timeParts[1]));
          Duration diff = now.difference(recordTime);
          if (diff.inMinutes >= 0 && diff.inMinutes < 240) { double remaining = 1.0 - (diff.inMinutes / 240.0); totalIob += (item['insulin'] * remaining); }
        }
      }
    }
    return totalIob;
  }

  @override
  Widget build(BuildContext context) {
    double currentIob = _calculateIOB(); 
    return SingleChildScrollView( 
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(flex: 2, child: Container(padding: const EdgeInsets.all(20.0), decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderDark)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('🩸 CURRENT GLUCOSE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: textMuted)), Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle))]), const SizedBox(height: 12), const Text('115', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: textMain, letterSpacing: -1)), const SizedBox(height: 4), Row(children: [Text('mg/dL', style: TextStyle(fontSize: 13, color: textMuted)), const Spacer(), const Text('Stable', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w500))])]))), 
            const SizedBox(width: 12), 
            Expanded(flex: 1, child: Container(padding: const EdgeInsets.all(20.0), decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderDark)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('💉 IOB', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: textMuted)), const SizedBox(height: 16), Text(currentIob.toStringAsFixed(1), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textMain, letterSpacing: -0.5)), const SizedBox(height: 4), Text('Units', style: TextStyle(fontSize: 11, color: textMuted))])))]),
          const SizedBox(height: 24), 
          
          Container(
            padding: const EdgeInsets.all(20), 
            decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderDark)), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                const Text('📈 Trend (Last 6h)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textMain)), 
                const SizedBox(height: 24), 
                SizedBox(
                  height: 180, 
                  child: LineChart(LineChartData(
                    minY: 40, maxY: 250, minX: 0, maxX: 6, 
                    gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1)), 
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) { 
                        switch (v.toInt()) { 
                          case 0: return Text('10h', style: TextStyle(color: textMuted, fontSize: 10)); 
                          case 2: return Text('12h', style: TextStyle(color: textMuted, fontSize: 10)); 
                          case 4: return Text('14h', style: TextStyle(color: textMuted, fontSize: 10)); 
                          case 6: return Text('Now', style: TextStyle(color: textMuted, fontSize: 10)); 
                        } 
                        return const Text(''); 
                      }))
                    ), 
                    borderData: FlBorderData(show: false), 
                    lineBarsData: [LineChartBarData(isCurved: true, color: Colors.white, barWidth: 2, isStrokeCapRound: true, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: Colors.white.withOpacity(0.03)), spots: const [FlSpot(0, 110), FlSpot(1, 140), FlSpot(2, 175), FlSpot(3, 145), FlSpot(4, 95), FlSpot(5, 105), FlSpot(6, 115)])], 
                    extraLinesData: ExtraLinesData(horizontalLines: [HorizontalLine(y: 180, color: Colors.orange.withOpacity(0.3), strokeWidth: 1, dashArray: [4, 4]), HorizontalLine(y: 70, color: Colors.red.withOpacity(0.3), strokeWidth: 1, dashArray: [4, 4])])
                  ))
                ),
                const SizedBox(height: 24),
                // Botão "Advanced Analytics" alinhado em baixo do gráfico
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdvancedChartScreen())),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Advanced Analytics'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: borderDark),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ),
                  ),
                )
              ]
            )
          ),
          
          const SizedBox(height: 16), 
          Container(padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 80), decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(12), border: Border.all(color: borderDark)), child: Row(children: [const Icon(Icons.auto_awesome, color: Colors.white, size: 18), const SizedBox(width: 12), Expanded(child: Text('✨ System status optimal. 85% time-in-range today.', style: TextStyle(color: Colors.grey.shade300, fontSize: 12, fontFamily: 'monospace')))]))
      ]),
    );
  }
}

// --- PÁGINA ISOLADA DO GRÁFICO AVANÇADO ---
class AdvancedChartScreen extends StatefulWidget {
  const AdvancedChartScreen({super.key});

  @override
  State<AdvancedChartScreen> createState() => _AdvancedChartScreenState();
}

class _AdvancedChartScreenState extends State<AdvancedChartScreen> {
  String _timeRange = '3 day'; 

  List<FlSpot> _getChartData() {
    if (_timeRange == 'Day') return const [FlSpot(0, 95), FlSpot(1, 140), FlSpot(2, 110), FlSpot(3, 85), FlSpot(4, 160), FlSpot(5, 120)];
    if (_timeRange == 'Months') return const [FlSpot(0, 110), FlSpot(1, 115), FlSpot(2, 105), FlSpot(3, 125), FlSpot(4, 110), FlSpot(5, 115)];
    return const [FlSpot(0, 85), FlSpot(1, 110), FlSpot(2, 160), FlSpot(3, 130), FlSpot(4, 145), FlSpot(5, 190), FlSpot(6, 120)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: const Text('Advanced Analytics', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: textMain)),
        backgroundColor: bgDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: textMain),
        shape: Border(bottom: BorderSide(color: borderDark, width: 1)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cardDark, 
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: borderDark)
              ),
              child: Row(
                children: ['Day', '3 day', 'Months'].map((range) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _timeRange = range),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _timeRange == range ? Colors.white.withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(range, style: TextStyle(fontWeight: FontWeight.w600, color: _timeRange == range ? Colors.white : textMuted)),
                    )
                  )
                )).toList()
              )
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20), 
                    decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderDark)), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        const Text('Blood glucose', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)), 
                        const SizedBox(height: 32), 
                        SizedBox(
                          height: 250, 
                          child: LineChart(
                            LineChartData(
                              minY: 50, maxY: 250, minX: 0, maxX: _timeRange == '3 day' ? 6 : 5, 
                              rangeAnnotations: RangeAnnotations(
                                horizontalRangeAnnotations: [
                                  HorizontalRangeAnnotation(y1: 50, y2: 80, color: Colors.red.withOpacity(0.15)),
                                  HorizontalRangeAnnotation(y1: 80, y2: 180, color: Colors.green.withOpacity(0.15)),
                                ],
                              ),
                              gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: borderDark, strokeWidth: 1)), 
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35, getTitlesWidget: (v, m) {
                                  if (v == 50 || v == 100 || v == 150 || v == 200 || v == 250) {
                                    return Text(v.toInt().toString(), style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold));
                                  }
                                  return const Text('');
                                })), 
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) { 
                                  switch (v.toInt()) { 
                                    case 1: return Text('1 AM', style: TextStyle(color: textMuted, fontSize: 10)); 
                                    case 3: return Text('1 PM', style: TextStyle(color: textMuted, fontSize: 10)); 
                                    case 5: return Text('12 PM', style: TextStyle(color: textMuted, fontSize: 10)); 
                                  } 
                                  return const Text(''); 
                                }))
                              ), 
                              borderData: FlBorderData(show: false), 
                              lineBarsData: [
                                LineChartBarData(
                                  isCurved: true, 
                                  color: Colors.white, 
                                  barWidth: 2.5, 
                                  isStrokeCapRound: true, 
                                  dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 3, color: bgDark, strokeWidth: 2, strokeColor: Colors.white)), 
                                  belowBarData: BarAreaData(show: false), 
                                  spots: _getChartData()
                                )
                              ], 
                            )
                          )
                        )
                      ]
                    )
                  ),
                  const SizedBox(height: 24), 
                  const Text('Detailed Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16), 
                    decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderDark)), 
                    child: Row(
                      children: [
                        Container(width: 4, height: 40, decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('On-target duration', style: TextStyle(color: textMuted, fontSize: 13)),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text('85', style: TextStyle(color: textMain, fontSize: 24, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Text('%', style: TextStyle(color: textMuted, fontSize: 14)),
                              ],
                            )
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Avg Glucose', style: TextStyle(color: textMuted, fontSize: 13)),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text('115', style: TextStyle(color: textMain, fontSize: 24, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Text('mg/dL', style: TextStyle(color: textMuted, fontSize: 14)),
                              ],
                            )
                          ],
                        )
                      ]
                    )
                  ),
                ]
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiaryTab extends StatelessWidget {
  const DiaryTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: globalDiary.isEmpty 
        ? Center(child: Text('📭 Your diary is empty.', style: TextStyle(color: textMuted, fontSize: 14)))
        : ListView.builder(
            padding: const EdgeInsets.all(16.0), itemCount: globalDiary.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) return const Padding(padding: EdgeInsets.only(bottom: 16.0), child: Text('📖 Event Log', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textMain)));
              if (index == globalDiary.length + 1) return const SizedBox(height: 80); 
              final itemIndex = index - 1; final item = globalDiary[itemIndex]; final isMeal = item['type'] == 'meal';
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8.0), 
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderDark)), 
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: Icon(isMeal ? Icons.restaurant : Icons.water_drop, color: Colors.white, size: 20)), 
                  title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: textMain)), 
                  subtitle: Text('${item['carbs']}g Carbs • ${item['insulin']}U Insulin', style: TextStyle(fontSize: 13, color: textMuted)), 
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text(item['time'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: textMain, fontFamily: 'monospace')), const SizedBox(width: 8), Icon(Icons.chevron_right, color: borderDark, size: 16)]), 
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DiaryDetailScreen(itemIndex: itemIndex)))
                )
              );
            },
          ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Future<void> _editValue(String title, double currentValue, String unit, Function(double) onSave) async {
    TextEditingController controller = TextEditingController(text: currentValue.toString());
    return showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: cardDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderDark)), title: Text('✏ Edit $title', style: const TextStyle(color: textMain)), content: TextField(controller: controller, keyboardType: TextInputType.number, style: const TextStyle(color: textMain), decoration: InputDecoration(suffixText: unit, suffixStyle: TextStyle(color: textMuted), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderDark)), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)))), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: textMuted))), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0), onPressed: () { if (controller.text.isNotEmpty) { onSave(double.parse(controller.text)); saveData(); setState(() {}); } Navigator.pop(context); }, child: const Text('Save'))]));
  }
  
  // NOVA FUNÇÃO DE EXPORTAÇÃO EM PDF
  Future<void> _exportReport() async {
    // Cria o documento PDF
    final pdf = pw.Document();

    // Adiciona uma página em formato A4
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('SmartGlycoAI', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: const PdfColor(0, 0.44, 0.95))), // Azul Vercel
                    pw.Text('Clinical Report', style: const pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Informação do Paciente
              pw.Text('Patient: João Silva', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('Condition: Type 1 Diabetes', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
              pw.Text('Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
              pw.SizedBox(height: 20),
              
              // Caixa de Parâmetros
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100, 
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColors.grey300)
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Text('ICR: $globalIcr g/U', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('ISF: $globalIsf mg/dL/U', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Target: $globalTarget mg/dL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              
              // Tabela de Diário
              pw.Text('Daily Event Log', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              if (globalDiary.isEmpty)
                pw.Text('No entries found for this period.', style: const pw.TextStyle(color: PdfColors.grey))
              else
                pw.TableHelper.fromTextArray(
                  context: context,
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColor(0, 0.44, 0.95)), // Azul Vercel
                  rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
                  cellAlignment: pw.Alignment.centerLeft,
                  data: <List<String>>[
                    ['Time', 'Type', 'Description', 'Carbs (g)', 'Insulin (U)'],
                    ...globalDiary.map((item) => [
                          item['time'].toString(),
                          item['type'].toString().toUpperCase(),
                          item['title'].toString(),
                          item['carbs'].toString(),
                          item['insulin'].toString()
                        ])
                  ],
                ),
                
              pw.Spacer(),
              // Rodapé
              pw.Divider(color: PdfColors.grey300),
              pw.Center(child: pw.Text('Generated securely by SmartGlycoAI Mobile App.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey))),
            ],
          );
        },
      ),
    );

    // Guarda o PDF temporariamente no dispositivo
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/SmartGlycoAI_ClinicalReport.pdf');
    await file.writeAsBytes(await pdf.save());

    // Partilha o ficheiro PDF nativamente (WhatsApp, Email, etc.)
    await Share.shareXFiles([XFile(file.path)], text: 'Clinical Report from SmartGlycoAI');
  }

  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 12, top: 24), child: Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: textMuted)));

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Center(child: Column(children: [Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: borderDark)), child: const Icon(Icons.person, size: 40, color: Colors.white)), const SizedBox(height: 16), const Text('👋 João Silva', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textMain)), Text('Type 1 Diabetes', style: TextStyle(fontSize: 14, color: textMuted)), const SizedBox(height: 8), TextButton(onPressed: () { isLoggedIn = false; saveData(); Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));}, child: const Text('🚪 Log Out', style: TextStyle(color: Colors.redAccent, fontSize: 13)))])),
        
        _buildSectionHeader('🔒 Security'),
        Container(decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderDark)), child: SwitchListTile(activeColor: Colors.white, inactiveTrackColor: bgDark, title: const Text('Biometric Lock', style: TextStyle(color: textMain, fontSize: 14)), subtitle: Text('Require FaceID/TouchID', style: TextStyle(color: textMuted, fontSize: 12)), value: useBiometricsGlobal, onChanged: (bool value) async { bool supported = await biometricAuth.canCheckBiometrics; if (supported || !value) { setState(() => useBiometricsGlobal = value); saveData(); } else { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Device unsupported.', style: TextStyle(color: Colors.black)), backgroundColor: Colors.redAccent)); } })),
        
        _buildSectionHeader('🎛️ Parameters'),
        Container(decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderDark)), child: Column(children: [
          ListTile(title: const Text('Insulin-to-Carb (ICR)', style: TextStyle(color: textMain, fontSize: 14)), subtitle: Text('1U : $globalIcr g', style: TextStyle(color: textMuted, fontSize: 12)), trailing: Icon(Icons.chevron_right, color: borderDark, size: 16), onTap: () => _editValue('ICR', globalIcr, 'g', (v) => globalIcr = v)), 
          Divider(height: 1, color: borderDark), 
          ListTile(title: const Text('Sensitivity (ISF)', style: TextStyle(color: textMain, fontSize: 14)), subtitle: Text('1U : $globalIsf mg/dL', style: TextStyle(color: textMuted, fontSize: 12)), trailing: Icon(Icons.chevron_right, color: borderDark, size: 16), onTap: () => _editValue('ISF', globalIsf, 'mg/dL', (v) => globalIsf = v)), 
          Divider(height: 1, color: borderDark), 
          ListTile(title: const Text('Target Glucose', style: TextStyle(color: textMain, fontSize: 14)), subtitle: Text('$globalTarget mg/dL', style: TextStyle(color: textMuted, fontSize: 12)), trailing: Icon(Icons.chevron_right, color: borderDark, size: 16), onTap: () => _editValue('Target', globalTarget, 'mg/dL', (v) => globalTarget = v))
        ])),
        
        _buildSectionHeader('📱 Data & Devices'),
        Container(decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderDark)), child: Column(children: [
          ListTile(title: const Text('Export Report (PDF)', style: TextStyle(color: textMain, fontSize: 14)), subtitle: Text('Generate Clinical PDF', style: TextStyle(color: textMuted, fontSize: 12)), trailing: const Icon(Icons.picture_as_pdf, color: accentBlue, size: 18), onTap: _exportReport),
          Divider(height: 1, color: borderDark),
          ListTile(title: const Text('CGM Sensor', style: TextStyle(color: textMain, fontSize: 14)), subtitle: Text('Bluetooth settings', style: TextStyle(color: textMuted, fontSize: 12)), trailing: Icon(Icons.bluetooth, color: textMuted, size: 16), onTap: () => AppSettings.openAppSettings(type: AppSettingsType.bluetooth))
        ])),
        const SizedBox(height: 80),
      ],
    );
  }
}

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});
  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final TextEditingController tCtrl = TextEditingController(); 
  final TextEditingController cCtrl = TextEditingController(); 
  final TextEditingController iCtrl = TextEditingController(); 
  String _entryType = 'meal'; 
  bool _isLoadingBarcode = false; 

  @override
  void dispose() { tCtrl.dispose(); cCtrl.dispose(); iCtrl.dispose(); super.dispose(); }

  Future<void> _scanBarcode() async {
    try {
      String? barcodeScanRes = await Navigator.push(context, MaterialPageRoute(builder: (context) => const SimpleBarcodeScannerPage()));
      if (barcodeScanRes != null && barcodeScanRes != '-1' && barcodeScanRes.isNotEmpty) {
        setState(() { _isLoadingBarcode = true; });
        final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcodeScanRes.json');
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 1) { 
            final product = data['product'];
            setState(() { tCtrl.text = product['product_name'] ?? 'Unknown Product'; cCtrl.text = (double.tryParse((product['nutriments']?['carbohydrates_100g'] ?? 0).toString()) ?? 0.0).toStringAsFixed(1); iCtrl.text = ((double.tryParse(cCtrl.text) ?? 0) / globalIcr).toStringAsFixed(1); });
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Product fetched!', style: TextStyle(color: Colors.black)), backgroundColor: Colors.greenAccent));
          } else {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Product not found.', style: TextStyle(color: Colors.black)), backgroundColor: Colors.orangeAccent));
          }
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() { _isLoadingBarcode = false; });
    }
  }

  InputDecoration _customInputDeco(String label, String suffix) {
    return InputDecoration(
      labelText: label, labelStyle: TextStyle(color: textMuted, fontSize: 14),
      suffixText: suffix, suffixStyle: TextStyle(color: textMuted),
      filled: true, fillColor: cardDark,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderDark)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(title: const Text('✍️ Log Entry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textMain)), backgroundColor: cardDark, elevation: 0, shape: Border(bottom: BorderSide(color: borderDark, width: 1)), iconTheme: const IconThemeData(color: textMain)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [ButtonSegment(value: 'meal', label: Text('🍽️ Meal')), ButtonSegment(value: 'correction', label: Text('💧 Correction'))], 
              selected: {_entryType}, 
              onSelectionChanged: (Set<String> s) => setState(() => _entryType = s.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.white : cardDark),
                foregroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.black : textMain),
                side: WidgetStateProperty.all(BorderSide(color: borderDark))
              ),
            ), 
            const SizedBox(height: 24),
            
            ElevatedButton.icon(
              onPressed: _isLoadingBarcode ? null : _scanBarcode,
              icon: _isLoadingBarcode ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(Icons.qr_code_scanner, size: 18),
              label: Text(_isLoadingBarcode ? '🔍 Scanning DB...' : '🔍 Scan Barcode', style: const TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            ),
            
            Padding(padding: const EdgeInsets.symmetric(vertical: 24.0), child: Row(children: [Expanded(child: Divider(color: borderDark)), Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Text('✍️ MANUAL', style: TextStyle(color: textMuted, fontSize: 10, letterSpacing: 1.2))), Expanded(child: Divider(color: borderDark))])),
            
            TextField(controller: tCtrl, style: const TextStyle(color: textMain), decoration: _customInputDeco('Description', '')), const SizedBox(height: 16),
            TextField(controller: cCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: textMain), decoration: _customInputDeco('Carbs', 'g')), const SizedBox(height: 16),
            TextField(controller: iCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: textMain), decoration: _customInputDeco('Insulin', 'U')), const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: () { globalDiary.insert(0, {'title': tCtrl.text.isEmpty ? 'Manual Log' : tCtrl.text, 'carbs': double.tryParse(cCtrl.text) ?? 0.0, 'insulin': double.tryParse(iCtrl.text) ?? 0.0, 'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}', 'type': _entryType, 'imagePath': null }); saveData(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Logged!', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white)); Navigator.of(context).pop(); }, 
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: cardDark, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: borderDark))),
              child: const Text('💾 Save Log', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}
class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller; bool _isInitialized = false;
  @override
  void initState() { super.initState(); if (cameras.isNotEmpty) { _controller = CameraController(cameras[0], ResolutionPreset.high, enableAudio: false); _controller.initialize().then((_) { if (mounted) setState(() => _isInitialized = true); }).catchError((e) => debugPrint("Camera Error: $e")); } }
  @override
  void dispose() { if (_isInitialized) _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (cameras.isEmpty) return Scaffold(backgroundColor: bgDark, appBar: AppBar(title: const Text('No Camera', style: TextStyle(color: textMain, fontSize: 16)), backgroundColor: bgDark, elevation: 0), body: Center(child: Text('📷 Device camera unavailable.', style: TextStyle(color: textMuted))));
    return Scaffold(
      backgroundColor: Colors.black, 
      appBar: AppBar(title: const Text('📸 Capture', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)), backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)), 
      body: _isInitialized ? Center(child: CameraPreview(_controller)) : const Center(child: CircularProgressIndicator(color: Colors.white)), 
      floatingActionButton: FloatingActionButton(
        onPressed: () async { final image = await _controller.takePicture(); if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AnalysisResultScreen(imagePath: image.path))); }, 
        backgroundColor: Colors.white, elevation: 0, child: const Icon(Icons.camera, color: Colors.black, size: 28)
      ), 
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
    );
  }
}

class AnalysisResultScreen extends StatefulWidget {
  final String imagePath; const AnalysisResultScreen({super.key, required this.imagePath});
  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}
class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  bool _isAnalyzing = true; 
  @override
  void initState() { super.initState(); Future.delayed(const Duration(milliseconds: 2500), () { if (mounted) setState(() => _isAnalyzing = false); }); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(title: const Text('🧠 AI Analysis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textMain)), backgroundColor: cardDark, elevation: 0, shape: Border(bottom: BorderSide(color: borderDark, width: 1)), iconTheme: const IconThemeData(color: textMain)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(width: double.infinity, height: 300, child: Image.file(File(widget.imagePath), fit: BoxFit.cover)), 
            const SizedBox(height: 24),
            _isAnalyzing ? Column(children: [const CircularProgressIndicator(color: Colors.white), const SizedBox(height: 16), Text('🤖 Processing vision model...', style: TextStyle(color: textMuted, fontFamily: 'monospace', fontSize: 12))]) : 
            Padding(
              padding: const EdgeInsets.all(20.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, 
                children: [
                  Container(
                    padding: const EdgeInsets.all(20.0), 
                    decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderDark)), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        Row(children: [const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18), const SizedBox(width: 8), const Text('🎯 MATCH FOUND', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: textMain))]), 
                        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: borderDark)), 
                        const Text('🥩 Steak with Rice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textMain)), 
                        const SizedBox(height: 16), 
                        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('🍞 EST. CARBS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: textMuted)), const Text('45g', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textMain))])), 
                        const SizedBox(height: 8), 
                        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('💉 DOSE SUGGESTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: textMuted)), Text('${(45 / globalIcr).toStringAsFixed(1)} U', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))]))
                      ]
                    )
                  ), 
                  const SizedBox(height: 24), 
                  ElevatedButton(
                    onPressed: () { globalDiary.insert(0, {'title': 'AI Meal', 'carbs': 45.0, 'insulin': double.parse((45 / globalIcr).toStringAsFixed(1)), 'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}', 'type': 'meal', 'imagePath': widget.imagePath}); saveData(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Logged!', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white)); Navigator.of(context).pop(); }, 
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text('✅ Confirm & Log', style: TextStyle(fontWeight: FontWeight.w600)),
                  ), 
                  const SizedBox(height: 8),
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('❌ Discard', style: TextStyle(color: textMuted)))
                ]
              )
            )
          ],
        ),
      ),
    );
  }
}

class DiaryDetailScreen extends StatefulWidget {
  final int itemIndex; const DiaryDetailScreen({super.key, required this.itemIndex});
  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  late TextEditingController tCtrl, cCtrl, iCtrl, hCtrl; 
  @override
  void initState() { super.initState(); final item = globalDiary[widget.itemIndex]; tCtrl = TextEditingController(text: item['title']); cCtrl = TextEditingController(text: item['carbs'].toString()); iCtrl = TextEditingController(text: item['insulin'].toString()); hCtrl = TextEditingController(text: item['time']); }
  @override
  void dispose() { tCtrl.dispose(); cCtrl.dispose(); iCtrl.dispose(); hCtrl.dispose(); super.dispose(); }
  
  void _deleteRecord() { 
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        backgroundColor: cardDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderDark)),
        title: const Text('🗑️ Delete Log?', style: TextStyle(color: textMain)), 
        content: Text('This action cannot be undone.', style: TextStyle(color: textMuted)), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: textMuted))), 
          ElevatedButton(onPressed: () { globalDiary.removeAt(widget.itemIndex); saveData(); Navigator.pop(ctx); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Deleted', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent)); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, elevation: 0), child: const Text('Delete'))
        ]
      )
    ); 
  }

  InputDecoration _customInputDeco(String label, String suffix) {
    return InputDecoration(
      labelText: label, labelStyle: TextStyle(color: textMuted, fontSize: 14),
      suffixText: suffix, suffixStyle: TextStyle(color: textMuted),
      filled: true, fillColor: bgDark,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderDark)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = globalDiary[widget.itemIndex]; final String? img = item['imagePath'];
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(title: const Text('📝 Edit Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textMain)), backgroundColor: cardDark, elevation: 0, shape: Border(bottom: BorderSide(color: borderDark, width: 1)), iconTheme: const IconThemeData(color: textMain), actions: [IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: _deleteRecord)]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (img != null) SizedBox(width: double.infinity, height: 250, child: Image.file(File(img), fit: BoxFit.cover)) else Container(width: double.infinity, height: 150, color: cardDark, child: Icon(item['type'] == 'meal' ? Icons.restaurant : Icons.water_drop, size: 40, color: textMuted.withOpacity(0.2))),
            Padding(
              padding: const EdgeInsets.all(20.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, 
                children: [
                  TextField(controller: hCtrl, style: const TextStyle(color: textMain), decoration: _customInputDeco('🕐 Time', '')), const SizedBox(height: 16), 
                  TextField(controller: tCtrl, style: const TextStyle(color: textMain), decoration: _customInputDeco('📝 Description', '')), const SizedBox(height: 16), 
                  TextField(controller: cCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: textMain), decoration: _customInputDeco('🍞 Carbs', 'g')), const SizedBox(height: 16), 
                  TextField(controller: iCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: textMain), decoration: _customInputDeco('💉 Insulin', 'U')), const SizedBox(height: 32), 
                  
                  ElevatedButton(
                    onPressed: () { globalDiary[widget.itemIndex]['time'] = hCtrl.text; globalDiary[widget.itemIndex]['title'] = tCtrl.text; globalDiary[widget.itemIndex]['carbs'] = double.tryParse(cCtrl.text) ?? 0.0; globalDiary[widget.itemIndex]['insulin'] = double.tryParse(iCtrl.text) ?? 0.0; saveData(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Updated!', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white)); Navigator.of(context).pop(); }, 
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text('🔄 Update Changes', style: TextStyle(fontWeight: FontWeight.w600))
                  )
                ]
              )
            )
          ],
        ),
      ),
    );
  }
}
