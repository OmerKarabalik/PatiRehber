import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../localization/app_language.dart';
import 'home_screen.dart';
import 'my_pet_tracking_screen.dart';
import 'reminders_screen.dart';
import 'profile_screen.dart';
import 'health/vaccine_schedule_screen.dart';
import 'health/vet_appointments_screen.dart';
import 'health/health_records_screen.dart';
import 'health/medication_tracking_screen.dart';
import '../theme/app_theme.dart';
import '../models/global_state.dart';
import '../services/pdf_passport_service.dart';

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    MyPetTrackingScreen(),
    RemindersScreen(),
    ProfileScreen(),
  ];

  void _showQuickActionSheet() {
    final appLang = AppLanguage.of(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              ),
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
              Text(
                appLang.translateDynamic('Hızlı İşlemler'),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
              ),
              SizedBox(height: 4.h),
              Text(
                appLang.translateDynamic('Minik dostunuz için anında kayıt oluşturun.'),
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight),
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      title: appLang.translate('vet_appointments'),
                      icon: Icons.calendar_month_rounded,
                      color: const Color(0xFF27AE60),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => VetAppointmentsScreen()));
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildQuickActionButton(
                      title: appLang.translate('health_records'),
                      icon: Icons.description_rounded,
                      color: const Color(0xFF1E824C),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => HealthRecordsScreen()));
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      title: appLang.translate('vaccine_calendar'),
                      icon: Icons.vaccines_rounded,
                      color: const Color(0xFF3498DB),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => VaccineScheduleScreen()));
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildQuickActionButton(
                      title: appLang.translate('medication_tracking'),
                      icon: Icons.medication_rounded,
                      color: const Color(0xFFE67E22),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => MedicationTrackingScreen()));
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      title: appLang.translate('my_pet'),
                      icon: Icons.pets_rounded,
                      color: const Color(0xFF9B59B6),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _currentIndex = 1);
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildQuickActionButton(
                      title: appLang.translate('reminders'),
                      icon: Icons.notifications_active_rounded,
                      color: const Color(0xFFE74C3C),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _currentIndex = 2);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _buildQuickActionButton(
                title: '📄 ${appLang.translateDynamic('Resmi Aşı & Sağlık Pasaportu (PDF)')}',
                icon: Icons.picture_as_pdf_rounded,
                color: const Color(0xFF1B5E20),
                onTap: () {
                  Navigator.pop(context);
                  final pets = GlobalState.pets;
                  if (pets.isEmpty) {
                    setState(() => _currentIndex = 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(appLang.translateDynamic('PDF pasaport oluşturmak için önce evcil dostunuzu ekleyin.')),
                        backgroundColor: AppTheme.primary,
                      ),
                    );
                    return;
                  }
                  final activePet = pets.first;
                  final petName = activePet['name']?.toString() ?? 'Max';
                  final vaccines = (GlobalState.vaccines[petName] as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
                  final records = (GlobalState.healthRecords[petName] as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
                  PdfPassportService.showRewardedPdfFlow(
                    context,
                    pet: activePet,
                    vaccines: vaccines,
                    healthRecords: records,
                  );
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: color.withOpacity(0.18), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = AppLanguage.of(context);

    return Scaffold(
      extendBody: false,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE8ECEF), width: 1.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: _buildTabItem(icon: Icons.home_rounded, label: appLanguage.translate('home'), index: 0),
                ),
                Expanded(
                  child: _buildTabItem(icon: Icons.pets_rounded, label: appLanguage.translate('my_pet'), index: 1),
                ),
                // Center Quick Action FAB
                Expanded(
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showQuickActionSheet,
                        customBorder: const CircleBorder(),
                        child: Ink(
                          width: 48.r,
                          height: 48.r,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF27AE60), Color(0xFF1E824C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.14),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildTabItem(icon: Icons.notifications_active_outlined, label: appLanguage.translate('reminders'), index: 2),
                ),
                Expanded(
                  child: _buildTabItem(icon: Icons.person_outline_rounded, label: appLanguage.translate('profile'), index: 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF1E824C) : Colors.grey.shade400;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      splashColor: const Color(0xFF1E824C).withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22.r),
          SizedBox(height: 3.h),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.5.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
