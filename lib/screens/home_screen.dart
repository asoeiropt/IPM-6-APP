import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart'; // Importado para Haptic Feedback
import 'trends_screen.dart'; 
import 'medication_screen.dart'; 
import 'activity_screen.dart'; 
import 'report_screen.dart';
import '../app_data.dart'; // <-- Acesso ao triggerHypoAlert e isHighContrast

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _currentIOB = "0.0";
  
  double _currentGlucose = 0;
  double _trendValue = 0;
  final List<FlSpot> _realSpots = [];
  final List<FlSpot> _forecastSpots = [];
  String _aiForecastText = "";
  double _maxX = 10;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    if (globalGlucose.isEmpty) {
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

    _realSpots.clear();
    for (int i = 0; i < globalGlucose.length; i++) {
      _realSpots.add(FlSpot(i.toDouble(), (globalGlucose[i]['value'] as num).toDouble()));
    }

    _currentGlucose = _realSpots.last.y;
    
    if (_realSpots.length > 1) {
      _trendValue = _currentGlucose - _realSpots.first.y; 
    }

    double currentIob = calculateIOB();
    double expectedDrop = currentIob * globalIsf; 
    double forecastTarget = _currentGlucose - expectedDrop;
    
    if (forecastTarget < 40) forecastTarget = 40; 

    _forecastSpots.clear();
    double lastIndex = (_realSpots.length - 1).toDouble();
    _forecastSpots.add(FlSpot(lastIndex, _currentGlucose));

    int forecastSteps = 4;
    double stepDrop = (_currentGlucose - forecastTarget) / forecastSteps;

    for (int i = 1; i <= forecastSteps; i++) {
      _forecastSpots.add(FlSpot(lastIndex + i, _currentGlucose - (stepDrop * i)));
    }

    _maxX = lastIndex + forecastSteps;

    setState(() {
      _currentIOB = currentIob.toStringAsFixed(1);
      
      if (currentIob > 0.1) {
        _aiForecastText = 'AI Forecast: Drop to ${forecastTarget.toInt()} mg/dL';
      } else {
        _aiForecastText = 'AI Forecast: Stable (No active insulin)';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE ALTO CONTRASTE ---
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);
    final mainTextColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : Colors.white70;
    
    final chartRealColor = isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF2DD4BF);
    final chartForecastColor = isHighContrast ? Colors.white : const Color(0xFFE81CFF);
    final gridLineColor = isHighContrast ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.15);

    bool isTrendDown = _trendValue <= 0;
    Color trendColor = isHighContrast 
        ? (isTrendDown ? Colors.white : const Color(0xFFFFD600)) 
        : (isTrendDown ? Colors.tealAccent : Colors.orangeAccent);
    IconData trendIcon = isTrendDown ? Icons.arrow_downward : Icons.arrow_upward;
    String trendPrefix = _trendValue > 0 ? '+' : '';
    
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20), 
              Text('Glucose', style: TextStyle(color: mainTextColor, fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              
              // --- TRUQUE DE APRESENTAÇÃO (ACIONAL NOTIFICAÇÃO) ---
              GestureDetector(
                onLongPress: () {
                  HapticFeedback.heavyImpact(); // Vibração longa para tu saberes que ativaste
                  triggerHypoAlert();
                  debugPrint("Notificação Preditiva Disparada!");
                },
                child: Text('${_currentGlucose.toInt()}', style: TextStyle(color: mainTextColor, fontSize: 80, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: 2)),
              ),
              // ----------------------------------------------------

              Text('mg/dL', style: TextStyle(color: subTextColor, fontSize: 16)),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isHighContrast ? Colors.transparent : trendColor.withOpacity(0.2), 
                      shape: BoxShape.circle,
                      border: isHighContrast ? Border.all(color: trendColor) : null
                    ),
                    child: Icon(trendIcon, color: trendColor, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Text('$trendPrefix${_trendValue.toInt()} mg/dL ', style: TextStyle(color: trendColor, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('vs. last hour', style: TextStyle(color: subTextColor, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),
              Text('Updated just now', style: TextStyle(color: subTextColor, fontSize: 13)),
              const SizedBox(height: 24),

              SizedBox(
                height: 120, 
                child: _realSpots.isEmpty ? const SizedBox() : LineChart(
                  LineChartData(
                    minY: 40, maxY: 220,
                    minX: 0, maxX: _maxX, 
                    gridData: FlGridData(
                      show: true, 
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        if (value == 70 || value == 180) {
                          return FlLine(color: gridLineColor, strokeWidth: isHighContrast ? 2 : 1, dashArray: [4, 4]);
                        }
                        return const FlLine(color: Colors.transparent);
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            if (value == 70 || value == 180) {
                              return Text(value.toInt().toString(), style: TextStyle(color: mainTextColor, fontSize: 10, fontWeight: FontWeight.bold));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _realSpots,
                        isCurved: true,
                        curveSmoothness: 0.4,
                        color: chartRealColor,
                        barWidth: isHighContrast ? 4 : 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          checkToShowDot: (spot, barData) => spot.x == _realSpots.last.x, 
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 6, color: chartRealColor, strokeWidth: 3, strokeColor: bgColor),
                        ),
                        belowBarData: BarAreaData(
                          show: !isHighContrast,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [chartRealColor.withOpacity(0.2), Colors.transparent],
                          ),
                        ),
                      ),
                      LineChartBarData(
                        spots: _forecastSpots,
                        isCurved: true,
                        curveSmoothness: 0.4,
                        color: chartForecastColor,
                        barWidth: isHighContrast ? 4 : 3,
                        isStrokeCapRound: true,
                        dashArray: [8, 6], 
                        dotData: FlDotData(
                          show: true,
                          checkToShowDot: (spot, barData) => spot.x == _forecastSpots.last.x, 
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: isHighContrast ? bgColor : Colors.transparent, strokeWidth: 2, strokeColor: chartForecastColor),
                        ),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isHighContrast ? Colors.black : chartForecastColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isHighContrast ? Colors.white : chartForecastColor.withOpacity(0.3), width: isHighContrast ? 2 : 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: chartForecastColor, size: 16),
                    const SizedBox(width: 8),
                    Text(_aiForecastText, style: TextStyle(color: chartForecastColor, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.1,
                children: [
                  _buildGradientCard(
                    title: 'Time in Range',
                    value: '82%',
                    subtitle: '70–180 mg/dL',
                    icon: Icons.access_time,
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF387A76), Color(0xFF285455)]),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TrendsScreen()));
                    },
                  ),
                  _buildGradientCard(
                    title: 'Active Insulin',
                    value: '$_currentIOB U',
                    subtitle: 'IOB based on logs',
                    icon: Icons.water_drop_outlined,
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE45C96), Color(0xFFB52B65)]),
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const MedicationScreen())
                      ).then((_) {
                        _refreshData();
                      });
                    },
                  ),
                  _buildGradientCard(
                    title: 'Activity',
                    value: '4,280',
                    subtitle: 'steps',
                    icon: Icons.local_fire_department,
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3B6EEA), Color(0xFF1E45A8)]),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ActivityScreen()));
                    },
                  ),
                  _buildGradientCard(
                    title: 'Weekly Report',
                    value: 'Insights',
                    subtitle: '& patterns',
                    icon: Icons.insert_drive_file_outlined,
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFD29C46), Color(0xFF9E6B22)]),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportScreen()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicationScreen()));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isHighContrast ? Colors.black : null,
                    gradient: isHighContrast ? null : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF5A449A), Color(0xFF3D277A)]),
                    borderRadius: BorderRadius.circular(24),
                    border: isHighContrast ? Border.all(color: const Color(0xFFFFD600), width: 2) : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isHighContrast ? Colors.transparent : Colors.white.withOpacity(0.1), 
                          shape: BoxShape.circle,
                          border: isHighContrast ? Border.all(color: const Color(0xFFFFD600)) : null,
                        ),
                        child: Icon(Icons.medication_outlined, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Next medication', style: TextStyle(color: mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Metformin 500mg', style: TextStyle(color: subTextColor, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text('Today • 8:00 AM', style: TextStyle(color: subTextColor, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isHighContrast ? Colors.transparent : Colors.black.withOpacity(0.3), 
                          shape: BoxShape.circle,
                          border: isHighContrast ? Border.all(color: Colors.white) : null,
                        ),
                        child: Icon(Icons.chevron_right, color: isHighContrast ? Colors.white : Colors.white, size: 20),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientCard({required String title, required String value, required String subtitle, required IconData icon, required Gradient gradient, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighContrast ? Colors.black : null,
          gradient: isHighContrast ? null : gradient,
          borderRadius: BorderRadius.circular(20),
          border: isHighContrast ? Border.all(color: const Color(0xFFFFD600), width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, size: 20),
                Icon(Icons.chevron_right, color: isHighContrast ? Colors.white : Colors.white54, size: 18),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: isHighContrast ? Colors.white : Colors.white70, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}