import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/global_state.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_language.dart';
import '../../services/ad_service.dart';
import '../../widgets/responsive_center.dart';

class VetAppointmentsScreen extends StatefulWidget {
  @override
  _VetAppointmentsScreenState createState() => _VetAppointmentsScreenState();
}

class _VetAppointmentsScreenState extends State<VetAppointmentsScreen> {
  int _selectedPetIndex = 0;

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
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: appLang.translate('pet_name'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 14.h),
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
                        GlobalState.addNewPet(petName, petType);
                        _selectedPetIndex = GlobalState.pets.length - 1;
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60)),
                  child: Text(appLang.translate('add'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14.sp)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showActionModal({Map<String, dynamic>? appointment, int? index}) {
    final appLang = AppLanguage.of(context, listen: false);
    final titleController = TextEditingController(text: appointment != null ? appLang.translateDynamic(appointment['title']?.toString() ?? '') : '');
    final dateController = TextEditingController(text: appointment != null ? appLang.translateDate(appointment['date']?.toString() ?? '') : appLang.translateDate('15 Mayıs 2026'));
    final timeController = TextEditingController(text: appointment != null ? (appointment['time']?.toString() ?? '') : '14:30');
    final clinicController = TextEditingController(text: appointment != null ? appLang.translateDynamic(appointment['clinic']?.toString() ?? appointment['location']?.toString() ?? '') : appLang.translateDynamic('Patili Veteriner Kliniği'));
    final doctorController = TextEditingController(text: appointment != null ? appLang.translateDynamic(appointment['doctor']?.toString() ?? '') : 'Dr. Ayşe Yılmaz');
    final notesController = TextEditingController(text: appointment != null ? appLang.translateDynamic(appointment['notes']?.toString() ?? '') : '');
    final alarmLabelController = TextEditingController(text: appointment != null ? appLang.translateDynamic(appointment['alarmLabel']?.toString() ?? '') : '');

    bool hasAlarm = appointment != null ? (appointment['hasAlarm'] == true) : true;
    String reminder = appointment != null ? (appointment['reminder']?.toString() ?? '1 Gün Önce') : '1 Gün Önce';
    String status = appointment != null ? (appointment['status']?.toString() ?? 'Yaklaşan') : 'Yaklaşan';

    if (alarmLabelController.text.isEmpty && titleController.text.isNotEmpty) {
      alarmLabelController.text = '${titleController.text} ${appLang.translate('reminders')}';
    }

    final reminderOptions = [
      {'key': 'Randevu Anında', 'label': appLang.translate('at_appointment_time')},
      {'key': '1 Saat Önce', 'label': appLang.translate('hours_before_1')},
      {'key': '3 Saat Önce', 'label': appLang.translate('hours_before_3')},
      {'key': '1 Gün Önce', 'label': appLang.translate('days_before_1')},
      {'key': '2 Gün Önce', 'label': appLang.translate('days_before_2')},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                          appointment != null ? appLang.translate('edit_appointment') : appLang.translate('new_appointment'),
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                        ),
                        if (appointment != null && index != null)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                            onPressed: () {
                              final petName = GlobalState.pets[_selectedPetIndex]['name'];
                              setState(() {
                                GlobalState.appointments[petName]?.removeAt(index);
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
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: appLang.translate('appointment_reason'),
                        prefixIcon: const Icon(Icons.medical_services_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onChanged: (val) {
                        if (alarmLabelController.text.isEmpty || alarmLabelController.text.endsWith('Hatırlatıcı')) {
                          alarmLabelController.text = '$val Hatırlatıcı';
                        }
                      },
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: dateController,
                            decoration: InputDecoration(
                              labelText: appLang.translate('date'),
                              prefixIcon: const Icon(Icons.calendar_today_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: TextField(
                            controller: timeController,
                            decoration: InputDecoration(
                              labelText: appLang.translate('time'),
                              prefixIcon: const Icon(Icons.access_time_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: clinicController,
                      decoration: InputDecoration(
                        labelText: appLang.translate('vet_clinic_address'),
                        prefixIcon: const Icon(Icons.location_on_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: doctorController,
                      decoration: InputDecoration(
                        labelText: appLang.translate('vet_doctor_name'),
                        prefixIcon: const Icon(Icons.person_pin_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: appLang.translate('appointment_note'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    
                    // ALARM & REMINDER BOX
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: hasAlarm ? const Color(0xFFE8F5E9) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: hasAlarm ? const Color(0xFF81C784) : Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    hasAlarm ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
                                    color: hasAlarm ? const Color(0xFF27AE60) : Colors.grey,
                                    size: 24,
                                  ),
                                  SizedBox(width: 10.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appLang.translate('appointment_alarm_card'),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5.sp,
                                          color: hasAlarm ? const Color(0xFF1B5E20) : AppTheme.textDark,
                                        ),
                                      ),
                                      Text(
                                        hasAlarm ? appLang.translate('alarm_subtitle') : appLang.translate('alarm_off'),
                                        style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Switch(
                                value: hasAlarm,
                                activeColor: const Color(0xFF27AE60),
                                onChanged: (val) => setModalState(() => hasAlarm = val),
                              ),
                            ],
                          ),
                          if (hasAlarm) ...[
                            SizedBox(height: 12.h),
                            TextField(
                              controller: alarmLabelController,
                              decoration: InputDecoration(
                                labelText: appLang.translate('alarm_title_field'),
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(appLang.translate('notification_time'), style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                            SizedBox(height: 6.h),
                            Wrap(
                              spacing: 8.w,
                              children: reminderOptions.map((opt) {
                                final optKey = opt['key']!;
                                final optLabel = opt['label']!;
                                bool isSelected = reminder == optKey;
                                return ChoiceChip(
                                  label: Text(optLabel, style: TextStyle(fontSize: 11.sp, color: isSelected ? Colors.white : const Color(0xFF1B5E20))),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFF27AE60),
                                  backgroundColor: Colors.white,
                                  onSelected: (sel) {
                                    if (sel) setModalState(() => reminder = optKey);
                                  },
                                );
                              }).toList(),
                            )
                          ]
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        {'key': 'Yaklaşan', 'label': appLang.translate('status_upcoming')},
                        {'key': 'Tamamlandı', 'label': appLang.translate('status_completed')},
                      ].map((item) {
                        final s = item['key']!;
                        final lbl = item['label']!;
                        bool isSelected = status == s;
                        Color c = s == 'Yaklaşan' ? const Color(0xFF27AE60) : Colors.grey.shade600;
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: ChoiceChip(
                            label: Text(lbl, style: TextStyle(color: isSelected ? Colors.white : c, fontWeight: FontWeight.bold)),
                            selected: isSelected,
                            selectedColor: c,
                            onSelected: (selected) {
                              if (selected) setModalState(() => status = s);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final date = dateController.text.trim();
                          final time = timeController.text.trim();
                          final clinic = clinicController.text.trim();
                          final doctor = doctorController.text.trim();
                          final notes = notesController.text.trim();
                          final alarmLabel = alarmLabelController.text.trim();

                          if (title.isNotEmpty) {
                            setState(() {
                              final petName = GlobalState.pets[_selectedPetIndex]['name'];
                              GlobalState.appointments.putIfAbsent(petName, () => []);

                              final newAppt = {
                                'title': title,
                                'date': date.isEmpty ? 'Tarih Belirtilmedi' : date,
                                'time': time.isEmpty ? '12:00' : time,
                                'clinic': clinic,
                                'location': clinic,
                                'doctor': doctor.isEmpty ? 'Veteriner Hekim' : doctor,
                                'notes': notes,
                                'status': status,
                                'hasAlarm': hasAlarm,
                                'reminder': reminder,
                                'alarmLabel': alarmLabel.isEmpty ? '$title Hatırlatıcı' : alarmLabel,
                              };

                              if (index != null && index < GlobalState.appointments[petName]!.length) {
                                GlobalState.appointments[petName]![index] = newAppt;
                              } else {
                                GlobalState.appointments[petName]!.insert(0, newAppt);
                              }
                            });
                            Navigator.pop(context);
                            AdService.onActionCompleted();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  hasAlarm
                                      ? '⏰ "$alarmLabel" - $reminder'
                                      : appLang.translate('save'),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        child: Text(appLang.translate('save'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
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
            appLang.translate('vet_appointments'),
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
                    color: const Color(0xFF2980B9).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF2980B9), size: 45),
                ),
                SizedBox(height: 20.h),
                Text(
                  appLang.translateDynamic('Kayıtlı Evcil Dost Bulunamadı'),
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                SizedBox(height: 8.h),
                Text(
                  appLang.translateDynamic('Veteriner randevusu planlamak ve hatırlatıcı kurmak için önce bir evcil hayvan ekle.'),
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
                    backgroundColor: const Color(0xFF2980B9),
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
    final appointments = GlobalState.appointments[petName] ?? [];

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
                SizedBox(height: 20.h),
                _buildPrimaryButton(),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${AppLanguage.of(context).translate('appointment_list')} (${appointments.length})',
                          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                        ),
                      ),
                    ),
                    if (appointments.any((a) => a['hasAlarm'] == true)) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.alarm_on_rounded, size: 14, color: Color(0xFF27AE60)),
                            SizedBox(width: 4.w),
                            Text(AppLanguage.of(context).translate('alarms_active'), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF27AE60))),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 14.h),
                if (appointments.isEmpty)
                  _buildEmptyState()
                else
                  ...appointments.asMap().entries.map((entry) {
                    int actualIndex = entry.key;
                    var appointment = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 14.0.h),
                      child: _buildAppointmentCard(appointment, actualIndex, petName),
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
            Text(AppLanguage.of(context).translate('vet_appointments'), style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
            Text(AppLanguage.of(context).translate('vet_appts_desc'), style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight)),
          ],
        )
      ],
    );
  }

  Widget _buildTitleCard() {
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
              color: const Color(0xFF27AE60),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 28),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLanguage.of(context).translate('vet_appointments'), style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                SizedBox(height: 3.h),
                Text(AppLanguage.of(context).translate('vet_appts_desc'),
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
                color: isSelected ? const Color(0xFF27AE60) : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: isSelected
                    ? [BoxShadow(color: const Color(0xFF27AE60).withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 4))]
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

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton.icon(
        onPressed: () => _showActionModal(),
        icon: const Icon(Icons.add_alert_rounded, color: Colors.white, size: 22),
        label: Text(AppLanguage.of(context).translate('add_appointment_btn'), style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF27AE60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment, int index, String petName) {
    final appLang = AppLanguage.of(context);
    final String title = appointment['title']?.toString() ?? 'Randevu';
    final String status = appointment['status']?.toString() ?? 'Yaklaşan';
    final bool isUpcoming = status == 'Yaklaşan' || status == 'Yaklaşıyor';
    final String date = appointment['date']?.toString() ?? '';
    final String time = appointment['time']?.toString() ?? '';
    final String clinic = appointment['clinic']?.toString() ?? appointment['location']?.toString() ?? 'Patili Veteriner Kliniği';
    final String doctor = appointment['doctor']?.toString() ?? '';
    final String notes = appointment['notes']?.toString() ?? '';
    final bool hasAlarm = appointment['hasAlarm'] == true;
    final String reminder = appointment['reminder']?.toString() ?? '1 Gün Önce';
    final String alarmLabel = appointment['alarmLabel']?.toString() ?? '$title Alarmı';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(22.r),
          onTap: () => _showActionModal(appointment: appointment, index: index),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isUpcoming ? const Color(0xFFE8F5E9) : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isUpcoming ? Icons.calendar_month_rounded : Icons.check_circle_outline_rounded,
                        color: isUpcoming ? const Color(0xFF27AE60) : Colors.grey.shade600,
                        size: 26,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  appLang.translateDynamic(title),
                                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: isUpcoming ? const Color(0xFFE8F5E9) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  isUpcoming
                                      ? appLang.translate('status_upcoming')
                                      : appLang.translate('status_completed'),
                                  style: TextStyle(
                                    fontSize: 10.5.sp,
                                    color: isUpcoming ? const Color(0xFF27AE60) : Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 13, color: AppTheme.textLight),
                              SizedBox(width: 5.w),
                              Text(appLang.translateDate(date), style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                              SizedBox(width: 10.w),
                              const Icon(Icons.access_time_rounded, size: 13, color: AppTheme.textLight),
                              SizedBox(width: 5.w),
                              Text(time, style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: const Color(0xFF27AE60).withOpacity(0.12),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _showActionModal(appointment: appointment, index: index),
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: const Icon(Icons.edit_rounded, color: Color(0xFF27AE60), size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 15, color: Color(0xFF27AE60)),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    appLang.translateDynamic(clinic) + (doctor.isNotEmpty ? ' • ${appLang.translateDynamic(doctor)}' : ''),
                    style: TextStyle(fontSize: 12.sp, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (notes.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              appLang.translateDynamic(notes),
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600, height: 1.3),
            ),
          ],
          SizedBox(height: 10.h),
          // ALARM ROW & QUICK TOGGLE
          InkWell(
            onTap: () {
              setState(() {
                GlobalState.toggleAppointmentAlarm(petName, index);
              });
              bool nowAlarm = appointment['hasAlarm'] == true;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text(
                    nowAlarm
                        ? '⏰ "${appLang.translateDynamic(alarmLabel)}" ${appLang.translate('alarms_active')} (${appLang.translateDynamic(reminder)})!'
                        : appLang.translate('alarm_off'),
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: hasAlarm ? const Color(0xFFE8F5E9) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: hasAlarm ? const Color(0xFFA5D6A7) : Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        hasAlarm ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                        size: 16,
                        color: hasAlarm ? const Color(0xFF2E7D32) : Colors.grey.shade600,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        hasAlarm ? '${appLang.translateDynamic(alarmLabel)} (${appLang.translateDynamic(reminder)})' : appLang.translate('tap_to_enable_alarm'),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.bold,
                          color: hasAlarm ? const Color(0xFF2E7D32) : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    hasAlarm
                        ? appLang.translate('alarm_on')
                        : appLang.translate('alarm_off'),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: hasAlarm ? const Color(0xFF2E7D32) : Colors.grey,
                    ),
                  )
                ],
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 54, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(
            AppLanguage.of(context).translateDynamic('Kayıtlı Randevu Bulunmuyor'),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          SizedBox(height: 6.h),
          Text(
            AppLanguage.of(context).translateDynamic('Dostunuz için yaklaşan bir veteriner randevusu oluşturup alarmını kurabilirsiniz.'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, height: 1.4),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () => _showActionModal(),
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: Text(AppLanguage.of(context).translate('add_appointment_btn'), style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
          )
        ],
      ),
    );
  }
}
