import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import '../constants.dart';
import '../app_data.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.max,
          enableAudio: false,
        );

        await _controller!.initialize();

        if (!mounted) return;
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Erro ao inicializar a câmara: $e");
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isTakingPicture) {
      return;
    }

    try {
      setState(() {
        _isTakingPicture = true;
      });

      final XFile image = await _controller!.takePicture();

      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AnalysisResultScreen(imagePath: image.path))
      );

    } catch (e) {
      debugPrint("Erro ao tirar a fotografia: $e");
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: 100,
                  height: 100 * _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
              ),
            ),
            
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: _isTakingPicture
                    ? const CircularProgressIndicator(color: Colors.white)
                    : GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: Colors.white.withOpacity(0.3),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
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
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(title: const Text('🧠 AI Analysis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textMain)), backgroundColor: cardDark, elevation: 0, shape: Border(bottom: BorderSide(color: borderDark, width: 1)), iconTheme: const IconThemeData(color: textMain)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(width: double.infinity, height: 300, child: Image.file(File(widget.imagePath), fit: BoxFit.cover)), 
            const SizedBox(height: 24),
            _isAnalyzing ? Column(children: [const CircularProgressIndicator(color: Colors.white), const SizedBox(height: 16), Text('🤖 Processing vision model...', style: TextStyle(color: textMuted, fontFamily: 'monospace', fontSize: 12))]) : 
            Padding(
              padding: const EdgeInsets.all(20.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, 
                children: [
                  Container(
                    padding: const EdgeInsets.all(20.0), 
                    decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderDark)), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        Row(children: [const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18), const SizedBox(width: 8), const Text('🎯 MATCH FOUND', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: textMain))]), 
                        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: borderDark)), 
                        const Text('🥩 Steak with Rice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textMain)), 
                        const SizedBox(height: 16), 
                        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('🍞 EST. CARBS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: textMuted)), const Text('45g', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textMain))])), 
                        const SizedBox(height: 8), 
                        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('💉 DOSE SUGGESTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: textMuted)), Text('${(45 / globalIcr).toStringAsFixed(1)} U', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))]))
                      ]
                    )
                  ), 
                  const SizedBox(height: 24), 
                  ElevatedButton(
                    onPressed: () { globalDiary.insert(0, {'title': 'AI Meal', 'carbs': 45.0, 'insulin': double.parse((45 / globalIcr).toStringAsFixed(1)), 'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}', 'type': 'meal', 'imagePath': widget.imagePath}); saveData(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Logged!', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white)); Navigator.of(context).pop(); }, 
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text('✅ Confirm & Log', style: TextStyle(fontWeight: FontWeight.w600)),
                  ), 
                  const SizedBox(height: 8),
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('❌ Discard', style: TextStyle(color: textMuted)))
                ]
              )
            )
          ],
        ),
      ),
    );
  }
}