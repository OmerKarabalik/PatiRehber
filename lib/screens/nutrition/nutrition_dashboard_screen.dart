import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/global_state.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_language.dart';
import '../../services/ad_service.dart';

class NutritionDashboardScreen extends StatefulWidget {
  const NutritionDashboardScreen({Key? key}) : super(key: key);

  @override
  State<NutritionDashboardScreen> createState() => _NutritionDashboardScreenState();
}

class _NutritionDashboardScreenState extends State<NutritionDashboardScreen> {
  int _selectedPetIndex = 0;
  String _selectedFoodFilter = 'Tümü';

  List<Map<String, dynamic>> _getFoodsForPetType(String petType) {
    final lower = petType.toLowerCase();
    if (lower.contains('kedi')) {
      return _catFoods;
    } else if (lower.contains('kuş') || lower.contains('kus')) {
      return _birdFoods;
    } else if (lower.contains('balık') || lower.contains('balik')) {
      return _fishFoods;
    } else if (lower.contains('tavşan') || lower.contains('tavsan') || lower.contains('hamster') || lower.contains('kemirgen')) {
      return _smallPetFoods;
    }
    return _dogFoods;
  }

  Widget _buildQuickFeedingGuideCard(String petType, String petName, AppLanguage appLang) {
    final lower = petType.toLowerCase();
    String frequency;
    String portion;
    String water;
    String goldenRule;
    Color themeColor;
    IconData petIcon;

    if (lower.contains('kedi')) {
      themeColor = const Color(0xFFE67E22);
      petIcon = Icons.pets_rounded;
      frequency = appLang.translateDynamic('Günde 2-3 Öğün (Kuru & Yaş)');
      portion = appLang.translateDynamic('Günde ~60-75g Mama');
      water = appLang.translateDynamic('Günde ~200-250 ml Taze Su');
      goldenRule = appLang.translateDynamic('Su kabını mama kabından uzakta tutun. Kediler mamaya yakın sudan hoşlanmaz.');
    } else if (lower.contains('kuş') || lower.contains('kus')) {
      themeColor = const Color(0xFF27AE60);
      petIcon = Icons.flutter_dash_rounded;
      frequency = appLang.translateDynamic('Günde 1-2 Kez Yemlik Kontrolü');
      portion = appLang.translateDynamic('1-2 Tatlı Kaşığı Tohum / Pelet');
      water = appLang.translateDynamic('Her gün yenilenen taze suluk');
      goldenRule = appLang.translateDynamic('Avokado ve elma çekirdeği kuşlar için ölümcüldür! Kafesi hava cereyanından koruyun.');
    } else if (lower.contains('balık') || lower.contains('balik')) {
      themeColor = const Color(0xFF2980B9);
      petIcon = Icons.set_meal_rounded;
      frequency = appLang.translateDynamic('Günde 1 veya 2 Kez');
      portion = appLang.translateDynamic('Gözü kadar / 2 dk bitecek tutam');
      water = appLang.translateDynamic('Haftalık %20 dinlenmiş su değişimi');
      goldenRule = appLang.translateDynamic('Asla fazla yem vermeyin! Yenmeyen yem suyu bozar ve balık ölümlerinin %90\'ının sebebidir.');
    } else if (lower.contains('tavşan') || lower.contains('tavsan') || lower.contains('hamster') || lower.contains('kemirgen')) {
      themeColor = const Color(0xFF8E44AD);
      petIcon = Icons.cruelty_free_rounded;
      frequency = appLang.translateDynamic('Sınırsız Kuru Ot + 1 Öğün Pelet');
      portion = appLang.translateDynamic('Vücudu kadar kuru ot + yeşillik');
      water = appLang.translateDynamic('Ağır kapta veya sulukta taze su');
      goldenRule = appLang.translateDynamic('Diyetin %80\'i kuru ot olmalıdır. Havuç şekerli olduğundan haftada 1-2 ince dilim ödül olmalıdır.');
    } else {
      themeColor = const Color(0xFF2E7D32);
      petIcon = Icons.pets_rounded;
      frequency = appLang.translateDynamic('Günde 2 Öğün (Sabah & Akşam)');
      portion = appLang.translateDynamic('Günde ~350-450g Kuru Mama');
      water = appLang.translateDynamic('Günde ~500-700 ml Taze Su');
      goldenRule = appLang.translateDynamic('Mamadan hemen sonra ağır egzersiz veya koşu yaptırmayın (mide dönmesi riski).');
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: themeColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(petIcon, color: themeColor, size: 20),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$petName • ${appLang.translatePetType(petType)} ${appLang.translateDynamic('Beslenme Rehberi')}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      appLang.translateDynamic('Bu hayvan türü nasıl, ne zaman ve ne kadar beslenmeli?'),
                      style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _buildGuideMiniBadge(
                  icon: Icons.access_time_filled_rounded,
                  title: appLang.translateDynamic('Öğün'),
                  value: frequency,
                  color: const Color(0xFFE67E22),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildGuideMiniBadge(
                  icon: Icons.scale_rounded,
                  title: appLang.translateDynamic('Porsiyon'),
                  value: portion,
                  color: const Color(0xFF27AE60),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildGuideMiniBadge(
                  icon: Icons.water_drop_rounded,
                  title: appLang.translateDynamic('Su'),
                  value: water,
                  color: const Color(0xFF2980B9),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_rounded, color: Color(0xFFF39C12), size: 18),
                SizedBox(width: 8.w),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF795548), height: 1.35),
                      children: [
                        TextSpan(
                          text: '${appLang.translateDynamic('Altın Kural')}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: goldenRule),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideMiniBadge({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              SizedBox(width: 4.w),
              Text(
                title,
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w600, color: AppTheme.textDark),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _catFoods = [
    {
      'name': 'Soğan, Sarımsak & Pırasa',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.dangerous_rounded,
      'color': const Color(0xFFC0392B),
      'shortDesc': 'Alyuvarları parçalayarak ölümcül kansızlığa (anemi) yol açar.',
      'detail': 'Çiğ, pişmiş veya toz halinde olması fark etmeksizin kediler için son derece zehirlidir. Yemek artıklarında asla bulunmamalıdır.',
      'action': 'Şüpheli tüketimde derhal veterinere başvurun.',
    },
    {
      'name': 'Zambak & Çiçek Polenleri',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.block_rounded,
      'color': const Color(0xFFE74C3C),
      'shortDesc': 'Yaprağını ısırmak veya polenini yalamak 24 saatte böbrekleri iflas ettirir.',
      'detail': 'Zambak türleri kediler için en tehlikeli bitkidir. Bir damla zambak suyu dahi akut böbrek yetmezliğine sebep olabilir.',
      'action': 'Evde zambak bulundurmayın, temasta acil kliniğe gidin.',
    },
    {
      'name': 'İnek Sütü & Yağlı Peynir',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.report_problem_rounded,
      'color': const Color(0xFFD35400),
      'shortDesc': 'Kediler sütten kesildikten sonra laktozu sindiremez; şiddetli ishal yapar.',
      'detail': 'Yaygın inanışın aksine inek sütü kedilere fayda değil, şiddetli gaz ve bağırsak bozukluğu verir.',
      'action': 'Yalnızca kedi süt tozu veya az miktarda laktozsuz kefir verilebilir.',
    },
    {
      'name': 'Çikolata & Kahve',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.warning_amber_rounded,
      'color': const Color(0xFF9B59B6),
      'shortDesc': 'Teobromin ve kafein kalp çarpıntısı ve titremelere yol açar.',
      'detail': 'Kedilerin vücudu kafein ve çikolatadaki alkoloidleri parçalayamaz.',
      'action': 'Çikolatayı kapalı dolaplarda saklayın.',
    },
    {
      'name': 'Çiğ Balık & Çiğ Et',
      'category': '⚠️ Dikkatli Verilmeli',
      'icon': Icons.set_meal_rounded,
      'color': const Color(0xFFE67E22),
      'shortDesc': 'Tiyaminaz enzimi B1 vitaminini yok eder, bakteri ve parazit riski taşır.',
      'detail': 'Çiğ balık tiyamin eksikliği yaparak sinirsel kasılmalara neden olabilir.',
      'action': 'Balığı her zaman kılçıksız ve haşlanmış olarak servis edin.',
    },
    {
      'name': 'Haşlanmış Somon & Balık Yağı',
      'category': '✅ Güvenli ve Faydalı',
      'icon': Icons.task_alt_rounded,
      'color': const Color(0xFF27AE60),
      'shortDesc': 'Omega-3 ile parlak tüyler, tüy dökülmesinde azalma ve böbrek koruması sağlar.',
      'detail': 'Haftada 1-2 kez tuzsuz haşlanmış somon veya günde 1 pompa saf balık yağı harika bir destektir.',
      'action': 'Kılçıksız ve baharatsız servis edin.',
    },
    {
      'name': 'Haşlanmış Tavuk Göğsü',
      'category': '✅ Güvenli ve Faydalı',
      'icon': Icons.check_circle_rounded,
      'color': const Color(0xFF2ECC71),
      'shortDesc': 'Yağsız, hafif ve sindirimi en kolay saf hayvansal protein kaynağıdır.',
      'detail': 'Mide hassasiyeti yaşayan kedilerin sindirimini dinlendirmek için idealdir.',
      'action': 'Derisiz ve kemiksiz haşlayarak ılık verin.',
    },
    {
      'name': 'Kedi Çimi',
      'category': '✅ Güvenli ve Faydalı',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFF1ABC9C),
      'shortDesc': 'Yalanırken yutulan tüy yumaklarının dışkıyla kolayca atılmasını sağlar.',
      'detail': 'Doğal lif desteği sunar ve kedinizin midesini rahatlatır.',
      'action': 'Evinizde taze saksıda kedi çimi bulundurun.',
    },
  ];

  final List<Map<String, dynamic>> _birdFoods = [
    {
      'name': 'Avokado',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.dangerous_rounded,
      'color': const Color(0xFFC0392B),
      'shortDesc': 'İçerdiği persin toksini kuşlar için 24 saat içinde ÖLÜMCÜLDÜR!',
      'detail': 'Avokadonun yaprağı, çekirdeği ve meyvesi kuşların kalbinde ve ciğerlerinde sıvı toplanmasına yol açar.',
      'action': 'Kuşunuzun yanına asla avokado yaklaştırmayın.',
    },
    {
      'name': 'Elma Çekirdeği & Kiraz Sapı',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.block_rounded,
      'color': const Color(0xFFE74C3C),
      'shortDesc': 'Siyanür türevi bileşikler içerir, küçük kuş kalbi kaldıramaz.',
      'detail': 'Meyvelerin çekirdekleri kuş metabolizması için son derece zehirlidir.',
      'action': 'Elma verirken çekirdek yuvasını tamamen temizleyin.',
    },
    {
      'name': 'Çikolata & Kafeinli İçecekler',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.warning_amber_rounded,
      'color': const Color(0xFF9B59B6),
      'shortDesc': 'Ani kalp ritim bozukluğu ve ölümcül hiperaktiviteye neden olur.',
      'detail': 'Kuşların çay, kahve veya çikolata tatmasına asla izin vermeyin.',
      'action': 'Masadaki açık fincanlara dikkat edin.',
    },
    {
      'name': 'Tuzlu Cips & Krakerler',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.report_problem_rounded,
      'color': const Color(0xFFD35400),
      'shortDesc': 'Kuş böbrekleri tuzu süzemez; susuzluk krizi ve böbrek iflası yapar.',
      'detail': 'Tuzlu insan atıştırmalıkları kuşlarda ölümcül zehirlenmeye yol açar.',
      'action': 'Yalnızca tuzsuz doğal tohum verin.',
    },
    {
      'name': 'Kalamar Kemiği (Mürekkep Balığı)',
      'category': '✅ Güvenli ve Faydalı',
      'icon': Icons.task_alt_rounded,
      'color': const Color(0xFF27AE60),
      'shortDesc': 'Doğal kalsiyum deposudur, gaganın aşınmasını ve sağlıklı kalmasını sağlar.',
      'detail': 'Kafeste daima asılı bulunmalı, özellikle yumurtlama döneminde kalsiyum ihtiyacını karşılar.',
      'action': 'Kafesin tüneğe yakın kısmına asın.',
    },
    {
      'name': 'Darı & Karışık Tohumlar',
      'category': '✅ Güvenli ve Faydalı',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFF2ECC71),
      'shortDesc': 'Günlük temel enerji, karbonhidrat ve doğal yağ gereksinimini karşılar.',
      'detail': 'Sarı ve kırmızı darı tohumları kuşların en sevdiği ve kolay sindirdiği besindir.',
      'action': 'Her sabah yemlik kabuklarını üfleyerek tazeleyin.',
    },
    {
      'name': 'Taze Marul, Roka & Karahindiba',
      'category': '✅ Güvenli ve Faydalı',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFF1ABC9C),
      'shortDesc': 'A vitamini, demir ve doğal nem desteğiyle canlılık katar.',
      'detail': 'İyi yıkanmış ve kurulanmış yeşillikler bağırsak hareketlerini destekler.',
      'action': 'Haftada 2-3 kez taze yeşil yaprak asın.',
    },
    {
      'name': 'Haşlanmış Yumurta Sarısı',
      'category': '✅ Güvenli ve Faydalı',
      'icon': Icons.check_circle_rounded,
      'color': const Color(0xFF16A085),
      'shortDesc': 'Tüy dökümünde kürk ve tüy yenilenmesi için eşsiz protein desteğidir.',
      'detail': 'Haftada bir çay kaşığı haşlanmış yumurta maması tüyleri parlatır.',
      'action': '2 saat sonra kafesten alın, bozulmasın.',
    },
  ];

  final List<Map<String, dynamic>> _fishFoods = [
    {
      'name': 'Aşırı Yem Verme (En Büyük Tehlike)',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.dangerous_rounded,
      'color': const Color(0xFFC0392B),
      'shortDesc': 'Yenmeyen yemler çürür, amonyak patlaması yapar ve balıkları zehirler!',
      'detail': 'Akvaryumdaki balık ölümlerinin %90\'ı açlıktan değil, aşırı yemleme sonucu suyun bozulmasından kaynaklanır.',
      'action': 'Yalnızca 2 dakikada bitirebilecekleri kadar bir tutam atın.',
    },
    {
      'name': 'Ekmek Kırıntısı & Bisküvi',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.block_rounded,
      'color': const Color(0xFFE74C3C),
      'shortDesc': 'Midede aşırı şişer, sindirimi tıkar ve suyu anında bulandırır.',
      'detail': 'Ekmek mayası ve karbonhidrat balık sindirim sistemini tahrip eder.',
      'action': 'Asla akvaryuma ekmek atmayın.',
    },
    {
      'name': 'Yağlı İnsan Gıdaları',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.report_problem_rounded,
      'color': const Color(0xFFD35400),
      'shortDesc': 'Balık karaciğerinde yağlanmaya ve erken ölüme yol açar.',
      'detail': 'İşlenmiş et, peynir gibi gıdalar suda yağ tabakası oluşturarak oksijeni keser.',
      'action': 'Sadece balıklara özel kaliteli yem kullanın.',
    },
    {
      'name': 'Açıkta Kalmış Bayat Yem',
      'category': '⚠️ Dikkatli Verilmeli',
      'icon': Icons.warning_amber_rounded,
      'color': const Color(0xFFE67E22),
      'shortDesc': 'Açık kalan yemlerde vitaminler uçar, küf ve mantar sporları üreyebilir.',
      'detail': 'Açıldıktan sonra 3 aydan eski yemler balıkların bağışıklığını düşürür.',
      'action': 'Yem kutusunun kapağını daima sıkıca kapatın.',
    },
    {
      'name': 'Kaliteli Pul & Granül Yem',
      'category': '✅ Güvenli ve Faydalı',
      'icon': Icons.task_alt_rounded,
      'color': const Color(0xFF27AE60),
      'shortDesc': 'Dengeli spirulina, karides unu ve vitaminlerle renkleri canlandırır.',
      'detail': 'Yüzeyden beslenen balıklar için pul yem, orta ve dip balıkları için granül yem idealdir.',
      'action': 'Günde 1 veya 2 kez azar azar verin.',
    },
    {
      'name': 'Kurutulmuş Artemia & Su Piresi',
      'category': '✅ Güvenli ve Faydalı',
      'icon': Icons.set_meal_rounded,
      'color': const Color(0xFF2ECC71),
      'shortDesc': 'Doğal protein bombasıdır; bağışıklığı artırır ve üremeyi tetikler.',
      'detail': 'Haftada 2 kez canlı yem alternatifi olarak kurutulmuş artemia veya kan kurdu mükemmeldir.',
      'action': 'Haftalık ödül ve kondisyon desteği olarak verin.',
    },
    {
      'name': 'Haşlanmış Bezelye (Kabuksuz)',
      'category': '✅ Güvenli ve Faydalı',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFF1ABC9C),
      'shortDesc': 'Hava kesesi problemini ve kabızlığı doğal yolla çözer.',
      'detail': 'Özellikle Japon balıklarında ters dönme ve kabızlığa karşı kabuğu soyulup ezilmiş haşlanmış bezelye şifadır.',
      'action': 'Haftada 1 gün kabuğu soyulup hafifçe ezilerek verilir.',
    },
  ];

