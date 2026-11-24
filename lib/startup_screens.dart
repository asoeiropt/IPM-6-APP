import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'app_data.dart';
import 'fcm_notification_service.dart';
import 'main_navigator.dart';
import 'screens/doctor_dashboard.dart';

const Color bgColor = Color(0xFF090C10);
const Color cardColor = Color(0xFF141923);
const Gradient neonGradient = LinearGradient(
  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
);
const Gradient dangerGradient = LinearGradient(
  colors: [Color(0xFFF43F5E), Color(0xFFBE185D)],
);
const Color textMuted = Color(0xFF64748B);

Widget _buildLanguagePillButton(VoidCallback onChanged) {
  return GestureDetector(
    onTap: () {
      HapticFeedback.selectionClick();
      isPortuguese = !isPortuguese;
      saveData();
      onChanged();
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language, color: Color(0xFF3B82F6), size: 16),
          const SizedBox(width: 6),
          Text(
            isPortuguese ? 'PT' : 'EN',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _startAppEngines();
  }

  Future<void> _startAppEngines() async {
    try {
      await loadData().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint("⚠️ Erro ou timeout ao carregar dados locais: $e");
    }
    _dataLoaded = true;

    // Garante que João, Maria e Dra. Joana existem na coleção 'users' do Firestore
    seedDemoUsersIfMissing()
        .catchError((e) => debugPrint("⚠️ Seed Firestore: $e"));

    await Future.delayed(const Duration(milliseconds: 1500));
    _goNext();
  }

  void _goNext() {
    if (_navigated || !mounted || !_dataLoaded) return;
    _navigated = true;

    Widget nextScreen;

    if (isLoggedIn && currentUserId.isNotEmpty) {
      FcmNotificationService.instance
          .registerUserDeviceToken()
          .catchError((e) => debugPrint("FCM Error: $e"));

      if (useBiometrics) {
        nextScreen = const LockScreen();
      } else {
        nextScreen = currentUserId == 'medica_joana'
            ? const DoctorDashboard()
            : const MainNavigator();
      }
    } else if (!isFirstTime) {
      nextScreen = const LoginScreen();
    } else {
      nextScreen = const OnboardingScreen();
    }

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goNext,
      child: Scaffold(
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
                          BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5),
                        ]),
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
      ),
    );
  }
}

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
      authenticated = await biometricAuth.authenticate(
          localizedReason: tr(
        'Autentica-te para aceder aos teus dados de saúde.',
        'Please authenticate to access your health data.',
      ));
    } catch (e) {
      debugPrint("Biometric Error: $e");
    }

    if (authenticated && mounted) {
      FcmNotificationService.instance
          .registerUserDeviceToken()
          .catchError((e) => debugPrint("FCM Error: $e"));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => currentUserId == 'medica_joana'
              ? const DoctorDashboard()
              : const MainNavigator(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFFF43F5E).withOpacity(0.1),
                      blurRadius: 30),
                ]),
            child: const Icon(Icons.lock_outline,
                size: 50, color: Color(0xFFF43F5E)),
          ),
          const SizedBox(height: 32),
          Text(tr('Aplicação Bloqueada', 'App Locked'),
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Text(
              tr('Proteção biométrica ativa.',
                  'Biometric protection enabled.'),
              style: const TextStyle(color: textMuted, fontSize: 14)),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _authenticate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: dangerGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFFF43F5E).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fingerprint, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(tr('Tentar Novamente', 'Try Again'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ])));
  }
}

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
            child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, right: 24),
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildLanguagePillButton(() => setState(() {})),
            ),
          ),
          Expanded(
              child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                _buildPage(
                    Icons.health_and_safety,
                    tr('Bem-vindo à\nSmartGlycoAI', 'Welcome to\nSmartGlycoAI'),
                    tr('O teu assistente inteligente para a\ngestão da Diabetes Tipo 1.',
                        'Your smart assistant for Type 1\ndiabetes management.')),
                _buildPage(
                    Icons.camera_alt_outlined,
                    tr('Cálculo por IA', 'AI Calculation'),
                    tr(
                        'Fotografa a tua refeição e a nossa IA\nsugere a dose exata de insulina.',
                        'Take a picture of your meal and our AI will\nsuggest the exact insulin dose.')),
                _buildPage(
                    Icons.notifications_active_outlined,
                    tr('Prevenção de Crises', 'Crisis Prevention'),
                    tr('Avisos preditivos antes de ocorrer\numa hipoglicemia.',
                        'Predictive warnings before a hypoglycemia\noccurs.'))
              ])),
          Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                        children: List.generate(
                            3,
                            (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 8),
                                height: 8,
                                width: _currentPage == index ? 24 : 8,
                                decoration: BoxDecoration(
                                    color: _currentPage == index
                                        ? const Color(0xFF3B82F6)
                                        : cardColor,
                                    borderRadius: BorderRadius.circular(8))))),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (_currentPage == 2) {
                          isFirstTime = false;
                          saveData();
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()));
                        } else {
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: neonGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Text(
                            _currentPage == 2
                                ? tr('Começar', 'Start')
                                : tr('Seguinte', 'Next'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    )
                  ]))
        ])));
  }

  Widget _buildPage(IconData icon, String title, String desc) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.2),
                  Colors.transparent
                ],
                radius: 0.8,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: Icon(icon, size: 50, color: const Color(0xFF3B82F6)),
            ),
          ),
          const SizedBox(height: 48),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 16),
          Text(desc,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 15, color: textMuted, height: 1.5))
        ]));
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _showMockGoogleSignIn(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: cardColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.g_mobiledata,
                          size: 40, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                          tr('Entrar com o Google', 'Sign in with Google'),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                      tr('Escolhe uma conta para continuar na SmartGlycoAI',
                          'Choose an account to continue to SmartGlycoAI'),
                      style: const TextStyle(color: textMuted, fontSize: 14)),
                  const SizedBox(height: 24),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        gradient: neonGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('A',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                    title: const Text('Afonso Soeiro',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text('afonso.soeiro@gmail.com',
                        style: TextStyle(color: textMuted)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      isFirstTime = false;
                      isLoggedIn = true;
                      currentUserId = 'paciente_joao';
                      currentUserName = 'Afonso Soeiro';
                      currentUserEmail = 'afonso.soeiro@gmail.com';
                      currentUserPhone = '+351 912 345 678';
                      currentUserDob = '15/08/2003';
                      currentDiagnosisYear = '2020';
                      await saveData();
                      FcmNotificationService.instance
                          .registerUserDeviceToken()
                          .catchError((e) => debugPrint("FCM Error: $e"));
                      if (!mounted) return;
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (_) => const MainNavigator()));
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.person_add,
                          color: Colors.white54, size: 20),
                    ),
                    title: Text(
                        tr('Adicionar outra conta', 'Add another account'),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500)),
                    onTap: () => Navigator.pop(ctx),
                  ),
                  const SizedBox(height: 32),
                ])));
  }

  InputDecoration _customInputDeco(String hint, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: textMuted, fontSize: 15),
      prefixIcon: Icon(icon, color: textMuted, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
    );
  }

  Future<void> _syncDemoUserFromFirestore(String docId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .get();
      if (doc.exists && doc.data() != null) {
        final d = doc.data()!;
        currentUserName = (d['name'] ?? currentUserName).toString();
        currentUserEmail = (d['email'] ?? currentUserEmail).toString();
        currentUserPhone = (d['phone'] ?? currentUserPhone).toString();
        currentUserDob = (d['dob'] ?? currentUserDob).toString();
        currentDiagnosisYear =
            (d['diagnosisYear'] ?? currentDiagnosisYear).toString();
        if (d['icr'] != null) globalIcr = (d['icr'] as num).toDouble();
        if (d['isf'] != null) globalIsf = (d['isf'] as num).toDouble();
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao ler dados atualizados de $docId: $e');
    }
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    final String email = _emailController.text.trim().toLowerCase();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(tr(
          'Por favor, preenche o email e a palavra-passe.',
          'Please enter your email and password.',
        ))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. CONTAS DE DEMONSTRAÇÃO PRÉ-DEFINIDAS (com leitura do Firestore se editadas)
      if ((email == 'joana@smartglyco.pt' || email == 'medica') &&
          password == '1234') {
        isFirstTime = false;
        isLoggedIn = true;
        currentUserId = 'medica_joana';
        currentUserName = 'Dra. Joana Sílvia';
        currentUserEmail = 'joana@smartglyco.pt';
        currentUserPhone = '+351 217 805 000';
        currentUserDob = '12/04/1984';
        currentDiagnosisYear = '';
        await _syncDemoUserFromFirestore('medica_joana');
        await saveData();
        FcmNotificationService.instance
            .registerUserDeviceToken()
            .catchError((e) => debugPrint("FCM Error: $e"));

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DoctorDashboard()));
        return;
      }

      if ((email == 'joao@smartglyco.pt' || email == 'joao') &&
          password == '1234') {
        isFirstTime = false;
        isLoggedIn = true;
        currentUserId = 'paciente_joao';
        currentUserName = 'João Antunes';
        currentUserEmail = 'joao@smartglyco.pt';
        currentUserPhone = '+351 912 345 678';
        currentUserDob = '15/08/1998';
        currentDiagnosisYear = '2021';
        await _syncDemoUserFromFirestore('paciente_joao');
        await saveData();
        FcmNotificationService.instance
            .registerUserDeviceToken()
            .catchError((e) => debugPrint("FCM Error: $e"));

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigator()));
        return;
      }

      if ((email == 'maria@smartglyco.pt' || email == 'maria') &&
          password == '1234') {
        isFirstTime = false;
        isLoggedIn = true;
        currentUserId = 'paciente_maria';
        currentUserName = 'Maria Silva';
        currentUserEmail = 'maria@smartglyco.pt';
        currentUserPhone = '+351 963 852 741';
        currentUserDob = '22/03/1995';
        currentDiagnosisYear = '2019';
        await _syncDemoUserFromFirestore('paciente_maria');
        await saveData();
        FcmNotificationService.instance
            .registerUserDeviceToken()
            .catchError((e) => debugPrint("FCM Error: $e"));

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigator()));
        return;
      }

      // 2. PROCURAR CONTAS CRIADAS NO CLOUD FIRESTORE (coleção 'users')
      final querySnap = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnap.docs.isNotEmpty) {
        final userDoc = querySnap.docs.first;
        final userData = userDoc.data();
        final savedPass = (userData['password'] ?? '').toString();

        if (savedPass == password) {
          isFirstTime = false;
          isLoggedIn = true;
          currentUserId = userDoc.id;
          currentUserName =
              (userData['name'] ?? tr('Utilizador', 'User')).toString();
          currentUserEmail = (userData['email'] ?? email).toString();
          currentUserPhone = (userData['phone'] ?? '').toString();
          currentUserDob = (userData['dob'] ?? '').toString();
          currentDiagnosisYear = (userData['diagnosisYear'] ?? '').toString();
          if (userData['icr'] != null) {
            globalIcr = (userData['icr'] as num).toDouble();
          }
          if (userData['isf'] != null) {
            globalIsf = (userData['isf'] as num).toDouble();
          }
          await saveData();

          FcmNotificationService.instance
              .registerUserDeviceToken()
              .catchError((e) => debugPrint("FCM Error: $e"));

          if (!mounted) return;
          final bool isDoctor = (userData['role'] ?? 'patient') == 'doctor';
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => isDoctor
                  ? const DoctorDashboard()
                  : const MainNavigator()));
          return;
        }
      }

      isLoggedIn = false;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFF43F5E),
          content: Text(tr(
            'Credenciais incorretas! Usa a tua conta registada ou joao / maria / medica (pass: 1234).',
            'Incorrect credentials! Use your registered account or joao / maria / medica (pass: 1234).',
          )),
        ),
      );
    } catch (e, st) {
      debugPrint("❌ ERRO NO LOGIN: $e\n$st");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('${tr('Erro ao entrar', 'Login error')}: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildLanguagePillButton(() => setState(() {})),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: const Icon(Icons.monitor_heart,
                        size: 40, color: Color(0xFF3B82F6)),
                  ),
                ),
                const SizedBox(height: 32),
                Text(tr('Bem-vindo de Volta', 'Welcome Back'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 40),
                TextField(
                    controller: _emailController,
                    autofocus: true,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _passFocus.requestFocus(),
                    style: const TextStyle(color: Colors.white),
                    decoration: _customInputDeco(
                        tr('Email', 'Email'), Icons.mail_outline)),
                const SizedBox(height: 16),
                TextField(
                    controller: _passwordController,
                    focusNode: _passFocus,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(),
                    style: const TextStyle(color: Colors.white),
                    decoration: _customInputDeco(
                      tr('Palavra-passe', 'Password'),
                      Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: textMuted,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    )),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _isLoading ? null : _handleLogin,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: neonGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(tr('Entrar', 'Sign In'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
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
                      border:
                          Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.g_mobiledata,
                            size: 26, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(tr('Entrar com o Google', 'Sign in with Google'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        tr('Não tens conta? ', "Don't have an account? "),
                        style: const TextStyle(color: textMuted, fontSize: 14)),
                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const SignUpScreen()));
                        if (mounted) setState(() {});
                      },
                      child: Text(tr('Criar Conta', 'Sign Up'),
                          style: const TextStyle(
                              color: Color(0xFF3B82F6),
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _diagnosisYearController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _diagnosisYearController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1998, 8, 15),
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() {
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  InputDecoration _customInputDeco(String hint, IconData icon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: textMuted, fontSize: 15),
      prefixIcon: Icon(icon, color: textMuted, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
    );
  }

  String _buildInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'P';
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim().toLowerCase();
    final String phone = _phoneController.text.trim();
    final String dob = _dobController.text.trim();
    final String diagnosisYear = _diagnosisYearController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        dob.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFF43F5E),
          content: Text(tr(
            '⚠️ Preenche todos os campos obrigatórios antes de criar conta.',
            '⚠️ Fill in all required fields before creating an account.',
          )),
        ),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFF43F5E),
          content: Text(tr(
            '⚠️ Introduz um endereço de email válido.',
            '⚠️ Please enter a valid email address.',
          )),
        ),
      );
      return;
    }

    if (password.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFF43F5E),
          content: Text(tr(
            '⚠️ A palavra-passe deve ter pelo menos 4 caracteres.',
            '⚠️ Password must be at least 4 characters long.',
          )),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFF43F5E),
          content: Text(tr(
            '⚠️ As palavras-passe não coincidem.',
            '⚠️ Passwords do not match.',
          )),
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFF43F5E),
            content: Text(tr(
              '⚠️ Já existe uma conta registada com esse email.',
              '⚠️ An account with this email already exists.',
            )),
          ),
        );
        setState(() => _isCreating = false);
        return;
      }

      final sanitizedEmail = email.replaceAll(RegExp(r'[^a-z0-9]'), '_');
      final String newUserId = 'paciente_$sanitizedEmail';
      final String initials = _buildInitials(name);

      await FirebaseFirestore.instance.collection('users').doc(newUserId).set({
        'name': name,
        'email': email,
        'phone': phone,
        'dob': dob,
        'diabetesType': 'Type 1 Diabetes',
        'diagnosisYear': diagnosisYear,
        'password': password,
        'role': 'patient',
        'initials': initials,
        'icr': 15.0,
        'isf': 50.0,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(newUserId)
          .set({
        'patientId': newUserId,
        'patientName': name,
        'initials': initials,
        'date': DateFormat('dd/MM/yyyy').format(tomorrow),
        'time': '11:00 AM',
        'type': tr('Primeira Consulta', 'First Visit'),
        'isCompleted': false,
      }, SetOptions(merge: true));

      isFirstTime = false;
      isLoggedIn = true;
      currentUserId = newUserId;
      currentUserName = name;
      currentUserEmail = email;
      currentUserPhone = phone;
      currentUserDob = dob;
      currentDiagnosisYear = diagnosisYear;
      globalIcr = 15.0;
      globalIsf = 50.0;
      await saveData();

      FcmNotificationService.instance
          .registerUserDeviceToken()
          .catchError((e) => debugPrint("FCM Error: $e"));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2DD4BF),
          content: Text(
            tr(
              '✅ Conta criada com sucesso! Bem-vindo(a), $name.',
              '✅ Account created successfully! Welcome, $name.',
            ),
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigator()),
          (Route<dynamic> route) => false);
    } catch (e) {
      debugPrint('❌ Erro ao criar conta no Firestore: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('${tr('Erro ao criar conta', 'Sign up error')}: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 24, top: 8, bottom: 8),
              child: _buildLanguagePillButton(() => setState(() {})),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(tr('Criar Conta', 'Create Account'),
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                    tr('Gestão inteligente para Diabetes Tipo 1',
                        'Smart management for Type 1 Diabetes'),
                    style: const TextStyle(color: textMuted, fontSize: 14)),
                const SizedBox(height: 28),
                TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.next,
                    decoration: _customInputDeco(
                        tr('Nome Completo', 'Full Name'),
                        Icons.person_outline)),
                const SizedBox(height: 14),
                TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _customInputDeco('Email', Icons.mail_outline)),
                const SizedBox(height: 14),
                TextField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    decoration: _customInputDeco(
                        tr('Telemóvel (ex: +351 912...)',
                            'Phone (e.g. +351 912...)'),
                        Icons.phone_outlined)),
                const SizedBox(height: 14),
                TextField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: _pickDob,
                    style: const TextStyle(color: Colors.white),
                    decoration: _customInputDeco(
                      tr('Data de Nascimento', 'Date of Birth'),
                      Icons.calendar_today_outlined,
                      suffixIcon: const Icon(Icons.edit_calendar,
                          color: textMuted, size: 18),
                    )),
                const SizedBox(height: 14),
                TextField(
                    controller: _diagnosisYearController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: _customInputDeco(
                        tr('Ano de Diagnóstico Tipo 1 (opcional)',
                            'Type 1 Diagnosis Year (optional)'),
                        Icons.history_edu_outlined)),
                const SizedBox(height: 14),
                TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.next,
                    decoration: _customInputDeco(
                      tr('Palavra-passe', 'Password'),
                      Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: textMuted,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    )),
                const SizedBox(height: 14),
                TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleSignUp(),
                    decoration: _customInputDeco(
                      tr('Confirmar Palavra-passe', 'Confirm Password'),
                      Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: textMuted,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirmPassword =
                              !_obscureConfirmPassword);
                        },
                      ),
                    )),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: _isCreating ? null : _handleSignUp,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: neonGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Center(
                      child: _isCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(tr('Criar Conta', 'Create Account'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.g_mobiledata,
                            size: 26, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                            tr('Registar com o Google', 'Sign up with Google'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        tr('Já tens uma conta? ',
                            'Already have an account? '),
                        style: const TextStyle(color: textMuted, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Text(tr('Entrar', 'Sign In'),
                          style: const TextStyle(
                              color: Color(0xFF3B82F6),
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}