import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/global_state.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_language.dart';
import '../../widgets/responsive_center.dart';
import '../../services/ad_service.dart';

class MedicationTrackingScreen extends StatefulWidget {
  @override
  _MedicationTrackingScreenState createState() => _MedicationTrackingScreenState();
}

class _MedicationTrackingScreenState extends State<MedicationTrackingScreen> {
  int _selectedPetIndex = 0;

  

  

  void _showAddPetModal() {
    final appLang = AppLanguage.of(context);
    TextEditingController nameController = TextEditingController();
    String petType = 'Köpek';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              title: Text(appLang.translate('add_pet_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: InputDecoration(labelText: appLang.translate('pet_name'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    value: petType,
                    items: ['Köpek', 'Kedi', 'Kuş', 'Tavşan', 'Hamster', 'Balık', 'Diğer'].map((t) => DropdownMenuItem(value: t, child: Text(appLang.translatePetType(t)))).toList(),
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

  void _showActionModal({Map<String, dynamic>? med, int? index}) {
    final appLang = AppLanguage.of(context, listen: false);
    final titleController = TextEditingController(text: med != null ? appLang.translateDynamic(med['title']?.toString() ?? '') : '');
    final dosageController = TextEditingController(text: med != null ? appLang.translateDynamic(med['dosage']?.toString() ?? '') : '');
    final frequencyController = TextEditingController(text: med != null ? appLang.translateDynamic(med['frequency']?.toString() ?? '') : '');
    final nextTimeController = TextEditingController(text: med != null ? appLang.translateDynamic(med['nextTime']?.toString() ?? '') : '');
    String status = med != null ? (med['status']?.toString() ?? 'Aktif') : 'Aktif';

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
                          med != null ? appLang.translate('edit_medication') : appLang.translate('new_medication'),
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        if (med != null && index != null)
                          IconButton(
                            tooltip: appLang.translate('delete'),
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 24),
                            onPressed: () {
                              final petName = GlobalState.pets[_selectedPetIndex]['name'];
                              setState(() {
                                if (GlobalState.medications[petName] != null && index < GlobalState.medications[petName]!.length) {
                                  GlobalState.medications[petName]!.removeAt(index);
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
                    TextField(controller: titleController, decoration: InputDecoration(labelText: appLang.translate('medication_name'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
                    SizedBox(height: 12.h),
                    TextField(controller: dosageController, decoration: InputDecoration(labelText: appLang.translate('dosage_label'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
                    SizedBox(height: 12.h),
                    TextField(controller: frequencyController, decoration: InputDecoration(labelText: appLang.translate('frequency_label'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
                    SizedBox(height: 12.h),
                    TextField(controller: nextTimeController, decoration: InputDecoration(labelText: appLang.translate('next_use_label'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
                    SizedBox(height: 16.h),
                    Wrap(
                      spacing: 8,
                      children: [
                        {'key': 'Aktif', 'label': appLang.translate('status_active')},
                        {'key': 'Bitti', 'label': appLang.translate('status_finished')},
                      ].map((item) {
                        final s = item['key']!;
                        final lbl = item['label']!;
                        bool isSelected = status == s;
                        Color color = s == 'Aktif' ? const Color(0xFFE67E22) : Colors.grey.shade600;
                        return ChoiceChip(
                          label: Text(lbl, style: TextStyle(color: isSelected ? Colors.white : color)),
                          selected: isSelected,
                          selectedColor: color,
                          onSelected: (selected) {
                            if (selected) setModalState(() => status = s);
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
                          final dosage = dosageController.text.trim();
                          final frequency = frequencyController.text.trim();
                          final nextTime = nextTimeController.text.trim();
                          if (title.isNotEmpty) {
                            setState(() {
                              Color c = status == 'Aktif' ? const Color(0xFFE67E22) : Colors.grey;
                              final petName = GlobalState.pets[_selectedPetIndex]['name'];
                              if (index != null) {
                                GlobalState.medications[petName]![index] = {'title': title, 'dosage': dosage, 'frequency': frequency, 'nextTime': nextTime, 'status': status, 'color': c};
                              } else {
                                GlobalState.medications[petName]!.insert(0, {'title': title, 'dosage': dosage, 'frequency': frequency, 'nextTime': nextTime, 'status': status, 'color': c});
                              }
                            });
                            Navigator.pop(context);
                            AdService.onActionCompleted();
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE67E22), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
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
            appLang.translate('medication_tracking'),
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
                    color: const Color(0xFFE67E22).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.medication_rounded, color: Color(0xFFE67E22), size: 45),
                ),
                SizedBox(height: 20.h),
                Text(
                  appLang.translateDynamic('Kayıtlı Evcil Dost Bulunamadı'),
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                SizedBox(height: 8.h),
                Text(
                  appLang.translateDynamic('İlaç ve vitamin takibi yapabilmek için lütfen önce bir evcil hayvan ekle.'),
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
                    backgroundColor: const Color(0xFFE67E22),
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
    final petName = GlobalState.pets[_selectedPetIndex]['name'];
    final meds = GlobalState.medications[petName] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ResponsiveCenter(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 16.0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: 24.h),
                _buildTitleCard(),
                SizedBox(height: 16.h),
                _buildPetSelector(),
                SizedBox(height: 24.h),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLanguage.of(context).translate('medication_list'),
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton.icon(
                      onPressed: () => _showActionModal(),
                      icon: const Icon(Icons.add, color: Colors.white, size: 16),
                      label: Text(
                        AppLanguage.of(context).translate('add_medication_btn').replaceAll('+ ', '').replaceAll('+', '').trim(),
                        style: TextStyle(color: Colors.white, fontSize: 12.5.sp, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE67E22),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16.h),
                
                if (meds.isEmpty)
                  Center(child: Padding(padding: EdgeInsets.all(20.w), child: Text(AppLanguage.of(context).translateDynamic("Kayıtlı ilaç bulunmuyor."), style: const TextStyle(color: Colors.grey))))
                else
                  ...meds.asMap().entries.map((entry) => Padding(
                    padding: EdgeInsets.only(bottom: 12.0.h),
                    child: _buildMedCard(entry.value, entry.key),
                  )).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        InkWell(onTap: () => Navigator.pop(context), child: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 22)),
        SizedBox(width: 12.w),
        Icon(Icons.pets, color: Color(0xFF1B5E20), size: 32),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLanguage.of(context).translate('app_title'),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                AppLanguage.of(context).translate('app_subtitle'),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))]),
      child: Row(
        children: [
          Container(padding: EdgeInsets.all(16.w), decoration: BoxDecoration(color: Color(0xFFE67E22), borderRadius: BorderRadius.circular(20.r)), child: Icon(Icons.medication_rounded, color: Colors.white, size: 32)),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLanguage.of(context).translate('medication_tracking'), style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                SizedBox(height: 4.h),
                Text(AppLanguage.of(context).translate('meds_desc'), style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, height: 1.3)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPetSelector() {
    return Container(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: GlobalState.pets.length + 1,
        itemBuilder: (context, index) {
          if (index == GlobalState.pets.length) {
            return GestureDetector(
              onTap: _showAddPetModal,
              child: Container(margin: EdgeInsets.only(left: 8.w, right: 16.w), width: 60, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))]), child: Icon(Icons.add, color: AppTheme.primary, size: 30)),
            );
          }
          final pet = GlobalState.pets[index];
          final isSelected = index == _selectedPetIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedPetIndex = index),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(color: isSelected ? AppTheme.primary : Colors.white, borderRadius: BorderRadius.circular(30.r), boxShadow: isSelected ? [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 8, offset: Offset(0, 4))] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))]),
              child: Row(
                children: [
                  CircleAvatar(radius: 20, backgroundImage: GlobalState.getPetImage(pet['image'], pet['type'] ?? 'Köpek')),
                  SizedBox(width: 12.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pet['name'], style: TextStyle(color: isSelected ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                      Text(AppLanguage.of(context).translatePetType(pet['type']), style: TextStyle(color: isSelected ? Colors.white70 : AppTheme.textLight, fontSize: 11.sp)),
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

  Widget _buildMedCard(Map<String, dynamic> med, int index) {
    final appLang = AppLanguage.of(context);
    bool isActive = med['status'] == 'Aktif';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () => _showActionModal(med: med, index: index),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(color: med['color'].withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.medication, color: med['color'], size: 28),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              appLang.translateDynamic(med['title']),
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(color: med['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
                            child: Text(
                              isActive ? appLang.translate('status_active') : appLang.translate('status_finished'),
                              style: TextStyle(fontSize: 10.sp, color: med['color'], fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          const Icon(Icons.monitor_weight_outlined, size: 14, color: AppTheme.textLight),
                          SizedBox(width: 6.w),
                          Text(appLang.translateDynamic(med['dosage']), style: TextStyle(fontSize: 13.sp, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          const Icon(Icons.loop_rounded, size: 14, color: AppTheme.textLight),
                          SizedBox(width: 6.w),
                          Text(appLang.translateDynamic(med['frequency']), style: TextStyle(fontSize: 13.sp, color: AppTheme.textLight)),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      if (isActive)
                        Row(
                          children: [
                            const Icon(Icons.alarm, size: 14, color: Color(0xFFE67E22)),
                            SizedBox(width: 6.w),
                            Text(appLang.translateDynamic(med['nextTime']), style: TextStyle(fontSize: 13.sp, color: const Color(0xFFE67E22), fontWeight: FontWeight.bold)),
                          ],
                        ),
                    ],
                  ),
                ),
                Material(
                  color: const Color(0xFFE67E22).withOpacity(0.12),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _showActionModal(med: med, index: index),
                    child: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: const Icon(Icons.edit_rounded, color: Color(0xFFE67E22), size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




