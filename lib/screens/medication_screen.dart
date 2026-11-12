import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import '../app_data.dart'; 

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final Color bgColor = const Color(0xFF090C10);
  final Color cardColor = const Color(0xFF141923);
  final Gradient neonGradient = const LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)], 
  );

  String _selectedTab = 'Today';

  // ATENÇÃO: Verifica se colou bem com os símbolos < e >
  final List _medications = [
    {
      'name': 'Metformin',
      'details': '500 mg • 1 tablet',
      'time': '8:00 AM',
      'icon': Icons.medication,
      'isTaken': false,
    },
    {
      'name': 'Insulin Glargine',
      'details': '10 U • Injection',
      'time': '9:00 PM',
      'icon': Icons.vaccines,
      'isTaken': false,
    },
    {
      'name': 'Vitamin D',
      'details': '1000 IU • 1 tablet',
      'time': '8:00 AM',
      'icon': Icons.medication,
      'isTaken': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    // 1. SINCRONIZAR ESTADO: Sempre que abres o ecrã, verifica se já tomaste hoje
    for (var i = 0; i < _medications.length; i++) {
      final medTitleToFind = '💊 ' + _medications[i]['name'].toString();
      
      // Procura no diário global se já existe um registo com este nome
      final hasBeenTaken = globalDiary.any((entry) => entry['title'] == medTitleToFind);
      
      _medications[i]['isTaken'] = hasBeenTaken;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            
            ...List.generate(_medications.length, (index) {
              return _buildMedicationCard(index);
            }),
            
            const SizedBox(height: 8),
            _buildNextDoseBanner(),
            const SizedBox(height: 16),
            _buildStatsGrid(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Medication', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.only(left: 32),
              child: Text('Stay on track', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: const Icon(Icons.settings_outlined, color: Colors.white54, size: 20),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    final tabs = ['Today', 'Week', 'Month'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: tabs.map((t) {
          final isSelected = _selectedTab == t;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = t;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? neonGradient : null,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isSelected
                      ? [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
                      : [],
                ),
                child: Center(
                  child: Text(
                    t,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
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

  Widget _buildMedicationCard(int index) {
    final med = _medications[index];
    final bool isTaken = med['isTaken'] == true;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact(); 
        
        bool willBeTaken = !isTaken; 
        
        setState(() {
          _medications[index]['isTaken'] = willBeTaken; 
        });

        final medTitle = '💊 ' + med['name'].toString();

        if (willBeTaken) {
          // 2. ADICIONAR AO DIÁRIO
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
              content: Text('${med['name']} adicionado ao diário!'),
              backgroundColor: const Color(0xFF00E676),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // 3. REMOVER DO DIÁRIO (Se o utilizador tirar o check)
          globalDiary.removeWhere((entry) => entry['title'] == medTitle);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${med['name']} removido do diário!'),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        
        // 4. GRAVAR NA BASE DE DADOS DO TELEMÓVEL (SharedPreferences)
        saveData(); 
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.2), Colors.transparent],
                  radius: 0.8,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Icon(med['icon'] as IconData?, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(med['name'].toString(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(med['details'].toString(), style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(med['time'].toString(), style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 13, fontWeight: FontWeight.bold)), 
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isTaken ? Icons.check_circle : Icons.add_circle_outline,
                  color: isTaken ? const Color(0xFF00E676) : Colors.white54,
                  size: 28, 
                ),
                const SizedBox(height: 4),
                Text(
                  isTaken ? 'Taken' : 'Upcoming',
                  style: TextStyle(
                    color: isTaken ? const Color(0xFF00E676) : Colors.white54,
                    fontSize: 12,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF4C1D95)], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.vaccines, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next dose', style: TextStyle(color: Colors.white70, fontSize: 13)),
                SizedBox(height: 4),
                Text('Insulin Glargine', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('9:00 PM', style: TextStyle(color: Colors.white, fontSize: 14)),
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
        Expanded(child: _statCard('Time in Range', '78', '%', valueColor: const Color(0xFF2DD4BF))),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Est. HbA1c', '6.8', '%')),
      ],
    );
  }

  Widget _statCard(String title, String value, String unit, {Color valueColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(color: valueColor, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(width: 2),
              Text(unit, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}