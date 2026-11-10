import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_language.dart';

class SecureChatScreen extends StatefulWidget {
  final String userName;
  final String userAvatar;

  SecureChatScreen({required this.userName, required this.userAvatar});

  @override
  _SecureChatScreenState createState() => _SecureChatScreenState();
}

class _SecureChatScreenState extends State<SecureChatScreen> {
  final TextEditingController _textController = TextEditingController();
  List<Map<String, dynamic>> messages = [
    {'isMe': false, 'text': 'Merhaba, evcil dostunuzla ilgilenmek için buradayım. Aklınıza takılan bir şey var mı?', 'time': '14:30'},
  ];
  bool _numberShared = false;

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    setState(() {
      messages.add({'isMe': true, 'text': _textController.text.trim(), 'time': 'Şimdi'});
      _textController.clear();
    });
    
    // Fake auto reply
    Future.delayed(Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        messages.add({'isMe': false, 'text': 'Anlıyorum. Detayları yüz yüze veya telefonda da görüşebiliriz.', 'time': 'Şimdi'});
      });
    });
  }

  void _shareNumber() {
    final appLang = AppLanguage.of(context, listen: false);
    setState(() {
      _numberShared = true;
      messages.add({'isSystem': true, 'text': 'Güvenli İletişim: Telefon numaranız karşı tarafa iletildi. (+90 555 123 4567)'});
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green[700],
      content: Text(appLang.translateDynamic('Numaranız güvenle paylaşıldı.')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.userAvatar), radius: 18),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userName, style: TextStyle(fontSize: 16.sp)),
                Text(appLang.translateDynamic('Şu an aktif'), style: TextStyle(fontSize: 12.sp, color: Colors.green, fontWeight: FontWeight.normal)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shield_rounded, color: AppTheme.secondary),
            tooltip: appLang.translateDynamic('Güvenlik Bilgisi'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(appLang.translateDynamic('Güvenli İletişim')),
                  content: Text(appLang.translateDynamic('Numaranız siz paylaşana kadar gizlidir. Yalnızca güvendiğiniz kişilerle numaranızı paylaşın.')),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(appLang.translateDynamic('Anladım')))],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTrustBanner(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                if (msg['isSystem'] == true) {
                  return _buildSystemMessage(msg['text']);
                }
                return _buildMessageBubble(msg['text'], msg['isMe'], msg['time']);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildTrustBanner() {
    final appLang = AppLanguage.of(context);
    return Container(
      color: Colors.blue[50],
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(Icons.lock_rounded, color: Colors.blue[700], size: 20),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              appLang.translateDynamic('Mesajlarınız uçtan uca şifrelidir. Gizliliğiniz için numaranızı sadece güvendiğinizde paylaşın.'),
              style: TextStyle(color: Colors.blue[900], fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(String text) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.green[200]!)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, color: Colors.green[700], size: 18),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: TextStyle(color: Colors.green[800], fontSize: 13.sp, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    final appLang = AppLanguage.of(context);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          border: isMe ? null : Border.all(color: AppTheme.divider),
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(appLang.translateDynamic(text), style: TextStyle(color: isMe ? Colors.white : AppTheme.textDark, fontSize: 15.sp)),
            SizedBox(height: 4.h),
            Text(appLang.translateDynamic(time), style: TextStyle(color: isMe ? Colors.white70 : AppTheme.textLight, fontSize: 10.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final appLang = AppLanguage.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (!_numberShared)
              Padding(
                padding: EdgeInsets.only(bottom: 12.0.h),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.contact_phone_rounded),
                    label: Text(appLang.translateDynamic('Numaramı Güvenle Paylaş')),
                    onPressed: _shareNumber,
                  ),
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle_outline_rounded, color: AppTheme.textLight),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: appLang.translateDynamic('Mesaj yazın...'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  child: IconButton(
                    icon: Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}



