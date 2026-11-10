import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/global_state.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_language.dart';
import '../../services/ad_service.dart';

class BehaviorDashboardScreen extends StatefulWidget {
  @override
  _BehaviorDashboardScreenState createState() => _BehaviorDashboardScreenState();
}

class _BehaviorDashboardScreenState extends State<BehaviorDashboardScreen> {
  int _selectedPetIndex = 0;
  String _activeCategoryTab = 'Seçili Dost';

  final Map<String, List<Map<String, String>>> _behaviorGuides = {
    'Köpek': [
      {'title': 'Aşırı Havlama Sorunu', 'desc': 'Havlama köpeğin konuşma şeklidir. Bağırmak yerine neden havladığını anlayın: Sıkılmış olabilir (yürüyüşü uzatın), yalnızlık korkusu olabilir veya bölgesini koruyordur. Sustuğu anda ödül vererek sakin kalmayı pekiştirin.', 'icon': 'front_hand_rounded', 'color': '0xFFE74C3C', 'category': 'İletişim'},
      {'title': 'Eşyaları Kemirme', 'desc': 'Yavrularda diş kaşıntısı, yetişkinlerde ise stres veya enerji fazlalığı kemirmeye yol açar. Yanlış bir eşyayı aldığında kızmak yerine sakince elinden alıp kendi oyuncağını verin ve onu kemirdiğinde övün.', 'icon': 'pets', 'color': '0xFFF39C12', 'category': 'Alışkanlık'},
      {'title': 'Yabancılara Agresyon', 'desc': 'Bilinmeyenden korkarlar. Onu kalabalığa zorlamayın; yeni insanlarla uzaktan ve ödül maması eşliğinde pozitif tanıştırma yapın.', 'icon': 'shield', 'color': '0xFF3498DB', 'category': 'Sosyalleşme'},
      {'title': 'Üstüne Atlama', 'desc': 'Sevgi gösterisi için atlar. Üstünüze atladığında arkanızı dönün ve kollarınızı bağlayın. Dört patisi yere bastığı an dönüp sevin.', 'icon': 'front_hand_rounded', 'color': '0xFF9B59B6', 'category': 'İtaat'},
    ],
    'Kedi': [
      {'title': 'Eşyaları Tırmalama', 'desc': 'Kediler eski tırnak kabuğunu atmak için tırmalamak zorundadır. Koltuk kenarlarına tırmalama tahtası koyup catnip sıkın.', 'icon': 'front_hand_rounded', 'color': '0xFF9B59B6', 'category': 'İçgüdü'},
      {'title': 'Gece Enerjisi (Zoomies)', 'desc': 'Gece sizi uyutmasını istemiyorsanız, uyumadan hemen önce olta oyuncakla 15 dakika yorup ardından yaş mama verin; doyan kedi mışıl mışıl uyur.', 'icon': 'nightlight_round', 'color': '0xFF34495E', 'category': 'Uyku Düzeni'},
      {'title': 'Kum Kabı Dışı Tuvalet', 'desc': 'Kuma gitmiyorsa kumu kirlidir, kokulu kumdan rahatsızdır ya da idrar yolu enfeksiyonu olabilir. Kumu her gün temizleyin ve veterinerinize danışın.', 'icon': 'cleaning_services', 'color': '0xFF16A085', 'category': 'Tuvalet'},
    ],
    'Kuş': [
      {'title': 'Kafes İçinde Çırpınma', 'desc': 'Ani hareketler, yüksek ses veya gece karanlığı korkutur. Kafesin arkasını duvara yaslayın ve geceleri üzerini ince bir örtüyle hafifçe örtün.', 'icon': 'pets', 'color': '0xFFE74C3C', 'category': 'Stres'},
      {'title': 'Sürekli Çığlık Atma', 'desc': 'İlgi veya kafesten çıkmak istiyordur. Bağırdığında yanına gitmeyin (bağırmayı ilgi sanır); sessizleştiğinde yanına gidip ödüllendirin.', 'icon': 'front_hand_rounded', 'color': '0xFF3498DB', 'category': 'İletişim'},
    ],
    'Tavşan': [
      {'title': 'Ayak Vurma (Thumping)', 'desc': 'Arka ayağını sertçe yere vurması tehlike hissettiğini veya bir şeye çok kızdığını gösterir. Ortamı sakinleştirin ve onu kendi haline bırakın.', 'icon': 'pets', 'color': '0xFFE74C3C', 'category': 'İletişim'},
      {'title': 'Kablo & Halı Kemirme', 'desc': 'Dişleri sürekli uzadığı için sert şeyleri kemirmek zorundadır. Elma dalı ve hasır kemirme matları vererek mobilyaları koruyun.', 'icon': 'pets', 'color': '0xFFF39C12', 'category': 'İçgüdü'},
      {'title': 'Mutluluk Zıplaması (Binky)', 'desc': 'Havaya sıçrayıp kafasını ve gövdesini kıvırması aşırı mutlu ve güvende olduğunu gösterir, tamamen normal ve harika bir işarettir.', 'icon': 'sentiment_very_satisfied_rounded', 'color': '0xFF2ECC71', 'category': 'Mutluluk'},
    ],
    'Hamster': [
      {'title': 'Kafes Tellerini Kemirme', 'desc': 'Kafesi çok küçük olduğunda veya sıkıldığında telleri kemirir. Daha büyük tabanlı bir kafes ve kalın talaş katmanı sağlayın.', 'icon': 'pets', 'color': '0xFFF39C12', 'category': 'Stres'},
      {'title': 'Gündüzleri Uyumama', 'desc': 'Hamsterlar gececil (nocturnal) canlılardır. Gündüz uyurken onu uyandırmak ısırmasına ve ciddi strese yol açar, akşamları ilgilenin.', 'icon': 'nightlight_round', 'color': '0xFF34495E', 'category': 'Biyolojik Saat'},
    ],
    'Balık': [
      {'title': 'Su Yüzeyinde Hava Alma', 'desc': 'Balıklar su yüzeyinde ağızlarını açıp kapıyorsa sudaki oksijen bitmiş veya su aşırı kirlenmiştir. Hava motorunu kontrol edin ve derhal %30 su değişimi yapın.', 'icon': 'water_rounded', 'color': '0xFFE74C3C', 'category': 'Hayati Uyarı'},
      {'title': 'Akvaryum Dibinde Hareketsizlik', 'desc': 'Isıtıcı arızası nedeniyle su soğumuş olabilir veya nitrat zehirlenmesi başlamıştır. Su sıcaklığını ve filtre akışını kontrol edin.', 'icon': 'thermostat_rounded', 'color': '0xFF3498DB', 'category': 'Sağlık'},
    ],
    'Diğer': [
      {'title': 'Yeni Eve Alışma', 'desc': 'İlk günler karanlık ve sessiz yerlere saklanmak isterler. Zorlamayın, suyunu ve yemini bırakıp güven kazanmasını bekleyin.', 'icon': 'shield', 'color': '0xFF95A5A6', 'category': 'Uyum'},
    ]
  };

