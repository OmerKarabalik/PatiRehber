import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/global_state.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_language.dart';

class CareDashboardScreen extends StatefulWidget {
  @override
  _CareDashboardScreenState createState() => _CareDashboardScreenState();
}

class _CareDashboardScreenState extends State<CareDashboardScreen> {
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

  void _showCareInfoModal(String title, Color color, IconData icon) {
    final appLang = AppLanguage.of(context);
    final pet = GlobalState.pets[_selectedPetIndex];
    String desc = '';
    if (title == 'Tıraş') {
      desc = '${pet['type']} dostunuz ${pet['name']} için mevsimsel tıraş rutini tüy dökümünü azaltır ve cildinin nefes almasını sağlar. Aşırı kısa kesimlerden kaçınılmalıdır.';
    } else if (title == 'Banyo') {
      desc = '${pet['type']} dostunuz ${pet['name']} çok sık yıkanmamalıdır. Özel ${pet['type']} şampuanı ile yıkayıp iyice kuruladığınızdan emin olun.';
    } else if (title == 'Tırnak Kesimi') {
      desc = '${pet['name']} tırnaklarını düzenli kestirmezse yürüyüş bozuklukları yaşayabilir. Canlı dokuyu (pembe kısmı) kesmemeye çok dikkat edin.';
    } else {
      desc = '${pet['name']} için $title uygulaması genel sağlığı ve yaşam kalitesini doğrudan artırır. Detaylı bilgi için veterinerinize danışın.';
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${appLang.translateDynamic(title)} ${appLang.translate('guide_suffix')}', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        Text('${appLang.translate('care_tips_for')} ${pet['name']}', style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight)),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16.r)),
                child: Text(appLang.translateDynamic(desc), style: TextStyle(fontSize: 14.sp, color: AppTheme.textDark, height: 1.5)),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                  child: Text(appLang.translate('understood'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 24.h),
              _buildTitleCard(),
              SizedBox(height: 16.h),
              _buildPetSelector(),
              SizedBox(height: 24.h),
              Text(AppLanguage.of(context).translate('care_needs_title'), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
              SizedBox(height: 16.h),
              _buildCareGrid(),
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
      children: [
        InkWell(onTap: () => Navigator.pop(context), child: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 22)),
        SizedBox(width: 12.w),
        Icon(Icons.pets, color: Color(0xFF8E44AD), size: 32),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appLang.translate('app_title'), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
            Text(appLang.translate('care_sub'), style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight)),
          ],
        )
      ],
    );
  }

  Widget _buildTitleCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))]),
      child: Row(
        children: [
          Container(padding: EdgeInsets.all(16.w), decoration: BoxDecoration(color: Color(0xFF8E44AD), borderRadius: BorderRadius.circular(20.r)), child: Icon(Icons.dry_cleaning_rounded, color: Colors.white, size: 32)),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLanguage.of(context).translate('care'), style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                SizedBox(height: 4.h),
                Text(AppLanguage.of(context).translate('care_sub'), style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, height: 1.3)),
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
              decoration: BoxDecoration(color: isSelected ? Color(0xFF8E44AD) : Colors.white, borderRadius: BorderRadius.circular(30.r), boxShadow: isSelected ? [BoxShadow(color: Color(0xFF8E44AD).withOpacity(0.4), blurRadius: 8, offset: Offset(0, 4))] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))]),
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

  Widget _buildCareGrid() {
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Tıraş', 'subtitle': 'Tüy bakımı & tıraş', 'icon': Icons.content_cut_rounded, 'iconColor': Color(0xFF8E44AD)},
      {'title': 'Banyo', 'subtitle': 'Hijyenik temizlik', 'icon': Icons.shower_rounded, 'iconColor': Color(0xFF3498DB)},
      {'title': 'Tırnak Kesimi', 'subtitle': 'Sağlıklı patiler', 'icon': Icons.healing_rounded, 'iconColor': Color(0xFFE67E22)},
      {'title': 'Kulak Temizliği', 'subtitle': 'Enfeksiyona karşı', 'icon': Icons.hearing_rounded, 'iconColor': Color(0xFF27AE60)},
      {'title': 'Diş Bakımı', 'subtitle': 'Ağız ve diş sağlığı', 'icon': Icons.medical_services_rounded, 'iconColor': Color(0xFFE74C3C)},
      {'title': 'Parazit Kontrolü', 'subtitle': 'Daha sağlıklı yaşam', 'icon': Icons.shield_rounded, 'iconColor': Color(0xFF16A085)},
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        mainAxisExtent: 122.h,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return InkWell(
          onTap: () => _showCareInfoModal(item['title'], item['iconColor'], item['icon']),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.grey[200]!)),
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'], color: item['iconColor'], size: 28),
                SizedBox(height: 8.h),
                Text(AppLanguage.of(context).translateDynamic(item['title']), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp, color: AppTheme.textDark), textAlign: TextAlign.center, maxLines: 1),
                SizedBox(height: 4.h),
                Text(AppLanguage.of(context).translateDynamic(item['subtitle']), style: TextStyle(fontSize: 8.sp, color: AppTheme.textLight), textAlign: TextAlign.center, maxLines: 2),
              ],
            ),
          ),
        );
      },
    );
  }
}




