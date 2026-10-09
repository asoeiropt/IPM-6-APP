import 'package:flutter/material.dart';
import 'dart:io';
import '../constants.dart';
import '../app_data.dart';

class DiaryTab extends StatelessWidget {
  const DiaryTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: globalDiary.isEmpty 
        ? Center(child: Text('📭 Your diary is empty.', style: TextStyle(color: textMuted, fontSize: 14)))
        : ListView.builder(
            padding: const EdgeInsets.all(16.0), itemCount: globalDiary.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) return const Padding(padding: EdgeInsets.only(bottom: 16.0), child: Text('📖 Event Log', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textMain)));
              if (index == globalDiary.length + 1) return const SizedBox(height: 80); 
              final itemIndex = index - 1; final item = globalDiary[itemIndex]; final isMeal = item['type'] == 'meal';
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8.0), 
                decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderDark)), 
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: Icon(isMeal ? Icons.restaurant : Icons.water_drop, color: Colors.white, size: 20)), 
                  title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: textMain)), 
                  subtitle: Text('${item['carbs']}g Carbs • ${item['insulin']}U Insulin', style: TextStyle(fontSize: 13, color: textMuted)), 
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text(item['time'], style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: textMain, fontFamily: 'monospace')), const SizedBox(width: 8), Icon(Icons.chevron_right, color: borderDark, size: 16)]), 
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DiaryDetailScreen(itemIndex: itemIndex)))
                )
              );
            },
          ),
    );
  }
}

class DiaryDetailScreen extends StatefulWidget {
  final int itemIndex; const DiaryDetailScreen({super.key, required this.itemIndex});
  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  late TextEditingController tCtrl, cCtrl, iCtrl, hCtrl; 
  @override
  void initState() { super.initState(); final item = globalDiary[widget.itemIndex]; tCtrl = TextEditingController(text: item['title']); cCtrl = TextEditingController(text: item['carbs'].toString()); iCtrl = TextEditingController(text: item['insulin'].toString()); hCtrl = TextEditingController(text: item['time']); }
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
    final item = globalDiary[widget.itemIndex]; final String? img = item['imagePath'];
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(title: const Text('📝 Edit Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textMain)), backgroundColor: cardDark, elevation: 0, shape: Border(bottom: BorderSide(color: borderDark, width: 1)), iconTheme: const IconThemeData(color: textMain), actions: [IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: _deleteRecord)]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (img != null) SizedBox(width: double.infinity, height: 250, child: Image.file(File(img), fit: BoxFit.cover)) else Container(width: double.infinity, height: 150, color: cardDark, child: Icon(item['type'] == 'meal' ? Icons.restaurant : Icons.water_drop, size: 40, color: textMuted.withOpacity(0.2))),
            Padding(
              padding: const EdgeInsets.all(20.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, 
                children: [
                  TextField(controller: hCtrl, style: const TextStyle(color: textMain), decoration: _customInputDeco('🕐 Time', '')), const SizedBox(height: 16), 
                  TextField(controller: tCtrl, style: const TextStyle(color: textMain), decoration: _customInputDeco('📝 Description', '')), const SizedBox(height: 16), 
                  TextField(controller: cCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: textMain), decoration: _customInputDeco('🍞 Carbs', 'g')), const SizedBox(height: 16), 
                  TextField(controller: iCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: textMain), decoration: _customInputDeco('💉 Insulin', 'U')), const SizedBox(height: 32), 
                  
                  ElevatedButton(
                    onPressed: () { globalDiary[widget.itemIndex]['time'] = hCtrl.text; globalDiary[widget.itemIndex]['title'] = tCtrl.text; globalDiary[widget.itemIndex]['carbs'] = double.tryParse(cCtrl.text) ?? 0.0; globalDiary[widget.itemIndex]['insulin'] = double.tryParse(iCtrl.text) ?? 0.0; saveData(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Updated!', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white)); Navigator.of(context).pop(); }, 
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