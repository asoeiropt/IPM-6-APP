import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';
import 'package:flutter/services.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final Color bgColor = const Color(0xFF090C10);
  final Color cardColor = const Color(0xFF141923);
  final Gradient neonGradient = const LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)], 
  );

  String _selectedTab = 'Activity';

  // --- VARIÁVEIS PARA OS DADOS REAIS ---
  int _stepsToday = 0;
  int _sleepHours = 0;
  int _sleepMinutes = 0;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _fetchRealHealthData(); // Arranca a busca de dados ao abrir a página
  }

  // --- LÓGICA DE INTEGRAÇÃO APPLE HEALTH / GOOGLE FIT ---
  Future<void> _fetchRealHealthData() async {
    // Configura a API de saúde (usa o Health Connect na Google, se disponível)
    Health health = Health();
    
    // Define os tipos de dados que queremos ler
    var types = [
      HealthDataType.STEPS,
      HealthDataType.SLEEP_ASLEEP,
    ];

    try {
      // 1. Pede permissão ao utilizador (Aparece o popup do iOS/Android)
      bool requested = await health.requestAuthorization(types);
      
      if (requested) {
        var now = DateTime.now();
        var midnight = DateTime(now.year, now.month, now.day);
        var yesterday = now.subtract(const Duration(days: 1));

        // 2. Vai buscar os PASSOS de hoje (desde a meia noite)
        int? steps = await health.getTotalStepsInInterval(midnight, now);

        // 3. Vai buscar o SONO da última noite
        List<HealthDataPoint> sleepData = await health.getHealthDataFromTypes(
          startTime: yesterday,
          endTime: now,
          types: [HealthDataType.SLEEP_ASLEEP],
        );

        // Soma os minutos de sono
        double totalSleepMinutes = 0;
        for (var point in sleepData) {
          totalSleepMinutes += (point.value as NumericHealthValue).numericValue.toDouble();
        }

        // 4. Atualiza a UI
        if (mounted) {
          setState(() {
            _stepsToday = steps ?? 0; // Se for null, mete 0
            _sleepHours = totalSleepMinutes ~/ 60; // Divisão inteira para horas
            _sleepMinutes = (totalSleepMinutes % 60).toInt(); // Resto para minutos
            _isLoadingData = false;
          });
        }
      } else {
        // Sem permissão
        if (mounted) setState(() => _isLoadingData = false);
      }
    } catch (e) {
      debugPrint("Erro ao buscar dados de saúde: $e");
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _isLoadingData 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(),
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

  Widget _buildHeader() {
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
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Activity & Sleep', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(left: 32),
              child: Text('Data synced from your phone.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: const Icon(Icons.sync, color: Color(0xFF3B82F6), size: 20),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(30)),
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
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = title);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? neonGradient : null,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
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
    // Calcula a percentagem da rodinha (Meta: 10,000 passos)
    double stepProgress = _stepsToday / 10000;
    if (stepProgress > 1.0) stepProgress = 1.0; 
    
    // Estima distância e calorias muito rapidamente com base nos passos reais
    double distanceKm = (_stepsToday * 0.762) / 1000; 
    int caloriesBurned = (_stepsToday * 0.04).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                      color: const Color(0xFF0D9488).withOpacity(0.2), 
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_walk, color: Color(0xFF2DD4BF), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Steps', style: TextStyle(color: Color(0xFF2DD4BF), fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      // MOSTRA OS PASSOS REAIS
                      Text('$_stepsToday', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      const Text('of 10,000', style: TextStyle(color: Colors.white54, fontSize: 12)),
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
                      value: stepProgress, // Atualiza a rodinha
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2DD4BF)),
                    ),
                    const Center(child: Icon(Icons.sync_alt, color: Colors.white54, size: 16)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Color(0xFF3B82F6), size: 18),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Distance', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text('${distanceKm.toStringAsFixed(1)} km', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_outlined, color: Color(0xFF8B5CF6), size: 18),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Calories', style: TextStyle(color: Colors.white54, fontSize: 12)),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                      color: const Color(0xFF8B5CF6).withOpacity(0.2), 
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.nightlight_round, color: Color(0xFFC084FC), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sleep', style: TextStyle(color: Color(0xFFC084FC), fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      // MOSTRA AS HORAS DE SONO REAIS
                      Text('${_sleepHours}h ${_sleepMinutes}m', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.health_and_safety_outlined, color: Color(0xFF2DD4BF), size: 18),
                  const SizedBox(height: 4),
                  Text(_sleepHours >= 7 ? 'Good' : 'Needs Fix', style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 12, fontWeight: FontWeight.bold)),
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
                        gradient: const LinearGradient(
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