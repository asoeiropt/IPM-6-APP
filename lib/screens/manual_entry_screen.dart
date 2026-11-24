import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../app_data.dart';

class ManualEntryScreen extends StatefulWidget {
  final String initialType;
  const ManualEntryScreen({super.key, this.initialType = 'meal'});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final TextEditingController tCtrl = TextEditingController();
  final TextEditingController cCtrl = TextEditingController();
  final TextEditingController iCtrl = TextEditingController();
  late String _entryType;
  bool _isLoadingBarcode = false;

  final List<String> _tagKeys = ['post_workout', 'sick', 'stress', 'active'];
  final List<String> _selectedTagKeys = [];

  String _tagLabel(String key) {
    switch (key) {
      case 'post_workout':
        return tr('🏋️ Pós-Treino', '🏋️ Post-Workout');
      case 'sick':
        return tr('🤒 Doente', '🤒 Sick');
      case 'stress':
        return tr('😤 Stress', '😤 Stress');
      case 'active':
        return tr('🏃 Ativo', '🏃 Active');
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _entryType = widget.initialType;

    cCtrl.addListener(() {
      if (!_isLoadingBarcode) {
        _recalculateInsulinWithTags();
      }
    });
  }

  @override
  void dispose() {
    tCtrl.dispose();
    cCtrl.dispose();
    iCtrl.dispose();
    super.dispose();
  }

  double _parsePositive(String raw) {
    final parsed = double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0.0;
    return parsed > 0 ? parsed : 0.0;
  }

  void _recalculateInsulinWithTags() {
    final double carbs = _parsePositive(cCtrl.text);
    if (carbs <= 0) {
      if (iCtrl.text.isNotEmpty) {
        iCtrl.clear();
      }
      return;
    }

    double baseInsulin = globalIcr > 0 ? (carbs / globalIcr) : 0.0;

    final bool hasStressOrSick = _selectedTagKeys.contains('sick') ||
        _selectedTagKeys.contains('stress');
    final bool hasActiveOrWorkout = _selectedTagKeys.contains('post_workout') ||
        _selectedTagKeys.contains('active');

    if (hasStressOrSick) {
      baseInsulin *= 1.20;
    }
    if (hasActiveOrWorkout) {
      baseInsulin *= 0.80;
    }

    iCtrl.text = baseInsulin.toStringAsFixed(1);
  }

  Future<void> _triggerWarningHaptic() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.heavyImpact();
  }

