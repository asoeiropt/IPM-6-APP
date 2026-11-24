import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_data.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _diagnosisYearCtrl;

  String _selectedDiabetesType = 'Diabetes Tipo 1';
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _diabetesTypes = [
    'Diabetes Tipo 1',
    'Diabetes Tipo 2',
    'Diabetes Gestacional',
    'LADA',
  ];

  String _diabetesTypeLabel(String type) {
    switch (type) {
      case 'Diabetes Tipo 1':
        return tr('Diabetes Tipo 1', 'Type 1 Diabetes');
      case 'Diabetes Tipo 2':
        return tr('Diabetes Tipo 2', 'Type 2 Diabetes');
      case 'Diabetes Gestacional':
        return tr('Diabetes Gestacional', 'Gestational Diabetes');
      case 'LADA':
        return 'LADA';
      default:
        return type;
    }
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: currentUserName);
    _emailCtrl = TextEditingController(text: currentUserEmail);
    _phoneCtrl = TextEditingController(text: currentUserPhone);
    _dobCtrl = TextEditingController(text: currentUserDob);
    _diagnosisYearCtrl = TextEditingController(text: currentDiagnosisYear);

    if (_diabetesTypes.contains(currentDiabetesType)) {
      _selectedDiabetesType = currentDiabetesType;
    }

    _loadUserFromFirestore();
  }

  Future<void> _loadUserFromFirestore() async {
    // Valores default apenas para as contas de demonstração caso ainda não tenham doc no Firestore
    String fallbackName = currentUserName;
    String fallbackEmail = currentUserEmail;
    String fallbackPhone = currentUserPhone;
    String fallbackDob = currentUserDob;
    String fallbackYear = currentDiagnosisYear;
    String fallbackType = currentDiabetesType;

    if (currentUserId == 'paciente_joao') {
      if (fallbackName.isEmpty) fallbackName = 'João Antunes';
      if (fallbackEmail.isEmpty) fallbackEmail = 'joao@smartglyco.pt';
      if (fallbackPhone.isEmpty) fallbackPhone = '+351 912 345 678';
      if (fallbackDob.isEmpty) fallbackDob = '15/08/1998';
      if (fallbackYear.isEmpty) fallbackYear = '2021';
    } else if (currentUserId == 'paciente_maria') {
      if (fallbackName.isEmpty) fallbackName = 'Maria Silva';
      if (fallbackEmail.isEmpty) fallbackEmail = 'maria@smartglyco.pt';
      if (fallbackPhone.isEmpty) fallbackPhone = '+351 963 852 741';
      if (fallbackDob.isEmpty) fallbackDob = '22/03/1995';
      if (fallbackYear.isEmpty) fallbackYear = '2019';
    }

    if (currentUserId.isEmpty) {
      _applyValues(fallbackName, fallbackEmail, fallbackPhone, fallbackDob,
          fallbackType, fallbackYear);
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        fallbackName = (data['name'] ?? fallbackName).toString();
        fallbackEmail = (data['email'] ?? fallbackEmail).toString();
        fallbackPhone = (data['phone'] ?? fallbackPhone).toString();
        fallbackDob = (data['dob'] ?? fallbackDob).toString();
        fallbackType = (data['diabetesType'] ?? fallbackType).toString();
        fallbackYear = (data['diagnosisYear'] ?? fallbackYear).toString();
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao carregar perfil do Firestore: $e');
    }

    _applyValues(fallbackName, fallbackEmail, fallbackPhone, fallbackDob,
        fallbackType, fallbackYear);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _applyValues(String name, String email, String phone, String dob,
      String dType, String year) {
    _nameCtrl.text = name;
    _emailCtrl.text = email;
    _phoneCtrl.text = phone;
    _dobCtrl.text = dob;
    _diagnosisYearCtrl.text = year;
    if (_diabetesTypes.contains(dType)) {
      _selectedDiabetesType = dType;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _diagnosisYearCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1998, 8, 15),
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() {
        _dobCtrl.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _saveProfile() async {
    HapticFeedback.mediumImpact();
    final updatedName = _nameCtrl.text.trim();
    final updatedEmail = _emailCtrl.text.trim().toLowerCase();
    final updatedPhone = _phoneCtrl.text.trim();
    final updatedDob = _dobCtrl.text.trim();
    final updatedYear = _diagnosisYearCtrl.text.trim();

    if (updatedName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr(
            '⚠️ O nome não pode ficar vazio.',
            '⚠️ Name cannot be empty.',
          )),
          backgroundColor: const Color(0xFFF43F5E),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    currentUserName = updatedName;
    currentUserEmail = updatedEmail;
    currentUserPhone = updatedPhone;
    currentUserDob = updatedDob;
    currentDiabetesType = _selectedDiabetesType;
    currentDiagnosisYear = updatedYear;
    await saveData();

    try {
      if (currentUserId.isNotEmpty) {
        final parts = updatedName.split(' ');
        final initials = parts.length >= 2
            ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
            : updatedName[0].toUpperCase();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .set({
          'name': updatedName,
          'email': updatedEmail,
          'phone': updatedPhone,
          'dob': updatedDob,
          'diabetesType': _selectedDiabetesType,
          'diagnosisYear': updatedYear,
          'initials': initials,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao atualizar perfil no Firestore: $e');
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr('✅ Perfil atualizado na nuvem!', '✅ Profile Updated!'),
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

  InputDecoration _customInputDeco(String label, IconData icon, Color cardColor,
      Color borderColor, Color mainTextColor, Color subTextColor,
      {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: subTextColor, fontSize: 14),
      prefixIcon: Icon(icon, color: subTextColor, size: 20),
      suffixIcon: suffixIcon,
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: mainTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(tr('Informação Pessoal', 'Personal Information'),
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: mainTextColor)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: isHighContrast
                      ? const Color(0xFFFFD600)
                      : const Color(0xFF3B82F6),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // --- AVATAR ---
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isHighContrast
                                  ? const Color(0xFFFFD600)
                                  : const Color(0xFF3B82F6).withOpacity(0.5),
                              width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: isHighContrast
                              ? Colors.transparent
                              : const Color(0xFF387A76),
                          child: Icon(Icons.person,
                              color: isHighContrast
                                  ? const Color(0xFFFFD600)
                                  : Colors.white,
                              size: 48),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- FORMULÁRIO PESSOAL ---
                    TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: _customInputDeco(
                          tr('Nome Completo', 'Full Name'),
                          Icons.person_outline,
                          cardColor,
                          borderColor,
                          mainTextColor,
                          subTextColor),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: _customInputDeco(
                          tr('Endereço de Email', 'Email Address'),
                          Icons.mail_outline,
                          cardColor,
                          borderColor,
                          mainTextColor,
                          subTextColor),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: _customInputDeco(
                          tr('Número de Telemóvel', 'Phone Number'),
                          Icons.phone_outlined,
                          cardColor,
                          borderColor,
                          mainTextColor,
                          subTextColor),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _dobCtrl,
                      readOnly: true,
                      onTap: _pickDob,
                      style: const TextStyle(color: Colors.white),
                      decoration: _customInputDeco(
                        tr('Data de Nascimento', 'Date of Birth'),
                        Icons.calendar_today_outlined,
                        cardColor,
                        borderColor,
                        mainTextColor,
                        subTextColor,
                        suffixIcon: Icon(Icons.edit_calendar,
                            color: subTextColor, size: 18),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- TIPO DE DIABETES ---
                    DropdownButtonFormField<String>(
                      value: _selectedDiabetesType,
                      dropdownColor:
                          isHighContrast ? Colors.black : const Color(0xFF141923),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: _customInputDeco(
                          tr('Tipo de Diabetes', 'Diabetes Type'),
                          Icons.bloodtype_outlined,
                          cardColor,
                          borderColor,
                          mainTextColor,
                          subTextColor),
                      items: _diabetesTypes.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(_diabetesTypeLabel(t)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedDiabetesType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- ANO DE DIAGNÓSTICO ---
                    TextFormField(
                      controller: _diagnosisYearCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _customInputDeco(
                          tr('Ano de Diagnóstico', 'Diagnosis Year'),
                          Icons.history_edu_outlined,
                          cardColor,
                          borderColor,
                          mainTextColor,
                          subTextColor),
                    ),
                    const SizedBox(height: 36),

                    // --- BOTÃO GRAVAR ---
                    GestureDetector(
                      onTap: _isSaving ? null : _saveProfile,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: isHighContrast ? const Color(0xFFFFD600) : null,
                          gradient: isHighContrast
                              ? null
                              : const LinearGradient(colors: [
                                  Color(0xFF3B82F6),
                                  Color(0xFF8B5CF6)
                                ]),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: isHighContrast
                              ? null
                              : [
                                  BoxShadow(
                                      color: const Color(0xFF3B82F6)
                                          .withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4)),
                                ],
                        ),
                        child: Center(
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  tr('Guardar Alterações', 'Save Changes'),
                                  style: TextStyle(
                                      color: isHighContrast
                                          ? Colors.black
                                          : Colors.white,
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