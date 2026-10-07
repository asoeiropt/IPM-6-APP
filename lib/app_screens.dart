import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';// PACOTE MODERNO AQUI!
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'app_data.dart';
import 'startup_screens.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});
  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}
class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0; 
  Widget get _currentScreen => [const HomeTab(), const DiaryTab(), const ProfileTab()][_currentIndex];

  @override
  void initState() {
    super.initState();
    if (!askedForNotifications) { WidgetsBinding.instance.addPostFrameCallback((_) => _askForNotifications()); }
  }

  Future<void> _askForNotifications() async {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Row(children: const [Icon(Icons.notifications_active, color: Colors.teal, size: 28), SizedBox(width: 8), Text('Ativar Alertas?')]), content: const Text('Para a SmartGlycoAI o avisar de descidas rápidas e evitar hipoglicemias, precisamos de lhe enviar notificações.\n\nDeseja ativar os alertas preditivos?', style: TextStyle(fontSize: 16)), actions: [TextButton(onPressed: () { askedForNotifications = true; saveData(); Navigator.pop(ctx); }, child: const Text('Agora Não', style: TextStyle(color: Colors.grey))), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white), onPressed: () async { askedForNotifications = true; saveData(); Navigator.pop(ctx); final androidPlatform = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>(); if (androidPlatform != null) { await androidPlatform.requestNotificationsPermission(); } }, child: const Text('Sim, Ativar'))]));
  }

  Future<void> _showPredictiveAlert() async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails('ai_alerts', 'Alertas de IA', importance: Importance.max, priority: Priority.high, icon: '@mipmap/ic_launcher', color: Colors.red, enableVibration: true);
      const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);
      dynamic magicPlugin = notificationsPlugin;
      await magicPlugin.show(id: 0, title: '⚠️ Alerta Preditivo', body: 'Previsão: 65 mg/dL em 20 min. Sugerido: 15g hidratos.', notificationDetails: notificationDetails);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ERRO NOTIFICAÇÃO: $e'), backgroundColor: Colors.red));
    }
    if (!mounted) return;
    showDialog(context: context, builder: (ctx) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), title: Row(children: const [Icon(Icons.warning_amber_rounded, color: Colors.red, size: 36), SizedBox(width: 8), Text('Alerta Preditivo', style: TextStyle(color: Colors.red))]), content: const Text('O algoritmo detetou uma descida rápida.\n\nPrevisão: 65 mg/dL em 20 min.\n\nSugestão: Ingerir 15g de hidratos rápidos.', style: TextStyle(fontSize: 16)), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ignorar', style: TextStyle(color: Colors.grey))), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), onPressed: () { globalDiary.insert(0, {'title': 'Correção Preventiva', 'carbs': 15.0, 'insulin': 0.0, 'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}', 'type': 'correction', 'imagePath': null}); saveData(); Navigator.pop(ctx); setState(() {}); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correção registada!'), backgroundColor: Colors.green)); }, child: const Text('Registar Correção'))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartGlycoAI', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, backgroundColor: Theme.of(context).colorScheme.inversePrimary, actions: [IconButton(icon: const Icon(Icons.add_box), onPressed: () async { await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManualEntryScreen())); setState(() {}); }), IconButton(icon: const Icon(Icons.notifications_active, color: Colors.redAccent), onPressed: _showPredictiveAlert)]),
      body: _currentScreen, 
      bottomNavigationBar: NavigationBar(selectedIndex: _currentIndex, onDestinationSelected: (int index) => setState(() => _currentIndex = index), destinations: const [NavigationDestination(icon: Icon(Icons.home), label: 'Início'), NavigationDestination(icon: Icon(Icons.book), label: 'Diário'), NavigationDestination(icon: Icon(Icons.person), label: 'Perfil')]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CameraScreen())), icon: const Icon(Icons.camera_alt), label: const Text('Analisar Refeição')), floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  double _calculateIOB() {
    double totalIob = 0.0; DateTime now = DateTime.now();
    for (var item in globalDiary) {
      if (item['insulin'] != null && item['insulin'] > 0) {
        List<String> timeParts = item['time'].split(':');
        if (timeParts.length == 2) {
          DateTime recordTime = DateTime(now.year, now.month, now.day, int.parse(timeParts[0]), int.parse(timeParts[1]));
          Duration diff = now.difference(recordTime);
          if (diff.inMinutes >= 0 && diff.inMinutes < 240) { double remaining = 1.0 - (diff.inMinutes / 240.0); totalIob += (item['insulin'] * remaining); }
        }
      }
    }
    return totalIob;
  }
  @override
  Widget build(BuildContext context) {
    double currentIob = _calculateIOB(); bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView( 
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [Expanded(flex: 2, child: Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(20.0), child: Column(children: [Text('Glicemia Atual', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)), const SizedBox(height: 8), const Text('115', style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.green)), Text('mg/dL', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)), const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.arrow_forward, color: Colors.green, size: 16), SizedBox(width: 4), Text('Estável', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14))])])))), const SizedBox(width: 12), Expanded(flex: 1, child: Card(elevation: 2, color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.shade50, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 8), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.vaccines, color: Colors.blue), const SizedBox(height: 8), const Text('Insulina Ativa', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.blueGrey)), const SizedBox(height: 4), Text('${currentIob.toStringAsFixed(1)} U', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.blue.shade300 : Colors.blue.shade700))]))))]),
          const SizedBox(height: 24), const Text('Tendência (Últimas 6 horas)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
          Container(height: 200, padding: const EdgeInsets.only(right: 16, left: 8, top: 16, bottom: 8), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)), child: LineChart(LineChartData(minY: 40, maxY: 250, minX: 0, maxX: 6, gridData: FlGridData(show: true, drawVerticalLine: false), titlesData: FlTitlesData(rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) { switch (v.toInt()) { case 0: return const Text('10h'); case 2: return const Text('12h'); case 4: return const Text('14h'); case 6: return const Text('Agora'); } return const Text(''); }))), borderData: FlBorderData(show: false), lineBarsData: [LineChartBarData(isCurved: true, color: Colors.teal, barWidth: 4, isStrokeCapRound: true, dotData: FlDotData(show: false), belowBarData: BarAreaData(show: true, color: Colors.teal.withOpacity(0.2)), spots: const [FlSpot(0, 110), FlSpot(1, 140), FlSpot(2, 175), FlSpot(3, 145), FlSpot(4, 95), FlSpot(5, 105), FlSpot(6, 115)])], extraLinesData: ExtraLinesData(horizontalLines: [HorizontalLine(y: 180, color: Colors.orange.withOpacity(0.5), strokeWidth: 2, dashArray: [5, 5]), HorizontalLine(y: 70, color: Colors.red.withOpacity(0.5), strokeWidth: 2, dashArray: [5, 5])])))),
          const SizedBox(height: 24), Container(padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 80), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.3))), child: Row(children: [const Icon(Icons.auto_awesome, color: Colors.blue, size: 32), const SizedBox(width: 16), Expanded(child: Text('A sua glicemia está estável e 85% do tempo no alvo hoje. Bom trabalho!', style: TextStyle(color: isDark ? Colors.blue.shade200 : Colors.blue.shade900, fontSize: 14)))]))
      ]),
    );
  }
}

