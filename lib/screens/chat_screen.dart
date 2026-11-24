import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../app_data.dart';
import '../fcm_notification_service.dart';
import 'report_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  final Set<String> _selectedDocIds = {};
  bool _isSendingImage = false;

  bool get _isSelectionMode => _selectedDocIds.isNotEmpty;

  // Ordenado por timestamp descendente + reverse: true na ListView
  // garante abertura imediata nas mensagens mais recentes
  Stream<QuerySnapshot> get _chatStream => FirebaseFirestore.instance
      .collection('chat_$currentUserId')
      .orderBy('timestamp', descending: true)
      .snapshots();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSelection(String docId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedDocIds.contains(docId)) {
        _selectedDocIds.remove(docId);
      } else {
        _selectedDocIds.add(docId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedDocIds.clear();
    });
  }

  Future<void> _deleteSelectedMessages() async {
    if (_selectedDocIds.isEmpty) return;

    final int count = _selectedDocIds.length;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isHighContrast ? Colors.black : const Color(0xFF141923),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isHighContrast
                ? const Color(0xFFFFD600)
                : Colors.white.withOpacity(0.1),
            width: isHighContrast ? 2 : 1,
          ),
        ),
        title: Text(
          tr(
            count == 1 ? 'Apagar mensagem?' : 'Apagar $count mensagens?',
            count == 1 ? 'Delete message?' : 'Delete $count messages?',
          ),
          style: TextStyle(
            color: isHighContrast ? const Color(0xFFFFD600) : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          tr(
            'Esta ação irá remover permanentemente as mensagens selecionadas da conversa.',
            'This will permanently remove the selected messages from the conversation.',
          ),
          style: TextStyle(
            color: isHighContrast ? Colors.white : Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              tr('Cancelar', 'Cancel'),
              style: TextStyle(
                color: isHighContrast ? Colors.white : Colors.white54,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isHighContrast ? const Color(0xFFFFD600) : Colors.redAccent,
              foregroundColor: isHighContrast ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              tr('Apagar', 'Delete'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      HapticFeedback.heavyImpact();
      final batch = FirebaseFirestore.instance.batch();
      final colRef =
          FirebaseFirestore.instance.collection('chat_$currentUserId');

      for (final id in _selectedDocIds) {
        batch.delete(colRef.doc(id));
      }

      await batch.commit();

      if (!mounted) return;
      _clearSelection();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              count == 1 ? '🗑️ Mensagem apagada.' : '🗑️ $count mensagens apagadas.',
              count == 1 ? '🗑️ Message deleted.' : '🗑️ $count messages deleted.',
            ),
            style: TextStyle(
              color: isHighContrast ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: isHighContrast
              ? const Color(0xFFFFD600)
              : const Color(0xFF141923),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('❌ Erro ao apagar mensagens no Firestore: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tr('Erro ao apagar', 'Delete error')}: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    await FirebaseFirestore.instance.collection('chat_$currentUserId').add({
      'text': text,
      'senderId': currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    await FcmNotificationService.instance.sendPushToUser(
      targetUserId: 'medica_joana',
      senderName: currentUserName.isNotEmpty
          ? currentUserName
          : tr('Paciente', 'Patient'),
      messageText: text,
    );
  }

  void _showAttachmentOptions() {
    HapticFeedback.lightImpact();
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final mainTextColor =
        isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : Colors.white54;
    final borderColor = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.1);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: borderColor, width: isHighContrast ? 2 : 1),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isHighContrast
                        ? Colors.transparent
                        : const Color(0xFF3B82F6).withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: isHighContrast
                        ? Border.all(color: const Color(0xFFFFD600))
                        : null,
                  ),
                  child: Icon(Icons.camera_alt_rounded,
                      color: isHighContrast
                          ? const Color(0xFFFFD600)
                          : const Color(0xFF3B82F6)),
                ),
                title: Text(
                  tr('Tirar Fotografia', 'Take Photo'),
                  style: TextStyle(
                      color: mainTextColor, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  tr('Usar a câmara para enviar uma imagem',
                      'Use camera to send a photo'),
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndSendImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isHighContrast
                        ? Colors.transparent
                        : const Color(0xFF8B5CF6).withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: isHighContrast
                        ? Border.all(color: const Color(0xFFFFD600))
                        : null,
                  ),
                  child: Icon(Icons.photo_library_rounded,
                      color: isHighContrast
                          ? const Color(0xFFFFD600)
                          : const Color(0xFF8B5CF6)),
                ),
                title: Text(
                  tr('Escolher da Galeria', 'Choose from Gallery'),
                  style: TextStyle(
                      color: mainTextColor, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  tr('Enviar foto guardada no telemóvel',
                      'Send a saved photo from your device'),
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndSendImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndSendImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 900,
        maxHeight: 900,
        imageQuality: 65,
      );

      if (pickedFile == null) return;

      setState(() => _isSendingImage = true);

      final Uint8List bytes = await File(pickedFile.path).readAsBytes();
      final String base64Image = base64Encode(bytes);
      final String caption = _messageController.text.trim();
      _messageController.clear();

      await FirebaseFirestore.instance.collection('chat_$currentUserId').add({
        'text': caption,
        'imageBase64': base64Image,
        'senderId': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }

      await FcmNotificationService.instance.sendPushToUser(
        targetUserId: 'medica_joana',
        senderName: currentUserName.isNotEmpty
            ? currentUserName
            : tr('Paciente', 'Patient'),
        messageText: caption.isNotEmpty
            ? '📷 $caption'
            : tr('📷 Enviou uma fotografia', '📷 Sent a photo'),
      );
    } catch (e) {
      debugPrint('❌ Erro ao enviar imagem no chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr('⚠️ Não foi possível enviar a imagem.',
                  '⚠️ Could not send image.'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingImage = false);
    }
  }

  void _openFullImage(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(imageBytes, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isHighContrast ? Colors.black : const Color(0xFF090C10);
    final cardColor = isHighContrast ? Colors.black : const Color(0xFF141923);
    final docBubbleColor =
        isHighContrast ? Colors.black : const Color(0xFF1A2130);
    final mainTextColor =
        isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : Colors.white54;
    final borderColor = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _isSelectionMode
          ? AppBar(
              backgroundColor:
                  isHighContrast ? Colors.black : const Color(0xFF141923),
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.close, color: mainTextColor),
                onPressed: _clearSelection,
              ),
              title: Text(
                tr(
                  '${_selectedDocIds.length} selecionada(s)',
                  '${_selectedDocIds.length} selected',
                ),
                style: TextStyle(
                  color: mainTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: isHighContrast
                        ? const Color(0xFFFFD600)
                        : Colors.redAccent,
                  ),
                  tooltip: tr('Apagar selecionadas', 'Delete selected'),
                  onPressed: _deleteSelectedMessages,
                ),
                const SizedBox(width: 8),
              ],
            )
          : AppBar(
              backgroundColor: bgColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: mainTextColor),
                onPressed: () => Navigator.pop(context),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('Chat Médico', 'Medical Chat'),
                      style: TextStyle(
                          color: mainTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(
                      tr('Fala com a tua equipa clínica',
                          'Talk to your health team'),
                      style: TextStyle(
                          color: subTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.normal)),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.assignment_outlined, color: subTextColor),
                  tooltip: tr('Relatório Clínico', 'Clinical Report'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportScreen()),
                    );
                  },
                ),
              ],
            ),
      body: Column(
        children: [
          _buildDoctorHeader(
              cardColor, mainTextColor, subTextColor, borderColor),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF3B82F6)));
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          tr('Erro ao carregar mensagens.',
                              'Error loading messages.'),
                          style: TextStyle(color: mainTextColor)));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                      child: Text(
                          tr('Nenhuma mensagem ainda.\nDiz olá à Dra. Joana!',
                              'No messages yet.\nSay hello to Dra. Joana!'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: subTextColor)));
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final String messageText = data['text'] ?? '';
                    final String? imageBase64 = data['imageBase64'] as String?;
                    final String senderId = data['senderId'] ?? '';
                    final bool isMe = senderId == currentUserId;
                    final bool isSelected = _selectedDocIds.contains(doc.id);

                    String timeString = '';
                    if (data['timestamp'] != null) {
                      final timestamp = data['timestamp'] as Timestamp;
                      final date = timestamp.toDate();
                      timeString =
                          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                    }

                    return GestureDetector(
                      onLongPress: () => _toggleSelection(doc.id),
                      onTap: () {
                        if (_isSelectionMode) {
                          _toggleSelection(doc.id);
                        }
                      },
                      child: Container(
                        color: isSelected
                            ? (isHighContrast
                                ? const Color(0xFFFFD600).withOpacity(0.2)
                                : const Color(0xFF3B82F6).withOpacity(0.18))
                            : Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildMessageBubble(
                          text: messageText,
                          imageBase64: imageBase64,
                          time: timeString,
                          isMe: isMe,
                          isSelected: isSelected,
                          docBubbleColor: docBubbleColor,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(cardColor, borderColor, mainTextColor),
        ],
      ),
    );
  }

  Widget _buildDoctorHeader(Color cardColor, Color mainTextColor,
      Color subTextColor, Color borderColor) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 12),
      padding: const EdgeInsets.all(14),
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
                radius: 24,
                backgroundColor: isHighContrast
                    ? Colors.transparent
                    : const Color(0xFF387A76),
                child: Icon(Icons.person,
                    color:
                        isHighContrast ? const Color(0xFFFFD600) : Colors.white,
                    size: 26),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: isHighContrast
                        ? const Color(0xFFFFD600)
                        : const Color(0xFF00E676),
                    shape: BoxShape.circle,
                    border: Border.all(color: cardColor, width: 2.5),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dra. Joana Sílvia',
                    style: TextStyle(
                        color: mainTextColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(tr('Endocrinologista', 'Endocrinologist'),
                    style: TextStyle(color: subTextColor, fontSize: 12)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.circle,
                        color: isHighContrast
                            ? const Color(0xFFFFD600)
                            : const Color(0xFF00E676),
                        size: 9),
                    const SizedBox(width: 4),
                    Text('Online',
                        style: TextStyle(
                            color: isHighContrast
                                ? const Color(0xFFFFD600)
                                : const Color(0xFF00E676),
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          if (!_isSelectionMode)
            Text(
              tr('Prime longo\npara apagar', 'Long press\nto select'),
              textAlign: TextAlign.right,
              style: TextStyle(color: subTextColor, fontSize: 10),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    String? imageBase64,
    required String time,
    required bool isMe,
    required bool isSelected,
    required Color docBubbleColor,
  }) {
    Uint8List? imageBytes;
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        imageBytes = base64Decode(imageBase64);
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14, top: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isSelectionMode) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 10),
              child: Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? (isHighContrast
                        ? const Color(0xFFFFD600)
                        : const Color(0xFF3B82F6))
                    : Colors.white38,
                size: 20,
              ),
            ),
          ],
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: isHighContrast
                  ? Colors.transparent
                  : const Color(0xFF387A76),
              child: Icon(Icons.person,
                  size: 18,
                  color:
                      isHighContrast ? const Color(0xFFFFD600) : Colors.white),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isHighContrast
                    ? Colors.black
                    : (isMe ? null : docBubbleColor),
                gradient: (!isHighContrast && isMe)
                    ? const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: isMe
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  topRight: const Radius.circular(20),
                  bottomLeft: const Radius.circular(20),
                  bottomRight: isMe
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
                border: isHighContrast
                    ? Border.all(
                        color: isMe ? Colors.white : const Color(0xFFFFD600),
                        width: 2)
                    : null,
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (imageBytes != null) ...[
                    GestureDetector(
                      onTap: _isSelectionMode
                          ? null
                          : () => _openFullImage(imageBytes!),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(
                          imageBytes,
                          width: 210,
                          height: 210,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (text.isNotEmpty) const SizedBox(height: 8),
                  ],
                  if (text.isNotEmpty)
                    Text(
                      text,
                      style: TextStyle(
                          color: isHighContrast
                              ? (isMe ? Colors.white : const Color(0xFFFFD600))
                              : Colors.white,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  const SizedBox(height: 5),
                  Text(
                    time,
                    style: TextStyle(
                      color: isHighContrast
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildMessageInput(
      Color cardColor, Color borderColor, Color mainTextColor) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 16, top: 10, bottom: 22),
      decoration: BoxDecoration(
        color: isHighContrast ? Colors.black : const Color(0xFF090C10),
      ),
      child: Row(
        children: [
          // Botão à esquerda para tirar foto ou escolher da galeria
          GestureDetector(
            onTap: _isSendingImage ? null : _showAttachmentOptions,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: isHighContrast ? 2 : 1,
                ),
              ),
              child: _isSendingImage
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isHighContrast
                            ? const Color(0xFFFFD600)
                            : const Color(0xFF3B82F6),
                      ),
                    )
                  : Icon(
                      Icons.add_photo_alternate_outlined,
                      color: isHighContrast
                          ? const Color(0xFFFFD600)
                          : Colors.white70,
                      size: 22,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: borderColor, width: isHighContrast ? 2 : 0),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: tr(
                      'Escreve uma mensagem...', 'Write a message...'),
                  hintStyle: TextStyle(
                      color:
                          isHighContrast ? Colors.white54 : Colors.white38),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isHighContrast ? Colors.black : const Color(0xFF3B82F6),
                shape: BoxShape.circle,
                border: isHighContrast
                    ? Border.all(color: const Color(0xFFFFD600), width: 2)
                    : null,
              ),
              child: Icon(Icons.send_rounded,
                  color:
                      isHighContrast ? const Color(0xFFFFD600) : Colors.white,
                  size: 22),
            ),
          ),
        ],
      ),
    );
  }
}