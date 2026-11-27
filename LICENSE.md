# 📜 SmartGlycoAI — Proprietary Academic Evaluation License

![License](https://img.shields.io/badge/License-Proprietary%20Academic%20Evaluation-b91c1c?style=for-the-badge)
![Rights](https://img.shields.io/badge/Copyright-All%20Rights%20Reserved-1e293b?style=for-the-badge)
![Medical Status](https://img.shields.io/badge/Medical%20Device-Not%20Certified%20(Prototype)-d97706?style=for-the-badge)
![Scope](https://img.shields.io/badge/Scope-IPM%202026%2F2027%20Evaluation%20Only-0f766e?style=for-the-badge)

**Copyright © 2026 SmartGlycoAI Team (Group 6 — NOVA School of Science and Technology / NOVA FCT).**  
**All Rights Reserved.**

> [!IMPORTANT]
> **Summary of License Terms (Non-Binding Overview)**  
> This repository contains proprietary software made available exclusively for academic grading and heuristic evaluation within the *Interação Pessoa-Máquina (IPM 2026/2027)* course. It is **not** open-source software.

| ✅ Permitted (Evaluation Only) | ℹ️ Conditions | ❌ Strictly Prohibited |
| :--- | :--- | :--- |
| Download and inspect source code | Retain copyright & license notices | Commercial or production use |
| Compile & install for course grading | Use solely within IPM 2026/2027 | Redistribution or sublicensing |
| Execute heuristic/usability evaluation | Use demo/simulated data only | Modification or derivative works |
| Capture screenshots for the IPM report | Respect third-party licenses | Clinical or real medical usage |

---

> [!CAUTION]
> **CRITICAL MEDICAL & CLINICAL DISCLAIMER**  
> **SmartGlycoAI is strictly an academic prototype.** It is **NOT** a certified medical device (including under EU MDR 2017/745, FDA regulations, or INFARMED guidelines) and has **NOT** undergone clinical validation.  
> All glucose values, CGM simulations, carbohydrate estimations, insulin bolus calculations (ICR/ISF/IOB), contextual tag adjustments, and predictive hypoglycemia alerts are **experimental and simulated**. Under no circumstances may this Software be used for real medical diagnosis, treatment decisions, or actual insulin dosing.

---

## 1. Definitions

For the purposes of this License Agreement ("License"):

- **"Authors" / "Copyright Holders"** refers collectively to the members of **Group 6 (SmartGlycoAI Team)** enrolled in *Interação Pessoa-Máquina (IPM 2026/2027)* at NOVA FCT.
- **"Software"** refers to all source code (Dart/Flutter, Swift, Kotlin, Gradle, web assets, and configuration scripts), compiled binaries (`.apk`, `.ipa`), UI/UX designs, visual assets, icons, architecture diagrams, and accompanying documentation contained in this repository.
- **"Authorized Evaluator"** refers exclusively to course instructors, teaching assistants, and peer student groups formally assigned to review or evaluate this project during the 2026/2027 academic term.
- **"Evaluation Period"** refers to the official academic assessment window for the IPM 2026/2027 course, including Stage 5 (Heuristic Evaluation) and final project grading.

---

## 2. Grant of Limited Academic Evaluation License

Subject to strict compliance with all terms and conditions of this License, the Copyright Holders hereby grant to each **Authorized Evaluator** a **non-exclusive, non-transferable, non-sublicensable, revocable, royalty-free limited license** during the Evaluation Period solely to:

1. **Access and Clone** the repository for code inspection and verification;
2. **Build, Install, and Execute** the Software on physical devices or emulators (Android, iOS, or Web) strictly to test its user interface, interaction flows, and functionality;
3. **Document Findings** by taking screenshots, screen recordings, or excerpts of the user interface strictly for inclusion in the official IPM Heuristic Evaluation Report and academic grading materials.

No other rights or licenses are granted, whether expressly, by implication, estoppel, or otherwise.

---

## 3. Restrictions and Prohibited Uses

Except as expressly authorized under **Section 2**, no individual, organization, or entity may, directly or indirectly:

1. **No Redistribution or Publication:** Copy, reproduce, distribute, publish, upload, mirror, sell, rent, lease, lend, or sublicense the Software (in whole or in part) in any public or private repository, app store, or medium.
2. **No Modifications or Derivative Works:** Modify, adapt, translate, fork for external use, rebrand, or create derivative works based on the Software, its codebase, or its UI/UX design system.
3. **No Commercial or Clinical Exploitation:** Use the Software, or any component thereof, for commercial gain, clinical deployment, healthcare delivery, patient monitoring, or any non-academic purpose.
4. **No Reverse Engineering or Extraction:** Decompile, disassemble, or extract proprietary assets, prompts, algorithms, or configuration files from compiled builds (`.apk` / `.ipa`) outside the scope of standard course evaluation.
5. **No Misuse of Backend & Credentials:** Attempt to access, tamper with, overload, or extract unauthorized data from connected Firebase (Firestore/FCM) instances, API endpoints, or external services (e.g., OpenFoodFacts).
6. **No Removal of Notices:** Remove, obscure, or alter any copyright notice, trademark, attribution, or medical disclaimer embedded in the Software or its documentation.

---

## 4. Intellectual Property and Ownership

All right, title, and interest in and to the Software—including without limitation all copyrights, database rights, trade secrets, interface layouts, visual design systems, branding ("SmartGlycoAI"), and documentation—remain the **sole and exclusive property of the Copyright Holders**.

Submitting an evaluation report, usability critique, bug report, or improvement suggestion during the IPM course does not transfer any ownership interest in the Software to the evaluator.

---

## 5. Medical, Clinical, and Regulatory Disclaimer

1. **Prototype Status:** The Software is designed exclusively to demonstrate Human-Computer Interaction (HCI) concepts, accessibility patterns, and decision-support interface flows for Type 1 Diabetes management.
2. **Simulated Calculations:** Any calculation displayed by the Software—including Insulin-to-Carb Ratio (ICR), Insulin Sensitivity Factor (ISF), Insulin on Board (IOB), contextual multipliers (e.g., *Sick/Stress* $+20\%$, *Post-Workout/Active* $-20\%$), safety thresholds ($\ge 15\text{ U}$ warnings), barcode nutrition lookups, or camera-based carbohydrate estimates—is illustrative and unverified for clinical accuracy.
3. **No Medical Advice:** Nothing in the Software constitutes medical advice, clinical guidance, or a substitute for professional medical judgment. Always consult a qualified endocrinologist or healthcare provider regarding diabetes management and insulin therapy.

---

## 6. Data Privacy, GDPR, and Demo Accounts

1. **Fictitious Data Only:** All bundled demo profiles (e.g., patient and clinician test accounts), glucose logs, diary records, and clinical chat threads are synthetic and intended solely for demonstration.
2. **Prohibition on Real Health Data (PHI):** Authorized Evaluators must **not** enter real personal health information, real patient identities, or sensitive personal data into the Software or its connected Firebase Firestore database.
3. **Local & Cloud Storage:** Testing the Software may store temporary session preferences locally on the test device and transmit demonstration messages or tokens to Firebase services solely to validate application functionality.

---

## 7. Third-Party Components and External Services

The Software incorporates open-source libraries, frameworks, and SDKs (including, but not limited to, Flutter, Dart, Firebase SDKs, `mobile_scanner`, `flutter_local_notifications`, and `workmanager`), as declared in `pubspec.yaml`, and queries external public APIs such as OpenFoodFacts.

- Each third-party component remains governed by its own respective open-source or service license.
- Nothing in this License limits your rights under, or grants rights that supersede, the terms of any applicable third-party license.

---

## 8. Disclaimer of Warranty

THE SOFTWARE IS PROVIDED **"AS IS"** AND **"AS AVAILABLE"**, WITH ALL FAULTS AND WITHOUT WARRANTY OF ANY KIND. TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THE COPYRIGHT HOLDERS EXPRESSLY DISCLAIM ALL WARRANTIES, WHETHER EXPRESS, IMPLIED, STATUTORY, OR OTHERWISE, INCLUDING WITHOUT LIMITATION IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, ACCURACY, CLINICAL SAFETY, RELIABILITY, QUIET ENJOYMENT, AND NON-INFRINGEMENT.

THE COPYRIGHT HOLDERS DO NOT WARRANT THAT THE SOFTWARE WILL BE ERROR-FREE, UNINTERRUPTED, SECURE, COMPATIBLE WITH ALL DEVICES, OR FREE OF DEFECTS.

---

## 9. Limitation of Liability

TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL THE AUTHORS, COPYRIGHT HOLDERS, OR THEIR ACADEMIC INSTITUTION BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, PUNITIVE, OR CONSEQUENTIAL DAMAGES WHATSOEVER—INCLUDING WITHOUT LIMITATION PERSONAL INJURY, BODILY HARM, MEDICAL COMPLICATIONS, HYPOGLYCEMIA, HYPERGLYCEMIA, LOSS OF DATA, DEVICE DAMAGE, OR LOSS OF PROFITS—ARISING OUT OF OR IN CONNECTION WITH THE USE, MISUSE, OR INABILITY TO USE THE SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

---

## 10. Term and Termination

1. **Automatic Expiration:** This License automatically terminates upon the conclusion of the IPM 2026/2027 academic evaluation and grading period.
2. **Termination for Breach:** Any use of the Software in violation of this License immediately and automatically terminates all rights granted hereunder without prior notice.
3. **Effect of Termination:** Upon termination, all copies of the Software, compiled binaries, and locally cloned repositories obtained solely for evaluation must cease to be used (except archived academic grading records required by university policy).
4. **Survival:** **Sections 3, 4, 5, 8, 9, and 11** shall survive any termination of this License.

---

## 11. Governing Law and Jurisdiction

This License shall be governed by and construed in accordance with the **laws of Portugal** and applicable **European Union** legislation, without regard to conflict-of-law principles. Any disputes arising under this License shall be subject to the exclusive jurisdiction of the competent courts of Lisbon, Portugal.

---

## 12. Contact & Licensing Inquiries

For questions regarding this License, academic verification, or requests for written permission beyond the scope granted herein, please contact the **SmartGlycoAI Team (Group 6)** through the project repository or official course channels.

---

*Last Updated: November 2026 — SmartGlycoAI (IPM 2026/2027, Group 6)*