  final List<Map<String, dynamic>> _smallPetFoods = [
    {
      'name': 'Çiğ Patates & Patates Yaprağı',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.dangerous_rounded,
      'color': const Color(0xFFC0392B),
      'shortDesc': 'Solanin toksini içerir, tavşan ve hamsterlar için son derece zehirlidir.',
      'detail': 'Çiğ patates ve filizleri sindirimi durdurarak zehirlenmeye sebep olur.',
      'action': 'Asla patates veya kabuğunu vermeyin.',
    },
    {
      'name': 'Çikolata & Şekerli Bisküviler',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.block_rounded,
      'color': const Color(0xFFE74C3C),
      'shortDesc': 'Hassas bağırsak florasını çökerterek ölümcül gaz krizine yol açar.',
      'detail': 'Tavşanların şekeri sindirme kapasitesi düşüktür; gaz bağırsak tıkanması (stasis) yapar.',
      'action': 'Şekerli insan gıdalarından uzak tutun.',
    },
    {
      'name': 'Soğan, Sarımsak & Avokado',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.warning_amber_rounded,
      'color': const Color(0xFFD35400),
      'shortDesc': 'Alyuvarları bozar ve mide kanamasına sebep olabilir.',
      'detail': 'Keskin sülfür ve persin içeren sebzeler küçük dostlarımız için tehlikelidir.',
      'action': 'Yalnızca güvenli taze yeşillikler verin.',
    },
    {
      'name': 'Aşırı Havuç & Tatlı Meyveler',
      'category': '⚠️ Dikkatli Verilmeli',
      'icon': Icons.report_problem_rounded,
      'color': const Color(0xFFE67E22),
      'shortDesc': 'Havuç ana yemek değildir! Yüksek şeker içerdiğinden haftada 1-2 dilim verilmelidir.',
      'detail': 'Çizgi filmlerin aksine havuç aşırı şekerlidir. Fazlası diş çürümesi ve obezite yapar.',
      'action': 'Yalnızca haftada 1 kez ödül olarak ince dilim verin.',
    },
    {
      'name': '%80 Kuru Çayır Otu (Timothy)',
      'category': '✅ Güvenli ve Faydalı',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFF27AE60),
      'shortDesc': 'Tavşanın ana yaşam kaynağıdır; sınırsız kuru ot kafeste daima bulunmalıdır.',
      'detail': 'Sürekli uzayan dişleri doğal olarak törpüler ve bağırsakların çalışmasını sağlar.',
      'action': 'Günde 24 saat taze kuru ot erişimi sağlayın.',
    },
    {
      'name': 'Taze Nane, Fesleğen & Dereotu',
      'category': '✅ Güvenli ve Faydalı',
      'icon': Icons.task_alt_rounded,
      'color': const Color(0xFF2ECC71),
      'shortDesc': 'Mideyi rahatlatır, gaz oluşumunu önler ve bağışıklığı güçlendirir.',
      'detail': 'İyi yıkanmış ve kurulanmış aromatik taze otlar tavşanların favori sağlıklı yeşilliğidir.',
      'action': 'Günde bir avuç taze yeşillik tabağı sunun.',
    },
    {
      'name': 'Yeşil Biber & Salatalık',
      'category': '✅ Güvenli ve Faydalı',
      'icon': Icons.check_circle_rounded,
      'color': const Color(0xFF1ABC9C),
      'shortDesc': 'C vitamini deposudur, sulu yapısıyla yaz aylarında serinletir.',
      'detail': 'Çekirdeksiz taze yeşil biber kürk sağlığını ve bağışıklığı parlatır.',
      'action': 'Küçük küpler halinde servis edin.',
    },
  ];

  final List<Map<String, dynamic>> _dogFoods = [
    {
      'name': 'Çikolata & Kakao',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.block_rounded,
      'color': const Color(0xFFE74C3C),
      'shortDesc': 'Teobromin maddesi kalp ve sinir sistemine şiddetli zarar verir, ölümcül olabilir.',
      'detail': 'Kakao çekirdeklerindeki teobromin ve kafein, köpeklerin metabolizması tarafından sindirilemez. Kalp atışında şiddetli artış, titreme, nöbetler ve kalp krizine yol açabilir. Bitter çikolata en tehlikelisidir.',
      'action': 'Acil olarak veterinere başvurun ve tüketilen miktarı bildirin.',
    },
    {
      'name': 'Soğan & Sarımsak',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.dangerous_rounded,
      'color': const Color(0xFFC0392B),
      'shortDesc': 'Alyuvarları tahrip ederek hemolitik anemiye (kansızlığa) neden olur.',
      'detail': 'Çiğ, pişmiş veya toz halinde olması fark etmeksizin sülfür bileşikleri içerir. Kırmızı kan hücrelerini parçalar ve idrarda koyulaşma, halsizlik, soluk diş etleri ile kendini belli eder.',
      'action': 'Yemek artıklarında soğan veya sarımsak tozu bulunmamasına dikkat edin.',
    },
    {
      'name': 'Üzüm & Kuru Üzüm',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.report_problem_rounded,
      'color': const Color(0xFF9B59B6),
      'shortDesc': 'Küçük miktarları bile ani akut böbrek yetmezliğine yol açabilir.',
      'detail': 'Hangi toksinin buna yol açtığı tam bilinmese de 1-2 adet kuru üzüm bile özellikle küçük ırklarda birkaç saat içinde kusma ve 24-48 saat içinde böbrek iflasına neden olabilir.',
      'action': 'Kusma belirtisi varsa derhal sıvı tedavisi için acil kliniğe gidin.',
    },
    {
      'name': 'Ksilitol (Tatlandırıcı)',
      'category': '🚫 Kesinlikle Yasak',
      'icon': Icons.warning_amber_rounded,
      'color': const Color(0xFFD35400),
      'shortDesc': 'Ani insülin patlaması, hipoglisemi ve karaciğer nekrozuna neden olur.',
      'detail': 'Şekersiz sakızlar, bazı fıstık ezmeleri ve diyet ürünlerde bulunur. Yutulduktan sonra 30 dakika içinde kan şekerini sıfırlayarak komaya sokabilir.',
      'action': 'Fıstık ezmesi vermeden önce etiketinde Ksilitol (Xylitol) olmadığını doğrulayın.',
    },
    {
      'name': 'Pişmiş Kemikler',
      'category': '⚠️ Dikkatli Verilmeli',
      'icon': Icons.health_and_safety_rounded,
      'color': const Color(0xFFE67E22),
      'shortDesc': 'Pişince sertleşip kıymıklanır; boğazı, mideyi veya bağırsağı yırtabilir.',
      'detail': 'Tavuk ve kuzu kemikleri fırınlanıp kaynatıldığında esnekliğini kaybeder. Sivri uçlar yemek borusunu delip acil cerrahi müdahale gerektirebilir.',
      'action': 'Yalnızca veteriner onaylı özel preslenmiş diş kemiklerini tercih edin.',
    },
    {
      'name': 'Haşlanmış Tavuk Göğsü',
      'category': '✅ Güvenli ve Faydalı',
      'icon': Icons.task_alt_rounded,
      'color': const Color(0xFF27AE60),
      'shortDesc': 'Yağsız, hafif ve sindirimi son derece kolay en kaliteli saf protein kaynağıdır.',
      'detail': 'Baharat ve tuz eklenmeden sadece suda haşlanan tavuk göğsü, sindirim hassasiyeti ve ishal dönemlerinde bağırsakları dinlendirir.',
      'action': 'Kemiksiz ve derisiz şekilde ılık olarak servis edin.',
    },
    {
      'name': 'Havuç',
      'category': '✅ Güvenli ve Faydalı',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFF16A085),
      'shortDesc': 'Düşük kalorili, beta-karoten zengini ve çiğnendiğinde diş plağını temizler.',
      'detail': 'Çiğ verildiğinde dişlerdeki plakları mekanik olarak fırçalar, haşlandığında ise mideye şifa verir. Kilo kontrolündeki köpekler için harika bir atıştırmalıktır.',
      'action': 'Boğulma riskine karşı köpeğinizin boyutuna uygun dilimleyin.',
    },
    {
      'name': 'Balkabağı Püresi',
      'category': '✅ Güvenli ve Faydalı',
      'icon': Icons.check_circle_rounded,
      'color': const Color(0xFF2ECC71),
      'shortDesc': 'Zengin çözünür lif içeriğiyle hem ishali hem kabızlığı mükemmel dengeler.',
      'detail': 'Bağırsaktaki fazla sıvıyı emerek dışkıyı kıvamına getirir. İçerdiği A vitamini ve antioksidanlar bağışıklık sistemini destekler.',
      'action': 'Şekersiz ve katkısız püre halinde mamaya 1 yemek kaşığı karıştırılabilir.',
    },
    {
      'name': 'Somon & Balık Yağı',
      'category': '✅ Güvenli ve Faydalı',
      'icon': Icons.set_meal_rounded,
      'color': const Color(0xFF1ABC9C),
      'shortDesc': 'Omega-3 ve Omega-6 ile parlak tüy yapısı, eklem esnekliği ve kalp sağlığı sunar.',
      'detail': 'Mevsimsel tüy dökülmesini belirgin derecede azaltır, cilt kaşıntılarını dindirir ve yaşlı dostlarımızın eklem kireçlenmesine karşı kıkırdağı korur.',
      'action': 'Kılçıksız pişmiş somon veya günde 1 pompa saf somon balık yağı ekleyin.',
    },
  ];

  Map<String, dynamic> _getPetPlan(String petName, String petType) {
    if (!GlobalState.nutritionPlans.containsKey(petName)) {
      GlobalState.nutritionPlans[petName] = {
        'totalAmount': petType == 'Kedi' ? '65 g' : (petType == 'Köpek' ? '380 g' : '20 g'),
        'meals': 3,
        'foodType': petType == 'Kedi' ? 'Kısırlaştırılmış Somonlu Kuru Mama' : (petType == 'Köpek' ? 'Tahılsız Kuzu Etli Kuru Mama' : 'Karışık Tohum Yemi'),
        'brand': 'Royal Canin / Acana',
        'morningTime': '08:00',
        'morningAmount': petType == 'Kedi' ? '25 g' : '190 g',
        'eveningTime': '19:30',
        'eveningAmount': petType == 'Kedi' ? '40 g' : '190 g',
        'notes': 'Taze su kabı günde iki kez yıkanıp yenilenmeli.',
        'targetCalories': petType == 'Kedi' ? 240 : (petType == 'Köpek' ? 580 : 35),
        'targetWaterMl': petType == 'Kedi' ? 250 : (petType == 'Köpek' ? 650 : 40),
        'currentWaterMl': petType == 'Kedi' ? 150 : (petType == 'Köpek' ? 400 : 25),
        'dailyMeals': [
          {
            'id': 1,
            'name': 'Sabah Kahvaltısı',
            'type': 'Kuru Mama',
            'time': '08:00',
            'amount': petType == 'Kedi' ? '25 g' : '190 g',
            'cal': petType == 'Kedi' ? 95 : 280,
            'completed': true,
          },
          {
            'id': 2,
            'name': 'Öğle Atıştırmalığı',
            'type': 'Ödül & Çiğneme',
            'time': '13:00',
            'amount': '15 g',
            'cal': 35,
            'completed': false,
          },
          {
            'id': 3,
            'name': 'Akşam Yemeği',
            'type': 'Yaş Mama',
            'time': '19:30',
            'amount': petType == 'Kedi' ? '40 g' : '190 g',
            'cal': petType == 'Kedi' ? 110 : 265,
            'completed': false,
          },
        ]
      };
    }

    var plan = GlobalState.nutritionPlans[petName]!;
    if (plan['dailyMeals'] == null) {
      plan['targetCalories'] = petType == 'Kedi' ? 240 : (petType == 'Köpek' ? 580 : 35);
      plan['targetWaterMl'] = petType == 'Kedi' ? 250 : (petType == 'Köpek' ? 650 : 40);
      plan['currentWaterMl'] = petType == 'Kedi' ? 150 : (petType == 'Köpek' ? 400 : 25);
      plan['dailyMeals'] = [
        {
          'id': 1,
          'name': 'Sabah Kahvaltısı',
          'type': 'Kuru Mama',
          'time': plan['morningTime'] ?? '08:00',
          'amount': plan['morningAmount'] ?? '60 g',
          'cal': 160,
          'completed': true,
        },
        {
          'id': 2,
          'name': 'Öğle Atıştırmalığı',
          'type': 'Ödül & Çiğneme',
          'time': '13:00',
          'amount': '15 g',
          'cal': 35,
          'completed': false,
        },
        {
          'id': 3,
          'name': 'Akşam Yemeği',
          'type': 'Yaş Mama',
          'time': plan['eveningTime'] ?? '19:30',
          'amount': plan['eveningAmount'] ?? '60 g',
          'cal': 175,
          'completed': false,
        },
      ];
    }
    return plan;
  }

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
          },
        );
      },
    );
  }

  void _showAddOrEditMealModal({Map<String, dynamic>? mealToEdit}) {
    final appLang = AppLanguage.of(context);
    final pet = GlobalState.pets[_selectedPetIndex];
    final petName = pet['name'];
    final plan = _getPetPlan(petName, pet['type'] ?? 'Köpek');
    final List meals = plan['dailyMeals'] as List;

    final nameController = TextEditingController(text: mealToEdit != null ? mealToEdit['name'] : 'Sabah Kahvaltısı');
    final amountController = TextEditingController(text: mealToEdit != null ? mealToEdit['amount'] : '50 g');
    final calController = TextEditingController(text: mealToEdit != null ? mealToEdit['cal'].toString() : '120');
    final timeController = TextEditingController(text: mealToEdit != null ? mealToEdit['time'] : '08:30');
    String selectedType = mealToEdit != null ? mealToEdit['type'] : 'Kuru Mama';

    final foodTypes = ['Kuru Mama', 'Yaş Mama', 'Ödül & Çiğneme', 'Vitamin & Takviye'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mealToEdit != null ? appLang.translateDynamic('Öğün Ekle / Düzenle') : appLang.translateDynamic('Öğün Ekle'),
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      if (mealToEdit != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          onPressed: () {
                            setState(() {
                              meals.removeWhere((m) => m['id'] == mealToEdit['id']);
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(appLang.translateDynamic('Öğün silindi.')), backgroundColor: Colors.redAccent),
                            );
                          },
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: appLang.translateDynamic('Öğün Adı'),
                      prefixIcon: const Icon(Icons.label_rounded, color: Color(0xFFF39C12)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: foodTypes.map((t) => DropdownMenuItem(value: t, child: Text(appLang.translateDynamic(t)))).toList(),
                    onChanged: (val) => setModalState(() => selectedType = val!),
                    decoration: InputDecoration(
                      labelText: appLang.translateDynamic('Mama / Yiyecek'),
                      prefixIcon: const Icon(Icons.restaurant_rounded, color: Color(0xFFF39C12)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: amountController,
                          decoration: InputDecoration(
                            labelText: appLang.translateDynamic('Miktar (Gram)'),
                            prefixIcon: const Icon(Icons.scale_rounded, color: Color(0xFFF39C12)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: TextField(
                          controller: calController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: appLang.translateDynamic('Kalori (kcal)'),
                            prefixIcon: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFE67E22)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: timeController,
                    decoration: InputDecoration(
                      labelText: appLang.translateDynamic('Saat'),
                      prefixIcon: const Icon(Icons.access_time_rounded, color: Color(0xFFF39C12)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        final cal = int.tryParse(calController.text.trim()) ?? 100;
                        setState(() {
                          if (mealToEdit != null) {
                            mealToEdit['name'] = nameController.text.trim();
                            mealToEdit['type'] = selectedType;
                            mealToEdit['amount'] = amountController.text.trim();
                            mealToEdit['cal'] = cal;
                            mealToEdit['time'] = timeController.text.trim();
                          } else {
                            meals.add({
                              'id': DateTime.now().millisecondsSinceEpoch,
                              'name': nameController.text.trim(),
                              'type': selectedType,
                              'amount': amountController.text.trim(),
                              'cal': cal,
                              'time': timeController.text.trim(),
                              'completed': false,
                            });
                          }
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF39C12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: Text(
                        appLang.translate('save'),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFoodDetailModal(Map<String, dynamic> food) {
    final appLang = AppLanguage.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: (food['color'] as Color).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(food['icon'] as IconData, color: food['color'] as Color, size: 28),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appLang.translateDynamic(food['name']),
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        appLang.translateDynamic(food['category']),
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: food['color'] as Color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Text(
              food['category'].toString().contains('Yasak')
                  ? appLang.translateDynamic('Neden Zararlı?')
                  : appLang.translateDynamic('Faydaları'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppTheme.textDark),
            ),
            SizedBox(height: 6.h),
            Text(
              appLang.translateDynamic(food['detail']),
              style: TextStyle(fontSize: 13.sp, color: AppTheme.textLight, height: 1.45),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: (food['color'] as Color).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: (food['color'] as Color).withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.tips_and_updates_rounded, color: food['color'] as Color, size: 20),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      appLang.translateDynamic(food['action']),
                      style: TextStyle(fontSize: 12.5.sp, color: AppTheme.textDark, height: 1.35, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: food['color'] as Color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: Text(
                  appLang.translateDynamic('Anladım, Harika!'),
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLang = AppLanguage.of(context);

    if (GlobalState.pets.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            appLang.translate('nutrition'),
            style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w900, fontSize: 18.sp),
          ),
          centerTitle: true,
        ),
        body: _buildEmptyState(),
      );
    }

    if (_selectedPetIndex >= GlobalState.pets.length) {
      _selectedPetIndex = 0;
    }

    final pet = GlobalState.pets[_selectedPetIndex];
    final petName = pet['name'];
    final petType = pet['type'] ?? 'Köpek';
    final plan = _getPetPlan(petName, petType);

    final meals = (plan['dailyMeals'] as List?) ?? [];
    final consumedCal = meals.where((m) => m['completed'] == true).fold<int>(0, (sum, m) => sum + ((m['cal'] as int?) ?? 0));
    final targetCal = (plan['targetCalories'] as int?) ?? 450;
    final calProgress = targetCal > 0 ? (consumedCal / targetCal).clamp(0.0, 1.0) : 0.0;

    final currentWater = (plan['currentWaterMl'] as int?) ?? 200;
    final targetWater = (plan['targetWaterMl'] as int?) ?? 350;
    final waterProgress = targetWater > 0 ? (currentWater / targetWater).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 20.h),
              _buildTitleCard(),
              SizedBox(height: 16.h),
              _buildPetSelector(),
              SizedBox(height: 16.h),
              _buildQuickFeedingGuideCard(petType, petName, appLang),
              SizedBox(height: 20.h),
              _buildDailyCalorieRingCard(consumedCal, targetCal, calProgress),
              SizedBox(height: 16.h),
              _buildHydrationTrackerCard(currentWater, targetWater, waterProgress, plan),
              SizedBox(height: 20.h),
              _buildDailyRoutineSection(meals),
              SizedBox(height: 20.h),
              _buildNutrientBreakdownCard(),
              SizedBox(height: 20.h),
              _buildToxicAndSafeFoodsSection(petType),
              SizedBox(height: 20.h),
              _buildRecommendationsSection(petType),
              SizedBox(height: 20.h),
              const PatiBannerAdWidget(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final appLang = AppLanguage.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90.r,
              height: 90.r,
              decoration: BoxDecoration(
                color: const Color(0xFFF39C12).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restaurant_rounded, color: Color(0xFFF39C12), size: 46),
            ),
            SizedBox(height: 20.h),
            Text(
              appLang.translateDynamic('Henüz Kayıtlı Bir Dostun Yok'),
              style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              appLang.translateDynamic('Köpeğin, kedin veya diğer dostlarının günlük kalori, su, mama ve beslenme rutinini takip etmek için hemen başla.'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: AppTheme.textLight, height: 1.4),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed: _showAddPetModal,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  appLang.translateDynamic('🐾 İlk Evcil Dostumu Ekle'),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF39C12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await GlobalState.loadSampleDemoData();
                  setState(() {
                    _selectedPetIndex = 0;
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(appLang.translateDynamic('Örnek evcil dostlar (Max, Luna, Maviş) yüklendi!')),
                        backgroundColor: const Color(0xFFF39C12),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFF39C12), size: 18),
                label: Text(
                  appLang.translateDynamic('💡 Örnek Demo Verilerini Yükle'),
                  style: TextStyle(color: const Color(0xFFF39C12), fontSize: 13.sp, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFFF39C12).withValues(alpha: 0.35)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final appLang = AppLanguage.of(context);
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 20),
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appLang.translate('app_title'), style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
              Text(appLang.translate('nutrition_sub'), style: TextStyle(fontSize: 11.5.sp, color: AppTheme.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        if (GlobalState.pets.isNotEmpty)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textDark),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            onSelected: (val) {
              if (val == 'clear_all') {
                _confirmClearAllData();
              } else if (val == 'delete_current') {
                if (_selectedPetIndex < GlobalState.pets.length) {
                  final currentPet = GlobalState.pets[_selectedPetIndex];
                  _confirmDeletePet(_selectedPetIndex, currentPet['name']);
                }
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'delete_current',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                    SizedBox(width: 8.w),
                    Text(appLang.translateDynamic('Bu Hayvanı Sil'), style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    const Icon(Icons.cleaning_services_rounded, color: Colors.red, size: 20),
                    SizedBox(width: 8.w),
                    Text(appLang.translateDynamic('Tüm Demo Verileri Sil'), style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _confirmDeletePet(int index, String petName) {
    final appLang = AppLanguage.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            const Icon(Icons.delete_forever_rounded, color: Colors.red),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                '$petName ${appLang.translateDynamic('silinsin mi?')}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ),
          ],
        ),
        content: Text(
          appLang.translateDynamic('Bu evcil dostu ve tüm beslenme/sağlık verilerini silmek istediğinize emin misiniz?'),
          style: TextStyle(fontSize: 13.sp, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(appLang.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                GlobalState.removePet(index);
                if (_selectedPetIndex >= GlobalState.pets.length) {
                  _selectedPetIndex = GlobalState.pets.isEmpty ? 0 : GlobalState.pets.length - 1;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red.shade700,
                  content: Text('$petName ${appLang.translateDynamic('profili silindi.')}'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(appLang.translate('delete'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmClearAllData() {
    final appLang = AppLanguage.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            const Icon(Icons.cleaning_services_rounded, color: Colors.red),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                appLang.translateDynamic('Tüm Verileri Temizle'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ),
          ],
        ),
        content: Text(
          appLang.translateDynamic('Tüm evcil hayvan profilleri ve kayıtları sıfırlanacaktır. Uygulamayı sıfır kurulum durumuna getirmek istediğinize emin misiniz?'),
          style: TextStyle(fontSize: 13.sp, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(appLang.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await GlobalState.clearAllUserPets();
              setState(() {
                _selectedPetIndex = 0;
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red.shade700,
                    content: Text(appLang.translateDynamic('Tüm test verileri temizlendi. Uygulama sıfırlandı.')),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(appLang.translate('delete'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    final appLang = AppLanguage.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(color: const Color(0xFFF39C12).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), shape: BoxShape.circle),
            child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 30),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appLang.translate('nutrition'), style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: Colors.white)),
                SizedBox(height: 3.h),
                Text(
                  appLang.translateDynamic('Günün Beslenme Rutini'),
                  style: TextStyle(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPetSelector() {
    return SizedBox(
      height: 64.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: GlobalState.pets.length + 1,
        itemBuilder: (context, index) {
          if (index == GlobalState.pets.length) {
            return GestureDetector(
              onTap: _showAddPetModal,
              child: Container(
                margin: EdgeInsets.only(left: 4.w, right: 12.w),
                width: 50.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: const Icon(Icons.add, color: Color(0xFFF39C12), size: 26),
              ),
            );
          }
          final pet = GlobalState.pets[index];
          final isSelected = index == _selectedPetIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedPetIndex = index),
            onLongPress: () => _confirmDeletePet(index, pet['name']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(right: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF39C12) : Colors.white,
                borderRadius: BorderRadius.circular(26.r),
                boxShadow: isSelected
                    ? [BoxShadow(color: const Color(0xFFF39C12).withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))]
                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundImage: GlobalState.getPetImage(pet['image'], pet['type'] ?? 'Köpek'),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet['name'],
                        style: TextStyle(color: isSelected ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 13.sp),
                      ),
                      Text(
                        AppLanguage.of(context).translatePetType(pet['type']),
                        style: TextStyle(color: isSelected ? Colors.white70 : AppTheme.textLight, fontSize: 10.5.sp),
                      ),
                    ],
                  ),
                  if (isSelected) ...[
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => _confirmDeletePet(index, pet['name']),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyCalorieRingCard(int consumedCal, int targetCal, double progress) {
    final appLang = AppLanguage.of(context);
    final remaining = (targetCal - consumedCal).clamp(0, 9999);

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.035), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 84.r,
            height: 84.r,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8.w,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF39C12)),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, color: AppTheme.textDark),
                      ),
                      Text(
                        'kcal',
                        style: TextStyle(fontSize: 10.sp, color: AppTheme.textLight, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appLang.translateDynamic('Bugün Tüketilen Kalori'),
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$consumedCal',
                      style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: const Color(0xFFF39C12)),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '/ $targetCal kcal',
                      style: TextStyle(fontSize: 13.sp, color: AppTheme.textDark, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${appLang.translateDynamic('Kalan')}: $remaining kcal',
                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF27AE60), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationTrackerCard(int currentWater, int targetWater, double progress, Map<String, dynamic> plan) {
    final appLang = AppLanguage.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.035), blurRadius: 10, offset: const Offset(0, 3)),
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
                  color: const Color(0xFF2980B9).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.water_drop_rounded, color: Color(0xFF2980B9), size: 20),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLang.translateDynamic('Günlük Su Tüketimi'),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppTheme.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${appLang.translateDynamic('Günlük İdeal Su İhtiyacı')} (${appLang.translateDynamic('kg başına ~50-60 ml')})',
                      style: TextStyle(fontSize: 10.sp, color: AppTheme.textLight),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '$currentWater / $targetWater ml',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5.sp, color: const Color(0xFF2980B9)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2980B9)),
            ),
          ),
          SizedBox(height: 14.h),
          Builder(
            builder: (context) {
              final int step1 = targetWater <= 60 ? 10 : (targetWater <= 200 ? 25 : 50);
              final int step2 = targetWater <= 60 ? 20 : (targetWater <= 200 ? 50 : 100);
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          plan['currentWaterMl'] = (currentWater + step1).clamp(0, 3000);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(appLang.translateDynamic('Su tüketimi eklendi!')), duration: const Duration(seconds: 1)),
                        );
                      },
                      icon: const Icon(Icons.add, size: 14, color: Color(0xFF2980B9)),
                      label: Text('+$step1 ml', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2980B9), fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        side: BorderSide(color: const Color(0xFF2980B9).withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          plan['currentWaterMl'] = (currentWater + step2).clamp(0, 3000);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(appLang.translateDynamic('Su tüketimi eklendi!')), duration: const Duration(seconds: 1)),
                        );
                      },
                      icon: const Icon(Icons.add, size: 14, color: Color(0xFF2980B9)),
                      label: Text('+$step2 ml', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2980B9), fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        side: BorderSide(color: const Color(0xFF2980B9).withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Tooltip(
                    message: appLang.translateDynamic('Sıfırla'),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          plan['currentWaterMl'] = 0;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(appLang.translateDynamic('Su Tüketimi Sıfırlandı 💧')), duration: const Duration(seconds: 1)),
                        );
                      },
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.restart_alt_rounded, color: Colors.redAccent, size: 18),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRoutineSection(List meals) {
    final appLang = AppLanguage.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule_rounded, color: AppTheme.textDark, size: 20),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                appLang.translateDynamic('Günün Beslenme Rutini'),
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, color: AppTheme.textDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            InkWell(
              onTap: () => _showAddOrEditMealModal(),
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF39C12).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 14, color: Color(0xFFF39C12)),
                    SizedBox(width: 4.w),
                    Text(
                      appLang.translateDynamic('Öğün Ekle'),
                      style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFFF39C12)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...meals.map((meal) {
          final isCompleted = meal['completed'] == true;
          return Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isCompleted ? const Color(0xFF27AE60).withValues(alpha: 0.3) : Colors.grey.shade100,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.025), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      meal['completed'] = !isCompleted;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isCompleted
                            ? appLang.translateDynamic('Öğün durumu güncellendi.')
                            : appLang.translateDynamic('Öğün tamamlandı olarak işaretlendi!')),
                        duration: const Duration(milliseconds: 900),
                        backgroundColor: const Color(0xFF27AE60),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20.r),
                  child: Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: isCompleted ? const Color(0xFF27AE60) : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                      color: isCompleted ? Colors.white : Colors.grey.shade400,
                      size: 22,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: InkWell(
                    onTap: () => _showAddOrEditMealModal(mealToEdit: meal),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                appLang.translateDynamic(meal['name'] ?? ''),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                  color: isCompleted ? Colors.grey.shade700 : AppTheme.textDark,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF39C12).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                appLang.translateDynamic(meal['type'] ?? ''),
                                style: TextStyle(fontSize: 9.5.sp, color: const Color(0xFFE67E22), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 12, color: AppTheme.textLight),
                            SizedBox(width: 4.w),
                            Text(
                              meal['time'] ?? '',
                              style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(width: 10.w),
                            Text('•', style: TextStyle(color: Colors.grey.shade400)),
                            SizedBox(width: 10.w),
                            Text(
                              meal['amount'] ?? '',
                              style: TextStyle(fontSize: 11.5.sp, color: AppTheme.textDark, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '(${meal['cal']} kcal)',
                              style: TextStyle(fontSize: 11.sp, color: const Color(0xFFE67E22), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded, color: Colors.grey),
                  onPressed: () => _showAddOrEditMealModal(mealToEdit: meal),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNutrientBreakdownCard() {
    final appLang = AppLanguage.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.035), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_rounded, color: Color(0xFF8E44AD), size: 20),
              SizedBox(width: 8.w),
              Text(
                appLang.translateDynamic('Besin Değerleri Dengesi'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppTheme.textDark),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              _buildMacroItem(appLang.translateDynamic('Protein'), '32%', const Color(0xFFE74C3C)),
              _buildMacroItem(appLang.translateDynamic('Sağlıklı Yağlar'), '18%', const Color(0xFFF39C12)),
              _buildMacroItem(appLang.translateDynamic('Sindirim Lifi'), '6%', const Color(0xFF27AE60)),
              _buildMacroItem(appLang.translateDynamic('Nem & Sıvı'), '44%', const Color(0xFF2980B9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 6.h,
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3.r)),
          ),
          SizedBox(height: 6.h),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.sp, color: AppTheme.textDark)),
          Text(label, style: TextStyle(fontSize: 10.sp, color: AppTheme.textLight), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  String _getBadgeText(String category, AppLanguage appLang) {
    if (category.contains('Yasak')) return appLang.translateDynamic('Yasak');
    if (category.contains('Dikkatli')) return appLang.translateDynamic('Dikkat');
    return appLang.translateDynamic('Güvenli');
  }

  Widget _buildToxicAndSafeFoodsSection(String petType) {
    final appLang = AppLanguage.of(context);
    final filters = ['Tümü', '🚫 Kesinlikle Yasak', '⚠️ Dikkatli Verilmeli', '✅ Güvenli ve Faydalı'];

    final foods = _getFoodsForPetType(petType);
    final filteredList = foods.where((food) {
      if (_selectedFoodFilter == 'Tümü') return true;
      return food['category'] == _selectedFoodFilter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.health_and_safety_rounded, color: Color(0xFFC0392B), size: 20),
                SizedBox(width: 8.w),
                Text(
                  appLang.translateDynamic('Zehirli ve Güvenli Gıdalar'),
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17.sp, color: AppTheme.textDark),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: filters.map((f) {
              final isSel = _selectedFoodFilter == f;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ChoiceChip(
                  label: Text(
                    appLang.translateDynamic(f),
                    style: TextStyle(
                      color: isSel ? Colors.white : AppTheme.textDark,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                      fontSize: 11.5.sp,
                    ),
                  ),
                  selected: isSel,
                  selectedColor: const Color(0xFFC0392B),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    side: BorderSide(color: isSel ? const Color(0xFFC0392B) : Colors.grey.shade200),
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedFoodFilter = f);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 156.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: filteredList.length,
            itemBuilder: (context, idx) {
              final food = filteredList[idx];
              final color = food['color'] as Color;
              return InkWell(
                onTap: () => _showFoodDetailModal(food),
                borderRadius: BorderRadius.circular(18.r),
                child: Container(
                  width: 190.w,
                  margin: EdgeInsets.only(right: 12.w),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(7.w),
                            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                            child: Icon(food['icon'] as IconData, color: color, size: 20),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
                            child: Text(
                              _getBadgeText(food['category'].toString(), appLang),
                              style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: color),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        appLang.translateDynamic(food['name']),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: AppTheme.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Expanded(
                        child: Text(
                          appLang.translateDynamic(food['shortDesc']),
                          style: TextStyle(fontSize: 10.5.sp, color: AppTheme.textLight, height: 1.3),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

    List<Map<String, dynamic>> _getVeterinaryRecommendations(String petType) {
    final lower = petType.toLowerCase();

    if (lower.contains('kedi')) {
      return [
        {
          'title': 'Zorunlu Etobur & Taurin Önemi',
          'subtitle': 'Kediler vegan beslenemez! Körlük ve kalp yetmezliğini önleme.',
          'category': 'Temel Biyoloji',
          'badge': 'HAYATİ ÖNEM',
          'badgeColor': const Color(0xFFC0392B),
          'icon': Icons.favorite_rounded,
          'iconColor': const Color(0xFFE74C3C),
          'image': 'assets/images/nutrition_food.jpg',
          'fullDescription':
              'Kediler biyolojik olarak "zorunlu etoburdur" (obligate carnivore). Vücutları taurin, araşidonik asit ve A vitaminini bitkisel kaynaklardan üretemez. Bu amino asit ve vitaminleri doğrudan hayvansal dokulardan almak zorundadırlar.\n\nYetersiz taurin alımı geri döndürülemez retina dejenerasyonuna (körlük) ve dilate kardiyomiyopatiye (ölümcül kalp yetmezliği) yol açar. Bu sebeple kedilere asla köpek maması veya vegan diyet verilmemelidir.',
          'vetQuote':
              'Kaliteli kedi mamasında ilk içerik mutlaka gerçek et olmalıdır. Tahıl oranı yüksek mamalar kedilerde diyabet ve obezite riskini katlar.',
          'keyPoints': [
            'Taurin desteği kalp kası ve göz retinası için vazgeçilmezdir.',
            'Asla köpek maması veya ev yemekleri ana öğün yapılmamalıdır.',
            'Kuru mama alırken protein oranının en az %30-34 olmasına dikkat edin.',
          ],
        },
        {
          'title': 'Böbrek Taşı & Yaş Mama Stratejisi',
          'subtitle': 'Susuzluğu az hisseden kedilerde böbrek koruma formülü.',
          'category': 'Böbrek Sağlığı',
          'badge': 'KLİNİK TAVSİYE',
          'badgeColor': const Color(0xFF2980B9),
          'icon': Icons.water_drop_rounded,
          'iconColor': const Color(0xFF2980B9),
          'image': 'assets/images/nutrition_water.jpg',
          'fullDescription':
              'Kedilerin ataları çöl kökenli olduğu için susuzluk hisleri son derece zayıftır. Yalnızca kuru mama tüketen kedilerde idrar yoğunlaşır, pH dengesi bozulur; bu durum struvit taşlarına, idrar yolu tıkanmasına (FLUTD) ve kronik böbrek yetmezliğine zemin hazırlar.\n\nHaftada en az 3-4 kez kaliteli yaş mama tüketimi ve evin farklı köşelerinde su pınarı (akar su) bulundurulması idrar hacmini artırarak böbrekleri ömür boyu korur.',
          'vetQuote':
              'Özellikle kısırlaştırılmış erkek kedilerde idrar yolu tıkanıklığı 24 saat içinde hayati risk oluşturur. Yaş mama bu riskin bir numaralı doğal önleyicisidir.',
          'keyPoints': [
            'Haftada 3-4 öğün kaliteli yaş mama ile hidrasyonu artırın.',
            'Akar su sağlayan kedi su pınarları su tüketimini 3 kat artırır.',
            'Kum kabında sık gidip az idrar yapma veya acı çekme belirtisinde derhal kliniğe başvurun.',
          ],
        },
        {
          'title': 'Su Kabını Mamadan Uzak Tutma Kuralı',
          'subtitle': 'İçgüdüsel kural: Kediler neden mamanın yanındaki suyu içmez?',
          'category': 'Davranış & Beslenme',
          'badge': 'ALTIN KURAL',
          'badgeColor': const Color(0xFFD35400),
          'icon': Icons.alt_route_rounded,
          'iconColor': const Color(0xFFE67E22),
          'image': 'assets/images/nutrition_recipe.jpg',
          'fullDescription':
              'Doğadaki vahşi kediler içgüdüsel olarak avlarını su kaynaklarının hemen yanında tüketmezler; av kalıntılarının suyu enfekte edebileceğini bilirler. Evcil kediler de aynı evrimsel refleksi taşır.\n\nMama kabının hemen bitişiğinde duran su kabı kediler tarafından "kirlenmiş" kabul edilir ve su içme sıklıkları belirgin şekilde düşer. Su kabını mama kabından en az 1.5 - 2 metre uzağa koyduğunuzda kedinizin çok daha hevesle su içtiğini göreceksiniz.',
          'vetQuote':
              'Geniş ağızlı cam veya seramik kaplar bıyık yorgunluğunu (whisker stress) önler; plastik kaplar ise çenede akneye sebep olabilir.',
          'keyPoints': [
            'Su kabını mama kabından en az 1.5 - 2 metre uzağa konumlandırın.',
            'Plastik yerine cam veya paslanmaz çelik su kapları kullanın.',
            'Suyu her gün en az 1 kez boşaltıp tazeleyin.',
          ],
        },
        {
          'title': 'Tüy Yumağı (Hairball) Yönetimi',
          'subtitle': 'Malt macunu ve taze kedi çiminin doğal lif desteği.',
          'category': 'Sindirim Güvenliği',
          'badge': 'DOĞAL KÜR',
          'badgeColor': const Color(0xFF27AE60),
          'icon': Icons.grass_rounded,
          'iconColor': const Color(0xFF27AE60),
          'image': 'assets/images/nutrition_food.jpg',
          'fullDescription':
              'Kediler günlerinin yaklaşık üçte birini yalanarak temizlenmeye ayırır. Dillerindeki geriye dönük minik dikenler dökülen tüyleri yutmalarına neden olur. Bu tüyler midede birikerek sindirimi tıkayabilir.\n\nHaftada 2-3 kez bezelye büyüklüğünde kaliteli malt macunu ve evde saksıda taze kedi çimi bulundurmak, yutulan tüylerin midede topaklaşmadan bağırsaklar yoluyla dışkıyla atılmasını sağlar.',
          'vetQuote':
              'Sık sık kuru öksürük ve sarı köpüklü kusma tüy yumağı birikiminin ilk işaretidir. Düzenli tarama yutulan tüy miktarını %70 azaltır.',
          'keyPoints': [
            'Haftada 2-3 kez malt macunu verin.',
            'Evinizde taze saksı kedi çimi bulundurun.',
            'Özellikle uzun tüylü ırkları her gün fırçalayın.',
          ],
        },
      ];
    } else if (lower.contains('kuş') || lower.contains('kus')) {
      return [
        {
          'title': 'Yalnızca Tohumla Besleme Tehlikesi',
          'subtitle': 'Karaciğer yağlanmasını önleyen %60 tohum, %30 sebze kuralı.',
          'category': 'Temel Beslenme',
          'badge': 'HAYATİ UYARI',
          'badgeColor': const Color(0xFFC0392B),
          'icon': Icons.warning_amber_rounded,
          'iconColor': const Color(0xFFE74C3C),
          'image': 'assets/images/nutrition_food.jpg',
          'fullDescription':
              'Pek çok kuş sahibi kafese sadece tohum koyar; oysa tohumlar yüksek oranda yağ barındırırken A vitamini ve kalsiyum yönünden çok fakirdir. Yalnızca tohumla beslenen muhabbet kuşları ve papağanlar erken yaşta ölümcül karaciğer yağlanmasına yakalanır.\n\nİdeal bir günlük diyet %60 kaliteli tohum veya pelet yem, %30 taze yıkanmış yeşillik ve sebze (brokoli, rende havuç, kırmızı biber), %10 mevsim meyvesinden oluşmalıdır.',
          'vetQuote':
              'Kuşunuz sebze yemeye alışkın değilse, rendelenmiş havucu tohumlarının üzerine hafifçe serperek yavaş yavaş alıştırabilirsiniz.',
          'keyPoints': [
            'Diyetin en az %30\'u taze sebze ve yeşilliklerden oluşmalıdır.',
            'Sebzeleri kafeste 4 saatten fazla tutmayın, bozulabilir.',
            'Yemlik kabuklarını her gün üfleyerek yemlik tabanını temizleyin.',
          ],
        },
        {
          'title': 'Kalamar Kemiği & İyot Taşı',
          'subtitle': 'Gaga aşınması, kemik sertliği ve yumurta sıkışması engelleme.',
          'category': 'Mineral Desteği',
          'badge': 'MİNERAL DENGESİ',
          'badgeColor': const Color(0xFF2980B9),
          'icon': Icons.hardware_rounded,
          'iconColor': const Color(0xFF2980B9),
          'image': 'assets/images/nutrition_recipe.jpg',
          'fullDescription':
              'Kuşların hafif kemik iskeleti ve sürekli uzayan keratin gagaları yoğun kalsiyum gerektirir. Özellikle dişi kuşlarda kalsiyum yetersizliği yumurta kabuğunun oluşamamasına ve ölümcül yumurta sıkışmasına yol açar.\n\nKafeste daima doğal mürekkep balığı kemiği (kalamar kemiği) ve mineral gaga taşı asılı olmalıdır. Bu taşlar aynı zamanda kuşun gagasını doğal olarak törpülemesini sağlayarak gaga deformasyonunu engeller.',
          'vetQuote':
              'Kalamar kemiğinin yumuşak iç kısmı tüneğe bakmalıdır; kuş oradan kolayca kalsiyum tozu kazıyabilir.',
          'keyPoints': [
            'Kafeste 365 gün kalamar kemiği ve mineral blok bulunmalıdır.',
            'Yumurtlama ve tüy döneminde kalsiyum ihtiyacı 2 katına çıkar.',
            'Aşırı uzayan gagalar yem yemeyi imkansız kılar, veteriner kontrolü gerekir.',
          ],
        },
        {
          'title': 'Tüy Dökümünde Yumurta Maması',
          'subtitle': 'Halsizliği önleyen ev yapımı doğal protein kürü.',
          'category': 'Ev Yapımı Tarif',
          'badge': 'DOĞAL KÜR',
          'badgeColor': const Color(0xFF27AE60),
          'icon': Icons.egg_rounded,
          'iconColor': const Color(0xFF27AE60),
          'image': 'assets/images/nutrition_food.jpg',
          'fullDescription':
              'Mevsimsel tüy değişiminde kuşlar yeni telekler oluşturabilmek için çok yüksek miktarda hayvansal proteine ve amino aside ihtiyaç duyar. Bu dönemde neşeleri kaçabilir ve uyku hali artabilir.\n\nTarif: 1 adet katı haşlanmış yumurta sarısını çatalla ezin. İçine 1 çay kaşığı ince rendelenmiş havuç ekleyin. Kuş başına haftada 1 tatlı kaşığı verin. Bu kür teleklerin parlak ve esnek çıkmasını sağlar.',
          'vetQuote':
              'Yumurta maması oda sıcaklığında çabuk bakteri üretir. Kafese konulduktan 2 saat sonra mutlaka alınmalıdır.',
          'keyPoints': [
            'Haftada 1 kez taze haşlanmış yumurta sarısı maması hazırlayın.',
            'Tüy köklerini güçlendirir ve döküm süresini kısaltır.',
            'Mama artığını 2 saat sonra kafesten mutlaka temizleyin.',
          ],
        },
      ];
    } else if (lower.contains('balık') || lower.contains('balik')) {
      return [
        {
          'title': '2 Dakika Kuralı (Aşırı Yemleme Katili)',
          'subtitle': 'Akvaryum ölümlerinin %90 sebebi açlık değil fazla yemdir.',
          'category': 'Kritik Kural',
          'badge': 'HAYATİ ÖNEM',
          'badgeColor': const Color(0xFFC0392B),
          'icon': Icons.timer_rounded,
          'iconColor': const Color(0xFFE74C3C),
          'image': 'assets/images/nutrition_food.jpg',
          'fullDescription':
              'Balıkların midesi gözlerinden küçüktür ve doyma mekanizmaları zayıftır. Akvaryuma atılan ve 2 dakika içinde tüketilmeyen yemler tabana çökerek çürür; nitrit ve ölümcül amonyak patlamasına sebep olur.\n\nBu kimyasal kirlilik balıkların solungaçlarını yakar ve aniden toplu ölümlere yol açar. Günde 1 veya en fazla 2 kez, balıkların 2 dakikada tamamen bitirebilecekleri kadar bir tutam yemleme altın kuraldır.',
          'vetQuote':
              'Aç kalan balık kolay kolay ölmez, fazla yemlenen balık ise suyu zehirleyerek saatler içinde ölür.',
          'keyPoints': [
            '2 dakikada yenmeyen yemleri derhal kepçeyle toplayın.',
            'Kısa tatillerde (3-4 gün) balıkları aç bırakmak aşırı yemlemekten çok daha güvenlidir.',
            'Yemlemeden sonra suda bulanıklık oluşuyorsa porsiyonu yarıya indirin.',
          ],
        },
        {
          'title': 'Haftalık 1 Gün Aç Bırakma (Oruç)',
          'subtitle': 'Yüzme kesesi iltihabı ve kabızlığı önleme sırrı.',
          'category': 'Sindirim Sağlığı',
          'badge': 'KLİNİK RUTİN',
          'badgeColor': const Color(0xFF2980B9),
          'icon': Icons.spa_rounded,
          'iconColor': const Color(0xFF2980B9),
          'image': 'assets/images/nutrition_water.jpg',
          'fullDescription':
              'Akvaryum ortamında yaşayan balıklar doğal göllerdeki kadar yüzemez ve hareketsiz kalırlar. Bu durum bağırsak tembelliğine ve yüzme kesesine baskı yapan kronik kabızlığa yol açar; balık ters veya yan yüzmeye başlar.\n\nProfesyonel akvaryum hekimleri haftanın bir gününü (örneğin pazar) tamamen açlık günü ilan eder. 24 saatlik bu sindirim dinlenmesi balıkların bağırsaklarını temizler ve su berraklığını artırır.',
          'vetQuote':
              'Japon balıklarında kabızlık durumunda haşlanmış ve kabuğu soyulmuş 1 adet bezelye içi mucizevi bir doğal sindirim ilacıdır.',
          'keyPoints': [
            'Haftada 1 gün balıklara kesinlikle yem vermeyin.',
            'Sindirim kanalı temizlenir ve yüzme dengesi korunur.',
            'Filtre süngerlerinin ömrünü uzatır ve su kalitesini zirveye çıkarır.',
          ],
        },
        {
          'title': 'Dip Balıkları & Vatozların Beslenmesi',
          'subtitle': 'Yüzey yemleri tabana ulaşmaz; batan spirulina tabletleri.',
          'category': 'Özel Tür İhtiyacı',
          'badge': 'TÜR BİLGİSİ',
          'badgeColor': const Color(0xFF27AE60),
          'icon': Icons.bubble_chart_rounded,
          'iconColor': const Color(0xFF27AE60),
          'image': 'assets/images/nutrition_recipe.jpg',
          'fullDescription':
              'Çöpçü balıkları (corydoras) ve vatozlar akvaryumun tabanında yaşar. Yüzeye atılan pul yemler üst kademedeki hareketli balıklar tarafından kapılır ve dip balıkları kronik açlık çeker.\n\nOnlar için ışıklar kapandıktan sonra akvaryuma batan spirulina tabletleri veya dip peletleri bırakılmalıdır. Ayrıca vatozların sindirim sisteminde selüloz sindirimi için akvaryumda mutlaka doğal mangrow veya mopani kütüğü bulunmalıdır.',
          'vetQuote':
              'Vatozlar sadece camdaki yosunlarla beslenemez; mutlaka bitkisel batan tabletlerle desteklenmelidir.',
          'keyPoints': [
            'Gece akvaryum ışıkları kapandıktan sonra dip tableti atın.',
            'Sindirim için akvaryumda doğal mangrow kökü bulundurun.',
            'Dip balıklarının bıyıklarının erimemesi için ince yuvarlak kum kullanın.',
          ],
        },
      ];
    } else if (lower.contains('tavşan') || lower.contains('tavsan') || lower.contains('hamster') || lower.contains('kemirgen')) {
      return [
        {
          'title': '%80 Kuru Ot (Timothy Çimi) Şartı',
          'subtitle': 'Ölümcül bağırsak durması (GI Stasis) ve diş uzaması uyarısı.',
          'category': 'Hayat Kurtaran',
          'badge': 'HAYATİ ÖNEM',
          'badgeColor': const Color(0xFFC0392B),
          'icon': Icons.grass_rounded,
          'iconColor': const Color(0xFFE74C3C),
          'image': 'assets/images/nutrition_food.jpg',
          'fullDescription':
              'Tavşan ve kobayların dişleri haftada 2-3 mm uzar. Yeterli oranda lifli kuru ot çiğnemezlerse arka azı dişleri uzayarak dillerini ve damaklarını deler. Ayrıca sindirim sistemleri sürekli lif geçişine bağımlıdır; ot yemezlerse bağırsak hareketleri durur (GI Stasis) ve 24 saat içinde ölüm riski doğar.\n\nDiyetlerinin %80\'i sınırsız kaliteli kuru çayır otu veya Timothy çimi olmalıdır. Kuru ot bir ara öğün değil, ana yaşam kaynağıdır.',
          'vetQuote':
              'Tavşanın önünde 24 saat sınırsız kuru ot bulunmalıdır. Ot yemeyi bırakan bir tavşan acil klinik vakasıdır.',
          'keyPoints': [
            'Diyetin %80\'i sınırsız kuru ot olmalıdır.',
            'Dişlerin doğal yoldan aşınarak sağlıklı kalmasını sağlar.',
            'Bağırsak hareketlerini canlı tutarak ölümcül tıkanmaları önler.',
          ],
        },
        {
          'title': 'Guinea Pig İçin C Vitamini Zorunluluğu',
          'subtitle': 'İnsanlar gibi kobaylar da C vitamini üretemez; iskorbüt uyarısı.',
          'category': 'Hayati Vitamin',
          'badge': 'GÜNLÜK İHTİYAÇ',
          'badgeColor': const Color(0xFF2980B9),
          'icon': Icons.medication_liquid_rounded,
          'iconColor': const Color(0xFF2980B9),
          'image': 'assets/images/nutrition_water.jpg',
          'fullDescription':
              'Guinea pigler (kobaylar) vücutlarında C vitamini sentezleyemeyen nadir canlılardandır. C vitamini eksikliği eklem şişlikleri, diş eti kanamaları, kürk dökülmesi ve arka bacak felcine (iskorbüt hastalığı) yol açar.\n\nHer gün taze kırmızı kapya biber, maydanoz veya brokoli verilerek günlük C vitamini ihtiyacı doğal yoldan karşılanmalıdır. Asla normal tavşan yemi verilmemelidir; çünkü tavşan yemleri kobayların ihtiyaç duyduğu C vitaminini içermez.',
          'vetQuote':
              'Suya damlatılan C vitamini ışıkta birkaç saatte bozulur; en sağlıklı yöntem doğrudan taze kırmızı kapya biber yedirmektir.',
          'keyPoints': [
            'Her gün bir parça taze kırmızı kapya biber verin.',
            'C vitamini eksikliği eklemlerde geri dönülmez hasar bırakır.',
            'Yalnızca Guinea Piglere özel zenginleştirilmiş yemleri seçin.',
          ],
        },
        {
          'title': 'Havuç Efsanesi: Şeker Tehlikesi',
          'subtitle': 'Çizgi filmlerin aksine havuç tavşanlar için ana yemek değildir!',
          'category': 'Beslenme Gerçekleri',
          'badge': 'DOĞRU BİLİNEN YANLIŞ',
          'badgeColor': const Color(0xFFD35400),
          'icon': Icons.psychology_rounded,
          'iconColor': const Color(0xFFE67E22),
          'image': 'assets/images/nutrition_recipe.jpg',
          'fullDescription':
              'Popüler çizgi filmlerin aksine tavşanların ana gıdası asla havuç değildir. Havuç yüksek oranda şeker ve nişasta barındırır; aşırı verildiğinde tavşanın hassas körbağırsak (cecum) florasını bozar, gaz sancısına ve karaciğer yağlanmasına yol açar.\n\nHavuç yalnızca haftada 1-2 kez parmak boğumu kadar küçük bir ödül olarak verilmelidir. Taze nane, fesleğen ve dereotu çok daha güvenli ve sağlıklı yeşilliklerdir.',
          'vetQuote':
              'Tavşana ödül olarak havuç yerine bir tutam taze nane veya fesleğen vermek sindirimi için katbekat faydalıdır.',
          'keyPoints': [
            'Havuç şeker oranı nedeniyle ana yemek olamaz.',
            'Haftada 1-2 kez küçük parça ödül olarak sunun.',
            'Taze dereotu, fesleğen ve nane bağırsakları rahatlatır.',
          ],
        },
      ];
    }

    // Default: Köpek (Dog)
    return [
      {
        'title': 'Doğru Mama & Yaş Grupları',
        'subtitle': 'Yavru, yetişkin ve yaşlı dönemde protein ve eklem dengesi.',
        'category': 'Temel Beslenme',
        'badge': 'YAŞ DÖNEMİ',
        'badgeColor': const Color(0xFF1E824C),
        'icon': Icons.health_and_safety_rounded,
        'iconColor': const Color(0xFF27AE60),
        'image': 'assets/images/nutrition_food.jpg',
        'fullDescription':
            'Köpeklerin besin ihtiyaçları yaşam evrelerine göre dramatik biçimde değişir. Yavru köpeklerde kemik ve kas gelişimi için %28-32 kaliteli hayvansal protein ve dengeli kalsiyum/fosfor oranı şarttır.\n\n1-7 yaş yetişkinlikte aşırı kaloriden kaçınarak yağsız kas kütlesi korunmalıdır. 7 yaş üzeri yaşlı köpeklerde ise böbrekleri yormayan, glukozamin ve kondroitin içeren eklem destekli mamalar tercih edilmelidir.',
        'vetQuote':
            'Kendi yediğiniz yağlı yemek artıklarını vermek köpeğin pankreasına aşırı yük bindirerek akut pankreatite yol açabilir.',
        'keyPoints': [
          'Yavruluk: Yüksek protein ve beyin gelişimi için DHA.',
          'Yetişkinlik: Kilo kontrolü ve tartar önleyici kıtırlık.',
          'Yaşlılık: Glukozamin desteği ve sindirimi kolay lifler.',
        ],
      },
      {
        'title': 'Ev Yapımı Kolajen Kemik Suyu',
        'subtitle': 'Eklemleri güçlendiren ve sindirimi yatıştıran şifa kürü.',
        'category': 'Doğal Tarif',
        'badge': 'DOĞAL KÜR',
        'badgeColor': const Color(0xFF2980B9),
        'icon': Icons.soup_kitchen_rounded,
        'iconColor': const Color(0xFF2980B9),
        'image': 'assets/images/nutrition_recipe.jpg',
        'fullDescription':
            'İlikli dana veya kuzu kemiklerini bol suda, içine az miktarda havuç ve kabak ekleyerek kısık ateşte 6-8 saat kaynatın. Soğuduktan sonra üzerindeki donmuş aşırı yağ tabakasını kaşıkla sıyırıp atın.\n\nElde edilen jöle kıvamındaki kolajen suyunu haftada 2-3 kez kuru mamasının üzerine 2 yemek kaşığı ılık olarak dökün. Eklem kireçlenmesine karşı kıkırdakları onarır ve iştahsız köpeklerin iştahını açar.',
        'vetQuote':
            'Kemik suyunu yaparken asla soğan, sarımsak, tuz veya baharat eklemeyin. Kaynamış kemikleri asla köpeğe yedirmeyin; kemikler midede batma ve yırtılma yapabilir.',
        'keyPoints': [
          'Tuzsuz ve soğansız kısık ateşte kaynatın.',
          'Üstteki donmuş yağ tabakasını mutlaka ayırın.',
          'Mamayı nemlendirmek ve eklemleri korumak için ılık servis edin.',
        ],
      },
      {
        'title': 'Mide Dönmesi (GDV) & Hızlı Yeme',
        'subtitle': 'Ölümcül mide torsiyonunu önleme kuralları.',
        'category': 'Kritik Güvenlik',
        'badge': 'HAYATİ ÖNEM',
        'badgeColor': const Color(0xFFC0392B),
        'icon': Icons.warning_amber_rounded,
        'iconColor': const Color(0xFFE74C3C),
        'image': 'assets/images/nutrition_water.jpg',
        'fullDescription':
            'Özellikle büyük ve derin göğüslü köpeklerde (Golden, Alman Çoban, Boxer vb.) mamanın çok hızlı yenmesi ve ardından koşup oynaması midenin kendi etrafında dönmesine (GDV - Gastrik Dilatasyon Volvulus) neden olur.\n\nBu durum acil cerrahi müdahale gerektiren ölümcül bir tablodur. Labirent (yavaş yeme) mama kapları kullanın ve yemekten sonraki 1 saat kesinlikle koşu veya ağır oyun yaptırmayın.',
        'vetQuote':
            'Mamadan hemen sonra aşırı su içilmesi ve zıplama hareketleri mide dönmesi riskini katlar. Beslenme sonrası dinlenme altın kuraldır.',
        'keyPoints': [
          'Labirent (yavaş yeme) kabı kullanın.',
          'Mamadan sonra 60 dakika sakin dinlenme sağlayın.',
          'Günde 1 dev öğün yerine 2 eşit öğün verin.',
        ],
      },
      {
        'title': 'Ödül Maması & Kalori Dengesi',
        'subtitle': 'Eğitimde kilo almayı önleyen %10 kuralı.',
        'category': 'Kilo Yönetimi',
        'badge': 'ALTIN KURAL',
        'badgeColor': const Color(0xFFD35400),
        'icon': Icons.pets_rounded,
        'iconColor': const Color(0xFFE67E22),
        'image': 'assets/images/nutrition_food.jpg',
        'fullDescription':
            'Eğitim sırasında verilen ödül mamaları gün boyu fark edilmeden köpeğin aşırı kalori almasına yol açar. Altın kural: Günlük toplam kalori ihtiyacının maksimum %10\'u ödüllerden gelmelidir.\n\nÖrneğin günlük 500 kcal yiyen bir köpeğe en fazla 50 kcal değerinde ödül verilmelidir. Kilo eğilimli dostlarımızda haşlanmış yağsız tavuk göğsü veya çiğ havuç parçacıkları düşük kalorili mükemmel bir alternatiftir.',
        'vetQuote':
            'Obezite köpeklerde kalp yetmezliği, eklem fıtığı ve şeker hastalığının bir numaralı sebebidir.',
        'keyPoints': [
          'Ödüller günlük kalorinin %10\'unu geçmemeli.',
          'Ödül verildiyse ana mama porsiyonu kısılmalı.',
          'Havuç ve kabak sağlıklı düşük kalorili ödüllerdir.',
        ],
      },
    ];
  }

  Widget _buildRecommendationsSection(String petType) {
    final appLang = AppLanguage.of(context);
    final recommendations = _getVeterinaryRecommendations(petType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1E824C).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF1E824C), size: 20),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appLang.translateDynamic('Veteriner Beslenme Tavsiyeleri'),
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17.sp, color: AppTheme.textDark),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    appLang.translateDynamic('$petType için klinik onaylı ve bilimsel beslenme rehberleri'),
                    style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        SizedBox(
          height: 195.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final rec = recommendations[index];
              return _buildRecommendationCard(rec, appLang);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> rec, AppLanguage appLang) {
    final title = rec['title'] as String;
    final subtitle = rec['subtitle'] as String;
    final badge = rec['badge'] as String;
    final badgeColor = (rec['badgeColor'] as Color?) ?? const Color(0xFF1E824C);
    final iconColor = (rec['iconColor'] as Color?) ?? const Color(0xFF1E824C);
    final icon = (rec['icon'] as IconData?) ?? Icons.lightbulb_rounded;
    final image = rec['image'] as String? ?? 'assets/images/nutrition_food.jpg';

    return Container(
      width: 175.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.shade100, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showRecommendationDetailModal(rec, appLang),
          borderRadius: BorderRadius.circular(18.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    child: Image.asset(
                      image,
                      height: 82.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => Container(
                        height: 82.h,
                        color: iconColor.withValues(alpha: 0.1),
                        child: Center(child: Icon(icon, color: iconColor, size: 32)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6.h,
                    left: 6.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(6.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        appLang.translateDynamic(badge),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.5.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(9.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appLang.translateDynamic(title),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: AppTheme.textDark),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      appLang.translateDynamic(subtitle),
                      style: TextStyle(fontSize: 10.sp, color: AppTheme.textLight, height: 1.25),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text(
                          appLang.translateDynamic('Detayı Oku'),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E824C),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 9, color: Color(0xFF1E824C)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecommendationDetailModal(Map<String, dynamic> rec, AppLanguage appLang) {
    final title = rec['title'] as String;
    final category = rec['category'] as String? ?? 'Veteriner Rehberi';
    final badge = rec['badge'] as String? ?? 'ÖNEMLİ';
    final badgeColor = (rec['badgeColor'] as Color?) ?? const Color(0xFF1E824C);
    final icon = (rec['icon'] as IconData?) ?? Icons.lightbulb_rounded;
    final iconColor = (rec['iconColor'] as Color?) ?? const Color(0xFF1E824C);
    final fullDescription = rec['fullDescription'] as String? ?? '';
    final vetQuote = rec['vetQuote'] as String? ?? '';
    final keyPoints = (rec['keyPoints'] as List?)?.cast<String>() ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Container(
              padding: EdgeInsets.only(
                top: 14.h,
                left: 20.w,
                right: 20.w,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Icon(icon, color: iconColor, size: 24),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  appLang.translateDynamic(badge),
                                  style: TextStyle(
                                    color: badgeColor,
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                appLang.translateDynamic(category),
                                style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.grey),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      appLang.translateDynamic(title),
                      style: TextStyle(
                        fontSize: 16.5.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      appLang.translateDynamic(fullDescription),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),
                    if (vetQuote.isNotEmpty) ...[
                      SizedBox(height: 14.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF9E7),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFF1C40F), width: 1.2),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.local_hospital_rounded, color: Color(0xFFD35400), size: 20),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appLang.translateDynamic('Uzman Veteriner Görüşü'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.5.sp,
                                      color: const Color(0xFFB7950B),
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    appLang.translateDynamic(vetQuote),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: const Color(0xFF7D6608),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (keyPoints.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Text(
                        appLang.translateDynamic('Kritik Kurallar & Tavsiyeler:'),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ...keyPoints.map((point) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF27AE60), size: 16),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  appLang.translateDynamic(point),
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    color: Colors.grey.shade800,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E824C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(
                          appLang.translateDynamic('Anladım, Teşekkürler'),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}
