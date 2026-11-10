import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/global_state.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_language.dart';
import '../../services/pdf_passport_service.dart';
import '../../services/ad_service.dart';
import '../../widgets/responsive_center.dart';

class VaccineScheduleScreen extends StatefulWidget {
  @override
  _VaccineScheduleScreenState createState() => _VaccineScheduleScreenState();
}

class _VaccineScheduleScreenState extends State<VaccineScheduleScreen> {
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
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: appLang.translate('pet_name'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))
                    ),
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    value: petType,
                    items: ['Köpek', 'Kedi', 'Kuş', 'Tavşan', 'Hamster', 'Balık', 'Diğer'].map((type) => DropdownMenuItem(value: type, child: Text(appLang.translatePetType(type)))).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        if (val != null) petType = val;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: appLang.translate('pet_type_label'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(appLang.translate('cancel'), style: const TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    String petName = nameController.text.trim();
                    if (petName.isNotEmpty) {
                      setState(() {
                        GlobalState.addNewPet(nameController.text.trim(), petType);
                        _selectedPetIndex = GlobalState.pets.length - 1;
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60)),
                  child: Text(appLang.translate('add'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            );
          }
        );
      }
    );
  }

  void _showActionModal(BuildContext context, String petName, {int? vaccineIndex}) {
    final appLang = AppLanguage.of(context, listen: false);
    String initialTitle = vaccineIndex != null ? appLang.translateDynamic(GlobalState.vaccines[petName]![vaccineIndex]['title']) : '';
    String initialDate = vaccineIndex != null ? appLang.translateDate(GlobalState.vaccines[petName]![vaccineIndex]['date']) : '';
    String status = vaccineIndex != null ? GlobalState.vaccines[petName]![vaccineIndex]['status'] : 'Planlandı';
    if (status == 'Yaklaşan') status = 'Yaklaşıyor';

    final titleController = TextEditingController(text: initialTitle);
    final dateController = TextEditingController(text: initialDate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
            left: 20.w,
            right: 20.w,
            top: 20.h,
          ),
          child: StatefulBuilder(
            builder: (modalContext, setModalState) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
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
                          vaccineIndex != null ? appLang.translate('edit_vaccine') : appLang.translate('new_vaccine'),
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        if (vaccineIndex != null)
                          IconButton(
                            tooltip: appLang.translate('delete'),
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 24),
                            onPressed: () {
                              setState(() {
                                if (GlobalState.vaccines[petName] != null && vaccineIndex < GlobalState.vaccines[petName]!.length) {
                                  GlobalState.vaccines[petName]!.removeAt(vaccineIndex);
                                }
                              });
                              Navigator.pop(modalContext);
                            AdService.onActionCompleted();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(appLang.translate('delete'))),
                              );
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: appLang.translate('vaccine_name'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: dateController,
                      decoration: InputDecoration(
                        labelText: appLang.translate('date'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        suffixIcon: const Icon(Icons.calendar_today_rounded),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(appLang.translate('status'), style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8,
                      children: [
                        {'key': 'Tamamlandı', 'label': appLang.translate('status_completed')},
                        {'key': 'Yaklaşıyor', 'label': appLang.translate('status_upcoming')},
                        {'key': 'Planlandı', 'label': appLang.translate('status_planned')},
                      ].map((item) {
                        final s = item['key']!;
                        final lbl = item['label']!;
                        bool isSelected = status == s;
                        Color color = s == 'Tamamlandı' ? const Color(0xFF27AE60) : s == 'Yaklaşıyor' ? const Color(0xFFF39C12) : const Color(0xFF95A5A6);
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
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final date = dateController.text.trim();
                          if (title.isNotEmpty) {
                            setState(() {
                              Color c = status == 'Tamamlandı' ? const Color(0xFF27AE60) : status == 'Yaklaşıyor' ? const Color(0xFFF39C12) : const Color(0xFF95A5A6);
                              final oldItem = (vaccineIndex != null && vaccineIndex < GlobalState.vaccines[petName]!.length)
                                  ? GlobalState.vaccines[petName]![vaccineIndex]
                                  : <String, dynamic>{};
                              final updatedItem = {
                                ...oldItem,
                                'title': title,
                                'date': date,
                                'status': status,
                                'color': c,
                                'icon': Icons.vaccines,
                              };
                              if (vaccineIndex != null && vaccineIndex < GlobalState.vaccines[petName]!.length) {
                                GlobalState.vaccines[petName]![vaccineIndex] = updatedItem;
                              } else {
                                GlobalState.vaccines[petName]!.add(updatedItem);
                              }
                            });
                            Navigator.pop(modalContext);
                            AdService.onActionCompleted();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text(appLang.translate('save'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _toggleVaccineStatus(String petName, int index) {
    setState(() {
      final v = GlobalState.vaccines[petName]![index];
      if (v['status'] != 'Tamamlandı') {
        v['status'] = 'Tamamlandı';
        v['color'] = Color(0xFF27AE60);
      } else {
        v['status'] = 'Planlandı';
        v['color'] = Color(0xFF95A5A6);
      }
    });
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
            appLang.translate('vaccine_calendar'),
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
                    color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.vaccines_rounded, color: Color(0xFF27AE60), size: 45),
                ),
                SizedBox(height: 20.h),
                Text(
                  appLang.translateDynamic('Kayıtlı Evcil Dost Bulunamadı'),
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                SizedBox(height: 8.h),
                Text(
                  appLang.translateDynamic('Aşı takvimini ve doz planlarını takip edebilmek için lütfen önce evcil hayvanını ekle.'),
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
                    backgroundColor: const Color(0xFF27AE60),
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
              SizedBox(height: 24.h),
              _buildPetSelector(),
              SizedBox(height: 24.h),
              _buildTitleCard(),
              SizedBox(height: 16.h),
              _buildStatsRow(),
              SizedBox(height: 24.h),
              _buildNextVaccineCard(),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLanguage.of(context).translate('vaccine_list'),
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton.icon(
                    onPressed: () => _showActionModal(context, petName),
                    icon: const Icon(Icons.add, color: Colors.white, size: 16),
                    label: Text(
                      AppLanguage.of(context).translate('add_vaccine_btn').replaceFirst('+ ', ''),
                      style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      minimumSize: Size.zero,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              _buildVaccineList(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 76.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 52.h,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showActionModal(context, petName),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                AppLanguage.of(context).translate('add_vaccine_btn'),
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26.r)),
                elevation: 3,
              ),
            ),
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
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 22),
        ),
        SizedBox(width: 12.w),
        const Icon(Icons.pets, color: Color(0xFF1B5E20), size: 32),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLanguage.of(context).translate('app_title'), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
              Text(AppLanguage.of(context).translate('app_subtitle'), style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF1B5E20), size: 26),
          tooltip: AppLanguage.of(context).translate('pdf_view_print'),
          onPressed: () {
            if (_selectedPetIndex >= GlobalState.pets.length) return;
            final pet = GlobalState.pets[_selectedPetIndex];
            final petName = pet['name'] ?? '';
            final vaccines = GlobalState.vaccines[petName] ?? [];
            final healthRecords = GlobalState.healthRecords[petName] ?? [];
            PdfPassportService.showRewardedPdfFlow(
              context,
              pet: pet,
              vaccines: vaccines,
              healthRecords: healthRecords,
            );
          },
        ),
      ],
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
              child: Container(
                margin: EdgeInsets.only(left: 8.w, right: 16.w),
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Icon(Icons.add, color: AppTheme.primary, size: 30),
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
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: isSelected 
                    ? [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 8, offset: Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: GlobalState.getPetImage(pet['image'], pet['type'] ?? 'Köpek'),
                  ),
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

  Widget _buildTitleCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Color(0xFF27AE60),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(Icons.vaccines, color: Colors.white, size: 28),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLanguage.of(context).translate('vaccine_calendar'), style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                SizedBox(height: 2.h),
                Text(AppLanguage.of(context).translate('vaccines_desc'), style: TextStyle(fontSize: 13.sp, color: AppTheme.textLight)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final petName = GlobalState.pets[_selectedPetIndex]['name'];
    final vaccines = GlobalState.vaccines[petName] ?? [];
    final appLang = AppLanguage.of(context);
    
    int completed = vaccines.where((v) => v['status'] == 'Tamamlandı').length;
    int approaching = vaccines.where((v) => v['status'] == 'Yaklaşıyor' || v['status'] == 'Yaklaşan').length;
    int planned = vaccines.where((v) => v['status'] == 'Planlandı').length;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem('$completed', appLang.translate('vaccines_completed'), Icons.check_circle_rounded, const Color(0xFF27AE60))),
          Container(width: 1, height: 36.h, color: Colors.grey.shade200),
          Expanded(child: _buildStatItem('$approaching', appLang.translate('vaccines_upcoming'), Icons.access_time_filled_rounded, const Color(0xFFF39C12))),
          Container(width: 1, height: 36.h, color: Colors.grey.shade200),
          Expanded(child: _buildStatItem('$planned', appLang.translate('vaccines_planned'), Icons.calendar_month_rounded, const Color(0xFF95A5A6))),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(width: 6.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(count, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                Text(label, style: TextStyle(fontSize: 8.5.sp, color: AppTheme.textLight, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNextVaccineCard() {
    final appLang = AppLanguage.of(context);
    final petName = GlobalState.pets[_selectedPetIndex]['name'];
    final vaccines = GlobalState.vaccines[petName] ?? [];
    
    // Find next upcoming or planned vaccine
    final upcomingList = vaccines.where((v) => v['status'] == 'Yaklaşıyor' || v['status'] == 'Yaklaşan' || v['status'] == 'Planlandı').toList();
    final nextVaccine = upcomingList.isNotEmpty ? upcomingList.first : (vaccines.isNotEmpty ? vaccines.first : null);
    final nextTitle = nextVaccine != null ? nextVaccine['title'] : 'Kuduz Aşısı';
    final nextDate = nextVaccine != null ? nextVaccine['date'] : '24 Eylül 2026';

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(appLang.translate('next_vaccine'), style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 12.h),
                Text(appLang.translateDynamic(nextTitle), style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1B5E20)), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF1B5E20)),
                    SizedBox(width: 6.w),
                    Text(appLang.translateDate(nextDate), style: TextStyle(fontSize: 13.sp, color: const Color(0xFF1B5E20), fontWeight: FontWeight.w600)),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFFF39C12)),
                    SizedBox(width: 6.w),
                    Text('13 ${appLang.translate('days_left')}', style: TextStyle(fontSize: 13.sp, color: const Color(0xFFF39C12), fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          // Right Graphic Illustration
          SizedBox(
            width: 90.w,
            height: 90.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(0xFFC8E6C9),
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(Icons.security_rounded, size: 70, color: Color(0xFF27AE60)),
                Icon(Icons.pets, size: 28, color: Colors.white),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Transform.rotate(
                    angle: -0.7,
                    child: Icon(Icons.vaccines, size: 40, color: Colors.white),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVaccineList() {
    final petName = GlobalState.pets[_selectedPetIndex]['name'];
    final vaccines = GlobalState.vaccines[petName] ?? [];

    if (vaccines.isEmpty) {
      return Center(child: Padding(
        padding: EdgeInsets.all(20.0.w),
        child: Text(AppLanguage.of(context).translateDynamic("Henüz aşı eklenmemiş."), style: const TextStyle(color: Colors.grey)),
      ));
    }

    return Column(
      children: List.generate(vaccines.length, (index) {
        final v = vaccines[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.0.h),
          child: _buildVaccineListItem(petName, index, v['title'], v['date'], v['status'], v['icon'], v['color']),
        );
      }),
    );
  }

  Widget _buildVaccineListItem(String petName, int index, String title, String date, String status, IconData? icon, Color? color) {
    final appLang = AppLanguage.of(context);
    bool isCompleted = status == 'Tamamlandı';
    bool isApproaching = status == 'Yaklaşıyor' || status == 'Yaklaşan';
    IconData finalIcon = icon ?? Icons.vaccines;
    Color finalColor = color ?? AppTheme.primary;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _toggleVaccineStatus(petName, index),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: finalColor,
                  shape: BoxShape.circle,
                  border: !isCompleted ? Border.all(color: finalColor, width: 2) : null,
                ),
                child: Icon(
                  isCompleted ? Icons.check : finalIcon, 
                  color: Colors.white, 
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showActionModal(context, petName, vaccineIndex: index),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLang.translateDynamic(title),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.textLight),
                        SizedBox(width: 4.w),
                        Text(appLang.translateDate(date), style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight)),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle_rounded :
                          isApproaching ? Icons.access_time_filled_rounded : Icons.calendar_month_rounded,
                          size: 12, color: finalColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          isCompleted
                              ? appLang.translate('status_completed')
                              : (isApproaching
                                  ? appLang.translate('status_upcoming')
                                  : appLang.translate('status_planned')),
                          style: TextStyle(fontSize: 12.sp, color: finalColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _showActionModal(context, petName, vaccineIndex: index);
              },
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.edit_rounded, color: AppTheme.primary, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




