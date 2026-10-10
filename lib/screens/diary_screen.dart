import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // <--- IMPORT LOTTIE ADICIONADO
import 'dart:io';
import '../constants.dart';
import '../app_data.dart';

class DiaryTab extends StatefulWidget {
  const DiaryTab({super.key});

  @override
  State<DiaryTab> createState() => _DiaryTabState();
}

class _DiaryTabState extends State<DiaryTab> {
  
  Map<String, double> _calculateDailyTotals() {
    double totalCarbs = 0;
    double totalInsulin = 0;
    for (var item in globalDiary) {
      totalCarbs += (item['carbs'] as num).toDouble();
      totalInsulin += (item['insulin'] as num).toDouble();
    }
    return {'carbs': totalCarbs, 'insulin': totalInsulin};
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateDailyTotals();

    return Scaffold(
      backgroundColor: bgDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: bgDark,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text('📖 Event Log', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              background: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [cardDark, bgDark],
                  )
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text('Today\'s Summary', style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Carbs', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('${totals['carbs']?.toStringAsFixed(1)}g', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 40, color: borderDark),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Insulin', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('${totals['insulin']?.toStringAsFixed(1)}U', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // --- ESTADO VAZIO ANIMADO COM LOTTIE ---
          if (globalDiary.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.network(
                      'https://lottie.host/233076a0-5cb0-4f51-b06f-f6bb2d174780/kC6H40z2H8.json', // URL público de um Empty State
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback caso estejas sem net ou o URL falhe
                        return Icon(Icons.menu_book_rounded, size: 64, color: textMuted.withOpacity(0.3));
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('📭 Your diary is empty.', style: TextStyle(color: textMuted, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('Start logging your meals to see them here.', style: TextStyle(color: textMuted.withOpacity(0.5), fontSize: 12)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == globalDiary.length) return const SizedBox(height: 80); 
                    
                    final item = globalDiary[index]; 
                    final isMeal = item['type'] == 'meal';
                    final List<dynamic>? tags = item['tags']; 
                    
                    final String heroTag = 'hero_icon_$index';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0), 
                      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderDark)), 
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.horizontal,
                          
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            color: accentBlue,
                            child: const Icon(Icons.copy, color: Colors.white),
                          ),
                          
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.redAccent,
                            child: const Icon(Icons.delete_outline, color: Colors.white),
                          ),
                          
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              setState(() {
                                final duplicatedItem = Map<String, dynamic>.from(globalDiary[index]);
                                duplicatedItem['time'] = '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
                                globalDiary.insert(0, duplicatedItem);
                                saveData();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📋 Log Duplicated!'), backgroundColor: accentBlue));
                              return false; 
                            }
                            return true; 
                          },
                          
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              setState(() {
                                globalDiary.removeAt(index);
                                saveData();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Log Deleted'), backgroundColor: Colors.redAccent));
                            }
                          },
                          
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Hero(
                              tag: heroTag,
                              child: Material(
                                type: MaterialType.transparency,
                                child: Container(
                                  padding: const EdgeInsets.all(8), 
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)), 
                                  child: Icon(isMeal ? Icons.restaurant : Icons.water_drop, color: Colors.white, size: 20)
                                ),
                              ),
                            ), 
                            title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: textMain)), 
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('${item['carbs']}g Carbs • ${item['insulin']}U Insulin', style: TextStyle(fontSize: 13, color: textMuted)),
                                if (tags != null && tags.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6, runSpacing: 6,
                                    children: tags.map<Widget>((tag) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(4), border: Border.all(color: borderDark)),
                                      child: Text(tag.toString(), style: TextStyle(color: Colors.grey.shade300, fontSize: 10, fontWeight: FontWeight.w500)),
                                    )).toList(),
                                  )
                                ]
                              ],
                            ), 
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(item['time'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: textMain, fontFamily: 'monospace')),
                              ],
                            ),
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DiaryDetailScreen(itemIndex: index, heroTag: heroTag))).then((_) => setState(() {}))
                          ),
                        ),
                      )
                    );
                  },
                  childCount: globalDiary.length + 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
        backgroundColor: cardDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderDark)),
        title: const Text('🗑️ Delete Log?', style: TextStyle(color: textMain)), 
        content: Text('This action cannot be undone.', style: TextStyle(color: textMuted)), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: textMuted))), 
          ElevatedButton(onPressed: () { globalDiary.removeAt(widget.itemIndex); saveData(); Navigator.pop(ctx); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Deleted', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent)); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, elevation: 0), child: const Text('Delete'))
        ]
      )
    ); 
  }

  InputDecoration _customInputDeco(String label, String suffix) {
    return InputDecoration(
      labelText: label, labelStyle: TextStyle(color: textMuted, fontSize: 14),
      suffixText: suffix, suffixStyle: TextStyle(color: textMuted),
      filled: true, fillColor: bgDark,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderDark)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = globalDiary[widget.itemIndex]; 
    final String? img = item['imagePath'];
    
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(title: const Text('📝 Edit Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textMain)), backgroundColor: cardDark, elevation: 0, shape: Border(bottom: BorderSide(color: borderDark, width: 1)), iconTheme: const IconThemeData(color: textMain), actions: [IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: _deleteRecord)]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: widget.heroTag,
              child: Material(
                type: MaterialType.transparency,
                child: img != null 
                  ? SizedBox(width: double.infinity, height: 250, child: Image.file(File(img), fit: BoxFit.cover)) 
                  : Container(width: double.infinity, height: 150, color: cardDark, child: Icon(item['type'] == 'meal' ? Icons.restaurant : Icons.water_drop, size: 40, color: textMuted.withOpacity(0.2))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, 
                children: [
                  TextField(controller: hCtrl, style: const TextStyle(color: textMain), decoration: _customInputDeco('🕐 Time', '')), const SizedBox(height: 16), 
                  TextField(controller: tCtrl, style: const TextStyle(color: textMain), decoration: _customInputDeco('📝 Description', '')), const SizedBox(height: 16), 
                  TextField(controller: cCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: textMain), decoration: _customInputDeco('🍞 Carbs', 'g')), const SizedBox(height: 16), 
                  TextField(controller: iCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: textMain), decoration: _customInputDeco('💉 Insulin', 'U')), const SizedBox(height: 24), 
                  
                  const Text('Tags', style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag, style: TextStyle(color: isSelected ? Colors.black : textMuted, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        selected: isSelected,
                        selectedColor: Colors.white,
                        backgroundColor: bgDark,
                        checkmarkColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.white : borderDark)),
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