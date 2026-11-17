import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/global_state.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_language.dart';
import '../../services/care_guide_service.dart';

class CareDashboardScreen extends StatefulWidget {
  const CareDashboardScreen({super.key});

  @override
  State<CareDashboardScreen> createState() => _CareDashboardScreenState();
}

class _CareDashboardScreenState extends State<CareDashboardScreen> {
  int _selectedPetIndex = 0;
  Set<String> _checkedTasks = {};

  @override
  void initState() {
    super.initState();
    _loadCheckedTasks();
  }

  Future<void> _loadCheckedTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentPet = _currentPet;
      final petKey = 'care_tasks_${currentPet['id'] ?? currentPet['name']}';
      final list = prefs.getStringList(petKey) ?? [];
      if (mounted) {
        setState(() {
          _checkedTasks = list.toSet();
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleTask(String task) async {
    setState(() {
      if (_checkedTasks.contains(task)) {
        _checkedTasks.remove(task);
      } else {
        _checkedTasks.add(task);
      }
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentPet = _currentPet;
      final petKey = 'care_tasks_${currentPet['id'] ?? currentPet['name']}';
      await prefs.setStringList(petKey, _checkedTasks.toList());
    } catch (_) {}
  }

  Map<String, dynamic> get _currentPet {
    if (GlobalState.pets.isEmpty) {
      return {'name': 'Dostum', 'type': 'Köpek', 'image': 'assets/images/dog_avatar.png'};
    }
    if (_selectedPetIndex >= GlobalState.pets.length) {
      _selectedPetIndex = 0;
    }
    return GlobalState.pets[_selectedPetIndex];
  }

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
              title: Text(
                appLang.translate('add_pet_title'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: appLang.translate('pet_name'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    initialValue: petType,
                    items: ['Köpek', 'Kedi', 'Kuş', 'Tavşan', 'Hamster', 'Balık', 'Diğer']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => petType = val!),
                    decoration: InputDecoration(
                      labelText: appLang.translate('pet_type_label'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
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
                        _loadCheckedTasks();
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text(appLang.translate('add')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDetailedCareSheet(CareCategoryDetail item, String petName, String petType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            children: [
              // Modal Top Grabber
              SizedBox(height: 12.h),
              Center(
                child: Container(
                  width: 44.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Modal Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(item.icon, color: item.color, size: 28),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            '$petName ($petType) İçin Rehber',
                            style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),

              // Modal Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sıklık Rozeti
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4ECF7),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFD7BDE2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.alarm_on_rounded, color: Color(0xFF8E44AD), size: 20),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Sıklık: ${item.frequency}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF5B2C6F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Neden Önemli?
                      _buildSectionCard(
                        icon: Icons.lightbulb_outline_rounded,
                        iconColor: const Color(0xFFF39C12),
                        title: 'Neden Hayati Önem Taşır?',
                        content: item.whyImportant,
                      ),
                      SizedBox(height: 16.h),

                      // Gerekli Malzemeler
                      if (item.supplies.isNotEmpty) ...[
                        _buildSectionHeader(Icons.shopping_bag_outlined, 'Gerekli Malzemeler'),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: item.supplies.map((sup) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Color(0xFF27AE60), size: 18),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        sup,
                                        style: TextStyle(fontSize: 13.sp, color: AppTheme.textDark, height: 1.3),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],

                      // Adım Adım Nasıl Yapılır?
                      _buildSectionHeader(Icons.format_list_numbered_rounded, 'Hiç Bilmeyene Adım Adım Uygulama'),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDFEFE),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFFD6DBDF)),
                        ),
                        child: Column(
                          children: item.stepByStep.map((step) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 8.w,
                                    height: 8.w,
                                    margin: EdgeInsets.only(top: 6.h, right: 10.w),
                                    decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
                                  ),
                                  Expanded(
                                    child: Text(
                                      step,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: AppTheme.textDark,
                                        height: 1.45,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Altın Kurallar & Püf Noktaları
                      if (item.goldenRules.isNotEmpty) ...[
                        _buildSectionHeader(Icons.star_rounded, 'Püf Noktaları & Tavsiyeler'),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF9E7),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: const Color(0xFFF9E79F)),
                          ),
                          child: Column(
                            children: item.goldenRules.map((rule) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.tips_and_updates_rounded, color: Color(0xFFF39C12), size: 18),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        rule,
                                        style: TextStyle(fontSize: 12.5.sp, color: const Color(0xFF7D6608), height: 1.35),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],

                      // ⚠️ ASLA Yapılmaması Gerekenler
                      if (item.dangerWarnings.isNotEmpty) ...[
                        _buildSectionHeader(Icons.warning_amber_rounded, 'ASLA Yapılmaması Gerekenler! (Hayati Uyarı)'),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDEDEC),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: const Color(0xFFF5B7B1)),
                          ),
                          child: Column(
                            children: item.dangerWarnings.map((warn) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.cancel_rounded, color: Color(0xFFE74C3C), size: 18),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        warn,
                                        style: TextStyle(
                                          fontSize: 12.5.sp,
                                          color: const Color(0xFF78281F),
                                          fontWeight: FontWeight.w600,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],

                      // 💡 Veteriner Hekim Tüyosu
                      if (item.vetTip.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F5),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: const Color(0xFFA3E4D7)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.health_and_safety_rounded, color: Color(0xFF16A085), size: 24),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Veteriner Hekim Tüyosu',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0E6251),
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      item.vetTip,
                                      style: TextStyle(
                                        fontSize: 12.5.sp,
                                        color: const Color(0xFF117A65),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],

                      // Anladım / Kapat Butonu
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.color,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          ),
                          child: Text(
                            'Rehberi Tamamladım',
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textDark),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: TextStyle(fontSize: 13.sp, color: AppTheme.textDark, height: 1.45),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pet = _currentPet;
    final petName = pet['name']?.toString() ?? 'Dostum';
    final petType = pet['type']?.toString() ?? 'Köpek';
    final profile = CareGuideService.getProfileForPetType(petType, petName);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 16.h),

              // Pet Selector Bar
              _buildPetSelector(),
              SizedBox(height: 18.h),

              // Dynamic Intro Banner for selected Pet
              _buildIntroCard(profile, petName, petType),
              SizedBox(height: 20.h),

              // Altın Kurallar (Beginner Golden Rules)
              _buildGoldenRulesSection(profile, petName),
              SizedBox(height: 24.h),

              // Ana Bakım Kategorileri
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$petType Bakım Rehberleri',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                  ),
                  Text(
                    'Detay için dokunun',
                    style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _buildCareCategoriesGrid(profile, petName, petType),
              SizedBox(height: 24.h),

              // Haftalık Bakım Kontrol Listesi (Interactive Checklist)
              _buildWeeklyChecklistSection(profile, petName),
              SizedBox(height: 24.h),

              // Doğru Bilinen Yanlışlar (Myth vs Fact)
              _buildCommonMistakesSection(profile),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 20),
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)]),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: const Icon(Icons.spa_rounded, color: Colors.white, size: 24),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kapsamlı Bakım Rehberi',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Hiç bilmeyene adım adım bakım ve sağlık',
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

