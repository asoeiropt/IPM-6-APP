import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final Color bgColor = const Color(0xFF090C10);
  final Color cardColor = const Color(0xFF141923);
  final Gradient neonGradient = const LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)], // Azul para Roxo
  );

  String _selectedTab = 'Activity';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildTabSelector(),
            const SizedBox(height: 24),
            
            // Alterna o conteúdo consoante o separador selecionado
            if (_selectedTab == 'Activity') _buildActivityView()
            else _buildSleepView(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- CABEÇALHO ---
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
              child: Text('Move more. Sleep better.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
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
          child: const Icon(Icons.notifications_none, color: Colors.white54, size: 20),
        ),
      ],
    );
  }

  // --- SELETOR DE SEPARADOR (Activity / Sleep) ---
  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
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
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = title;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? neonGradient : null,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected
                ? [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
                : [],
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

  // --- VISTA DE ATIVIDADE ---
  Widget _buildActivityView() {
    return Column(
      children: [
        _buildStepsCard(),
        const SizedBox(height: 16),
        _buildSleepCard(),
      ],
    );
  }

  // --- VISTA DE SONO (Quando o separador "Sleep" é clicado) ---
  Widget _buildSleepView() {
    return Column(
      children: [
        _buildSleepCard(),
        const SizedBox(height: 16),
        // Placeholder para mais estatísticas de sono (Podes expandir isto no futuro)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sleep Stages', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('Deep Sleep: 2h 10m', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 8),
              Text('Light Sleep: 4h 20m', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 8),
              Text('REM: 1h 18m', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ],
    );
  }

  // --- CARTÃO DE PASSOS ---
  Widget _buildStepsCard() {
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
                      color: const Color(0xFF0D9488).withOpacity(0.2), // Fundo teal escuro
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_walk, color: Color(0xFF2DD4BF), size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Steps', style: TextStyle(color: Color(0xFF2DD4BF), fontSize: 13, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('8,432', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text('of 10,000', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              // Círculo de progresso
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 0.84, // 8432 / 10000
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2DD4BF)),
                    ),
                    const Center(
                      child: Icon(Icons.sync_alt, color: Colors.white54, size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          const SizedBox(height: 16),
          // Distância e Calorias
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Color(0xFF3B82F6), size: 18),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Distance', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text('6.3 km', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
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
                      children: const [
                        Text('Calories', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text('412 kcal', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
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

  // --- CARTÃO DE SONO ---
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
                      color: const Color(0xFF8B5CF6).withOpacity(0.2), // Fundo roxo escuro
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.nightlight_round, color: Color(0xFFC084FC), size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sleep', style: TextStyle(color: Color(0xFFC084FC), fontSize: 13, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('7h 48m', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              Column(
                children: const [
                  Icon(Icons.health_and_safety_outlined, color: Color(0xFF2DD4BF), size: 18),
                  SizedBox(height: 4),
                  Text('Good', style: TextStyle(color: Color(0xFF2DD4BF), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Gráfico de barras do sono
          SizedBox(
            height: 60,
            child: BarChart(
              BarChartData(
                maxY: 100,
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(24, (index) {
                  // Padrão aleatório semelhante ao da imagem
                  final heights = [30, 40, 20, 60, 40, 30, 70, 40, 30, 60, 40, 30, 70, 50, 40, 60, 40, 30, 50, 40, 30, 60, 40, 30];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: heights[index].toDouble(),
                        width: 6,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)], // Gradiente da barra Azul->Roxo
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
          const SizedBox(height: 8),
          // Horas no fundo do gráfico
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('11:32 PM', style: TextStyle(color: Colors.white54, fontSize: 11)),
              Text('7:20 AM', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}