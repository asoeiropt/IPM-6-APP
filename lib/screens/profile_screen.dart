import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'personal_info_screen.dart';
import 'health_settings_screen.dart';
import 'data_privacy_screen.dart';
import '../app_data.dart';
import '../startup_screens.dart';

class ProfileTab extends StatefulWidget {
  final VoidCallback? onContrastChanged;
  const ProfileTab({super.key, this.onContrastChanged});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _buildDiagnosisSubtitle() {
    final int? diagYear = int.tryParse(currentDiagnosisYear.trim());
    if (diagYear != null && diagYear > 1920 && diagYear <= DateTime.now().year) {
      final int years = DateTime.now().year - diagYear;
      if (years <= 0) {
        return tr('Diabetes Tipo 1 • Diagnosticado este ano',
            'Type 1 Diabetes • Diagnosed this year');
      }
      return tr(
        'Diabetes Tipo 1 • $years ${years == 1 ? 'ano' : 'anos'}',
        'Type 1 Diabetes • $years ${years == 1 ? 'year' : 'years'}',
      );
    }
    return tr('Diabetes Tipo 1', 'Type 1 Diabetes');
  }

  void _handleLogout() {
    HapticFeedback.mediumImpact();
    isLoggedIn = false;
    currentUserId = '';
    currentUserName = '';
    currentUserEmail = '';
    currentUserPhone = '';
    currentUserDob = '';
    currentDiagnosisYear = '';
    saveData();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _showHelpDialog(
      Color cardColor, Color textColor, Color subtitleColor, Color borderColor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor, width: isHighContrast ? 2 : 1),
        ),
        title: Text(
            tr('Glossário Clínico & Suporte', 'Clinical Glossary & Support'),
            style: TextStyle(
                color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        content: Text(
          tr(
            '• ICR (Rácio Insulina/Hidratos): Gramas de hidratos cobertos por 1 unidade de insulina.\n\n'
                '• ISF (Fator de Sensibilidade): Queda esperada da glicemia (mg/dL) por 1 unidade de insulina.\n\n'
                '• IOB (Insulina Ativa): Insulina ainda ativa no organismo proveniente de registos recentes.\n\n'
                'Precisas de ajuda técnica? Contacta support@smartglyco.pt',
            '• ICR (Insulin-to-Carb Ratio): Grams of carbs covered by 1 unit of insulin.\n\n'
                '• ISF (Insulin Sensitivity Factor): Expected mg/dL glucose drop per 1 unit of insulin.\n\n'
                '• IOB (Insulin on Board): Active insulin remaining in your body from recent logs.\n\n'
                'Need technical help? Contact support@smartglyco.pt',
          ),
          style: TextStyle(color: subtitleColor, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('Fechar', 'Close'),
                style:
                    TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final textColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subtitleColor = isHighContrast ? Colors.white : Colors.white54;
    final borderColor = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.05);
    final iconColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white70;

    final displayName =
        currentUserName.trim().isNotEmpty ? currentUserName : 'João Antunes';

    final buttonDecoration = isHighContrast
        ? BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD600), width: 2))
        : BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFFE81CFF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight),
            borderRadius: BorderRadius.circular(24));

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr('Perfil', 'Profile'),
                    style: TextStyle(
                        color: textColor,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HealthSettingsScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: borderColor, width: isHighContrast ? 2 : 1),
                    ),
                    child: Icon(Icons.settings_outlined,
                        color: iconColor, size: 20),
                  ),
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
                      backgroundColor: isHighContrast
                          ? const Color(0xFFFFD600)
                          : const Color(0xFF387A76),
                      child: Icon(Icons.person,
                          color: isHighContrast ? Colors.black : Colors.white,
                          size: 40),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName,
                          style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_buildDiagnosisSubtitle(),
                          style: TextStyle(color: subtitleColor, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: borderColor, width: isHighContrast ? 2 : 1),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                      icon: Icons.person_outline,
                      title: tr('Informação Pessoal', 'Personal Information'),
                      isFirst: true,
                      iconColor: iconColor,
                      textColor: textColor,
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PersonalInfoScreen()));
                        if (mounted) setState(() {});
                      }),
                  _buildDivider(borderColor),

                  // --- TOGGLE DE IDIOMA PT / EN ---
                  _buildLanguageItem(
                    iconColor: iconColor,
                    textColor: textColor,
                    borderColor: borderColor,
                  ),
                  _buildDivider(borderColor),

                  // --- TOGGLE ALTO CONTRASTE ---
                  _buildSwitchItem(
                      icon: Icons.visibility,
                      title: tr('Modo Alto Contraste', 'High Contrast Mode'),
                      value: isHighContrast,
                      iconColor: iconColor,
                      textColor: textColor,
                      onChanged: (value) {
                        HapticFeedback.heavyImpact();
                        setState(() {
                          isHighContrast = value;
                        });
                        saveData();
                        widget.onContrastChanged?.call();
                      }),
                  _buildDivider(borderColor),

                  _buildMenuItem(
                      icon: Icons.health_and_safety_outlined,
                      title: tr('Definições Clínicas', 'Health Settings'),
                      iconColor: iconColor,
                      textColor: textColor,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const HealthSettingsScreen()));
                      }),
                  _buildDivider(borderColor),
                  _buildMenuItem(
                      icon: Icons.link,
                      title: tr('Dispositivos Ligados', 'Connected Devices'),
                      trailingText: 'Dexcom G7',
                      iconColor: iconColor,
                      textColor: textColor,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(tr(
                                '📡 Dexcom G7 CGM ligado e a sincronizar.',
                                '📡 Dexcom G7 CGM connected & syncing.')),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }),
                  _buildDivider(borderColor),
                  _buildMenuItem(
                      icon: Icons.shield_outlined,
                      title: tr('Dados & Privacidade', 'Data & Privacy'),
                      iconColor: iconColor,
                      textColor: textColor,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const DataPrivacyScreen()));
                      }),
                  _buildDivider(borderColor),
                  _buildMenuItem(
                      icon: Icons.help_outline,
                      title: tr('Ajuda & Suporte', 'Help & Support'),
                      isLast: true,
                      iconColor: iconColor,
                      textColor: textColor,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showHelpDialog(
                            cardColor, textColor, subtitleColor, borderColor);
                      }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: _handleLogout,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: buttonDecoration,
                child: Center(
                  child: Text(
                    tr('Terminar Sessão', 'Log Out'),
                    style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
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

  Widget _buildLanguageItem({
    required Color iconColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.language, color: iconColor, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              tr('Idioma', 'Language'),
              style: TextStyle(
                  color: textColor, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isHighContrast ? Colors.black : const Color(0xFF090C10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: isHighContrast
                      ? const Color(0xFFFFD600)
                      : Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLangPill('PT', true),
                _buildLangPill('EN', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangPill(String label, bool targetIsPortuguese) {
    final bool isSelected = isPortuguese == targetIsPortuguese;

    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        HapticFeedback.selectionClick();
        setState(() {
          isPortuguese = targetIsPortuguese;
        });
        saveData();
        widget.onContrastChanged?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isHighContrast
                  ? const Color(0xFFFFD600)
                  : const Color(0xFF3B82F6))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isHighContrast ? Colors.black : Colors.white)
                : (isHighContrast ? Colors.white : Colors.white54),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      {required IconData icon,
      required String title,
      String? trailingText,
      bool isFirst = false,
      bool isLast = false,
      VoidCallback? onTap,
      required Color iconColor,
      required Color textColor}) {
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
              child: Text(title,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(trailingText,
                    style: TextStyle(
                        color: isHighContrast ? Colors.white : Colors.white54,
                        fontSize: 13)),
              ),
            Icon(Icons.arrow_forward_ios,
                color:
                    isHighContrast ? const Color(0xFFFFD600) : Colors.white38,
                size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
      {required IconData icon,
      required String title,
      required bool value,
      required ValueChanged<bool> onChanged,
      required Color iconColor,
      required Color textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title,
                style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
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