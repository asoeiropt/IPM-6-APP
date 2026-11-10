import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_data.dart'; 
import 'main_navigator.dart';

// --- CORES BASE DO NOVO DESIGN ---
const Color bgColor = Color(0xFF090C10);
const Color cardColor = Color(0xFF141923);
const Gradient neonGradient = LinearGradient(
  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)], 
);
const Gradient dangerGradient = LinearGradient(
  colors: [Color(0xFFF43F5E), Color(0xFFBE185D)], 
);
const Color textMuted = Color(0xFF64748B);

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
    await Future.delayed(const Duration(seconds: 10)); 
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash_logo.jpg'), 
            fit: BoxFit.cover, 
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end, 
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5), 
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                    ]
                  ),
                  child: const CircularProgressIndicator(
                    color: Colors.white, 
                    strokeWidth: 3,
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
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                color: cardColor, 
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFF43F5E).withOpacity(0.1), blurRadius: 30),
                ]
              ),
              child: const Icon(Icons.lock_outline, size: 50, color: Color(0xFFF43F5E)),
            ),
            const SizedBox(height: 32), 
            const Text('App Locked', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8), 
            const Text('Biometric protection enabled.', style: TextStyle(color: textMuted, fontSize: 14)),
            const SizedBox(height: 40), 
            
            GestureDetector(
              onTap: _authenticate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: dangerGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFF43F5E).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.fingerprint, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Try Again', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
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
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildPage(Icons.health_and_safety, 'Welcome to\nSmartGlycoAI', 'Your smart assistant for diabetes\nmanagement.'),
                  _buildPage(Icons.camera_alt_outlined, 'AI Calculation', 'Take a picture of your meal and our AI will\nsuggest the exact insulin dose.'),
                  _buildPage(Icons.notifications_active_outlined, 'Crisis Prevention', 'Predictive warnings before a hypoglycemia\noccurs.')
                ]
              )
            ), 
            Padding(
              padding: const EdgeInsets.all(32.0), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(3, (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8), 
                      height: 8, 
                      width: _currentPage == index ? 24 : 8, 
                      decoration: BoxDecoration(
                        color: _currentPage == index ? const Color(0xFF3B82F6) : cardColor,
                        borderRadius: BorderRadius.circular(8)
                      )
                    ))
                  ), 
                  GestureDetector(
                    onTap: () { 
                      HapticFeedback.lightImpact();
                      if (_currentPage == 2) { 
                        isFirstTime = false;
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
                      } else { 
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn); 
                      } 
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: neonGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Text(
                        _currentPage == 2 ? 'Start' : 'Next',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                    ),
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
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [const Color(0xFF3B82F6).withOpacity(0.2), Colors.transparent],
                radius: 0.8,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: Icon(icon, size: 50, color: const Color(0xFF3B82F6)),
            ),
          ),
          const SizedBox(height: 48), 
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16), 
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: textMuted, height: 1.5))
        ]
      )
    ); 
  }
}

// --- ECRÃ DE LOGIN ---
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _showMockGoogleSignIn(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.g_mobiledata, size: 40, color: Colors.white),
                SizedBox(width: 8),
                Text('Sign in with Google', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Choose an account to continue to SmartGlycoAI', style: TextStyle(color: textMuted, fontSize: 14)),
            const SizedBox(height: 24),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  gradient: neonGradient,
                  shape: BoxShape.circle,
                ),
                child: const Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              title: const Text('Afonso Soeiro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('afonso.soeiro@gmail.com', style: TextStyle(color: textMuted)),
              onTap: () {
                Navigator.pop(ctx); 
                isLoggedIn = true;
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigator()));
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                child: const Icon(Icons.person_add, color: Colors.white54, size: 20),
              ),
              title: const Text('Add another account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(ctx), 
            ),
            const SizedBox(height: 32),
          ]
        )
      )
    );
  }

  InputDecoration _customInputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: textMuted, fontSize: 15),
      prefixIcon: Icon(icon, color: textMuted, size: 20),
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0), 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: cardColor, 
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: const Icon(Icons.monitor_heart, size: 40, color: Color(0xFF3B82F6)),
                ),
              ),
              const SizedBox(height: 32), 
              
              const Text('Welcome Back', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 40), 
              
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: _customInputDeco('Email', Icons.mail_outline)
              ), 
              const SizedBox(height: 16), 
              TextField(
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _customInputDeco('Password', Icons.lock_outline)
              ), 
              const SizedBox(height: 32), 
              
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  isLoggedIn = true; 
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigator()));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: neonGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Center(
                    child: Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 16), 
              
              GestureDetector(
                onTap: () => _showMockGoogleSignIn(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.g_mobiledata, size: 26, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Sign in with Google', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // --- ZONA DE CRIAR CONTA ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: textMuted, fontSize: 14)),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignUpScreen()));
                    },
                    child: const Text('Sign Up', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ]
          )
        )
      )
    );
  }
}

// --- NOVO ECRÃ DE REGISTO (SIGN UP) ---
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  InputDecoration _customInputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: textMuted, fontSize: 15),
      prefixIcon: Icon(icon, color: textMuted, size: 20),
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context), // <--- Substitui onTap por onPressed
          ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10.0), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Join SmartGlycoAI today', style: TextStyle(color: textMuted, fontSize: 14)),
              const SizedBox(height: 40), 
              
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: _customInputDeco('Full Name', Icons.person_outline)
              ), 
              const SizedBox(height: 16), 
              
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: _customInputDeco('Email', Icons.mail_outline)
              ), 
              const SizedBox(height: 16), 
              
              TextField(
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _customInputDeco('Password', Icons.lock_outline)
              ), 
              const SizedBox(height: 16),
              
              TextField(
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _customInputDeco('Confirm Password', Icons.lock_outline)
              ), 
              const SizedBox(height: 32), 
              
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  isLoggedIn = true; 
                  // Vai direto para a App após criar conta e remove o stack de navegação para trás
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainNavigator()), 
                    (Route<dynamic> route) => false
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: neonGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Center(
                    child: Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 16), 
              
              GestureDetector(
                onTap: () {
                  // Pode chamar o mesmo mock de Google Sign In aqui ou voltar atrás
                  Navigator.pop(context); 
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.g_mobiledata, size: 26, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Sign up with Google', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ", style: TextStyle(color: textMuted, fontSize: 14)),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context); // Volta ao login
                    },
                    child: const Text('Sign In', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ]
          )
        )
      )
    );
  }
}