import 'package:flutter/material.dart'; // Importa o framework principal do Flutter para a interface gráfica (Material Design).
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Importa o pacote para gerir notificações locais no dispositivo.
import 'package:camera/camera.dart'; // Importa o pacote para aceder às câmaras do telemóvel.
import 'app_data.dart'; // Importa ficheiro do teu projeto (provavelmente variáveis globais e de estado).
import 'app_screens.dart'; // Importa ficheiro do teu projeto (com ecrãs adicionais como o MainNavigator).

// --- ECRÃ DE INÍCIO (SPLASH SCREEN) ---
class SplashScreen extends StatefulWidget { // Define o SplashScreen como um widget que possui estado (Stateful).
  const SplashScreen({super.key}); // Construtor padrão com uma chave opcional.
  @override
  State<SplashScreen> createState() => _SplashScreenState(); // Cria e liga a classe de estado a este widget.
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() { // Método executado apenas uma vez quando o widget é inicializado.
    super.initState(); // Chama a inicialização da classe mãe.
    _startAppEngines(); // Chama a função que vai preparar a aplicação.
  }

  Future<void> _startAppEngines() async { // Função assíncrona que prepara dependências antes de entrar na app.
    try {
      cameras = await availableCameras(); // Obtém a lista de câmaras disponíveis no dispositivo.
      await loadData(); // Função (provavelmente de app_data.dart) que carrega dados guardados (ex: shared_preferences).
      
      // Configuração inicial para notificações no Android.
      const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher'); 
      const InitializationSettings initSettings = InitializationSettings(android: androidInit); // Agrupa as definições.
      
      dynamic magicPlugin = notificationsPlugin; // Referência para o plugin de notificações (deve estar em app_data.dart).
      await magicPlugin.initialize(initSettings); // Inicializa o serviço de notificações.
    } catch (e) {
      debugPrint("Startup Error: $e"); // Se houver um erro, imprime-o na consola em vez de rebentar a app.
    }
    
    await Future.delayed(const Duration(seconds: 2)); // Cria uma pausa de 2 segundos para o logótipo ficar visível.
    
    if (mounted) { // Verifica se o widget ainda está ativo na árvore antes de navegar (evita crashes).
      // Lógica de roteamento baseada no estado do utilizador:
      if (isFirstTime) { 
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OnboardingScreen())); // 1ª vez: vai para o tutorial.
      } 
      else if (!isLoggedIn) { 
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())); // Não logado: vai para o Login.
      } 
      else {
        if (useBiometricsGlobal) { 
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LockScreen())); // Logado com biometria: pede impressão digital.
        } 
        else { 
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigator())); // Logado sem biometria: entra direto.
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) { // Constrói a interface visual do SplashScreen.
    return Scaffold( // Estrutura base de uma página Material.
      backgroundColor: Theme.of(context).colorScheme.surface, // Define a cor de fundo baseada no tema atual.
      body: Center( // Centra o conteúdo no ecrã.
        child: Column( // Coloca os elementos numa coluna (vertical).
          mainAxisAlignment: MainAxisAlignment.center, // Centra a coluna verticalmente.
          children: [
            SizedBox( // Define um tamanho fixo para a imagem.
              width: 200, height: 200, 
              child: Image.asset('assets/icon.png', // Carrega o ícone da app.
              fit: BoxFit.contain, // Ajusta a imagem mantendo as proporções.
              errorBuilder: (c, e, s) => const Icon(Icons.monitor_heart, size: 100, color: Colors.teal) // Se a imagem falhar, mostra este ícone alternativo.
            )), 
            const SizedBox(height: 24), // Espaçamento de 24 píxeis.
            const CircularProgressIndicator(color: Colors.teal) // Mostra a "rodinha" de carregamento verde-azulado.
          ]
        )
      )
    );
  }
}

// --- ECRÃ DE BLOQUEIO (BIOMETRIA) ---
class LockScreen extends StatefulWidget { // Widget Stateful para gerir o estado da autenticação.
  const LockScreen({super.key});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  @override
  void initState() { 
    super.initState(); 
    _authenticate(); // Chama a autenticação biométrica assim que o ecrã abre.
  }

  Future<void> _authenticate() async { // Função assíncrona de autenticação.
    bool authenticated = false; // Variável para guardar o resultado da biometria.
    try { 
      // Pede ao utilizador para usar a impressão digital/FaceID com uma mensagem personalizada.
      authenticated = await biometricAuth.authenticate(localizedReason: 'Por favor, autentique-se para aceder aos seus dados de saúde.'); 
    } catch (e) { 
      debugPrint("Biometric Error: $e"); // Captura e imprime falhas no sensor biométrico.
    }
    
    // Se a autenticação teve sucesso e a página ainda está ativa, avança para a app principal.
    if (authenticated && mounted) { 
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigator())); 
    }
  }

  @override
  Widget build(BuildContext context) { // Interface do ecrã de bloqueio.
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Icon(Icons.lock_outline, size: 100, color: Theme.of(context).colorScheme.primary), // Ícone de cadeado.
            const SizedBox(height: 24), 
            const Text('Aplicação Bloqueada', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), // Título principal.
            const SizedBox(height: 8), 
            const Text('Proteção biométrica ativada.'), // Subtítulo.
            const SizedBox(height: 32), 
            ElevatedButton.icon( // Botão para tentar a biometria novamente caso tenha falhado.
              onPressed: _authenticate, 
              icon: const Icon(Icons.fingerprint), // Ícone de impressão digital.
              label: const Text('Tentar Novamente'), 
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)) // Estilo e preenchimento do botão.
            )
          ]
        )
      )
    );
  }
}

