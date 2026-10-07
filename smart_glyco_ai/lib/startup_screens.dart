import 'package:flutter/material.dart'; // Imports the main Flutter framework for the graphical interface (Material Design).
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Imports the package to manage local notifications on the device.
import 'package:camera/camera.dart'; // Imports the package to access the device cameras.
import 'app_data.dart'; // Imports your project file (likely global variables and state).
import 'app_screens.dart'; // Imports your project file (with additional screens like MainNavigator).

// --- VERCEL DARK THEME CONSTANTS (in case they aren't globally imported) ---
const Color bgDark = Color(0xFF0A0A0A);
const Color cardDark = Color(0xFF111111);
final Color borderDark = Colors.white.withOpacity(0.1);
const Color accentBlue = Color(0xFF0070F3); 
const Color textMain = Colors.white;
final Color textMuted = Colors.grey.shade500;

// --- SPLASH SCREEN ---
class SplashScreen extends StatefulWidget { // Defines SplashScreen as a Stateful widget.
  const SplashScreen({super.key}); // Default constructor with an optional key.
  @override
  State<SplashScreen> createState() => _SplashScreenState(); // Creates and links the state class to this widget.
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() { // Method executed only once when the widget is initialized.
    super.initState(); // Calls the parent class initialization.
    _startAppEngines(); // Calls the function that will prepare the application.
  }

  Future<void> _startAppEngines() async { // Asynchronous function that prepares dependencies before entering the app.
    try {
      cameras = await availableCameras(); // Gets the list of available cameras on the device.
      await loadData(); // Function (likely from app_data.dart) that loads saved data (e.g., shared_preferences).
      
      // Initial configuration for Android notifications.
      const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher'); 
      const InitializationSettings initSettings = InitializationSettings(android: androidInit); // Groups the settings.
      
      dynamic magicPlugin = notificationsPlugin; // Reference to the notifications plugin (should be in app_data.dart).
      await magicPlugin.initialize(initSettings); // Initializes the notifications service.
    } catch (e) {
      debugPrint("Startup Error: $e"); // If there's an error, prints it to the console instead of crashing the app.
    }
    
    await Future.delayed(const Duration(seconds: 2)); // Creates a 2-second pause so the logo remains visible.
    
    if (mounted) { // Checks if the widget is still active in the tree before navigating (prevents crashes).
      // Routing logic based on user state:
      if (isFirstTime) { 
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OnboardingScreen())); // 1st time: goes to the tutorial.
      } 
      else if (!isLoggedIn) { 
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())); // Not logged in: goes to Login.
      } 
      else {
        if (useBiometricsGlobal) { 
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LockScreen())); // Logged in with biometrics: asks for fingerprint.
        } 
        else { 
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigator())); // Logged in without biometrics: enters directly.
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) { // Builds the visual interface of the SplashScreen.
    return Scaffold( // Base structure of a Material page.
      backgroundColor: bgDark, // Sets the background color to dark Vercel theme.
      body: Center( // Centers the content on the screen.
        child: Column( // Places elements in a column (vertically).
          mainAxisAlignment: MainAxisAlignment.center, // Centers the column vertically.
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: cardDark, shape: BoxShape.circle, border: Border.all(color: borderDark)),
              child: SizedBox( // Defines a fixed size for the image.
                width: 120, height: 120, 
                child: Image.asset('assets/icon.png', // Loads the app icon.
                fit: BoxFit.contain, // Adjusts the image maintaining its proportions.
                errorBuilder: (c, e, s) => const Icon(Icons.monitor_heart, size: 80, color: accentBlue) // If the image fails to load, shows this alternative icon.
              )),
            ), 
            const SizedBox(height: 32), // 32 pixels spacing.
            const CircularProgressIndicator(color: accentBlue) // Shows the modern blue loading spinner.
          ]
        )
      )
    );
  }
}

// --- LOCK SCREEN (BIOMETRICS) ---
class LockScreen extends StatefulWidget { // Stateful widget to manage authentication state.
  const LockScreen({super.key});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  @override
  void initState() { 
    super.initState(); 
    _authenticate(); // Calls biometric authentication as soon as the screen opens.
  }

  Future<void> _authenticate() async { // Asynchronous authentication function.
    bool authenticated = false; // Variable to store the biometrics result.
    try { 
      // Asks the user to use fingerprint/FaceID with a custom message.
      authenticated = await biometricAuth.authenticate(localizedReason: 'Please authenticate to access your health data.'); 
    } catch (e) { 
      debugPrint("Biometric Error: $e"); // Catches and prints failures in the biometric sensor.
    }
    
    // If authentication was successful and the page is still active, proceeds to the main app.
    if (authenticated && mounted) { 
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigator())); 
    }
  }

  @override
  Widget build(BuildContext context) { // Lock screen interface.
    return Scaffold(
      backgroundColor: bgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: cardDark, shape: BoxShape.circle, border: Border.all(color: borderDark)),
              child: const Icon(Icons.lock_outline, size: 60, color: accentBlue) // Padlock icon.
            ),
            const SizedBox(height: 24), 
            const Text('🔒 App Locked', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textMain)), // Main title.
            const SizedBox(height: 8), 
            Text('Biometric protection enabled.', style: TextStyle(color: textMuted)), // Subtitle.
            const SizedBox(height: 32), 
            ElevatedButton.icon( // Button to try biometrics again if it failed.
              onPressed: _authenticate, 
              icon: const Icon(Icons.fingerprint), // Fingerprint icon.
              label: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.w600)), 
              style: ElevatedButton.styleFrom(backgroundColor: accentBlue, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))) // Button style and padding.
            )
          ]
        )
      )
    );
  }
}

