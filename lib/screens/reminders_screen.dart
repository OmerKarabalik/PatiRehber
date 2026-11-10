import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/global_state.dart';
import '../theme/app_theme.dart';
import '../localization/app_language.dart';
import 'health/vet_appointments_screen.dart';
import 'health/vaccine_schedule_screen.dart';
import 'health/medication_tracking_screen.dart';
import '../widgets/responsive_center.dart';

class RemindersScreen extends StatefulWidget {
  @override
  _RemindersScreenState createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  String _selectedFilter = 'Tümü';

  @override
  Widget build(BuildContext context) {
    // Collect all reminders across all pets
    List<Map<String, dynamic>> allReminders = [];

    for (var pet in GlobalState.pets) {
      final petName = pet['name'] ?? '';

      // Appointments
      final appts = GlobalState.appointments[petName] ?? [];
      for (var a in appts) {
        if (a['status'] == 'Yaklaşan') {
          allReminders.add({
            'type': 'Randevu',
            'petName': petName,
            'title': a['title'] ?? 'Veteriner Randevusu',
            'subtitle': '${a['clinic'] ?? a['location'] ?? 'Klinik'} • ${a['date']} ${a['time']}',
            'time': '${a['date']} • ${a['time']}',
            'hasAlarm': a['hasAlarm'] == true,
            'alarmLabel': a['alarmLabel'] ?? 'Randevu Alarmı',
            'reminder': a['reminder'] ?? '1 Gün Önce',
            'icon': Icons.alarm_rounded,
            'color': const Color(0xFF27AE60),
            'action': () => Navigator.push(context, MaterialPageRoute(builder: (_) => VetAppointmentsScreen())),
          });
        }
      }

      // Vaccines
      final vacs = GlobalState.vaccines[petName] ?? [];
      for (var v in vacs) {
        if (v['status'] == 'Yaklaşan') {
          allReminders.add({
            'type': 'Aşı',
            'petName': petName,
            'title': v['title'] ?? 'Aşı',
            'subtitle': 'Yaklaşan Aşı Takvimi • ${v['date']}',
            'time': v['date'] ?? '',
            'hasAlarm': true,
            'alarmLabel': 'Aşı Zamanı',
            'reminder': 'Zamanında Bildir',
            'icon': Icons.vaccines_rounded,
            'color': const Color(0xFF3498DB),
            'action': () => Navigator.push(context, MaterialPageRoute(builder: (_) => VaccineScheduleScreen())),
          });
        }
      }

      // Medications
      final meds = GlobalState.medications[petName] ?? [];
      for (var m in meds) {
        if (m['status'] == 'Aktif') {
          allReminders.add({
            'type': 'İlaç',
            'petName': petName,
            'title': m['title'] ?? 'İlaç',
            'subtitle': '${m['dosage']} • ${m['frequency']} (${m['nextTime']})',
            'time': m['nextTime'] ?? '',
            'hasAlarm': true,
            'alarmLabel': 'İlaç Saati',
            'reminder': m['frequency'] ?? 'Düzenli',
            'icon': Icons.medication_rounded,
            'color': const Color(0xFFE67E22),
            'action': () => Navigator.push(context, MaterialPageRoute(builder: (_) => MedicationTrackingScreen())),
          });
        }
      }
    }

    final filtered = allReminders.where((r) {
      if (_selectedFilter == 'Tümü') return true;
      return r['type'] == _selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLanguage.of(context).translate('reminders'),
          style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w900, fontSize: 18.sp),
        ),
      ),
      body: ResponsiveCenter(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryBanner(allReminders.length),
              SizedBox(height: 16.h),
              _buildFilterChips(),
              SizedBox(height: 18.h),
              Text(
                '${AppLanguage.of(context).translate('active_reminders')} (${filtered.length})',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
              ),
              SizedBox(height: 12.h),
              if (filtered.isEmpty)
                _buildEmptyState()
              else
                ...filtered.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildReminderCard(item),
                    )),
              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBanner(int count) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF27AE60), Color(0xFF1E824C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(color: const Color(0xFF27AE60).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.alarm_on_rounded, color: Colors.white, size: 30),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLanguage.of(context).translateDynamic('Aktif Akıllı Hatırlatıcılar'),
                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4.h),
                Text(
                  AppLanguage.of(context).translateDynamic('Tüm dostlarınız için yaklaşan veteriner randevusu, aşı ve ilaç hatırlatıcısı kuruldu.'),
                  style: TextStyle(color: Colors.white70, fontSize: 11.5.sp, height: 1.3),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.white),
                      SizedBox(width: 5.w),
                      Text(
                        AppLanguage.of(context).translateDynamic('Günü Gününe Sesli Alarm Aktif 🔔'),
                        style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Tümü', 'Randevu', 'Aşı', 'İlaç'];
    return Row(
      children: filters.map((f) {
        final isSel = _selectedFilter == f;
        return Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: ChoiceChip(
            label: Text(
              AppLanguage.of(context).translateDynamic(f),
              style: TextStyle(
                color: isSel ? Colors.white : AppTheme.textDark,
                fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
            selected: isSel,
            selectedColor: const Color(0xFF27AE60),
            backgroundColor: Colors.white,
            onSelected: (sel) {
              if (sel) setState(() => _selectedFilter = f);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> item) {
    final Color color = item['color'] as Color;
    final IconData icon = item['icon'] as IconData;
    final bool hasAlarm = item['hasAlarm'] == true;

    return InkWell(
      onTap: item['action'] as VoidCallback,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          item['petName'],
                          style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          AppLanguage.of(context).translateDynamic(item['type']),
                          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: color),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    AppLanguage.of(context).translateDynamic(item['title']),
                    style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    AppLanguage.of(context).translateDynamic(item['subtitle']),
                    style: TextStyle(fontSize: 11.5.sp, color: AppTheme.textLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasAlarm) ...[
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        const Icon(Icons.notifications_active_rounded, size: 13, color: Color(0xFF27AE60)),
                        SizedBox(width: 4.w),
                        Text(
                          '${AppLanguage.of(context).translateDynamic(item['alarmLabel'])} (${AppLanguage.of(context).translateDynamic(item['reminder'])})',
                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF27AE60)),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22.r)),
      child: Column(
        children: [
          Icon(Icons.notifications_off_outlined, size: 50, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(
            AppLanguage.of(context).translateDynamic('Yaklaşan Hatırlatıcı Yok'),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          SizedBox(height: 6.h),
          Text(
            AppLanguage.of(context).translateDynamic('Seçtiğiniz kategoride henüz bekleyen bir randevu veya alarm bulunmuyor.'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }
}
