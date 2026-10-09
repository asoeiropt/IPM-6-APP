import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';
import '../app_data.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});
  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final TextEditingController tCtrl = TextEditingController(); 
  final TextEditingController cCtrl = TextEditingController(); 
  final TextEditingController iCtrl = TextEditingController(); 
  String _entryType = 'meal'; 
  bool _isLoadingBarcode = false; 

  @override
  void dispose() { tCtrl.dispose(); cCtrl.dispose(); iCtrl.dispose(); super.dispose(); }

  Future<void> _scanBarcode() async {
    try {
      String? barcodeScanRes = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Digitalizar Código', style: TextStyle(color: textMain, fontSize: 16)),
              backgroundColor: cardDark,
              iconTheme: const IconThemeData(color: textMain),
            ),
            body: MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String? code = barcodes.first.rawValue;
                  if (code != null) {
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
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Product fetched!', style: TextStyle(color: Colors.black)), backgroundColor: Colors.greenAccent));
          } else {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Product not found.', style: TextStyle(color: Colors.black)), backgroundColor: Colors.orangeAccent));
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
      labelText: label, labelStyle: TextStyle(color: textMuted, fontSize: 14),
      suffixText: suffix, suffixStyle: TextStyle(color: textMuted),
      filled: true, fillColor: cardDark,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderDark)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(title: const Text('✍️ Log Entry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textMain)), backgroundColor: cardDark, elevation: 0, shape: Border(bottom: BorderSide(color: borderDark, width: 1)), iconTheme: const IconThemeData(color: textMain)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [ButtonSegment(value: 'meal', label: Text('🍽️ Meal')), ButtonSegment(value: 'correction', label: Text('💧 Correction'))], 
              selected: {_entryType}, 
              onSelectionChanged: (Set<String> s) => setState(() => _entryType = s.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.white : cardDark),
                foregroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.black : textMain),
                side: WidgetStateProperty.all(BorderSide(color: borderDark))
              ),
            ), 
            const SizedBox(height: 24),
            
            ElevatedButton.icon(
              onPressed: _isLoadingBarcode ? null : _scanBarcode,
              icon: _isLoadingBarcode ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(Icons.qr_code_scanner, size: 18),
              label: Text(_isLoadingBarcode ? '🔍 Scanning DB...' : '🔍 Scan Barcode', style: const TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            ),
            
            Padding(padding: const EdgeInsets.symmetric(vertical: 24.0), child: Row(children: [Expanded(child: Divider(color: borderDark)), Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Text('✍️ MANUAL', style: TextStyle(color: textMuted, fontSize: 10, letterSpacing: 1.2))), Expanded(child: Divider(color: borderDark))])),
            
            TextField(controller: tCtrl, style: const TextStyle(color: textMain), decoration: _customInputDeco('Description', '')), const SizedBox(height: 16),
            TextField(controller: cCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: textMain), decoration: _customInputDeco('Carbs', 'g')), const SizedBox(height: 16),
            TextField(controller: iCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: textMain), decoration: _customInputDeco('Insulin', 'U')), const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: () { globalDiary.insert(0, {'title': tCtrl.text.isEmpty ? 'Manual Log' : tCtrl.text, 'carbs': double.tryParse(cCtrl.text) ?? 0.0, 'insulin': double.tryParse(iCtrl.text) ?? 0.0, 'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}', 'type': _entryType, 'imagePath': null }); saveData(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Logged!', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white)); Navigator.of(context).pop(); }, 
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: cardDark, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: borderDark))),
              child: const Text('💾 Save Log', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}