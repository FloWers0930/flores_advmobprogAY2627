import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../widgets/custom_text.dart';
import '../constants.dart';

class ChatDetailScreen extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  final String receiverName;

  const ChatDetailScreen({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserID,
    required this.receiverName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isSending = false;

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _isSending = true;
      });
      
      _messageController.clear();
      
      try {
        await _chatService.sendMessage(widget.receiverUserID, message);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send message: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSending = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: widget.receiverName.isNotEmpty ? widget.receiverName : widget.receiverUserEmail,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.receiverUserID, currentUserId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: CustomText(text: 'Error loading messages.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        
        // Mark unread messages from the other user as read
        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['senderId'] != currentUserId && !(data['isRead'] ?? false)) {
              _chatService.markMessageAsRead(widget.receiverUserID, doc.id);
            }
          }
        });
        
        if (docs.isEmpty) {
          return Center(
            child: CustomText(
              text: 'No messages yet. Say hi!',
              color: Colors.grey,
            ),
          );
        }

        return ListView.builder(
          reverse: true, // Show latest messages at the bottom
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final isPending = doc.metadata.hasPendingWrites;
            return _buildMessageItem(context, data, isPending);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(BuildContext context, Map<String, dynamic> data, bool isPending) {
    final isMe = data['senderId'] == _auth.currentUser?.uid;
    final message = data['message'] as String? ?? '';
    final bool isRead = data['isRead'] ?? false;
    
    // Parse timestamp
    String timeString = '';
    if (data['timestamp'] != null) {
      final dateTime = (data['timestamp'] as Timestamp).toDate();
      timeString = TimeOfDay.fromDateTime(dateTime).format(context);
    }

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h).copyWith(bottom: 6.h),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF6B4E90) : Colors.grey.shade200, // Matching the purple color from screenshot
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(2.r),
                  bottomRight: isMe ? Radius.circular(2.r) : Radius.circular(16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: message,
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 15.sp,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        text: timeString,
                        color: isMe ? Colors.white70 : Colors.black54,
                        fontSize: 10.sp,
                      ),
                      if (isMe) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          isPending ? Icons.access_time : (isRead ? Icons.done_all : Icons.done),
                          size: 14.sp,
                          color: isPending ? Colors.white54 : (isRead ? Colors.blue.shade300 : Colors.white70),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isMe && isRead)
              Padding(
                padding: EdgeInsets.only(top: 2.h, right: 4.w),
                child: CustomText(
                  text: 'Seen',
                  fontSize: 11.sp,
                  color: const Color(0xFF6B4E90), // Matching the purple color from screenshot
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h).copyWith(
        bottom: MediaQuery.of(context).padding.bottom + 8.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8.w),
          _isSending 
            ? Padding(
                padding: EdgeInsets.all(12.r),
                child: SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                onPressed: _sendMessage,
                icon: Icon(Icons.send, color: brandNavy, size: 28.sp),
              ),
        ],
      ),
    );
  }
}
