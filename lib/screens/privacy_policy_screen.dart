import 'package:flutter/material.dart';
import '../app_data.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);
    final mainTextColor =
        isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : Colors.white54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: mainTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(tr('Política de Privacidade', 'Privacy Policy'),
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
              Text(
                  tr('Última atualização: Novembro 2026',
                      'Last updated: November 2026'),
                  style: TextStyle(color: subTextColor, fontSize: 13)),
              const SizedBox(height: 24),
              _buildSection(
                icon: Icons.data_usage,
                title: tr('1. Recolha de Dados', '1. Data Collection'),
                content: tr(
                  'A SmartGlycoAI recolhe dados de saúde incluindo níveis de glicemia, doses de insulina, registos de refeições (hidratos de carbono) e atividade física. Também recolhe dados do dispositivo para garantir a sincronização adequada com monitores contínuos de glicose (CGMs).',
                  'SmartGlycoAI collects health data including glucose levels, insulin doses, meal logs (carbohydrates), and physical activity. We also collect device data to ensure the proper synchronization with continuous glucose monitors (CGMs).',
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                icon: Icons.psychology,
                title: tr('2. Como Utilizamos os Teus Dados',
                    '2. How We Use Your Data'),
                content: tr(
                  'Os teus dados de saúde são utilizados para alimentar os nossos modelos de Inteligência Artificial de forma a fornecer sugestões personalizadas de insulina e alertas preditivos de hipoglicemia. Dados anónimos podem ser usados para melhorar os algoritmos caso autorizes explicitamente.',
                  'Your health data is used to feed our Artificial Intelligence models to provide personalized insulin suggestions and predictive hypoglycemia alerts. Anonymous data may be used to improve our algorithms if you explicitly opt-in.',
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                icon: Icons.lock_outline,
                title: tr('3. Segurança dos Dados', '3. Data Security'),
                content: tr(
                  'Implementamos encriptação AES-256 de última geração para dados em repouso e TLS 1.3 para dados em trânsito. Os teus registos clínicos são armazenados de forma segura e cumprem o RGPD e as normas padrão de privacidade médica.',
                  'We implement state-of-the-art AES-256 encryption for data at rest and TLS 1.3 for data in transit. Your health records are stored securely and comply with GDPR and standard medical privacy guidelines.',
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                icon: Icons.admin_panel_settings_outlined,
                title: tr('4. Os Teus Direitos', '4. Your Rights'),
                content: tr(
                  'Tens o direito de aceder, exportar (CSV/PDF) e eliminar permanentemente os teus dados a qualquer momento no menu Dados & Privacidade. A eliminação da conta apaga imediatamente todos os registos pessoais dos nossos servidores.',
                  'You have the right to access, export (CSV/PDF), and permanently delete your data at any time from the Data & Privacy settings menu. Deleting your account will immediately erase all personal records from our servers.',
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
      {required IconData icon,
      required String title,
      required String content}) {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.05);
    final iconColor =
        isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6);
    final titleColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final contentColor = isHighContrast ? Colors.white : Colors.white70;

    return Container(
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
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          color: titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 12),
          Text(content,
              style:
                  TextStyle(color: contentColor, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}