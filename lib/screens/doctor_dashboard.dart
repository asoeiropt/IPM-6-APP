import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_data.dart'; 
import 'doctor_chat_screen.dart'; 

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
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
          Text('Tens 1 alerta crítico e 4 consultas hoje.', style: TextStyle(color: subTextColor, fontSize: 14)),
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('A ligar para João Antunes...', style: TextStyle(color: isHighContrast ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                                    backgroundColor: isHighContrast ? const Color(0xFFFFD600) : Colors.green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
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
                                  patientInitials: 'JA',
                                  initialMessages: [
                                    {'text': 'SOS! Preciso de ajuda. A minha glicemia atual é 68 mg/dL. Contactem o Martim ou o Gui imediatamente!', 'isMe': false, 'time': 'Agora mesmo'}
                                  ],
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

          // Paciente 1 (João Antunes - Consulta Normal com o histórico IGUAL ao telemóvel dele)
          _buildPatientSlot(
            time: '9:30 AM',
            patientName: 'João Antunes',
            type: 'Revisão Mensal (Remarcada)',
            statusColor: const Color(0xFF2DD4BF),
            cardColor: cardColor,
            borderColor: borderColor,
            mainTextColor: mainTextColor,
            subTextColor: subTextColor,
            onChatTapped: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorChatScreen(
                patientName: 'João Antunes',
                patientInitials: 'JA',
                initialMessages: [
                  {'text': 'Olá João! Analisei os teus dados da última semana. A tua glicose parece estável. Continua o excelente trabalho!', 'isMe': true, 'time': '09:12'},
                  {'text': 'Muito obrigado! Tenho uma dúvida sobre a minha dose de insulina de manhã...', 'isMe': false, 'time': '09:20'},
                  {'text': 'Claro! Terei todo o gosto em ajudar. Qual é a tua dose atual e como têm sido as leituras em jejum?', 'isMe': true, 'time': '09:24'}
                ],
              )));
            }
          ),
          
          // Paciente 2 (Maria Silva)
          _buildPatientSlot(
            time: '11:00 AM',
            patientName: 'Maria Silva',
            type: 'Ajuste de Insulina',
            statusColor: const Color(0xFFE81CFF),
            cardColor: cardColor,
            borderColor: borderColor,
            mainTextColor: mainTextColor,
            subTextColor: subTextColor,
            onChatTapped: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorChatScreen(
                patientName: 'Maria Silva',
                patientInitials: 'MS',
                initialMessages: [
                  {'text': 'Dra. Joana, a minha glicemia tem estado alta (200+) depois do almoço esta semana.', 'isMe': false, 'time': 'Ontem'},
                  {'text': 'Olá Maria. Traz o teu diário à consulta para ajustarmos o rácio (ICR) do almoço.', 'isMe': true, 'time': 'Ontem'},
                  {'text': 'Combinado, até amanhã às 11h!', 'isMe': false, 'time': 'Ontem'}
                ],
              )));
            }
          ),

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
    required Color cardColor,
    required Color borderColor,
    required Color mainTextColor,
    required Color subTextColor,
    required VoidCallback onChatTapped, 
  }) {
    return Container(
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
            child: Text(time, style: TextStyle(color: mainTextColor, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          Container(
            width: 3, height: 40,
            color: isHighContrast ? const Color(0xFFFFD600) : statusColor,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patientName, style: TextStyle(color: mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(type, style: TextStyle(color: subTextColor, fontSize: 13)),
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
    );
  }
}