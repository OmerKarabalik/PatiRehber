import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/global_state.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_language.dart';
import 'vaccine_schedule_screen.dart';
import 'vet_appointments_screen.dart';
import 'health_records_screen.dart';
import 'medication_tracking_screen.dart';
import 'disease_symptoms_screen.dart';
import 'emergency_screen.dart';

class HealthDashboardScreen extends StatefulWidget {
  @override
  _HealthDashboardScreenState createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 24.h),
              _buildPetSelector(),
              SizedBox(height: 24.h),
              _buildHealthGrid(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final appLang = AppLanguage.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 22),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        SizedBox(width: 10.w),
        const Icon(Icons.pets, color: AppTheme.primary, size: 36),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appLang.translate('health'),
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                appLang.translate('health_sub'),
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight),
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

  Widget _buildHealthGrid() {
    final appLang = AppLanguage.of(context);
    final List<Map<String, dynamic>> menuItems = [
      {
        'key': 'vaccine_calendar',
        'title': appLang.translate('vaccine_calendar'),
        'subtitle': appLang.translate('vaccine_calendar_sub'),
        'icon': Icons.calendar_today_rounded,
        'iconColor': Color(0xFF27AE60),
        'bgColor': Color(0xFF27AE60).withOpacity(0.1),
      },
      {
        'key': 'vet_appointments',
        'title': appLang.translate('vet_appointments'),
        'subtitle': appLang.translate('vet_appointments_sub'),
        'icon': Icons.medical_services_outlined,
        'iconColor': Color(0xFFF39C12),
        'bgColor': Color(0xFFF39C12).withOpacity(0.1),
      },
      {
        'key': 'health_records',
        'title': appLang.translate('health_records'),
        'subtitle': appLang.translate('health_records_sub'),
        'icon': Icons.description_rounded,
        'iconColor': Color(0xFF1E824C),
        'bgColor': Color(0xFF1E824C).withOpacity(0.1),
      },
      {
        'key': 'medication_tracking',
        'title': appLang.translate('medication_tracking'),
        'subtitle': appLang.translate('medication_tracking_sub'),
        'icon': Icons.medication_rounded,
        'iconColor': Color(0xFFE67E22),
        'bgColor': Color(0xFFE67E22).withOpacity(0.1),
      },
      {
        'key': 'disease_symptoms',
        'title': appLang.translate('disease_symptoms'),
        'subtitle': appLang.translate('disease_symptoms_sub'),
        'icon': Icons.search_rounded,
        'iconColor': Color(0xFF2ECC71),
        'bgColor': Color(0xFF2ECC71).withOpacity(0.1),
      },
      {
        'key': 'emergency',
        'title': appLang.translate('emergency'),
        'subtitle': appLang.translate('emergency_sub'),
        'icon': Icons.notifications_active_rounded,
        'iconColor': Color(0xFFE74C3C),
        'bgColor': Color(0xFFE74C3C).withOpacity(0.1),
      },
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.15,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return GestureDetector(
          onTap: () {
            if (item['key'] == 'vaccine_calendar') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => VaccineScheduleScreen()));
            } else if (item['key'] == 'vet_appointments') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => VetAppointmentsScreen()));
            } else if (item['key'] == 'health_records') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => HealthRecordsScreen()));
            } else if (item['key'] == 'medication_tracking') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => MedicationTrackingScreen()));
            } else if (item['key'] == 'disease_symptoms') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DiseaseSymptomsScreen()));
            } else if (item['key'] == 'emergency') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => EmergencyScreen()));
            }
          },
          child: _buildGridItem(
            title: item['title'],
            subtitle: item['subtitle'],
            icon: item['icon'],
            iconColor: item['iconColor'],
            bgColor: item['bgColor'],
          ),
        );
      },
    );
  }

  Widget _buildGridItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))
        ]
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(child: Icon(icon, color: Colors.white, size: 28)),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp, color: AppTheme.textDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppTheme.textDark, size: 16),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10.sp, color: AppTheme.textLight, height: 1.2),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}




