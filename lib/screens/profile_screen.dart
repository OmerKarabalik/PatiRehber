import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../localization/app_language.dart';
import '../models/global_state.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'my_pet_tracking_screen.dart';
import 'premium/pati_plus_sheet.dart';
import '../widgets/responsive_center.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _offlineCacheActive = true;

  void _showLanguageModal(BuildContext context) {
    AppLanguage.showLanguageModal(context);
  }

  void _showFeedbackModal(BuildContext context) {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final messageController = TextEditingController();
    String selectedCategory = '💡 Yeni Fikir / Öneri';

    final categories = [
      '💡 Yeni Fikir / Öneri',
      '🐞 Hata Bildirimi',
      '🐾 Yeni Hayvan Türü',
      '⭐ Teşekkür & Görüş',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final appLang = AppLanguage.of(context);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 20.w,
                right: 20.w,
                top: 20.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 5.h,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27AE60).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.mark_email_read_rounded, color: Color(0xFF27AE60), size: 24),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appLang.translateDynamic('Geliştiriciye Mesaj & Öneri'),
                                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                appLang.translateDynamic('Uygulamayı mükemmelleştirmek için fikirleriniz bizim için çok değerli!'),
                                style: TextStyle(fontSize: 11.5.sp, color: AppTheme.textLight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    Text(appLang.translateDynamic('Mesaj Konusu'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppTheme.textDark)),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: categories.map((cat) {
                        final isSel = selectedCategory == cat;
                        return ChoiceChip(
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
                          backgroundColor: Colors.grey.shade100,
                          onSelected: (val) {
                            if (val) setModalState(() => selectedCategory = cat);
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: appLang.translateDynamic('Adınız & Soyadınız (İsteğe bağlı)'),
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: contactController,
                      decoration: InputDecoration(
                        labelText: appLang.translateDynamic('E-posta Adresiniz (Geri dönüş için)'),
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: appLang.translateDynamic('Mesajınız, Öneriniz veya Hata Bildirimi'),
                        alignLabelWithHint: true,
                        hintText: appLang.translateDynamic('Örn: Şu özellik eklense çok iyi olurdu...'),
                        hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final msg = messageController.text.trim();
                          final name = nameController.text.trim();
                          final contact = contactController.text.trim();
                          if (msg.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(appLang.translate('feedback_enter_message'))),
                            );
                            return;
                          }

                          // 1. Firebase Firestore'a kaydet (100% Ücretsiz Spark)
                          FirestoreService().sendFeedback(
                            category: selectedCategory,
                            name: name.isNotEmpty ? name : 'PatiRehber Kullanıcısı',
                            contact: contact.isNotEmpty ? contact : 'Uygulama İçi',
                            message: msg,
                          );

                          // 2. Yerel kutuya ekle
                          final now = DateTime.now();
                          final dateStr = '${now.day}.${now.month}.${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                          GlobalState.addFeedbackMessage({
                            'id': 'fb_${DateTime.now().millisecondsSinceEpoch}',
                            'category': selectedCategory,
                            'name': name.isNotEmpty ? name : 'PatiRehber Kullanıcısı',
                            'contact': contact.isNotEmpty ? contact : 'Uygulama İçi',
                            'message': msg,
                            'dateStr': dateStr,
                            'isRead': false,
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF27AE60),
                              content: Text(appLang.translate('feedback_sent_success')),
                            ),
                          );
                        },
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        label: Text(
                          appLang.translate('send_feedback_btn'),
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appLang.translate('profile'),
          style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w900, fontSize: 18.sp),
        ),
      ),
      body: ResponsiveCenter(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserCard(),
              SizedBox(height: 16.h),
              _buildPatiSupportCard(context),
              SizedBox(height: 16.h),
              _buildFeedbackCard(context),
              SizedBox(height: 16.h),
              _buildOfflineStatusCard(),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${appLang.translate('my_registered_pets')} (${GlobalState.pets.length})',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => MyPetTrackingScreen()));
                    },
                    icon: const Icon(Icons.manage_accounts_rounded, size: 16),
                    label: Text(appLang.translate('manage')),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              _buildPetsList(),
              SizedBox(height: 20.h),
              Text(
                appLang.translate('app_preferences'),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
              ),
              SizedBox(height: 10.h),
              _buildSettingsList(),
              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatiSupportCard(BuildContext context) {
    final appLang = AppLanguage.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF132A13), Color(0xFF1E3A1E), Color(0xFF0A180A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE67E22).withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(11.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE67E22).withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'PatiPlus',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFF39C12), Color(0xFFE67E22)]),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'PRO',
                        style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  appLang.translateDynamic('Reklamsız deneyim, sınırsız dijital pasaport & bağımsız yazılım desteği.'),
                  style: TextStyle(fontSize: 10.5.sp, color: Colors.white.withValues(alpha: 0.8), height: 1.3),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: () => PatiPlusSheet.show(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE67E22),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              elevation: 2,
              minimumSize: Size.zero,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.white),
                SizedBox(width: 4.w),
                Text(
                  appLang.translateDynamic('İncele'),
                  style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context) {
    final appLang = AppLanguage.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF27AE60).withValues(alpha: 0.12),
            const Color(0xFF2ECC71).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFF27AE60).withValues(alpha: 0.3), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLang.translate('feedback_title'),
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      appLang.translate('feedback_sub'),
                      style: TextStyle(fontSize: 11.5.sp, color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            appLang.translate('feedback_desc'),
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700, height: 1.35),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton.icon(
              onPressed: () => _showFeedbackModal(context),
              icon: const Icon(Icons.edit_note_rounded, size: 20, color: Colors.white),
              label: Text(
                appLang.translate('fill_form_btn'),
                style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    final appLang = AppLanguage.of(context);
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32.r,
            backgroundColor: const Color(0xFFE8F5E9),
            child: const Icon(Icons.person_rounded, size: 36, color: Color(0xFF27AE60)),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appLang.translate('pet_parent'),
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                ),
                SizedBox(height: 3.h),
                Text(
                  appLang.translate('family_member'),
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${GlobalState.pets.length} ${appLang.translate('pets_registered_count')}',
                    style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF27AE60)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineStatusCard() {
    final appLang = AppLanguage.of(context);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_done_rounded, color: Color(0xFF2E7D32), size: 26),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appLang.translate('offline_status'),
                  style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20)),
                ),
                SizedBox(height: 2.h),
                Text(
                  appLang.translate('offline_desc'),
                  style: TextStyle(fontSize: 11.sp, color: const Color(0xFF2E7D32)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsList() {
    final appLang = AppLanguage.of(context);
    if (GlobalState.pets.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.pets_rounded, size: 36.r, color: Colors.grey.shade400),
            SizedBox(height: 8.h),
            Text(
              appLang.translateDynamic('Henüz kayıtlı bir evcil hayvanın yok.'),
              style: TextStyle(fontSize: 13.sp, color: AppTheme.textLight),
            ),
            SizedBox(height: 12.h),
            TextButton.icon(
              onPressed: () async {
                await GlobalState.loadSampleDemoData();
                setState(() {});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(appLang.translateDynamic('Örnek veriler (Max, Luna, Maviş) yüklendi!'))),
                  );
                }
              },
              icon: const Icon(Icons.auto_awesome_rounded, size: 16, color: AppTheme.primary),
              label: Text(
                appLang.translateDynamic('💡 Örnek Demo Verilerini Yükle'),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        ...GlobalState.pets.asMap().entries.map((entry) {
          final int index = entry.key;
          final pet = entry.value;
          final String name = pet['name'] ?? '';
          final String type = pet['type'] ?? '';
          final String breed = pet['breed'] ?? 'Melez';
          final String chipNo = pet['chipNo'] ?? '';

          return Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundImage: GlobalState.getPetImage(pet['image'], type),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                      SizedBox(height: 2.h),
                      Text('${appLang.translatePetType(type)} • ${appLang.translateDynamic(breed)}', style: TextStyle(fontSize: 11.5.sp, color: AppTheme.textLight)),
                    ],
                  ),
                ),
                if (chipNo.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_2_rounded, size: 14, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(appLang.translate('chipped'), style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                  tooltip: appLang.translate('delete'),
                  onPressed: () => _confirmDeletePet(index, name),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => MyPetTrackingScreen()));
                  },
                )
              ],
            ),
          );
        }),
        if (GlobalState.pets.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _confirmClearAllData,
              icon: const Icon(Icons.delete_sweep_rounded, size: 16, color: Colors.redAccent),
              label: Text(
                appLang.translateDynamic('Tüm Demo / Test Verilerini Sil'),
                style: TextStyle(fontSize: 11.5.sp, color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _confirmDeletePet(int index, String petName) {
    final appLang = AppLanguage.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            const Icon(Icons.delete_forever_rounded, color: Colors.red),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                '$petName ${appLang.translateDynamic('silinsin mi?')}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ),
          ],
        ),
        content: Text(
          appLang.translateDynamic('Bu evcil dostu ve tüm sağlık, aşı ve beslenme kayıtlarını kalıcı olarak silmek istediğinize emin misiniz?'),
          style: TextStyle(fontSize: 13.sp, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(appLang.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                GlobalState.removePet(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red.shade700,
                  content: Text('$petName ${appLang.translateDynamic('profili silindi.')}'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(appLang.translate('delete'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmClearAllData() {
    final appLang = AppLanguage.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            const Icon(Icons.cleaning_services_rounded, color: Colors.red),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                appLang.translateDynamic('Tüm Verileri Temizle'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ),
          ],
        ),
        content: Text(
          appLang.translateDynamic('Tüm evcil hayvan profilleri ve kayıtları sıfırlanacaktır. Uygulamayı sıfır kurulum durumuna getirmek istediğinize emin misiniz?'),
          style: TextStyle(fontSize: 13.sp, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(appLang.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await GlobalState.clearAllUserPets();
              setState(() {});
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red.shade700,
                    content: Text(appLang.translateDynamic('Tüm test verileri temizlendi. Uygulama sıfırlandı.')),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(appLang.translate('delete'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    final appLanguage = AppLanguage.of(context);
    final currentLang = AppLanguage.supportedLanguages.firstWhere(
      (l) => l.code == appLanguage.currentLanguage,
      orElse: () => AppLanguage.supportedLanguages.first,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.language_rounded, color: Color(0xFFE67E22)),
            title: Text(appLanguage.translate('language_selection'), style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w600)),
            subtitle: Text('TR, DE, RU, EN, FR, ES (Multi-Language)', style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight)),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10.r), border: Border.all(color: Colors.grey.shade300)),
              child: Text(
                '${currentLang.flag} ${currentLang.name}',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
            ),
            onTap: () => _showLanguageModal(context),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(appLanguage.translate('notifications'), style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w600)),
            subtitle: Text(appLanguage.translate('notifications_sub'), style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight)),
            secondary: const Icon(Icons.notifications_active_outlined, color: Color(0xFF27AE60)),
            activeThumbColor: const Color(0xFF27AE60),
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(appLanguage.translate('offline_cache'), style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w600)),
            subtitle: Text(appLanguage.translate('offline_desc'), style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight)),
            secondary: const Icon(Icons.storage_rounded, color: Color(0xFF3498DB)),
            activeThumbColor: const Color(0xFF3498DB),
            value: _offlineCacheActive,
            onChanged: (v) => setState(() => _offlineCacheActive = v),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
            title: Text(appLanguage.translateDynamic('Tüm Test Verilerini Temizle'), style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w600, color: Colors.red.shade700)),
            subtitle: Text(appLanguage.translateDynamic('Evcil hayvanları ve kayıtları sıfırla'), style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            onTap: _confirmClearAllData,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded, color: Colors.grey),
            title: Text(appLanguage.translate('app_version'), style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w600)),
            trailing: Text(appLanguage.translateDynamic('v1.0.0 (Canlı)'), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF27AE60))),
          ),
        ],
      ),
    );
  }
}
