import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Birebir Görseldeki Renkler (Eski isimlendirmelerle)
  static const Color primary = Color(0xFF1E824C); 
  static const Color secondary = Color(0xFFF39C12);
  static const Color background = Color(0xFFF7F9F9);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textLight = Color(0xFF7F8C8D);
  static const Color divider = Color(0xFFEEEEEE);

  // Kutu İkon Renkleri
  static const Color iconHealth = Color(0xFF27AE60);
  static const Color iconNutrition = Color(0xFFF29C12);
  static const Color iconCare = Color(0xFF2980B9);
  static const Color iconEducation = Color(0xFFE74C3C);
  static const Color iconShopping = Color(0xFF16A085);
  static const Color iconLocation = Color(0xFF34495E);

  // Geriye dönük uyumluluk için takma adlar
  static const Color primaryGreen = primary;
  static const Color accentOrange = secondary;
  static const Color backgroundLight = background;

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.nunito(
          color: textDark,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(color: textDark, fontWeight: FontWeight.w900),
        titleLarge: GoogleFonts.nunito(color: textDark, fontWeight: FontWeight.w800, fontSize: 18.sp),
        titleMedium: GoogleFonts.nunito(color: textDark, fontWeight: FontWeight.bold, fontSize: 14.sp),
        bodyLarge: GoogleFonts.nunito(color: textDark, fontSize: 14.sp),
        bodyMedium: GoogleFonts.nunito(color: textLight, fontSize: 12.sp),
      ),
    );
  }
}