  Widget _buildPetSelector() {
    return SizedBox(
      height: 68.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: GlobalState.pets.length + 1,
        itemBuilder: (context, index) {
          if (index == GlobalState.pets.length) {
            return GestureDetector(
              onTap: _showAddPetModal,
              child: Container(
                margin: EdgeInsets.only(left: 6.w, right: 12.w, top: 4.h, bottom: 4.h),
                width: 58.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: const Icon(Icons.add, color: Color(0xFF8E44AD), size: 28),
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
              _loadCheckedTasks();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(right: 12.w, top: 4.h, bottom: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF8E44AD) : Colors.white,
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(
                  color: isSelected ? const Color(0xFF8E44AD) : Colors.grey.shade200,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF8E44AD).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 19.r,
                    backgroundImage: GlobalState.getPetImage(pet['image'], pet['type'] ?? 'Köpek'),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet['name'] ?? 'Dostum',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5.sp,
                        ),
                      ),
                      Text(
                        AppLanguage.of(context).translatePetType(pet['type'] ?? 'Köpek'),
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : AppTheme.textLight,
                          fontSize: 10.5.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIntroCard(PetCareProfile profile, String petName, String petType) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C3483), Color(0xFF8E44AD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E44AD).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '$petType Özel Rehberi',
                  style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              const Icon(Icons.verified_rounded, color: Color(0xFFF1C40F), size: 20),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            profile.introTitle,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            profile.introSubtitle,
            style: TextStyle(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.9), height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildGoldenRulesSection(PetCareProfile profile, String petName) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF9E79F)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9E7),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: const Icon(Icons.star_rounded, color: Color(0xFFF39C12), size: 22),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İlk Kez Bakanlar İçin 5 Altın Kural',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    Text(
                      '$petName için hayat kurtaran pratik bilgiler',
                      style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Column(
            children: profile.beginnerRules.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final rule = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.w,
                      margin: EdgeInsets.only(top: 2.h),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF39C12),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$idx',
                        style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        rule,
                        style: TextStyle(fontSize: 12.5.sp, color: AppTheme.textDark, height: 1.35),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCareCategoriesGrid(PetCareProfile profile, String petName, String petType) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: profile.categories.length,
      separatorBuilder: (ctx, i) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = profile.categories[index];
        return InkWell(
          onTap: () => _showDetailedCareSheet(item, petName, petType),
          borderRadius: BorderRadius.circular(18.r),
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(item.icon, color: item.color, size: 26),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        item.subtitle,
                        style: TextStyle(fontSize: 11.5.sp, color: AppTheme.textLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(Icons.repeat_rounded, size: 14, color: item.color),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              item.frequency,
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w600,
                                color: item.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyChecklistSection(PetCareProfile profile, String petName) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFD4EFDF)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8F5),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: const Icon(Icons.checklist_rounded, color: Color(0xFF27AE60), size: 22),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Haftalık Bakım Kontrolü',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    Text(
                      '$petName için bu haftanın rutinleri',
                      style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
              Text(
                '${_checkedTasks.length} / ${profile.defaultWeeklyChecklist.length}',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF27AE60)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Column(
            children: profile.defaultWeeklyChecklist.map((task) {
              final isChecked = _checkedTasks.contains(task);
              return InkWell(
                onTap: () => _toggleTask(task),
                borderRadius: BorderRadius.circular(10.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: Row(
                    children: [
                      Icon(
                        isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                        color: isChecked ? const Color(0xFF27AE60) : Colors.grey.shade400,
                        size: 22,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          task,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            color: isChecked ? Colors.grey.shade500 : AppTheme.textDark,
                            decoration: isChecked ? TextDecoration.lineThrough : null,
                            fontWeight: isChecked ? FontWeight.normal : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonMistakesSection(PetCareProfile profile) {
    if (profile.commonMistakes.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFFADBD8)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDEDEC),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: const Icon(Icons.fact_check_rounded, color: Color(0xFFE74C3C), size: 22),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sık Yapılan Hatalar (Efsaneler vs Gerçekler)',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    Text(
                      'Doğru bilinen ölümcül bakım yanılgıları',
                      style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Column(
            children: profile.commonMistakes.map((item) {
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.close_rounded, color: Color(0xFFE74C3C), size: 18),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Yanlış: ${item.myth}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF922B21),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_rounded, color: Color(0xFF27AE60), size: 18),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Doğrusu: ${item.fact}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF196F3D),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
