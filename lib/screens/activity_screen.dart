import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'package:flutter/services.dart';
import '../app_data.dart'; // <-- IMPORTADO para ler isHighContrast

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String _selectedTab = 'Activity';

  int _stepsToday = 0;
  int _sleepHours = 0;
  int _sleepMinutes = 0;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _fetchRealHealthData();
  }

  Future<void> _fetchRealHealthData() async {
    Health health = Health();
    var types = [
      HealthDataType.STEPS,
      HealthDataType.SLEEP_ASLEEP,
    ];

    try {
      bool requested = await health.requestAuthorization(types);
      if (requested) {
        var now = DateTime.now();
        var midnight = DateTime(now.year, now.month, now.day);
        var yesterday = now.subtract(const Duration(days: 1));

        int? steps = await health.getTotalStepsInInterval(midnight, now);

        List<HealthDataPoint> sleepData = await health.getHealthDataFromTypes(
          startTime: yesterday,
          endTime: now,
          types: [HealthDataType.SLEEP_ASLEEP],
        );

        double totalSleepMinutes = 0;
        for (var point in sleepData) {
          totalSleepMinutes += (point.value as NumericHealthValue).numericValue.toDouble();
        }

        if (mounted) {
          setState(() {
            _stepsToday = steps ?? 0;
            _sleepHours = totalSleepMinutes ~/ 60;
            _sleepMinutes = (totalSleepMinutes % 60).toInt();
            _isLoadingData = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingData = false);
      }
    } catch (e) {
      debugPrint("Erro ao buscar dados de saúde: $e");
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE ALTO CONTRASTE ---
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);
    final mainTextColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _isLoadingData 
          ? Center(child: CircularProgressIndicator(color: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(mainTextColor, subTextColor),
                const SizedBox(height: 24),
                _buildTabSelector(),
                const SizedBox(height: 24),
                
                if (_selectedTab == 'Activity') _buildActivityView()
                else _buildSleepView(),
                
                const SizedBox(height: 40),
              ],
            ),
      ),
    );
  }

  Widget _buildHeader(Color mainTextColor, Color subTextColor) {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);
    final iconColor = isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back_ios_new, color: isHighContrast ? Colors.white : Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Activity & Sleep', style: TextStyle(color: mainTextColor, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text('Data synced from your phone.', style: TextStyle(color: subTextColor, fontSize: 13)),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
          ),
          child: Icon(Icons.sync, color: iconColor, size: 20),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.transparent;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: isHighContrast ? 2 : 0)
      ),
      child: Row(
        children: [
          _buildTabButton('Activity'),
          _buildTabButton('Sleep'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title) {
    final isSelected = _selectedTab == title;
    final neonGradient = const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]);
    
    // Decoração do botão muda conforme o modo
    BoxDecoration? decoration;
    if (isSelected) {
      decoration = isHighContrast 
          ? BoxDecoration(color: const Color(0xFFFFD600), borderRadius: BorderRadius.circular(24))
          : BoxDecoration(gradient: neonGradient, borderRadius: BorderRadius.circular(24));
    }

    final textColor = isSelected 
        ? (isHighContrast ? Colors.black : Colors.white) 
        : (isHighContrast ? Colors.white : Colors.white54);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = title);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: decoration,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityView() {
    return Column(
      children: [
        _buildStepsCard(),
        const SizedBox(height: 16),
        _buildSleepCard(),
      ],
    );
  }

  Widget _buildSleepView() {
    return Column(
      children: [
        _buildSleepCard(),
      ],
    );
  }

  Widget _buildStepsCard() {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);
    final primaryColor = isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF2DD4BF);
    final subTextColor = isHighContrast ? Colors.white : Colors.white54;
    
    double stepProgress = _stepsToday / 10000;
    if (stepProgress > 1.0) stepProgress = 1.0; 
    
    double distanceKm = (_stepsToday * 0.762) / 1000; 
    int caloriesBurned = (_stepsToday * 0.04).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isHighContrast ? Colors.transparent : const Color(0xFF0D9488).withOpacity(0.2), 
                      shape: BoxShape.circle,
                      border: isHighContrast ? Border.all(color: primaryColor) : null,
                    ),
                    child: Icon(Icons.directions_walk, color: primaryColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Steps', style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('$_stepsToday', style: TextStyle(color: isHighContrast ? Colors.white : Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('of 10,000', style: TextStyle(color: subTextColor, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: stepProgress, 
                      strokeWidth: 8,
                      backgroundColor: isHighContrast ? Colors.grey[900] : Colors.white.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                    Center(child: Icon(Icons.sync_alt, color: subTextColor, size: 16)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: borderColor, height: 1, thickness: isHighContrast ? 2 : 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: isHighContrast ? Colors.white : const Color(0xFF3B82F6), size: 18),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Distance', style: TextStyle(color: subTextColor, fontSize: 12)),
                        Text('${distanceKm.toStringAsFixed(1)} km', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department_outlined, color: isHighContrast ? Colors.white : const Color(0xFF8B5CF6), size: 18),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Calories', style: TextStyle(color: subTextColor, fontSize: 12)),
                        Text('$caloriesBurned kcal', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepCard() {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);
    final primaryColor = isHighContrast ? const Color(0xFFFFD600) : const Color(0xFFC084FC);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isHighContrast ? Colors.transparent : const Color(0xFF8B5CF6).withOpacity(0.2), 
                      shape: BoxShape.circle,
                      border: isHighContrast ? Border.all(color: primaryColor) : null,
                    ),
                    child: Icon(Icons.nightlight_round, color: primaryColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sleep', style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('${_sleepHours}h ${_sleepMinutes}m', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.health_and_safety_outlined, color: isHighContrast ? Colors.white : const Color(0xFF2DD4BF), size: 18),
                  const SizedBox(height: 4),
                  Text(_sleepHours >= 7 ? 'Good' : 'Needs Fix', style: TextStyle(color: isHighContrast ? Colors.white : const Color(0xFF2DD4BF), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 60,
            child: BarChart(
              BarChartData(
                maxY: 100,
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(24, (index) {
                  final heights = [30, 40, 20, 60, 40, 30, 70, 40, 30, 60, 40, 30, 70, 50, 40, 60, 40, 30, 50, 40, 30, 60, 40, 30];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: heights[index].toDouble(),
                        width: 6,
                        color: isHighContrast ? const Color(0xFFFFD600) : null,
                        gradient: isHighContrast ? null : const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)], 
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      )
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}