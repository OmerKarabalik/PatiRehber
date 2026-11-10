import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/global_state.dart';
import '../theme/app_theme.dart';
import '../localization/app_language.dart';
import 'knowledge_base/pet_selection_screen.dart';
import 'sitter_search_screen.dart';
import 'health/health_dashboard_screen.dart';
import 'health/vaccine_schedule_screen.dart';
import 'health/health_records_screen.dart';
import 'health/vet_appointments_screen.dart';
import 'health/emergency_screen.dart';
import 'health/disease_symptoms_screen.dart';
import 'health/medication_tracking_screen.dart';
import 'nutrition/nutrition_dashboard_screen.dart';
import 'education/education_dashboard_screen.dart';
import 'behavior/behavior_dashboard_screen.dart';
import 'care/care_dashboard_screen.dart';
import 'my_pet_tracking_screen.dart';
import 'reminders_screen.dart';
import '../services/pdf_passport_service.dart';
import '../services/ad_service.dart';

class _SearchItem {
  final String title;
  final String category;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> keywords;
  final Widget Function() destination;

  const _SearchItem({
    required this.title,
    required this.category,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.keywords,
    required this.destination,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_SearchItem> _getAllSearchItems(AppLanguage appLang) {
    return [
      _SearchItem(
        title: appLang.translateDynamic('Aşı Takvimi & Dozlar'),
        category: appLang.translate('health'),
        subtitle: appLang.translateDynamic('Karma, kuduz, parazit aşıları ve alarm takvimi'),
        icon: Icons.vaccines_rounded,
        color: const Color(0xFF27AE60),
        keywords: ['aşı', 'karma', 'kuduz', 'lösemi', 'parazit', 'iç parazit', 'dış parazit', 'doz', 'takvim', 'alarm', 'vaccine', 'impfung', 'vacuna'],
        destination: () => VaccineScheduleScreen(),
      ),
      _SearchItem(
        title: appLang.translateDynamic('Beslenme & Mama Planı'),
        category: appLang.translate('nutrition'),
        subtitle: appLang.translateDynamic('Günlük porsiyon, doğru mama seçimi, su tüketimi'),
        icon: Icons.restaurant_rounded,
        color: const Color(0xFFF39C12),
        keywords: ['beslenme', 'mama', 'porsiyon', 'kuru mama', 'yaş mama', 'öğün', 'su', 'tarif', 'protein', 'nutrition', 'futter', 'nourriture', 'comida'],
        destination: () => NutritionDashboardScreen(),
      ),
      _SearchItem(
        title: appLang.translateDynamic('Veteriner & Acil Klinikler'),
        category: appLang.translate('clinics'),
        subtitle: appLang.translateDynamic('7/24 nöbetçi hayvan hastaneleri, yol tarifi ve arama'),
        icon: Icons.local_hospital_rounded,
        color: const Color(0xFFE74C3C),
        keywords: ['veteriner', 'klinik', 'nöbetçi', 'acil klinik', 'hastane', 'doktor', 'kadıköy', 'beşiktaş', 'çankaya', 'muratpaşa', 'karşıyaka', 'clinic', 'vet', 'tierarzt'],
        destination: () => const SitterSearchScreen(),
      ),
      _SearchItem(
        title: appLang.translateDynamic('Acil Durum & İlk Yardım'),
        category: appLang.translateDynamic('Acil Durum'),
        subtitle: appLang.translateDynamic('Zehirlenme, kanama, sıcak çarpması ve kırık müdahalesi'),
        icon: Icons.emergency_rounded,
        color: const Color(0xFFC0392B),
        keywords: ['acil', 'zehirlenme', 'kanama', 'sıcak çarpması', 'kaza', 'düşme', 'nefes', 'ilk yardım', 'koma', 'emergency', 'notfall', 'urgence'],
        destination: () => EmergencyScreen(),
      ),
      _SearchItem(
        title: appLang.translateDynamic('Hastalık Belirtileri & Teşhis'),
        category: appLang.translate('health'),
        subtitle: appLang.translateDynamic('İştahsızlık, halsizlik, kaşınma ve alarm veren semptomlar'),
        icon: Icons.health_and_safety_rounded,
        color: const Color(0xFFE67E22),
        keywords: ['belirti', 'hastalık', 'iştahsızlık', 'kusma', 'ishal', 'halsizlik', 'kaşınma', 'tüy dökme', 'ateş', 'symptom', 'disease'],
        destination: () => DiseaseSymptomsScreen(),
      ),
      _SearchItem(
        title: appLang.translateDynamic('Sağlık Kayıtları & Tahlil'),
        category: appLang.translate('health'),
        subtitle: appLang.translateDynamic('Geçmiş tedaviler, ameliyatlar, tahliller ve alerjiler'),
        icon: Icons.folder_shared_rounded,
        color: const Color(0xFF2980B9),
        keywords: ['sağlık kayıt', 'kayıt', 'tahlil', 'geçmiş', 'tedavi', 'ameliyat', 'alerji', 'kan grubu', 'medical records'],
        destination: () => HealthRecordsScreen(),
      ),
      _SearchItem(
        title: appLang.translateDynamic('İlaç Takibi & Dozaj'),
        category: appLang.translate('health'),
        subtitle: appLang.translateDynamic('Antibiyotik, vitamin, damla ve şurup hatırlatıcıları'),
        icon: Icons.medication_rounded,
        color: const Color(0xFF8E44AD),
        keywords: ['ilaç', 'vitamin', 'antibiyotik', 'damla', 'şurup', 'hap', 'dozaj', 'tedavi', 'medication'],
        destination: () => MedicationTrackingScreen(),
      ),
      _SearchItem(
        title: appLang.translateDynamic('Veteriner Randevuları'),
        category: appLang.translateDynamic('Randevu'),
        subtitle: appLang.translateDynamic('Yaklaşan doktor kontrolleri ve randevu alarmları'),
        icon: Icons.calendar_month_rounded,
        color: const Color(0xFF16A085),
        keywords: ['randevu', 'kontrol', 'doktor randevusu', 'muayene', 'appointment', 'termin'],
        destination: () => VetAppointmentsScreen(),
      ),
      _SearchItem(
        title: appLang.translateDynamic('Tuvalet & İtaat Eğitimi'),
        category: appLang.translate('education'),
        subtitle: appLang.translateDynamic('Otur, pati ver, bekle komutları ve ödül sistemi'),
        icon: Icons.school_rounded,
        color: const Color(0xFF2C3E50),
        keywords: ['eğitim', 'komut', 'tuvalet', 'otur', 'pati', 'tasma', 'ödül maması', 'itaat', 'training'],
        destination: () => EducationDashboardScreen(),
      ),
      _SearchItem(
        title: appLang.translateDynamic('Davranış & Psikoloji'),
        category: appLang.translate('behavior'),
        subtitle: appLang.translateDynamic('Miyavlama, havlama, tırmalama, korku ve stres yönetimi'),
        icon: Icons.pets_rounded,
        color: const Color(0xFF16A085),
        keywords: ['davranış', 'miyavlama', 'havlama', 'tırmalama', 'stres', 'korku', 'saldırganlık', 'kemirme', 'hırçınlık', 'behavior'],
        destination: () => BehaviorDashboardScreen(),
      ),
      _SearchItem(
        title: appLang.translateDynamic('Tüy Bakımı & Hijyen'),
        category: appLang.translate('care'),
        subtitle: appLang.translateDynamic('Banyo, tırnak kesimi, göz ve kulak temizliği'),
        icon: Icons.spa_rounded,
        color: const Color(0xFF1ABC9C),
        keywords: ['bakım', 'tüy', 'tarak', 'banyo', 'yıkama', 'tırnak', 'göz', 'kulak', 'hijyen', 'care', 'grooming'],
        destination: () => CareDashboardScreen(),
      ),
      _SearchItem(
        title: appLang.translateDynamic('Akıllı Hatırlatıcılar & Alarmlar'),
        category: appLang.translateDynamic('Hatırlatıcı'),
        subtitle: appLang.translateDynamic('Yaklaşan aşı, mama, ilaç ve randevu bildirimleri'),
        icon: Icons.alarm_rounded,
        color: const Color(0xFFE91E63),
        keywords: ['hatırlatıcı', 'alarm', 'bildirim', 'saat', 'uyarı', 'reminders'],
        destination: () => RemindersScreen(),
      ),
      _SearchItem(
        title: appLang.translateDynamic('Dijital Pati Pasaportu & PDF'),
        category: appLang.translateDynamic('Pati Takip'),
        subtitle: appLang.translateDynamic('Resmi PDF sağlık & aşı pasaportu çıktısı, çip no ve kilo grafiği'),
        icon: Icons.badge_rounded,
        color: const Color(0xFF1B5E20),
        keywords: ['pasaport', 'pdf', 'aşı karnesi', 'çip', 'kilo', 'ırk', 'doğum', 'yaş', 'kimlik', 'kısır', 'passport', 'print'],
        destination: () => MyPetTrackingScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        title: Transform.translate(
          offset: Offset(-12.w, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pets, color: AppTheme.primary, size: 28),
              SizedBox(width: 7.w),
              Text(appLang.brandPrefix, style: GoogleFonts.nunito(color: AppTheme.primary, fontSize: 24.sp, fontWeight: FontWeight.w900)),
              Text(appLang.brandSuffix, style: GoogleFonts.nunito(color: AppTheme.secondary, fontSize: 24.sp, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: AppLanguage.buildLanguagePill(context),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.secondary),
            tooltip: appLang.translateDynamic('Hatırlatıcılar & Bildirimler'),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => RemindersScreen()));
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isTablet ? 720 : double.infinity),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(context, appLang),
                SizedBox(height: 14.h),
                if (_searchQuery.isNotEmpty)
                  _buildSearchResults(context, appLang)
                else ...[
                  _buildGreetingAndPetBar(context, appLang),
                  SizedBox(height: 14.h),
                  _buildBanner(),
                  SizedBox(height: 18.h),
                  _buildGridMenu(context, appLang, screenWidth),
                  SizedBox(height: 20.h),
                  _buildPopularTopicsHeader(context, appLang),
                  SizedBox(height: 12.h),
                  _buildPopularTopicsList(context, appLang),
                  SizedBox(height: 16.h),
                  const PatiBannerAdWidget(),
                  SizedBox(height: 24.h),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLanguage appLang) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val.trim();
          });
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          hintText: appLang.translate('search_hint'),
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, AppLanguage appLang) {
    final allItems = _getAllSearchItems(appLang);
    final query = _searchQuery.toLowerCase();

    final matches = allItems.where((item) {
      if (item.title.toLowerCase().contains(query)) return true;
      if (item.subtitle.toLowerCase().contains(query)) return true;
      if (item.category.toLowerCase().contains(query)) return true;
      return item.keywords.any((k) => k.toLowerCase().contains(query));
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${appLang.translateDynamic('Arama Sonuçları')} (${matches.length})',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Text(
                appLang.translateDynamic('Temizle'),
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
            )
          ],
        ),
        SizedBox(height: 8.h),
        if (matches.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Column(
              children: [
                Icon(Icons.search_off_rounded, size: 48.r, color: Colors.grey.shade400),
                SizedBox(height: 12.h),
                Text(
                  appLang.translateDynamic('Aramanıza uygun başlık veya modül bulunamadı.'),
                  style: TextStyle(fontSize: 13.sp, color: AppTheme.textLight),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6.h),
                Text(
                  appLang.translateDynamic('İpucu: Aşı, Mama, Klinik, Acil, Eğitim kelimelerini deneyin.'),
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final item = matches[index];
              return Card(
                margin: EdgeInsets.only(bottom: 10.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                elevation: 1.5,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.r),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => item.destination()));
                  },
                  child: Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Icon(item.icon, color: item.color, size: 26.r),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppTheme.textDark),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      item.category,
                                      style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                item.subtitle,
                                style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildGreetingAndPetBar(BuildContext context, AppLanguage appLang) {
    final pets = GlobalState.pets;
    final hasPets = pets.isNotEmpty;

    if (!hasPets) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets_rounded, color: AppTheme.primary, size: 22),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appLang.translateDynamic('Evcil Dostunla Tanışalım'),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppTheme.textDark),
                  ),
                  Text(
                    appLang.translateDynamic('Aşı ve pasaport için ilk dostunu kaydet'),
                    style: TextStyle(fontSize: 10.5.sp, color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MyPetTrackingScreen()));
              },
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 3.w),
                    Text(
                      appLang.translateDynamic('Dostunu Ekle'),
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          _buildPetAvatarBadge(pets),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appLang.translateDynamic('Evcil Dostlarım'),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppTheme.textDark),
                ),
                Text(
                  '${pets.length} ${appLang.translateDynamic('Kayıt')} • ${appLang.translateDynamic('Sağlık Takibi Aktif')}',
                  style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  final activePet = pets.isNotEmpty ? pets.first : <String, dynamic>{'name': 'Max', 'type': 'Köpek'};
                  final petName = activePet['name']?.toString() ?? 'Max';
                  final vaccines = (GlobalState.vaccines[petName] as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
                  final records = (GlobalState.healthRecords[petName] as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
                  PdfPassportService.showRewardedPdfFlow(
                    context,
                    pet: activePet,
                    vaccines: vaccines,
                    healthRecords: records,
                  );
                },
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFF1B5E20).withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf_rounded, size: 13, color: Color(0xFF1B5E20)),
                      SizedBox(width: 3.w),
                      Text(
                        'PDF',
                        style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 5.w),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MyPetTrackingScreen()));
                },
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        appLang.translateDynamic('Görüntüle'),
                        style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                      SizedBox(width: 2.w),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 9, color: AppTheme.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPetAvatarBadge(List<dynamic> pets) {
    if (pets.isEmpty) {
      return Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.pets_rounded, color: AppTheme.primary, size: 22),
      );
    }

    if (pets.length == 1) {
      final pet = pets.first;
      return Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.35), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: CircleAvatar(
          radius: 20.r,
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          backgroundImage: GlobalState.getPetImage(pet['image'], pet['type'] ?? 'Köpek'),
        ),
      );
    }

    // 2 or more pets: stacked avatar effect!
    final count = pets.length > 3 ? 3 : pets.length;
    final double stackWidth = 36.w + (count - 1) * 16.w;
    return SizedBox(
      width: stackWidth,
      height: 42.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: List.generate(count, (index) {
          final pet = pets[index];
          return Positioned(
            left: index * 16.w,
            child: Container(
              padding: EdgeInsets.all(1.5.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: CircleAvatar(
                radius: 17.r,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                backgroundImage: GlobalState.getPetImage(pet['image'], pet['type'] ?? 'Köpek'),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 140.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        image: const DecorationImage(
          image: AssetImage('assets/images/home_banner.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
    );
  }

  Widget _buildGridMenu(BuildContext context, AppLanguage appLang, double screenWidth) {
    final List<Map<String, dynamic>> categories = [
      {'key': 'health', 'title': appLang.translate('health'), 'subtitle': appLang.translate('health_sub'), 'icon': Icons.medical_services_rounded, 'color': AppTheme.iconHealth},
      {'key': 'nutrition', 'title': appLang.translate('nutrition'), 'subtitle': appLang.translate('nutrition_sub'), 'icon': Icons.food_bank_rounded, 'color': AppTheme.iconNutrition},
      {'key': 'care', 'title': appLang.translate('care'), 'subtitle': appLang.translate('care_sub'), 'icon': Icons.spa_rounded, 'color': AppTheme.iconCare},
      {'key': 'education', 'title': appLang.translate('education'), 'subtitle': appLang.translate('education_sub'), 'icon': Icons.school_rounded, 'color': AppTheme.iconEducation},
      {'key': 'behavior', 'title': appLang.translate('behavior'), 'subtitle': appLang.translate('behavior_sub'), 'icon': Icons.pets_rounded, 'color': const Color(0xFF16A085)},
      {'key': 'sitters', 'title': appLang.translate('clinics'), 'subtitle': appLang.translate('clinics_sub'), 'icon': Icons.local_hospital_rounded, 'color': const Color(0xFFE74C3C)},
    ];

    final int columns = 3;

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        mainAxisExtent: 120.h,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final item = categories[index];
        return InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: () {
            if (item['key'] == 'sitters') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SitterSearchScreen()));
            } else if (item['key'] == 'health') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => HealthDashboardScreen()));
            } else if (item['key'] == 'nutrition') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => NutritionDashboardScreen()));
            } else if (item['key'] == 'care') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => CareDashboardScreen()));
            } else if (item['key'] == 'education') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => EducationDashboardScreen()));
            } else if (item['key'] == 'behavior') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => BehaviorDashboardScreen()));
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PetSelectionScreen(topic: item['title'])));
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 24.r),
                ),
                SizedBox(height: 6.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item['title'] as String,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5.sp, color: AppTheme.textDark),
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item['subtitle'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9.5.sp, color: AppTheme.textLight),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopularTopicsHeader(BuildContext context, AppLanguage appLang) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            appLang.translate('popular_topics'),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: AppTheme.textDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => EducationDashboardScreen()));
          },
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            child: Row(
              children: [
                Text(
                  appLang.translate('comprehensive_list'),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5.sp, color: AppTheme.primary),
                ),
                SizedBox(width: 3.w),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularTopicsList(BuildContext context, AppLanguage appLang) {
    final topics = [
      {
        'title': '${appLang.translate('dog')} • ${appLang.translate('care')}',
        'subtitle': 'Temel itaat, tuvalet ve tasma eğitimi...',
        'image': 'assets/images/dog_avatar.png',
        'type': 'Köpek',
        'alignment': Alignment.center,
      },
      {
        'title': '${appLang.translate('cat')} • ${appLang.translate('care')}',
        'subtitle': 'Kum alışkanlığı, tırmalama ve beslenme...',
        'image': 'assets/images/cat_avatar.png',
        'type': 'Kedi',
        'alignment': Alignment.center,
      },
      {
        'title': '${appLang.translate('bird')} • ${appLang.translate('care')}',
        'subtitle': 'Kafes ortamı, konuşma eğitimi ve vitaminler...',
        'image': 'assets/images/bird_avatar.png',
        'type': 'Kuş',
        'alignment': Alignment.topCenter,
      },
      {
        'title': '${appLang.translate('rabbit')} • ${appLang.translate('care')}',
        'subtitle': 'Tuvalet kabı eğitimi, kuru ot ve kemirme...',
        'image': 'assets/images/rabbit_avatar.png',
        'type': 'Tavşan',
        'alignment': const Alignment(0, -0.6),
      },
      {
        'title': '${appLang.translate('hamster')} • ${appLang.translate('care')}',
        'subtitle': 'Çark egzersizi, talaş seçimi ve gece düzeni...',
        'image': 'assets/images/hamster_avatar.png',
        'type': 'Hamster',
        'alignment': Alignment.center,
      },
      {
        'title': '${appLang.translate('fish')} • ${appLang.translate('care')}',
        'subtitle': 'Akvaryum su dengesi, filtre ve porsiyon...',
        'image': 'assets/images/fish_avatar.png',
        'type': 'Balık',
        'alignment': const Alignment(0, -0.4),
      },
    ];

    return SizedBox(
      height: 205.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PetSelectionScreen(topic: appLang.translate('care')),
                ),
              );
            },
            borderRadius: BorderRadius.circular(18.r),
            child: Container(
              width: 150.w,
              margin: EdgeInsets.only(right: 14.w, bottom: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: Colors.grey.shade100, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    child: Image.asset(
                      topic['image']! as String,
                      height: 100.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      alignment: (topic['alignment'] as Alignment?) ?? Alignment.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic['title']! as String,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5.sp, color: AppTheme.textDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          appLang.translateDynamic(topic['subtitle']! as String),
                          style: TextStyle(fontSize: 10.sp, color: AppTheme.textLight, height: 1.25),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
