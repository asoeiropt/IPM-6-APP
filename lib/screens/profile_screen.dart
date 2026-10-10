import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:smart_glyco_ai/constants.dart';
import 'package:smart_glyco_ai/app_data.dart';
import 'package:smart_glyco_ai/startup_screens.dart' hide cardDark, borderDark, textMain, textMuted, bgDark, accentBlue;

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Future<void> _editValue(String title, double currentValue, String unit, Function(double) onSave) async {
    TextEditingController controller = TextEditingController(text: currentValue.toString());
    return showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        backgroundColor: cardDark, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderDark)), 
        title: Text('✏ Edit $title', style: const TextStyle(color: textMain)), 
        content: TextField(
          controller: controller, 
          keyboardType: TextInputType.number, 
          style: const TextStyle(color: textMain), 
          decoration: InputDecoration(
            suffixText: unit, 
            suffixStyle: TextStyle(color: textMuted), 
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderDark)), 
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))
          )
        ), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: textMuted))), 
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0), 
            onPressed: () { 
              if (controller.text.isNotEmpty) { 
                onSave(double.parse(controller.text)); 
                saveData(); 
                setState(() {}); 
              } 
              Navigator.pop(context); 
            }, 
            child: const Text('Save')
          )
        ]
      )
    );
  }
  
  Future<void> _exportReport() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // --- CABEÇALHO CLÍNICO PROFISSIONAL ---
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('SmartGlycoAI', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: const PdfColor(0, 0.44, 0.95))),
                      pw.Text('Clinical Data Report', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                    ]
                  ),
                  pw.Text('Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                ]
              )
            ),
            pw.SizedBox(height: 20),
            
            // --- CAIXA DE RESUMO DO PACIENTE ---
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                border: pw.Border.all(color: PdfColors.grey300)
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Patient: Afonso Lopes Soeiro', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Condition: Type 1 Diabetes', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                      pw.SizedBox(height: 8),
                      pw.Text('Insulin-to-Carb Ratio (ICR): ${globalIcr.toStringAsFixed(1)} g/U', style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('Insulin Sensitivity (ISF): ${globalIsf.toStringAsFixed(1)} mg/dL/U', style: const pw.TextStyle(fontSize: 12)),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Time in Range', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                      pw.Text('85% Optimal', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green600)),
                      pw.SizedBox(height: 8),
                      pw.Text('Target Glucose', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                      pw.Text('${globalTarget.toStringAsFixed(0)} mg/dL', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ]
                  )
                ]
              )
            ),
            pw.SizedBox(height: 30),

            // --- CALENDÁRIO HEATMAP NO PDF ---
            pw.Text('30-Day Control Heatmap', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: const PdfColor(0, 0.44, 0.95))),
            pw.SizedBox(height: 10),
            pw.Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(30, (index) {
                // Mesma lógica visual do ecrã Home
                PdfColor boxColor = PdfColors.green400; 
                if (index == 5 || index == 12 || index == 22 || index == 29) boxColor = PdfColors.orange400;
                if (index == 8 || index == 18 || index == 27) boxColor = PdfColors.red400;

                return pw.Container(
                  width: 25,
                  height: 25,
                  decoration: pw.BoxDecoration(
                    color: boxColor,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '${index + 1}', 
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)
                  ),
                );
              }),
            ),
            pw.SizedBox(height: 12),
            // Legenda do Heatmap
            pw.Row(
              children: [
                pw.Container(width: 10, height: 10, color: PdfColors.green400),
                pw.SizedBox(width: 4),
                pw.Text('In Target', style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(width: 16),
                pw.Container(width: 10, height: 10, color: PdfColors.orange400),
                pw.SizedBox(width: 4),
                pw.Text('Hyperglycemia', style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(width: 16),
                pw.Container(width: 10, height: 10, color: PdfColors.red400),
                pw.SizedBox(width: 4),
                pw.Text('Hypoglycemia', style: const pw.TextStyle(fontSize: 10)),
              ]
            ),
            pw.SizedBox(height: 30),
            
            // --- TABELA DE EVENTOS ---
            pw.Text('Detailed Event Log', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: const PdfColor(0, 0.44, 0.95))),
            pw.SizedBox(height: 10),
            
            if (globalDiary.isEmpty)
              pw.Text('No entries found for this period.', style: const pw.TextStyle(color: PdfColors.grey))
            else
              pw.TableHelper.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
                headerDecoration: const pw.BoxDecoration(color: PdfColor(0, 0.44, 0.95)),
                rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
                cellPadding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                },
                data: <List<String>>[
                  ['Time', 'Type', 'Description & Tags', 'Carbs (g)', 'Insulin (U)'],
                  ...globalDiary.map((item) {
                    final tags = item['tags'] as List<dynamic>?;
                    final tagsStr = tags != null && tags.isNotEmpty ? '\nTags: ${tags.join(', ')}' : '';
                    
                    return [
                      item['time'].toString(),
                      item['type'].toString().toUpperCase(),
                      '${item['title']}$tagsStr',
                      item['carbs'].toString(),
                      item['insulin'].toString()
                    ];
                  })
                ],
              ),
              
            pw.SizedBox(height: 30),
            pw.Center(child: pw.Text('-- End of Clinical Report --', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500))),
            pw.SizedBox(height: 10),
            pw.Center(child: pw.Text('Generated securely by SmartGlycoAI.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey))),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/SmartGlycoAI_ClinicalReport.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Clinical Report from SmartGlycoAI');
  }

  Widget _buildSectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 12, top: 24), child: Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: textMuted)));

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Center(
          child: Column(
            children: [
              Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: borderDark)), child: const Icon(Icons.person, size: 40, color: Colors.white)), 
              const SizedBox(height: 16), 
              const Text('👋 Afonso', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textMain)), 
              Text('Type 1 Diabetes', style: TextStyle(fontSize: 14, color: textMuted)), 
              const SizedBox(height: 8), 
              TextButton(
                onPressed: () { 
                  isLoggedIn = false; 
                  saveData(); 
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
                }, 
                child: const Text('🚪 Log Out', style: TextStyle(color: Colors.redAccent, fontSize: 13))
              )
            ]
          )
        ),
        
        _buildSectionHeader('🔒 Security'),
        Container(decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderDark)), child: SwitchListTile(activeColor: Colors.white, inactiveTrackColor: bgDark, title: const Text('Biometric Lock', style: TextStyle(color: textMain, fontSize: 14)), subtitle: Text('Require FaceID/TouchID', style: TextStyle(color: textMuted, fontSize: 12)), value: useBiometricsGlobal, onChanged: (bool value) async { bool supported = await biometricAuth.canCheckBiometrics; if (supported || !value) { setState(() => useBiometricsGlobal = value); saveData(); } else { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Device unsupported.', style: TextStyle(color: Colors.black)), backgroundColor: Colors.redAccent)); } })),
        
        _buildSectionHeader('🎛️ Parameters'),
        Container(decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderDark)), child: Column(children: [
          ListTile(title: const Text('Insulin-to-Carb (ICR)', style: TextStyle(color: textMain, fontSize: 14)), subtitle: Text('1U : $globalIcr g', style: TextStyle(color: textMuted, fontSize: 12)), trailing: Icon(Icons.chevron_right, color: borderDark, size: 16), onTap: () => _editValue('ICR', globalIcr, 'g', (v) => globalIcr = v)), 
          Divider(height: 1, color: borderDark), 
          ListTile(title: const Text('Sensitivity (ISF)', style: TextStyle(color: textMain, fontSize: 14)), subtitle: Text('1U : $globalIsf mg/dL', style: TextStyle(color: textMuted, fontSize: 12)), trailing: Icon(Icons.chevron_right, color: borderDark, size: 16), onTap: () => _editValue('ISF', globalIsf, 'mg/dL', (v) => globalIsf = v)), 
          Divider(height: 1, color: borderDark), 
          ListTile(title: const Text('Target Glucose', style: TextStyle(color: textMain, fontSize: 14)), subtitle: Text('$globalTarget mg/dL', style: TextStyle(color: textMuted, fontSize: 12)), trailing: Icon(Icons.chevron_right, color: borderDark, size: 16), onTap: () => _editValue('Target', globalTarget, 'mg/dL', (v) => globalTarget = v))
        ])),
        
        _buildSectionHeader('📱 Data & Devices'),
        Container(decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderDark)), child: Column(children: [
          ListTile(title: const Text('Export Report (PDF)', style: TextStyle(color: textMain, fontSize: 14)), subtitle: Text('Generate Clinical PDF', style: TextStyle(color: textMuted, fontSize: 12)), trailing: const Icon(Icons.picture_as_pdf, color: accentBlue, size: 18), onTap: _exportReport),
          Divider(height: 1, color: borderDark),
          ListTile(title: const Text('CGM Sensor', style: TextStyle(color: textMain, fontSize: 14)), subtitle: Text('Bluetooth settings', style: TextStyle(color: textMuted, fontSize: 12)), trailing: Icon(Icons.bluetooth, color: textMuted, size: 16), onTap: () => AppSettings.openAppSettings(type: AppSettingsType.bluetooth))
        ])),
        const SizedBox(height: 80),
      ],
    );
  }
}