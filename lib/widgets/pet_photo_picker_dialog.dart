import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../localization/app_language.dart';
import '../theme/app_theme.dart';

class PetPhotoPickerDialog {
  static const List<Map<String, String>> defaultAvatars = [
    {'path': 'assets/images/dog_avatar.png', 'name': 'Köpek'},
    {'path': 'assets/images/cat_avatar.png', 'name': 'Kedi'},
    {'path': 'assets/images/bird_avatar.png', 'name': 'Kuş'},
    {'path': 'assets/images/rabbit_avatar.png', 'name': 'Tavşan'},
    {'path': 'assets/images/hamster_avatar.png', 'name': 'Hamster'},
    {'path': 'assets/images/fish_avatar.png', 'name': 'Balık'},
    {'path': 'assets/images/pet_avatar.png', 'name': 'Pati'},
  ];

  static Future<String?> show(
    BuildContext context, {
    String? currentImagePath,
    String petType = 'Köpek',
  }) async {
    final appLang = AppLanguage.of(context);
    final picker = ImagePicker();

    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: AppTheme.primary, size: 22),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appLang.translateDynamic('Evcil Dostunun Fotoğrafı'),
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          appLang.translateDynamic('Kendi fotoğrafını yükle veya sevimli avatar seç'),
                          style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.camera_enhance_rounded,
                      label: appLang.translateDynamic('Kamera'),
                      sublabel: appLang.translateDynamic('Yeni Çek'),
                      color: const Color(0xFF2E7D32),
                      onTap: () async {
                        try {
                          final XFile? photo = await picker.pickImage(
                            source: ImageSource.camera,
                            maxWidth: 1200,
                            maxHeight: 1200,
                            imageQuality: 85,
                          );
                          if (photo != null && ctx.mounted) {
                            Navigator.pop(ctx, photo.path);
                          }
                        } catch (e) {
                          debugPrint('Camera error: $e');
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.photo_library_rounded,
                      label: appLang.translateDynamic('Galeri'),
                      sublabel: appLang.translateDynamic('Cihazdan Seç'),
                      color: const Color(0xFF1976D2),
                      onTap: () async {
                        try {
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 1200,
                            maxHeight: 1200,
                            imageQuality: 85,
                          );
                          if (image != null && ctx.mounted) {
                            Navigator.pop(ctx, image.path);
                          }
                        } catch (e) {
                          debugPrint('Gallery error: $e');
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 22.h),
              Text(
                appLang.translateDynamic('Veya Hazır Sevimli Karakter Seç:'),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 80.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: defaultAvatars.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
                  itemBuilder: (context, i) {
                    final item = defaultAvatars[i];
                    final isSelected = currentImagePath == item['path'];
                    return GestureDetector(
                      onTap: () => Navigator.pop(ctx, item['path']),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                                width: isSelected ? 3 : 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primary.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: CircleAvatar(
                              radius: 24.r,
                              backgroundColor: Colors.grey.shade100,
                              backgroundImage: AssetImage(item['path']!),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            appLang.translatePetType(item['name']!),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppTheme.primary : AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (currentImagePath != null && currentImagePath.isNotEmpty) ...[
                SizedBox(height: 14.h),
                TextButton.icon(
                  onPressed: () => Navigator.pop(ctx, ''),
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                  label: Text(
                    appLang.translateDynamic('Fotoğrafı Kaldır / Varsayılana Dön'),
                    style: TextStyle(color: Colors.red, fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  Text(
                    sublabel,
                    style: TextStyle(fontSize: 10.5.sp, color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
