import 'package:flutter/material.dart';
import '../app_data.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
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
        title: Text(tr('Termos de Serviço', 'Terms of Service'),
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
                  tr('Data de Entrada em Vigor: Novembro 2026',
                      'Effective Date: November 2026'),
                  style: TextStyle(color: subTextColor, fontSize: 13)),
              const SizedBox(height: 24),
              _buildSection(
                icon: Icons.gavel_outlined,
                title: tr('1. Aceitação dos Termos', '1. Acceptance of Terms'),
                content: tr(
                  'Ao criar uma conta e utilizar a SmartGlycoAI, aceitas ficar vinculado a estes Termos de Serviço. Caso não concordes, por favor não utilizes a aplicação.',
                  'By creating an account and using SmartGlycoAI, you agree to be bound by these Terms of Service. If you do not agree, please do not use the application.',
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                icon: Icons.medical_information_outlined,
                title: tr('2. Não Constitui Aconselhamento Médico (Aviso Legal)',
                    '2. Not Medical Advice (Disclaimer)'),
                content: tr(
                  'A SmartGlycoAI foi concebida para auxiliar na gestão da diabetes, mas NÃO FORNECE ACONSELHAMENTO MÉDICO. As sugestões de insulina geradas por IA e os alertas preditivos destinam-se apenas a fins informativos. Consulta sempre o teu endocrinologista ou médico antes de efetuar alterações na tua terapêutica.',
                  'SmartGlycoAI is designed to assist in diabetes management, but IT DOES NOT PROVIDE MEDICAL ADVICE. The AI-generated insulin suggestions and predictive alerts are for informational purposes only. Always consult your endocrinologist or physician before making changes to your therapy.',
                ),
                isAlert: true,
              ),
              const SizedBox(height: 24),
              _buildSection(
                icon: Icons.fact_check_outlined,
                title: tr('3. Responsabilidades do Utilizador',
                    '3. User Responsibilities'),
                content: tr(
                  'És responsável por garantir a exatidão dos dados que introduces (hidratos de carbono, registos manuais de glicemia). Os modelos de IA dependem fortemente de dados rigorosos. Não dependas exclusivamente da aplicação em situações de emergência.',
                  'You are responsible for ensuring the accuracy of the data you input (carbohydrates, manual glucose entries). The AI models rely heavily on accurate data. Do not rely solely on the app in emergency situations.',
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                icon: Icons.block_flipped,
                title: tr('4. Limitação de Responsabilidade',
                    '4. Limitation of Liability'),
                content: tr(
                  'Na extensão máxima permitida por lei, a SmartGlycoAI e os seus programadores não serão responsáveis por quaisquer danos diretos, indiretos, incidentais ou consequenciais resultantes da utilização ou incapacidade de utilização do serviço.',
                  'To the maximum extent permitted by law, SmartGlycoAI and its developers shall not be liable for any direct, indirect, incidental, or consequential damages resulting from the use or inability to use the service.',
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
      required String content,
      bool isAlert = false}) {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);

    final themeColor = isAlert
        ? (isHighContrast ? const Color(0xFFFFD600) : const Color(0xFFF43F5E))
        : (isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6));

    final borderColor = isHighContrast
        ? themeColor
        : (isAlert
            ? themeColor.withOpacity(0.3)
            : Colors.white.withOpacity(0.05));
    final bgColor = isHighContrast
        ? Colors.black
        : (isAlert ? themeColor.withOpacity(0.05) : cardColor);
    final contentColor = isHighContrast ? Colors.white : Colors.white70;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: themeColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          color: themeColor,
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