import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';
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

  final Color bgColor = const Color(0xFF090C10);
  final Color cardColor = const Color(0xFF141923);
  final Gradient neonGradient = const LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)], 
  );

  final List<String> _availableTags = ['🏋️ Pós-Treino', '🤒 Doente', '😤 Stress', '🏃 Ativo'];
  final List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _entryType = widget.initialType; 
  }

  @override
  void dispose() { 
    tCtrl.dispose(); 
    cCtrl.dispose(); 
    iCtrl.dispose(); 
    super.dispose(); 
  }

  Future<void> _scanBarcode() async {
    HapticFeedback.lightImpact();
    try {
      String? barcodeScanRes = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              title: const Text('Digitalizar Código', style: TextStyle(color: Colors.white, fontSize: 16)),
              backgroundColor: cardColor,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String? code = barcodes.first.rawValue;
                  if (code != null) {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context, code);
                  }
                }
              },
            ),
          ),
        ),
      );

      if (barcodeScanRes != null && barcodeScanRes != '-1' && barcodeScanRes.isNotEmpty) {
        setState(() { _isLoadingBarcode = true; });
        final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcodeScanRes.json');
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 1) { 
            final product = data['product'];
            setState(() { 
              tCtrl.text = product['product_name'] ?? 'Unknown Product'; 
              cCtrl.text = (double.tryParse((product['nutriments']?['carbohydrates_100g'] ?? 0).toString()) ?? 0.0).toStringAsFixed(1); 
              iCtrl.text = ((double.tryParse(cCtrl.text) ?? 0) / globalIcr).toStringAsFixed(1); 
            });
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Product fetched!'), backgroundColor: Color(0xFF2DD4BF)));
          } else {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Product not found.'), backgroundColor: Colors.orangeAccent));
          }
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() { _isLoadingBarcode = false; });
    }
  }

  InputDecoration _customInputDeco(String label, String suffix) {
    return InputDecoration(
      labelText: label, 
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 14),
      suffixText: suffix, 
      suffixStyle: const TextStyle(color: Colors.white54),
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
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('Log Entry', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: const Icon(Icons.edit_note, color: Colors.white54, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  _buildTypeTab('meal', '🍽️ Meal'),
                  _buildTypeTab('correction', '💧 Correction'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // --- A NOVA BARRA DE PESQUISA / SCANNER DE CÓDIGO ---
            TextField(
              controller: tCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search food or scan barcode',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: IconButton(
                  icon: _isLoadingBarcode 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54))
                      : const Icon(Icons.qr_code_scanner, color: Colors.white54),
                  onPressed: _isLoadingBarcode ? null : _scanBarcode,
                ),
                filled: true,
                fillColor: cardColor,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(controller: cCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: _customInputDeco('Carbs', 'g')), 
            const SizedBox(height: 16),
            TextField(controller: iCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: _customInputDeco('Insulin', 'U')), 
            const SizedBox(height: 24),
            
            const Text('Tags', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  selected: isSelected,
                  selectedColor: const Color(0xFF3B82F6),
                  backgroundColor: cardColor,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), 
                    side: BorderSide(color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.05))
                  ),
                  onSelected: (bool selected) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            
            GestureDetector(
              onTap: () { 
                HapticFeedback.mediumImpact(); 
                globalDiary.insert(0, {
                  'title': tCtrl.text.isEmpty ? 'Manual Log' : tCtrl.text, 
                  'carbs': double.tryParse(cCtrl.text) ?? 0.0, 
                  'insulin': double.tryParse(iCtrl.text) ?? 0.0, 
                  'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}', 
                  'type': _entryType, 
                  'imagePath': null,
                  'tags': List<String>.from(_selectedTags) 
                }); 
                saveData(); 
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Logged!'), backgroundColor: Color(0xFF2DD4BF))); 
                Navigator.of(context).pop(); 
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
                  child: Text('Save Log', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _entryType = typeValue);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? neonGradient : null,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}