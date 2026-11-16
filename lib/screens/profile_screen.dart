import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'personal_info_screen.dart'; 
import 'health_settings_screen.dart';
import 'data_privacy_screen.dart';
import '../app_data.dart'; // Importante para aceder ao isHighContrast e saveData()

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    // LÓGICA DE ALTO CONTRASTE (Heurística de Acessibilidade)
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final textColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subtitleColor = isHighContrast ? Colors.white : Colors.white54;
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);
    final iconColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white70;
    
    // O gradiente desaparece no modo de contraste para garantir leitura pura
    final buttonDecoration = isHighContrast 
        ? BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFFFD600), width: 2))
        : BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFFE81CFF)], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(24));

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Profile', style: TextStyle(color: textColor, fontSize: 26, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
                  ),
                  child: Icon(Icons.settings_outlined, color: iconColor, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF387A76),
                      child: Icon(Icons.person, color: isHighContrast ? Colors.black : Colors.white, size: 40),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676), 
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
                  children: [
                    Text('João Antunes', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Type 1 Diabetes • 5 years', style: TextStyle(color: subtitleColor, fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline, 
                    title: 'Personal Information', 
                    isFirst: true,
                    iconColor: iconColor,
                    textColor: textColor,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalInfoScreen()));
                    }
                  ),
                  _buildDivider(borderColor),
                  
                  // NOVO: Toggle de Acessibilidade perfeitamente integrado no teu design
                  _buildSwitchItem(
                    icon: Icons.visibility,
                    title: 'Alto Contraste',
                    value: isHighContrast,
                    iconColor: iconColor,
                    textColor: textColor,
                    onChanged: (value) {
                      HapticFeedback.heavyImpact(); // Confirmação tátil forte
                      setState(() {
                        isHighContrast = value;
                      });
                      saveData(); // Grava na base de dados
                    }
                  ),
                  _buildDivider(borderColor),
                  
                  _buildMenuItem(
                    icon: Icons.health_and_safety_outlined, 
                    title: 'Health Settings',
                    iconColor: iconColor,
                    textColor: textColor,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthSettingsScreen()));
                    }
                  ),
                  _buildDivider(borderColor),
                  _buildMenuItem(icon: Icons.link, title: 'Connected Devices', trailingText: 'Dexcom G7', iconColor: iconColor, textColor: textColor),
                  _buildDivider(borderColor),
                  _buildMenuItem(
                    icon: Icons.shield_outlined, 
                    title: 'Data & Privacy',
                    iconColor: iconColor,
                    textColor: textColor,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DataPrivacyScreen()));
                    }
                  ),
                  _buildDivider(borderColor),
                  _buildMenuItem(icon: Icons.help_outline, title: 'Help & Support', isLast: true, iconColor: iconColor, textColor: textColor),
                ],
              ),
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                // Lógica de logout
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: buttonDecoration,
                child: Center(
                  child: Text(
                    'Log Out',
                    style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 100), 
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, String? trailingText, bool isFirst = false, bool isLast = false, VoidCallback? onTap, required Color iconColor, required Color textColor}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(isFirst ? 24 : 0),
        bottom: Radius.circular(isLast ? 24 : 0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500)),
            ),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(trailingText, style: TextStyle(color: isHighContrast ? Colors.white : Colors.white54, fontSize: 13)),
              ),
            Icon(Icons.arrow_forward_ios, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }

  // NOVO WIDGET: Para o toggle Switch igualar o teu design de menu
  Widget _buildSwitchItem({required IconData icon, required String title, required bool value, required ValueChanged<bool> onChanged, required Color iconColor, required Color textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500)),
          ),
          Switch(
            value: value,
            activeColor: Colors.black,
            activeTrackColor: const Color(0xFFFFD600),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color borderColor) {
    return Divider(
      color: borderColor,
      height: 1,
      thickness: isHighContrast ? 2 : 1,
      indent: 58, 
      endIndent: 20,
    );
  }
}