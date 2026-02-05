import 'package:flutter/material.dart';
import 'package:e_pay/utils/constants.dart';
import 'package:e_pay/widgets/glass_container.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_pay/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final String paymentMethod;
  final Map<String, dynamic>? transactionDetails;

  const ChatScreen({
    Key? key, 
    required this.paymentMethod,
    this.transactionDetails, // Optional
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _supabase = Supabase.instance.client;
  late final Stream<List<Map<String, dynamic>>> _messagesStream;
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final myUserId = _supabase.auth.currentUser?.id;
    if(myUserId == null) return;
    
    // Subscribe to messages for this user
    _messagesStream = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('user_id', myUserId)
        .order('created_at', ascending: true);

    // Send Transaction Message if details exist
    if (widget.transactionDetails != null) {
      // Use postFrameCallback to avoid build collisions or ensure context is ready not strictly needed for just insert but good practice
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendTransactionMessage();
      });
    }
  }

  Future<void> _sendTransactionMessage() async {
    final details = widget.transactionDetails!;
    final message = "New Order Request:\n"
        "Game: ${details['product_name']}\n"
        "Offer: ${details['offer_name']} - ${details['price']} TND\n"
        "Method: ${details['payment_method']}\n"
        "TxID: ${details['id']}";
    
    await _sendMessage(textContent: message);
  }

  Future<void> _sendMessage({String? imageUrl, String? textContent}) async {
    final text = textContent ?? _messageController.text.trim();
    if (text.isEmpty && imageUrl == null) return;

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _messageController.clear();
    
    try {
      await _supabase.from('messages').insert({
        'user_id': user.id,
        'content': text.isEmpty ? 'Sent an image' : text,
        'image_url': imageUrl,
        'is_admin': false,
      });
      // Scroll to bottom after sending
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isUploading = true);

      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final fileExt = image.path.split('.').last;
      final fileName = 'chat/${DateTime.now().toIso8601String()}_${user.id}.$fileExt';
      
      final file = File(image.path);
      await _supabase.storage.from('images').upload(fileName, file);
      
      final imageUrl = _supabase.storage.from('images').getPublicUrl(fileName);
      
      await _sendMessage(imageUrl: imageUrl, textContent: "");

    } catch (e) {
      debugPrint('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paymentMethod == 'Support' ? "Support Chat" : "Transaction: ${widget.paymentMethod}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: Column(
          children: [
            const Gap(80), // For AppBar
            // Messages Area
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _messagesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    debugPrint('Stream Error: ${snapshot.error}');
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!;
                  
                  if (messages.isEmpty) {
                    return Center(
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(Icons.chat_bubble_outline, size: 60, color: Colors.white24),
                           const Gap(16),
                           Text("Start a conversation with us!", style: TextStyle(color: AppColors.textGray)),
                         ],
                       ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isAdmin = msg['is_admin'] as bool;
                      final content = msg['content'] as String;
                      final imageUrl = msg['image_url'] as String?;
                      final date = DateTime.parse(msg['created_at']); // Format if needed

                      return Align(
                        alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          child: Column(
                            crossAxisAlignment: isAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                            children: [
                              if (imageUrl != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                            height: 150,
                                            width: 200,
                                            color: Colors.black12,
                                            child: const Center(child: CircularProgressIndicator())
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isAdmin ? AppColors.surfaceDark : AppColors.accent,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isAdmin ? 4 : 16),
                                    bottomRight: Radius.circular(isAdmin ? 16 : 4),
                                  ),
                                ),
                                child: Text(
                                  content,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            // Input Area
            GlassContainer(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: _isUploading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Icon(Icons.image, color: AppColors.accent),
                    onPressed: _isUploading ? null : _pickAndUploadImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: AppColors.textDark), // Assuming Light Mode logic in glass, checking needed
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.accent),
                    onPressed: () => _sendMessage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
