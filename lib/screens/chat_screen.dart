import 'package:flutter/material.dart';
import '../app_data.dart'; // Importante para aceder ao isHighContrast

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  var _messages = [
    {
      'text': 'Olá João! Analisei os teus dados da última semana. A tua glicose parece estável. Continua o excelente trabalho!',
      'isMe': false,
      'time': '09:12',
    },
    {
      'text': 'Muito obrigado! Tenho uma dúvida sobre a minha dose de insulina de manhã...',
      'isMe': true,
      'time': '09:20',
    },
    {
      'text': 'Claro! Terei todo o gosto em ajudar. Qual é a tua dose atual e como têm sido as leituras em jejum?',
      'isMe': false,
      'time': '09:24',
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isMe': true,
        'time': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      });
    });

    _messageController.clear();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE ALTO CONTRASTE ---
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final docBubbleColor = isHighContrast ? Colors.black : const Color(0xFF1A2130);
    final mainTextColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : Colors.white54;
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: mainTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chat Médico', style: TextStyle(color: mainTextColor, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Fala com a tua equipa clínica', style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.assignment_outlined, color: subTextColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDoctorHeader(cardColor, mainTextColor, subTextColor, borderColor),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['isMe'] == true; 
                
                return _buildMessageBubble(
                  text: message['text'].toString(),
                  time: message['time'].toString(),
                  isMe: isMe,
                  docBubbleColor: docBubbleColor,
                );
              },
            ),
          ),
          _buildMessageInput(cardColor, borderColor, mainTextColor),
        ],
      ),
    );
  }

  Widget _buildDoctorHeader(Color cardColor, Color mainTextColor, Color subTextColor, Color borderColor) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: isHighContrast ? 2 : 1),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: isHighContrast ? Colors.transparent : const Color(0xFF387A76),
                child: Icon(Icons.person, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, size: 28), 
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF00E676), 
                    shape: BoxShape.circle,
                    border: Border.all(color: cardColor, width: 2.5),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dra. Joana Sílvia', style: TextStyle(color: mainTextColor, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text('Endocrinologista', style: TextStyle(color: subTextColor, fontSize: 13)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.circle, color: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF00E676), size: 10),
                  const SizedBox(width: 4),
                  Text('Online', style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({required String text, required String time, required bool isMe, required Color docBubbleColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: isHighContrast ? Colors.transparent : const Color(0xFF387A76),
              child: Icon(Icons.person, size: 18, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isHighContrast ? Colors.black : (isMe ? null : docBubbleColor),
                gradient: (!isHighContrast && isMe) 
                    ? const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)], 
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: isMe ? const Radius.circular(20) : const Radius.circular(4), 
                  topRight: const Radius.circular(20),
                  bottomLeft: const Radius.circular(20),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20), 
                ),
                border: isHighContrast 
                    ? Border.all(color: isMe ? Colors.white : const Color(0xFFFFD600), width: 2) 
                    : null,
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(color: isHighContrast ? (isMe ? Colors.white : const Color(0xFFFFD600)) : Colors.white, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    time,
                    style: TextStyle(
                      color: isHighContrast ? Colors.white : Colors.white.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 30), 
        ],
      ),
    );
  }

  Widget _buildMessageInput(Color cardColor, Color borderColor, Color mainTextColor) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
      decoration: BoxDecoration(
        color: isHighContrast ? Colors.black : const Color(0xFF090C10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(30), 
                border: Border.all(color: borderColor, width: isHighContrast ? 2 : 0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: isHighContrast ? Colors.white : Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Escreve uma mensagem...',
                        hintStyle: TextStyle(color: isHighContrast ? Colors.white54 : Colors.white38),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt_outlined, color: isHighContrast ? Colors.white : Colors.white54, size: 20),
                    onPressed: () {}, 
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isHighContrast ? Colors.black : const Color(0xFF3B82F6), 
                shape: BoxShape.circle,
                border: isHighContrast ? Border.all(color: const Color(0xFFFFD600), width: 2) : null,
              ),
              child: Icon(Icons.send_rounded, color: isHighContrast ? const Color(0xFFFFD600) : Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}