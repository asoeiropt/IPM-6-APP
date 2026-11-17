import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_data.dart'; 

class DoctorChatScreen extends StatefulWidget {
  final String patientName;
  final String patientInitials;
  final List initialMessages;

  const DoctorChatScreen({
    super.key,
    required this.patientName,
    required this.patientInitials,
    required this.initialMessages,
  });

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  List _messages = [];

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.initialMessages);
  }

  // OBRIGA O ECRÃ A ATUALIZAR SE O PACIENTE MUDAR!
  @override
  void didUpdateWidget(covariant DoctorChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.patientName != oldWidget.patientName) {
      _messages = List.from(widget.initialMessages);
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    
    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'time': _getCurrentTime(),
      });
      _messageController.clear();
    });

    _scrollToBottom();
    
    // Simulações diferentes consoante o paciente
    if (widget.patientName.contains("João")) {
      _simulatePatientReply('Já bebi o sumo de 15g Dra. Joana. Estou a aguardar os 15 minutos sentindo-me um pouco melhor. Obrigado pela rapidez!');
    } else if (widget.patientName.contains("Maria")) {
      _simulatePatientReply('Muito obrigada Dra. Joana, não me esqueço!');
    }
  }

  void _simulatePatientReply(String replyText) async {
    setState(() => _isTyping = true);
    _scrollToBottom();

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add({
        'text': replyText,
        'isMe': false,
        'time': _getCurrentTime(),
      });
    });

    HapticFeedback.mediumImpact(); 
    _scrollToBottom();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    int hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    return '$hour:${now.minute.toString().padLeft(2, '0')}${now.hour >= 12 ? 'PM' : 'AM'}';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100, 
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final borderColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white.withOpacity(0.05);
    final mainTextColor = isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : Colors.white54;

    final isSOS = widget.patientName.contains("João");
    final avatarColor = isSOS ? Colors.redAccent : const Color(0xFF3B82F6);
    final statusText = isSOS ? 'Paciente (Alerta SOS)' : 'Paciente (Online)';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: mainTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isHighContrast ? Colors.transparent : avatarColor.withOpacity(0.2),
                  child: Text(widget.patientInitials, style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : avatarColor, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF00E676),
                      shape: BoxShape.circle,
                      border: Border.all(color: cardColor, width: 2),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.patientName, style: TextStyle(color: mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(statusText, style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : avatarColor, fontSize: 12)),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderColor, height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) return _buildTypingIndicator(avatarColor);
                  final msg = _messages[index];
                  return _buildMessageBubble(msg['text'], msg['time'], msg['isMe']);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: cardColor, border: Border(top: BorderSide(color: borderColor, width: 1))),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isHighContrast ? Colors.transparent : Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: isHighContrast ? Border.all(color: const Color(0xFFFFD600)) : null,
                    ),
                    child: Icon(Icons.medical_services_outlined, color: subTextColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Responder ao paciente...',
                        hintStyle: TextStyle(color: subTextColor, fontSize: 14),
                        filled: true,
                        fillColor: isHighContrast ? Colors.black : Colors.white.withOpacity(0.03),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: isHighContrast ? const BorderSide(color: Color(0xFFFFD600)) : BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: isHighContrast ? const BorderSide(color: Color(0xFFFFD600)) : BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isHighContrast ? const Color(0xFFFFD600) : const Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.send, color: isHighContrast ? Colors.black : Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, String time, bool isMe) {
    final bubbleColor = isHighContrast 
        ? (isMe ? const Color(0xFFFFD600) : Colors.transparent)
        : (isMe ? const Color(0xFF3B82F6) : const Color(0xFF1E293B));
        
    final textColor = isHighContrast ? (isMe ? Colors.black : Colors.white) : Colors.white;
    final isSOSMsg = !isMe && text.contains('SOS');
    final border = isHighContrast && !isMe 
        ? Border.all(color: const Color(0xFFFFD600), width: 1.5) 
        : (isSOSMsg ? Border.all(color: Colors.redAccent, width: 1) : null);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: isHighContrast ? Colors.transparent : (isSOSMsg ? Colors.redAccent : const Color(0xFF3B82F6)).withOpacity(0.2),
              child: Text(widget.patientInitials, style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : (isSOSMsg ? Colors.redAccent : const Color(0xFF3B82F6)), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                border: border,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(text, style: TextStyle(color: textColor, fontSize: 15, height: 1.3)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(time, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 10)),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.done_all, color: isHighContrast ? Colors.black54 : Colors.white54, size: 12),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 22), 
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(Color avatarColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isHighContrast ? Colors.transparent : avatarColor.withOpacity(0.2),
            child: Text(widget.patientInitials, style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : avatarColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isHighContrast ? Colors.transparent : const Color(0xFF1E293B),
              border: isHighContrast ? Border.all(color: const Color(0xFFFFD600), width: 1.5) : null,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(20)),
            ),
            child: Text('A escrever...', style: TextStyle(color: isHighContrast ? const Color(0xFFFFD600) : Colors.white70, fontSize: 13, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }
}