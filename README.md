<div align="center">

# 🧬 SmartGlycoAI 📱

**Cross-Platform Clinical Decision Support & Type 1 Diabetes Management Application**  
*Aplicação Multiplataforma de Apoio à Decisão Clínica e Gestão da Diabetes Tipo 1*

<p>
  <a href="https://smartglycoai.vercel.app/">
    <img src="https://img.shields.io/badge/Web%20Portal-smartglycoai.vercel.app-0070f3?style=for-the-badge&logo=vercel&logoColor=white" alt="Web Portal" />
  </a>
  <img src="https://img.shields.io/badge/Flutter-Cross--Platform-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Firebase-Cloud%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Android-API%2026%2B%20(SDK%2036)-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/iOS-Swift%20%2F%20Xcode-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS" />
  <img src="https://img.shields.io/badge/Gradle-9.5.0%20KTS-02303A?style=for-the-badge&logo=gradle&logoColor=white" alt="Gradle" />
</p>

<p>
  <b>🌐 Language / Idioma:</b><br/>
  <a href="#english"><b>🇬🇧 English Version</b></a> &nbsp;|&nbsp; <a href="#portugues"><b>🇵🇹 Versão em Português</b></a>
</p>

</div>

---

<a id="english"></a>
## 🇬🇧 English Documentation

