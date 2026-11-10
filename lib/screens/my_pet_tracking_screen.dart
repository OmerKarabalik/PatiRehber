import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../localization/app_language.dart';
import '../models/global_state.dart';
import '../theme/app_theme.dart';
import 'health/vaccine_schedule_screen.dart';
import 'health/vet_appointments_screen.dart';
import 'health/health_records_screen.dart';
import 'health/medication_tracking_screen.dart';
import 'nutrition/nutrition_dashboard_screen.dart';
import 'education/education_dashboard_screen.dart';
import '../services/pdf_passport_service.dart';
import 'premium/pati_plus_sheet.dart';
import '../widgets/responsive_center.dart';
import '../widgets/pet_photo_picker_dialog.dart';

class MyPetTrackingScreen extends StatefulWidget {
  @override
  _MyPetTrackingScreenState createState() => _MyPetTrackingScreenState();
}

class _MyPetTrackingScreenState extends State<MyPetTrackingScreen> {
  int _selectedPetIndex = 0;

  void _showAddPetModal() {
    final appLang = AppLanguage.of(context);
    final nameController = TextEditingController();
    String petType = 'Köpek';
    String breed = '';
    String gender = 'Erkek';
    double weight = 5.0;
    String? selectedImagePath;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
              title: Text(appLang.translate('add_pet_title'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final path = await PetPhotoPickerDialog.show(
                            context,
                            currentImagePath: selectedImagePath,
                            petType: petType,
                          );
                          if (path != null) {
                            setDialogState(() {
                              selectedImagePath = path.isEmpty ? null : path;
                            });
                          }
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primary, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 36.r,
                                backgroundColor: Colors.grey.shade100,
                                backgroundImage: GlobalState.getPetImage(selectedImagePath, petType),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      appLang.translateDynamic('Fotoğraf Seç / Değiştir'),
                      style: TextStyle(fontSize: 11.5.sp, color: AppTheme.primary, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12.h),
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
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        {'val': 'Erkek', 'label': appLang.translate('male')},
                        {'val': 'Dişi', 'label': appLang.translate('female')},
                      ].map((item) {
                        bool isSel = gender == item['val'];
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: ChoiceChip(
                            label: Text(item['label']!, style: TextStyle(color: isSel ? Colors.white : AppTheme.textDark)),
                            selected: isSel,
                            selectedColor: AppTheme.primary,
                            onSelected: (s) {
                              if (s) setDialogState(() => gender = item['val']!);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: appLang.translate('weight_kg'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onChanged: (v) => weight = double.tryParse(v) ?? 5.0,
                    ),
                  ],
                ),
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
                        GlobalState.addNewPet(
                          petName,
                          petType,
                          breed: breed.trim().isEmpty ? 'Belirtilmedi' : breed.trim(),
                          gender: gender,
                          weight: weight,
                          image: selectedImagePath,
                        );
                        _selectedPetIndex = GlobalState.pets.length - 1;
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                  child: Text(appLang.translate('add'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14.sp)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditPetModal(Map<String, dynamic> pet, int index) {
    final nameController = TextEditingController(text: pet['name']?.toString() ?? '');
    final breedController = TextEditingController(text: pet['breed']?.toString() ?? '');
    final birthDateController = TextEditingController(text: pet['birthDate']?.toString() ?? '');
    final ageController = TextEditingController(text: pet['age']?.toString() ?? '');
    final chipNoController = TextEditingController(text: pet['chipNo']?.toString() ?? '');
    final allergiesController = TextEditingController(text: pet['allergies']?.toString() ?? '');
    final bloodTypeController = TextEditingController(text: pet['bloodType']?.toString() ?? '');
    final notesController = TextEditingController(text: pet['notes']?.toString() ?? '');
    final weightController = TextEditingController(text: (pet['weight'] ?? 5.0).toString());
    String gender = pet['gender']?.toString() ?? 'Erkek';
    bool isNeutered = pet['isNeutered'] == true;
    String? selectedImagePath = pet['image']?.toString();

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
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${pet['name']} • ${AppLanguage.of(context).translate('edit_profile')}',
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                        ),
                        if (GlobalState.pets.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                            onPressed: () {
                              Navigator.pop(context);
                              _confirmDeletePet(index, pet['name'] ?? '');
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final path = await PetPhotoPickerDialog.show(
                            context,
                            currentImagePath: selectedImagePath,
                            petType: pet['type'] ?? 'Köpek',
                          );
                          if (path != null) {
                            setModalState(() {
                              selectedImagePath = path.isEmpty ? null : path;
                            });
                          }
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primary, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 36.r,
                                backgroundColor: Colors.grey.shade100,
                                backgroundImage: GlobalState.getPetImage(selectedImagePath, pet['type'] ?? 'Köpek'),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Center(
                      child: Text(
                        AppLanguage.of(context).translateDynamic('Fotoğrafı Değiştir'),
                        style: TextStyle(fontSize: 11.5.sp, color: AppTheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: AppLanguage.of(context).translate('pet_name'),
                        prefixIcon: const Icon(Icons.pets),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: breedController,
                            decoration: InputDecoration(
                              labelText: AppLanguage.of(context).translate('breed_label'),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TextField(
                            controller: ageController,
                            decoration: InputDecoration(
                              labelText: AppLanguage.of(context).translate('age'),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: birthDateController,
                            decoration: InputDecoration(
                              labelText: AppLanguage.of(context).translate('birth_date'),
                              prefixIcon: const Icon(Icons.cake_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TextField(
                            controller: weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: AppLanguage.of(context).translate('weight_kg'),
                              prefixIcon: const Icon(Icons.monitor_weight_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: chipNoController,
                      decoration: InputDecoration(
                        labelText: AppLanguage.of(context).translate('chip_no_label'),
                        prefixIcon: const Icon(Icons.qr_code_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLanguage.of(context).translate('gender_label'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                        Row(
                          children: [
                            {'val': 'Erkek', 'label': AppLanguage.of(context).translate('male')},
                            {'val': 'Dişi', 'label': AppLanguage.of(context).translate('female')},
                          ].map((item) {
                            bool isSel = gender == item['val'];
                            return Padding(
                              padding: EdgeInsets.only(left: 8.w),
                              child: ChoiceChip(
                                label: Text(item['label']!, style: TextStyle(color: isSel ? Colors.white : AppTheme.textDark)),
                                selected: isSel,
                                selectedColor: AppTheme.primary,
                                onSelected: (s) {
                                  if (s) setModalState(() => gender = item['val']!);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.health_and_safety_rounded, color: isNeutered ? const Color(0xFF27AE60) : Colors.grey, size: 22),
                              SizedBox(width: 10.w),
                              Text(AppLanguage.of(context).translate('is_neutered_question'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                            ],
                          ),
                          Switch(
                            value: isNeutered,
                            activeColor: const Color(0xFF27AE60),
                            onChanged: (v) => setModalState(() => isNeutered = v),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: allergiesController,
                      decoration: InputDecoration(
                        labelText: AppLanguage.of(context).translate('allergies_label'),
                        prefixIcon: const Icon(Icons.warning_amber_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: bloodTypeController,
                      decoration: InputDecoration(
                        labelText: AppLanguage.of(context).translate('blood_type_label'),
                        prefixIcon: const Icon(Icons.bloodtype_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: AppLanguage.of(context).translate('special_notes_label'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: () {
                          final newName = nameController.text.trim();
                          if (newName.isNotEmpty) {
                            setState(() {
                              GlobalState.updatePet(index, {
                                'name': newName,
                                'breed': breedController.text.trim(),
                                'gender': gender,
                                'birthDate': birthDateController.text.trim(),
                                'age': ageController.text.trim(),
                                'weight': double.tryParse(weightController.text.trim()) ?? 5.0,
                                'chipNo': chipNoController.text.trim(),
                                'isNeutered': isNeutered,
                                'allergies': allergiesController.text.trim(),
                                'bloodType': bloodTypeController.text.trim(),
                                'notes': notesController.text.trim(),
                                'image': selectedImagePath ?? pet['image'],
                              });
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLanguage.of(context).translate('profile_updated_msg'))),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        child: Text(AppLanguage.of(context).translate('save_and_update'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
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

  void _showAddWeightModal(String petName) {
    final appLang = AppLanguage.of(context);
    final weightController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text('$petName • ${appLang.translate('weight_entry_title')}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: appLang.translate('new_weight_kg'),
                  prefixIcon: const Icon(Icons.monitor_weight_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: appLang.translate('weight_note_hint'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(appLang.translate('cancel'))),
            ElevatedButton(
              onPressed: () {
                final newWeight = double.tryParse(weightController.text.trim()) ?? 0.0;
                final note = noteController.text.trim();
                if (newWeight > 0) {
                  setState(() {
                    GlobalState.addWeightRecord(petName, newWeight, note);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$petName: $newWeight kg ${appLang.translate('weight_saved_msg')}')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: Text(appLang.translate('save'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
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
                if (_selectedPetIndex >= GlobalState.pets.length) {
                  _selectedPetIndex = GlobalState.pets.isEmpty ? 0 : GlobalState.pets.length - 1;
                }
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
              setState(() {
                _selectedPetIndex = 0;
              });
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
          leadingWidth: 115.w,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (Navigator.canPop(context))
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.only(left: 8.w, right: 4.w),
                  constraints: const BoxConstraints(),
                )
              else
                SizedBox(width: 8.w),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AppLanguage.buildLanguagePill(context),
                ),
              ),
            ],
          ),
          title: Text(
            appLang.translateDynamic('Pati Kimliği'),
            style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w900, fontSize: 17.5.sp),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary, size: 28),
              tooltip: appLang.translate('add'),
              onPressed: _showAddPetModal,
            ),
          ],
        ),
        body: ResponsiveCenter(
          child: _buildEmptyPetView(context, appLang),
        ),
      );
    }

    if (_selectedPetIndex >= GlobalState.pets.length) {
      _selectedPetIndex = 0;
    }
    final pet = GlobalState.pets[_selectedPetIndex];
    final petName = pet['name'] ?? 'Max';

    final vaccines = GlobalState.vaccines[petName] ?? [];
    final appointments = GlobalState.appointments[petName] ?? [];
    final healthRecords = GlobalState.healthRecords[petName] ?? [];
    final medications = GlobalState.medications[petName] ?? [];
    final weightHistory = GlobalState.weightHistory[petName] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leadingWidth: 95.w,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Navigator.canPop(context))
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 18),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.only(left: 6.w, right: 2.w),
                constraints: const BoxConstraints(),
              )
            else
              SizedBox(width: 6.w),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AppLanguage.buildLanguagePill(context),
              ),
            ),
          ],
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            appLang.translateDynamic('Pati Kimliği'),
            style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w900, fontSize: 16.5.sp),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primary, size: 26),
            tooltip: appLang.translate('pdf_view_print'),
            onPressed: () => PdfPassportService.showRewardedPdfFlow(
              context,
              pet: pet,
              vaccines: vaccines,
              healthRecords: healthRecords,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primary, size: 28),
            tooltip: appLang.translate('edit_profile'),
            onPressed: () => _showEditPetModal(pet, _selectedPetIndex),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textDark),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            onSelected: (val) {
              if (val == 'clear_all') {
                _confirmClearAllData();
              } else if (val == 'delete_current') {
                _confirmDeletePet(_selectedPetIndex, petName);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'delete_current',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                    SizedBox(width: 8.w),
                    Text(appLang.translateDynamic('Bu Hayvanı Sil'), style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    const Icon(Icons.cleaning_services_rounded, color: Colors.red, size: 20),
                    SizedBox(width: 8.w),
                    Text(appLang.translateDynamic('Tüm Demo Verileri Sil'), style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ResponsiveCenter(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPetSelector(),
              SizedBox(height: 18.h),
              _buildPetPassportCard(pet, _selectedPetIndex, vaccines, healthRecords),
              SizedBox(height: 12.h),
              _buildPdfExportBanner(pet, vaccines, healthRecords),
              SizedBox(height: 18.h),
              _buildQuickStats(pet, petName),
              SizedBox(height: 22.h),
              _buildHubSection(context, vaccines, appointments, healthRecords, medications),
              SizedBox(height: 22.h),
              _buildWeightTracker(petName, weightHistory),
              SizedBox(height: 20.h),
              _buildMedicalAlerts(pet),
              SizedBox(height: 40.h),
            ],
          ),
        ),
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
            onLongPress: () => _confirmDeletePet(index, pet['name'] ?? ''),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppTheme.primary.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 4))]
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
                        AppLanguage.of(context).translatePetType(pet['type'] ?? ''),
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : AppTheme.textLight,
                          fontSize: 10.5.sp,
                        ),
                      ),
                    ],
                  ),
                  if (isSelected) ...[
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => _confirmDeletePet(index, pet['name'] ?? ''),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetPassportCard(
    Map<String, dynamic> pet,
    int index,
    List<Map<String, dynamic>> vaccines,
    List<Map<String, dynamic>> healthRecords,
  ) {
    final appLang = AppLanguage.of(context);
    final String name = pet['name'] ?? 'Max';
    final String type = pet['type'] ?? 'Köpek';
    final String breed = pet['breed'] ?? 'Melez';
    final String chipNo = pet['chipNo'] ?? 'Çip Kaydı Yok';
    final String gender = pet['gender'] ?? 'Erkek';
    final String birthDate = pet['birthDate'] ?? '01.01.2024';
    final bool isNeutered = pet['isNeutered'] == true;

    return InkWell(
      onTap: () => _showEditPetModal(pet, index),
      borderRadius: BorderRadius.circular(26.r),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(Icons.pets, size: 140, color: Colors.white.withOpacity(0.08)),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_rounded, color: Colors.amberAccent, size: 18),
                            SizedBox(width: 5.w),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  appLang.translate('digital_passport'),
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10.sp,
                                    letterSpacing: 0.6,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      InkWell(
                        onTap: () => _showEditPetModal(pet, _selectedPetIndex),
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.edit_rounded, color: Colors.white, size: 13),
                              SizedBox(width: 3.w),
                              Text(
                                appLang.translate('edit_profile'),
                                style: TextStyle(color: Colors.white, fontSize: 10.5.sp, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      InkWell(
                        onTap: () => _confirmDeletePet(_selectedPetIndex, name),
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 13),
                              SizedBox(width: 3.w),
                              Text(
                                appLang.translate('delete'),
                                style: TextStyle(color: Colors.white, fontSize: 10.5.sp, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final path = await PetPhotoPickerDialog.show(
                            context,
                            currentImagePath: pet['image'],
                            petType: type,
                          );
                          if (path != null) {
                            setState(() {
                              pet['image'] = path.isEmpty ? null : path;
                              GlobalState.saveToDisk();
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(appLang.translateDynamic('Fotoğraf güncellendi!')),
                                  backgroundColor: AppTheme.primary,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                              ),
                              child: CircleAvatar(
                                radius: 36.r,
                                backgroundImage: GlobalState.getPetImage(pet['image'], type),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              '${appLang.translatePetType(type)} • ${appLang.translateDynamic(breed)}',
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13.sp, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 6.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.qr_code_2_rounded, color: Colors.amberAccent, size: 14),
                                  SizedBox(width: 6.w),
                                  Text(
                                    appLang.translateDynamic(chipNo),
                                    style: TextStyle(color: Colors.amberAccent, fontSize: 11.sp, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 18.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPassportInfoCol(AppLanguage.of(context).translate('gender'), gender == 'Erkek' ? AppLanguage.of(context).translate('male') : AppLanguage.of(context).translate('female')),
                      Container(width: 1, height: 24.h, color: Colors.white24),
                      _buildPassportInfoCol(AppLanguage.of(context).translate('birth'), birthDate),
                      Container(width: 1, height: 24.h, color: Colors.white24),
                      _buildPassportInfoCol(AppLanguage.of(context).translate('neutered'), isNeutered ? AppLanguage.of(context).translate('yes') : AppLanguage.of(context).translate('no')),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildPassportInfoCol(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white60, fontSize: 9.5.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 3.h),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildPdfExportBanner(
    Map<String, dynamic> pet,
    List<Map<String, dynamic>> vaccines,
    List<Map<String, dynamic>> healthRecords,
  ) {
    final appLang = AppLanguage.of(context);
    final petName = pet['name'] ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF1B5E20), size: 24),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            appLang.translate('pdf_export_passport'),
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            appLang.translate('pdf_official_cert'),
                            style: TextStyle(
                              color: Colors.brown.shade800,
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      appLang.translate('pdf_export_desc'),
                      style: TextStyle(fontSize: 10.5.sp, color: AppTheme.textLight),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42.h,
                  child: ElevatedButton.icon(
                    onPressed: () => PdfPassportService.showRewardedPdfFlow(
                      context,
                      pet: pet,
                      vaccines: vaccines,
                      healthRecords: healthRecords,
                    ),
                    icon: const Icon(Icons.print_rounded, color: Colors.white, size: 17),
                    label: Text(
                      '$petName • ${appLang.translate('pdf_view_print')}',
                      style: TextStyle(color: Colors.white, fontSize: 12.5.sp, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              InkWell(
                onTap: () => PatiPlusSheet.show(context),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  height: 42.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFFFD54F)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD97706), size: 18),
                      SizedBox(width: 4.w),
                      Text(
                        'Pati+',
                        style: TextStyle(color: const Color(0xFFB45309), fontSize: 12.sp, fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildQuickStats(Map<String, dynamic> pet, String petName) {
    final String age = pet['age']?.toString() ?? '1';
    final double weight = (pet['weight'] is num) ? (pet['weight'] as num).toDouble() : 5.0;
    final String bloodType = pet['bloodType']?.toString() ?? '-';
    final appLang = AppLanguage.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(appLang.translate('age'), appLang.translateDynamic(age), Icons.cake_rounded, const Color(0xFFF39C12)),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: InkWell(
            onTap: () => _showAddWeightModal(petName),
            borderRadius: BorderRadius.circular(18.r),
            child: _buildStatCard(
              appLang.translate('weight'),
              '$weight kg',
              Icons.monitor_weight_rounded,
              const Color(0xFF27AE60),
              subtitle: appLang.translate('add_weight'),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildStatCard(appLang.translate('blood_type'), appLang.translateDynamic(bloodType), Icons.bloodtype_rounded, const Color(0xFFE74C3C)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 18.sp),
              ),
              if (subtitle != null)
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(left: 3.w),
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6.r)),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        subtitle,
                        style: TextStyle(color: color, fontSize: 8.5.sp, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(label, style: TextStyle(fontSize: 10.5.sp, color: AppTheme.textLight, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
          SizedBox(height: 2.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHubSection(
    BuildContext context,
    List<Map<String, dynamic>> vaccines,
    List<Map<String, dynamic>> appointments,
    List<Map<String, dynamic>> healthRecords,
    List<Map<String, dynamic>> medications,
  ) {
    final appLang = AppLanguage.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLang.translate('health_management'),
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildHubCard(
                title: appLang.translate('vaccine_calendar'),
                count: '${vaccines.length} ${appLang.translateDynamic('Kayıt')}',
                icon: Icons.vaccines_rounded,
                color: const Color(0xFF27AE60),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VaccineScheduleScreen())),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildHubCard(
                title: appLang.translate('vet_appointments'),
                count: '${appointments.length} ${appLang.translateDynamic('Randevu')}',
                icon: Icons.calendar_month_rounded,
                color: const Color(0xFFF39C12),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VetAppointmentsScreen())),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _buildHubCard(
                title: appLang.translate('health_records'),
                count: '${healthRecords.length} ${appLang.translateDynamic('Kayıt')}',
                icon: Icons.description_rounded,
                color: const Color(0xFF1E824C),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HealthRecordsScreen())),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildHubCard(
                title: appLang.translate('medication_tracking'),
                count: '${medications.length} ${appLang.translateDynamic('İlaç')}',
                icon: Icons.medication_rounded,
                color: const Color(0xFFE67E22),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MedicationTrackingScreen())),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _buildHubCard(
                title: appLang.translate('nutrition'),
                count: appLang.translateDynamic('Plan & Porsiyon'),
                icon: Icons.restaurant_rounded,
                color: const Color(0xFF2ECC71),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NutritionDashboardScreen())),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildHubCard(
                title: appLang.translate('education'),
                count: appLang.translateDynamic('İpuçları & Komut'),
                icon: Icons.school_rounded,
                color: const Color(0xFF3498DB),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EducationDashboardScreen())),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHubCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      count,
                      style: TextStyle(fontSize: 10.5.sp, color: AppTheme.textLight, fontWeight: FontWeight.w600),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightTracker(String petName, List<Map<String, dynamic>> history) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.show_chart_rounded, color: Color(0xFF27AE60), size: 22),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        AppLanguage.of(context).translate('weight_history'),
                        style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddWeightModal(petName),
                icon: const Icon(Icons.add, size: 16),
                label: Text(AppLanguage.of(context).translate('add_weight_record')),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF27AE60),
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (history.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(AppLanguage.of(context).translateDynamic('Henüz kilo ölçümü kaydedilmedi.'), style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            )
          else
            Column(
              children: history.map((w) {
                final String date = w['date']?.toString() ?? '';
                final String weightStr = '${w['weight']} kg';
                final String diff = w['diff']?.toString() ?? '';
                final String notes = w['notes']?.toString() ?? '';
                final appLang = AppLanguage.of(context);

                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appLang.translateDate(date), style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                          if (notes.isNotEmpty)
                            Text(appLang.translateDynamic(notes), style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                        ],
                      ),
                      Row(
                        children: [
                          Text(weightStr, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: diff.contains('+')
                                  ? Colors.red.withOpacity(0.1)
                                  : (diff.contains('-') ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              diff,
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.bold,
                                color: diff.contains('+')
                                    ? Colors.red
                                    : (diff.contains('-') ? Colors.green : Colors.grey.shade700),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicalAlerts(Map<String, dynamic> pet) {
    final appLang = AppLanguage.of(context);
    final String allergies = pet['allergies']?.toString() ?? 'Yok';
    final String notes = pet['notes']?.toString() ?? '';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 22),
              SizedBox(width: 8.w),
              Text(
                appLang.translate('medical_alerts'),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFFE65100)),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${appLang.translate('allergies')}: ', style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              Expanded(
                child: Text(allergies.isEmpty || allergies == 'Yok' ? appLang.translateDynamic('Kayıtlı alerji yok') : appLang.translateDynamic(allergies), style: TextStyle(fontSize: 12.5.sp, color: Colors.grey.shade800)),
              ),
            ],
          ),
          if (notes.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${appLang.translate('notes_label')}: ', style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                Expanded(
                  child: Text(appLang.translateDynamic(notes), style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700, height: 1.3)),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildEmptyPetView(BuildContext context, AppLanguage appLang) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25), width: 3),
              ),
              child: Center(
                child: Icon(Icons.pets_rounded, size: 50.r, color: AppTheme.primary),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              appLang.translateDynamic('Henüz Kayıtlı Bir Dostun Yok'),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              appLang.translateDynamic('Köpeğin, kedin, kuşun veya diğer dostların için dijital aşı pasaportu, kilo grafiği ve resmi sağlık karnesi oluşturmak için hemen başla.'),
              style: TextStyle(fontSize: 12.5.sp, color: AppTheme.textLight, height: 1.45),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton.icon(
                onPressed: _showAddPetModal,
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                label: Text(
                  appLang.translateDynamic('🐾 İlk Evcil Dostumu Ekle'),
                  style: TextStyle(color: Colors.white, fontSize: 14.5.sp, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  elevation: 3,
                  shadowColor: AppTheme.primary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await GlobalState.loadSampleDemoData();
                  setState(() {
                    _selectedPetIndex = 0;
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(appLang.translateDynamic('Örnek evcil dostlar (Max, Luna, Maviş) yüklendi!')),
                        backgroundColor: AppTheme.primary,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primary, size: 18),
                label: Text(
                  appLang.translateDynamic('💡 Örnek Veriyle İncele (Demo)'),
                  style: TextStyle(color: AppTheme.primary, fontSize: 13.sp, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.35)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
              ),
            ),
            SizedBox(height: 30.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                children: [
                  _buildEmptyFeatureItem(Icons.picture_as_pdf_rounded, const Color(0xFF1B5E20), appLang.translateDynamic('Resmi Uluslararası PDF Pasaport'), appLang.translateDynamic('QR kodlu ve onaylı resmi A4 aşı çıktısı')),
                  Divider(color: Colors.grey.shade200, height: 18.h),
                  _buildEmptyFeatureItem(Icons.vaccines_rounded, const Color(0xFF2980B9), appLang.translateDynamic('Aşı ve Doz Takvim Alarmı'), appLang.translateDynamic('Karma, kuduz, parazit dozları asla unutulmaz')),
                  Divider(color: Colors.grey.shade200, height: 18.h),
                  _buildEmptyFeatureItem(Icons.monitor_weight_rounded, const Color(0xFF27AE60), appLang.translateDynamic('Kilo ve Gelişim Grafiği'), appLang.translateDynamic('İdeal kilo değişimlerini tarihsel izleyin')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFeatureItem(IconData icon, Color color, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: AppTheme.textDark)),
              Text(subtitle, style: TextStyle(fontSize: 10.sp, color: AppTheme.textLight)),
            ],
          ),
        ),
      ],
    );
  }
}
