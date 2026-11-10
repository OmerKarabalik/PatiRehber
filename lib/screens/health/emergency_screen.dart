import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/global_state.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_language.dart';
import '../../widgets/responsive_center.dart';

class EmergencyScreen extends StatefulWidget {
  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  int _selectedPetIndex = 0;

  final List<Map<String, String>> _guides = [
    {'title': 'Zehirlenme Durumu', 'desc': 'Kusma, titreme, nefes darlığı varsa derhal veterineri arayın. Asla kendi başınıza kusturmaya çalışmayın.'},
    {'title': 'Yaralanma / Kanama', 'desc': 'Kanayan bölgeye temiz bir bezle hafif baskı uygulayın. Turnike yapmaktan kaçının ve hızlıca kliniğe gidin.'},
    {'title': 'Sıcak Çarpması', 'desc': 'Aşırı nefes nefese kalma ve baygınlık durumunda patilerini ve göbeğini serin (buzlu olmayan) suyla ıslatın.'}
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

  void _showActionModal({Map<String, dynamic>? contact, int? index}) {
    final appLang = AppLanguage.of(context, listen: false);
    final titleController = TextEditingController(text: contact != null ? appLang.translateDynamic(contact['title']?.toString() ?? '') : '');
    final nameController = TextEditingController(text: contact != null ? appLang.translateDynamic(contact['name']?.toString() ?? '') : '');
    final phoneController = TextEditingController(text: contact != null ? (contact['phone']?.toString() ?? '') : '');

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
                          contact != null ? appLang.translate('edit_emergency_contact') : appLang.translate('new_emergency_contact'),
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        if (contact != null && index != null)
                          IconButton(
                            tooltip: appLang.translate('delete'),
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 24),
                            onPressed: () {
                              final petName = GlobalState.pets[_selectedPetIndex]['name'];
                              setState(() {
                                if (GlobalState.emergencyContacts[petName] != null && index < GlobalState.emergencyContacts[petName]!.length) {
                                  GlobalState.emergencyContacts[petName]!.removeAt(index);
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
                    TextField(controller: titleController, decoration: InputDecoration(labelText: appLang.translate('contact_title_hint'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
                    SizedBox(height: 12.h),
                    TextField(controller: nameController, decoration: InputDecoration(labelText: appLang.translate('contact_name_hint'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
                    SizedBox(height: 12.h),
                    TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: appLang.translate('phone_number'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final name = nameController.text.trim();
                          final phone = phoneController.text.trim();
                          if (title.isNotEmpty && phone.isNotEmpty) {
                            setState(() {
                              final petName = GlobalState.pets[_selectedPetIndex]['name'];
                              GlobalState.emergencyContacts.putIfAbsent(petName, () => []);
                              if (index != null && index < GlobalState.emergencyContacts[petName]!.length) {
                                GlobalState.emergencyContacts[petName]![index] = {'title': title, 'name': name, 'phone': phone, 'color': const Color(0xFFE74C3C)};
                              } else {
                                GlobalState.emergencyContacts[petName]!.add({'title': title, 'name': name, 'phone': phone, 'color': const Color(0xFFE74C3C)});
                              }
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE74C3C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
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
    final contacts = GlobalState.emergencyContacts[petName] ?? [];

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
                      child: Text(
                        AppLanguage.of(context).translate('emergency_contacts_list'),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton.icon(
                      onPressed: () => _showActionModal(),
                      icon: const Icon(Icons.add, color: Colors.white, size: 16),
                      label: Text(AppLanguage.of(context).translate('add_contact_btn'), style: const TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE74C3C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                        minimumSize: Size.zero,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16.h),
                if (contacts.isEmpty)
                  Center(child: Padding(padding: const EdgeInsets.all(20), child: Text(AppLanguage.of(context).translate('no_contacts_recorded'), style: const TextStyle(color: Colors.grey))))
                else
                  ...contacts.asMap().entries.map((entry) => Padding(
                    padding: EdgeInsets.only(bottom: 12.0.h),
                    child: _buildContactCard(entry.value, entry.key),
                  )).toList(),
                SizedBox(height: 24.h),
                Text(AppLanguage.of(context).translate('emergency_guide'), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                SizedBox(height: 16.h),
                ..._guides.map((guide) => Padding(
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
                appLang.translate('app_subtitle'),
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
              color: const Color(0xFFE74C3C),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 32),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appLang.translate('emergency'), style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                SizedBox(height: 4.h),
                Text(appLang.translate('emergency_desc'), style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, height: 1.3)),
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

  Widget _buildContactCard(Map<String, dynamic> contact, int index) {
    final appLang = AppLanguage.of(context);
    Color cardColor = (contact['color'] is Color) ? contact['color'] : const Color(0xFFE74C3C);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: cardColor.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () => _showActionModal(contact: contact, index: index),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(color: cardColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.phone_in_talk_rounded, color: cardColor, size: 26),
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
                              appLang.translateDynamic(contact['title']),
                              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Material(
                            color: const Color(0xFFE74C3C).withOpacity(0.12),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _showActionModal(contact: contact, index: index),
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: const Icon(Icons.edit_rounded, color: Color(0xFFE74C3C), size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(appLang.translateDynamic(contact['name']), style: TextStyle(fontSize: 12.5.sp, color: AppTheme.textLight, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4.h),
                      Text(contact['phone'] ?? '', style: TextStyle(fontSize: 13.5.sp, color: cardColor, fontWeight: FontWeight.bold)),
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