  void _attemptToSave() {
    final String title = tCtrl.text.trim();
    final double carbs = _parsePositive(cCtrl.text);
    final double insulinDose = _parsePositive(iCtrl.text);

    if (title.isEmpty && carbs <= 0 && insulinDose <= 0) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr(
            '⚠️ Preenche a descrição, hidratos ou insulina antes de guardar.',
            '⚠️ Fill in description, carbs, or insulin before saving.',
          )),
          backgroundColor: const Color(0xFFF43F5E),
        ),
      );
      return;
    }

    if (insulinDose >= 15.0) {
      _triggerWarningHaptic();
      _showSafetyWarningDialog(insulinDose);
    } else {
      HapticFeedback.mediumImpact();
      _executeSave();
    }
  }

  void _showSafetyWarningDialog(double dose) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isHighContrast ? Colors.black : const Color(0xFF1E1E2A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                color:
                    isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent,
                width: 2)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color:
                    isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent,
                size: 28),
            const SizedBox(width: 10),
            Text(tr('Alerta de Segurança', 'Safety Alert'),
                style: TextStyle(
                    color: isHighContrast
                        ? const Color(0xFFFFD600)
                        : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          tr(
            'A dose calculada é de $dose U.\nIsto é invulgarmente alto e pode causar hipoglicemia severa. Tens a certeza que queres registar este valor?',
            'The calculated dose is $dose U.\nThis is unusually high and may cause severe hypoglycemia. Are you sure you want to log this value?',
          ),
          style: TextStyle(
              color: isHighContrast ? Colors.white : Colors.white70,
              fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
            },
            child: Text(tr('CORRIGIR', 'EDIT'),
                style: TextStyle(
                    color: isHighContrast ? Colors.white : Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent,
              foregroundColor: isHighContrast ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              _executeSave();
            },
            child: Text(tr('CONFIRMAR', 'CONFIRM'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _executeSave() {
    final now = DateTime.now();
    final safeTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final String defaultTitle = _entryType == 'correction'
        ? tr('Correção Manual', 'Manual Correction')
        : tr('Registo Manual', 'Manual Log');

    globalDiary.insert(0, {
      'title': tCtrl.text.trim().isEmpty ? defaultTitle : tCtrl.text.trim(),
      'carbs': _parsePositive(cCtrl.text),
      'insulin': _parsePositive(iCtrl.text),
      'time': safeTime,
      'type': _entryType,
      'imagePath': null,
      'tags': _selectedTagKeys.map(_tagLabel).toList(),
    });

    saveData();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr('✅ Registo guardado!', '✅ Log saved!'),
            style: TextStyle(
                color: isHighContrast ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold)),
        backgroundColor: isHighContrast
            ? const Color(0xFFFFD600)
            : const Color(0xFF2DD4BF)));
    Navigator.of(context).pop();
  }

  Future<void> _scanBarcode() async {
    HapticFeedback.lightImpact();
    MobileScannerController cameraController = MobileScannerController();

    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);

    try {
      String? barcodeScanRes = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              title: Text(tr('Digitalizar Código', 'Scan Barcode'),
                  style: TextStyle(
                      color: isHighContrast
                          ? const Color(0xFFFFD600)
                          : Colors.white,
                      fontSize: 16)),
              backgroundColor: cardColor,
              iconTheme: IconThemeData(
                  color:
                      isHighContrast ? const Color(0xFFFFD600) : Colors.white),
            ),
            body: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final String? code = barcodes.first.rawValue;
                      if (code != null) {
                        cameraController.stop();
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context, code);
                      }
                    }
                  },
                ),
                Center(
                  child: Container(
                    width: 250,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: isHighContrast
                              ? const Color(0xFFFFD600)
                              : const Color(0xFF2DD4BF),
                          width: 3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (barcodeScanRes != null &&
          barcodeScanRes != '-1' &&
          barcodeScanRes.isNotEmpty) {
        setState(() {
          _isLoadingBarcode = true;
        });
        final url = Uri.parse(
            'https://world.openfoodfacts.org/api/v0/product/$barcodeScanRes.json');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 1) {
            final product = data['product'];
            final double fetchedCarbs = double.tryParse(
                    (product['nutriments']?['carbohydrates_100g'] ?? 0)
                        .toString()) ??
                0.0;
            setState(() {
              tCtrl.text = product['product_name'] ??
                  tr('Produto Desconhecido', 'Unknown Product');
              cCtrl.text =
                  fetchedCarbs > 0 ? fetchedCarbs.toStringAsFixed(1) : '';
              _recalculateInsulinWithTags();
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      tr('✅ Produto adicionado!', '✅ Product added!'),
                      style: TextStyle(
                          color: isHighContrast ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold)),
                  backgroundColor: isHighContrast
                      ? const Color(0xFFFFD600)
                      : const Color(0xFF2DD4BF)));
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      tr('⚠️ Produto não encontrado.', '⚠️ Product not found.'),
                      style: TextStyle(
                          color: isHighContrast ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold)),
                  backgroundColor: isHighContrast
                      ? const Color(0xFFFFD600)
                      : Colors.orangeAccent));
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('❌ ${tr('Erro de rede', 'Network error')}: $e'),
            backgroundColor: Colors.redAccent));
      }
    } finally {
      cameraController.dispose();
      if (mounted) {
        setState(() {
          _isLoadingBarcode = false;
        });
      }
    }
  }

  InputDecoration _customInputDeco(String label, String suffix, Color cardColor,
      Color borderColor, Color mainTextColor) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
          color: isHighContrast ? Colors.white : Colors.white54, fontSize: 14),
      suffixText: suffix,
      suffixStyle:
          TextStyle(color: isHighContrast ? Colors.white : Colors.white54),
      filled: true,
      fillColor: cardColor,
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
    final borderColor = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_ios_new,
                          color: mainTextColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(tr('Novo Registo', 'Log Entry'),
                        style: TextStyle(
                            color: mainTextColor,
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: borderColor, width: isHighContrast ? 2 : 1),
                  ),
                  child: Icon(Icons.edit_note,
                      color: isHighContrast
                          ? const Color(0xFFFFD600)
                          : Colors.white54,
                      size: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: isHighContrast
                        ? const Color(0xFFFFD600)
                        : Colors.transparent,
                    width: isHighContrast ? 2 : 0),
              ),
              child: Row(
                children: [
                  _buildTypeTab('meal', tr('🍽️ Refeição', '🍽️ Meal')),
                  _buildTypeTab(
                      'correction', tr('💧 Correção', '💧 Correction')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: tCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: tr('Pesquisar alimento ou código de barras',
                    'Search food or scan barcode'),
                hintStyle: TextStyle(
                    color: isHighContrast ? Colors.white54 : Colors.white38),
                prefixIcon: Icon(Icons.search,
                    color: isHighContrast
                        ? const Color(0xFFFFD600)
                        : Colors.white54),
                suffixIcon: IconButton(
                  icon: _isLoadingBarcode
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isHighContrast
                                  ? const Color(0xFFFFD600)
                                  : Colors.white54))
                      : Icon(Icons.qr_code_scanner,
                          color: isHighContrast
                              ? const Color(0xFFFFD600)
                              : Colors.white54),
                  onPressed: _isLoadingBarcode ? null : _scanBarcode,
                ),
                filled: true,
                fillColor: cardColor,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                        color: borderColor, width: isHighContrast ? 2 : 1)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                        color: isHighContrast
                            ? const Color(0xFFFFD600)
                            : const Color(0xFF3B82F6),
                        width: 2)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
                controller: cCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: _customInputDeco(tr('Hidratos', 'Carbs'), 'g',
                    cardColor, borderColor, mainTextColor)),
            const SizedBox(height: 16),
            TextField(
                controller: iCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: _customInputDeco(tr('Insulina', 'Insulin'), 'U',
                    cardColor, borderColor, mainTextColor)),
            const SizedBox(height: 24),
            Text(tr('Etiquetas', 'Tags'),
                style: TextStyle(
                    color: mainTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _tagKeys.map((key) {
                final isSelected = _selectedTagKeys.contains(key);
                return FilterChip(
                  label: Text(_tagLabel(key),
                      style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : (isHighContrast
                                  ? Colors.white
                                  : Colors.white70),
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal)),
                  selected: isSelected,
                  selectedColor: isHighContrast
                      ? const Color(0xFFFFD600)
                      : const Color(0xFF3B82F6),
                  backgroundColor: cardColor,
                  checkmarkColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                          color: isSelected ? Colors.transparent : borderColor,
                          width: isHighContrast ? 2 : 1)),
                  onSelected: (bool selected) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (selected) {
                        _selectedTagKeys.add(key);
                      } else {
                        _selectedTagKeys.remove(key);
                      }
                      _recalculateInsulinWithTags();
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _attemptToSave,
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
                              offset: const Offset(0, 4)),
                        ],
                ),
                child: Center(
                  child: Text(tr('Guardar Registo', 'Save Log'),
                      style: TextStyle(
                          color: isHighContrast ? Colors.black : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeTab(String typeValue, String label) {
    final isSelected = _entryType == typeValue;

    BoxDecoration? decoration;
    if (isSelected) {
      decoration = isHighContrast
          ? BoxDecoration(
              color: const Color(0xFFFFD600),
              borderRadius: BorderRadius.circular(24))
          : BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
              borderRadius: BorderRadius.circular(24));
    }

    final textColor = isSelected
        ? (isHighContrast ? Colors.black : Colors.white)
        : (isHighContrast ? Colors.white : Colors.white54);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _entryType = typeValue);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: decoration,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}