import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../localization/app_language.dart';

class SitterSearchScreen extends StatefulWidget {
  const SitterSearchScreen({super.key});

  @override
  State<SitterSearchScreen> createState() => _SitterSearchScreenState();
}

class _SitterSearchScreenState extends State<SitterSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCity = '';

  final List<String> _popularCities = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Bursa',
    'Antalya',
    'Adana',
    'Konya',
    'Gaziantep',
    'Trabzon',
    'Eskişehir',
    'Kayseri',
    'Mersin',
    'Samsun',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _callPhone(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      await launchUrl(uri);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(phone)),
        );
      }
    }
  }

  Future<void> _openLiveMap(AppLanguage appLang, [String? targetCity]) async {
    String query;
    final lang = appLang.currentLanguage;
    final city = targetCity ?? _selectedCity;

    if (city.trim().isNotEmpty) {
      if (lang == 'en') {
        query = '$city emergency veterinary clinic';
      } else if (lang == 'de') {
        query = '$city tiernotdienst';
      } else if (lang == 'fr') {
        query = '$city vétérinaire de garde';
      } else if (lang == 'es') {
        query = '$city veterinario de urgencias';
      } else if (lang == 'ru') {
        query = '$city дежурная ветеринарная клиника';
      } else {
        query = '$city nöbetçi veteriner klinikleri';
      }
    } else {
      if (lang == 'en') {
        query = 'emergency veterinary clinic near me';
      } else if (lang == 'de') {
        query = 'tiernotdienst in der nähe';
      } else if (lang == 'fr') {
        query = 'vétérinaire de garde à proximité';
      } else if (lang == 'es') {
        query = 'veterinario de urgencias cerca de mí';
      } else if (lang == 'ru') {
        query = 'дежурная ветеринарная клиника рядом';
      } else {
        query = 'en yakın nöbetçi veteriner klinikleri';
      }
    }

    final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    final geoUri = Uri.parse('geo:0,0?q=${Uri.encodeComponent(query)}');

    // 1. Try native geo intent (opens Google Maps app directly on Android)
    try {
      final launchedGeo = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      if (launchedGeo) return;
    } catch (_) {}

    // 2. Try web url in external app/browser
    try {
      final launchedWeb = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      if (launchedWeb) return;
    } catch (_) {}

    // 3. Fallback platform default
    try {
      await launchUrl(webUri, mode: LaunchMode.platformDefault);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLang.translateDynamic('Harita uygulaması açılamadı. Lütfen Google Haritalar\'ı açıp aratın.')),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(appLang.translate('clinics')),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLiveGpsCard(appLang),
            SizedBox(height: 16.h),
            _buildOfficialEmergencyHotlines(appLang),
            SizedBox(height: 20.h),
            _buildCitySearchHeader(appLang),
            SizedBox(height: 12.h),
            _buildSearchBar(appLang),
            SizedBox(height: 12.h),
            _buildCityChips(appLang),
            SizedBox(height: 16.h),
            _buildCityResultCard(appLang),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveGpsCard(AppLanguage appLang) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE74C3C).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openLiveMap(appLang),
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 26),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appLang.translateDynamic('Yakınımdaki Nöbetçi Veterinerleri Canlı Bul'),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            appLang.translateDynamic('81 İl & Konumunuza göre açık acil klinikleri Google Haritalar\'da açın'),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 11.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map_rounded, color: Color(0xFFE74C3C), size: 18),
                      SizedBox(width: 8.w),
                      Text(
                        appLang.translateDynamic('Haritada Canlı Aç'),
                        style: TextStyle(
                          color: const Color(0xFFE74C3C),
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5.sp,
                        ),
                      ),
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

  Widget _buildOfficialEmergencyHotlines(AppLanguage appLang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLang.translateDynamic('7/24 Resmi Acil Hatlar'),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppTheme.textDark),
        ),
        SizedBox(height: 10.h),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          elevation: 1.5,
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF27AE60), size: 24),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appLang.translateDynamic('153 Hayvan Ambulansı & Acil Müdahale'),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppTheme.textDark),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        appLang.translateDynamic('Yaralı veya acil durumdaki evcil dostlarımız için 7/24 belediye acil hattı'),
                        style: TextStyle(fontSize: 10.5.sp, color: AppTheme.textLight),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: () => _callPhone('153'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: Text(
                    appLang.translateDynamic('Ara (153)'),
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCitySearchHeader(AppLanguage appLang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLang.translateDynamic('81 İl Şehir Bazlı Nöbetçi Arama'),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppTheme.textDark),
        ),
        SizedBox(height: 2.h),
        Text(
          appLang.translateDynamic('Seçtiğiniz şehir veya ilçedeki açık veterinerleri haritada canlı görün'),
          style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppLanguage appLang) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: appLang.translateDynamic('İl veya İlçe Ara (Örn: Kadıköy, Çankaya, İzmir)...'),
        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _selectedCity = '');
                },
              )
            : null,
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: AppTheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: AppTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: AppTheme.primary, width: 2),
        ),
      ),
      onChanged: (val) {
        setState(() {
          _selectedCity = val.trim();
        });
      },
      onSubmitted: (val) {
        if (val.trim().isNotEmpty) {
          _openLiveMap(appLang, val.trim());
        }
      },
    );
  }

  Widget _buildCityChips(AppLanguage appLang) {
    return SizedBox(
      height: 38.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _popularCities.length,
        itemBuilder: (context, index) {
          final city = _popularCities[index];
          final isSelected = _selectedCity.toLowerCase() == city.toLowerCase();
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              label: Text(
                city,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.textDark,
                ),
              ),
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(
                  color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                ),
              ),
              onSelected: (_) {
                setState(() {
                  _selectedCity = city;
                  _searchController.text = city;
                });
                _openLiveMap(appLang, city);
              },
            ),
          );
        },
      ),
    );
  }

  String _getCityClinicsTitle(AppLanguage appLang, String city) {
    final lang = appLang.currentLanguage;
    switch (lang) {
      case 'en': return '$city Emergency Veterinarians';
      case 'de': return 'Notfall-Tierärzte in $city';
      case 'fr': return 'Vétérinaires de garde à $city';
      case 'es': return 'Veterinarios de urgencias en $city';
      case 'ru': return 'Дежурные ветеринары в г. $city';
      case 'tr':
      default: return '$city Nöbetçi Veterinerleri';
    }
  }

  String _getCityButtonText(AppLanguage appLang, String city) {
    final lang = appLang.currentLanguage;
    switch (lang) {
      case 'en': return 'Show $city Clinics on Live Map';
      case 'de': return 'Kliniken in $city auf Live-Karte anzeigen';
      case 'fr': return 'Afficher les cliniques de $city sur la carte';
      case 'es': return 'Ver clínicas de $city en el mapa en vivo';
      case 'ru': return 'Показать клиники в $city на карте';
      case 'tr':
      default: return '$city Kliniklerini Canlı Haritada Göster';
    }
  }

  Widget _buildCityResultCard(AppLanguage appLang) {
    final activeCity = _selectedCity.isNotEmpty ? _selectedCity : 'İstanbul';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_city_rounded, color: Color(0xFFE74C3C), size: 22),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCityClinicsTitle(appLang, activeCity),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppTheme.textDark),
                    ),
                    Text(
                      appLang.translateDynamic('Canlı Google Haritalar üzerinde açık klinikler'),
                      style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.near_me_rounded, color: Colors.white, size: 18),
              label: Text(
                _getCityButtonText(appLang, activeCity),
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: () => _openLiveMap(appLang, activeCity),
            ),
          ),
        ],
      ),
    );
  }
}
