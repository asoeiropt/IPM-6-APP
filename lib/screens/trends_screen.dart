import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  final Color bgColor = const Color(0xFF090C10);
  final Color cardColor = const Color(0xFF141923);
  final Gradient neonGradient = const LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)], 
  );

  // Variáveis de estado para controlar os filtros selecionados
  String _selectedMainTime = '7d';
  String _selectedTrendTime = '7d';

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
            _buildMainTimeSelector(),
            const SizedBox(height: 24),
            _buildLineChartCard(),
            const SizedBox(height: 16),
            _buildStatsGrid(),
            const SizedBox(height: 16),
            _buildBarChartCard(),
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
                const Text('Trends', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(left: 32),
              child: Text('Your glucose patterns', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.white54, size: 20),
              const SizedBox(width: 12),
              const CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFF387A76),
                child: Icon(Icons.person, color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- SELETOR DE TEMPO PRINCIPAL (TOP) ---
  Widget _buildMainTimeSelector() {
    final times = ['3h', '6h', '12h', '24h', '7d'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: times.map((t) {
          final isSelected = _selectedMainTime == t;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMainTime = t;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected ? neonGradient : null,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isSelected
                    ? [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Text(
                t,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- GRÁFICO DE LINHA (GLUCOSE TREND) ---
  Widget _buildLineChartCard() {
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
              const Text('Glucose Trend', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    _miniPill('24h'),
                    _miniPill('7d'),
                    _miniPill('30d'),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: 60, maxY: 190,
                minX: 0, maxX: 6,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10, // AQUI: Força a verificar de 10 em 10
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
                  checkToShowHorizontalLine: (value) => [70.0, 100.0, 140.0, 180.0].contains(value),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36, // Mais espaço para o número 180 caber bem
                      interval: 10, // AQUI: Garante que os números 70, 100, 140, 180 são avaliados
                      getTitlesWidget: (value, meta) {
                        if (![70.0, 100.0, 140.0, 180.0].contains(value)) return const SizedBox();
                        return Text(value.toInt().toString(), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: _getBottomTitlesForLineChart,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getSpotsForLineChart(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    gradient: const LinearGradient(colors: [Color(0xFFE81CFF), Color(0xFF40C9FF)]),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final isLast = index == _getSpotsForLineChart().length - 1;
                        return FlDotCirclePainter(
                          radius: isLast ? 5 : 4,
                          color: Colors.white,
                          strokeWidth: isLast ? 4 : 0,
                          strokeColor: const Color(0xFF3B82F6).withOpacity(0.5),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [const Color(0xFFE81CFF).withOpacity(0.2), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getSpotsForLineChart() {
    if (_selectedTrendTime == '24h') {
      return const [FlSpot(0, 95), FlSpot(1, 130), FlSpot(2, 105), FlSpot(3, 145), FlSpot(4, 110), FlSpot(5, 160), FlSpot(6, 125)];
    } else if (_selectedTrendTime == '30d') {
      return const [FlSpot(0, 130), FlSpot(1, 145), FlSpot(2, 120), FlSpot(3, 140), FlSpot(4, 155), FlSpot(5, 135), FlSpot(6, 120)];
    }
    return const [FlSpot(0, 110), FlSpot(1, 122), FlSpot(2, 118), FlSpot(3, 165), FlSpot(4, 150), FlSpot(5, 115), FlSpot(6, 130)];
  }

  Widget _getBottomTitlesForLineChart(double value, TitleMeta meta) {
    if (value % 1 != 0) return const SizedBox(); 
    int index = value.toInt();
    if (index < 0 || index > 6) return const SizedBox();

    String text = '';
    if (_selectedTrendTime == '24h') {
      const labels = ['12AM', '4AM', '8AM', '12PM', '4PM', '8PM', '11PM'];
      text = labels[index];
    } else if (_selectedTrendTime == '30d') {
      const labels = ['1', '5', '10', '15', '20', '25', '30'];
      text = labels[index];
    } else {
      const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      text = labels[index];
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 11)),
    );
  }

  Widget _miniPill(String text) {
    final isSelected = _selectedTrendTime == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTrendTime = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? neonGradient : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text, 
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54, 
            fontSize: 12, 
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
          )
        ),
      ),
    );
  }

  // --- GRID DE ESTATÍSTICAS ---
  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _statCard('Avg Glucose', '124', 'mg/dL')),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Time in Range', '78', '%', valueColor: const Color(0xFF2DD4BF))),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Est. HbA1c', '6.8', '%')),
      ],
    );
  }

  Widget _statCard(String title, String value, String unit, {Color valueColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(color: valueColor, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 2),
              Text(unit, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // --- GRÁFICO DE BARRAS (DAILY PATTERN) ---
  Widget _buildBarChartCard() {
    final barHeights = _getHeightsForBarChart();

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
          const Text('Daily Pattern', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                maxY: 190,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10, // AQUI: Força a verificar de 10 em 10
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
                  checkToShowHorizontalLine: (value) => [70.0, 100.0, 140.0, 180.0].contains(value),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36, // Mais espaço
                      interval: 10, // AQUI: Garante que os números 70, 100, 140, 180 são avaliados
                      getTitlesWidget: (value, meta) {
                        if (![70.0, 100.0, 140.0, 180.0].contains(value)) return const SizedBox();
                        return Text(value.toInt().toString(), style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['12 AM', '6 AM', '12 PM', '6 PM', '12 AM'];
                        if (value.toInt() % 6 == 0 && value.toInt() ~/ 6 < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(labels[value.toInt() ~/ 6], style: const TextStyle(color: Colors.white54, fontSize: 10)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(25, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: barHeights[index].toDouble(),
                        width: 6,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)], 
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(4),
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

  List<int> _getHeightsForBarChart() {
    if (_selectedMainTime == '3h') {
      return [100, 105, 110, 120, 115, 110, 105, 100, 95, 105, 115, 125, 135, 140, 130, 120, 110, 105, 100, 95, 105, 115, 120, 110, 105];
    } else if (_selectedMainTime == '12h') {
      return [80, 90, 100, 110, 130, 140, 135, 125, 115, 105, 95, 85, 90, 100, 110, 120, 130, 125, 115, 105, 95, 85, 90, 100, 110];
    }
    return [70, 85, 95, 110, 105, 120, 115, 100, 145, 120, 110, 95, 100, 105, 115, 125, 140, 120, 110, 145, 125, 110, 135, 110, 105];
  }
}