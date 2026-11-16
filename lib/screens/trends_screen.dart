import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_data.dart'; // <-- Acesso ao isHighContrast

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  // Variáveis de estado para controlar os filtros selecionados
  String _selectedMainTime = '7d';
  String _selectedTrendTime = '7d';

  // --- VARIÁVEIS PARA PINCH-TO-ZOOM (Manipulação Direta) ---
  double minX = 0;
  double maxX = 6;

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE ALTO CONTRASTE ---
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);

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
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);
    final mainTextColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : const Color(0xFF64748B);

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
                  child: Icon(Icons.arrow_back_ios_new, color: mainTextColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Trends', style: TextStyle(color: mainTextColor, fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text('Your glucose patterns', style: TextStyle(color: subTextColor, fontSize: 14)),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white54, size: 20),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 14,
                backgroundColor: isHighContrast ? Colors.transparent : const Color(0xFF387A76),
                child: Icon(Icons.person, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, size: 16),
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
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: isHighContrast ? 2 : 0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: times.map((t) {
          final isSelected = _selectedMainTime == t;
          final neonGradient = const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)]);

          BoxDecoration? decoration;
          if (isSelected) {
            decoration = isHighContrast
                ? BoxDecoration(color: const Color(0xFFFFD600), borderRadius: BorderRadius.circular(24))
                : BoxDecoration(
                    gradient: neonGradient, 
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
                  );
          }

          final textColor = isSelected 
              ? (isHighContrast ? Colors.black : Colors.white) 
              : (isHighContrast ? Colors.white : Colors.white54);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMainTime = t;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: decoration,
              child: Text(
                t,
                style: TextStyle(
                  color: textColor,
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
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);
    final mainTextColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final gridColor = isHighContrast ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.05);
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);

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
              Text('Glucose Trend', style: TextStyle(color: mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isHighContrast ? const Color(0xFFFFD600) : Colors.transparent)),
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
                
                // --- HEURÍSTICA DE MANIPULAÇÃO DIRETA (PINCH-TO-ZOOM E ARRASTO) ---
                minX: minX, maxX: maxX,
                clipData: const FlClipData.all(), // Não deixa o gráfico sair da caixa ao fazer zoom
                lineTouchData: LineTouchData(
                  touchSpotThreshold: 20,
                  handleBuiltInTouches: true,
                ),
                // ----------------------------------------------------------------

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10, 
                  getDrawingHorizontalLine: (value) => FlLine(color: gridColor, strokeWidth: isHighContrast ? 2 : 1),
                  checkToShowHorizontalLine: (value) => [70.0, 100.0, 140.0, 180.0].contains(value),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36, 
                      interval: 10, 
                      getTitlesWidget: (value, meta) {
                        if (![70.0, 100.0, 140.0, 180.0].contains(value)) return const SizedBox();
                        return Text(value.toInt().toString(), style: TextStyle(color: isHighContrast ? Colors.white : Colors.white70, fontSize: 12, fontWeight: FontWeight.w600));
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
                    color: isHighContrast ? const Color(0xFFFFD600) : null,
                    gradient: isHighContrast ? null : const LinearGradient(colors: [Color(0xFFE81CFF), Color(0xFF40C9FF)]),
                    barWidth: isHighContrast ? 4 : 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final isLast = index == _getSpotsForLineChart().length - 1;
                        return FlDotCirclePainter(
                          radius: isLast ? 5 : 4,
                          color: isHighContrast ? Colors.black : Colors.white,
                          strokeWidth: isLast ? (isHighContrast ? 2 : 4) : (isHighContrast ? 2 : 0),
                          strokeColor: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6).withOpacity(0.5),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: !isHighContrast, // Desliga o fundo suave em alto contraste
                      gradient: isHighContrast ? null : LinearGradient(
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
          // INSTRUÇÃO VISUAL PARA O UTILIZADOR
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pinch, color: isHighContrast ? Colors.white : Colors.white54, size: 14),
              const SizedBox(width: 6),
              Text('Pinch to zoom / Drag to pan', style: TextStyle(color: isHighContrast ? Colors.white : Colors.white54, fontSize: 10, fontStyle: FontStyle.italic)),
            ],
          )
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
      child: Text(text, style: TextStyle(color: isHighContrast ? Colors.white : Colors.white54, fontSize: 11)),
    );
  }

  Widget _miniPill(String text) {
    final isSelected = _selectedTrendTime == text;
    final neonGradient = const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)]);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTrendTime = text;
          // Faz reset ao zoom quando mudamos o filtro
          minX = 0;
          maxX = 6;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected && isHighContrast ? const Color(0xFFFFD600) : Colors.transparent,
          gradient: isSelected && !isHighContrast ? neonGradient : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text, 
          style: TextStyle(
            color: isSelected ? (isHighContrast ? Colors.black : Colors.white) : (isHighContrast ? Colors.white : Colors.white54), 
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
        Expanded(child: _statCard('Time in Range', '78', '%', valueColor: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF2DD4BF))),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Est. HbA1c', '6.8', '%')),
      ],
    );
  }

  Widget _statCard(String title, String value, String unit, {Color? valueColor}) {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);
    final mainTextColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final finalValueColor = valueColor ?? mainTextColor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: isHighContrast ? Colors.white : Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(color: finalValueColor, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 2),
              Text(unit, style: TextStyle(color: isHighContrast ? Colors.white : Colors.white54, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // --- GRÁFICO DE BARRAS (DAILY PATTERN) ---
  Widget _buildBarChartCard() {
    final barHeights = _getHeightsForBarChart();
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);
    final mainTextColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final gridColor = isHighContrast ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.05);

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
          Text('Daily Pattern', style: TextStyle(color: mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                maxY: 190,
                
                // Heurística Manipulação Direta no BarChart
                barTouchData: BarTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                ),

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10, 
                  getDrawingHorizontalLine: (value) => FlLine(color: gridColor, strokeWidth: isHighContrast ? 2 : 1),
                  checkToShowHorizontalLine: (value) => [70.0, 100.0, 140.0, 180.0].contains(value),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36, 
                      interval: 10, 
                      getTitlesWidget: (value, meta) {
                        if (![70.0, 100.0, 140.0, 180.0].contains(value)) return const SizedBox();
                        return Text(value.toInt().toString(), style: TextStyle(color: isHighContrast ? Colors.white : Colors.white70, fontSize: 10, fontWeight: FontWeight.w600));
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
                            child: Text(labels[value.toInt() ~/ 6], style: TextStyle(color: isHighContrast ? Colors.white : Colors.white54, fontSize: 10)),
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
                        color: isHighContrast ? const Color(0xFFFFD600) : null,
                        gradient: isHighContrast ? null : const LinearGradient(
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