### 📖 Table of Contents
1. [Project Overview & Vision](#en-overview)
2. [Core Features & Modules](#en-features)
3. [Test Accounts & Evaluation Walkthrough](#en-test-accounts)
4. [System Architecture & Data Flow](#en-architecture)
5. [Firebase Cloud Firestore Schema](#en-database)
6. [Tech Stack & Build Compatibility Matrix](#en-tech-stack)
7. [Repository Structure](#en-structure)
8. [Prerequisites & Environment Setup](#en-prerequisites)
9. [Build, Run & Physical Device Deployment](#en-build-run)
10. [Troubleshooting Guide](#en-troubleshooting)
11. [Roadmap & Future Work](#en-roadmap)
12. [Academic Context & Medical Disclaimer](#en-disclaimer)

---

<a id="en-overview"></a>
### 🎯 1. Project Overview & Vision

**SmartGlycoAI** is a cross-platform mobile application built with **Flutter** designed to modernize **Type 1 Diabetes** self-management and doctor–patient collaboration. Managing Type 1 Diabetes requires continuous synchronization between glycemic trends, carbohydrate estimation, insulin therapy adjustments, and clinical follow-up.

SmartGlycoAI bridges this gap through a unified, role-based ecosystem:
- **For Patients:** Streamlines daily glucose tracking, multi-timeframe analytics, barcode nutritional lookup, meal photo capture, and direct clinical communication.
- **For Healthcare Professionals:** Provides a real-time clinical dashboard synced with **Firebase Cloud Firestore** to monitor patients, manage and reschedule appointments instantaneously, and communicate securely.

🌐 **Companion Web Portal:** [https://smartglycoai.vercel.app/](https://smartglycoai.vercel.app/)

---

<a id="en-features"></a>
### ✨ 2. Core Features & Modules

#### 🔐 Role-Based Access Control (RBAC)
- Simulated multi-role authentication engine that dynamically routes users to tailored interfaces (**Doctor Dashboard** vs. **Patient Workspace**) based on credentials or quick-login aliases.

#### 🩺 Clinical Module (Doctor View)
- **Real-Time Appointment Management:** Powered by Cloud Firestore `StreamBuilder`, reflecting schedule updates instantaneously across clients.
- **Interactive Rescheduling Bottom Sheet:** Allows doctors to select new dates and time slots with immediate cloud persistence (`date` and `time` updates) and visual feedback via top snackbar notifications.
- **Patient Overview & Clinical Follow-Up:** Quick access to patient summaries, consultation status (`isCompleted`), and consultation type.
- **Clinical Chat Interface:** Dedicated messaging channel for doctor–patient communication.

#### 📊 Patient Module & Analytics
- **Multi-Timeframe Glucose Charts:** Dedicated interactive chart views supporting **1-Day**, **3-Day**, and **1-Month** glycemic trend analysis with a clean, high-contrast dark UI.
- **Glucose & Meal Diary:** Daily logging workflow for blood sugar measurements and meals.
- **Bidirectional Messaging:** Direct access to the assigned physician for therapy feedback and questions.

#### 📷 Computer Vision & Nutritional Scanning
- **Meal Photo Capture:** Native Android CameraX integration (`camera_android_camerax`) with proper lifecycle management (`init`/`dispose`) for meal capture and carbohydrate estimation workflows.
- **Barcode Scanner:** Fast nutritional product scanning (`mobile_scanner` / `simple_barcode_scanner`) integrated with the **OpenFoodFacts** database.

#### 📱 Native OS & Hardware Integrations
- **Health Data Aggregation:** Integration with **Android Health Connect** and **Apple Health** via the `health` plugin.
- **Biometric Security:** Local device authentication (`local_auth`) for fingerprint / Face ID access protection.
- **Home Screen Widgets & Background Jobs:** Quick-glance widgets (`home_widget`) and periodic background execution (`workmanager`).
- **System Utilities:** Granular runtime permissions (`permission_handler`), native splash screens (`flutter_native_splash`), local persistence (`shared_preferences`), and content sharing (`share_plus`).

---

<a id="en-test-accounts"></a>
### 🔑 3. Test Accounts & Evaluation Walkthrough

To facilitate testing, grading, and demonstration of Role-Based Access Control (RBAC), the app includes pre-configured test accounts. All accounts use the same password (`1234`):

| Role | Full Name | Email | Quick Login Alias | Password | Routed Interface |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Doctor** | Dra. Joana Silvia | `joana@smartglyco.pt` | `medica` | `1234` | Clinical Dashboard (`doctor_dashboard.dart`) |
| **Patient** | João Antunes | `joao@smartglyco.pt` | `joao` | `1234` | Patient Workspace & Charts |
| **Patient** | Maria Silva | `maria@smartglyco.pt` | `maria` | `1234` | Patient Workspace & Charts |

#### 🧪 Suggested QA Test Scenarios
1. **Test Doctor Real-Time Cloud Sync:**
   - Log in with `medica` (or `joana@smartglyco.pt`) and password `1234`.
   - Open the appointments list showing **João Antunes** and **Maria Silva** fetched live from Cloud Firestore.
   - Tap an appointment card to open the rescheduling Bottom Sheet, choose a new date and time, and tap **Confirm Appointment**.
   - Verify the confirmation banner appears and the updated `date` / `time` reflects immediately in the UI and Firebase Console.
2. **Test Patient Interface & Analytics:**
   - Log in with `joao` (or `maria`) and password `1234`.
   - Navigate through the bottom bar to inspect the **1-Day / 3-Day / 1-Month** glucose charts.
   - Test the barcode scanner against any packaged food product (OpenFoodFacts lookup) and test meal photo capture.

> **Note:** These test credentials are intentionally documented in this repository exclusively for academic evaluation, usability testing, and QA.

---

<a id="en-architecture"></a>
### 🏗️ 4. System Architecture & Data Flow

```mermaid
flowchart TB
    subgraph Client["📱 SmartGlycoAI Mobile App (Flutter / Dart)"]
        Auth["🔐 RBAC Auth Router"]
        DocUI["🩺 Doctor Dashboard & Chat"]
        PatUI["📊 Patient Workspace, Charts & Diary"]
        Cam["📷 CameraX & Barcode Scanner"]
        Native["⚙️ Native Layer (Kotlin / Swift)"]
    end

    subgraph Cloud["☁️ Cloud & External APIs"]
        Firestore[("🔥 Firebase Cloud Firestore\n(Real-Time Sync)")]
        OFF["🥗 OpenFoodFacts API\n(Nutritional Data)"]
    end

    subgraph Device["📲 Device OS Services"]
        Health["❤️ Health Connect / Apple Health"]
        Bio["🔒 Biometrics & Secure Storage"]
    end

    Auth -->|Doctor Role| DocUI
    Auth -->|Patient Role| PatUI
    DocUI <-->|StreamBuilder / Real-Time CRUD| Firestore
    PatUI <-->|Sync & Messaging| Firestore
    PatUI --> Cam
    Cam -->|Barcode Lookup| OFF
    Client --> Native
    Native <--> Health
    Native <--> Bio
```

---

<a id="en-database"></a>
### 🔥 5. Firebase Cloud Firestore Schema

#### Collection: `appointments`
Stores real-time clinical consultation records synced directly with `doctor_dashboard.dart`.

**Document IDs:** `joao_antunes`, `maria_silva`

```json
{
  "patientName": "João Antunes",
  "initials": "JA",
  "date": "17/11/2026",
  "time": "9:30 AM",
  "type": "Revisão Mensal (Remarcada)",
  "isCompleted": false
}
```

| Field | Data Type | Format / Example | Description |
| :--- | :--- | :--- | :--- |
| `patientName` | `string` | `"João Antunes"` | Full display name of the patient |
| `initials` | `string` | `"JA"` | Avatar badge initials |
| `date` | `string` | `"17/11/2026"` | Scheduled date formatted as `DD/MM/YYYY` |
| `time` | `string` | `"9:30 AM"` | Scheduled consultation time slot |
| `type` | `string` | `"Ajuste de Insulina"` | Clinical reason / appointment category |
| `isCompleted` | `boolean` | `false` | Completion status flag |

#### Planned Subcollection: `chats/{patientId}/messages`
Designed for persistent bidirectional real-time messaging between doctor and patient:
- `senderId` (`string`), `senderRole` (`"doctor"` | `"patient"`), `text` (`string`), `timestamp` (`FieldValue.serverTimestamp()`).

---

<a id="en-tech-stack"></a>
### 🛠️ 6. Tech Stack & Build Compatibility Matrix

| Layer | Technology / Specification | Version / Target |
| :--- | :--- | :--- |
| **UI Framework** | Flutter | Latest Stable |
| **Primary Language** | Dart | 3.x |
| **Android Native** | Kotlin + Kotlin DSL (`.kts`) | Kotlin `2.4.x` |
| **iOS Native** | Swift + CocoaPods / Xcode | iOS 13+ |
| **Cloud Backend** | Firebase Core & Cloud Firestore | Real-Time NoSQL |
| **Java Runtime (Build)** | OpenJDK / Oracle JDK | **JDK 21** (`jvmToolchain(21)`) |
| **Gradle Wrapper** | Gradle | **9.5.0** |
| **Android Gradle Plugin** | AGP | **9.1.1+** (recommended `9.3.1`) |
| **Android SDK Targets** | `compileSdk` / `targetSdk` / `minSdk` | **36** / **36** / **26** |
| **Desugaring** | `com.android.tools:desugar_jdk_libs` | **2.1.5** |
| **Package Identifier** | Android `applicationId` / `namespace` | `com.example.smart_glyco_ai` |

> **Why `minSdk = 26` and `compileSdk = 36`?**  
> The `health` plugin strictly requires Android API 26 (Android 8.0) as the minimum SDK, while modern Flutter plugins (`camera_android_camerax`, `mobile_scanner`, `local_auth_android`, `device_info_plus`, `share_plus`, etc.) require compiling against Android SDK 36.

---

<a id="en-structure"></a>
### 📂 7. Repository Structure

```text
IPM-6-APP/
├── lib/                                # Core Flutter / Dart source code
│   ├── main.dart                       # Application entry point & Firebase init
│   ├── screens/                        # Role-based UI screens
│   │   ├── doctor_dashboard.dart       # Real-time Firestore clinical dashboard
│   │   ├── doctor_chat_screen.dart     # Clinical messaging interface
│   │   └── ...                         # Auth, Patient Home, Charts, Scanner
│   └── ...
├── android/                            # Android Native Module (Kotlin DSL)
│   ├── app/
│   │   ├── build.gradle.kts            # SDK 36, minSdk 26, JDK 21, Desugaring
│   │   ├── google-services.json        # Firebase Android config (local/env)
│   │   └── src/
│   │       ├── debug/AndroidManifest.xml
│   │       ├── main/
│   │       │   ├── AndroidManifest.xml # Hardware, Camera & Health permissions
│   │       │   ├── kotlin/.../MainActivity.kt
│   │       │   └── res/                # Drawables, Mipmaps, Night/v31 Styles
│   │       └── profile/AndroidManifest.xml
│   ├── gradle/wrapper/
│   │   └── gradle-wrapper.properties   # Gradle 9.5.0 distribution URL
│   ├── build.gradle.kts                # Root Gradle build script
│   └── settings.gradle(.kts)           # Flutter plugin loader, AGP & KGP
├── ios/                                # iOS Native Module (Xcode / Swift)
│   ├── Runner.xcodeproj / .xcworkspace # Xcode project & CocoaPods workspace
│   ├── Runner/
│   │   ├── AppDelegate.swift           # Swift lifecycle entry point
│   │   ├── Assets.xcassets/            # AppIcons (20px–1024px) & LaunchImages
│   │   └── GoogleService-Info.plist    # Firebase iOS config
│   └── Flutter/                        # Debug.xcconfig, Release.xcconfig
├── analysis_options.yaml               # Strict Dart static analysis & linting
├── devtools_options.yaml               # Flutter DevTools profiling config
├── pubspec.yaml                        # Dart dependencies & asset registry
└── README.md                           # Project documentation
```

---

<a id="en-prerequisites"></a>
### ⚙️ 8. Prerequisites & Environment Setup

Before building the project locally, ensure your development machine meets the following requirements:

1. **Flutter SDK:** Installed and verified via `flutter doctor` with no critical errors.
2. **Java Development Kit (JDK 21):** Required to match `jvmToolchain(21)` and Gradle 9.5.0.
   - Verify or explicitly point Flutter to JDK 21:
     ```bash
     flutter config --jdk-dir="C:\Program Files\Java\jdk-21.0.12"
     ```
3. **Android Studio & SDKs:**
   - Install **Android SDK Platform 36** and Android SDK Build-Tools.
   - Use an Android Emulator or physical device running **Android 8.0 (API 26) or higher**.
4. **Xcode (macOS only):** Required for iOS compilation, CocoaPods, and device signing.
5. **Firebase Configuration Files:**
   - Ensure `android/app/google-services.json` (Android) and `ios/Runner/GoogleService-Info.plist` (iOS) are present and connected to the Firebase Firestore project.

---

<a id="en-build-run"></a>
### 🚀 9. Build, Run & Physical Device Deployment

Run these commands from the **root directory** of the project:

```bash
# 1. Clean previous build artifacts (recommended after config changes)
flutter clean

# 2. Fetch all Flutter & Dart dependencies
flutter pub get

# 3. Run in debug mode on a connected emulator or physical device
flutter run

# 4. Build a Debug APK (fast build for direct device testing)
flutter build apk --debug

# 5. Build an optimized Release APK (ready for distribution)
flutter build apk --release

# 6. Build a Release IPA for iOS (macOS only)
flutter build ipa --release
```

📦 **Output APK Path:** `build/app/outputs/flutter-apk/app-release.apk` (or `app-debug.apk`).

#### 📱 Deploying to a Physical Android Device (e.g., Xiaomi / MIUI / HyperOS)
1. Enable **Developer Options** (*Settings → About Phone → Tap OS/MIUI Version 7 times*).
2. Enable **USB Debugging** and **Install via USB** (*Note: On Xiaomi devices, disable "Verify apps over USB" or enable "USB Debugging (Security settings)" to prevent `INSTALL_FAILED_USER_RESTRICTED`*).
3. Connect via USB, verify detection with `flutter devices`, and run `flutter run` (or transfer the generated `.apk` manually).

#### 🍏 Deploying to a Physical iPhone (macOS + Xcode)
1. Open **`ios/Runner.xcworkspace`** in Xcode (do not open `.xcodeproj`).
2. Select the **Runner** target → **Signing & Capabilities** → select your **Apple ID Team**.
3. On the iPhone, enable **Developer Mode** (*Settings → Privacy & Security → Developer Mode*).
4. Run `flutter run` from the project root and trust the developer certificate under *Settings → General → VPN & Device Management*.

---

<a id="en-troubleshooting"></a>
### 🩹 10. Troubleshooting Guide

| Issue / Error Message | Root Cause | Solution |
| :--- | :--- | :--- |
| `Java version 25.x is incompatible with Gradle` or `Cannot find Java installation matching languageVersion=21` | System `JAVA_HOME` points to an unsupported JDK version. | Point Flutter explicitly to JDK 21: `flutter config --jdk-dir="<path-to-jdk-21>"` and run `flutter clean`. |
| `Timeout waiting to lock build logic queue (buildLogic.lock)` | A previous Gradle daemon hung and kept the lock file open. | Stop stuck daemons: `cd android && ./gradlew --stop && cd ..` then re-run. |
| `Manifest merger failed: minSdkVersion cannot be smaller than 26 declared in [:health]` | `minSdk` in `android/app/build.gradle.kts` is set below 26. | Set `minSdk = 26` inside `defaultConfig` in `android/app/build.gradle.kts`. |
| `Missing local.properties` / Red import underlines in IDE | Dependencies not fetched or SDK path not regenerated after clone. | Run `flutter pub get` and restart the Dart Analysis Server. |
| `Warning: Your app uses plugins that apply Kotlin Gradle Plugin (KGP)` | Upstream third-party Flutter plugins haven't migrated to Built-in Kotlin yet. | Non-blocking warning. Safe to ignore until plugin maintainers release updates (`flutter pub upgrade`). |

---

<a id="en-roadmap"></a>
### 🗺️ 11. Roadmap & Future Work

- [x] Role-Based Access Control (Doctor & Patient flows)
- [x] Interactive Glucose Analytics (1D / 3D / 1M views)
- [x] CameraX Meal Capture & OpenFoodFacts Barcode Scanner
- [x] Firebase Cloud Firestore Real-Time Appointments & Rescheduling (`date` + `time`)
- [x] Android SDK 36 / Gradle 9.5.0 / JDK 21 Modernization
- [ ] Full Cloud Firestore Real-Time Chat Persistence (`chats/{patientId}/messages`)
- [ ] Bluetooth CGM (Continuous Glucose Monitor) Live Streaming Integration
- [ ] Computer Vision ML Model for Automated Carbohydrate & Bolus Estimation
- [ ] Production Firebase Authentication & Granular Firestore Security Rules

---

<a id="en-disclaimer"></a>
### 🎓 12. Academic Context & Medical Disclaimer

Developed as part of the **Human-Computer Interaction (IPM — Group 6)** academic project.

> ⚠️ **Medical Disclaimer:** SmartGlycoAI is an academic research and software engineering prototype. It is **not a certified medical device** and must **not** be used for real-world clinical diagnosis, insulin dosing, or medical treatment decisions.

---
---

<a id="portugues"></a>
## 🇵🇹 Documentação em Português

### 📖 Índice
1. [Visão Geral do Projeto](#pt-overview)
2. [Funcionalidades e Módulos Principais](#pt-features)
3. [Contas de Teste e Guião de Avaliação (QA)](#pt-test-accounts)
4. [Arquitetura do Sistema e Fluxo de Dados](#pt-architecture)
5. [Esquema da Base de Dados (Cloud Firestore)](#pt-database)
6. [Stack Tecnológica e Matriz de Compatibilidade](#pt-tech-stack)
7. [Estrutura do Repositório](#pt-structure)
8. [Pré-requisitos e Configuração do Ambiente](#pt-prerequisites)
9. [Compilação, Execução e Instalação em Dispositivos](#pt-build-run)
10. [Guia de Resolução de Problemas (Troubleshooting)](#pt-troubleshooting)
11. [Roadmap e Trabalho Futuro](#pt-roadmap)
12. [Contexto Académico e Aviso Médico](#pt-disclaimer)

---

<a id="pt-overview"></a>
### 🎯 1. Visão Geral do Projeto

A **SmartGlycoAI** é uma aplicação móvel multiplataforma desenvolvida em **Flutter**, concebida para modernizar a autogestão da **Diabetes Tipo 1** e a colaboração em tempo real entre doentes e profissionais de saúde. A gestão da Diabetes Tipo 1 exige monitorização contínua da glicemia, estimativa rigorosa de hidratos de carbono, ajustes de terapêutica de insulina e acompanhamento clínico constante.

A aplicação responde a este desafio através de um ecossistema unificado baseado em perfis:
- **Para Pacientes:** Simplifica o registo diário de glicemia, análise gráfica por múltiplos períodos, leitura nutricional por código de barras, captura fotográfica de refeições e contacto direto com a equipa médica.
- **Para Profissionais de Saúde:** Disponibiliza um painel clínico sincronizado em tempo real com o **Firebase Cloud Firestore** para gerir consultas, remarcar datas/horas instantaneamente e acompanhar pacientes.

🌐 **Portal Web do Projeto:** [https://smartglycoai.vercel.app/](https://smartglycoai.vercel.app/)

---

<a id="pt-features"></a>
### ✨ 2. Funcionalidades e Módulos Principais

#### 🔐 Controlo de Acesso Baseado em Funções (RBAC)
- Motor de autenticação simulada multiperfil que encaminha dinamicamente cada utilizador para a respetiva interface (**Dashboard da Médica** ou **Área do Paciente**) através do email ou atalho de login.

#### 🩺 Módulo Clínico (Vista da Médica)
- **Gestão de Consultas em Tempo Real:** Alimentada por `StreamBuilder` ligado ao Cloud Firestore, refletindo alterações de agenda instantaneamente.
- **Remarcação Interativa (Bottom Sheet):** Permite selecionar novas datas e horários com gravação imediata na nuvem (atualização simultânea dos campos `date` e `time`) e confirmação visual via *Top SnackBar*.
- **Vista Geral de Pacientes:** Acesso rápido ao resumo de cada doente, tipo de consulta e estado de conclusão (`isCompleted`).
- **Chat Clínico:** Canal dedicado de mensagens entre médica e paciente.

#### 📊 Módulo do Paciente e Análise Glicémica
- **Gráficos Interativos de Glicemia:** Ecrã dedicado com visualização de tendências para **1 Dia**, **3 Dias** e **1 Mês** em interface moderna de alto contraste (tema escuro).
- **Diário de Glicemia e Refeições:** Registo diário de medições glicémicas e refeições.
- **Comunicação Bidirecional:** Acesso direto à médica assistente para esclarecimento de dúvidas e ajustes terapêuticos.

#### 📷 Visão Computacional e Leitura Nutricional
- **Captura de Refeições:** Integração nativa com Android CameraX (`camera_android_camerax`) com gestão controlada do ciclo de vida do controlador (`init`/`dispose`) para captura fotográfica de refeições.
- **Leitor de Códigos de Barras:** Leitura rápida de embalagens (`mobile_scanner` / `simple_barcode_scanner`) integrada com a API **OpenFoodFacts** para consulta de informação nutricional.

#### 📱 Integrações Nativas do Sistema e Hardware
- **Dados de Saúde:** Integração com **Android Health Connect** e **Apple Health** através do plugin `health`.
- **Segurança Biométrica:** Autenticação nativa no dispositivo (`local_auth`) via impressão digital ou Face ID.
- **Widgets e Tarefas em Segundo Plano:** Widgets no ecrã inicial (`home_widget`) e execução periódica em *background* (`workmanager`).
- **Utilitários Nativos:** Gestão granular de permissões (`permission_handler`), ecrã de arranque nativo (`flutter_native_splash`), armazenamento local (`shared_preferences`) e partilha de dados (`share_plus`).

---

<a id="pt-test-accounts"></a>
### 🔑 3. Contas de Teste e Guião de Avaliação (QA)

Para facilitar os testes, avaliação académica e demonstração do sistema RBAC, a aplicação inclui contas de teste pré-configuradas. Todas as contas utilizam a mesma palavra-passe (`1234`):

| Perfil | Nome Completo | Email | Atalho de Login | Password | Interface de Destino |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Médica** | Dra. Joana Silvia | `joana@smartglyco.pt` | `medica` | `1234` | Dashboard Clínico (`doctor_dashboard.dart`) |
| **Paciente** | João Antunes | `joao@smartglyco.pt` | `joao` | `1234` | Área do Paciente e Gráficos |
| **Paciente** | Maria Silva | `maria@smartglyco.pt` | `maria` | `1234` | Área do Paciente e Gráficos |

#### 🧪 Cenários de Teste Recomendados
1. **Testar Sincronização em Tempo Real (Perfil Médica):**
   - Iniciar sessão com `medica` (ou `joana@smartglyco.pt`) e password `1234`.
   - Confirmar que os cartões das consultas de **João Antunes** e **Maria Silva** carregam diretamente do Cloud Firestore.
   - Tocar num cartão de consulta para abrir o *Bottom Sheet* de remarcação, escolher uma nova data e hora e confirmar em **Confirm Appointment**.
   - Verificar o aparecimento da notificação de sucesso e a atualização imediata dos campos `date` e `time` na interface e na consola do Firebase.
2. **Testar Experiência e Gráficos (Perfil Paciente):**
   - Iniciar sessão com `joao` (ou `maria`) e password `1234`.
   - Navegar pela barra inferior para explorar os gráficos de glicemia de **1 Dia / 3 Dias / 1 Mês**.
   - Testar o leitor de códigos de barras num produto alimentar (consulta OpenFoodFacts) e a câmara para captura de refeições.

> **Nota:** Estas credenciais são disponibilizadas intencionalmente neste repositório exclusivamente para fins de teste, avaliação académica e demonstração.

---

<a id="pt-architecture"></a>
### 🏗️ 4. Arquitetura do Sistema e Fluxo de Dados

```mermaid
flowchart TB
    subgraph Client["📱 Aplicação Móvel SmartGlycoAI (Flutter / Dart)"]
        Auth["🔐 Router de Autenticação RBAC"]
        DocUI["🩺 Dashboard Clínico e Chat"]
        PatUI["📊 Área do Paciente, Gráficos e Diário"]
        Cam["📷 CameraX e Leitor de Códigos de Barras"]
        Native["⚙️ Camada Nativa (Kotlin / Swift)"]
    end

    subgraph Cloud["☁️ Cloud e APIs Externas"]
        Firestore[("🔥 Firebase Cloud Firestore\n(Sincronização em Tempo Real)")]
        OFF["🥗 API OpenFoodFacts\n(Informação Nutricional)"]
    end

    subgraph Device["📲 Serviços Nativos do Dispositivo"]
        Health["❤️ Health Connect / Apple Health"]
        Bio["🔒 Biometria e Armazenamento Local"]
    end

    Auth -->|Perfil Médica| DocUI
    Auth -->|Perfil Paciente| PatUI
    DocUI <-->|StreamBuilder / CRUD Tempo Real| Firestore
    PatUI <-->|Sincronização e Mensagens| Firestore
    PatUI --> Cam
    Cam -->|Consulta Nutricional| OFF
    Client --> Native
    Native <--> Health
    Native <--> Bio
```

---

<a id="pt-database"></a>
### 🔥 5. Esquema da Base de Dados (Cloud Firestore)

#### Coleção: `appointments`
Armazena as consultas clínicas em tempo real sincronizadas diretamente com o ficheiro `doctor_dashboard.dart`.

**IDs de Documentos:** `joao_antunes`, `maria_silva`

```json
{
  "patientName": "João Antunes",
  "initials": "JA",
  "date": "17/11/2026",
  "time": "9:30 AM",
  "type": "Revisão Mensal (Remarcada)",
  "isCompleted": false
}
```

| Campo | Tipo de Dados | Formato / Exemplo | Descrição |
| :--- | :--- | :--- | :--- |
| `patientName` | `string` | `"João Antunes"` | Nome completo do paciente |
| `initials` | `string` | `"JA"` | Iniciais apresentadas no avatar |
| `date` | `string` | `"17/11/2026"` | Data agendada no formato `DD/MM/YYYY` |
| `time` | `string` | `"9:30 AM"` | Hora marcada para a consulta |
| `type` | `string` | `"Ajuste de Insulina"` | Motivo clínico / tipologia da consulta |
| `isCompleted` | `boolean` | `false` | Indicador de conclusão da consulta |

#### Subcoleção Planeada: `chats/{patientId}/messages`
Estruturada para persistência de mensagens bidirecionais em tempo real entre médica e paciente:
- `senderId` (`string`), `senderRole` (`"doctor"` | `"patient"`), `text` (`string`), `timestamp` (`FieldValue.serverTimestamp()`).

---

<a id="pt-tech-stack"></a>
### 🛠️ 6. Stack Tecnológica e Matriz de Compatibilidade

| Camada | Tecnologia / Especificação | Versão / Alvo |
| :--- | :--- | :--- |
| **Framework UI** | Flutter | Última Estável |
| **Linguagem Principal** | Dart | 3.x |
| **Nativo Android** | Kotlin + Kotlin DSL (`.kts`) | Kotlin `2.4.x` |
| **Nativo iOS** | Swift + CocoaPods / Xcode | iOS 13+ |
| **Backend Cloud** | Firebase Core & Cloud Firestore | NoSQL em Tempo Real |
| **Java Runtime (Build)** | OpenJDK / Oracle JDK | **JDK 21** (`jvmToolchain(21)`) |
| **Gradle Wrapper** | Gradle | **9.5.0** |
| **Android Gradle Plugin** | AGP | **9.1.1+** (recomendado `9.3.1`) |
| **Android SDKs** | `compileSdk` / `targetSdk` / `minSdk` | **36** / **36** / **26** |
| **Desugaring** | `com.android.tools:desugar_jdk_libs` | **2.1.5** |
| **Identificador do Pacote** | Android `applicationId` / `namespace` | `com.example.smart_glyco_ai` |

> **Porquê `minSdk = 26` e `compileSdk = 36`?**  
> O plugin `health` exige obrigatoriamente a API Android 26 (Android 8.0) como versão mínima, enquanto os plugins mais recentes do ecossistema Flutter (`camera_android_camerax`, `mobile_scanner`, `local_auth_android`, `device_info_plus`, `share_plus`, entre outros) requerem compilação com o Android SDK 36.

---

<a id="pt-structure"></a>
### 📂 7. Estrutura do Repositório

```text
IPM-6-APP/
├── lib/                                # Código-fonte principal Flutter / Dart
│   ├── main.dart                       # Ponto de entrada e inicialização Firebase
│   ├── screens/                        # Ecrãs da aplicação por perfil
│   │   ├── doctor_dashboard.dart       # Dashboard clínico em tempo real (Firestore)
│   │   ├── doctor_chat_screen.dart     # Interface de chat clínico
│   │   └── ...                         # Login, Área do Paciente, Gráficos, Scanner
│   └── ...
├── android/                            # Módulo Nativo Android (Kotlin DSL)
│   ├── app/
│   │   ├── build.gradle.kts            # SDK 36, minSdk 26, JDK 21, Desugaring
│   │   ├── google-services.json        # Configuração Firebase Android
│   │   └── src/
│   │       ├── debug/AndroidManifest.xml
│   │       ├── main/
│   │       │   ├── AndroidManifest.xml # Permissões de Câmara, Saúde e Hardware
│   │       │   ├── kotlin/.../MainActivity.kt
│   │       │   └── res/                # Drawables, Mipmaps, Estilos Night/v31
│   │       └── profile/AndroidManifest.xml
│   ├── gradle/wrapper/
│   │   └── gradle-wrapper.properties   # URL de distribuição Gradle 9.5.0
│   ├── build.gradle.kts                # Script Gradle raiz
│   └── settings.gradle(.kts)           # Carregador Flutter, AGP e KGP
├── ios/                                # Módulo Nativo iOS (Xcode / Swift)
│   ├── Runner.xcodeproj / .xcworkspace # Projeto Xcode e Workspace CocoaPods
│   ├── Runner/
│   │   ├── AppDelegate.swift           # Ponto de entrada Swift
│   │   ├── Assets.xcassets/            # Ícones Apple (20px–1024px) e LaunchImages
│   │   └── GoogleService-Info.plist    # Configuração Firebase iOS
│   └── Flutter/                        # Debug.xcconfig, Release.xcconfig
├── analysis_options.yaml               # Regras estritas de análise estática Dart
├── devtools_options.yaml               # Configuração do Flutter DevTools
├── pubspec.yaml                        # Dependências Dart e registo de assets
└── README.md                           # Documentação do projeto
```

---

<a id="pt-prerequisites"></a>
### ⚙️ 8. Pré-requisitos e Configuração do Ambiente

Antes de compilar o projeto localmente, garanta que o ambiente cumpre os seguintes requisitos:

1. **Flutter SDK:** Instalado e validado com `flutter doctor` sem erros críticos.
2. **Java Development Kit (JDK 21):** Obrigatório para compatibilidade com `jvmToolchain(21)` e Gradle 9.5.0.
   - Para associar explicitamente o JDK 21 ao Flutter:
     ```bash
     flutter config --jdk-dir="C:\Program Files\Java\jdk-21.0.12"
     ```
3. **Android Studio e SDKs:**
   - Instalar **Android SDK Platform 36** e Android SDK Build-Tools.
   - Utilizar um emulador ou telemóvel Android com **Android 8.0 (API 26) ou superior**.
4. **Xcode (apenas macOS):** Necessário para compilação iOS, CocoaPods e assinatura digital.
5. **Ficheiros de Configuração Firebase:**
   - Garantir a presença dos ficheiros `android/app/google-services.json` (Android) e `ios/Runner/GoogleService-Info.plist` (iOS) associados ao projeto Firestore.

---

<a id="pt-build-run"></a>
### 🚀 9. Compilação, Execução e Instalação em Dispositivos

Execute os seguintes comandos na **pasta raiz** do projeto:

```bash
# 1. Limpar ficheiros temporários de builds anteriores (recomendado após alterações de config)
flutter clean

# 2. Descarregar todas as dependências Flutter / Dart
flutter pub get

# 3. Correr em modo debug no emulador ou telemóvel ligado por USB
flutter run

# 4. Gerar APK de Debug (compilação rápida para testes diretos)
flutter build apk --debug

# 5. Gerar APK de Release otimizado (pronto para distribuição)
flutter build apk --release

# 6. Gerar IPA de Release para iOS (apenas macOS)
flutter build ipa --release
```

📦 **Localização do APK gerado:** `build/app/outputs/flutter-apk/app-release.apk` (ou `app-debug.apk`).

#### 📱 Instalação num Telemóvel Android Físico (ex.: Xiaomi / MIUI / HyperOS)
1. Ativar as **Opções de Programador** (*Definições → Acerca do telefone → Tocar 7 vezes na versão do SO/MIUI*).
2. Ativar **Depuração USB** e **Instalar via USB** (*Nota: Em dispositivos Xiaomi, desativar "Verificar apps via USB" ou ativar "Depuração USB (Definições de segurança)" para evitar o erro `INSTALL_FAILED_USER_RESTRICTED`*).
3. Ligar por cabo USB, confirmar a deteção com `flutter devices` e executar `flutter run` (ou copiar o `.apk` gerado manualmente para o telemóvel).

#### 🍏 Instalação num iPhone Físico (macOS + Xcode)
1. Abrir **`ios/Runner.xcworkspace`** no Xcode (não abrir o `.xcodeproj`).
2. Selecionar o target **Runner** → **Signing & Capabilities** → associar a sua **Apple ID Team**.
3. No iPhone, ativar o **Modo de Programador** (*Definições → Privacidade e Segurança → Modo de Programador*).
4. Executar `flutter run` na raiz do projeto e confiar no certificado de programador em *Definições → Geral → VPN e Gestão de Dispositivos*.

---

<a id="pt-troubleshooting"></a>
### 🩹 10. Guia de Resolução de Problemas (Troubleshooting)

| Erro / Mensagem | Causa Raiz | Solução |
| :--- | :--- | :--- |
| `Java version 25.x is incompatible with Gradle` ou `Cannot find Java installation matching languageVersion=21` | A variável `JAVA_HOME` do sistema aponta para uma versão incompatível do JDK. | Configurar explicitamente o JDK 21 no Flutter: `flutter config --jdk-dir="<caminho-para-jdk-21>"` e correr `flutter clean`. |
| `Timeout waiting to lock build logic queue (buildLogic.lock)` | Um processo anterior do Gradle encravou e manteve o ficheiro bloqueado. | Encerrar os daemons ativos: `cd android && ./gradlew --stop && cd ..` e voltar a compilar. |
| `Manifest merger failed: minSdkVersion cannot be smaller than 26 declared in [:health]` | O valor de `minSdk` em `android/app/build.gradle.kts` está abaixo de 26. | Alterar para `minSdk = 26` dentro do bloco `defaultConfig` em `android/app/build.gradle.kts`. |
| `Missing local.properties` ou erros vermelhos nos imports no IDE | Dependências ainda não instaladas ou caminhos do SDK por gerar após clone. | Executar `flutter pub get` e reiniciar o servidor de análise Dart. |
| `Warning: Your app uses plugins that apply Kotlin Gradle Plugin (KGP)` | Plugins de terceiros ainda não foram migrados pelos autores para Built-in Kotlin. | Aviso não bloqueante. Pode ser ignorado em segurança até os pacotes lançarem atualizações (`flutter pub upgrade`). |

---

<a id="pt-roadmap"></a>
### 🗺️ 11. Roadmap e Trabalho Futuro

- [x] Controlo de Acesso Baseado em Funções (Fluxos de Médica e Paciente)
- [x] Análise Glicémica Interativa (Vistas de 1D / 3D / 1M)
- [x] Captura de Refeições com CameraX e Leitor de Códigos de Barras (OpenFoodFacts)
- [x] Consultas e Remarcação em Tempo Real com Firebase Cloud Firestore (`date` + `time`)
- [x] Modernização da Build Android (SDK 36 / Gradle 9.5.0 / JDK 21)
- [ ] Persistência Completa do Chat em Tempo Real no Cloud Firestore (`chats/{patientId}/messages`)
- [ ] Integração Bluetooth com Sensores CGM (Monitorização Contínua de Glicose)
- [ ] Modelo de Machine Learning / Visão Computacional para Estimativa Automática de Hidratos de Carbono e Bólus
- [ ] Firebase Authentication em Produção e Regras de Segurança Granulares no Firestore

---

<a id="pt-disclaimer"></a>
### 🎓 12. Contexto Académico e Aviso Médico

Desenvolvido no âmbito do projeto académico de **Interação Pessoa-Máquina (IPM — Grupo 6)**.

> ⚠️ **Aviso Médico:** A SmartGlycoAI é um protótipo académico de engenharia de software e investigação. **Não constitui um dispositivo médico certificado** e **não deve** ser utilizada para diagnóstico clínico real, cálculo de dosagem de insulina ou decisões terapêuticas.
