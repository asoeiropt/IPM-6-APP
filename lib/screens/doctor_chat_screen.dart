import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../app_data.dart';
import '../fcm_notification_service.dart';

class DoctorChatScreen extends StatefulWidget {
  final String patientName;
  final String patientInitials;
  final String? patientId;

  const DoctorChatScreen({
    super.key,
    required this.patientName,
    required this.patientInitials,
    this.patientId,
    required List initialMessages,
  });

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  final Set<String> _selectedDocIds = {};
  bool _isSendingImage = false;

  bool get _isSelectionMode => _selectedDocIds.isNotEmpty;

  String get _resolvedPatientId {
    if (widget.patientId != null && widget.patientId!.isNotEmpty) {
      return widget.patientId!;
    }
    if (widget.patientName.contains("João")) return 'paciente_joao';
    if (widget.patientName.contains("Maria")) return 'paciente_maria';
    return 'paciente_joao';
  }

  String get _roomId => 'chat_$_resolvedPatientId';

  String get _doctorSenderId =>
      currentUserId.isNotEmpty ? currentUserId : 'medica_joana';

  // Ordenado por timestamp descendente + reverse: true na ListView
  // abre imediatamente nas mensagens mais recentes
  Stream<QuerySnapshot> _getChatStream() {
    return FirebaseFirestore.instance
        .collection(_roomId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

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
      final colRef = FirebaseFirestore.instance.collection(_roomId);

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
              count == 1
                  ? '🗑️ Mensagem apagada.'
                  : '🗑️ $count mensagens apagadas.',
              count == 1
                  ? '🗑️ Message deleted.'
                  : '🗑️ $count messages deleted.',
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

    HapticFeedback.lightImpact();
    _messageController.clear();

    await FirebaseFirestore.instance.collection(_roomId).add({
      'text': text,
      'senderId': _doctorSenderId,
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
      targetUserId: _resolvedPatientId,
      senderName: 'Dra. Joana Sílvia',
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
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isHighContrast
                        ? Colors.transparent
                        : const Color(0xFF2DD4BF).withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: isHighContrast
                        ? Border.all(color: const Color(0xFFFFD600))
                        : null,
                  ),
                  child: Icon(Icons.medical_services_outlined,
                      color: isHighContrast
                          ? const Color(0xFFFFD600)
                          : const Color(0xFF2DD4BF)),
                ),
                title: Text(
                  tr('Orientação Clínica Rápida', 'Quick Clinical Note'),
                  style: TextStyle(
                      color: mainTextColor, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  tr('Preencher recomendação de controlo glicémico',
                      'Insert glycemic control recommendation'),
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _messageController.text = tr(
                    'Analisei os teus registos recentes. Mantém a hidratação e verifica a glicemia dentro de 2 horas.',
                    'I reviewed your recent logs. Stay hydrated and recheck your glucose in 2 hours.',
                  );
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

      await FirebaseFirestore.instance.collection(_roomId).add({
        'text': caption,
        'imageBase64': base64Image,
        'senderId': _doctorSenderId,
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
        targetUserId: _resolvedPatientId,
        senderName: 'Dra. Joana Sílvia',
        messageText: caption.isNotEmpty
            ? '📷 $caption'
            : tr('📷 Enviou uma fotografia', '📷 Sent a photo'),
      );
    } catch (e) {
      debugPrint('❌ Erro ao enviar imagem no chat médico: $e');
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
    final borderColor = isHighContrast
        ? const Color(0xFFFFD600)
        : Colors.white.withOpacity(0.05);
    final mainTextColor =
        isHighContrast ? const Color(0xFFFFD600) : Colors.white;
    final subTextColor = isHighContrast ? Colors.white : Colors.white54;

    final isSOS = widget.patientName.contains("João");
    final avatarColor = isSOS ? Colors.redAccent : const Color(0xFF3B82F6);
    final statusText = isSOS
        ? tr('Paciente (Alerta SOS)', 'Patient (SOS Alert)')
        : tr('Paciente (Online)', 'Patient (Online)');

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _isSelectionMode
          ? AppBar(
              backgroundColor: cardColor,
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
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: borderColor, height: 1),
              ),
            )
          : AppBar(
              backgroundColor: cardColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    color: mainTextColor, size: 20),
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
                  Expanded(
                    child: Column(
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
                        child: Text(
                            tr('Erro ao carregar chat.', 'Error loading chat.'),
                            style: TextStyle(color: mainTextColor)));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                        child: Text(
                            tr('A aguardar mensagens do paciente.',
                                'Waiting for patient messages.'),
                            style: TextStyle(color: subTextColor)));
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final String messageText = data['text'] ?? '';
                      final String? imageBase64 =
                          data['imageBase64'] as String?;
                      final String senderId = data['senderId'] ?? '';

                      final bool isMe = senderId == _doctorSenderId;
                      final bool isSelected = _selectedDocIds.contains(doc.id);

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
                            isSOS: isSOS,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                  color: cardColor,
                  border:
                      Border(top: BorderSide(color: borderColor, width: 1))),
              child: Row(
                children: [
                  // Botão à esquerda para Câmara, Galeria ou Nota Clínica
                  GestureDetector(
                    onTap: _isSendingImage ? null : _showAttachmentOptions,
                    child: Container(
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
                          : Icon(Icons.add_photo_alternate_outlined,
                              color: isHighContrast
                                  ? const Color(0xFFFFD600)
                                  : subTextColor,
                              size: 22),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: tr('Responder ao paciente...',
                            'Reply to patient...'),
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
                  const SizedBox(width: 10),
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

  Widget _buildMessageBubble({
    required String text,
    String? imageBase64,
    required String time,
    required bool isMe,
    required bool isSelected,
    required bool isSOS,
  }) {
    Uint8List? imageBytes;
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        imageBytes = base64Decode(imageBase64);
      } catch (_) {}
    }

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
      padding: const EdgeInsets.only(bottom: 12, top: 4),
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
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          if (isMe) const SizedBox(width: 12),
        ],
      ),
    );
  }
}