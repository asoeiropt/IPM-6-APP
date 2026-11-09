import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'trends_screen.dart';

class CareTab extends StatelessWidget {
  const CareTab({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF090C10); // Fundo igual ao do chat
    const cardColor = Color(0xFF141923); // Azul escuro dos cartões

    return Scaffold(
      backgroundColor: bgColor,
      body: ListView(
        // O padding inferior (100) garante que a barra de navegação flutuante não tapa os últimos itens
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
        children: [
          // --- TÍTULO DA PÁGINA ---
          const Text('Care Hub', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Your health team, always close', style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 24),

          // --- CARTÃO DO MÉDICO ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Color(0xFF387A76),
                          child: Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676), // Ponto verde online
                              shape: BoxShape.circle,
                              border: Border.all(color: cardColor, width: 2.5),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dra. Joana Sílvia', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text('Endocrinologista', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.circle, color: Color(0xFF00E676), size: 10),
                            SizedBox(width: 6),
                            Text('Online', style: TextStyle(color: Color(0xFF00E676), fontSize: 13, fontWeight: FontWeight.w600)),
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text('Message'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.calendar_today_outlined, size: 18),
                        label: const Text('Book Visit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A), // Azul mais forte para destacar a marcação
                          foregroundColor: Colors.white,
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

          // --- BANNER DE MEDICAÇÃO (ROXO) ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD946EF), Color(0xFF6B21A8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Transform.rotate(
                  angle: -0.5,
                  child: const Icon(Icons.medication, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                const Text('Medication Refill Due', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('IN 3 DAYS', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --- CARTÕES QUADRADOS (ROSA E VERDE) ---
          Row(
            children: [
              // Cartão Rosa (Next Visit)
              Expanded(
                child: Container(
                  height: 160,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF43F5E), Color(0xFFBE185D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 26),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                          )
                        ],
                      ),
                      const Spacer(),
                      const Text('Next Visit', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      const Text('Tuesday\n9:30 AM', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Cartão Verde/Teal (Health Trend)
              // Cartão Verde/Teal (Health Trend)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // NAVEGAÇÃO PARA OS GRÁFICOS ACONTECE AQUI
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TrendsScreen()));
                  },
                  child: Container(
                    height: 160,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2DD4BF), Color(0xFF0F766E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.ios_share_rounded, color: Colors.white, size: 26),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(8, (index) {
                            final heights = [10.0, 20.0, 15.0, 30.0, 25.0, 40.0, 20.0, 35.0];
                            return Container(
                              margin: const EdgeInsets.only(right: 4),
                              width: 3,
                              height: heights[index],
                              color: Colors.white.withOpacity(0.5),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        const Text('Health Trend', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        const Text('Share Report', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Protocol', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text('Current Prescribed Doses', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('On Track', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                _buildProtocolItem('Morning Insulin', '8 UNITS'),
                const SizedBox(height: 16),
                _buildProtocolItem('Metformin', '500 MG'),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Widget reutilizável para as linhas do protocolo
  Widget _buildProtocolItem(String name, String dose) {
    return Row(
      children: [
        const Icon(Icons.circle, color: Color(0xFFC026D3), size: 8), // Ponto roxo
        const SizedBox(width: 12),
        Text(name, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const Spacer(),
        Text(dose, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}