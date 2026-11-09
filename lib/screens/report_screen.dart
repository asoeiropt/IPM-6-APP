import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  final Color bgColor = const Color(0xFF090C10);
  final Color cardColor = const Color(0xFF141923);
  final Gradient goldGradient = const LinearGradient(
    colors: [Color(0xFFD29C46), Color(0xFF9E6B22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            
            // Insight da IA (Cartão Dourado)
            _buildAIInsightBanner(),
            const SizedBox(height: 24),

            // Gráfico Circular de Time in Range
            _buildTimeInRangeChart(),
            const SizedBox(height: 16),

            // Métricas da Semana
            _buildWeeklyMetricsGrid(),
            const SizedBox(height: 24),

            // Botão de Exportar PDF
            _buildExportButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- CABEÇALHO ---
  Widget _buildHeader(BuildContext context) {
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
                const Text('Weekly Report', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(left: 32),
              child: Text('Nov 2 - Nov 8', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
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
          child: const Icon(Icons.calendar_month_outlined, color: Colors.white54, size: 20),
        ),
      ],
    );
  }

  // --- BANNER DE INSIGHT DA IA ---
  Widget _buildAIInsightBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: goldGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('AI Insight', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'A tua glicose matinal esteve 15% mais estável esta semana! O ajuste na rotina de sono e o lanche noturno estão a dar excelentes resultados.',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  // --- GRÁFICO CIRCULAR (DONUT) ---
  Widget _buildTimeInRangeChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Time in Range', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 60,
                    startDegreeOffset: -90,
                    sections: [
                      // In Range (Teal)
                      PieChartSectionData(
                        color: const Color(0xFF2DD4BF),
                        value: 82,
                        title: '',
                        radius: 20,
                      ),
                      // High (Roxo)
                      PieChartSectionData(
                        color: const Color(0xFF8B5CF6),
                        value: 12,
                        title: '',
                        radius: 16,
                      ),
                      // Low (Vermelho/Rosa)
                      PieChartSectionData(
                        color: const Color(0xFFF43F5E),
                        value: 6,
                        title: '',
                        radius: 16,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('82%', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      Text('In Target', style: TextStyle(color: Color(0xFF2DD4BF), fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Legenda
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Low', '6%', const Color(0xFFF43F5E)),
              _buildLegendItem('In Range', '82%', const Color(0xFF2DD4BF)),
              _buildLegendItem('High', '12%', const Color(0xFF8B5CF6)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, String value, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.circle, color: color, size: 10),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // --- GRID DE MÉDIAS DA SEMANA ---
  Widget _buildWeeklyMetricsGrid() {
    return Row(
      children: [
        Expanded(child: _metricCard('Avg. Carbs', '145', 'g / day', Icons.restaurant)),
        const SizedBox(width: 12),
        Expanded(child: _metricCard('Avg. Insulin', '32', 'U / day', Icons.vaccines)),
      ],
    );
  }

  Widget _metricCard(String title, String value, String unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  // --- BOTÃO EXPORTAR PDF ---
  Widget _buildExportButton() {
    return GestureDetector(
      onTap: () {}, // Lógica para gerar PDF no futuro
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // Azul muito escuro
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 22),
            SizedBox(width: 12),
            Text('Export Report as PDF', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}