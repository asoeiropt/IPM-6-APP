import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Cores baseadas no teu novo design dark mode
    const bgColor = Color(0xFF090C10);
    const cardColor = Color(0xFF141923);
    const neonGradient = LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFFE81CFF)], // Gradiente Azul para Rosa/Roxo do Log Out
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- CABEÇALHO DA PÁGINA ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Profile', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: const Icon(Icons.settings_outlined, color: Colors.white54, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- INFO DO UTILIZADOR (FOTO E NOME) ---
            Row(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Color(0xFF387A76),
                      child: Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676), // Ponto verde brilhante
                          shape: BoxShape.circle,
                          border: Border.all(color: bgColor, width: 3),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('João Antunes', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Type 1 Diabetes • 5 years', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- BLOCO DE MENUS ---
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  _buildMenuItem(Icons.person_outline, 'Personal Information', isFirst: true),
                  _buildDivider(),
                  _buildMenuItem(Icons.health_and_safety_outlined, 'Health Settings'),
                  _buildDivider(),
                  _buildMenuItem(Icons.link, 'Connected Devices', trailingText: 'Dexcom G7'),
                  _buildDivider(),
                  _buildMenuItem(Icons.shield_outlined, 'Data & Privacy'),
                  _buildDivider(),
                  _buildMenuItem(Icons.help_outline, 'Help & Support', isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- BOTÃO LOG OUT ---
            GestureDetector(
              onTap: () {
                // Lógica de logout (por exemplo, voltar ao ecrã de login)
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: neonGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: Text(
                    'Log Out',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 100), // Espaçamento extra para a barra flutuante
          ],
        ),
      ),
    );
  }

  // --- WIDGET PARA OS ITENS DO MENU ---
  Widget _buildMenuItem(IconData icon, String title, {String? trailingText, bool isFirst = false, bool isLast = false}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(isFirst ? 24 : 0),
        bottom: Radius.circular(isLast ? 24 : 0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
            ),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(trailingText, style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PARA O TRAÇO DIVISÓRIO ---
  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.05),
      height: 1,
      indent: 58, // Para alinhar o traço pelo texto e não pelo ícone
      endIndent: 20,
    );
  }
}