import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'trends_screen.dart'; 
import 'medication_screen.dart'; 
import 'activity_screen.dart'; 
import 'report_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // COR UNIFICADA PARA TODA A APP
    const bgColor = Color(0xFF090C10);
    
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20), 
              const Text('Glucose', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              const Text('112', style: TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: 2)),
              const Text('mg/dL', style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.tealAccent.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_downward, color: Colors.tealAccent, size: 14),
                  ),
                  const SizedBox(width: 8),
                  const Text('-6 mg/dL ', style: TextStyle(color: Colors.tealAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                  const Text('vs. last hour', style: TextStyle(color: Colors.white54, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Updated 12 min ago', style: TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 24),

              // --- GRÁFICO DUPLO: PASSADO (REAL) E FUTURO (PREVISÃO IA) ---
              SizedBox(
                height: 120, // Altura aumentada ligeiramente para o novo design
                child: LineChart(
                  LineChartData(
                    minY: 50, maxY: 200,
                    minX: 0, maxX: 10, // Eixo X expandido para o futuro
                    gridData: FlGridData(
                      show: true, 
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        if (value == 70 || value == 180) {
                          return FlLine(color: Colors.white.withOpacity(0.15), strokeWidth: 1, dashArray: [4, 4]);
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
                              return Text(value.toInt().toString(), style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold));
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      // 1. LINHA DO PASSADO (Glicose Real - Sólida e Verde/Teal)
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 110), FlSpot(1, 115), FlSpot(2, 130), 
                          FlSpot(3, 145), FlSpot(4, 135), FlSpot(5, 115), 
                          FlSpot(6, 112) // Ponto Atual
                        ],
                        isCurved: true,
                        curveSmoothness: 0.4,
                        color: const Color(0xFF2DD4BF),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          checkToShowDot: (spot, barData) => spot.x == 6, // Ponto apenas no "Agora"
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 6, color: const Color(0xFF2DD4BF), strokeWidth: 3, strokeColor: bgColor),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [const Color(0xFF2DD4BF).withOpacity(0.2), Colors.transparent],
                          ),
                        ),
                      ),
                      
                      // 2. LINHA DO FUTURO (Predição da IA - Tracejada e Roxa)
                      LineChartBarData(
                        spots: const [
                          FlSpot(6, 112), // Começa exatamente onde a real acaba
                          FlSpot(7, 100), 
                          FlSpot(8, 85), 
                          FlSpot(9, 72), 
                          FlSpot(10, 65)  // Projeção de hipoglicemia
                        ],
                        isCurved: true,
                        curveSmoothness: 0.4,
                        color: const Color(0xFFE81CFF),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dashArray: [8, 6], // Efeito Tracejado
                        dotData: FlDotData(
                          show: true,
                          checkToShowDot: (spot, barData) => spot.x == 10, // Destaca o ponto final da previsão
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Colors.transparent, strokeWidth: 2, strokeColor: const Color(0xFFE81CFF)),
                        ),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // --- ALERTA DINÂMICO PREDITIVO ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE81CFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE81CFF).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.auto_awesome, color: Color(0xFFE81CFF), size: 16),
                    SizedBox(width: 8),
                    Text('AI Forecast: Drop to 65 mg/dL in 45m', style: TextStyle(color: Color(0xFFE81CFF), fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- CARTÕES DE NAVEGAÇÃO RÁPIDA ---
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
                    title: 'Next Insulin',
                    value: '8:30 AM',
                    subtitle: '4.2 U',
                    icon: Icons.health_and_safety_outlined,
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE45C96), Color(0xFFB52B65)]),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicationScreen()));
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

              // --- PRÓXIMA MEDICAÇÃO ---
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicationScreen()));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF5A449A), Color(0xFF3D277A)]),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.medication_outlined, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Next medication', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Metformin 500mg', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text('Today • 8:00 AM', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                        child: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
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
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const Icon(Icons.chevron_right, color: Colors.white54, size: 18),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}