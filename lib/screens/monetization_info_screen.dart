import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'become_sitter_screen.dart';

class MonetizationInfoScreen extends StatefulWidget {
  const MonetizationInfoScreen({super.key});

  @override
  State<MonetizationInfoScreen> createState() => _MonetizationInfoScreenState();
}

class _MonetizationInfoScreenState extends State<MonetizationInfoScreen> {
  bool _admobEnabled = true;
  bool _premiumEnabled = false;
  bool _affiliateEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gelir Paneli & Y�netim'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card - Simulated Earnings
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00ACC1), Color(0xFF00838F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00ACC1).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sim�le Edilen Ayl�k Kazan�',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Temmuz 2026',
                          style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '?4,850.50',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  const Divider(color: Colors.white30, height: 1),
                  SizedBox(height: 18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickStat('Toplam �ndirme', '12.4K', FontAwesomeIcons.download),
                      _buildQuickStat('Reklam G�sterimi', '84.2K', FontAwesomeIcons.rectangleAd),
                      _buildQuickStat('Ortakl�k T�klamas�', '1,420', FontAwesomeIcons.arrowPointer),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 28.h),

            // Monetization toggles (Switches)
            Text(
              'Aktif Gelir Modelleri',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 12.h),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('Google AdMob Reklamlar�'),
                      subtitle: const Text('Uygulama i�i banner ve ge�i� reklamlar�.'),
                      activeColor: const Color(0xFFFF8A65),
                      value: _admobEnabled,
                      onChanged: (val) {
                        setState(() {
                          _admobEnabled = val;
                        });
                      },
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    SwitchListTile(
                      title: const Text('Sat�� Ortakl��� (Affiliate Linkleri)'),
                      subtitle: const Text('�nerilen �r�n linklerinden komisyon kazan�n.'),
                      activeColor: const Color(0xFFFF8A65),
                      value: _affiliateEnabled,
                      onChanged: (val) {
                        setState(() {
                          _affiliateEnabled = val;
                        });
                      },
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    SwitchListTile(
                      title: const Text('PatiPremium (�yelik Modeli)'),
                      subtitle: const Text('Reklam kald�rma ve s�n�rs�z mesajla�ma aboneli�i.'),
                      activeColor: const Color(0xFFFF8A65),
                      value: _premiumEnabled,
                      onChanged: (val) {
                        setState(() {
                          _premiumEnabled = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 28.h),

            // How to monetize roadmap / guide
            Text(
              'Nas�l Para Kazanacaks�n�z?',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 12.h),
            _buildGuideStep(
              '1',
              'Google AdMob Kurulumu',
              'Google AdMob hesab� a�arak reklam kimlikleri (Ad Unit ID) edinin. `google_mobile_ads` paketini Flutter projenize ekleyip reklamlar� aktif hale getirin. Tamamen �cretsizdir.',
              FontAwesomeIcons.rectangleAd,
            ),
            _buildGuideStep(
              '2',
              'Sat�� Ortakl��� Linkleri',
              'Amazon Associate, Hepsiburada veya Trendyol Gelir Orta�� olun. Rehber ekran�m�zdaki mama ve ila� �nerilerine kendi ortakl�k linklerinizi yerle�tirin. T�klay�p alan her kullan�c�dan komisyon kazan�n.',
              FontAwesomeIcons.handshake,
            ),
            _buildGuideStep(
              '3',
              'Veteriner ve Pet Shop Sponsorlu�u',
              '�evrenizdeki yerel veteriner klinikleriyle g�r���n. Ayl�k k���k bir �cret kar��l���nda onlar� aramada "Sponsorlu Klinik" olarak �st s�ralarda listeleyebilirsiniz.',
              FontAwesomeIcons.store,
            ),

            SizedBox(height: 30.h),

            // CTA: Sitter Register test
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A65).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFFF8A65).withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    'Bak�c� Bulma Yap�s�n� Test Edin!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: Color(0xFFC75A3C),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Kendinizi bir bak�c� olarak kaydedebilir ve bak�c� arama listesinde nas�l g�r�nd���n�z� test edebilirsiniz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.sp, color: Color(0xFF7F8C8D)),
                  ),
                  SizedBox(height: 14.h),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BecomeSitterScreen(),
                        ),
                      );
                    },
                    child: Text('Bak�c� Kayd� Ekran�na Git'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, dynamic icon) {
    return Column(
      children: [
        FaIcon(icon, color: Colors.white70, size: 18),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildGuideStep(String num, String title, String desc, dynamic icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFF00ACC1).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: FaIcon(icon, color: const Color(0xFF00ACC1), size: 18),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    desc,
                    style: TextStyle(fontSize: 13.sp, color: const Color(0xFF7F8C8D), height: 1.4),
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