// --- ONBOARDING SCREEN ---
class OnboardingScreen extends StatefulWidget { // Stateful widget because we need to control the current tutorial page.
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(); // Controller to manage swipes between pages.
  int _currentPage = 0; // Stores the current page index (0, 1, or 2).

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea( // Ensures content doesn't overlap the notch or status bar.
        child: Column(
          children: [
            Expanded( // Makes the PageView take up all available vertical space.
              child: PageView(
                controller: _pageController, // Assigns the controller defined above.
                onPageChanged: (i) => setState(() => _currentPage = i), // Updates the '_currentPage' state when the user swipes.
                children: [ // Creates the 3 tutorial pages calling the _buildPage helper function.
                  _buildPage(Icons.health_and_safety_outlined, '💙 Welcome to SmartGlycoAI', 'Your smart assistant for diabetes management.'), 
                  _buildPage(Icons.camera_alt_outlined, '📸 AI Calculation', 'Take a picture of your meal and our AI will suggest the exact insulin dose.'), 
                  _buildPage(Icons.notifications_active_outlined, '🚨 Crisis Prevention', 'Predictive warnings before a hypoglycemia occurs.')
                ]
              )
            ), 
            Padding( // Footer with dots (indicators) and button.
              padding: const EdgeInsets.all(24.0), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spaces dots to the left and button to the right.
                children: [
                  Row( // Generates the 3 page indicator dots.
                    children: List.generate(3, (index) => Container(
                      margin: const EdgeInsets.only(right: 8), 
                      height: 8, 
                      width: _currentPage == index ? 24 : 8, // If it's the current page, it gets wider.
                      decoration: BoxDecoration(
                        color: _currentPage == index ? accentBlue : borderDark, // Changes the active page color.
                        borderRadius: BorderRadius.circular(4) // Rounds the corners of the dots.
                      )
                    ))
                  ), 
                  ElevatedButton( // 'Next' or 'Start' button.
                    onPressed: () { 
                      if (_currentPage == 2) { // If on the last page (index 2):
                        isFirstTime = false; // Marks that the user has seen the tutorial.
                        saveData(); // Saves this information.
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())); // Proceeds to Login.
                      } else { 
                        // If not the last, animates transition to the next page.
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn); 
                      } 
                    }, 
                    style: ElevatedButton.styleFrom(backgroundColor: accentBlue, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
                    child: Text(_currentPage == 2 ? 'Start' : 'Next', style: const TextStyle(fontWeight: FontWeight.w600)) // Changes text depending on the current page.
                  )
                ]
              )
            )
          ]
        )
      )
    );
  }

  // Helper function to build the layout of each tutorial page without repeating code.
  Widget _buildPage(IconData icon, String title, String desc) { 
    return Padding(
      padding: const EdgeInsets.all(40.0), 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: cardDark, shape: BoxShape.circle, border: Border.all(color: borderDark)),
            child: Icon(icon, size: 80, color: accentBlue) // Shows the icon passed as an argument.
          ),
          const SizedBox(height: 40), 
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textMain)), // Shows the title.
          const SizedBox(height: 16), 
          Text(desc, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: textMuted)) // Shows the description.
        ]
      )
    ); 
  }
}

// --- LOGIN SCREEN ---
class LoginScreen extends StatelessWidget { // Stateless widget because it doesn't change interface based on internal state (only inputs).
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Padding( // Adds padding all around.
          padding: const EdgeInsets.all(24.0), 
          child: Column( // Organizes elements vertically.
            mainAxisAlignment: MainAxisAlignment.center, // Centers vertically.
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretches elements horizontally to take full width.
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cardDark, shape: BoxShape.circle, border: Border.all(color: borderDark)),
                  child: const Icon(Icons.monitor_heart, size: 60, color: accentBlue) // Simple logo.
                ),
              ),
              const SizedBox(height: 24), 
              const Text('Welcome Back', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textMain)), // Form title.
              const SizedBox(height: 32), 
              TextField( // Text field for Email.
                style: const TextStyle(color: textMain),
                decoration: InputDecoration(
                  labelText: 'Email', labelStyle: TextStyle(color: textMuted),
                  prefixIcon: Icon(Icons.email_outlined, color: textMuted),
                  filled: true, fillColor: cardDark,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderDark)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: accentBlue))
                )
              ), 
              const SizedBox(height: 16), 
              TextField( // Text field for Password.
                obscureText: true, // Hides typed text (as a password).
                style: const TextStyle(color: textMain),
                decoration: InputDecoration(
                  labelText: 'Password', labelStyle: TextStyle(color: textMuted),
                  prefixIcon: Icon(Icons.lock_outline, color: textMuted),
                  filled: true, fillColor: cardDark,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderDark)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: accentBlue))
                )
              ), 
              const SizedBox(height: 24), 
              ElevatedButton( // Login button by email/password.
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: accentBlue, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
                onPressed: () { 
                  isLoggedIn = true; // Updates global variable saying there is an active login. (NOTE: mocked logic, in production validate with backend)
                  saveData(); // Saves the login state locally.
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigator())); // Navigates to the app.
                }, 
                child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
              ), 
              const SizedBox(height: 16), 
              OutlinedButton.icon( // Google login button.
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: borderDark), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), 
                onPressed: () { 
                  isLoggedIn = true; // Also simulates Google login.
                  saveData(); 
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigator()));
                }, 
                icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 28), // G icon.
                label: const Text('Sign in with Google', style: TextStyle(color: textMain, fontWeight: FontWeight.w600))
              )
            ]
          )
        )
      )
    );
  }
}