class DiaryTab extends StatefulWidget {
  const DiaryTab({super.key});
  @override
  State<DiaryTab> createState() => _DiaryTabState();
}
class _DiaryTabState extends State<DiaryTab> {
  @override
  Widget build(BuildContext context) {
    if (globalDiary.isEmpty) return const Center(child: Text('O seu diário está vazio.', style: TextStyle(color: Colors.grey, fontSize: 16)));
    return ListView.builder(
      padding: const EdgeInsets.all(16.0), itemCount: globalDiary.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) return const Padding(padding: EdgeInsets.only(bottom: 16.0), child: Text('Histórico', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)));
        if (index == globalDiary.length + 1) return const SizedBox(height: 80); 
        final itemIndex = index - 1; final item = globalDiary[itemIndex]; final isMeal = item['type'] == 'meal';
        return Card(elevation: 1, margin: const EdgeInsets.only(bottom: 8.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: ListTile(leading: CircleAvatar(backgroundColor: isMeal ? Colors.orange : Colors.redAccent, child: Icon(isMeal ? Icons.restaurant : Icons.water_drop, color: Colors.white)), title: Text(item['title']), subtitle: Text('${item['carbs']}g Hidratos • ${item['insulin']} U Insulina'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text(item['time'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(width: 8), const Icon(Icons.chevron_right, color: Colors.grey)]), onTap: () async { await Navigator.of(context).push(MaterialPageRoute(builder: (_) => DiaryDetailScreen(itemIndex: itemIndex))); setState(() {}); }));
      },
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Future<void> _editValue(String title, double currentValue, String unit, Function(double) onSave) async {
    TextEditingController controller = TextEditingController(text: currentValue.toString());
    return showDialog(context: context, builder: (context) => AlertDialog(title: Text('Editar $title'), content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: InputDecoration(suffixText: unit)), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), ElevatedButton(onPressed: () { if (controller.text.isNotEmpty) { onSave(double.parse(controller.text)); saveData(); setState(() {}); } Navigator.pop(context); }, child: const Text('Guardar'))]));
  }
  void _exportReport() {
    String report = "🏥 RELATÓRIO CLÍNICO - SMARTGLYCO AI\nPaciente: João Silva\n\n📊 PARÂMETROS ATUAIS:\nICR: $globalIcr | ISF: $globalIsf | Alvo: $globalTarget mg/dL\n\n📖 DIÁRIO DE HOJE:\n";
    for (var item in globalDiary) { report += "[${item['time']}] ${item['title']}\n   Hidratos: ${item['carbs']}g | Insulina: ${item['insulin']}U\n\n"; }
    Share.share(report, subject: 'Relatório Diário de Glicemia');
  }
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Center(child: Column(children: [const CircleAvatar(radius: 50, backgroundColor: Colors.teal, child: Icon(Icons.person, size: 50, color: Colors.white)), const SizedBox(height: 16), const Text('João Silva', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const Text('Diabetes Tipo 1', style: TextStyle(fontSize: 16, color: Colors.grey)), TextButton.icon(onPressed: () { isLoggedIn = false; saveData(); Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));}, icon: const Icon(Icons.logout, size: 16, color: Colors.red), label: const Text('Terminar Sessão', style: TextStyle(color: Colors.red)))])),
        const SizedBox(height: 24), const Text('Privacidade', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)), const SizedBox(height: 16),
        Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: SwitchListTile(activeColor: Colors.teal, secondary: const Icon(Icons.fingerprint, color: Colors.teal), title: const Text('Bloqueio Biométrico'), subtitle: const Text('Pedir FaceID/Impressão Digital ao abrir'), value: useBiometricsGlobal, onChanged: (bool value) async { bool supported = await biometricAuth.canCheckBiometrics; if (supported || !value) { setState(() => useBiometricsGlobal = value); saveData(); } else { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Este dispositivo não suporta biometria.'), backgroundColor: Colors.red)); } })),
        const SizedBox(height: 32), const Text('Parâmetros Clínicos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)), const SizedBox(height: 16),
        Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Column(children: [ListTile(leading: const Icon(Icons.restaurant_menu, color: Colors.orange), title: const Text('Rácio Insulina/Hidratos (ICR)'), subtitle: Text('1 Unidade para cada $globalIcr g'), trailing: const Icon(Icons.edit, color: Colors.grey), onTap: () => _editValue('ICR', globalIcr, 'gramas', (v) => globalIcr = v)), const Divider(height: 1), ListTile(leading: const Icon(Icons.trending_down, color: Colors.redAccent), title: const Text('Fator de Sensibilidade (ISF)'), subtitle: Text('1 Unidade desce $globalIsf mg/dL'), trailing: const Icon(Icons.edit, color: Colors.grey), onTap: () => _editValue('ISF', globalIsf, 'mg/dL', (v) => globalIsf = v)), const Divider(height: 1), ListTile(leading: const Icon(Icons.track_changes, color: Colors.green), title: const Text('Glicemia Alvo'), subtitle: Text('$globalTarget mg/dL'), trailing: const Icon(Icons.edit, color: Colors.grey), onTap: () => _editValue('Glicemia Alvo', globalTarget, 'mg/dL', (v) => globalTarget = v))])),
        const SizedBox(height: 32), const Text('Relatórios e Partilha', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)), const SizedBox(height: 16),
        Card(elevation: 2, color: Colors.teal.withOpacity(0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: ListTile(leading: const Icon(Icons.share, color: Colors.teal), title: const Text('Exportar para o Médico', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('Enviar relatório diário por WhatsApp/Email'), trailing: const Icon(Icons.send, color: Colors.teal), onTap: _exportReport)),
        const SizedBox(height: 32), const Text('Dispositivos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)), const SizedBox(height: 16),
        Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: ListTile(leading: const Icon(Icons.bluetooth_connected, color: Colors.blue), title: const Text('Sensor CGM (Bluetooth)'), subtitle: const Text('Toque para abrir definições'), trailing: const Icon(Icons.settings_bluetooth, color: Colors.grey), onTap: () => AppSettings.openAppSettings(type: AppSettingsType.bluetooth))),
        const SizedBox(height: 80),
      ],
    );
  }
}

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

  // Função moderna para o Scanner de Código de Barras
  Future<void> _scanBarcode() async {
    try {
      // Abre a nova janela do Scanner
      String? barcodeScanRes = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
  appBar: AppBar(title: const Text('Digitalizar Código')),
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
            final nome = product['product_name'] ?? 'Produto Desconhecido';
            final nutriments = product['nutriments'] ?? {};
            
            double hidratos = 0.0;
            if (nutriments['carbohydrates_serving'] != null) {
              hidratos = double.tryParse(nutriments['carbohydrates_serving'].toString()) ?? 0.0;
            } else if (nutriments['carbohydrates_100g'] != null) {
              hidratos = double.tryParse(nutriments['carbohydrates_100g'].toString()) ?? 0.0;
            }

            setState(() {
              tCtrl.text = nome;
              cCtrl.text = hidratos.toStringAsFixed(1);
              iCtrl.text = (hidratos / globalIcr).toStringAsFixed(1); 
            });

            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Produto preenchido com sucesso!'), backgroundColor: Colors.green));
          } else {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Produto não encontrado na base de dados.'), backgroundColor: Colors.orange));
          }
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao ler código: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() { _isLoadingBarcode = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registo Manual'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('O que deseja registar?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 16),
            SegmentedButton<String>(segments: const [ButtonSegment(value: 'meal', label: Text('Refeição'), icon: Icon(Icons.restaurant)), ButtonSegment(value: 'correction', label: Text('Correção'), icon: Icon(Icons.water_drop))], selected: {_entryType}, onSelectionChanged: (Set<String> s) => setState(() => _entryType = s.first)), const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: _isLoadingBarcode ? null : _scanBarcode,
              icon: _isLoadingBarcode ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.qr_code_scanner),
              label: Text(_isLoadingBarcode ? 'A consultar base de dados mundial...' : 'Ler Código de Barras do Produto'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(children: const [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('OU PREENCHA MANUALMENTE', style: TextStyle(color: Colors.grey, fontSize: 12))), Expanded(child: Divider())]),
            const SizedBox(height: 16),

            TextField(controller: tCtrl, decoration: const InputDecoration(labelText: 'Descrição (Ex: Maçã)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description, color: Colors.teal))), const SizedBox(height: 16),
            TextField(controller: cCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hidratos de Carbono', suffixText: 'g', border: OutlineInputBorder(), prefixIcon: Icon(Icons.bakery_dining, color: Colors.orange))), const SizedBox(height: 16),
            TextField(controller: iCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dose de Insulina', suffixText: 'Unidades', border: OutlineInputBorder(), prefixIcon: Icon(Icons.vaccines, color: Colors.blue))), const SizedBox(height: 32),
            ElevatedButton.icon(onPressed: () { globalDiary.insert(0, {'title': tCtrl.text.isEmpty ? 'Registo Manual' : tCtrl.text, 'carbs': double.tryParse(cCtrl.text) ?? 0.0, 'insulin': double.tryParse(iCtrl.text) ?? 0.0, 'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}', 'type': _entryType, 'imagePath': null }); saveData(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado no Diário!'), backgroundColor: Colors.green)); Navigator.of(context).pop(); }, icon: const Icon(Icons.save), label: const Text('Guardar no Diário'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16))),
          ],
        ),
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}
class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller; bool _isInitialized = false;
  @override
  void initState() { super.initState(); if (cameras.isNotEmpty) { _controller = CameraController(cameras[0], ResolutionPreset.high, enableAudio: false); _controller.initialize().then((_) { if (mounted) setState(() => _isInitialized = true); }).catchError((e) => debugPrint("Camera Error: $e")); } }
  @override
  void dispose() { if (_isInitialized) _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (cameras.isEmpty) return Scaffold(appBar: AppBar(title: const Text('Câmara não encontrada')), body: const Center(child: Text('Nenhuma câmara detetada.')));
    return Scaffold(appBar: AppBar(title: const Text('Analisar Refeição'), backgroundColor: Colors.black, foregroundColor: Colors.white), backgroundColor: Colors.black, body: _isInitialized ? Center(child: CameraPreview(_controller)) : const Center(child: CircularProgressIndicator(color: Colors.white)), floatingActionButton: FloatingActionButton(onPressed: () async { final image = await _controller.takePicture(); if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AnalysisResultScreen(imagePath: image.path))); }, backgroundColor: Colors.white, child: const Icon(Icons.camera, color: Colors.black, size: 32)), floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}

class AnalysisResultScreen extends StatefulWidget {
  final String imagePath; const AnalysisResultScreen({super.key, required this.imagePath});
  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}
class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  bool _isAnalyzing = true; 
  @override
  void initState() { super.initState(); Future.delayed(const Duration(milliseconds: 2500), () { if (mounted) setState(() => _isAnalyzing = false); }); }
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Análise SmartGlycoAI'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(width: double.infinity, height: 300, child: Image.file(File(widget.imagePath), fit: BoxFit.cover)), const SizedBox(height: 24),
            _isAnalyzing ? Column(children: const [CircularProgressIndicator(), SizedBox(height: 16), Text('A analisar refeição com IA...', style: TextStyle(color: Colors.grey))]) : Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(20.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: const [Icon(Icons.check_circle, color: Colors.green, size: 28), SizedBox(width: 8), Text('Refeição Identificada', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]), const Divider(height: 30), const Text('Alimento Principal: Bife com Arroz', style: TextStyle(fontSize: 16)), const SizedBox(height: 12), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Hidratos:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text('45g', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange))])), const SizedBox(height: 12), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Dose Sugerida:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text('${(45 / globalIcr).toStringAsFixed(1)} U', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue))]))]))), const SizedBox(height: 24), ElevatedButton.icon(onPressed: () { globalDiary.insert(0, {'title': 'Refeição Analisada', 'carbs': 45.0, 'insulin': double.parse((45 / globalIcr).toStringAsFixed(1)), 'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}', 'type': 'meal', 'imagePath': widget.imagePath}); saveData(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado no Diário!'), backgroundColor: Colors.green)); Navigator.of(context).pop(); }, icon: const Icon(Icons.save), label: const Text('Confirmar e Guardar'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16))), TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar / Tirar outra foto', style: TextStyle(color: Colors.grey)))]))
          ],
        ),
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
  void _deleteRecord() { showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Apagar Registo?'), content: const Text('Tem a certeza que quer apagar?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')), ElevatedButton(onPressed: () { globalDiary.removeAt(widget.itemIndex); saveData(); Navigator.pop(ctx); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Apagado!'), backgroundColor: Colors.red)); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('Apagar'))])); }

  @override
  Widget build(BuildContext context) {
    final item = globalDiary[widget.itemIndex]; final String? img = item['imagePath'];
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Registo'), backgroundColor: Theme.of(context).colorScheme.inversePrimary, actions: [IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _deleteRecord)]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (img != null) SizedBox(width: double.infinity, height: 250, child: Image.file(File(img), fit: BoxFit.cover)) else Container(width: double.infinity, height: 200, color: Theme.of(context).colorScheme.surfaceContainerHighest, child: Icon(item['type'] == 'meal' ? Icons.restaurant : Icons.water_drop, size: 80, color: Colors.grey)),
            Padding(padding: const EdgeInsets.all(20.0), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [TextField(controller: hCtrl, decoration: const InputDecoration(labelText: 'Hora', border: OutlineInputBorder(), prefixIcon: Icon(Icons.access_time))), const SizedBox(height: 16), TextField(controller: tCtrl, decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description))), const SizedBox(height: 16), TextField(controller: cCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hidratos', suffixText: 'g', border: OutlineInputBorder(), prefixIcon: Icon(Icons.bakery_dining))), const SizedBox(height: 16), TextField(controller: iCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Insulina', suffixText: 'U', border: OutlineInputBorder(), prefixIcon: Icon(Icons.vaccines))), const SizedBox(height: 32), ElevatedButton.icon(onPressed: () { globalDiary[widget.itemIndex]['time'] = hCtrl.text; globalDiary[widget.itemIndex]['title'] = tCtrl.text; globalDiary[widget.itemIndex]['carbs'] = double.tryParse(cCtrl.text) ?? 0.0; globalDiary[widget.itemIndex]['insulin'] = double.tryParse(iCtrl.text) ?? 0.0; saveData(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado!'), backgroundColor: Colors.teal)); Navigator.of(context).pop(); }, icon: const Icon(Icons.check), label: const Text('Guardar'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)))]))
          ],
        ),
      ),
    );
  }
}