// --- ECRÃ DE BOAS VINDAS (ONBOARDING) ---
class OnboardingScreen extends StatefulWidget { // Widget Stateful porque precisamos de controlar a página atual do tutorial.
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(); // Controlador para gerir os deslizes entre páginas (swipe).
  int _currentPage = 0; // Guarda o índice da página atual (0, 1 ou 2).

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // Garante que o conteúdo não se sobrepõe à notch ou barra de status.
        child: Column(
          children: [
            Expanded( // Faz o PageView ocupar todo o espaço disponível verticalmente.
              child: PageView(
                controller: _pageController, // Atribui o controlador definido acima.
                onPageChanged: (i) => setState(() => _currentPage = i), // Atualiza o estado da '_currentPage' quando o utilizador desliza.
                children: [ // Cria as 3 páginas do tutorial chamando a função auxiliar _buildPage.
                  _buildPage(Icons.health_and_safety, 'Bem-vindo ao SmartGlycoAI', 'O seu assistente inteligente para gestão da diabetes.'), 
                  _buildPage(Icons.camera_alt, 'Cálculo com Inteligência Artificial', 'Tire foto à sua refeição e a nossa IA sugere a dose exata de insulina.'), 
                  _buildPage(Icons.notifications_active, 'Prevenção de Crises', 'Avisos preditivos antes de uma hipoglicemia acontecer.')
                ]
              )
            ), 
            Padding( // Rodapé com os pontinhos (indicadores) e o botão.
              padding: const EdgeInsets.all(24.0), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espaça os pontinhos à esquerda e o botão à direita.
                children: [
                  Row( // Gera os 3 pontinhos indicadores de página.
                    children: List.generate(3, (index) => Container(
                      margin: const EdgeInsets.only(right: 8), 
                      height: 10, 
                      width: _currentPage == index ? 20 : 10, // Se for a página atual, fica mais largo.
                      decoration: BoxDecoration(
                        color: _currentPage == index ? Colors.teal : Theme.of(context).colorScheme.surfaceContainerHighest, // Muda a cor da página ativa.
                        borderRadius: BorderRadius.circular(5) // Arredonda os cantos dos pontinhos.
                      )
                    ))
                  ), 
                  ElevatedButton( // Botão 'Seguinte' ou 'Começar'.
                    onPressed: () { 
                      if (_currentPage == 2) { // Se estiver na última página (índice 2):
                        isFirstTime = false; // Marca que o utilizador já viu o tutorial.
                        saveData(); // Guarda essa informação.
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())); // Avança para o Login.
                      } else { 
                        // Se não for a última, anima a transição para a próxima página.
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn); 
                      } 
                    }, 
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white), 
                    child: Text(_currentPage == 2 ? 'Começar' : 'Seguinte') // Muda o texto dependendo da página em que está.
                  )
                ]
              )
            )
          ]
        )
      )
    );
  }

  // Função auxiliar para construir o layout de cada página do tutorial sem repetir código.
  Widget _buildPage(IconData icon, String title, String desc) { 
    return Padding(
      padding: const EdgeInsets.all(40.0), 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Icon(icon, size: 100, color: Colors.teal), // Mostra o ícone passado como argumento.
          const SizedBox(height: 40), 
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), // Mostra o título.
          const SizedBox(height: 16), 
          Text(desc, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant)) // Mostra a descrição.
        ]
      )
    ); 
  }
}

// --- ECRÃ DE LOGIN ---
class LoginScreen extends StatelessWidget { // Widget Stateless porque não altera a interface baseado no próprio estado interno (apenas inputs).
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding( // Adiciona margem a toda a volta.
          padding: const EdgeInsets.all(24.0), 
          child: Column( // Organiza os elementos verticalmente.
            mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente.
            crossAxisAlignment: CrossAxisAlignment.stretch, // Estica os elementos na horizontal para ocuparem a largura toda.
            children: [
              const Icon(Icons.monitor_heart, size: 80, color: Colors.teal), // Logótipo simples.
              const SizedBox(height: 24), 
              const Text('Entrar', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), // Título do formulário.
              const SizedBox(height: 32), 
              const TextField( // Campo de texto para o Email.
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email))
              ), 
              const SizedBox(height: 16), 
              const TextField( // Campo de texto para a Palavra-passe.
                obscureText: true, // Esconde o texto digitado (como password).
                decoration: InputDecoration(labelText: 'Palavra-passe', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock))
              ), 
              const SizedBox(height: 24), 
              ElevatedButton( // Botão de login por email/password.
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.teal, foregroundColor: Colors.white), 
                onPressed: () { 
                  isLoggedIn = true; // Atualiza a variável global dizendo que há um login ativo. (NOTA: lógica mockada, em produção deves validar com backend)
                  saveData(); // Guarda o estado do login localmente.
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigator())); // Navega para a app.
                }, 
                child: const Text('Entrar', style: TextStyle(fontSize: 16))
              ), 
              const SizedBox(height: 16), 
              OutlinedButton.icon( // Botão de login com a Google.
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), 
                onPressed: () { 
                  isLoggedIn = true; // Simula também o login com o Google.
                  saveData(); 
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigator()));
                }, 
                icon: const Icon(Icons.g_mobiledata, color: Colors.red), // Ícone do G.
                label: Text('Entrar com Google', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))
              )
            ]
          )
        )
      )
    );
  }
}