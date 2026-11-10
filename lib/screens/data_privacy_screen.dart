import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class DataPrivacyScreen extends StatefulWidget {
  const DataPrivacyScreen({super.key});

  @override
  State<DataPrivacyScreen> createState() => _DataPrivacyScreenState();
}

class _DataPrivacyScreenState extends State<DataPrivacyScreen> {
  final Color bgColor = const Color(0xFF090C10);
  final Color cardColor = const Color(0xFF141923);
  final Gradient dangerGradient = const LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFBE185D)],
  );

  bool _useBiometrics = true;
  bool _shareAnonymousData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Data & Privacy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SEGURANÇA E ACESSO ---
              const Text('SECURITY & ACCESS', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Biometric Login', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                      subtitle: const Text('Use Face ID / Touch ID to unlock', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      activeColor: const Color(0xFF3B82F6),
                      value: _useBiometrics,
                      onChanged: (bool value) {
                        HapticFeedback.lightImpact();
                        setState(() => _useBiometrics = value);
                      },
                    ),
                    Divider(color: Colors.white.withOpacity(0.05), height: 1, indent: 20, endIndent: 20),
                    _buildActionItem(
                      icon: Icons.password,
                      title: 'Change Password',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // Lógica para mudar password
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- OS MEUS DADOS ---
              const Text('YOUR DATA', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    _buildActionItem(
                      icon: Icons.cloud_download_outlined,
                      title: 'Export Health Data',
                      subtitle: 'Download your diary as CSV or PDF',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📥 Exporting data...'), backgroundColor: Color(0xFF3B82F6)));
                      },
                    ),
                    Divider(color: Colors.white.withOpacity(0.05), height: 1, indent: 20, endIndent: 20),
                    SwitchListTile(
                      title: const Text('Help AI Research', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                      subtitle: const Text('Share anonymous data to improve AI models', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      activeColor: const Color(0xFF3B82F6),
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
              const Text('LEGAL', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    _buildActionItem(
                      icon: Icons.privacy_tip_outlined, 
                      title: 'Privacy Policy',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
                      },
                    ),
                    Divider(color: Colors.white.withOpacity(0.05), height: 1, indent: 20, endIndent: 20),
                    _buildActionItem(
                      icon: Icons.description_outlined, 
                      title: 'Terms of Service',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- DANGER ZONE (ZONA DE PERIGO) ---
              const Text('DANGER ZONE', style: TextStyle(color: Color(0xFFF43F5E), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  _showDeleteConfirmation(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF43F5E).withOpacity(0.5)),
                  ),
                  child: const Center(
                    child: Text('Delete Account', style: TextStyle(color: Color(0xFFF43F5E), fontSize: 16, fontWeight: FontWeight.bold)),
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

  // --- WIDGET REUTILIZÁVEL PARA AS OPÇÕES ---
  Widget _buildActionItem({required IconData icon, required String title, String? subtitle, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ]
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }

  // --- POPUP DE CONFIRMAÇÃO DE APAGAR CONTA ---
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withOpacity(0.05))),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFF43F5E), size: 24),
            SizedBox(width: 12),
            Text('Delete Account?', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: const Text(
          'This action is permanent and cannot be undone. All your health records, AI models, and history will be permanently erased.',
          style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Lógica de apagar a conta iria aqui
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF43F5E),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}