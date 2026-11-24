import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'report_screen.dart';
import '../app_data.dart';
import '../startup_screens.dart';

class DataPrivacyScreen extends StatefulWidget {
  const DataPrivacyScreen({super.key});

  @override
  State<DataPrivacyScreen> createState() => _DataPrivacyScreenState();
}

class _DataPrivacyScreenState extends State<DataPrivacyScreen> {
  final Gradient dangerGradient = const LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFBE185D)],
  );

  bool _shareAnonymousData = false;

  void _showChangePasswordDialog(Color cardColor, Color mainTextColor,
      Color subTextColor, Color borderColor) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: isHighContrast ? 2 : 1),
        ),
        title: Text(tr('Alterar Palavra-passe', 'Change Password'),
            style: TextStyle(color: mainTextColor, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: tr('Palavra-passe Atual', 'Current Password'),
                labelStyle: TextStyle(color: subTextColor),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: tr('Nova Palavra-passe', 'New Password'),
                labelStyle: TextStyle(color: subTextColor),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('Cancelar', 'Cancel'),
                style: TextStyle(color: subTextColor)),
          ),
          ElevatedButton(
            onPressed: () {
              if (currentCtrl.text.trim().isEmpty ||
                  newCtrl.text.trim().length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr(
                      '⚠️ Preenche a password atual e uma nova com pelo menos 4 caracteres.',
                      '⚠️ Fill in current password and a new one with at least 4 characters.',
                    )),
                    backgroundColor: const Color(0xFFF43F5E),
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    tr('✅ Palavra-passe atualizada!', '✅ Password updated!'),
                    style: TextStyle(
                      color: isHighContrast ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: isHighContrast
                      ? const Color(0xFFFFD600)
                      : const Color(0xFF2DD4BF),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isHighContrast
                  ? const Color(0xFFFFD600)
                  : const Color(0xFF3B82F6),
              foregroundColor: isHighContrast ? Colors.black : Colors.white,
            ),
            child: Text(tr('Guardar', 'Save'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
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
    final iconColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white70;
    final actionColor =
        isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6);
    final dangerColor =
        isHighContrast ? const Color(0xFFFFD600) : const Color(0xFFF43F5E);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: mainTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(tr('Dados & Privacidade', 'Data & Privacy'),
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: mainTextColor)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SEGURANÇA E ACESSO ---
              Text(tr('SEGURANÇA & ACESSO', 'SECURITY & ACCESS'),
                  style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: borderColor, width: isHighContrast ? 2 : 1),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                          tr('Autenticação Biométrica', 'Biometric Login'),
                          style: TextStyle(
                              color: mainTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                      subtitle: Text(
                          tr('Usar Face ID / Impressão Digital ao abrir',
                              'Use Face ID / Touch ID to unlock'),
                          style: TextStyle(color: subTextColor, fontSize: 12)),
                      activeColor: isHighContrast ? Colors.black : actionColor,
                      activeTrackColor:
                          isHighContrast ? const Color(0xFFFFD600) : null,
                      value: useBiometrics,
                      onChanged: (bool value) {
                        HapticFeedback.lightImpact();
                        setState(() => useBiometrics = value);
                        saveData();
                      },
                    ),
                    Divider(
                        color: borderColor,
                        height: 1,
                        indent: 20,
                        endIndent: 20,
                        thickness: isHighContrast ? 2 : 1),
                    _buildActionItem(
                      icon: Icons.password,
                      title: tr('Alterar Palavra-passe', 'Change Password'),
                      iconColor: iconColor,
                      mainTextColor: mainTextColor,
                      subTextColor: subTextColor,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showChangePasswordDialog(cardColor, mainTextColor,
                            subTextColor, borderColor);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- OS MEUS DADOS ---
              Text(tr('OS TEUS DADOS', 'YOUR DATA'),
                  style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: borderColor, width: isHighContrast ? 2 : 1),
                ),
                child: Column(
                  children: [
                    _buildActionItem(
                      icon: Icons.cloud_download_outlined,
                      title: tr('Exportar Dados Clínicos', 'Export Health Data'),
                      subtitle: tr('Transferir o diário em PDF',
                          'Download your diary as PDF'),
                      iconColor: iconColor,
                      mainTextColor: mainTextColor,
                      subTextColor: subTextColor,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ReportScreen()),
                        );
                      },
                    ),
                    Divider(
                        color: borderColor,
                        height: 1,
                        indent: 20,
                        endIndent: 20,
                        thickness: isHighContrast ? 2 : 1),
                    SwitchListTile(
                      title: Text(
                          tr('Contribuir para Investigação IA',
                              'Help AI Research'),
                      style: TextStyle(
                              color: mainTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                      subtitle: Text(
                          tr('Partilhar dados anónimos para melhorar os modelos IA',
                              'Share anonymous data to improve AI models'),
                          style: TextStyle(color: subTextColor, fontSize: 12)),
                      activeColor: isHighContrast ? Colors.black : actionColor,
                      activeTrackColor:
                          isHighContrast ? const Color(0xFFFFD600) : null,
                      value: _shareAnonymousData,
                      onChanged: (bool value) {
                        HapticFeedback.lightImpact();
                        setState(() => _shareAnonymousData = value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- LEGAL ---
              Text(tr('LEGAL', 'LEGAL'),
                  style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: borderColor, width: isHighContrast ? 2 : 1),
                ),
                child: Column(
                  children: [
                    _buildActionItem(
                      icon: Icons.privacy_tip_outlined,
                      title: tr('Política de Privacidade', 'Privacy Policy'),
                      iconColor: iconColor,
                      mainTextColor: mainTextColor,
                      subTextColor: subTextColor,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PrivacyPolicyScreen()));
                      },
                    ),
                    Divider(
                        color: borderColor,
                        height: 1,
                        indent: 20,
                        endIndent: 20,
                        thickness: isHighContrast ? 2 : 1),
                    _buildActionItem(
                      icon: Icons.description_outlined,
                      title: tr('Termos de Serviço', 'Terms of Service'),
                      iconColor: iconColor,
                      mainTextColor: mainTextColor,
                      subTextColor: subTextColor,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const TermsOfServiceScreen()));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- DANGER ZONE (ZONA DE PERIGO) ---
              Text(tr('ZONA DE PERIGO', 'DANGER ZONE'),
                  style: TextStyle(
                      color: dangerColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  _showDeleteConfirmation(context, cardColor, dangerColor,
                      mainTextColor, subTextColor, borderColor);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: isHighContrast ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: isHighContrast
                            ? const Color(0xFFFFD600)
                            : const Color(0xFFF43F5E).withOpacity(0.5),
                        width: isHighContrast ? 2 : 1),
                  ),
                  child: Center(
                    child: Text(tr('Eliminar Conta', 'Delete Account'),
                        style: TextStyle(
                            color: dangerColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(
      {required IconData icon,
      required String title,
      String? subtitle,
      VoidCallback? onTap,
      required Color iconColor,
      required Color mainTextColor,
      required Color subTextColor}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: mainTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(color: subTextColor, fontSize: 12)),
                  ]
                ],
              ),
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

  void _showDeleteConfirmation(
      BuildContext context,
      Color cardColor,
      Color dangerColor,
      Color mainTextColor,
      Color subTextColor,
      Color borderColor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: borderColor, width: isHighContrast ? 2 : 1)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: dangerColor, size: 24),
            const SizedBox(width: 12),
            Text(tr('Eliminar Conta?', 'Delete Account?'),
                style: TextStyle(color: mainTextColor, fontSize: 18)),
          ],
        ),
        content: Text(
          tr(
            'Esta ação é permanente e irreversível. Todos os teus registos clínicos, modelos de IA e histórico serão apagados.',
            'This action is permanent and cannot be undone. All your health records, AI models, and history will be permanently erased.',
          ),
          style: TextStyle(color: subTextColor, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('Cancelar', 'Cancel'),
                style: TextStyle(color: subTextColor)),
          ),
          ElevatedButton(
            onPressed: () {
              globalDiary.clear();
              isLoggedIn = false;
              currentUserId = '';
              currentUserName = '';
              saveData();

              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isHighContrast
                  ? Colors.transparent
                  : const Color(0xFFF43F5E),
              foregroundColor:
                  isHighContrast ? const Color(0xFFFFD600) : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: isHighContrast
                    ? const BorderSide(color: Color(0xFFFFD600), width: 2)
                    : BorderSide.none,
              ),
            ),
            child: Text(
                tr('Eliminar Permanentemente', 'Delete Permanently'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}