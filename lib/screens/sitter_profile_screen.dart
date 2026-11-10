import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/sitter_model.dart';
import '../localization/app_language.dart';
import 'chat_screen.dart';

class SitterProfileScreen extends StatelessWidget {
  final SitterModel sitter;

  const SitterProfileScreen({super.key, required this.sitter});

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(appLang.translateDynamic('Bakıcı Profili')),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header Info
            Container(
              padding: EdgeInsets.symmetric(vertical: 24.0.h, horizontal: 20.0.w),
              color: Colors.white,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF00ACC1).withValues(alpha: 0.1),
                    backgroundImage: NetworkImage(sitter.avatarUrl),
                    onBackgroundImageError: (_, _) {},
                    child: const Icon(Icons.person, color: Color(0xFF00ACC1), size: 40),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    sitter.name,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
                      SizedBox(width: 4.w),
                      Text(
                        sitter.city,
                        style: TextStyle(color: const Color(0xFF7F8C8D), fontSize: 14.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4.w),
                            Text(
                              '${sitter.rating} (${appLang.translateDynamic('${sitter.reviewsCount} Yorum')})',
                              style: TextStyle(
                                color: const Color(0xFFC75A3C),
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // Sitter details
            Padding(
              padding: EdgeInsets.all(20.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Section
                  Text(
                    appLang.translateDynamic('Hakkında'),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    appLang.translateDynamic(sitter.bio),
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.5,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Services and Pricing
                  Text(
                    appLang.translateDynamic('Hizmetler ve Ücretlendirme'),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: sitter.services.map((service) {
                      return Card(
                        margin: EdgeInsets.zero,
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 12.0.h),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.circleCheck,
                                color: Color(0xFF00ACC1),
                                size: 16,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                appLang.translateDynamic(service),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 24.h),

                  // Contact Details
                  Text(
                    appLang.translateDynamic('İletişim Bilgileri'),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: EdgeInsets.all(16.0.w),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00ACC1).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.phone,
                              color: Color(0xFF00ACC1),
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appLang.translateDynamic('Telefon Numarası'),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                sitter.contactPhone,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Start Chat Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const FaIcon(FontAwesomeIcons.solidComment, size: 18),
                      label: Text(appLang.translateDynamic('Mesaj Gönder / Sohbet Başlat')),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(sitter: sitter),
                          ),
                        );
                      },
                    ),
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