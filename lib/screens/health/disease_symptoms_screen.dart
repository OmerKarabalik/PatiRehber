import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/global_state.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_language.dart';
import '../../widgets/responsive_center.dart';

class DiseaseSymptomsScreen extends StatefulWidget {
  @override
  _DiseaseSymptomsScreenState createState() => _DiseaseSymptomsScreenState();
}

class _DiseaseSymptomsScreenState extends State<DiseaseSymptomsScreen> {
  int _selectedPetIndex = 0;

  final List<Map<String, String>> _commonSymptoms = [
    {'title': 'İştahsızlık', 'desc': '24 saatten uzun süren iştahsızlık durumunda veteriner kontrolü önerilir.'},
    {'title': 'Sık Su İçme ve İdrara Çıkma', 'desc': 'Diyabet veya böbrek rahatsızlıklarının erken belirtisi olabilir.'},
    {'title': 'Halsizlik ve İsteksizlik', 'desc': 'Sürekli uyuma, oyun oynamama enfeksiyon veya ağrı işareti olabilir.'},
    {'title': 'Sık Kaşınma veya Tüy Dökme', 'desc': 'Alerji, parazit veya mantar enfeksiyonlarına işaret edebilir.'},
  ];

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

  void _showActionModal({Map<String, dynamic>? sym, int? index}) {
    final appLang = AppLanguage.of(context, listen: false);
    final titleController = TextEditingController(text: sym != null ? appLang.translateDynamic(sym['title']?.toString() ?? '') : '');
    final dateController = TextEditingController(text: sym != null ? appLang.translateDate(sym['date']?.toString() ?? '') : appLang.translate('today'));
    final notesController = TextEditingController(text: sym != null ? appLang.translateDynamic(sym['notes']?.toString() ?? '') : '');
    String severity = sym != null ? (sym['severity']?.toString() ?? 'Hafif') : 'Hafif';

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
                          sym != null ? appLang.translate('edit_symptom') : appLang.translate('new_symptom'),
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        if (sym != null && index != null)
                          IconButton(
                            tooltip: appLang.translate('delete'),
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 24),
                            onPressed: () {
                              final petName = GlobalState.pets[_selectedPetIndex]['name'];
                              setState(() {
                                if (GlobalState.symptoms[petName] != null && index < GlobalState.symptoms[petName]!.length) {
                                  GlobalState.symptoms[petName]!.removeAt(index);
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
                    TextField(controller: titleController, decoration: InputDecoration(labelText: appLang.translate('symptom_name_hint'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
                    SizedBox(height: 12.h),
                    TextField(controller: dateController, decoration: InputDecoration(labelText: appLang.translate('date'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
                    SizedBox(height: 12.h),
                    TextField(controller: notesController, maxLines: 2, decoration: InputDecoration(labelText: appLang.translate('notes_desc'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
                    SizedBox(height: 16.h),
                    Text(appLang.translate('severity'), style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8,
                      children: [
                        {'key': 'Hafif', 'label': appLang.translate('severity_mild'), 'color': const Color(0xFF2ECC71)},
                        {'key': 'Orta', 'label': appLang.translate('severity_moderate'), 'color': const Color(0xFFF39C12)},
                        {'key': 'Yüksek', 'label': appLang.translate('severity_severe'), 'color': const Color(0xFFE74C3C)},
                      ].map((item) {
                        bool isSelected = severity == item['key'];
                        Color color = item['color'] as Color;
                        return ChoiceChip(
                          label: Text(item['label'] as String, style: TextStyle(color: isSelected ? Colors.white : color)),
                          selected: isSelected,
                          selectedColor: color,
                          onSelected: (selected) {
                            if (selected) setModalState(() => severity = item['key'] as String);
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
                              Color c = severity == 'Hafif' ? const Color(0xFF2ECC71) : severity == 'Orta' ? const Color(0xFFF39C12) : const Color(0xFFE74C3C);
                              final petName = GlobalState.pets[_selectedPetIndex]['name'];
                              GlobalState.symptoms.putIfAbsent(petName, () => []);
                              if (index != null && index < GlobalState.symptoms[petName]!.length) {
                                GlobalState.symptoms[petName]![index] = {'title': title, 'date': date, 'severity': severity, 'notes': notes, 'color': c};
                              } else {
                                GlobalState.symptoms[petName]!.insert(0, {'title': title, 'date': date, 'severity': severity, 'notes': notes, 'color': c});
                              }
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
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
    if (_selectedPetIndex >= GlobalState.pets.length) {
      _selectedPetIndex = 0;
    }
    final pet = GlobalState.pets.isNotEmpty ? GlobalState.pets[_selectedPetIndex] : {'name': 'Max', 'type': 'Köpek'};
    final petName = pet['name'] ?? 'Max';
    final symptoms = GlobalState.symptoms[petName] ?? [];

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
                          AppLanguage.of(context).translate('symptoms_list'),
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton.icon(
                      onPressed: () => _showActionModal(),
                      icon: const Icon(Icons.add, color: Colors.white, size: 16),
                      label: Text(
                        AppLanguage.of(context).translate('add_symptom_btn').replaceAll('+ ', '').replaceAll('+', '').trim(),
                        style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                        minimumSize: Size.zero,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16.h),
                if (symptoms.isEmpty)
                  Center(child: Padding(padding: const EdgeInsets.all(20), child: Text(AppLanguage.of(context).translate('no_symptoms_recorded'), style: const TextStyle(color: Colors.grey))))
                else
                  ...symptoms.asMap().entries.map((entry) => Padding(
                    padding: EdgeInsets.only(bottom: 12.0.h),
                    child: _buildSymptomCard(entry.value, entry.key),
                  )).toList(),
                SizedBox(height: 24.h),
                Text(AppLanguage.of(context).translate('common_symptoms_guide'), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                SizedBox(height: 16.h),
                ..._commonSymptoms.map((guide) => Padding(
                  padding: EdgeInsets.only(bottom: 12.0.h),
                  child: _buildGuideCard(guide),
                )).toList(),
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
            Text(appLang.translate('app_title'), style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
            Text(appLang.translate('app_subtitle'), style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight)),
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
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: const Icon(Icons.search_rounded, color: Colors.white, size: 32),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appLang.translate('disease_symptoms'), style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                SizedBox(height: 4.h),
                Text(appLang.translate('symptoms_desc'), style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, height: 1.3)),
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

  Widget _buildSymptomCard(Map<String, dynamic> sym, int index) {
    final appLang = AppLanguage.of(context);
    Color symColor = (sym['color'] is Color) ? sym['color'] : const Color(0xFF2ECC71);

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
          onTap: () => _showActionModal(sym: sym, index: index),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(color: symColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.warning_amber_rounded, color: symColor, size: 26),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              appLang.translateDynamic(sym['title']),
                              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(color: symColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
                            child: Text(
                              '${appLang.translate('severity')}: ${appLang.translateDynamic(sym['severity'])}',
                              style: TextStyle(fontSize: 10.sp, color: symColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Material(
                            color: const Color(0xFF2ECC71).withOpacity(0.12),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _showActionModal(sym: sym, index: index),
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: const Icon(Icons.edit_rounded, color: Color(0xFF2ECC71), size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 13, color: AppTheme.textLight),
                          SizedBox(width: 5.w),
                          Text(appLang.translateDate(sym['date']), style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      if ((sym['notes'] ?? '').toString().isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Text(appLang.translateDynamic(sym['notes']), style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700, height: 1.3)),
                      ],
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
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16.r)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.grey.shade600, size: 20),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appLang.translateDynamic(guide['title']!), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                SizedBox(height: 4.h),
                Text(appLang.translateDynamic(guide['desc']!), style: TextStyle(fontSize: 12.5.sp, color: AppTheme.textLight, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