  void _showAddPetModal() {
    final appLang = AppLanguage.of(context);
    final nameController = TextEditingController();
    String petType = 'Köpek';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              title: Text(appLang.translate('add_pet_title'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: InputDecoration(labelText: appLang.translate('pet_name'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    value: petType,
                    items: ['Köpek', 'Kedi', 'Kuş', 'Tavşan', 'Hamster', 'Balık', 'Diğer'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setDialogState(() => petType = val!),
                    decoration: InputDecoration(labelText: appLang.translate('pet_type_label'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(appLang.translate('cancel'))),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      setState(() {
                        GlobalState.addNewPet(nameController.text.trim(), petType);
                        _selectedPetIndex = GlobalState.pets.length - 1;
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text(appLang.translate('add')),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _showActionModal({Map<String, dynamic>? issue, int? index}) {
    final appLang = AppLanguage.of(context, listen: false);
    final titleController = TextEditingController(text: issue != null ? appLang.translateDynamic(issue['title']?.toString() ?? '') : '');
    final dateController = TextEditingController(text: issue != null ? appLang.translateDate(issue['date']?.toString() ?? '') : appLang.translate('today'));
    final notesController = TextEditingController(text: issue != null ? appLang.translateDynamic(issue['notes']?.toString() ?? '') : '');
    String severity = issue != null ? (issue['severity']?.toString() ?? 'Hafif') : 'Hafif';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          issue != null ? appLang.translate('edit_behavior') : appLang.translate('new_behavior'),
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        if (issue != null && index != null)
                          IconButton(
                            tooltip: appLang.translate('delete'),
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 24),
                            onPressed: () {
                              final petName = GlobalState.pets[_selectedPetIndex]['name'];
                              setState(() {
                                if (GlobalState.behaviorIssues[petName] != null && index < GlobalState.behaviorIssues[petName]!.length) {
                                  GlobalState.behaviorIssues[petName]!.removeAt(index);
                                }
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(appLang.translate('delete'))),
                              );
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    TextField(controller: titleController, decoration: InputDecoration(labelText: appLang.translate('behavior_name_hint'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
                    SizedBox(height: 12.h),
                    TextField(controller: dateController, decoration: InputDecoration(labelText: appLang.translate('noticed_date_hint'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
                    SizedBox(height: 12.h),
                    TextField(controller: notesController, maxLines: 3, decoration: InputDecoration(labelText: appLang.translate('behavior_details_hint'), alignLabelWithHint: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
                    SizedBox(height: 16.h),
                    Text(appLang.translate('severity_frequency'), style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8,
                      children: ['Hafif', 'Orta', 'Şiddetli'].map((s) {
                        bool isSelected = severity == s;
                        Color color = s == 'Hafif' ? const Color(0xFF27AE60) : s == 'Orta' ? const Color(0xFFF39C12) : const Color(0xFFE74C3C);
                        return ChoiceChip(
                          label: Text(s == 'Hafif' ? appLang.translate('severity_mild') : s == 'Orta' ? appLang.translate('severity_moderate') : appLang.translate('severity_high'), style: TextStyle(color: isSelected ? Colors.white : color)),
                          selected: isSelected,
                          selectedColor: color,
                          onSelected: (selected) {
                            if (selected) setModalState(() => severity = s);
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final date = dateController.text.trim();
                          final notes = notesController.text.trim();
                          if (title.isNotEmpty) {
                            setState(() {
                              Color c = severity == 'Hafif' ? const Color(0xFF27AE60) : severity == 'Orta' ? const Color(0xFFF39C12) : const Color(0xFFE74C3C);
                              final petName = GlobalState.pets[_selectedPetIndex]['name'];
                              GlobalState.behaviorIssues.putIfAbsent(petName, () => []);
                              if (index != null && index < GlobalState.behaviorIssues[petName]!.length) {
                                GlobalState.behaviorIssues[petName]![index] = {'title': title, 'date': date, 'severity': severity, 'notes': notes, 'color': c};
                              } else {
                                GlobalState.behaviorIssues[petName]!.add({'title': title, 'date': date, 'severity': severity, 'notes': notes, 'color': c});
                              }
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A085), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                        child: Text(appLang.translate('save'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  void _showGuideDetailModal(Map<String, String> guide) {
    final appLang = AppLanguage.of(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40.w, height: 5.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10.r))),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(color: const Color(0xFF16A085).withOpacity(0.12), borderRadius: BorderRadius.circular(8.r)),
                child: Text(appLang.translateDynamic(guide['category'] ?? 'Davranış'), style: TextStyle(color: const Color(0xFF16A085), fontWeight: FontWeight.bold, fontSize: 11.sp)),
              ),
              SizedBox(height: 10.h),
              Text(appLang.translateBehaviorTitle(guide['title'] ?? ''), style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
              SizedBox(height: 14.h),
              Text(appLang.translateBehaviorDesc(guide['title'] ?? '', guide['desc'] ?? ''), style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade800, height: 1.5)),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A085), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r))),
                  child: Text(appLang.translateDynamic('Anladım, Teşekkürler!'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedPetIndex >= GlobalState.pets.length) {
      _selectedPetIndex = 0;
    }
    final pet = GlobalState.pets.isNotEmpty ? GlobalState.pets[_selectedPetIndex] : {'name': 'Max', 'type': 'Köpek'};
    final petName = pet['name'] ?? 'Max';
    final petType = pet['type'] ?? 'Köpek';

    final issues = GlobalState.behaviorIssues[petName] ?? [];

    String guideKey = petType;
    if (_activeCategoryTab != 'Seçili Dost') {
      guideKey = _activeCategoryTab;
    }
    final guides = _behaviorGuides[guideKey] ?? _behaviorGuides['Diğer'] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 16.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 20.h),
              _buildTitleCard(),
              SizedBox(height: 16.h),
              _buildPetSelector(),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${AppLanguage.of(context).translate('behavior_tracking_title')} ($petName)',
                        style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton.icon(
                    onPressed: () => _showActionModal(),
                    icon: const Icon(Icons.add, color: Colors.white, size: 16),
                    label: Text(
                      AppLanguage.of(context).translate('add_record_btn').replaceAll('+ ', '').replaceAll('+', '').trim(),
                      style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A085),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                      minimumSize: Size.zero,
                    ),
                  )
                ],
              ),
              SizedBox(height: 14.h),
              if (issues.isEmpty)
                Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(AppLanguage.of(context).translateDynamic("Kayıtlı bir davranış sorunu bulunmuyor."), style: const TextStyle(color: Colors.grey))))
              else
                ...issues.asMap().entries.map((entry) => Padding(
                  padding: EdgeInsets.only(bottom: 12.0.h),
                  child: _buildIssueCard(entry.value, entry.key),
                )),
              SizedBox(height: 24.h),
              Text(AppLanguage.of(context).translate('behavior_guides_title'), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
              SizedBox(height: 10.h),
              _buildCategoryTabs(),
              SizedBox(height: 14.h),
              ...guides.map((g) => Padding(
                padding: EdgeInsets.only(bottom: 12.0.h),
                child: _buildGuideCard(g),
              )).toList(),
              SizedBox(height: 20.h),
              const PatiBannerAdWidget(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final appLang = AppLanguage.of(context);
    final categories = ['Seçili Dost', 'Köpek', 'Kedi', 'Kuş', 'Tavşan', 'Hamster', 'Balık'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSel = _activeCategoryTab == cat;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(
                cat == 'Seçili Dost' ? appLang.translate('selected_pet') : appLang.translatePetType(cat),
                style: TextStyle(
                  color: isSel ? Colors.white : AppTheme.textDark,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
              selected: isSel,
              selectedColor: const Color(0xFF16A085),
              backgroundColor: Colors.white,
              onSelected: (s) {
                if (s) setState(() => _activeCategoryTab = cat);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final appLang = AppLanguage.of(context);
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 18),
          ),
        ),
        SizedBox(width: 12.w),
        const Icon(Icons.pets, color: Color(0xFF1B5E20), size: 28),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appLang.translate('app_title'),
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                appLang.translate('behavior_guides_sub'),
                style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF16A085),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 32),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLanguage.of(context).translate('behavior'), style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                SizedBox(height: 4.h),
                Text(AppLanguage.of(context).translate('behavior_sub'), style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, height: 1.3)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPetSelector() {
    return SizedBox(
      height: 65.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: GlobalState.pets.length + 1,
        itemBuilder: (context, index) {
          if (index == GlobalState.pets.length) {
            return GestureDetector(
              onTap: _showAddPetModal,
              child: Container(
                margin: EdgeInsets.only(left: 8.w, right: 16.w),
                width: 55.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: const Icon(Icons.add, color: AppTheme.primary, size: 28),
              ),
            );
          }

          final pet = GlobalState.pets[index];
          final isSelected = index == _selectedPetIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPetIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(right: 14.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  CircleAvatar(radius: 18.r, backgroundImage: GlobalState.getPetImage(pet['image'], pet['type'] ?? 'Köpek')),
                  SizedBox(width: 10.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pet['name'], style: TextStyle(color: isSelected ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                      Text(AppLanguage.of(context).translatePetType(pet['type']), style: TextStyle(color: isSelected ? Colors.white70 : AppTheme.textLight, fontSize: 10.5.sp)),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIssueCard(Map<String, dynamic> issue, int index) {
    final appLang = AppLanguage.of(context);
    Color cardColor = (issue['color'] is Color) ? issue['color'] : const Color(0xFF16A085);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () => _showActionModal(issue: issue, index: index),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(color: cardColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.warning_amber_rounded, color: cardColor, size: 26),
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
                              appLang.translateDynamic(issue['title'] ?? ''),
                              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Material(
                            color: const Color(0xFF16A085).withOpacity(0.12),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _showActionModal(issue: issue, index: index),
                              child: Padding(
                                padding: EdgeInsets.all(12.w),
                                child: const Icon(Icons.edit_rounded, color: Color(0xFF16A085), size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text('${appLang.translate('form_severity')}: ${appLang.translateDynamic(issue['severity'])}', style: TextStyle(fontSize: 12.sp, color: cardColor, fontWeight: FontWeight.bold)),
                          SizedBox(width: 12.w),
                          const Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.textLight),
                          SizedBox(width: 4.w),
                          Text(appLang.translateDate(issue['date'] ?? ''), style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight)),
                        ],
                      ),
                      if (issue['notes'] != null && issue['notes'].toString().isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 6.0.h),
                          child: Text(appLang.translateDynamic(issue['notes']), style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, height: 1.3)),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(Map<String, String> guide) {
    final appLang = AppLanguage.of(context);
    return InkWell(
      onTap: () => _showGuideDetailModal(guide),
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(color: const Color(0xFF16A085).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.psychology_rounded, color: Color(0xFF16A085), size: 22),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6.r)),
                    child: Text(appLang.translatePetType(guide['category'] ?? ''), style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                  ),
                  SizedBox(height: 6.h),
                  Text(appLang.translateBehaviorTitle(guide['title'] ?? ''), style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  SizedBox(height: 4.h),
                  Text(appLang.translateBehaviorDesc(guide['title'] ?? '', guide['desc'] ?? ''), style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
