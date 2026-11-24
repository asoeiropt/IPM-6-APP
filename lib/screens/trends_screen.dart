import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_data.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  String _selectedMainTime = '7d';
  String _selectedTrendTime = '7d';

  // --- PINCH-TO-ZOOM & PAN REAL ---
  double minX = 0;
  double maxX = 6;
  double _baseMinX = 0;
  double _baseMaxX = 6;
  double _baseFocalX = 0;

  bool get _isZoomed => (minX > 0.05 || maxX < 5.95);

  void _resetZoom() {
    HapticFeedback.selectionClick();
    setState(() {
      minX = 0;
      maxX = 6;
    });
  }

  @override
  Widget build(BuildContext context) {
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
    final mainTextColor =
        isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : const Color(0xFF64748B);

    return Column(
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
            Text(tr('Tendências', 'Trends'),
                style: TextStyle(
                    color: mainTextColor,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text(
              tr('Os teus padrões glicémicos', 'Your glucose patterns'),
              style: TextStyle(color: subTextColor, fontSize: 14)),
        ),
      ],
    );
  }

  // --- SELETOR DE TEMPO PRINCIPAL (TOP) ---
  Widget _buildMainTimeSelector() {
    final times = ['3h', '6h', '12h', '24h', '7d'];
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor =
        isHighContrast ? const Color(0xFFFFD600) : Colors.transparent;

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
          const neonGradient =
              LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)]);

          BoxDecoration? decoration;
          if (isSelected) {
            decoration = isHighContrast
                ? BoxDecoration(
                    color: const Color(0xFFFFD600),
                    borderRadius: BorderRadius.circular(24))
                : BoxDecoration(
                    gradient: neonGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ]);
          }

          final textColor = isSelected
              ? (isHighContrast ? Colors.black : Colors.white)
              : (isHighContrast ? Colors.white : Colors.white54);

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedMainTime = t;
                  if (t == '24h' || t == '7d') {
                    _selectedTrendTime = t;
                  }
                  minX = 0;
                  maxX = 6;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: decoration,
                child: Center(
                  child: Text(
                    t,
                    style: TextStyle(
                      color: textColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- GRÁFICO DE LINHA (GLUCOSE TREND COM PINCH-TO-ZOOM REAL) ---
  Widget _buildLineChartCard() {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.05);
    final mainTextColor =
        isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final gridColor = isHighContrast
        ? Colors.white.withOpacity(0.3)
        : Colors.white.withOpacity(0.05);
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
              Text(tr('Tendência de Glicemia', 'Glucose Trend'),
                  style: TextStyle(
                      color: mainTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isHighContrast
                            ? const Color(0xFFFFD600)
                            : Colors.transparent)),
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
          LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth =
                  (constraints.maxWidth - 36).clamp(100.0, 2000.0);

              return GestureDetector(
                onDoubleTap: _resetZoom,
                onScaleStart: (details) {
                  _baseMinX = minX;
                  _baseMaxX = maxX;
                  _baseFocalX = details.localFocalPoint.dx;
                },
                onScaleUpdate: (details) {
                  final baseSpan = _baseMaxX - _baseMinX;
                  if (baseSpan <= 0) return;

                  final newSpan =
                      (baseSpan / details.scale).clamp(1.5, 6.0);
                  final center = (_baseMinX + _baseMaxX) / 2.0;

                  final dx = details.localFocalPoint.dx - _baseFocalX;
                  final panDelta = -(dx / chartWidth) * newSpan;

                  double nextMin = center - (newSpan / 2.0) + panDelta;
                  double nextMax = center + (newSpan / 2.0) + panDelta;

                  if (nextMin < 0) {
                    nextMin = 0;
                    nextMax = newSpan;
                  }
                  if (nextMax > 6) {
                    nextMax = 6;
                    nextMin = (6 - newSpan).clamp(0.0, 6.0);
                  }

                  setState(() {
                    minX = nextMin;
                    maxX = nextMax;
                  });
                },
                child: SizedBox(
                  height: 160,
                  child: LineChart(
                    LineChartData(
                      minY: 60,
                      maxY: 190,
                      minX: minX,
                      maxX: maxX,
                      clipData: const FlClipData.all(),
                      lineTouchData: LineTouchData(
                        touchSpotThreshold: 20,
                        handleBuiltInTouches: true,
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 10,
                        getDrawingHorizontalLine: (value) => FlLine(
                            color: gridColor,
                            strokeWidth: isHighContrast ? 2 : 1),
                        checkToShowHorizontalLine: (value) =>
                            [70.0, 100.0, 140.0, 180.0].contains(value),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            interval: 10,
                            getTitlesWidget: (value, meta) {
                              if (![70.0, 100.0, 140.0, 180.0]
                                  .contains(value)) {
                                return const SizedBox();
                              }
                              return Text(value.toInt().toString(),
                                  style: TextStyle(
                                      color: isHighContrast
                                          ? Colors.white
                                          : Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600));
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: _getBottomTitlesForLineChart,
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _getSpotsForLineChart(),
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: isHighContrast
                              ? const Color(0xFFFFD600)
                              : null,
                          gradient: isHighContrast
                              ? null
                              : const LinearGradient(colors: [
                                  Color(0xFFE81CFF),
                                  Color(0xFF40C9FF)
                                ]),
                          barWidth: isHighContrast ? 4 : 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              final isLast =
                                  index == _getSpotsForLineChart().length - 1;
                              return FlDotCirclePainter(
                                radius: isLast ? 5 : 4,
                                color: isHighContrast
                                    ? Colors.black
                                    : Colors.white,
                                strokeWidth: isLast
                                    ? (isHighContrast ? 2 : 4)
                                    : (isHighContrast ? 2 : 0),
                                strokeColor: isHighContrast
                                    ? const Color(0xFFFFD600)
                                    : const Color(0xFF3B82F6).withOpacity(0.5),
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: !isHighContrast,
                            gradient: isHighContrast
                                ? null
                                : LinearGradient(
                                    colors: [
                                      const Color(0xFFE81CFF).withOpacity(0.2),
                                      Colors.transparent
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pinch,
                  color: isHighContrast ? Colors.white : Colors.white54,
                  size: 14),
              const SizedBox(width: 6),
              Text(
                  tr('Pinça para zoom / Arrasta para mover',
                      'Pinch to zoom / Drag to pan'),
                  style: TextStyle(
                      color: isHighContrast ? Colors.white : Colors.white54,
                      fontSize: 11,
                      fontStyle: FontStyle.italic)),
              if (_isZoomed) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _resetZoom,
                  child: Text(tr('Repor', 'Reset'),
                      style: TextStyle(
                          color: isHighContrast
                              ? const Color(0xFFFFD600)
                              : const Color(0xFF3B82F6),
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ]
            ],
          )
        ],
      ),
    );
  }

  List<FlSpot> _getSpotsForLineChart() {
    if (_selectedTrendTime == '24h') {
      return const [
        FlSpot(0, 95),
        FlSpot(1, 130),
        FlSpot(2, 105),
        FlSpot(3, 145),
        FlSpot(4, 110),
        FlSpot(5, 160),
        FlSpot(6, 125)
      ];
    } else if (_selectedTrendTime == '30d') {
      return const [
        FlSpot(0, 130),
        FlSpot(1, 145),
        FlSpot(2, 120),
        FlSpot(3, 140),
        FlSpot(4, 155),
        FlSpot(5, 135),
        FlSpot(6, 120)
      ];
    }
    return const [
      FlSpot(0, 110),
      FlSpot(1, 122),
      FlSpot(2, 118),
      FlSpot(3, 165),
      FlSpot(4, 150),
      FlSpot(5, 115),
      FlSpot(6, 130)
    ];
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
      final labels = isPortuguese
          ? ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']
          : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      text = labels[index];
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(text,
          style: TextStyle(
              color: isHighContrast ? Colors.white : Colors.white54,
              fontSize: 11)),
    );
  }

  Widget _miniPill(String text) {
    final isSelected = _selectedTrendTime == text;
    const neonGradient =
        LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)]);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedTrendTime = text;
          if (text == '24h' || text == '7d') {
            _selectedMainTime = text;
          }
          minX = 0;
          maxX = 6;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected && isHighContrast
              ? const Color(0xFFFFD600)
              : Colors.transparent,
          gradient: isSelected && !isHighContrast ? neonGradient : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text,
            style: TextStyle(
                color: isSelected
                    ? (isHighContrast ? Colors.black : Colors.white)
                    : (isHighContrast ? Colors.white : Colors.white54),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  // --- GRID DE ESTATÍSTICAS (ALINHADO COM HOME = 82%) ---
  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
            child:
                _statCard(tr('Glicemia Média', 'Avg Glucose'), '124', 'mg/dL')),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard(tr('Tempo no Alvo', 'Time in Range'), '82', '%',
                valueColor: isHighContrast
                    ? const Color(0xFFFFD600)
                    : const Color(0xFF2DD4BF))),
        const SizedBox(width: 12),
        Expanded(child: _statCard(tr('HbA1c Est.', 'Est. HbA1c'), '6.8', '%')),
      ],
    );
  }

  Widget _statCard(String title, String value, String unit,
      {Color? valueColor}) {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.05);
    final mainTextColor =
        isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final finalValueColor = valueColor ?? mainTextColor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: borderColor, width: isHighContrast ? 2 : 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: isHighContrast ? Colors.white : Colors.white54,
                  fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: TextStyle(
                      color: finalValueColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 2),
              Text(unit,
                  style: TextStyle(
                      color: isHighContrast ? Colors.white : Colors.white54,
                      fontSize: 10)),
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
    final borderColor = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.05);
    final mainTextColor =
        isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final gridColor = isHighContrast
        ? Colors.white.withOpacity(0.3)
        : Colors.white.withOpacity(0.05);

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
          Text(tr('Padrão Diário', 'Daily Pattern'),
              style: TextStyle(
                  color: mainTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                maxY: 190,
                barTouchData: BarTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(
                      color: gridColor, strokeWidth: isHighContrast ? 2 : 1),
                  checkToShowHorizontalLine: (value) =>
                      [70.0, 100.0, 140.0, 180.0].contains(value),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        if (![70.0, 100.0, 140.0, 180.0].contains(value)) {
                          return const SizedBox();
                        }
                        return Text(value.toInt().toString(),
                            style: TextStyle(
                                color: isHighContrast
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w600));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = [
                          '12 AM',
                          '6 AM',
                          '12 PM',
                          '6 PM',
                          '12 AM'
                        ];
                        if (value.toInt() % 6 == 0 &&
                            value.toInt() ~/ 6 < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(labels[value.toInt() ~/ 6],
                                style: TextStyle(
                                    color: isHighContrast
                                        ? Colors.white
                                        : Colors.white54,
                                    fontSize: 10)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(25, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: barHeights[index].toDouble(),
                        width: 6,
                        color:
                            isHighContrast ? const Color(0xFFFFD600) : null,
                        gradient: isHighContrast
                            ? null
                            : const LinearGradient(
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
    switch (_selectedMainTime) {
      case '3h':
        return [
          100, 105, 110, 120, 115, 110, 105, 100, 95, 105, 115, 125, 135, 140,
          130, 120, 110, 105, 100, 95, 105, 115, 120, 110, 105
        ];
      case '6h':
        return [
          90, 98, 108, 118, 125, 132, 128, 120, 112, 104, 98, 92, 96, 105, 115,
          126, 136, 130, 122, 114, 106, 100, 108, 112, 106
        ];
      case '12h':
        return [
          80, 90, 100, 110, 130, 140, 135, 125, 115, 105, 95, 85, 90, 100, 110,
          120, 130, 125, 115, 105, 95, 85, 90, 100, 110
        ];
      case '24h':
        return [
          75, 82, 92, 108, 118, 134, 126, 112, 138, 128, 116, 102, 96, 104, 114,
          124, 142, 132, 118, 140, 126, 112, 128, 114, 102
        ];
      default:
        return [
          70, 85, 95, 110, 105, 120, 115, 100, 145, 120, 110, 95, 100, 105, 115,
          125, 140, 120, 110, 145, 125, 110, 135, 110, 105
        ];
    }
  }
}