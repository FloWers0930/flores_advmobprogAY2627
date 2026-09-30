import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../widgets/custom_text.dart';
import 'chat_detailscreen.dart';
import '../constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Chats',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: CustomText(text: 'Error loading users.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentUser = _auth.currentUser;
        if (currentUser == null) {
          return Center(child: CustomText(text: 'Please log in to chat.'));
        }

        List<Map<String, dynamic>> users = snapshot.data ?? [];
        
        // Filter out current user and apply search query
        users = users.where((user) {
          final uid = user['uid'] as String? ?? '';
          if (uid == currentUser.uid) return false;

          if (_searchQuery.isEmpty) return true;

          final name = (user['firstName'] as String? ?? '').toLowerCase();
          final email = (user['email'] as String? ?? '').toLowerCase();
          return name.contains(_searchQuery) || email.contains(_searchQuery);
        }).toList();

        if (users.isEmpty) {
          return Center(child: CustomText(text: 'No users found.'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserListItem(user, context);
          },
        );
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> user, BuildContext context) {
    final name = user['firstName'] as String? ?? 'Unknown';
    final email = user['email'] as String? ?? 'No email';
    final receiverId = user['uid'] as String?;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: brandNavy.withValues(alpha: 0.1),
        child: CustomText(
          text: name.isNotEmpty ? name[0].toUpperCase() : '?',
          color: brandNavy,
          fontWeight: FontWeight.bold,
        ),
      ),
      title: CustomText(text: name, fontSize: 16.sp, fontWeight: FontWeight.w500),
      subtitle: CustomText(text: email, fontSize: 13.sp, color: Colors.grey),
      onTap: () {
        if (receiverId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                receiverUserEmail: email,
                receiverUserID: receiverId,
                receiverName: name,
              ),
            ),
          );
        }
      },
    );
  }
}
