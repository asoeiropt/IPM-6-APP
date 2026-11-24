import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_data.dart';

class HealthSettingsScreen extends StatefulWidget {
  const HealthSettingsScreen({super.key});

  @override
  State<HealthSettingsScreen> createState() => _HealthSettingsScreenState();
}

class _HealthSettingsScreenState extends State<HealthSettingsScreen> {
  late final TextEditingController _lowTargetCtrl;
  late final TextEditingController _highTargetCtrl;
  late final TextEditingController _icrCtrl;
  late final TextEditingController _isfCtrl;
  late final TextEditingController _basalCtrl;

  bool _predictiveAlerts = true;
  bool _shareDataWithDoctor = true;

  @override
  void initState() {
    super.initState();
    _lowTargetCtrl = TextEditingController(text: '70');
    _highTargetCtrl = TextEditingController(text: '180');
    _icrCtrl = TextEditingController(text: globalIcr.toStringAsFixed(0));
    _isfCtrl = TextEditingController(text: globalIsf.toStringAsFixed(0));
    _basalCtrl = TextEditingController(text: '14');
  }

  @override
  void dispose() {
    _lowTargetCtrl.dispose();
    _highTargetCtrl.dispose();
    _icrCtrl.dispose();
    _isfCtrl.dispose();
    _basalCtrl.dispose();
    super.dispose();
  }

  void _saveHealthSettings() {
    HapticFeedback.mediumImpact();

    final parsedIcr = double.tryParse(_icrCtrl.text.trim());
    final parsedIsf = double.tryParse(_isfCtrl.text.trim());

    if (parsedIcr == null ||
        parsedIcr <= 0 ||
        parsedIsf == null ||
        parsedIsf <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr(
            '⚠️ ICR e ISF devem ser valores numéricos maiores que 0.',
            '⚠️ ICR and ISF must be numeric values greater than 0.',
          )),
          backgroundColor: const Color(0xFFF43F5E),
        ),
      );
      return;
    }

    globalIcr = parsedIcr;
    globalIsf = parsedIsf;
    saveData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(
            '✅ Definições clínicas guardadas! (ICR: ${globalIcr.toStringAsFixed(0)}g/U, ISF: ${globalIsf.toStringAsFixed(0)})',
            '✅ Health Settings Saved! (ICR: ${globalIcr.toStringAsFixed(0)}g/U, ISF: ${globalIsf.toStringAsFixed(0)})',
          ),
          style: TextStyle(
            color: isHighContrast ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF2DD4BF),
      ),
    );
    Navigator.pop(context);
  }

  InputDecoration _customInputDeco(String label, String suffix, Color cardColor,
      Color borderColor, Color textColor, Color subTextColor) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: subTextColor, fontSize: 13),
      suffixText: suffix,
      suffixStyle: TextStyle(color: subTextColor, fontWeight: FontWeight.bold),
      filled: true,
      fillColor: isHighContrast ? Colors.black : cardColor,
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: borderColor, width: isHighContrast ? 2 : 1)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: isHighContrast
                  ? const Color(0xFFFFD600)
                  : const Color(0xFF3B82F6),
              width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
    final actionColor =
        isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: mainTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(tr('Definições Clínicas', 'Health Settings'),
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
              // --- GLUCOSE TARGETS ---
              Text(tr('ALVOS DE GLICEMIA', 'GLUCOSE TARGETS'),
                  style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lowTargetCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      decoration: _customInputDeco(
                          tr('Limite Mínimo', 'Low Target'),
                          'mg/dL',
                          cardColor,
                          borderColor,
                          mainTextColor,
                          subTextColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _highTargetCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      decoration: _customInputDeco(
                          tr('Limite Máximo', 'High Target'),
                          'mg/dL',
                          cardColor,
                          borderColor,
                          mainTextColor,
                          subTextColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- INSULIN PARAMETERS ---
              Text(tr('PARÂMETROS DE INSULINA', 'INSULIN PARAMETERS'),
                  style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _icrCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: _customInputDeco(
                    tr('Rácio Insulina/Hidratos (ICR)',
                        'Insulin-to-Carb Ratio (ICR)'),
                    'g / U',
                    cardColor,
                    borderColor,
                    mainTextColor,
                    subTextColor),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _isfCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: _customInputDeco(
                    tr('Fator de Sensibilidade (ISF)',
                        'Insulin Sensitivity Factor (ISF)'),
                    'mg/dL / U',
                    cardColor,
                    borderColor,
                    mainTextColor,
                    subTextColor),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _basalCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: _customInputDeco(
                    tr('Insulina Basal Diária', 'Daily Basal Insulin'),
                    'U',
                    cardColor,
                    borderColor,
                    mainTextColor,
                    subTextColor),
              ),
              const SizedBox(height: 32),

              // --- PREFERENCES & ALERTS ---
              Text(tr('PREFERÊNCIAS & ALERTAS', 'PREFERENCES & ALERTS'),
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
                          tr('Alertas Preditivos', 'Predictive Alerts'),
                          style: TextStyle(
                              color: mainTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                      subtitle: Text(
                          tr('Avisar antes de hipoglicemia',
                              'Warn before hypoglycemia'),
                          style: TextStyle(color: subTextColor, fontSize: 12)),
                      activeColor: isHighContrast ? Colors.black : actionColor,
                      activeTrackColor:
                          isHighContrast ? const Color(0xFFFFD600) : null,
                      value: _predictiveAlerts,
                      onChanged: (bool value) {
                        HapticFeedback.lightImpact();
                        setState(() => _predictiveAlerts = value);
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
                          tr('Partilhar com o Médico', 'Share with Doctor'),
                          style: TextStyle(
                              color: mainTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                      subtitle: Text(
                          tr('Sincronizar relatórios no Centro de Saúde',
                              'Auto-sync reports to Care Hub'),
                          style: TextStyle(color: subTextColor, fontSize: 12)),
                      activeColor: isHighContrast ? Colors.black : actionColor,
                      activeTrackColor:
                          isHighContrast ? const Color(0xFFFFD600) : null,
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
                onTap: _saveHealthSettings,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: isHighContrast ? const Color(0xFFFFD600) : null,
                    gradient: isHighContrast
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isHighContrast
                        ? null
                        : [
                            BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4))
                          ],
                  ),
                  child: Center(
                    child: Text(tr('Guardar Definições', 'Save Settings'),
                        style: TextStyle(
                            color: isHighContrast ? Colors.black : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
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