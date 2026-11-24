import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../app_data.dart';
import '../fcm_notification_service.dart';
import 'doctor_chat_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final List<String> _availableSlots = [
    "9:00 AM",
    "9:30 AM",
    "11:00 AM",
    "2:30 PM",
    "4:00 PM"
  ];

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

  Future<void> _rescheduleAppointment({
    required String docId,
    required Map<String, dynamic> appt,
    required DateTime newDate,
    required String newTime,
  }) async {
    final String formattedDate = DateFormat('dd/MM/yyyy').format(newDate);
    final String weekdayStr = _formatWeekday(newDate);
    final String patientName =
        (appt['patientName'] ?? tr('Paciente', 'Patient')).toString();

    final String patientId = (appt['patientId'] != null &&
            appt['patientId'].toString().isNotEmpty)
        ? appt['patientId'].toString()
        : (patientName.contains('Maria') ? 'paciente_maria' : 'paciente_joao');

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .set({
        'patientId': patientId,
        'patientName': patientName,
        'date': formattedDate,
        'time': newTime,
        'updatedBy': 'Dra. Joana Sílvia',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final String chatMsg = tr(
        '📅 A Dra. Joana Sílvia remarcou a tua consulta para $weekdayStr ($formattedDate) às $newTime.',
        '📅 Dra. Joana Sílvia rescheduled your appointment to $weekdayStr ($formattedDate) at $newTime.',
      );

      await FirebaseFirestore.instance.collection('chat_$patientId').add({
        'text': chatMsg,
        'senderId': currentUserId.isNotEmpty ? currentUserId : 'medica_joana',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FcmNotificationService.instance.sendPushToUser(
        targetUserId: patientId,
        senderName:
            'Dra. Joana Sílvia • ${tr('Consulta', 'Appointment')}',
        messageText: chatMsg,
      );
    } catch (e) {
      debugPrint("Erro ao remarcar consulta e notificar: $e");
    }
  }

  void _showCalendarBottomSheet(String docId, Map<String, dynamic> appt) {
    HapticFeedback.mediumImpact();

    DateTime tempSelectedDate = DateTime.now().add(const Duration(days: 1));
    String tempSelectedTime = "";

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
                  Text(tr('Remarcar Consulta', 'Reschedule Appointment'),
                      style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      tr(
                        'Seleciona uma data e hora para ${appt['patientName']}.',
                        'Select a date and time for ${appt['patientName']}.',
                      ),
                      style: TextStyle(
                          color: isHighContrast ? Colors.white : Colors.white54,
                          fontSize: 14)),
                  const SizedBox(height: 24),
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
                            Navigator.pop(sheetCtx);

                            await _rescheduleAppointment(
                              docId: docId,
                              appt: appt,
                              newDate: tempSelectedDate,
                              newTime: tempSelectedTime,
                            );

                            if (!mounted) return;
                            showTopSnackBar(
                              Overlay.of(context),
                              CustomSnackBar.success(
                                message: tr(
                                  'Consulta remarcada e paciente notificado!',
                                  'Appointment rescheduled and patient notified!',
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.medical_services,
                color: isHighContrast
                    ? const Color(0xFFFFD600)
                    : const Color(0xFF2DD4BF)),
            const SizedBox(width: 8),
            Text('SmartGlyco Pro',
                style: TextStyle(
                    color: mainTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 4.0),
            child: GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorProfileScreen(
                      onSettingsChanged: () {
                        if (mounted) setState(() {});
                      },
                    ),
                  ),
                );
                if (mounted) setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isHighContrast ? mainTextColor : Colors.white24,
                      width: 1),
                ),
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: isHighContrast
                      ? const Color(0xFFFFD600)
                      : const Color(0xFF387A76),
                  child: Icon(Icons.person,
                      color: isHighContrast ? Colors.black : Colors.white,
                      size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('appointments').snapshots(),
        builder: (context, apptSnapshot) {
          if (apptSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = apptSnapshot.data?.docs ?? [];

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('sos_alerts')
                .where('active', isEqualTo: true)
                .snapshots(),
            builder: (context, sosSnapshot) {
              final sosDocs = sosSnapshot.data?.docs ?? [];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(tr('Olá, Dra. Joana 👋', 'Hello, Dra. Joana 👋'),
                      style: TextStyle(
                          color: mainTextColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                      tr(
                        'Tens ${sosDocs.length} alerta(s) urgente(s) e ${docs.length} consulta(s) agendada(s).',
                        'You have ${sosDocs.length} urgent alert(s) and ${docs.length} scheduled appointment(s).',
                      ),
                      style: TextStyle(color: subTextColor, fontSize: 14)),
                  const SizedBox(height: 24),
                  Text(tr('Alertas Urgentes', 'Urgent Alerts'),
                      style: TextStyle(
                          color: mainTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (sosDocs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: isHighContrast
                                  ? const Color(0xFFFFD600)
                                  : const Color(0xFF2DD4BF)),
                          const SizedBox(width: 12),
                          Text(
                              tr(
                                'Sem alertas SOS ativos neste momento.',
                                'No active SOS alerts at this moment.',
                              ),
                              style:
                                  TextStyle(color: subTextColor, fontSize: 13)),
                        ],
                      ),
                    )
                  else
                    ...sosDocs.map((sosDoc) {
                      final sos = sosDoc.data() as Map<String, dynamic>;
                      final String pName =
                          (sos['patientName'] ?? tr('Paciente', 'Patient'))
                              .toString();
                      final String pId =
                          (sos['patientId'] ?? sosDoc.id).toString();
                      final String pInitials =
                          (sos['initials'] ?? 'P').toString();
                      final String glucose =
                          (sos['glucose'] ?? '---').toString();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isHighContrast
                              ? Colors.black
                              : Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isHighContrast
                                  ? const Color(0xFFFFD600)
                                  : Colors.redAccent,
                              width: 2),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.sos,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(pName,
                                          style: TextStyle(
                                              color: mainTextColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      GestureDetector(
                                        onTap: () async {
                                          await FirebaseFirestore.instance
                                              .collection('sos_alerts')
                                              .doc(sosDoc.id)
                                              .update({'active': false});
                                        },
                                        child: Text(
                                            tr('Resolver', 'Resolve'),
                                            style: TextStyle(
                                                color: isHighContrast
                                                    ? Colors.white
                                                    : Colors.redAccent,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                      tr(
                                        'Glicemia a $glucose mg/dL. O paciente acionou o SOS no Care Hub.',
                                        'Glucose at $glucose mg/dL. The patient triggered SOS in Care Hub.',
                                      ),
                                      style: TextStyle(
                                          color: subTextColor,
                                          fontSize: 13,
                                          height: 1.4)),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            HapticFeedback.heavyImpact();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(tr(
                                                  '📞 A iniciar chamada de emergência para $pName...',
                                                  '📞 Starting emergency call to $pName...',
                                                )),
                                              ),
                                            );
                                          },
                                          icon:
                                              const Icon(Icons.call, size: 18),
                                          label: Text(tr('Ligar', 'Call'),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isHighContrast
                                                ? const Color(0xFFFFD600)
                                                : Colors.redAccent,
                                            foregroundColor: isHighContrast
                                                ? Colors.black
                                                : Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            HapticFeedback.lightImpact();
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        DoctorChatScreen(
                                                          patientName: pName,
                                                          patientInitials:
                                                              pInitials,
                                                          patientId: pId,
                                                          initialMessages:
                                                              const [],
                                                        )));
                                          },
                                          icon: const Icon(
                                              Icons.chat_bubble_outline,
                                              size: 18),
                                          label: Text(
                                              tr('Chat SOS', 'SOS Chat'),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isHighContrast
                                                ? Colors.black
                                                : Colors.redAccent
                                                    .withOpacity(0.15),
                                            foregroundColor: isHighContrast
                                                ? const Color(0xFFFFD600)
                                                : Colors.redAccent,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              side: BorderSide(
                                                  color: isHighContrast
                                                      ? const Color(0xFFFFD600)
                                                      : Colors.redAccent
                                                          .withOpacity(0.5)),
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
                      );
                    }),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          tr('Consultas Agendadas', 'Scheduled Appointments'),
                          style: TextStyle(
                              color: mainTextColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Icon(Icons.calendar_month, color: subTextColor, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (docs.isEmpty)
                    Text(
                        tr('Sem consultas agendadas.',
                            'No scheduled appointments.'),
                        style: TextStyle(color: subTextColor))
                  else
                    ...docs.map((doc) {
                      final appt = doc.data() as Map<String, dynamic>;
                      final docId = doc.id;

                      Color statusColor = const Color(0xFF2DD4BF);
                      if (appt['initials'] == 'MS') {
                        statusColor = const Color(0xFFE81CFF);
                      }

                      final String dateLabel =
                          appt['date'] != null ? ' • ${appt['date']}' : '';

                      return _buildPatientSlot(
                          time: appt['time'] ?? '9:30 AM',
                          patientName:
                              appt['patientName'] ?? tr('Paciente', 'Patient'),
                          type:
                              '${appt['type'] ?? tr('Consulta', 'Appointment')}$dateLabel',
                          statusColor: statusColor,
                          isCompleted: appt['isCompleted'] ?? false,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          mainTextColor: mainTextColor,
                          subTextColor: subTextColor,
                          onCardTapped: () =>
                              _showCalendarBottomSheet(docId, appt),
                          onChatTapped: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => DoctorChatScreen(
                                          patientName: appt['patientName'] ??
                                              tr('Paciente', 'Patient'),
                                          patientInitials:
                                              appt['initials'] ?? 'P',
                                          patientId:
                                              (appt['patientId'] ?? docId)
                                                  .toString(),
                                          initialMessages: const [],
                                        )));
                          });
                    }),
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isHighContrast
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: borderColor, style: BorderStyle.solid),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 70,
                          child: Text('2:30 PM',
                              style: TextStyle(
                                  color: subTextColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Container(
                            width: 2,
                            height: 30,
                            color: borderColor,
                            margin: const EdgeInsets.symmetric(horizontal: 12)),
                        Text(tr('Slot Livre', 'Free Slot'),
                            style: TextStyle(
                                color: subTextColor,
                                fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
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
            border: Border.all(
                color: borderColor, width: isHighContrast ? 2 : 1),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(time,
                    style: TextStyle(
                      color: isCompleted ? subTextColor : mainTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    )),
              ),
              Container(
                width: 3,
                height: 40,
                color: isCompleted
                    ? Colors.grey
                    : (isHighContrast
                        ? const Color(0xFFFFD600)
                        : statusColor),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patientName,
                        style: TextStyle(
                            color: mainTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(isCompleted ? tr('Concluída', 'Completed') : type,
                        style: TextStyle(color: subTextColor, fontSize: 13)),
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
                  child: Icon(Icons.chat_bubble,
                      color: isHighContrast
                          ? const Color(0xFFFFD600)
                          : Colors.white24,
                      size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}