import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Lista simples para evitar qualquer erro de sintaxe
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
    
    // Scroll automático para o fundo após enviar
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
    // Cores exatas baseadas no teu novo design de imagem
    const bgColor = Color(0xFF090C10); // Fundo azul super escuro
    const cardColor = Color(0xFF141923); // Azul/Cinza escuro para os cartões
    const docBubbleColor = Color(0xFF1A2130); // Bolha do médico

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chat Médico', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Fala com a tua equipa clínica', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_outlined, color: Colors.white54),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDoctorHeader(cardColor),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['isMe'] == true; // Validação 100% segura
                
                return _buildMessageBubble(
                  text: message['text'].toString(),
                  time: message['time'].toString(),
                  isMe: isMe,
                  docBubbleColor: docBubbleColor,
                );
              },
            ),
          ),
          _buildMessageInput(cardColor),
        ],
      ),
    );
  }

  // --- CARTÃO DO MÉDICO NO TOPO ---
  Widget _buildDoctorHeader(Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Color(0xFF387A76),
                child: Icon(Icons.person, color: Colors.white, size: 28), // Placeholder avatar
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676), // Ponto verde brilhante
                    shape: BoxShape.circle,
                    border: Border.all(color: cardColor, width: 2.5),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dra. Joana Sílvia', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 2),
              Text('Endocrinologista', style: TextStyle(color: Colors.white70, fontSize: 13)),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.circle, color: Color(0xFF00E676), size: 10),
                  SizedBox(width: 4),
                  Text('Online', style: TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- BOLHAS DE MENSAGEM ---
  Widget _buildMessageBubble({required String text, required String time, required bool isMe, required Color docBubbleColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF387A76),
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                // O gradiente só é aplicado se a mensagem for tua (isMe)
                gradient: isMe 
                    ? const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)], // Roxo para Azul (como na imagem)
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe ? null : docBubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: isMe ? const Radius.circular(20) : const Radius.circular(4), // Canto afiado do médico
                  topRight: const Radius.circular(20),
                  bottomLeft: const Radius.circular(20),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20), // Canto afiado do paciente
                ),
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 30), // Margem à direita se fores tu
        ],
      ),
    );
  }

  // --- ÁREA DE INPUT (ESCREVER MENSAGEM) ---
  Widget _buildMessageInput(Color cardColor) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF090C10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(30), // Formato de pílula
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Escreve uma mensagem...',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 20),
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
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6), // Azul forte do botão
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}