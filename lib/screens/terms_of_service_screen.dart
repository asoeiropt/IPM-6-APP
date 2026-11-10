import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  final Color bgColor = const Color(0xFF090C10);
  final Color cardColor = const Color(0xFF141923);

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
        title: const Text('Terms of Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Effective Date: November 2026', style: TextStyle(color: Colors.white54, fontSize: 13)),
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
                isAlert: true, // Destaca esta secção importante
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isAlert ? const Color(0xFFF43F5E).withOpacity(0.05) : cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isAlert ? const Color(0xFFF43F5E).withOpacity(0.3) : Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isAlert ? const Color(0xFFF43F5E) : const Color(0xFF3B82F6), size: 24),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: TextStyle(color: isAlert ? const Color(0xFFF43F5E) : Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}