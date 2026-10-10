import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../constants.dart';
import '../app_data.dart';

// ==========================================
// WIDGET REUTILIZÁVEL: EFEITO GLASSMORPHISM
// ==========================================
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(20.0)});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: cardDark.withOpacity(0.6), 
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)), 
          ),
          child: child,
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  
  double _calculateIOB() {
    double totalIob = 0.0; DateTime now = DateTime.now();
    for (var item in globalDiary) {
      if (item['insulin'] != null && item['insulin'] > 0) {
        List<String> timeParts = item['time'].split(':');
        if (timeParts.length == 2) {
          DateTime recordTime = DateTime(now.year, now.month, now.day, int.parse(timeParts[0]), int.parse(timeParts[1]));
          Duration diff = now.difference(recordTime);
          if (diff.inMinutes >= 0 && diff.inMinutes < 240) { double remaining = 1.0 - (diff.inMinutes / 240.0); totalIob += (item['insulin'] * remaining); }
        }
      }
    }
    return totalIob;
  }

  @override
  Widget build(BuildContext context) {
    double currentIob = _calculateIOB(); 
    double currentGlucose = 115.0; 
    
    double predictedGlucose = currentGlucose - (currentIob * globalIsf);
    if (predictedGlucose < 40) predictedGlucose = 40; 

    return SingleChildScrollView( 
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(flex: 2, child: GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('🩸 CURRENT GLUCOSE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: textMuted)), Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 8)]))]), const SizedBox(height: 12), const Text('115', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: textMain, letterSpacing: -1)), const SizedBox(height: 4), Row(children: [Text('mg/dL', style: TextStyle(fontSize: 13, color: textMuted)), const Spacer(), const Text('Stable', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w500))])]))), 
            const SizedBox(width: 12), 
            Expanded(flex: 1, child: GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text('💉 IOB', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: textMuted)), const SizedBox(height: 16), Text(currentIob.toStringAsFixed(1), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textMain, letterSpacing: -0.5)), const SizedBox(height: 4), Text('Units', style: TextStyle(fontSize: 11, color: textMuted))])))]),
          const SizedBox(height: 24), 
          
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                const Text('📈 Trend & Prediction (+2h)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textMain)), 
                const SizedBox(height: 24), 
                SizedBox(
                  height: 180, 
                  child: LineChart(LineChartData(
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              '${spot.y.toInt()} mg/dL\n',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              children: [
                                TextSpan(
                                  text: spot.x == 6 ? 'Now' : (spot.x > 6 ? '+${(spot.x - 6).toInt()}h' : '${(6 - spot.x).toInt()}h ago'),
                                  style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.normal),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                    minY: 40, maxY: 250, minX: 0, maxX: 8, 
                    gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1)), 
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) { 
                        switch (v.toInt()) { 
                          case 0: return Text('10h', style: TextStyle(color: textMuted, fontSize: 10)); 
                          case 2: return Text('12h', style: TextStyle(color: textMuted, fontSize: 10)); 
                          case 4: return Text('14h', style: TextStyle(color: textMuted, fontSize: 10)); 
                          case 6: return Text('Now', style: TextStyle(color: textMain, fontSize: 10, fontWeight: FontWeight.bold)); 
                          case 8: return Text('+2h', style: TextStyle(color: accentBlue, fontSize: 10, fontWeight: FontWeight.bold)); 
                        } 
                        return const Text(''); 
                      }))
                    ), 
                    borderData: FlBorderData(show: false), 
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true, color: Colors.white, barWidth: 2.5, isStrokeCapRound: true, 
                        dotData: const FlDotData(show: false), 
                        belowBarData: BarAreaData(show: true, color: Colors.white.withOpacity(0.03)), 
                        spots: const [FlSpot(0, 110), FlSpot(1, 140), FlSpot(2, 175), FlSpot(3, 145), FlSpot(4, 95), FlSpot(5, 105), FlSpot(6, 115)]
                      ),
                      LineChartBarData(
                        isCurved: true, color: accentBlue, barWidth: 2.5, isStrokeCapRound: true, dashArray: [6, 4], 
                        dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: bgDark, strokeWidth: 2, strokeColor: accentBlue)), 
                        belowBarData: BarAreaData(show: false), 
                        spots: [FlSpot(6, currentGlucose), FlSpot(7, currentGlucose - ((currentGlucose - predictedGlucose) / 2)), FlSpot(8, predictedGlucose)]
                      )
                    ], 
                    extraLinesData: ExtraLinesData(horizontalLines: [HorizontalLine(y: 180, color: Colors.orange.withOpacity(0.2), strokeWidth: 1, dashArray: [4, 4]), HorizontalLine(y: 70, color: Colors.red.withOpacity(0.2), strokeWidth: 1, dashArray: [4, 4])])
                  ))
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdvancedChartScreen())),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Advanced Analytics'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: borderDark),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)) 
                    ),
                  ),
                )
              ]
            )
          ),
          
          const SizedBox(height: 16), 
          
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  height: 60, width: 60,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 15,
                      sections: [
                        PieChartSectionData(color: Colors.greenAccent, value: 85, title: '', radius: 8),
                        PieChartSectionData(color: Colors.orangeAccent, value: 10, title: '', radius: 8),
                        PieChartSectionData(color: Colors.redAccent, value: 5, title: '', radius: 8),
                      ]
                    )
                  )
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.greenAccent, size: 14),
                          const SizedBox(width: 6),
                          Text('Optimal Control', style: TextStyle(color: Colors.grey.shade300, fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('85% time-in-range today. Keep it up!', style: TextStyle(color: textMuted, fontSize: 11)),
                    ],
                  )
                )
              ]
            )
          ),
          const SizedBox(height: 80), 
      ]),
    );
  }
}

