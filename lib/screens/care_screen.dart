import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'chat_screen.dart';
import 'trends_screen.dart';
import '../app_data.dart';
import '../fcm_notification_service.dart';

class CareTab extends StatefulWidget {
  const CareTab({super.key});

  @override
  State<CareTab> createState() => _CareTabState();
}

class _CareTabState extends State<CareTab> {
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));
  String _scheduledTime = "9:30 AM";

  final List<String> _availableSlots = [
    "9:00 AM",
    "9:30 AM",
    "11:00 AM",
    "2:30 PM",
    "4:00 PM"
  ];

  String get _patientId =>
      currentUserId.isNotEmpty ? currentUserId : 'paciente_joao';

  String get _patientName =>
      currentUserName.isNotEmpty ? currentUserName : 'João Antunes';

  String get _patientInitials {
    final parts = _patientName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return _patientName.isNotEmpty ? _patientName[0].toUpperCase() : 'P';
  }

  String _formatWeekday(DateTime date) {
    if (!isPortuguese) return DateFormat('EEEE').format(date);
    switch (date.weekday) {
      case 1:
        return 'Segunda-feira';
      case 2:
        return 'Terça-feira';
      case 3:
        return 'Quarta-feira';
      case 4:
        return 'Quinta-feira';
      case 5:
        return 'Sexta-feira';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return '';
    }
  }

  String _formatShortDay(DateTime date) {
    if (!isPortuguese) return DateFormat('E').format(date);
    const days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return days[date.weekday - 1];
  }

  // --- LÓGICA DO BOTÃO SOS (FIRESTORE + CHAT + PUSH) ---
  void _triggerSOS() {
    HapticFeedback.heavyImpact();

    final String currentGlucose = globalGlucose.isNotEmpty
        ? globalGlucose.last['value'].toInt().toString()
        : '---';
    final String message = tr(
      "🚨 SOS! Preciso de ajuda urgente. A minha glicemia atual é $currentGlucose mg/dL.",
      "🚨 SOS! I need urgent help. My current blood glucose is $currentGlucose mg/dL.",
    );

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor:
            isHighContrast ? Colors.black : const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color:
                  isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent,
              width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color:
                    isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent,
                size: 28),
            const SizedBox(width: 10),
            Text(tr('EMERGÊNCIA', 'EMERGENCY'),
                style: TextStyle(
                    color: isHighContrast
                        ? const Color(0xFFFFD600)
                        : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(
                'O alerta será registado na consola médica e enviado à Dra. Joana:',
                'The alert will be logged on the medical dashboard and sent to Dra. Joana:',
              ),
              style: TextStyle(
                  color: isHighContrast ? Colors.white : Colors.white70,
                  fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isHighContrast ? Colors.grey[900] : Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isHighContrast ? Colors.white : Colors.transparent),
              ),
              child: Text(
                message,
                style: TextStyle(
                    color:
                        isHighContrast ? const Color(0xFFFFD600) : Colors.white,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(dialogCtx);
            },
            child: Text(tr('CANCELAR', 'CANCEL'),
                style: TextStyle(
                    color: isHighContrast ? Colors.white : Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent,
              foregroundColor: isHighContrast ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              HapticFeedback.heavyImpact();
              Navigator.pop(dialogCtx);

              try {
                await FirebaseFirestore.instance
                    .collection('sos_alerts')
                    .doc(_patientId)
                    .set({
                  'patientId': _patientId,
                  'patientName': _patientName,
                  'initials': _patientInitials,
                  'glucose': currentGlucose,
                  'message': message,
                  'active': true,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                await FirebaseFirestore.instance
                    .collection('chat_$_patientId')
                    .add({
                  'text': message,
                  'senderId': _patientId,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                await FcmNotificationService.instance.sendPushToUser(
                  targetUserId: 'medica_joana',
                  senderName: '🚨 SOS • $_patientName',
                  messageText: message,
                );
              } catch (e) {
                debugPrint('Erro ao enviar SOS para o Firestore: $e');
              }

              if (!mounted) return;
              showTopSnackBar(
                Overlay.of(context),
                CustomSnackBar.success(
                  message: tr(
                    'Alerta SOS enviado à Dra. Joana!',
                    'SOS alert sent to Dra. Joana!',
                  ),
                  backgroundColor: isHighContrast
                      ? const Color(0xFFFFD600)
                      : const Color(0xFF00E676),
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
                    color: isHighContrast
                        ? Colors.black.withOpacity(0.5)
                        : Colors.white.withOpacity(0.5),
                    size: 60,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                displayDuration: const Duration(seconds: 2),
                reverseAnimationDuration: const Duration(milliseconds: 400),
                animationDuration: const Duration(milliseconds: 600),
              );
            },
            child: Text(tr('ENVIAR SOS', 'SEND SOS'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // CALENDÁRIO INTERATIVO (GRAVA NO FIRESTORE + CHAT + NOTIFICAÇÃO)
  // ==============================================================
  void _showCalendarBottomSheet(DateTime initialDate, String initialTime) {
    HapticFeedback.mediumImpact();
    DateTime tempSelectedDate = initialDate;
    String tempSelectedTime = initialTime;

    final bgColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final textColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 24),
                  Text(tr('Remarcar Consulta', 'Reschedule Visit'),
                      style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      tr(
                        'Seleciona uma data e hora disponível com a Dra. Joana.',
                        'Select an available date and time with Dra. Joana.',
                      ),
                      style: TextStyle(
                          color: isHighContrast ? Colors.white : Colors.white54,
                          fontSize: 14)),
                  const SizedBox(height: 24),

                  // SCROLL HORIZONTAL DE DIAS
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 14,
                      itemBuilder: (context, index) {
                        final date = DateTime.now().add(Duration(days: index));
                        final isSelected = date.day == tempSelectedDate.day &&
                            date.month == tempSelectedDate.month;
                        final isWeekend =
                            date.weekday == 6 || date.weekday == 7;

                        return GestureDetector(
                          onTap: isWeekend
                              ? null
                              : () {
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
                                  ? (isHighContrast
                                      ? const Color(0xFFFFD600)
                                      : const Color(0xFF3B82F6))
                                  : (isHighContrast
                                      ? Colors.transparent
                                      : Colors.white.withOpacity(0.05)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : (isHighContrast
                                        ? Colors.white38
                                        : Colors.white12),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_formatShortDay(date),
                                    style: TextStyle(
                                        color: isSelected
                                            ? Colors.black
                                            : (isWeekend
                                                ? Colors.white24
                                                : Colors.white70),
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal)),
                                const SizedBox(height: 4),
                                Text('${date.day}',
                                    style: TextStyle(
                                        color: isSelected
                                            ? Colors.black
                                            : (isWeekend
                                                ? Colors.white24
                                                : Colors.white),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(tr('Horários Disponíveis', 'Available Slots'),
                      style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // GRID DE HORAS (SLOTS)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _availableSlots.map((time) {
                      final isSelectedTime = tempSelectedTime == time;
                      final isOccupied = (time == "11:00 AM" &&
                              tempSelectedDate.weekday == 3) ||
                          (time == "2:30 PM" && tempSelectedDate.weekday == 5);

                      return GestureDetector(
                        onTap: isOccupied
                            ? null
                            : () {
                                HapticFeedback.lightImpact();
                                setModalState(() {
                                  tempSelectedTime = time;
                                });
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelectedTime
                                ? (isHighContrast
                                    ? const Color(0xFFFFD600)
                                    : const Color(0xFFE81CFF))
                                : (isHighContrast
                                    ? Colors.transparent
                                    : Colors.white.withOpacity(0.05)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelectedTime
                                  ? Colors.transparent
                                  : (isHighContrast
                                      ? Colors.white38
                                      : Colors.white12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time,
                                  size: 16,
                                  color: isOccupied
                                      ? Colors.white24
                                      : (isSelectedTime
                                          ? Colors.black
                                          : Colors.white70)),
                              const SizedBox(width: 8),
                              Text(
                                time,
                                style: TextStyle(
                                  color: isOccupied
                                      ? Colors.white24
                                      : (isSelectedTime
                                          ? Colors.black
                                          : Colors.white),
                                  fontWeight: isSelectedTime
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  decoration: isOccupied
                                      ? TextDecoration.lineThrough
                                      : null,
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
                    onTap: tempSelectedTime.isEmpty
                        ? null
                        : () async {
                            HapticFeedback.heavyImpact();
                            final formattedDateStr =
                                DateFormat('dd/MM/yyyy').format(tempSelectedDate);
                            final weekdayStr = _formatWeekday(tempSelectedDate);

                            setState(() {
                              _scheduledDate = tempSelectedDate;
                              _scheduledTime = tempSelectedTime;
                            });
                            Navigator.pop(sheetCtx);

                            try {
                              await FirebaseFirestore.instance
                                  .collection('appointments')
                                  .doc(_patientId)
                                  .set({
                                'patientId': _patientId,
                                'patientName': _patientName,
                                'initials': _patientInitials,
                                'date': formattedDateStr,
                                'time': tempSelectedTime,
                                'type': tr('Consulta de Endocrinologia',
                                    'Endocrinology Visit'),
                                'isCompleted': false,
                                'updatedBy': _patientName,
                                'updatedAt': FieldValue.serverTimestamp(),
                              }, SetOptions(merge: true));

                              final chatMsg = tr(
                                '📅 Consulta remarcada por $_patientName para $weekdayStr ($formattedDateStr) às $tempSelectedTime.',
                                '📅 Appointment rescheduled by $_patientName to $weekdayStr ($formattedDateStr) at $tempSelectedTime.',
                              );

                              await FirebaseFirestore.instance
                                  .collection('chat_$_patientId')
                                  .add({
                                'text': chatMsg,
                                'senderId': _patientId,
                                'timestamp': FieldValue.serverTimestamp(),
                              });

                              await FcmNotificationService.instance
                                  .sendPushToUser(
                                targetUserId: 'medica_joana',
                                senderName:
                                    '$_patientName • ${tr('Marcação', 'Appointment')}',
                                messageText: chatMsg,
                              );
                            } catch (e) {
                              debugPrint('Erro ao remarcar no Firestore: $e');
                            }

                            if (!mounted) return;
                            showTopSnackBar(
                              Overlay.of(context),
                              CustomSnackBar.success(
                                message: tr(
                                  'Consulta remarcada e Dra. Joana notificada!',
                                  'Visit rescheduled and Dra. Joana notified!',
                                ),
                                backgroundColor: isHighContrast
                                    ? const Color(0xFFFFD600)
                                    : const Color(0xFF00E676),
                                textStyle: TextStyle(
                                  color: isHighContrast
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                iconPositionLeft: 12,
                                iconPositionTop: -10,
                                iconRotationAngle: 0,
                                icon: Icon(
                                  Icons.check_circle_outline,
                                  color: isHighContrast
                                      ? Colors.black.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.5),
                                  size: 60,
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                              ),
                              displayDuration: const Duration(seconds: 2),
                              reverseAnimationDuration:
                                  const Duration(milliseconds: 400),
                              animationDuration:
                                  const Duration(milliseconds: 600),
                            );
                          },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: tempSelectedTime.isEmpty
                            ? Colors.grey.withOpacity(0.5)
                            : (isHighContrast
                                ? const Color(0xFFFFD600)
                                : const Color(0xFF3B82F6)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                            tr('Confirmar Consulta', 'Confirm Appointment'),
                            style: TextStyle(
                                color: tempSelectedTime.isEmpty
                                    ? Colors.white54
                                    : (isHighContrast
                                        ? Colors.black
                                        : Colors.white),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
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
    final mainTextColor =
        isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : Colors.white54;
    final borderColor = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .doc(_patientId)
            .snapshots(),
        builder: (context, snapshot) {
          DateTime displayDate = _scheduledDate;
          String displayTime = _scheduledTime;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data != null) {
              if (data['time'] != null &&
                  data['time'].toString().isNotEmpty) {
                displayTime = data['time'].toString();
              }
              if (data['date'] != null &&
                  data['date'].toString().isNotEmpty) {
                try {
                  displayDate =
                      DateFormat('dd/MM/yyyy').parse(data['date'].toString());
                } catch (_) {}
              }
            }
          }

          final String formattedDate = _formatWeekday(displayDate);

          return ListView(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
            children: [
              // --- HEADER & BOTÃO SOS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('Centro de Saúde', 'Care Hub'),
                          style: TextStyle(
                              color: mainTextColor,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                          tr('A tua equipa clínica, sempre perto',
                              'Your health team, always close'),
                          style: TextStyle(color: subTextColor, fontSize: 14)),
                    ],
                  ),
                  GestureDetector(
                    onTap: _triggerSOS,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isHighContrast
                            ? Colors.black
                            : Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isHighContrast
                                ? const Color(0xFFFFD600)
                                : Colors.redAccent,
                            width: 2),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.sos,
                              color: isHighContrast
                                  ? const Color(0xFFFFD600)
                                  : Colors.redAccent,
                              size: 20),
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
                  border: Border.all(
                      color: borderColor, width: isHighContrast ? 2 : 1),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: isHighContrast
                                  ? Colors.transparent
                                  : const Color(0xFF387A76),
                              child: Icon(Icons.person,
                                  color: isHighContrast
                                      ? const Color(0xFFFFD600)
                                      : Colors.white,
                                  size: 30),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: isHighContrast
                                      ? const Color(0xFFFFD600)
                                      : const Color(0xFF00E676),
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: cardColor, width: 2.5),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dra. Joana Sílvia',
                                style: TextStyle(
                                    color: mainTextColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(
                                tr('Endocrinologista', 'Endocrinologist'),
                                style: TextStyle(
                                    color: subTextColor, fontSize: 14)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.circle,
                                    color: isHighContrast
                                        ? const Color(0xFFFFD600)
                                        : const Color(0xFF00E676),
                                    size: 10),
                                const SizedBox(width: 6),
                                Text('Online',
                                    style: TextStyle(
                                        color: isHighContrast
                                            ? const Color(0xFFFFD600)
                                            : const Color(0xFF00E676),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ChatScreen()));
                            },
                            icon: const Icon(Icons.chat_bubble_outline,
                                size: 18),
                            label: Text(tr('Mensagem', 'Message')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isHighContrast
                                  ? Colors.black
                                  : const Color(0xFF1E293B),
                              foregroundColor: isHighContrast
                                  ? const Color(0xFFFFD600)
                                  : Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: isHighContrast
                                    ? const BorderSide(
                                        color: Color(0xFFFFD600), width: 2)
                                    : BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showCalendarBottomSheet(
                                displayDate, displayTime),
                            icon: const Icon(Icons.calendar_today_outlined,
                                size: 18),
                            label: Text(tr('Marcar', 'Book Visit')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isHighContrast
                                  ? const Color(0xFFFFD600)
                                  : const Color(0xFF1E3A8A),
                              foregroundColor:
                                  isHighContrast ? Colors.black : Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                  border: isHighContrast
                      ? Border.all(color: const Color(0xFFFFD600), width: 2)
                      : null,
                ),
                child: Row(
                  children: [
                    Transform.rotate(
                      angle: -0.5,
                      child: Icon(Icons.medication,
                          color: isHighContrast
                              ? const Color(0xFFFFD600)
                              : Colors.white,
                          size: 28),
                    ),
                    const SizedBox(width: 12),
                    Text(
                        tr('Renovação de Receita',
                            'Medication Refill Due'),
                        style: TextStyle(
                            color: isHighContrast
                                ? const Color(0xFFFFD600)
                                : Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isHighContrast
                            ? const Color(0xFFFFD600)
                            : Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(tr('EM 3 DIAS', 'IN 3 DAYS'),
                          style: TextStyle(
                              color:
                                  isHighContrast ? Colors.black : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- CARTÕES QUADRADOS ---
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          _showCalendarBottomSheet(displayDate, displayTime),
                      child: Container(
                        height: 160,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isHighContrast ? Colors.black : null,
                          gradient: isHighContrast
                              ? null
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFFF43F5E),
                                    Color(0xFFBE185D)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(24),
                          border: isHighContrast
                              ? Border.all(
                                  color: const Color(0xFFFFD600), width: 2)
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.calendar_month_outlined,
                                    color: isHighContrast
                                        ? const Color(0xFFFFD600)
                                        : Colors.white,
                                    size: 26),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                      color: isHighContrast
                                          ? const Color(0xFFFFD600)
                                          : Colors.black,
                                      shape: BoxShape.circle),
                                  child: Icon(Icons.arrow_forward_ios,
                                      color: isHighContrast
                                          ? Colors.black
                                          : Colors.white,
                                      size: 14),
                                )
                              ],
                            ),
                            const Spacer(),
                            Text(tr('Próxima Consulta', 'Next Visit'),
                                style: TextStyle(
                                    color: isHighContrast
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 13)),
                            const SizedBox(height: 4),
                            Text('$formattedDate\n$displayTime',
                                style: TextStyle(
                                    color: isHighContrast
                                        ? const Color(0xFFFFD600)
                                        : Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const TrendsScreen()));
                      },
                      child: Container(
                        height: 160,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isHighContrast ? Colors.black : null,
                          gradient: isHighContrast
                              ? null
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF2DD4BF),
                                    Color(0xFF0F766E)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(24),
                          border: isHighContrast
                              ? Border.all(
                                  color: const Color(0xFFFFD600), width: 2)
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.ios_share_rounded,
                                color: isHighContrast
                                    ? const Color(0xFFFFD600)
                                    : Colors.white,
                                size: 26),
                            const Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(8, (index) {
                                final heights = [
                                  10.0,
                                  20.0,
                                  15.0,
                                  30.0,
                                  25.0,
                                  40.0,
                                  20.0,
                                  35.0
                                ];
                                return Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  width: 3,
                                  height: heights[index],
                                  color: isHighContrast
                                      ? const Color(0xFFFFD600)
                                      : Colors.white.withOpacity(0.5),
                                );
                              }),
                            ),
                            const SizedBox(height: 12),
                            Text(tr('Tendência Glicémica', 'Health Trend'),
                                style: TextStyle(
                                    color: isHighContrast
                                        ? const Color(0xFFFFD600)
                                        : Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(tr('Ver Relatório', 'Share Report'),
                                style: TextStyle(
                                    color: isHighContrast
                                        ? Colors.white
                                        : Colors.white70,
                                    fontSize: 12)),
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
                  border: Border.all(
                      color: borderColor, width: isHighContrast ? 2 : 1),
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
                            Text(tr('Protocolo Diário', 'Daily Protocol'),
                                style: TextStyle(
                                    color: mainTextColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(
                                tr('Doses Atuais Prescritas',
                                    'Current Prescribed Doses'),
                                style: TextStyle(
                                    color: subTextColor, fontSize: 12)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isHighContrast
                                ? Colors.transparent
                                : const Color(0xFF1E3A8A).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: isHighContrast
                                ? Border.all(color: const Color(0xFFFFD600))
                                : null,
                          ),
                          child: Text(tr('Em Dia', 'On Track'),
                              style: TextStyle(
                                  color: isHighContrast
                                      ? const Color(0xFFFFD600)
                                      : const Color(0xFF60A5FA),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildProtocolItem(
                        tr('Insulina Matinal', 'Morning Insulin'),
                        tr('8 UNIDADES', '8 UNITS'),
                        isHighContrast),
                    const SizedBox(height: 16),
                    _buildProtocolItem(
                        tr('Metformina', 'Metformin'), '500 MG', isHighContrast),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildProtocolItem(String name, String dose, bool isHighContrast) {
    return Row(
      children: [
        Icon(Icons.circle,
            color: isHighContrast
                ? const Color(0xFFFFD600)
                : const Color(0xFFC026D3),
            size: 8),
        const SizedBox(width: 12),
        Text(name,
            style: TextStyle(
                color: isHighContrast ? Colors.white : Colors.white70,
                fontSize: 14)),
        const Spacer(),
        Text(dose,
            style: TextStyle(
                color: isHighContrast ? const Color(0xFFFFD600) : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}