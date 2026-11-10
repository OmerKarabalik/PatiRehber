import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/global_state.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_language.dart';
import '../../widgets/responsive_center.dart';
import '../../services/ad_service.dart';

class HealthRecordsScreen extends StatefulWidget {
  @override
  _HealthRecordsScreenState createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  int _selectedPetIndex = 0;
  String _selectedFilter = 'Tümü';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'Tümü',
    'Muayene',
    'Check-up',
    'Aşı/Parazit',
    'Ameliyat',
    'Tahlil',
    'Diş'
  ];

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Muayene':
        return const Color(0xFFE74C3C);
      case 'Check-up':
        return const Color(0xFF2ECC71);
      case 'Aşı/Parazit':
        return const Color(0xFF3498DB);
      case 'Ameliyat':
        return const Color(0xFF9B59B6);
      case 'Tahlil':
        return const Color(0xFF1ABC9C);
      case 'Diş':
        return const Color(0xFFF39C12);
      default:
        return const Color(0xFF1E824C);
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Muayene':
        return Icons.medical_services_rounded;
      case 'Check-up':
        return Icons.verified_user_rounded;
      case 'Aşı/Parazit':
        return Icons.vaccines_rounded;
      case 'Ameliyat':
        return Icons.healing_rounded;
      case 'Tahlil':
        return Icons.biotech_rounded;
      case 'Diş':
        return Icons.clean_hands_rounded;
      default:
        return Icons.monitor_heart_rounded;
    }
  }

  void _showAddPetModal() {
    final appLang = AppLanguage.of(context);
    final nameController = TextEditingController();
    String petType = 'Köpek';
    String breed = '';

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
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: appLang.translate('pet_name'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  DropdownButtonFormField<String>(
                    value: petType,
                    items: ['Köpek', 'Kedi', 'Kuş', 'Tavşan', 'Diğer']
                        .map((type) => DropdownMenuItem(value: type, child: Text(appLang.translatePetType(type))))
                        .toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        if (val != null) petType = val;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: appLang.translate('pet_type_label'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    decoration: InputDecoration(
                      labelText: appLang.translate('breed_label'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onChanged: (v) => breed = v,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(appLang.translate('cancel'), style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                ),
                ElevatedButton(
                  onPressed: () {
                    String petName = nameController.text.trim();
                    if (petName.isNotEmpty) {
                      setState(() {
                        GlobalState.addNewPet(petName, petType, breed: breed.isEmpty ? 'Melez' : breed);
                        _selectedPetIndex = GlobalState.pets.length - 1;
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E824C)),
                  child: Text(appLang.translate('add'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14.sp)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddRecordModal({Map<String, dynamic>? record, int? index}) {
    final appLang = AppLanguage.of(context);
    final titleController = TextEditingController(text: record != null ? appLang.translateDynamic(record['title']?.toString() ?? '') : '');
    final dateController = TextEditingController(text: record != null ? appLang.translateDate(record['date']?.toString() ?? '') : appLang.translate('today'));
    final nextControlController = TextEditingController(text: record != null ? appLang.translateDate(record['nextControlDate']?.toString() ?? '') : '');
    final doctorController = TextEditingController(text: record != null ? appLang.translateDynamic(record['doctor']?.toString() ?? '') : '');
    final prescriptionsController = TextEditingController(text: record != null ? appLang.translateDynamic(record['prescriptions']?.toString() ?? '') : '');
    final notesController = TextEditingController(text: record != null ? appLang.translateDynamic(record['notes']?.toString() ?? '') : '');
    String clinic = record != null ? appLang.translateDynamic(record['clinic']?.toString() ?? '') : '';
    String type = record != null ? (record['type']?.toString() ?? 'Muayene') : 'Muayene';

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          record != null ? appLang.translate('edit_health_record') : appLang.translate('new_health_record'),
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                        ),
                        if (record != null && index != null)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                            onPressed: () {
                              final petName = GlobalState.pets[_selectedPetIndex]['name'];
                              setState(() {
                                GlobalState.healthRecords[petName]?.removeAt(index);
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
                    Text(appLang.translate('record_type'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppTheme.textDark)),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        {'key': 'Muayene', 'label': appLang.translate('type_exam')},
                        {'key': 'Check-up', 'label': appLang.translate('type_checkup')},
                        {'key': 'Aşı/Parazit', 'label': appLang.translate('type_vaccine_parasite')},
                        {'key': 'Ameliyat', 'label': appLang.translate('type_surgery')},
                        {'key': 'Tahlil', 'label': appLang.translate('type_lab')},
                        {'key': 'Diş', 'label': appLang.translate('type_dental')},
                      ].map((item) {
                        final s = item['key']!;
                        final lbl = item['label']!;
                        bool isSelected = type == s;
                        Color c = _getColorForCategory(s);
                        return ChoiceChip(
                          label: Text(lbl, style: TextStyle(color: isSelected ? Colors.white : c, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                          selected: isSelected,
                          selectedColor: c,
                          backgroundColor: c.withOpacity(0.08),
                          onSelected: (selected) {
                            if (selected) setModalState(() => type = s);
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: appLang.translate('diagnosis_title'),
                        prefixIcon: const Icon(Icons.title_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: dateController,
                            decoration: InputDecoration(
                              labelText: appLang.translate('exam_date'),
                              prefixIcon: const Icon(Icons.calendar_today_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: TextField(
                            controller: nextControlController,
                            decoration: InputDecoration(
                              labelText: appLang.translate('next_control_date'),
                              prefixIcon: const Icon(Icons.event_repeat_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: doctorController,
                      decoration: InputDecoration(
                        labelText: appLang.translate('vet_clinic_address'),
                        prefixIcon: const Icon(Icons.local_hospital_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: prescriptionsController,
                      decoration: InputDecoration(
                        labelText: appLang.translate('prescriptions_label'),
                        prefixIcon: const Icon(Icons.medication_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: appLang.translate('treatment_notes'),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final date = dateController.text.trim();
                          final doctor = doctorController.text.trim();
                          final notes = notesController.text.trim();
                          final prescriptions = prescriptionsController.text.trim();
                          final nextControlDate = nextControlController.text.trim();

                          if (title.isNotEmpty) {
                            setState(() {
                              Color c = _getColorForCategory(type);
                              final petName = GlobalState.pets[_selectedPetIndex]['name'];
                              GlobalState.healthRecords.putIfAbsent(petName, () => []);

                              final newRecord = {
                                'title': title,
                                'date': date.isEmpty ? 'Tarih Belirtilmedi' : date,
                                'doctor': doctor.isEmpty ? 'Veteriner Belirtilmedi' : doctor,
                                'clinic': clinic.trim(),
                                'notes': notes.isEmpty ? 'Açıklama girilmedi.' : notes,
                                'prescriptions': prescriptions,
                                'nextControlDate': nextControlDate,
                                'type': type,
                                'color': c,
                              };

                              if (index != null && index < GlobalState.healthRecords[petName]!.length) {
                                GlobalState.healthRecords[petName]![index] = newRecord;
                              } else {
                                GlobalState.healthRecords[petName]!.insert(0, newRecord);
                              }
                            });
                            Navigator.pop(context);
                            AdService.onActionCompleted();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(appLang.translate('save'))),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E824C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        child: Text(
                          appLang.translate('complete_record_btn'),
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
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
    final hasPets = GlobalState.pets.isNotEmpty;

    if (!hasPets) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            appLang.translate('health_records'),
            style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w900, fontSize: 18.sp),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90.r,
                  height: 90.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B59B6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.folder_shared_rounded, color: Color(0xFF9B59B6), size: 45),
                ),
                SizedBox(height: 20.h),
                Text(
                  appLang.translateDynamic('Kayıtlı Evcil Dost Bulunamadı'),
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                SizedBox(height: 8.h),
                Text(
                  appLang.translateDynamic('Muayene, tahlil ve ameliyat geçmişini kaydetmek için önce bir evcil hayvan ekle.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp, color: AppTheme.textLight),
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: _showAddPetModal,
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: Text(
                    appLang.translateDynamic('🐾 Evcil Dostumu Ekle'),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B59B6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_selectedPetIndex >= GlobalState.pets.length) {
      _selectedPetIndex = 0;
    }
    final pet = GlobalState.pets[_selectedPetIndex];
    final petName = pet['name'] ?? 'Max';
    final allRecords = GlobalState.healthRecords[petName] ?? [];

    final filteredRecords = allRecords.where((r) {
      final matchesFilter = _selectedFilter == 'Tümü' || (r['type']?.toString() == _selectedFilter);
      final titleMatch = (r['title']?.toString() ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      final doctorMatch = (r['doctor']?.toString() ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      final notesMatch = (r['notes']?.toString() ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && (titleMatch || doctorMatch || notesMatch);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ResponsiveCenter(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 14.0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: 18.h),
                _buildTitleCard(),
                SizedBox(height: 16.h),
                _buildPetSelector(),
                SizedBox(height: 18.h),
                _buildSummaryStats(allRecords),
                SizedBox(height: 18.h),
                _buildSearchBar(),
                SizedBox(height: 12.h),
                _buildFilterChips(),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${AppLanguage.of(context).translate('health_records')} (${filteredRecords.length})',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton.icon(
                      onPressed: () => _showAddRecordModal(),
                      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                      label: Text(
                        AppLanguage.of(context).translate('add_record_btn').replaceAll('+ ', '').replaceAll('+', '').trim(),
                        style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E824C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                        minimumSize: Size.zero,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 14.h),
                if (filteredRecords.isEmpty)
                  _buildEmptyState()
                else
                  ...filteredRecords.map((record) {
                    int actualIndex = allRecords.indexOf(record);
                    return Padding(
                      padding: EdgeInsets.only(bottom: 14.0.h),
                      child: _buildRecordCard(record, actualIndex),
                    );
                  }).toList(),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appLang.translate('health_tracking_title'), style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
            Text(appLang.translate('health_tracking_sub'), style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight)),
          ],
        )
      ],
    );
  }

  Widget _buildTitleCard() {
    final appLang = AppLanguage.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1E824C),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: const Icon(Icons.description_rounded, color: Colors.white, size: 28),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appLang.translate('health_records'), style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                SizedBox(height: 3.h),
                Text(appLang.translate('health_records_desc'),
                    style: TextStyle(fontSize: 11.5.sp, color: AppTheme.textLight, height: 1.3)),
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
                margin: EdgeInsets.only(left: 6.w, right: 12.w),
                width: 55.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: const Icon(Icons.add_rounded, color: AppTheme.primary, size: 28),
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
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E824C) : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: isSelected
                    ? [BoxShadow(color: const Color(0xFF1E824C).withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundImage: GlobalState.getPetImage(pet['image'], pet['type'] ?? 'Köpek'),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet['name'] ?? '',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                      Text(
                        AppLanguage.of(context).translatePetType(pet['type']),
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : AppTheme.textLight,
                          fontSize: 10.5.sp,
                        ),
                      ),
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

  Widget _buildSummaryStats(List<Map<String, dynamic>> records) {
    final appLang = AppLanguage.of(context);
    int totalCount = records.length;
    String lastVisit = records.isNotEmpty ? (records.first['date'] ?? '-') : '-';
    String nextFollowup = '-';
    for (var r in records) {
      if (r['nextControlDate'] != null && r['nextControlDate'].toString().trim().isNotEmpty) {
        nextFollowup = r['nextControlDate'].toString();
        break;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(appLang.translateDynamic('Toplam Kayıt'), appLang.translateDynamic('$totalCount Adet'), Icons.folder_shared_rounded, const Color(0xFF1E824C)),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildStatItem(appLang.translateDynamic('Son Ziyaret'), appLang.translateDate(lastVisit), Icons.event_available_rounded, const Color(0xFF3498DB)),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildStatItem(appLang.translateDynamic('Kontrol'), appLang.translateDate(nextFollowup), Icons.notifications_active_rounded, const Color(0xFFF39C12)),
        ),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 6.h),
          Text(title, style: TextStyle(fontSize: 10.sp, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(fontSize: 11.5.sp, color: AppTheme.textDark, fontWeight: FontWeight.w900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final appLang = AppLanguage.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6)],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          icon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
          hintText: appLang.translateDynamic('Kayıtlarda veya hekim adında ara...'),
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
          border: InputBorder.none,
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final appLang = AppLanguage.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedFilter == cat;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(
                appLang.translateDynamic(cat),
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 11.5.sp,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF1E824C),
              backgroundColor: Colors.white,
              onSelected: (selected) {
                if (selected) setState(() => _selectedFilter = cat);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record, int index) {
    final appLang = AppLanguage.of(context);
    final String title = record['title']?.toString() ?? 'Kayıt';
    final String date = record['date']?.toString() ?? '';
    final String doctor = record['doctor']?.toString() ?? 'Veteriner Hekim';
    final String notes = record['notes']?.toString() ?? '';
    final String prescriptions = record['prescriptions']?.toString() ?? '';
    final String nextControlDate = record['nextControlDate']?.toString() ?? '';
    final String type = record['type']?.toString() ?? 'Muayene';
    final Color categoryColor = (record['color'] is Color) ? record['color'] : _getColorForCategory(type);
    final IconData categoryIcon = _getIconForCategory(type);

    return InkWell(
      onTap: () => _showAddRecordModal(record: record, index: index),
      borderRadius: BorderRadius.circular(22.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(categoryIcon, color: categoryColor, size: 22),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appLang.translateDynamic(title), style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(appLang.translateDynamic(type), style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: categoryColor)),
                          ),
                          SizedBox(width: 8.w),
                          Text(appLang.translateDate(date), style: TextStyle(fontSize: 11.5.sp, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: appLang.translate('edit_health_record'),
                  onPressed: () => _showAddRecordModal(record: record, index: index),
                  icon: const Icon(Icons.edit_rounded, color: AppTheme.primary, size: 22),
                )
              ],
            ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_hospital_rounded, size: 14, color: categoryColor),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        appLang.translateDynamic(doctor),
                        style: TextStyle(fontSize: 12.5.sp, color: AppTheme.textDark, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  appLang.translateDynamic(notes),
                  style: TextStyle(fontSize: 12.5.sp, color: Colors.grey.shade700, height: 1.4),
                ),
                if (prescriptions.trim().isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE67E22).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.medication_rounded, size: 15, color: Color(0xFFE67E22)),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            '${appLang.translate('prescriptions_label')}: ${appLang.translateDynamic(prescriptions)}',
                            style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFFD35400), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (nextControlDate.trim().isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      const Icon(Icons.event_repeat_rounded, size: 14, color: Color(0xFF27AE60)),
                      SizedBox(width: 6.w),
                      Text(
                        '${appLang.translate('next_control_date')}: ${appLang.translateDate(nextControlDate)}',
                        style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF27AE60), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          )
        ],
      ),
    ),
    );
  }

  Widget _buildEmptyState() {
    final appLang = AppLanguage.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined, size: 54, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(
            appLang.translateDynamic('Henüz Kayıt Yok'),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          SizedBox(height: 6.h),
          Text(
            appLang.translateDynamic('Bu evcil dostunuz için henüz bir sağlık geçmişi bulunmuyor. Yeni bir kayıt ekleyerek başlayabilirsiniz.'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, height: 1.4),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () => _showAddRecordModal(),
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: Text(appLang.translateDynamic('İlk Kaydı Oluştur'), style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E824C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
          )
        ],
      ),
    );
  }
}
