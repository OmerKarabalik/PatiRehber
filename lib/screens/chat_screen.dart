import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/sitter_model.dart';
import '../../localization/app_language.dart';

class ChatScreen extends StatefulWidget {
  final SitterModel sitter;
  
  ChatScreen({required this.sitter});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Create a unique chat ID based on the user and sitter
  String get chatId {
    final userId = _auth.currentUser?.uid ?? 'guest_user';
    return '${userId}_${widget.sitter.id}';
  }

  void _sendMessage({String? specialText}) {
    final text = specialText ?? _messageController.text.trim();
    if (text.isEmpty) return;
    
    final userId = _auth.currentUser?.uid ?? 'guest_user';

    _firestore.collection('chats').doc(chatId).collection('messages').add({
      'text': text,
      'senderId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  void _sharePhoneNum() {
    // Sitter initiates sharing their phone number. 
    // In a real app, we would verify if current user is the sitter.
    _sendMessage(specialText: 'Merhaba, bana bu numaradan ulaşabilirsiniz: ${widget.sitter.contactPhone}');
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid ?? 'guest_user';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sitter.name),
        actions: [
          // GÜVENLİK: Bakıcıya özel "Numaramı Paylaş" butonu simülasyonu
          // Gerçek senaryoda bu buton sadece giriş yapan kullanıcı == bakıcı ise görünür.
          IconButton(
            icon: Icon(Icons.phone_android),
            tooltip: AppLanguage.of(context).translateDynamic('Numaranı Paylaş (Sadece Bakıcı İçin)'),
            onPressed: _sharePhoneNum,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                
                final messages = snapshot.data!.docs;
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      AppLanguage.of(context).translateDynamic('Güvenli sohbete başlayın.\nTelefon numaraları asla izinsiz paylaşılmaz.'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isMe = msg['senderId'] == currentUserId;
                    final text = msg['text'] ?? '';

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Text(
                          text,
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0.w),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: AppLanguage.of(context).translateDynamic('Mesajınızı yazın...'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.r)),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}



