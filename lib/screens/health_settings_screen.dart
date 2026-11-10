import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HealthSettingsScreen extends StatefulWidget {
  const HealthSettingsScreen({super.key});

  @override
  State<HealthSettingsScreen> createState() => _HealthSettingsScreenState();
}

class _HealthSettingsScreenState extends State<HealthSettingsScreen> {
  final Color bgColor = const Color(0xFF090C10);
  final Color cardColor = const Color(0xFF141923);
  final Gradient neonGradient = const LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)], 
  );

  bool _predictiveAlerts = true;
  bool _shareDataWithDoctor = true;

  InputDecoration _customInputDeco(String label, String suffix) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      suffixText: suffix,
      suffixStyle: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
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
        title: const Text('Health Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- GLUCOSE TARGETS ---
              const Text('GLUCOSE TARGETS', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: '70',
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: _customInputDeco('Low Target', 'mg/dL'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: '180',
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: _customInputDeco('High Target', 'mg/dL'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- INSULIN PARAMETERS ---
              const Text('INSULIN PARAMETERS', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: '15',
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: _customInputDeco('Insulin-to-Carb Ratio (ICR)', 'g / U'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: '50',
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: _customInputDeco('Insulin Sensitivity Factor (ISF)', 'mg/dL / U'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: '14',
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: _customInputDeco('Daily Basal Insulin', 'U'),
              ),
              const SizedBox(height: 32),

              // --- PREFERENCES & ALERTS ---
              const Text('PREFERENCES & ALERTS', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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
                      title: const Text('Predictive Alerts', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                      subtitle: const Text('Warn before hypoglycemia', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      activeColor: const Color(0xFF3B82F6),
                      value: _predictiveAlerts,
                      onChanged: (bool value) {
                        HapticFeedback.lightImpact();
                        setState(() => _predictiveAlerts = value);
                      },
                    ),
                    Divider(color: Colors.white.withOpacity(0.05), height: 1, indent: 20, endIndent: 20),
                    SwitchListTile(
                      title: const Text('Share with Doctor', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                      subtitle: const Text('Auto-sync reports to Care Hub', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      activeColor: const Color(0xFF3B82F6),
                      value: _shareDataWithDoctor,
                      onChanged: (bool value) {
                        HapticFeedback.lightImpact();
                        setState(() => _shareDataWithDoctor = value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- BOTÃO GRAVAR ---
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Health Settings Saved!'), backgroundColor: Color(0xFF2DD4BF)));
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
                    child: Text('Save Settings', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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