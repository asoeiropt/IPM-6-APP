import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'package:flutter/services.dart';
import '../app_data.dart';

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
    setState(() => _isLoadingData = true);
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
          totalSleepMinutes +=
              (point.value as NumericHealthValue).numericValue.toDouble();
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
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);
    final mainTextColor =
        isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _isLoadingData
            ? Center(
                child: CircularProgressIndicator(
                    color: isHighContrast
                        ? const Color(0xFFFFD600)
                        : const Color(0xFF3B82F6)))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeader(mainTextColor, subTextColor),
                  const SizedBox(height: 24),
                  _buildTabSelector(),
                  const SizedBox(height: 24),
                  if (_selectedTab == 'Activity')
                    _buildActivityView()
                  else
                    _buildSleepView(),
                  const SizedBox(height: 40),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(Color mainTextColor, Color subTextColor) {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.05);
    final iconColor =
        isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6);

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
                  child: Icon(Icons.arrow_back_ios_new,
                      color: mainTextColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(tr('Atividade & Sono', 'Activity & Sleep'),
                    style: TextStyle(
                        color: mainTextColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                  tr('Dados sincronizados do telemóvel.',
                      'Data synced from your phone.'),
                  style: TextStyle(color: subTextColor, fontSize: 13)),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _fetchRealHealthData();
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
              border: Border.all(
                  color: borderColor, width: isHighContrast ? 2 : 1),
            ),
            child: Icon(Icons.sync, color: iconColor, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor =
        isHighContrast ? const Color(0xFFFFD600) : Colors.transparent;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: borderColor, width: isHighContrast ? 2 : 0)),
      child: Row(
        children: [
          _buildTabButton('Activity', tr('Atividade', 'Activity')),
          _buildTabButton('Sleep', tr('Sono', 'Sleep')),
        ],
      ),
    );
  }

  Widget _buildTabButton(String key, String label) {
    final isSelected = _selectedTab == key;
    const neonGradient =
        LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]);

    BoxDecoration? decoration;
    if (isSelected) {
      decoration = isHighContrast
          ? BoxDecoration(
              color: const Color(0xFFFFD600),
              borderRadius: BorderRadius.circular(24))
          : BoxDecoration(
              gradient: neonGradient, borderRadius: BorderRadius.circular(24));
    }

    final textColor = isSelected
        ? (isHighContrast ? Colors.black : Colors.white)
        : (isHighContrast ? Colors.white : Colors.white54);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = key);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: decoration,
          child: Center(
            child: Text(
              label,
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
        _buildActivityPatternCard(),
      ],
    );
  }

  Widget _buildSleepView() {
    return Column(
      children: [
        _buildSleepCard(),
        const SizedBox(height: 16),
        _buildSleepImpactCard(),
      ],
    );
  }

  Widget _buildStepsCard() {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.05);
    final primaryColor =
        isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF2DD4BF);
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
                      color: isHighContrast
                          ? Colors.transparent
                          : const Color(0xFF0D9488).withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: isHighContrast
                          ? Border.all(color: primaryColor)
                          : null,
                    ),
                    child: Icon(Icons.directions_walk,
                        color: primaryColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('Passos', 'Steps'),
                          style: TextStyle(
                              color: primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('$_stepsToday',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(tr('de 10.000', 'of 10,000'),
                          style: TextStyle(color: subTextColor, fontSize: 12)),
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
                      backgroundColor: isHighContrast
                          ? Colors.grey[900]
                          : Colors.white.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                    Center(
                        child: Text('${(stepProgress * 100).toInt()}%',
                            style: TextStyle(
                                color: subTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(
              color: borderColor,
              height: 1,
              thickness: isHighContrast ? 2 : 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: isHighContrast
                            ? Colors.white
                            : const Color(0xFF3B82F6),
                        size: 18),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('Distância', 'Distance'),
                            style:
                                TextStyle(color: subTextColor, fontSize: 12)),
                        Text('${distanceKm.toStringAsFixed(1)} km',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department_outlined,
                        color: isHighContrast
                            ? Colors.white
                            : const Color(0xFF8B5CF6),
                        size: 18),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('Calorias', 'Calories'),
                            style:
                                TextStyle(color: subTextColor, fontSize: 12)),
                        Text('$caloriesBurned kcal',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
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

  Widget _buildActivityPatternCard() {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.05);
    final primaryColor =
        isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6);
    final subTextColor = isHighContrast ? Colors.white : Colors.white54;

    final bool hasSteps = _stepsToday > 0;
    final heights = hasSteps
        ? [
            10, 5, 5, 5, 5, 10, 25, 45, 70, 55, 40, 35, 65, 80, 50, 45, 60, 85,
            75, 50, 35, 25, 15, 10
          ]
        : List.filled(24, 6);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(tr('Ritmo Diário', 'Hourly Pace'),
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              Text(
                  hasSteps
                      ? tr('Ativo hoje', 'Active today')
                      : tr('Sem movimento registado', 'No movement recorded'),
                  style: TextStyle(color: subTextColor, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 60,
            child: BarChart(
              BarChartData(
                maxY: 100,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(24, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: heights[index].toDouble(),
                        width: 6,
                        color: isHighContrast
                            ? const Color(0xFFFFD600)
                            : (!hasSteps ? Colors.white12 : null),
                        gradient: (isHighContrast || !hasSteps)
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xFF2DD4BF), Color(0xFF3B82F6)],
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

  Widget _buildSleepCard() {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.05);
    final primaryColor =
        isHighContrast ? const Color(0xFFFFD600) : const Color(0xFFC084FC);
    final subTextColor = isHighContrast ? Colors.white : Colors.white54;

    final int totalMinutes = (_sleepHours * 60) + _sleepMinutes;
    final bool hasSleepData = totalMinutes > 0;
    final String statusLabel = !hasSleepData
        ? tr('Sem dados', 'No Data')
        : (_sleepHours >= 7
            ? tr('Bom', 'Good')
            : tr('Abaixo do ideal', 'Needs Rest'));

    // Escala dinâmica com base nos minutos reais de sono (objetivo: 480 min = 8h)
    final double sleepScale = (totalMinutes / 480.0).clamp(0.15, 1.0);
    const List<int> baseSleepCycle = [
      25, 45, 75, 90, 60, 40, 80, 95, 70, 50, 85, 65, 45, 75, 80, 55, 40, 65,
      50, 35, 30, 25, 20, 15
    ];
    final List<double> heights = hasSleepData
        ? baseSleepCycle.map((v) => (v * sleepScale).clamp(6.0, 100.0)).toList()
        : List.filled(24, 4.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isHighContrast
                          ? Colors.transparent
                          : const Color(0xFF8B5CF6).withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: isHighContrast
                          ? Border.all(color: primaryColor)
                          : null,
                    ),
                    child: Icon(Icons.nightlight_round,
                        color: primaryColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('Sono', 'Sleep'),
                          style: TextStyle(
                              color: primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('${_sleepHours}h ${_sleepMinutes}m',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.health_and_safety_outlined,
                      color: isHighContrast
                          ? Colors.white
                          : const Color(0xFF2DD4BF),
                      size: 18),
                  const SizedBox(height: 4),
                  Text(statusLabel,
                      style: TextStyle(
                          color: isHighContrast
                              ? Colors.white
                              : const Color(0xFF2DD4BF),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
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
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(24, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: heights[index],
                        width: 6,
                        color: isHighContrast
                            ? const Color(0xFFFFD600)
                            : (!hasSleepData ? Colors.white12 : null),
                        gradient: (isHighContrast || !hasSleepData)
                            ? null
                            : const LinearGradient(
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
          const SizedBox(height: 16),
          Text(
            hasSleepData
                ? tr(
                    'Dormir 7–8h ajuda a estabilizar a sensibilidade à insulina.',
                    'Sleeping 7–8h helps stabilize insulin sensitivity.')
                : tr(
                    'Liga o Apple Health ou Google Health Connect para sincronizar o sono.',
                    'Connect Apple Health or Google Health Connect to sync sleep data.'),
            style: TextStyle(color: subTextColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepImpactCard() {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.05);
    final accentColor =
        isHighContrast ? const Color(0xFFFFD600) : const Color(0xFFC084FC);
    final subTextColor = isHighContrast ? Colors.white : Colors.white54;

    final int totalMinutes = (_sleepHours * 60) + _sleepMinutes;
    final bool hasSleepData = totalMinutes > 0;
    final int goalPct = ((totalMinutes / 480.0) * 100).clamp(0, 100).toInt();

    final String sensitivityNote = !hasSleepData
        ? tr('Sem registo recente', 'No recent log')
        : (_sleepHours >= 7
            ? tr('Estável (+0%)', 'Stable (+0%)')
            : tr('Resistência ligeira', 'Mild resistance'));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('Meta de Descanso', 'Rest Goal'),
                    style: TextStyle(color: subTextColor, fontSize: 12)),
                const SizedBox(height: 4),
                Text(hasSleepData ? '$goalPct% (8h)' : '-- / 8h',
                    style: TextStyle(
                        color: accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: borderColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('Sensibilidade ISF', 'ISF Sensitivity'),
                    style: TextStyle(color: subTextColor, fontSize: 12)),
                const SizedBox(height: 4),
                Text(sensitivityNote,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}