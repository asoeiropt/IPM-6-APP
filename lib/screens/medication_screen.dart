import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import '../app_data.dart'; // Importante para ler o isHighContrast

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  String _selectedTab = 'Today';

  // Base dos medicamentos diários
  final List _baseMedications = [
    {
      'name': 'Metformin',
      'details': '500 mg • 1 tablet',
      'time': '8:00 AM',
      'icon': Icons.medication,
    },
    {
      'name': 'Insulin Glargine',
      'details': '10 U • Injection',
      'time': '9:00 PM',
      'icon': Icons.vaccines,
    },
    {
      'name': 'Vitamin D',
      'details': '1000 IU • 1 tablet',
      'time': '8:00 AM',
      'icon': Icons.medication,
    },
  ];

  // Função para converter o número do dia da semana para Português
  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1: return 'Segunda';
      case 2: return 'Terça';
      case 3: return 'Quarta';
      case 4: return 'Quinta';
      case 5: return 'Sexta';
      case 6: return 'Sábado';
      case 7: return 'Domingo';
      default: return '';
    }
  }

  // --- O TRUQUE DE AGRUPAMENTO (UX/UI Heuristics) ---
  List<Widget> _buildGroupedMedications() {
    List<Widget> widgets = [];
    int days = _selectedTab == 'Week' ? 7 : (_selectedTab == 'Month' ? 30 : 1);
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      bool isPast = i > 0;
      
      // 1. CRIAR CABEÇALHO DO DIA (Apenas na Semana e Mês)
      if (_selectedTab != 'Today') {
        String headerTitle = '';
        if (i == 0) headerTitle = 'Hoje';
        else if (i == 1) headerTitle = 'Ontem';
        else if (_selectedTab == 'Week') {
          headerTitle = _getWeekdayName(date.weekday);
        } else {
          headerTitle = 'Dia ${date.day}';
        }

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 12, left: 8),
            child: Text(
              headerTitle,
              style: TextStyle(
                color: isHighContrast ? const Color(0xFFFFD600) : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }

      // 2. GERAR OS 3 CARTÕES DO DIA
      for (var med in _baseMedications) {
        bool isTaken = false;
        
        if (!isPast) {
          final medTitleToFind = '💊 ' + med['name'].toString();
          isTaken = globalDiary.any((entry) => entry['title'] == medTitleToFind);
        } else {
          isTaken = true; // No passado aparecem já com o "Check" a verde
        }

        // Criamos uma cópia dos dados para passar ao Widget
        final medData = Map<String, dynamic>.from(med);
        medData['isTaken'] = isTaken;
        medData['isPast'] = isPast;

        widgets.add(_buildMedicationCard(medData));
      }
      
      // Separador visual entre dias no histórico
      if (_selectedTab != 'Today' && i < days - 1) {
        widgets.add(Divider(color: Colors.white.withOpacity(0.05), height: 32, thickness: isHighContrast ? 2 : 1));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildTimeSelector(),
            const SizedBox(height: 24),
            
            // Renderiza as secções geradas de forma agrupada
            ..._buildGroupedMedications(),
            
            const SizedBox(height: 8),
            if (_selectedTab == 'Today') _buildNextDoseBanner(),
            const SizedBox(height: 16),
            _buildStatsGrid(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);
    final mainTextColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : const Color(0xFF64748B);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back_ios_new, color: mainTextColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Medication', style: TextStyle(color: mainTextColor, fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text('Stay on track', style: TextStyle(color: subTextColor, fontSize: 14)),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
          ),
          child: Icon(Icons.settings_outlined, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white54, size: 20),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    final tabs = ['Today', 'Week', 'Month'];
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: isHighContrast ? 2 : 0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: tabs.map((t) {
          final isSelected = _selectedTab == t;
          final neonGradient = const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)]);
          
          BoxDecoration? decoration;
          if (isSelected) {
            decoration = isHighContrast
                ? BoxDecoration(color: const Color(0xFFFFD600), borderRadius: BorderRadius.circular(24))
                : BoxDecoration(
                    gradient: neonGradient, 
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
                  );
          }

          final textColor = isSelected 
              ? (isHighContrast ? Colors.black : Colors.white) 
              : (isHighContrast ? Colors.white : Colors.white54);

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedTab = t;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: decoration,
                child: Center(
                  child: Text(
                    t,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> med) {
    final bool isTaken = med['isTaken'] == true;
    final bool isPast = med['isPast'] == true;

    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);
    final mainTextColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : Colors.white54;
    final timeColor = isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF2DD4BF);
    final statusColor = isHighContrast ? (isTaken ? const Color(0xFFFFD600) : Colors.white) : (isTaken ? const Color(0xFF00E676) : Colors.white54);

    return GestureDetector(
      onTap: () {
        // Bloquear edição do histórico para manter a integridade dos dados
        if (isPast) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Este registo é do passado e já está concluído.', style: TextStyle(color: isHighContrast ? Colors.black : Colors.white)),
              backgroundColor: isHighContrast ? const Color(0xFFFFD600) : Colors.orangeAccent,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }

        // Lógica para marcar/desmarcar medicação HOJE
        HapticFeedback.lightImpact(); 
        bool willBeTaken = !isTaken; 
        
        setState(() {
          med['isTaken'] = willBeTaken; 
        });

        final medTitle = '💊 ' + med['name'].toString();

        if (willBeTaken) {
          final now = DateTime.now();
          final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
          
          globalDiary.add({
            'title': medTitle,
            'carbs': 0.0,
            'insulin': 0.0, 
            'time': timeStr,
            'type': 'medication',
            'imagePath': null
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${med['name']} adicionado ao diário!', style: TextStyle(color: isHighContrast ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF00E676),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          globalDiary.removeWhere((entry) => entry['title'] == medTitle);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${med['name']} removido do diário!', style: TextStyle(color: isHighContrast ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        
        saveData(); 
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isHighContrast ? Colors.transparent : null,
                gradient: isHighContrast ? null : RadialGradient(
                  colors: [Colors.white.withOpacity(0.2), Colors.transparent],
                  radius: 0.8,
                ),
                border: Border.all(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.1), width: isHighContrast ? 2 : 1),
              ),
              child: Icon(med['icon'] as IconData?, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(med['name'].toString(), style: TextStyle(color: mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(med['details'].toString(), style: TextStyle(color: subTextColor, fontSize: 13)),
                  const SizedBox(height: 4),
                  // Limpamos o dateLabel daqui, agora usa-se só a hora
                  Text('${med['time']}', style: TextStyle(color: timeColor, fontSize: 13, fontWeight: FontWeight.bold)), 
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isTaken ? Icons.check_circle : Icons.add_circle_outline,
                  color: statusColor,
                  size: 28, 
                ),
                const SizedBox(height: 4),
                Text(
                  isTaken ? 'Taken' : 'Upcoming',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: isHighContrast ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNextDoseBanner() {
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.transparent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighContrast ? Colors.black : null,
        gradient: isHighContrast 
            ? null 
            : const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF4C1D95)], 
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: isHighContrast ? 2 : 0),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isHighContrast ? Colors.transparent : Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: isHighContrast ? Border.all(color: const Color(0xFFFFD600)) : null,
            ),
            child: Icon(Icons.vaccines, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next dose', style: TextStyle(color: isHighContrast ? Colors.white : Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text('Insulin Glargine', style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('9:00 PM', style: TextStyle(color: isHighContrast ? Colors.white : Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _statCard('Avg Glucose', '124', 'mg/dL')),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Time in Range', '78', '%', valueColor: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF2DD4BF))),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Est. HbA1c', '6.8', '%')),
      ],
    );
  }

  Widget _statCard(String title, String value, String unit, {Color? valueColor}) {
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);
    final textColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;

    final finalValueColor = valueColor ?? textColor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: isHighContrast ? Colors.white : Colors.white54, fontSize: 11)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(color: finalValueColor, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(width: 2),
              Text(unit, style: TextStyle(color: isHighContrast ? Colors.white : Colors.white54, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}