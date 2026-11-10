import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'localization/app_language.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';
import 'services/ad_service.dart';
import 'services/alarm_notification_service.dart';
import 'services/in_app_purchase_service.dart';
import 'models/global_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  // Google AdMob SDK'sını başlat
  await AdService.initialize();

  // In-App Purchase (Google Play Store) servisini başlat
  await InAppPurchaseService.initialize();

  // Yerel hafızayı (Kalıcı evcil hayvan & sağlık verilerini) yükle
  await GlobalState.initialize();

  // Telefon alarm ve sesli bildirim servisini başlat
  await AlarmNotificationService.initialize();

  final appLanguage = AppLanguage();
  await appLanguage.loadSavedLanguage();

  runApp(
    ChangeNotifierProvider<AppLanguage>.value(
      value: appLanguage,
      child: PatiRehberApp(),
    ),
  );
}

class PatiRehberApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: appLanguage.translate('app_title'),
          locale: Locale(appLanguage.currentLanguage),
          theme: ThemeData(
            primaryColor: AppTheme.primary,
            scaffoldBackgroundColor: Colors.grey[100],
            appBarTheme: const AppBarTheme(
              backgroundColor: AppTheme.primary,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: AppTheme.primary,
              secondary: AppTheme.secondary,
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: child,
        );
      },
      child: MainNavigationScreen(),
    );
  }
}
