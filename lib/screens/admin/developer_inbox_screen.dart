import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/firestore_service.dart';
import '../../services/communication_service.dart';
import '../../models/global_state.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_language.dart';

class DeveloperInboxScreen extends StatefulWidget {
  @override
  _DeveloperInboxScreenState createState() => _DeveloperInboxScreenState();
}

class _DeveloperInboxScreenState extends State<DeveloperInboxScreen> {
  final FirestoreService _firestore = FirestoreService();
  String _activeFilter = 'Tümü';

  final List<String> _filterCategories = [
    'Tümü',
    '💡 Yeni Fikir / Öneri',
    '🐞 Hata Bildirimi',
    '🐾 Yeni Hayvan Türü',
    '⭐ Teşekkür & Görüş',
  ];

  Color _getCategoryColor(String cat) {
    if (cat.contains('Fikir') || cat.contains('Öneri')) return const Color(0xFF27AE60);
    if (cat.contains('Hata')) return const Color(0xFFE74C3C);
    if (cat.contains('Hayvan')) return const Color(0xFF3498DB);
    return const Color(0xFFF39C12);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLanguage.of(context).translateDynamic('Geliştirici Gelen Kutusu'),
          style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w900, fontSize: 18.sp),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestore.getFeedbacks(),
        builder: (context, snapshot) {
          List<Map<String, dynamic>> messages = [];

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            messages = snapshot.data!;
          } else {
            // Offline / local fallback
            messages = GlobalState.feedbackMessages;
          }

          if (_activeFilter != 'Tümü') {
            messages = messages.where((m) => m['category'] == _activeFilter).toList();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderBanner(messages.length),
              SizedBox(height: 12.h),
              _buildFilterChips(),
              SizedBox(height: 10.h),
              Expanded(
                child: messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return _buildMessageCard(msg, index);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderBanner(int count) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_unread_rounded, color: Colors.white, size: 28),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLanguage.of(context).translateDynamic('Kullanıcı Geri Bildirimleri'),
                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 3.h),
                Text(
                  '${AppLanguage.of(context).translateDynamic('Toplam')} $count ${AppLanguage.of(context).translateDynamic('mesaj listeleniyor')}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11.5.sp),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final appLang = AppLanguage.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: _filterCategories.map((cat) {
          final isSel = _activeFilter == cat;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(
                appLang.translateDynamic(cat),
                style: TextStyle(
                  color: isSel ? Colors.white : AppTheme.textDark,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  fontSize: 11.5.sp,
                ),
              ),
              selected: isSel,
              selectedColor: const Color(0xFF27AE60),
              backgroundColor: Colors.white,
              onSelected: (val) {
                if (val) setState(() => _activeFilter = cat);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> msg, int index) {
    final name = msg['name'] ?? 'Anonim Kullanıcı';
    final contact = msg['contact'] ?? '';
    final category = msg['category'] ?? '💡 Öneri';
    final messageText = msg['message'] ?? '';
    final dateStr = msg['dateStr'] ?? 'Yeni';
    final id = msg['id'] ?? '';
    final catColor = _getCategoryColor(category);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  category,
                  style: TextStyle(color: catColor, fontWeight: FontWeight.bold, fontSize: 11.sp),
                ),
              ),
              Row(
                children: [
                  Text(
                    dateStr,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                  ),
                  SizedBox(width: 4.w),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      if (id.isNotEmpty) {
                        _firestore.deleteFeedback(id);
                      }
                      setState(() {
                        GlobalState.feedbackMessages.removeWhere((item) => item['id'] == id || item['message'] == messageText);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLanguage.of(context).translateDynamic('Mesaj silindi.'))),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: catColor.withValues(alpha: 0.15),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'A',
                  style: TextStyle(color: catColor, fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    if (contact.isNotEmpty)
                      Text(
                        contact,
                        style: TextStyle(fontSize: 11.5.sp, color: AppTheme.textLight),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200, width: 0.8),
            ),
            child: Text(
              messageText,
              style: TextStyle(fontSize: 13.5.sp, color: Colors.grey.shade900, height: 1.45),
            ),
          ),
          SizedBox(height: 10.h),
          // Hızlı Cevap Butonları
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38.h,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final emailTarget = contact.contains('@') ? contact : 'eyer259@gmail.com';
                      CommunicationService.replyViaEmail(
                        email: emailTarget,
                        subject: 'PatiRehber - Geri Bildiriminiz Hakkında ($category)',
                        message: 'Merhaba $name,\n\nPatiRehber uygulamamız üzerinden ilettiğiniz "$category" konulu geri bildiriminiz için teşekkür ederiz.\n\n',
                      );
                    },
                    icon: const Icon(Icons.mail_rounded, size: 16, color: Colors.white),
                    label: Text(
                      contact.contains('@') ? '${AppLanguage.of(context).translateDynamic('E-posta ile Yanıtla')} ($contact)' : AppLanguage.of(context).translateDynamic('E-posta ile Yanıt Yaz'),
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA4335),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final appLang = AppLanguage.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
            SizedBox(height: 16.h),
            Text(
              appLang.translateDynamic('Henüz gelen geri bildirim yok'),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            SizedBox(height: 6.h),
            Text(
              appLang.translateDynamic('Kullanıcılar Profil ekranındaki formdan mesaj gönderdiklerinde burada canlı ve ücretsiz listelenecektir.'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
