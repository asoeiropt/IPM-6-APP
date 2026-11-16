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
    
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);
    
    try {
      String? barcodeScanRes = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              title: Text('Digitalizar Código', style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, fontSize: 16)),
              backgroundColor: cardColor,
              iconTheme: IconThemeData(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white),
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
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('✅ Meal Logged!'), backgroundColor: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF2DD4BF)));
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
    
    // --- LÓGICA DE ALTO CONTRASTE ---
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);

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
            
            if (_selectedTab == 'Log Meal') ...[
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildNutritionSummaryCard(totals['carbs'] ?? 0),
              const SizedBox(height: 24),
              Text('Today', style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
            ] else ...[
              Text('All History', style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final mainTextColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : const Color(0xFF64748B);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);
    final iconColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white54;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nutrition', style: TextStyle(color: mainTextColor, fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Fuel your goals', style: TextStyle(color: subTextColor, fontSize: 14)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
          ),
          child: Icon(Icons.alarm, color: iconColor, size: 20),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.transparent;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: isHighContrast ? 2 : 0),
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
    final neonGradient = const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]);
    
    BoxDecoration? decoration;
    if (isSelected) {
      decoration = isHighContrast 
          ? BoxDecoration(color: const Color(0xFFFFD600), borderRadius: BorderRadius.circular(24))
          : BoxDecoration(
              gradient: neonGradient, 
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
            );
    }

    final textColor = isSelected 
        ? (isHighContrast ? Colors.black : Colors.white) 
        : (isHighContrast ? Colors.white : Colors.white54);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = title);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: decoration,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
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
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
      ),
      child: TextField(
        style: TextStyle(color: isHighContrast ? Colors.white : Colors.white),
        decoration: InputDecoration(
          hintText: 'Search food or scan barcode',
          hintStyle: TextStyle(color: isHighContrast ? Colors.white54 : Colors.white38),
          prefixIcon: Icon(Icons.search, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white54),
          suffixIcon: IconButton(
            icon: _isLoadingBarcode 
                ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white54))
                : Icon(Icons.qr_code_scanner, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white54),
            onPressed: _isLoadingBarcode ? null : _scanBarcode,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildNutritionSummaryCard(double dynamicCarbs) {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
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
                      PieChartSectionData(color: isHighContrast ? Colors.white : const Color(0xFFE81CFF), value: 30, title: '', radius: 10), 
                      PieChartSectionData(color: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6), value: 50, title: '', radius: 10), 
                      PieChartSectionData(color: isHighContrast ? Colors.grey : const Color(0xFF2DD4BF), value: 20, title: '', radius: 10), 
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('428', style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('Calories', style: TextStyle(color: isHighContrast ? Colors.white : Colors.white54, fontSize: 11)),
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
                _buildMacroRow(isHighContrast ? Colors.white : const Color(0xFFE81CFF), 'Protein', '28g'),
                const SizedBox(height: 12),
                _buildMacroRow(isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6), 'Carbs', '${dynamicCarbs > 0 ? dynamicCarbs.toStringAsFixed(0) : '149'}g'),
                const SizedBox(height: 12),
                _buildMacroRow(isHighContrast ? Colors.grey : const Color(0xFF2DD4BF), 'Fats', '52g'),
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
            Text(name, style: TextStyle(color: isHighContrast ? Colors.white : Colors.white70, fontSize: 14)),
          ],
        ),
        Text(amount, style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDiaryList() {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.transparent;

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
              Text('No meals logged yet.', style: TextStyle(color: isHighContrast ? Colors.white : Colors.white54, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: isHighContrast ? 2 : 0),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: globalDiary.length,
        separatorBuilder: (context, index) => Divider(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05), height: 1, indent: 70, thickness: isHighContrast ? 2 : 1),
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
                      backgroundColor: isHighContrast ? Colors.transparent : Colors.white.withOpacity(0.05),
                      backgroundImage: imgPath != null ? FileImage(File(imgPath)) : null,
                      child: imgPath == null ? Icon(Icons.restaurant, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white54) : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'], style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('${item['time']} \n${item['carbs']}g carbs', style: TextStyle(color: isHighContrast ? Colors.white : Colors.white54, fontSize: 13)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white38, size: 20),
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
// ECRÃ DE EDIÇÃO E DETALHE DO DIÁRIO
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
        backgroundColor: isHighContrast ? Colors.black : const Color(0xFF141923), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05), width: isHighContrast ? 2 : 1)),
        title: Text('🗑️ Delete Log?', style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white)), 
        content: Text('This action cannot be undone.', style: TextStyle(color: isHighContrast ? Colors.white : Colors.white54)), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: isHighContrast ? Colors.white : Colors.white54))), 
          ElevatedButton(
            onPressed: () { 
              globalDiary.removeAt(widget.itemIndex); 
              saveData(); 
              Navigator.pop(ctx); 
              Navigator.pop(context); 
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('🗑️ Deleted', style: TextStyle(color: Colors.white)), backgroundColor: isHighContrast ? Colors.black : Colors.redAccent)); 
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent, foregroundColor: isHighContrast ? Colors.black : Colors.white, elevation: 0), 
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold))
          )
        ]
      )
    ); 
  }

  InputDecoration _customInputDeco(String label, String suffix) {
    return InputDecoration(
      labelText: label, labelStyle: TextStyle(color: isHighContrast ? Colors.white : Colors.white54, fontSize: 14),
      suffixText: suffix, suffixStyle: TextStyle(color: isHighContrast ? Colors.white : Colors.white54),
      filled: true, fillColor: isHighContrast ? Colors.black : const Color(0xFF090C10),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05), width: isHighContrast ? 2 : 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = globalDiary[widget.itemIndex]; 
    final String? img = item['imagePath'];
    
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('📝 Edit Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white)), 
        backgroundColor: cardColor, 
        elevation: 0, 
        shape: Border(bottom: BorderSide(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05), width: isHighContrast ? 2 : 1)), 
        iconTheme: IconThemeData(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white), 
        actions: [IconButton(icon: Icon(Icons.delete_outline, color: isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent), onPressed: _deleteRecord)]
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: widget.heroTag,
              child: Material(
                type: MaterialType.transparency,
                child: img != null 
                  ? SizedBox(width: double.infinity, height: 250, child: Image.file(File(img), fit: BoxFit.cover)) 
                  : Container(
                      width: double.infinity, 
                      height: 150, 
                      decoration: BoxDecoration(
                        color: cardColor,
                        border: Border(bottom: BorderSide(color: isHighContrast ? const Color(0xFFFFD600) : Colors.transparent, width: 2)),
                      ),
                      child: Icon(item['type'] == 'meal' ? Icons.restaurant : Icons.water_drop, size: 40, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.2))
                    ),
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
                  
                  Text('Tags', style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag, style: TextStyle(color: isSelected ? Colors.black : (isHighContrast ? Colors.white : Colors.white54), fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        selected: isSelected,
                        selectedColor: isHighContrast ? const Color(0xFFFFD600) : Colors.white,
                        backgroundColor: bgColor,
                        checkmarkColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), 
                          side: BorderSide(color: isSelected ? Colors.transparent : (isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05)), width: isHighContrast ? 2 : 1)
                        ),
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
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('✅ Updated!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: isHighContrast ? const Color(0xFFFFD600) : Colors.white)); 
                      Navigator.of(context).pop(); 
                    }, 
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16), 
                      backgroundColor: isHighContrast ? const Color(0xFFFFD600) : Colors.white, 
                      foregroundColor: Colors.black, 
                      elevation: 0, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ),
                    child: const Text('🔄 Update Changes', style: TextStyle(fontWeight: FontWeight.bold))
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