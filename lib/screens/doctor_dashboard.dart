import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; 
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../app_data.dart'; 
import 'doctor_chat_screen.dart'; 

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  // --- ESTADO DINÂMICO DAS CONSULTAS ---
  final List _appointments = [
    {
      'time': '9:30 AM',
      'patientName': 'João Antunes',
      'type': 'Revisão Mensal (Remarcada)',
      'statusColor': const Color(0xFF2DD4BF),
      'initials': 'JA',
      'isCompleted': false,
    },
    {
      'time': '11:00 AM',
      'patientName': 'Maria Silva',
      'type': 'Ajuste de Insulina',
      'statusColor': const Color(0xFFE81CFF),
      'initials': 'MS',
      'isCompleted': false,
    }
  ];

  final List<String> _availableSlots = ["9:00 AM", "9:30 AM", "11:00 AM", "2:30 PM", "4:00 PM"];

  // ==============================================================
  // CALENDÁRIO INTERATIVO DIRETO (IGUAL AO DO PACIENTE)
  // ==============================================================
  void _showCalendarBottomSheet(int appointmentIndex) {
    HapticFeedback.mediumImpact();
    final appt = _appointments[appointmentIndex];
    
    DateTime tempSelectedDate = DateTime.now().add(const Duration(days: 1)); // Amanhã
    String tempSelectedTime = ""; // Começa vazio para obrigar a escolher

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
                  Text('Remarcar Consulta', style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Seleciona uma data e hora para ${appt['patientName']}.', style: TextStyle(color: isHighContrast ? Colors.white : Colors.white54, fontSize: 14)),
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
                        // Atualiza a hora no cartão da médica
                        _appointments[appointmentIndex]['time'] = tempSelectedTime;
                      });
                      Navigator.pop(context);
                      
                      // O TEU TOP SNACKBAR AQUI (Igual ao do CareTab)
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
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final mainTextColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : Colors.white54;
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Row(
          children: [
            Icon(Icons.medical_services, color: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF2DD4BF)),
            const SizedBox(width: 8),
            Text('SmartGlyco Pro', style: TextStyle(color: mainTextColor, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: subTextColor),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context); 
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Olá, Dra. Joana 👋', style: TextStyle(color: mainTextColor, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Tens 1 alerta crítico e ${_appointments.length} consultas hoje.', style: TextStyle(color: subTextColor, fontSize: 14)),
          const SizedBox(height: 24),

          // --- ALERTA SOS ---
          Text('Alertas Urgentes', style: TextStyle(color: mainTextColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isHighContrast ? Colors.black : Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent, width: 2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  child: const Icon(Icons.sos, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('João Antunes', style: TextStyle(color: mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Agora', style: TextStyle(color: isHighContrast ? Colors.white : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Glicemia a 68 mg/dL em queda. O paciente acionou o SOS no Care Hub.', style: TextStyle(color: subTextColor, fontSize: 13, height: 1.4)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.heavyImpact();
                              },
                              icon: const Icon(Icons.call, size: 18),
                              label: const Text('Ligar', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent,
                                foregroundColor: isHighContrast ? Colors.black : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorChatScreen(
                                  patientName: 'João Antunes',
                                  patientInitials: 'JA', initialMessages: [],
                                )));
                              },
                              icon: const Icon(Icons.chat_bubble_outline, size: 18),
                              label: const Text('Chat SOS', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isHighContrast ? Colors.black : Colors.redAccent.withOpacity(0.15),
                                foregroundColor: isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent.withOpacity(0.5)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),

          // --- CALENDÁRIO DE PACIENTES ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Consultas de Hoje', style: TextStyle(color: mainTextColor, fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(Icons.calendar_month, color: subTextColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),

          // Gera a lista de consultas dinamicamente
          ...List.generate(_appointments.length, (index) {
            final appt = _appointments[index];
            return _buildPatientSlot(
              time: appt['time'],
              patientName: appt['patientName'],
              type: appt['type'],
              statusColor: appt['statusColor'],
              isCompleted: appt['isCompleted'],
              cardColor: cardColor,
              borderColor: borderColor,
              mainTextColor: mainTextColor,
              subTextColor: subTextColor,
              onCardTapped: () => _showCalendarBottomSheet(index), // <-- AGORA ABRE O CALENDÁRIO DIRETAMENTE
              onChatTapped: () { 
                Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorChatScreen(
                  patientName: appt['patientName'],
                  patientInitials: appt['initials'], initialMessages: [],
                )));
              }
            );
          }),

          // Slot Livre
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isHighContrast ? Colors.transparent : Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, style: BorderStyle.solid),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text('2:30 PM', style: TextStyle(color: subTextColor, fontWeight: FontWeight.bold)),
                ),
                Container(width: 2, height: 30, color: borderColor, margin: const EdgeInsets.symmetric(horizontal: 12)),
                Text('Slot Livre', style: TextStyle(color: subTextColor, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientSlot({
    required String time, 
    required String patientName, 
    required String type, 
    required Color statusColor,
    required bool isCompleted,
    required Color cardColor,
    required Color borderColor,
    required Color mainTextColor,
    required Color subTextColor,
    required VoidCallback onCardTapped,
    required VoidCallback onChatTapped, 
  }) {
    final double opacity = isCompleted ? 0.4 : 1.0;

    return GestureDetector(
      onTap: onCardTapped,
      child: Opacity(
        opacity: opacity,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(time, style: TextStyle(
                  color: isCompleted ? subTextColor : mainTextColor, 
                  fontWeight: FontWeight.bold, fontSize: 14,
                  decoration: isCompleted ? TextDecoration.lineThrough : null, 
                )),
              ),
              Container(
                width: 3, height: 40,
                color: isCompleted ? Colors.grey : (isHighContrast ? const Color(0xFFFFD600) : statusColor),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patientName, style: TextStyle(color: mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(isCompleted ? 'Concluída' : type, style: TextStyle(color: subTextColor, fontSize: 13)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onChatTapped(); 
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.transparent, 
                  child: Icon(Icons.chat_bubble, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white24, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}