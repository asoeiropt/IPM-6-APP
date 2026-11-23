import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_data.dart';
import '../fcm_notification_service.dart';

class DoctorChatScreen extends StatefulWidget {
  final String patientName;
  final String patientInitials;

  const DoctorChatScreen({
    super.key,
    required this.patientName,
    required this.patientInitials,
    required List initialMessages,
  });

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // --- FIREBASE 1: Apanhar a sala consoante o doente escolhido ---
  Stream<QuerySnapshot> _getChatStream() {
    String roomId = widget.patientName.contains("João")
        ? 'chat_paciente_joao'
        : 'chat_paciente_maria';

    return FirebaseFirestore.instance
        .collection(roomId)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    _messageController.clear();

    final bool isJoao = widget.patientName.contains("João");
    final String roomId =
        isJoao ? 'chat_paciente_joao' : 'chat_paciente_maria';
    final String targetPatientId =
        isJoao ? 'paciente_joao' : 'paciente_maria';

    // --- FIREBASE 2: Enviar mensagem para a sala isolada ---
    await FirebaseFirestore.instance.collection(roomId).add({
      'text': text,
      'senderId': currentUserId, // A Dra. Joana
      'timestamp': FieldValue.serverTimestamp(),
    });

    _scrollToBottom();

    // --- FIREBASE 3: Disparar notificação push real para o telemóvel do paciente ---
    await FcmNotificationService.instance.sendPushToUser(
      targetUserId: targetPatientId,
      senderName: 'Dra. Joana Sílvia',
      messageText: text,
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
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
    final borderColor = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.05);
    final mainTextColor =
        isHighContrast ? const Color(0xFFFFD600) : Colors.white;
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
                  backgroundColor: isHighContrast
                      ? Colors.transparent
                      : avatarColor.withOpacity(0.2),
                  child: Text(widget.patientInitials,
                      style: TextStyle(
                          color: isHighContrast
                              ? const Color(0xFFFFD600)
                              : avatarColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isHighContrast
                          ? const Color(0xFFFFD600)
                          : const Color(0xFF00E676),
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
                Text(widget.patientName,
                    style: TextStyle(
                        color: mainTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(statusText,
                    style: TextStyle(
                        color: isHighContrast
                            ? const Color(0xFFFFD600)
                            : avatarColor,
                        fontSize: 12)),
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
              child: StreamBuilder<QuerySnapshot>(
                stream: _getChatStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF3B82F6)));
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Erro ao carregar chat.',
                            style: TextStyle(color: mainTextColor)));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                        child: Text('A aguardar mensagens do paciente.',
                            style: TextStyle(color: subTextColor)));
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;

                      final String messageText = data['text'] ?? '';
                      final String senderId = data['senderId'] ?? '';

                      final bool isMe = senderId == currentUserId;

                      String timeString = '';
                      if (data['timestamp'] != null) {
                        final timestamp = data['timestamp'] as Timestamp;
                        final date = timestamp.toDate();
                        int hour = date.hour > 12
                            ? date.hour - 12
                            : (date.hour == 0 ? 12 : date.hour);
                        timeString =
                            '$hour:${date.minute.toString().padLeft(2, '0')}${date.hour >= 12 ? 'PM' : 'AM'}';
                      }

                      return _buildMessageBubble(
                          messageText, timeString, isMe, isSOS);
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: cardColor,
                  border:
                      Border(top: BorderSide(color: borderColor, width: 1))),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isHighContrast
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: isHighContrast
                          ? Border.all(color: const Color(0xFFFFD600))
                          : null,
                    ),
                    child: Icon(Icons.medical_services_outlined,
                        color: subTextColor, size: 22),
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
                        hintStyle:
                            TextStyle(color: subTextColor, fontSize: 14),
                        filled: true,
                        fillColor: isHighContrast
                            ? Colors.black
                            : Colors.white.withOpacity(0.03),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: isHighContrast
                                ? const BorderSide(color: Color(0xFFFFD600))
                                : BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: isHighContrast
                                ? const BorderSide(color: Color(0xFFFFD600))
                                : BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                                const BorderSide(color: Color(0xFF3B82F6))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isHighContrast
                            ? const Color(0xFFFFD600)
                            : const Color(0xFF3B82F6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.send,
                          color: isHighContrast ? Colors.black : Colors.white,
                          size: 20),
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

  Widget _buildMessageBubble(
      String text, String time, bool isMe, bool isSOS) {
    final bubbleColor = isHighContrast
        ? (isMe ? const Color(0xFFFFD600) : Colors.transparent)
        : (isMe ? const Color(0xFF3B82F6) : const Color(0xFF1E293B));

    final textColor =
        isHighContrast ? (isMe ? Colors.black : Colors.white) : Colors.white;
    final isSOSMsg = !isMe && text.contains('SOS') && isSOS;

    final border = isHighContrast && !isMe
        ? Border.all(color: const Color(0xFFFFD600), width: 1.5)
        : (isSOSMsg ? Border.all(color: Colors.redAccent, width: 1) : null);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: isHighContrast
                  ? Colors.transparent
                  : (isSOSMsg ? Colors.redAccent : const Color(0xFF3B82F6))
                      .withOpacity(0.2),
              child: Text(widget.patientInitials,
                  style: TextStyle(
                      color: isHighContrast
                          ? const Color(0xFFFFD600)
                          : (isSOSMsg
                              ? Colors.redAccent
                              : const Color(0xFF3B82F6)),
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                border: border,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isMe
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(text,
                      style: TextStyle(
                          color: textColor, fontSize: 15, height: 1.3)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(time,
                          style: TextStyle(
                              color: textColor.withOpacity(0.6), fontSize: 10)),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.done_all,
                            color: isHighContrast
                                ? Colors.black54
                                : Colors.white54,
                            size: 12),
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
}