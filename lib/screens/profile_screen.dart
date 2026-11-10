import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'personal_info_screen.dart'; 
import 'health_settings_screen.dart';
import 'data_privacy_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF090C10);
    const cardColor = Color(0xFF141923);
    const neonGradient = LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFFE81CFF)], 
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                  children: const [
                    Text('João Antunes', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Type 1 Diabetes • 5 years', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline, 
                    title: 'Personal Information', 
                    isFirst: true,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalInfoScreen()));
                    }
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.health_and_safety_outlined, 
                    title: 'Health Settings',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthSettingsScreen()));
                    }
                  ),
                  _buildDivider(),
                  _buildMenuItem(icon: Icons.link, title: 'Connected Devices', trailingText: 'Dexcom G7'),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.shield_outlined, 
                    title: 'Data & Privacy',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DataPrivacyScreen()));
                    }
                  ),
                  _buildDivider(),
                  _buildMenuItem(icon: Icons.help_outline, title: 'Help & Support', isLast: true),
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
            
            const SizedBox(height: 100), 
          ],
        ),
      ),
    );
  }

  // ATUALIZADO: Agora recebe um onTap opcional
  Widget _buildMenuItem({required IconData icon, required String title, String? trailingText, bool isFirst = false, bool isLast = false, VoidCallback? onTap}) {
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

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.05),
      height: 1,
      indent: 58, 
      endIndent: 20,
    );
  }
}