class AdvancedChartScreen extends StatefulWidget {
  const AdvancedChartScreen({super.key});

  @override
  State<AdvancedChartScreen> createState() => _AdvancedChartScreenState();
}

class _AdvancedChartScreenState extends State<AdvancedChartScreen> {
  String _timeRange = '3 day'; 

  List<FlSpot> _getChartData() {
    if (_timeRange == 'Day') return const [FlSpot(0, 95), FlSpot(1, 140), FlSpot(2, 110), FlSpot(3, 85), FlSpot(4, 160), FlSpot(5, 120)];
    if (_timeRange == 'Months') return const [FlSpot(0, 110), FlSpot(1, 115), FlSpot(2, 105), FlSpot(3, 125), FlSpot(4, 110), FlSpot(5, 115)];
    return const [FlSpot(0, 85), FlSpot(1, 110), FlSpot(2, 160), FlSpot(3, 130), FlSpot(4, 145), FlSpot(5, 190), FlSpot(6, 120)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: const Text('Advanced Analytics', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: textMain)),
        backgroundColor: bgDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: textMain),
        shape: Border(bottom: BorderSide(color: borderDark, width: 1)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cardDark, 
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: borderDark)
              ),
              child: Row(
                children: ['Day', '3 day', 'Months'].map((range) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _timeRange = range),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _timeRange == range ? Colors.white.withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(range, style: TextStyle(fontWeight: FontWeight.w600, color: _timeRange == range ? Colors.white : textMuted)),
                    )
                  )
                )).toList()
              )
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  
                  GlassCard( 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        const Text('Blood glucose', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)), 
                        const SizedBox(height: 32), 
                        SizedBox(
                          height: 250, 
                          child: LineChart(
                            LineChartData(
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipItems: (touchedSpots) => touchedSpots.map((spot) => LineTooltipItem('${spot.y.toInt()}\n', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))).toList(),
                                )
                              ),
                              minY: 50, maxY: 250, minX: 0, maxX: _timeRange == '3 day' ? 6 : 5, 
                              rangeAnnotations: RangeAnnotations(
                                horizontalRangeAnnotations: [
                                  HorizontalRangeAnnotation(y1: 50, y2: 70, color: Colors.red.withOpacity(0.15)),
                                  HorizontalRangeAnnotation(y1: 70, y2: 180, color: Colors.green.withOpacity(0.10)),
                                ],
                              ),
                              gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: borderDark, strokeWidth: 1)), 
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35, getTitlesWidget: (v, m) {
                                  if (v == 50 || v == 100 || v == 150 || v == 200 || v == 250) {
                                    return Text(v.toInt().toString(), style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold));
                                  }
                                  return const Text('');
                                })), 
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) { 
                                  switch (v.toInt()) { 
                                    case 1: return Text('1 AM', style: TextStyle(color: textMuted, fontSize: 10)); 
                                    case 3: return Text('1 PM', style: TextStyle(color: textMuted, fontSize: 10)); 
                                    case 5: return Text('12 PM', style: TextStyle(color: textMuted, fontSize: 10)); 
                                  } 
                                  return const Text(''); 
                                }))
                              ), 
                              borderData: FlBorderData(show: false), 
                              lineBarsData: [
                                LineChartBarData(
                                  isCurved: true, 
                                  color: Colors.white, 
                                  barWidth: 2.5, 
                                  isStrokeCapRound: true, 
                                  dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 3, color: bgDark, strokeWidth: 2, strokeColor: Colors.white)), 
                                  belowBarData: BarAreaData(show: false), 
                                  spots: _getChartData()
                                )
                              ], 
                            )
                          )
                        )
                      ]
                    )
                  ),
                  
                  const SizedBox(height: 24), 
                  
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('📅 30-Day Control Heatmap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            Icon(Icons.calendar_month, color: textMuted, size: 20),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Green: In Target • Orange: Hyper • Red: Hypo', style: TextStyle(color: textMuted, fontSize: 11)),
                        const SizedBox(height: 24),
                        
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                          itemCount: 35, 
                          itemBuilder: (context, index) {
                            Color boxColor = Colors.greenAccent.withOpacity(0.7); 
                            
                            if (index == 5 || index == 12 || index == 22 || index == 29) boxColor = Colors.orangeAccent.withOpacity(0.8);
                            if (index == 8 || index == 18 || index == 27) boxColor = Colors.redAccent.withOpacity(0.8);
                            
                            if (index > 30) boxColor = Colors.white.withOpacity(0.05);

                            return Tooltip(
                              message: index > 30 ? 'Future' : 'Day ${index + 1}\nTap for details',
                              child: Container(
                                decoration: BoxDecoration(
                                  color: boxColor,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                  boxShadow: index <= 30 ? [
                                    BoxShadow(color: boxColor.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                                  ] : [],
                                ),
                                child: Center(
                                  child: Text(
                                    index <= 30 ? '${index + 1}' : '',
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.6), 
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24), 
                  const Text('Detailed Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: const EdgeInsets.all(16), 
                    child: Row(
                      children: [
                        Container(width: 4, height: 40, decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('On-target duration', style: TextStyle(color: textMuted, fontSize: 13)),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text('85', style: TextStyle(color: textMain, fontSize: 24, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Text('%', style: TextStyle(color: textMuted, fontSize: 14)),
                              ],
                            )
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Avg Glucose', style: TextStyle(color: textMuted, fontSize: 13)),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text('115', style: TextStyle(color: textMain, fontSize: 24, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Text('mg/dL', style: TextStyle(color: textMuted, fontSize: 14)),
                              ],
                            )
                          ],
                        )
                      ]
                    )
                  ),
                  const SizedBox(height: 80),
                ]
              ),
            ),
          ),
        ],
      ),
    );
  }
}