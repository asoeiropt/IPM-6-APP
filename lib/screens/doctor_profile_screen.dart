import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_data.dart';
import '../startup_screens.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  final VoidCallback? onSettingsChanged;
  const DoctorProfileScreen({super.key, this.onSettingsChanged});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool _sosPushEnabled = true;
  bool _teleconsultAvailable = true;

  String get _doctorDocId =>
      currentUserId.isNotEmpty ? currentUserId : 'medica_joana';

  String get _doctorName => currentUserName.trim().isNotEmpty
      ? currentUserName
      : 'Dra. Joana Sílvia';

  @override
  void initState() {
    super.initState();
    _loadDoctorPrefs();
  }

  Future<void> _loadDoctorPrefs() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_doctorDocId)
          .get();
      if (doc.exists && mounted) {
        final data = doc.data() ?? {};
        setState(() {
          _sosPushEnabled = (data['sosPushEnabled'] as bool?) ?? true;
          _teleconsultAvailable =
              (data['teleconsultAvailable'] as bool?) ?? true;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao carregar preferências da médica: $e');
    }
  }

  Future<void> _updateDoctorPref(String field, bool value) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_doctorDocId)
          .set({
        field: value,
        'name': _doctorName,
        'role': 'doctor',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('⚠️ Erro ao guardar preferência da médica: $e');
    }
  }

  void _handleLogout() {
    HapticFeedback.mediumImpact();
    isLoggedIn = false;
    currentUserId = '';
    currentUserName = '';
    saveData();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _showClinicDetailsDialog(
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
          tr('Informação Profissional', 'Professional Credentials'),
          style: TextStyle(
              color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          tr(
            '• Nome: $_doctorName\n'
                '• Especialidade: Endocrinologia e Nutrição\n'
                '• Cédula Profissional: OM-54892\n'
                '• Unidade: Hospital de Santa Maria • SmartGlyco Pro\n'
                '• Email Institucional: joana@smartglyco.pt',
            '• Name: $_doctorName\n'
                '• Specialty: Endocrinology & Metabolism\n'
                '• Medical License: OM-54892\n'
                '• Unit: Santa Maria Hospital • SmartGlyco Pro\n'
                '• Institutional Email: joana@smartglyco.pt',
          ),
          style: TextStyle(color: subtitleColor, fontSize: 13, height: 1.6),
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
    final accentColor =
        isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF2DD4BF);

    final buttonDecoration = isHighContrast
        ? BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD600), width: 2))
        : BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFF43F5E), Color(0xFFBE185D)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight),
            borderRadius: BorderRadius.circular(24));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(tr('Perfil Médico', 'Doctor Profile'),
            style: TextStyle(
                color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- CARTÃO DE IDENTIDADE DA MÉDICA ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: borderColor, width: isHighContrast ? 2 : 1),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: isHighContrast
                            ? const Color(0xFFFFD600)
                            : const Color(0xFF387A76),
                        child: Icon(Icons.medical_services_rounded,
                            color:
                                isHighContrast ? Colors.black : Colors.white,
                            size: 32),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 2,
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: _teleconsultAvailable
                                ? const Color(0xFF00E676)
                                : Colors.orangeAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: cardColor, width: 2.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_doctorName,
                            style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                            tr('Endocrinologista • OM-54892',
                                'Endocrinologist • OM-54892'),
                            style:
                                TextStyle(color: subtitleColor, fontSize: 13)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isHighContrast
                                ? Colors.transparent
                                : accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: isHighContrast
                                ? Border.all(color: accentColor)
                                : null,
                          ),
                          child: Text(
                            'SmartGlyco Pro',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- SECÇÃO CLÍNICA & PREFERÊNCIAS ---
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 10),
              child: Text(
                tr('PREFERÊNCIAS CLÍNICAS', 'CLINICAL PREFERENCES'),
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
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
                    icon: Icons.badge_outlined,
                    title: tr('Dados Profissionais', 'Professional Details'),
                    trailingText: 'OM-54892',
                    isFirst: true,
                    iconColor: iconColor,
                    textColor: textColor,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showClinicDetailsDialog(
                          cardColor, textColor, subtitleColor, borderColor);
                    },
                  ),
                  _buildDivider(borderColor),
                  _buildSwitchItem(
                    icon: Icons.sos_rounded,
                    title: tr('Alertas SOS Prioritários',
                        'Priority SOS Alerts'),
                    value: _sosPushEnabled,
                    iconColor: iconColor,
                    textColor: textColor,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setState(() => _sosPushEnabled = value);
                      _updateDoctorPref('sosPushEnabled', value);
                    },
                  ),
                  _buildDivider(borderColor),
                  _buildSwitchItem(
                    icon: Icons.online_prediction_rounded,
                    title: tr('Disponível para Teleconsulta',
                        'Available for Telehealth'),
                    value: _teleconsultAvailable,
                    iconColor: iconColor,
                    textColor: textColor,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      setState(() => _teleconsultAvailable = value);
                      _updateDoctorPref('teleconsultAvailable', value);
                    },
                  ),
                  _buildDivider(borderColor),
                  _buildLanguageItem(
                    iconColor: iconColor,
                    textColor: textColor,
                  ),
                  _buildDivider(borderColor),
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
                      widget.onSettingsChanged?.call();
                    },
                  ),
                  _buildDivider(borderColor),
                  _buildMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: tr('Política de Privacidade', 'Privacy Policy'),
                    iconColor: iconColor,
                    textColor: textColor,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen()),
                      );
                    },
                  ),
                  _buildDivider(borderColor),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: tr('Termos de Serviço', 'Terms of Service'),
                    isLast: true,
                    iconColor: iconColor,
                    textColor: textColor,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TermsOfServiceScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // --- BOTÃO LOG OUT ---
            GestureDetector(
              onTap: _handleLogout,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: buttonDecoration,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded,
                        color: isHighContrast ? textColor : Colors.white,
                        size: 20),
                    const SizedBox(width: 10),
                    Text(
                      tr('Terminar Sessão', 'Log Out'),
                      style: TextStyle(
                          color: isHighContrast ? textColor : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem({
    required Color iconColor,
    required Color textColor,
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
        widget.onSettingsChanged?.call();
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? trailingText,
    bool isFirst = false,
    bool isLast = false,
    VoidCallback? onTap,
    required Color iconColor,
    required Color textColor,
  }) {
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

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color iconColor,
    required Color textColor,
  }) {
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
            activeTrackColor: isHighContrast
                ? const Color(0xFFFFD600)
                : const Color(0xFF2DD4BF),
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