import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../app_data.dart';

class DiaryTab extends StatefulWidget {
  const DiaryTab({super.key});

  @override
  State<DiaryTab> createState() => _DiaryTabState();
}

class _DiaryTabState extends State<DiaryTab> {
  final Color bgColor = const Color(0xFF090C10);
  final Color cardColor = const Color(0xFF141923);
  final Gradient neonGradient = const LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)], 
  );

  String _selectedTab = 'Log Meal';
  bool _isLoadingBarcode = false;

  Map<String, double> _calculateDailyTotals() {
    double totalCarbs = 0;
    double totalInsulin = 0;
    for (var item in globalDiary) {
      totalCarbs += (item['carbs'] as num).toDouble();
      totalInsulin += (item['insulin'] as num).toDouble();
    }
    return {'carbs': totalCarbs, 'insulin': totalInsulin};
  }

  // --- LÓGICA DE DIGITALIZAR CÓDIGO NO DIÁRIO ---
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
            double carbs = double.tryParse((product['nutriments']?['carbohydrates_100g'] ?? 0).toString()) ?? 0.0;
            double insulin = carbs / globalIcr;
            
            setState(() {
              globalDiary.insert(0, {
                'title': product['product_name'] ?? 'Unknown Product',
                'carbs': carbs,
                'insulin': insulin,
                'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                'type': 'meal',
                'imagePath': null,
                'tags': []
              });
            });
            saveData();
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Meal Logged!'), backgroundColor: Color(0xFF2DD4BF)));
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

  @override
  Widget build(BuildContext context) {
    final totals = _calculateDailyTotals();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildTabSelector(),
            const SizedBox(height: 24),
            
            // --- CONDIÇÃO PARA MOSTRAR OS DADOS SÓ NO "LOG MEAL" ---
            if (_selectedTab == 'Log Meal') ...[
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildNutritionSummaryCard(totals['carbs'] ?? 0),
              const SizedBox(height: 24),
              const Text('Today', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
            ] else ...[
              // Se for "History", mostra só este título e a lista a seguir
              const Text('All History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
            ],

            _buildDiaryList(),
            const SizedBox(height: 100), 
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Nutrition', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Fuel your goals', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: const Icon(Icons.alarm, color: Colors.white54, size: 20),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTabButton('Log Meal'),
          _buildTabButton('History'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title) {
    final isSelected = _selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = title);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? neonGradient : null,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected
                ? [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildNutritionSummaryCard(double dynamicCarbs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 45,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(color: const Color(0xFFE81CFF), value: 30, title: '', radius: 10), 
                      PieChartSectionData(color: const Color(0xFF3B82F6), value: 50, title: '', radius: 10), 
                      PieChartSectionData(color: const Color(0xFF2DD4BF), value: 20, title: '', radius: 10), 
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('428', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('Calories', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildMacroRow(const Color(0xFFE81CFF), 'Protein', '28g'),
                const SizedBox(height: 12),
                _buildMacroRow(const Color(0xFF3B82F6), 'Carbs', '${dynamicCarbs > 0 ? dynamicCarbs.toStringAsFixed(0) : '149'}g'),
                const SizedBox(height: 12),
                _buildMacroRow(const Color(0xFF2DD4BF), 'Fats', '52g'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMacroRow(Color color, String name, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.stop_circle_outlined, color: color, size: 16),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
        Text(amount, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDiaryList() {
    if (globalDiary.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Lottie.network(
                'https://lottie.host/233076a0-5cb0-4f51-b06f-f6bb2d174780/kC6H40z2H8.json',
                width: 150, height: 150,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.restaurant, size: 64, color: Colors.white.withOpacity(0.3)),
              ),
              const SizedBox(height: 16),
              const Text('No meals logged yet.', style: TextStyle(color: Colors.white54, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: globalDiary.length,
        separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.05), height: 1, indent: 70),
        itemBuilder: (context, index) {
          final item = globalDiary[index];
          final String? imgPath = item['imagePath'];
          final String heroTag = 'hero_icon_$index';

          return InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DiaryDetailScreen(itemIndex: index, heroTag: heroTag))).then((_) => setState(() {})),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Hero(
                    tag: heroTag,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      backgroundImage: imgPath != null ? FileImage(File(imgPath)) : null,
                      child: imgPath == null ? const Icon(Icons.restaurant, color: Colors.white54) : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'], style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('${item['time']} - ${item['carbs']}g carbs', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// ECRÃ DE EDIÇÃO E DETALHE DO DIÁRIO INTACTO
// ==========================================
class DiaryDetailScreen extends StatefulWidget {
  final int itemIndex; 
  final String heroTag;
  const DiaryDetailScreen({super.key, required this.itemIndex, required this.heroTag});
  
  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  late TextEditingController tCtrl, cCtrl, iCtrl, hCtrl; 
  
  final List<String> _availableTags = ['🏋️ Pós-Treino', '🤒 Doente', '😤 Stress', '🏃 Ativo'];
  late List<String> _selectedTags;

  @override
  void initState() { 
    super.initState(); 
    final item = globalDiary[widget.itemIndex]; 
    tCtrl = TextEditingController(text: item['title']); 
    cCtrl = TextEditingController(text: item['carbs'].toString()); 
    iCtrl = TextEditingController(text: item['insulin'].toString()); 
    hCtrl = TextEditingController(text: item['time']); 
    _selectedTags = item['tags'] != null ? List<String>.from(item['tags']) : [];
  }
  
  @override
  void dispose() { tCtrl.dispose(); cCtrl.dispose(); iCtrl.dispose(); hCtrl.dispose(); super.dispose(); }
  
  void _deleteRecord() { 
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141923), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white.withOpacity(0.05))),
        title: const Text('🗑️ Delete Log?', style: TextStyle(color: Colors.white)), 
        content: const Text('This action cannot be undone.', style: TextStyle(color: Colors.white54)), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))), 
          ElevatedButton(onPressed: () { globalDiary.removeAt(widget.itemIndex); saveData(); Navigator.pop(ctx); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Deleted', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent)); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, elevation: 0), child: const Text('Delete'))
        ]
      )
    ); 
  }

  InputDecoration _customInputDeco(String label, String suffix) {
    return InputDecoration(
      labelText: label, labelStyle: const TextStyle(color: Colors.white54, fontSize: 14),
      suffixText: suffix, suffixStyle: const TextStyle(color: Colors.white54),
      filled: true, fillColor: const Color(0xFF090C10),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = globalDiary[widget.itemIndex]; 
    final String? img = item['imagePath'];
    
    return Scaffold(
      backgroundColor: const Color(0xFF090C10),
      appBar: AppBar(title: const Text('📝 Edit Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)), backgroundColor: const Color(0xFF141923), elevation: 0, shape: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)), iconTheme: const IconThemeData(color: Colors.white), actions: [IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: _deleteRecord)]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: widget.heroTag,
              child: Material(
                type: MaterialType.transparency,
                child: img != null 
                  ? SizedBox(width: double.infinity, height: 250, child: Image.file(File(img), fit: BoxFit.cover)) 
                  : Container(width: double.infinity, height: 150, color: const Color(0xFF141923), child: Icon(item['type'] == 'meal' ? Icons.restaurant : Icons.water_drop, size: 40, color: Colors.white.withOpacity(0.2))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, 
                children: [
                  TextField(controller: hCtrl, style: const TextStyle(color: Colors.white), decoration: _customInputDeco('🕐 Time', '')), const SizedBox(height: 16), 
                  TextField(controller: tCtrl, style: const TextStyle(color: Colors.white), decoration: _customInputDeco('📝 Description', '')), const SizedBox(height: 16), 
                  TextField(controller: cCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: _customInputDeco('🍞 Carbs', 'g')), const SizedBox(height: 16), 
                  TextField(controller: iCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: _customInputDeco('💉 Insulin', 'U')), const SizedBox(height: 24), 
                  
                  const Text('Tags', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag, style: TextStyle(color: isSelected ? Colors.black : Colors.white54, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        selected: isSelected,
                        selectedColor: Colors.white,
                        backgroundColor: const Color(0xFF090C10),
                        checkmarkColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.white : Colors.white.withOpacity(0.05))),
                        onSelected: (bool selected) {
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
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: () { 
                      globalDiary[widget.itemIndex]['time'] = hCtrl.text; 
                      globalDiary[widget.itemIndex]['title'] = tCtrl.text; 
                      globalDiary[widget.itemIndex]['carbs'] = double.tryParse(cCtrl.text) ?? 0.0; 
                      globalDiary[widget.itemIndex]['insulin'] = double.tryParse(iCtrl.text) ?? 0.0; 
                      globalDiary[widget.itemIndex]['tags'] = List<String>.from(_selectedTags);
                      saveData(); 
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Updated!', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white)); 
                      Navigator.of(context).pop(); 
                    }, 
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text('🔄 Update Changes', style: TextStyle(fontWeight: FontWeight.w600))
                  )
                ]
              )
            )
          ],
        ),
      ),
    );
  }
}