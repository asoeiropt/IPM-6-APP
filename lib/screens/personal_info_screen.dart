import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final Color bgColor = const Color(0xFF090C10);
  final Color cardColor = const Color(0xFF141923);
  final Gradient neonGradient = const LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)], 
  );

  InputDecoration _customInputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      filled: true,
      fillColor: cardColor,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

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
        title: const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // --- AVATAR EDITÁVEL ---
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.5), width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 48,
                        backgroundColor: Color(0xFF387A76),
                        child: Icon(Icons.person, color: Colors.white, size: 50),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          // Lógica para abrir a galeria
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                            border: Border.all(color: bgColor, width: 3),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // --- FORMULÁRIO ---
              TextFormField(
                initialValue: 'João Antunes',
                style: const TextStyle(color: Colors.white),
                decoration: _customInputDeco('Full Name', Icons.person_outline),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                initialValue: 'joao.antunes@email.com',
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: _customInputDeco('Email Address', Icons.mail_outline),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                initialValue: '+351 912 345 678',
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: _customInputDeco('Phone Number', Icons.phone_outlined),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                initialValue: '15/08/1998',
                style: const TextStyle(color: Colors.white),
                decoration: _customInputDeco('Date of Birth', Icons.calendar_today_outlined),
              ),
              const SizedBox(height: 40),
              
              // --- BOTÃO GRAVAR ---
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Profile Updated!'), backgroundColor: Color(0xFF2DD4BF)));
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: neonGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Center(
                    child: Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}