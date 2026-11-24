import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../app_data.dart';

// --- CORES BASE DO DESIGN PADRÃO ---
const Color defaultBgColor = Color(0xFF090C10);
const Color defaultCardColor = Color(0xFF141923);
const Gradient defaultNeonGradient = LinearGradient(
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
  bool _hasCameraError = false;
  bool _isPermissionOrHardwareError = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (!mounted) return;
        setState(() {
          _hasCameraError = true;
          _isPermissionOrHardwareError = false;
        });
        return;
      }

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
    } catch (e) {
      debugPrint("Erro ao inicializar a câmara: $e");
      if (!mounted) return;
      setState(() {
        _hasCameraError = true;
        _isPermissionOrHardwareError = true;
      });
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isTakingPicture) {
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
        MaterialPageRoute(
            builder: (_) => AnalysisResultScreen(imagePath: image.path)),
      );
    } catch (e) {
      debugPrint("Erro ao tirar a fotografia: $e");
      if (!mounted) return;
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  void _openSampleAnalysis() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (_) => const AnalysisResultScreen(imagePath: null)),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isHighContrast ? Colors.black : defaultBgColor;
    final primaryColor =
        isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6);
    final textColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;

    if (_hasCameraError) {
      final errorMessage = _isPermissionOrHardwareError
          ? tr(
              'Câmara indisponível ou permissão recusada. Podes testar a análise de refeição com um exemplo.',
              'Camera unavailable or permission denied. You can still test the AI meal analysis using a sample meal.')
          : tr(
              'Nenhuma câmara detetada neste dispositivo ou navegador.',
              'No camera detected on this device or browser.');

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: textColor, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(tr('Analisar Refeição', 'Scan your meal'),
              style: TextStyle(color: textColor, fontSize: 18)),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.no_photography_outlined,
                    size: 64, color: primaryColor),
                const SizedBox(height: 20),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: isHighContrast ? Colors.white : Colors.white70,
                      fontSize: 15,
                      height: 1.5),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _openSampleAnalysis,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isHighContrast ? const Color(0xFFFFD600) : null,
                      gradient: isHighContrast ? null : defaultNeonGradient,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        tr('Usar Refeição Exemplo (Demo)',
                            'Use Sample Meal (Demo)'),
                        style: TextStyle(
                            color: isHighContrast ? Colors.black : Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: textColor, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryColor),
              const SizedBox(height: 16),
              Text(tr('A iniciar câmara...', 'Starting camera...'),
                  style: TextStyle(
                      color: isHighContrast ? Colors.white : Colors.white54,
                      fontSize: 14)),
            ],
          ),
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
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                )),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                )),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: isHighContrast
                      ? Border.all(color: const Color(0xFFFFD600), width: 2)
                      : null,
                ),
                child: IconButton(
                  icon: Icon(Icons.close,
                      color: isHighContrast
                          ? const Color(0xFFFFD600)
                          : Colors.white,
                      size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 28,
              left: 0,
              right: 0,
              child: Text(tr('Fotografa a refeição', 'Scan your meal'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: isHighContrast
                          ? const Color(0xFFFFD600)
                          : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 8)
                      ])),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: _isTakingPicture
                    ? CircularProgressIndicator(color: primaryColor)
                    : GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: isHighContrast
                                    ? const Color(0xFFFFD600)
                                    : Colors.white,
                                width: 4),
                            color: isHighContrast
                                ? Colors.black.withOpacity(0.5)
                                : Colors.white.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isHighContrast
                                    ? const Color(0xFFFFD600)
                                    : Colors.white,
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
  final String? imagePath;
  const AnalysisResultScreen({super.key, required this.imagePath});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  bool _isAnalyzing = true;
  late final TextEditingController _mealNameCtrl;
  late final TextEditingController _carbsCtrl;

  @override
  void initState() {
    super.initState();
    _mealNameCtrl =
        TextEditingController(text: tr('Bife com Arroz', 'Steak with Rice'));
    _carbsCtrl = TextEditingController(text: '45');
    _carbsCtrl.addListener(() {
      if (mounted) setState(() {});
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _isAnalyzing = false);
    });
  }

  @override
  void dispose() {
    _mealNameCtrl.dispose();
    _carbsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isHighContrast ? Colors.black : defaultBgColor;
    final textColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(tr('Análise IA', 'AI Analysis'),
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: isHighContrast ? Colors.black : defaultCardColor,
                borderRadius: BorderRadius.circular(24),
                border: isHighContrast
                    ? Border.all(color: const Color(0xFFFFD600), width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isHighContrast ? 22 : 24),
                child: (widget.imagePath != null && !kIsWeb)
                    ? Image.file(File(widget.imagePath!), fit: BoxFit.cover)
                    : (widget.imagePath != null && kIsWeb)
                        ? Image.network(widget.imagePath!, fit: BoxFit.cover)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restaurant_menu,
                                  size: 56, color: textColor),
                              const SizedBox(height: 12),
                              Text(
                                  tr('Pré-visualização de Exemplo',
                                      'Sample Meal Preview'),
                                  style: TextStyle(
                                      color: isHighContrast
                                          ? Colors.white
                                          : Colors.white70,
                                      fontSize: 14)),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 16),
            _isAnalyzing ? _buildLoadingState() : _buildResultState(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final primaryColor =
        isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6);

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(children: [
        CircularProgressIndicator(color: primaryColor, strokeWidth: 3),
        const SizedBox(height: 24),
        Text(
            tr('A processar modelo de visão...',
                'Processing vision model...'),
            style: TextStyle(
                color: isHighContrast ? Colors.white : Colors.white54,
                fontSize: 14)),
        const SizedBox(height: 8),
        Text(
            tr('A identificar ingredientes e macros',
                'Identifying ingredients & macros'),
            style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildResultState() {
    final bgColor = isHighContrast ? Colors.black : defaultBgColor;
    final cardColor = isHighContrast ? Colors.black : defaultCardColor;
    final primaryColor =
        isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF2DD4BF);
    final borderColor = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.05);

    final double parsedCarbs =
        double.tryParse(_carbsCtrl.text.trim().replaceAll(',', '.')) ?? 0.0;
    final double suggestedInsulin =
        globalIcr > 0 ? (parsedCarbs / globalIcr) : 0.0;

    return Padding(
        padding: const EdgeInsets.all(20.0),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: borderColor, width: isHighContrast ? 2 : 1)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isHighContrast
                              ? Colors.transparent
                              : const Color(0xFF2DD4BF).withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: isHighContrast
                              ? Border.all(color: primaryColor)
                              : null,
                        ),
                        child: Icon(Icons.check, color: primaryColor, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Text(
                          tr('REFEIÇÃO DETETADA (TOCA PARA EDITAR)',
                              'MATCH FOUND (TAP TO EDIT)'),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: primaryColor)),
                    ]),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(
                            height: 1,
                            color: isHighContrast
                                ? primaryColor
                                : Colors.white.withOpacity(0.05),
                            thickness: isHighContrast ? 2 : 1)),
                    TextField(
                      controller: _mealNameCtrl,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isHighContrast
                              ? const Color(0xFFFFD600)
                              : Colors.white),
                      decoration: InputDecoration(
                        labelText: tr('Refeição Detetada', 'Detected Meal'),
                        labelStyle: TextStyle(
                            color:
                                isHighContrast ? Colors.white : Colors.white54,
                            fontSize: 12),
                        suffixIcon: Icon(Icons.edit,
                            size: 18,
                            color:
                                isHighContrast ? primaryColor : Colors.white54),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: borderColor)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColor)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(16),
                              border: isHighContrast
                                  ? Border.all(color: primaryColor, width: 2)
                                  : null,
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tr('HIDRATOS (g)', 'CARBS (g)'),
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1,
                                          color: isHighContrast
                                              ? Colors.white
                                              : Colors.white54)),
                                  TextField(
                                    controller: _carbsCtrl,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isHighContrast
                                            ? const Color(0xFFFFD600)
                                            : Colors.white),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          EdgeInsets.only(top: 6, bottom: 2),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isHighContrast ? Colors.black : null,
                              gradient:
                                  isHighContrast ? null : defaultNeonGradient,
                              borderRadius: BorderRadius.circular(16),
                              border: isHighContrast
                                  ? Border.all(color: primaryColor, width: 2)
                                  : null,
                              boxShadow: isHighContrast
                                  ? null
                                  : [
                                      BoxShadow(
                                          color: const Color(0xFF3B82F6)
                                              .withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4))
                                    ],
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tr('SUGERIDO', 'SUGGESTED'),
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                          color: isHighContrast
                                              ? Colors.white
                                              : Colors.white70)),
                                  const SizedBox(height: 6),
                                  Text(
                                      '${suggestedInsulin.toStringAsFixed(1)} U',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isHighContrast
                                              ? const Color(0xFFFFD600)
                                              : Colors.white)),
                                ]),
                          ),
                        ),
                      ],
                    )
                  ])),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              final mealTitle = _mealNameCtrl.text.trim().isEmpty
                  ? tr('Refeição IA', 'AI Meal')
                  : _mealNameCtrl.text.trim();
              if (parsedCarbs <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr(
                        '⚠️ Introduz um valor de hidratos superior a 0g.',
                        '⚠️ Enter a carbohydrate value greater than 0g.')),
                    backgroundColor: const Color(0xFFF43F5E),
                  ),
                );
                return;
              }

              HapticFeedback.mediumImpact();
              globalDiary.insert(0, {
                'title': mealTitle,
                'carbs': parsedCarbs,
                'insulin': double.parse(suggestedInsulin.toStringAsFixed(1)),
                'time':
                    '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                'type': 'meal',
                'imagePath': kIsWeb ? null : widget.imagePath
              });
              saveData();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(tr('✅ Registado!', '✅ Logged!')),
                  backgroundColor: const Color(0xFF2DD4BF)));
              Navigator.of(context).pop();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: isHighContrast ? const Color(0xFFFFD600) : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(tr('Confirmar & Registar', 'Confirm & Log'),
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(tr('Descartar', 'Discard'),
                    style: TextStyle(
                        color: isHighContrast ? Colors.white : Colors.white54,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          )
        ]));
  }
}