import 'package:flutter/material.dart';
import '../app_data.dart'; // <-- Acesso ao isHighContrast

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE ALTO CONTRASTE ---
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);
    final mainTextColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
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
        title: Text('Terms of Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainTextColor)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Effective Date: November 2026', style: TextStyle(color: subTextColor, fontSize: 13)),
              const SizedBox(height: 24),
              
              _buildSection(
                icon: Icons.gavel_outlined,
                title: '1. Acceptance of Terms',
                content: 'By creating an account and using SmartGlycoAI, you agree to be bound by these Terms of Service. If you do not agree, please do not use the application.',
              ),
              const SizedBox(height: 24),
              
              _buildSection(
                icon: Icons.medical_information_outlined,
                title: '2. Not Medical Advice (Disclaimer)',
                content: 'SmartGlycoAI is designed to assist in diabetes management, but IT DOES NOT PROVIDE MEDICAL ADVICE. The AI-generated insulin suggestions and predictive alerts are for informational purposes only. Always consult your endocrinologist or physician before making changes to your therapy.',
                isAlert: true,
              ),
              const SizedBox(height: 24),
              
              _buildSection(
                icon: Icons.fact_check_outlined,
                title: '3. User Responsibilities',
                content: 'You are responsible for ensuring the accuracy of the data you input (carbohydrates, manual glucose entries). The AI models rely heavily on accurate data. Do not rely solely on the app in emergency situations.',
              ),
              const SizedBox(height: 24),
              
              _buildSection(
                icon: Icons.block_flipped,
                title: '4. Limitation of Liability',
                content: 'To the maximum extent permitted by law, SmartGlycoAI and its developers shall not be liable for any direct, indirect, incidental, or consequential damages resulting from the use or inability to use the service.',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required String content, bool isAlert = false}) {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    
    // Se for alert, fica vermelho. Se for normal, fica amarelo (se alto contraste) ou azul (se normal)
    final themeColor = isAlert 
        ? (isHighContrast ? const Color(0xFFFFD600) : const Color(0xFFF43F5E)) 
        : (isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6));
        
    final borderColor = isHighContrast ? themeColor : (isAlert ? themeColor.withOpacity(0.3) : Colors.white.withOpacity(0.05));
    final bgColor = isHighContrast ? Colors.black : (isAlert ? themeColor.withOpacity(0.05) : cardColor);
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
              Expanded(child: Text(title, style: TextStyle(color: themeColor, fontSize: 16, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: TextStyle(color: contentColor, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}