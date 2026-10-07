import 'package:flutter/material.dart';
import 'app_data.dart'; 
import 'app_screens.dart'; 

// --- CONSTANTES DE ESTILO (Baseadas nas imagens) ---
const Color bgDark = Colors.black; 
const Color cardDark = Color(0xFF111111); 
const Color accentBlue = Color(0xFF0070F3); 
final Color borderDark = Colors.white.withOpacity(0.05);
const Color textMain = Colors.white;
final Color textMuted = Colors.grey.shade500;

// --- ECRÃ DE INÍCIO (SPLASH SCREEN) ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startAppEngines();
  }

  Future<void> _startAppEngines() async {
    // Mantém o carregamento durante exatamente 4 segundos
    await Future.delayed(const Duration(seconds: 4));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash_logo.jpeg'), // O nome do teu ficheiro de imagem[cite: 5]
            fit: BoxFit.cover, // Preenche todo o ecrã do telemóvel
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end, // Alinha no fundo
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4), // Fundo escuro suave para dar contraste à roda
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    color: Colors.white, // Branco puro para garantir que se vê perfeitamente contra qualquer fundo
                    strokeWidth: 3.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ECRÃ DE BLOQUEIO (BIOMETRIA) ---
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  @override
  void initState() { 
    super.initState(); 
    _authenticate();
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try { 
      authenticated = await biometricAuth.authenticate(localizedReason: 'Please authenticate to access your health data.'); 
    } catch (e) { 
      debugPrint("Biometric Error: $e");
    }
    
    if (authenticated && mounted) { 
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigator())); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Container(
              width: 120, height: 120,
              decoration: const BoxDecoration(color: cardDark, shape: BoxShape.circle),
              child: const Icon(Icons.lock_outline, size: 60, color: accentBlue),
            ),
            const SizedBox(height: 32), 
            const Text('App Locked', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textMain)),
            const SizedBox(height: 8), 
            Text('Biometric protection enabled.', style: TextStyle(color: textMuted)),
            const SizedBox(height: 32), 
            ElevatedButton.icon(
              onPressed: _authenticate, 
              icon: const Icon(Icons.fingerprint),
              label: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.w600)), 
              style: ElevatedButton.styleFrom(
                backgroundColor: accentBlue, 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              )
            )
          ]
        )
      )
    );
  }
}

// --- ECRÃ DE BOAS VINDAS (ONBOARDING) ---
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildPage(Icons.health_and_safety, '💙 Welcome to SmartGlycoAI', 'Your smart assistant for diabetes\nmanagement.'),
                  _buildPage(Icons.camera_alt_outlined, '📸 AI Calculation', 'Take a picture of your meal and our AI will\nsuggest the exact insulin dose.'),
                  _buildPage(Icons.notifications_active_outlined, '🚨 Crisis Prevention', 'Predictive warnings before a hypoglycemia\noccurs.')
                ]
              )
            ), 
            Padding(
              padding: const EdgeInsets.all(32.0), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pontinhos indicadores
                  Row(
                    children: List.generate(3, (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8), 
                      height: 8, 
                      width: _currentPage == index ? 24 : 8, 
                      decoration: BoxDecoration(
                        color: _currentPage == index ? accentBlue : const Color(0xFF333333),
                        borderRadius: BorderRadius.circular(8)
                      )
                    ))
                  ), 
                  // Botão Azul
                  ElevatedButton(
                    onPressed: () { 
                      if (_currentPage == 2) { 
                        isFirstTime = false;
                        // saveData(); (removido temporariamente para não dar erro)
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
                      } else { 
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn); 
                      } 
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentBlue, 
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ), 
                    child: Text(
                      _currentPage == 2 ? 'Start' : 'Next',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
                    )
                  )
                ]
              )
            )
          ]
        )
      )
    );
  }

  Widget _buildPage(IconData icon, String title, String desc) { 
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0), 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Container(
            width: 140, height: 140,
            decoration: const BoxDecoration(color: cardDark, shape: BoxShape.circle),
            child: Icon(icon, size: 70, color: accentBlue),
          ),
          const SizedBox(height: 48), 
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textMain)),
          const SizedBox(height: 16), 
          Text(desc, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: textMuted, height: 1.4))
        ]
      )
    ); 
  }
}

// --- ECRÃ DE LOGIN ---
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Simulação do Popup do Google para o Protótipo
  void _showMockGoogleSignIn(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.g_mobiledata, size: 40, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Sign in with Google', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Choose an account to continue to SmartGlycoAI', style: TextStyle(color: textMuted, fontSize: 14)),
            const SizedBox(height: 24),
            
            // Conta Mockada para a Demo
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: accentBlue, 
                child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              ),
              title: const Text('Afonso Soeiro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              subtitle: Text('afonso.soeiro@gmail.com', style: TextStyle(color: textMuted)),
              onTap: () {
                Navigator.pop(ctx); // Fecha o popup
                
                isLoggedIn = true;
                // saveData(); (removido para evitar encravar)
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigator()));
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.1), 
                child: const Icon(Icons.person_add, color: Colors.white, size: 20)
              ),
              title: const Text('Add another account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(ctx), // Apenas fecha
            ),
            const SizedBox(height: 16),
          ]
        )
      )
    );
  }

  InputDecoration _customInputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: textMuted, fontSize: 15),
      prefixIcon: Icon(icon, color: textMuted, size: 20),
      filled: true,
      fillColor: cardDark,
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accentBlue, width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0), 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 100, height: 100,
                  decoration: const BoxDecoration(color: cardDark, shape: BoxShape.circle),
                  child: const Icon(Icons.monitor_heart, size: 50, color: accentBlue),
                ),
              ),
              const SizedBox(height: 32), 
              
              const Text('Welcome Back', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textMain)),
              const SizedBox(height: 40), 
              
              TextField(
                style: const TextStyle(color: textMain),
                decoration: _customInputDeco('Email', Icons.mail_outline)
              ), 
              const SizedBox(height: 16), 
              TextField(
                obscureText: true,
                style: const TextStyle(color: textMain),
                decoration: _customInputDeco('Password', Icons.lock_outline)
              ), 
              const SizedBox(height: 32), 
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18), 
                  backgroundColor: accentBlue, 
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ), 
                onPressed: () { 
                  isLoggedIn = true; 
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigator()));
                }, 
                child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
              ), 
              const SizedBox(height: 16), 
              
              // Botão Sign In com a Google 
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: cardDark, 
                  foregroundColor: textMain,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ), 
                onPressed: () => _showMockGoogleSignIn(context),
                icon: const Icon(Icons.g_mobiledata, size: 28, color: textMain),
                label: const Text('Sign in with Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600))
              )
            ]
          )
        )
      )
    );
  }
}