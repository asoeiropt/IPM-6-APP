import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import '../constants.dart';
import '../app_data.dart';

// --- CORES BASE DO NOVO DESIGN ---
const Color bgColor = Color(0xFF090C10);
const Color cardColor = Color(0xFF141923);
const Gradient neonGradient = LinearGradient(
  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)], 
);

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
      HapticFeedback.mediumImpact();
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
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black, // O fundo de ecrã da câmara fica mesmo preto para contraste
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
            
            // Blur/Degradé no topo e fundo para melhorar a interface
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  )
                ),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter, end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                  )
                ),
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 28,
              left: 0,
              right: 0,
              child: const Text('Scan your meal', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
            ),

            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: _isTakingPicture
                    ? const CircularProgressIndicator(color: Color(0xFF3B82F6))
                    : GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
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
  final String imagePath; 
  const AnalysisResultScreen({super.key, required this.imagePath});
  
  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  bool _isAnalyzing = true; 
  
  @override
  void initState() { 
    super.initState(); 
    Future.delayed(const Duration(milliseconds: 2500), () { 
      if (mounted) setState(() => _isAnalyzing = false); 
    }); 
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('AI Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), 
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity, 
              height: 300, 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
              ),
            ), 
            const SizedBox(height: 24),
            
            _isAnalyzing ? _buildLoadingState() : _buildResultState(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: const [
          CircularProgressIndicator(color: Color(0xFF3B82F6), strokeWidth: 3), 
          SizedBox(height: 24), 
          Text('Processing vision model...', style: TextStyle(color: Colors.white54, fontSize: 14)),
          SizedBox(height: 8),
          Text('Identifying ingredients & macros', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.bold)),
        ]
      ),
    );
  }

  Widget _buildResultState() {
    return Padding(
      padding: const EdgeInsets.all(20.0), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        children: [
          Container(
            padding: const EdgeInsets.all(20.0), 
            decoration: BoxDecoration(
              color: cardColor, 
              borderRadius: BorderRadius.circular(24), 
              border: Border.all(color: Colors.white.withOpacity(0.05))
            ), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: const Color(0xFF2DD4BF).withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Color(0xFF2DD4BF), size: 16),
                    ), 
                    const SizedBox(width: 12), 
                    const Text('MATCH FOUND', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: Color(0xFF2DD4BF))),
                  ]
                ), 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16), 
                  child: Divider(height: 1, color: Colors.white.withOpacity(0.05))
                ), 
                const Text('Steak with Rice', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)), 
                const SizedBox(height: 24), 
                
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16), 
                        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)), 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('CARBS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: Colors.white54)),
                            SizedBox(height: 4), 
                            Text('45g', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          ]
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16), 
                        decoration: BoxDecoration(
                          gradient: neonGradient, 
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                        ), 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('SUGGESTED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white70)),
                            const SizedBox(height: 4), 
                            Text('${(45 / globalIcr).toStringAsFixed(1)} U', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                          ]
                        ),
                      ),
                    ),
                  ],
                )
              ]
            )
          ), 
          const SizedBox(height: 32), 
          
          GestureDetector(
            onTap: () { 
              HapticFeedback.mediumImpact();
              globalDiary.insert(0, {'title': 'AI Meal', 'carbs': 45.0, 'insulin': double.parse((45 / globalIcr).toStringAsFixed(1)), 'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}', 'type': 'meal', 'imagePath': widget.imagePath}); 
              saveData(); 
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Logged!'), backgroundColor: Color(0xFF2DD4BF))); 
              Navigator.of(context).pop(); 
            }, 
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text('Confirm & Log', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ), 
          const SizedBox(height: 16),
          
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Discard', style: TextStyle(color: Colors.white54, fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          )
        ]
      )
    );
  }
}