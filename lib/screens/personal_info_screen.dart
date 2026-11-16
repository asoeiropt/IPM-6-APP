import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_data.dart'; // Importante para ler o isHighContrast

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {

  InputDecoration _customInputDeco(String label, IconData icon, Color cardColor, Color borderColor, Color mainTextColor, Color subTextColor) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: subTextColor, fontSize: 14),
      prefixIcon: Icon(icon, color: subTextColor, size: 20),
      filled: true,
      fillColor: isHighContrast ? Colors.black : cardColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), 
        borderSide: BorderSide(color: borderColor, width: isHighContrast ? 2 : 1)
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), 
        borderSide: BorderSide(color: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6), width: 2)
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE ALTO CONTRASTE ---
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final mainTextColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : Colors.white54;
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);
    final actionColor = isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: mainTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainTextColor)),
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
                        border: Border.all(color: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6).withOpacity(0.5), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: isHighContrast ? Colors.transparent : const Color(0xFF387A76),
                        child: Icon(Icons.person, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, size: 50),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isHighContrast ? Colors.black : const Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                            border: Border.all(color: isHighContrast ? const Color(0xFFFFD600) : bgColor, width: 3),
                          ),
                          child: Icon(Icons.camera_alt, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, size: 16),
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
                style: TextStyle(color: isHighContrast ? Colors.white : Colors.white),
                decoration: _customInputDeco('Full Name', Icons.person_outline, cardColor, borderColor, mainTextColor, subTextColor),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                initialValue: 'joao.antunes@email.com',
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: isHighContrast ? Colors.white : Colors.white),
                decoration: _customInputDeco('Email Address', Icons.mail_outline, cardColor, borderColor, mainTextColor, subTextColor),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                initialValue: '+351 912 345 678',
                keyboardType: TextInputType.phone,
                style: TextStyle(color: isHighContrast ? Colors.white : Colors.white),
                decoration: _customInputDeco('Phone Number', Icons.phone_outlined, cardColor, borderColor, mainTextColor, subTextColor),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                initialValue: '15/08/1998',
                style: TextStyle(color: isHighContrast ? Colors.white : Colors.white),
                decoration: _customInputDeco('Date of Birth', Icons.calendar_today_outlined, cardColor, borderColor, mainTextColor, subTextColor),
              ),
              const SizedBox(height: 40),
              
              // --- BOTÃO GRAVAR ---
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('✅ Profile Updated!', style: TextStyle(color: isHighContrast ? Colors.black : Colors.white, fontWeight: FontWeight.bold)), 
                    backgroundColor: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF2DD4BF)
                  ));
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: isHighContrast ? const Color(0xFFFFD600) : null,
                    gradient: isHighContrast 
                        ? null 
                        : const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isHighContrast ? null : [
                      BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Center(
                    child: Text('Save Changes', style: TextStyle(color: isHighContrast ? Colors.black : Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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