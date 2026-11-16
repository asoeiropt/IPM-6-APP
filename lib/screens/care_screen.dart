import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chat_screen.dart';
import 'trends_screen.dart';
import '../app_data.dart'; // Importante para aceder ao isHighContrast e aos dados de glicose

class CareTab extends StatefulWidget {
  const CareTab({super.key});

  @override
  State<CareTab> createState() => _CareTabState();
}

class _CareTabState extends State<CareTab> {
  
  // --- LÓGICA DO BOTÃO SOS (IPM: Segurança e Recuperação) ---
  void _triggerSOS() {
    HapticFeedback.heavyImpact();
    
    // Calcula a glicemia atual para meter na mensagem
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mensagem de SOS enviada com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('ENVIAR SOS', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
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
                        onPressed: () {
                          HapticFeedback.lightImpact();
                        },
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
                      Text('Tuesday\n9:30 AM', style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)),
                    ],
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