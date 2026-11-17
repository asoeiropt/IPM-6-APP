import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'chat_screen.dart';
import 'trends_screen.dart';
import '../app_data.dart'; 

class CareTab extends StatefulWidget {
  const CareTab({super.key});

  @override
  State<CareTab> createState() => _CareTabState();
}

class _CareTabState extends State<CareTab> {
  // Estado da marcação atual
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1)); // Amanhã
  String _scheduledTime = "9:30 AM";

  // Simulação de slots disponíveis
  final List<String> _availableSlots = ["9:00 AM", "9:30 AM", "11:00 AM", "2:30 PM", "4:00 PM"];
  
  // --- LÓGICA DO BOTÃO SOS (IPM: Segurança e Recuperação) ---
  void _triggerSOS() {
    HapticFeedback.heavyImpact();
    
    String currentGlucose = globalGlucose.isNotEmpty ? globalGlucose.last['value'].toInt().toString() : '---';
    String message = "SOS! Preciso de ajuda. A minha glicemia atual é $currentGlucose mg/dL. Contactem o Martim ou o Gui imediatamente!";
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isHighContrast ? Colors.black : const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent, size: 28),
            const SizedBox(width: 10),
            Text('EMERGÊNCIA', style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A seguinte mensagem será enviada aos teus contactos de emergência:',
              style: TextStyle(color: isHighContrast ? Colors.white : Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isHighContrast ? Colors.grey[900] : Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isHighContrast ? Colors.white : Colors.transparent),
              ),
              child: Text(
                message,
                style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text('CANCELAR', style: TextStyle(color: isHighContrast ? Colors.white : Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent,
              foregroundColor: isHighContrast ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
              
              // APLICADO O TOP SNACKBAR AQUI TAMBÉM
              showTopSnackBar(
                Overlay.of(context),
                CustomSnackBar.success(
                  message: 'Mensagem de SOS enviada com sucesso!',
                  backgroundColor: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF00E676),
                  textStyle: TextStyle(
                    color: isHighContrast ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  iconPositionLeft: 12,
                  iconPositionTop: -10,
                  iconRotationAngle: 0,
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: isHighContrast ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5),
                    size: 60,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                displayDuration: const Duration(seconds: 2),
                reverseAnimationDuration: const Duration(milliseconds: 400),
                animationDuration: const Duration(milliseconds: 600),
              );
            },
            child: const Text('ENVIAR SOS', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // CALENDÁRIO INTERATIVO (BOTTOM SHEET) - UX/HCI HEURISTICS
  // ==============================================================
  void _showCalendarBottomSheet() {
    HapticFeedback.mediumImpact();
    DateTime tempSelectedDate = _scheduledDate;
    String tempSelectedTime = _scheduledTime;

    final bgColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final textColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 24),
                  Text('Reschedule Visit', style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Select an available date and time with Dra. Joana.', style: TextStyle(color: isHighContrast ? Colors.white : Colors.white54, fontSize: 14)),
                  const SizedBox(height: 24),

                  // SCROLL HORIZONTAL DE DIAS
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 14, 
                      itemBuilder: (context, index) {
                        final date = DateTime.now().add(Duration(days: index));
                        final isSelected = date.day == tempSelectedDate.day && date.month == tempSelectedDate.month;
                        
                        final isWeekend = date.weekday == 6 || date.weekday == 7;

                        return GestureDetector(
                          onTap: isWeekend ? null : () {
                            HapticFeedback.selectionClick();
                            setModalState(() {
                              tempSelectedDate = date;
                              tempSelectedTime = "";
                            });
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? (isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6))
                                  : (isHighContrast ? Colors.transparent : Colors.white.withOpacity(0.05)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                    ? Colors.transparent 
                                    : (isHighContrast ? Colors.white38 : Colors.white12),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('E').format(date), 
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : (isWeekend ? Colors.white24 : Colors.white70),
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                  )
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${date.day}', 
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : (isWeekend ? Colors.white24 : Colors.white),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text('Available Slots', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // GRID DE HORAS (SLOTS)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _availableSlots.map((time) {
                      final isSelectedTime = tempSelectedTime == time;
                      
                      // Simula indisponibilidade para UX (Quartas e Sextas estão cheias em certas horas)
                      final isOccupied = (time == "11:00 AM" && tempSelectedDate.weekday == 3) || 
                                         (time == "2:30 PM" && tempSelectedDate.weekday == 5);

                      return GestureDetector(
                        onTap: isOccupied ? null : () {
                          HapticFeedback.lightImpact();
                          setModalState(() {
                            tempSelectedTime = time;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelectedTime 
                                ? (isHighContrast ? const Color(0xFFFFD600) : const Color(0xFFE81CFF))
                                : (isHighContrast ? Colors.transparent : Colors.white.withOpacity(0.05)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelectedTime 
                                  ? Colors.transparent 
                                  : (isHighContrast ? Colors.white38 : Colors.white12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time, size: 16, color: isOccupied ? Colors.white24 : (isSelectedTime ? Colors.black : Colors.white70)),
                              const SizedBox(width: 8),
                              Text(
                                time,
                                style: TextStyle(
                                  color: isOccupied ? Colors.white24 : (isSelectedTime ? Colors.black : Colors.white),
                                  fontWeight: isSelectedTime ? FontWeight.bold : FontWeight.normal,
                                  decoration: isOccupied ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 40),

                  GestureDetector(
                    onTap: tempSelectedTime.isEmpty ? null : () {
                      HapticFeedback.heavyImpact();
                      setState(() {
                        _scheduledDate = tempSelectedDate;
                        _scheduledTime = tempSelectedTime;
                      });
                      Navigator.pop(context);
                      
                      // APLICADO O TOP SNACKBAR AQUI
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.success(
                          message: 'Consulta remarcada com sucesso!',
                          backgroundColor: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF00E676),
                          textStyle: TextStyle(
                            color: isHighContrast ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          iconPositionLeft: 12,
                          iconPositionTop: -10,
                          iconRotationAngle: 0,
                          icon: Icon(
                            Icons.check_circle_outline,
                            color: isHighContrast ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.5),
                            size: 60,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                        ),
                        displayDuration: const Duration(seconds: 2),
                        reverseAnimationDuration: const Duration(milliseconds: 400),
                        animationDuration: const Duration(milliseconds: 600),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: tempSelectedTime.isEmpty 
                            ? Colors.grey.withOpacity(0.5) 
                            : (isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Confirm Appointment', 
                          style: TextStyle(
                            color: tempSelectedTime.isEmpty ? Colors.white54 : (isHighContrast ? Colors.black : Colors.white), 
                            fontSize: 16, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE ALTO CONTRASTE ---
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final mainTextColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : Colors.white54;
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);

    String formattedDate = DateFormat('EEEE').format(_scheduledDate); 

    return Scaffold(
      backgroundColor: bgColor,
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
        children: [
          // --- HEADER & BOTÃO SOS ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Care Hub', style: TextStyle(color: mainTextColor, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Your health team, always close', style: TextStyle(color: subTextColor, fontSize: 14)),
                ],
              ),
              GestureDetector(
                onTap: _triggerSOS,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isHighContrast ? Colors.black : Colors.redAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sos, color: isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- CARTÃO DO MÉDICO ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: isHighContrast ? Colors.transparent : const Color(0xFF387A76),
                          child: Icon(Icons.person, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, size: 30),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF00E676),
                              shape: BoxShape.circle,
                              border: Border.all(color: cardColor, width: 2.5),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dra. Joana Sílvia', style: TextStyle(color: mainTextColor, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Endocrinologista', style: TextStyle(color: subTextColor, fontSize: 14)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.circle, color: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF00E676), size: 10),
                            const SizedBox(width: 6),
                            Text('Online', style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF00E676), fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text('Message'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isHighContrast ? Colors.black : const Color(0xFF1E293B),
                          foregroundColor: isHighContrast ? const Color(0xFFFFD600) : Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: isHighContrast ? const BorderSide(color: Color(0xFFFFD600), width: 2) : BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showCalendarBottomSheet, 
                        icon: const Icon(Icons.calendar_today_outlined, size: 18),
                        label: const Text('Book Visit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF1E3A8A), 
                          foregroundColor: isHighContrast ? Colors.black : Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- BANNER DE MEDICAÇÃO ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: isHighContrast ? Colors.black : null,
              gradient: isHighContrast 
                  ? null 
                  : const LinearGradient(
                      colors: [Color(0xFFD946EF), Color(0xFF6B21A8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              borderRadius: BorderRadius.circular(20),
              border: isHighContrast ? Border.all(color: const Color(0xFFFFD600), width: 2) : null,
            ),
            child: Row(
              children: [
                Transform.rotate(
                  angle: -0.5,
                  child: Icon(Icons.medication, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Text('Medication Refill Due', style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isHighContrast ? const Color(0xFFFFD600) : Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('IN 3 DAYS', style: TextStyle(color: isHighContrast ? Colors.black : Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- CARTÕES QUADRADOS ---
          Row(
            children: [
              // Cartão Next Visit
              Expanded(
                child: GestureDetector(
                  onTap: _showCalendarBottomSheet, 
                  child: Container(
                    height: 160,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isHighContrast ? Colors.black : null,
                      gradient: isHighContrast
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFFF43F5E), Color(0xFFBE185D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(24),
                      border: isHighContrast ? Border.all(color: const Color(0xFFFFD600), width: 2) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.calendar_month_outlined, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, size: 26),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isHighContrast ? const Color(0xFFFFD600) : Colors.black, 
                                shape: BoxShape.circle
                              ),
                              child: Icon(Icons.arrow_forward_ios, color: isHighContrast ? Colors.black : Colors.white, size: 14),
                            )
                          ],
                        ),
                        const Spacer(),
                        Text('Next Visit', style: TextStyle(color: isHighContrast ? Colors.white : Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('$formattedDate\n$_scheduledTime', style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Cartão Health Trend
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TrendsScreen()));
                  },
                  child: Container(
                    height: 160,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isHighContrast ? Colors.black : null,
                      gradient: isHighContrast
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF2DD4BF), Color(0xFF0F766E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(24),
                      border: isHighContrast ? Border.all(color: const Color(0xFFFFD600), width: 2) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.ios_share_rounded, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, size: 26),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(8, (index) {
                            final heights = [10.0, 20.0, 15.0, 30.0, 25.0, 40.0, 20.0, 35.0];
                            return Container(
                              margin: const EdgeInsets.only(right: 4),
                              width: 3,
                              height: heights[index],
                              color: isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.5),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        Text('Health Trend', style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Share Report', style: TextStyle(color: isHighContrast ? Colors.white : Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- PROTOCOLO DIÁRIO ---
          Container(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Protocol', style: TextStyle(color: mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Current Prescribed Doses', style: TextStyle(color: subTextColor, fontSize: 12)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isHighContrast ? Colors.transparent : const Color(0xFF1E3A8A).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: isHighContrast ? Border.all(color: const Color(0xFFFFD600)) : null,
                      ),
                      child: Text('On Track', style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF60A5FA), fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                _buildProtocolItem('Morning Insulin', '8 UNITS', isHighContrast),
                const SizedBox(height: 16),
                _buildProtocolItem('Metformin', '500 MG', isHighContrast),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProtocolItem(String name, String dose, bool isHighContrast) {
    return Row(
      children: [
        Icon(Icons.circle, color: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFFC026D3), size: 8),
        const SizedBox(width: 12),
        Text(name, style: TextStyle(color: isHighContrast ? Colors.white : Colors.white70, fontSize: 14)),
        const Spacer(),
        Text(dose, style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}