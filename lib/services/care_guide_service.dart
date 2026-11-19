import 'package:flutter/material.dart';

class CareCategoryDetail {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String frequency;
  final String whyImportant;
  final List<String> supplies;
  final List<String> stepByStep;
  final List<String> goldenRules;
  final List<String> dangerWarnings;
  final String vetTip;

  const CareCategoryDetail({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.frequency,
    required this.whyImportant,
    required this.supplies,
    required this.stepByStep,
    required this.goldenRules,
    required this.dangerWarnings,
    required this.vetTip,
  });
}

class CareMythFact {
  final String myth;
  final String fact;

  const CareMythFact({required this.myth, required this.fact});
}

class PetCareProfile {
  final String petType;
  final String introTitle;
  final String introSubtitle;
  final List<String> beginnerRules;
  final List<CareCategoryDetail> categories;
  final List<CareMythFact> commonMistakes;
  final List<String> defaultWeeklyChecklist;

  const PetCareProfile({
    required this.petType,
    required this.introTitle,
    required this.introSubtitle,
    required this.beginnerRules,
    required this.categories,
    required this.commonMistakes,
    required this.defaultWeeklyChecklist,
  });
}

class CareGuideService {
  /// Returns a comprehensive, beginner-friendly care profile tailored to the pet type.
  static PetCareProfile getProfileForPetType(String rawType, String petName) {
    final type = rawType.trim().toLowerCase();

    if (type.contains('kedi') || type.contains('cat')) {
      return _buildCatProfile(petName);
    } else if (type.contains('kuş') || type.contains('kus') || type.contains('bird')) {
      return _buildBirdProfile(petName);
    } else if (type.contains('tavşan') || type.contains('tavsan') || type.contains('rabbit')) {
      return _buildRabbitProfile(petName);
    } else if (type.contains('hamster') || type.contains('kemirgen') || type.contains('guinea')) {
      return _buildHamsterProfile(petName);
    } else if (type.contains('balık') || type.contains('balik') || type.contains('fish')) {
      return _buildFishProfile(petName);
    } else {
      // Default to Dog profile (most common)
      return _buildDogProfile(petName);
    }
  }

  // ==========================================
  // 🐶 KÖPEK DETAYLI BAKIM REHBERİ
  // ==========================================
  static PetCareProfile _buildDogProfile(String name) {
    return PetCareProfile(
      petType: 'Köpek',
      introTitle: '$name İçin Sıfırdan Adım Adım Köpek Bakımı',
      introSubtitle: 'İlk kez köpek sahiplenenler için pratik, adım adım ve hayat kurtaran bakım rehberi.',
      beginnerRules: [
        'Köpeklerin deri pH seviyesi (7.0 - 7.5) insanlardan (5.5) çok farklıdır. Asla bebek veya insan şampuanı kullanmayın.',
        'Çift katmanlı tüylere sahip ırkları (Golden, Husky, Pomeranian) yazın sıfıra tıraş ettirmeyin; alt tüyler sıcağa ve güneşe karşı doğal yalıtım sağlar.',
        'Yürüyüş sonrası patileri kimyasal ıslak mendillerle değil, ılık su veya evcil hayvanlara özel mendille silin.',
        'Kulaklarına su kaçması inatçı mantar ve bakteri enfeksiyonlarına yol açar. Banyoda kulaklara mutlaka pamuk yerleştirin.',
        'Günde en az 5-10 dakika tüy tarama rutini, evinize dökülen tüy miktarını %80 oranında azaltır.',
      ],
      categories: [
        CareCategoryDetail(
          id: 'dog_brushing',
          title: 'Tüy Taraması & Tıraş',
          subtitle: 'Deri sağlığı, tüy döküm kontrolü ve keçe önleme',
          icon: Icons.content_cut_rounded,
          color: const Color(0xFF8E44AD),
          frequency: 'Kısa tüylüler için haftada 2-3 kez; uzun veya çift katmanlılar için her gün 5-10 dk',
          whyImportant:
              'Köpekler dökülen ölü tüyleri kendi başlarına atamazlar. Düzenli taranmayan tüyler keçeleşir, derinin hava almasını engeller ve altında nemli egzama (hot-spot), mantar ve parazit yuvalanmasına neden olur. Tarama aynı zamanda kan dolaşımını hızlandırır ve doğal koruyucu yağların tüylere dağılmasını sağlar.',
          supplies: [
            'Slicker (telli uçlu) fırça (alt tüy dökümünü toplamak için)',
            'Metal seyrek dişli tarak (düğümleri ve keçeleri açmak için)',
            'Tüy açıcı ve nemlendirici köpek spreyi (tüy kırılmasını önler)',
            'Ödül maması (işlemi olumlu pekiştirmek için)',
          ],
          stepByStep: [
            '1. Adım - Sakinleştirme: $name\'i sessiz bir alana alın, göğsünü ve sırtını sevip sakinleşmesini sağlayın. Küçük bir ödül maması verin.',
            '2. Adım - Spreyle Nemlendirme: Asla tamamen kuru tüyleri sertçe çekmeyin. Tüy açıcı spreyi 20 cm uzaktan hafifçe sıkın.',
            '3. Adım - Uçlardan Köklere Tarama: Düğümlenmiş bir bölge varsa kökünden asılmak yerine, tüyün altından elinizle tutup uç kısımlardan yavaşça tarayarak açın.',
            '4. Adım - Tüy Çıkış Yönüne Doğru: Slicker fırçayı fazla bastırmadan, tüy çıkış yönünde boyundan kuyruğa doğru nazikçe çekin.',
            '5. Adım - Koltuk Altı ve Kulak Arkası: En çok keçeleşen yerler bacak araları ve kulak arkalarıdır; bu bölgeleri seyrek dişli metal tarakla dikkatle geçin.',
          ],
          goldenRules: [
            'Düğüm açarken köpeğin derisini elinizle gererek çekme hissini engelleyin.',
            'Her başarılı bölgeden sonra sakin ses tonuyla övün ve ödül verin.',
          ],
          dangerWarnings: [
            'Çift katmanlı ırkları (Golden, Samoyed, Husky, Alman Çoban) asla makineyle sıfıra kestirmeyin; tüyler bir daha eski kalitesinde çıkmayabilir ve güneş yanığı oluşabilir.',
            'Dolaşmış keçeleri açmak için asla ev tipi sivri uçlu makas kullanmayın; köpek ani hareket ederse derisi kesilebilir.',
          ],
          vetTip:
              'Mevsim geçişlerinde (ilkbahar ve sonbahar) tüy dökümü zirve yapar. Bu dönemde her gün düzenli 10 dakika taramak evdeki tüyleri süpürmekten 10 kat daha etkilidir.',
        ),
        CareCategoryDetail(
          id: 'dog_bath',
          title: 'Banyo & Yıkama',
          subtitle: 'Doğru şampuan seçimi ve ılık su hijyeni',
          icon: Icons.shower_rounded,
          color: const Color(0xFF3498DB),
          frequency: 'Ayda 1 kez (Çok kirlenmedikçe 3-4 haftadan sık yıkanmamalıdır)',
          whyImportant:
              'Köpeklerin derisi insan derisinden 3 kat daha incedir ve ter bezleri deride değil pati altlarındadır. Aşırı sık yıkamak, derinin cildi koruyan doğal sebum tabakasını yok eder; bu da kuruluk, kepeklenme, kaşıntı ve kötü kokuya yol açar.',
          supplies: [
            'Köpeklere özel pH dengeli şampuan (Asla insan şampuanı değil)',
            'Banyoya kaydırmaz taban matı (kayma korkusunu engeller)',
            '2 adet büyük boy emici havlu',
            'Ilık hava üfleyen saç kurutma makinesi (düşük ayarda)',
            'Kulaklar için 2 parça temiz kuru pamuk',
          ],
          stepByStep: [
            '1. Adım - Ön Hazırlık: Banyoya girmeden önce $name\'in tüylerini tarayın (ıslanan düğümler taşlaşır ve açılamaz). Kulaklarına su kaçmaması için kulak girişlerine pamuk koyun.',
            '2. Adım - Ilık Su Kontrolü: Suyu bileğinize tutun; ne sıcak ne soğuk, tam vücut ısısında ılık olmalıdır.',
            '3. Adım - Islatma: Arkadan öne doğru (patilerden başlayıp sırta doğru) tüyleri iyice ıslatın. Başa doğrudan tazyikli su tutmayın.',
            '4. Adım - Köpürtme ve Masaj: Şampuanı doğrudan dökmek yerine elinizde ılık suyla köpürtüp masaj yaparak deriye yayın. Göz ve ağız çevresine sabun değdirmeyin.',
            '5. Adım - Kusursuz Durulama: Şampuan kalıntısı ciltte kuruyup kaşıntı yapar; su tamamen berrak akana kadar en az 3-4 dakika durulayın.',
            '6. Adım - Kurulama: Önce havluyla tampon hareketlerle suyunu alın, ardından kurutma makinesini 30 cm uzaktan ılık ayarda tutarak derisi tamamen kuruyana kadar kurutun.',
          ],
          goldenRules: [
            'Banyo sırasında banyo zeminine kaydırmaz paspas koymak köpeğin güven duygusunu 2 katına çıkarır.',
            'Banyo biter bitmez en sevdiği yüksek değerli ödülü (örneğin haşlanmış tavuk göğsü) verin.',
          ],
          dangerWarnings: [
            'Bebek şampuanı dahil hiçbir insan şampuanını kullanmayın; pH farkı deride yanma ve yoğun kaşıntıya yol açar.',
            'Tüyleri nemli bırakıp rüzgara çıkarmayın; mantar enfeksiyonu nemli deride hızla ürer.',
          ],
          vetTip:
              'Köpekler banyodan sonra deli gibi koşup silkelenmek ister; bu tamamen doğal bir rahatlama tepkisidir, endişelenmeyin.',
        ),
        CareCategoryDetail(
          id: 'dog_nails',
          title: 'Tırnak Kesimi & Pati Bakımı',
          subtitle: 'Canlı damar kontrolü ve basış bozukluğunu önleme',
          icon: Icons.pets_rounded,
          color: const Color(0xFFE67E22),
          frequency: '3 - 4 haftada bir (Yere bastığında tık tık ses geliyorsa uzamıştır)',
          whyImportant:
              'Aşırı uzayan tırnaklar yere her basışta parmak kemiklerini geriye doğru iter. Bu durum zamanla eklem ağrılarına, basış bozukluklarına ve tırnağın kıvrılarak pati etine batmasına neden olur.',
          supplies: [
            'Giyotin veya pense tipi kaliteli köpek tırnak makası',
            'Mısır nişastası veya hemostatik kan durdurucu toz',
            'Telefon feneri (koyu renkli tırnaklarda damarı görmek için)',
            'Yüksek değerli lezzetli ödül maması',
          ],
          stepByStep: [
            '1. Adım - Alıştırma: Makası hemen kesmek için kullanmayın; birkaç gün makası patisine değdirip ödül vererek sesine ve varlığına alıştırın.',
            '2. Adım - Damar Tespiti (Quick): Açık renkli tırnaklarda pembe canlı damar net görünür. Koyu tırnaklarda arkadan telefon feneri tutarak damarın bittiği yeri belirleyin.',
            '3. Adım - 45 Derecelik Açı: Tırnağı canlı pembe dokunun en az 2-3 mm uzağından, aşağı doğru 45 derecelik açıyla tutun.',
            '4. Adım - Tek Seferde Kesmeyin: Tırnaktan tek seferde büyük parça koparmak yerine milim milim ince tabakalar halinde kesin.',
            '5. Adım - Kesilen Yere Bakın: Tırnağın kesilen ortasında siyah bir nokta veya beyazımsı halka gördüğünüz an damara yaklaştınız demektir; derhal durun.',
          ],
          goldenRules: [
            'Günde sadece 1-2 tırnak keserek başlayın; köpeği strese sokmadan günlere yayabilirsiniz.',
            'Pati altı yastıkçıkları çatlamışsa balmumu içerikli doğal pati kremi sürün.',
          ],
          dangerWarnings: [
            'Eğer canlı damar kesilirse yoğun kanama olabilir. Panik yapmayın! Parmağınızla biraz mısır nişastası alıp tırnağın ucuna bastırın; 1 dakikada kanamayı durdurur.',
            'Asla kör veya paslı ev tipi tırnak makası kullanmayın; tırnağı kesmek yerine ezer ve çatlatır.',
          ],
          vetTip:
              'Asfalt ve betonda düzenli yürüyen köpeklerin tırnakları doğal olarak törpülenir; ön ayaklardaki yan tırnak (kurt tırnağı) yere basmadığı için en çok o uzar, onu unutmayın.',
        ),
        CareCategoryDetail(
          id: 'dog_ears_eyes',
          title: 'Kulak & Göz Temizliği',
          subtitle: 'Mantar, koku ve çapak kontrolü',
          icon: Icons.hearing_rounded,
          color: const Color(0xFF27AE60),
          frequency: 'Haftada 1 kez kontrol ve gerekirse temizlik',
          whyImportant:
              'Özellikle sarkık kulaklı ırklarda (Cocker, Golden, Beagle) kulak içi hava almadığı için sıcak ve nemli ortamda maya (mantar) ve bakteri kolayca çoğalır. Göz çapakları ise kornea çizilmelerine ve enfeksiyonlara yol açabilir.',
          supplies: [
            'Veteriner onaylı kulak temizleme solüsyonu',
            'Makyaj temizleme pamuğu veya gazlı bez',
            'Göz temizleme solüsyonu veya steril izotonik serum fizyolojik',
          ],
          stepByStep: [
            '1. Adım - Koku ve Renk Kontrolü: Kulağı kaldırıp koklayın. Kötü ekşi bir koku veya kahve telvesi benzeri siyah akıntı varsa temizlemek yerine veterinere gidin (kulak uyuzu/mantar belirtisidir).',
            '2. Adım - Solüsyon Damlatma: Kulak içi pembe ve normalse, solüsyondan 2-3 damla kulak kanalına damlatın.',
            '3. Adım - Taban Masajı: Kulağın kök kısmına dışarıdan 30 saniye hafifçe masaj yapın ("cık cık" şeklinde sıvı sesi duyacaksınız). Bu kirleri çözer.',
            '4. Adım - Silkelenmeye İzin Verin: Köpek kafasını kuvvetle silkeleyecektir; geri çekilin, çözülen kirler dışarı fırlayacaktır.',
            '5. Adım - Dış Kulak Temizliği: Pamukla sadece dış kulak kepçesinde görünen kiri silin. Göz çapaklarını da ılık serum fizyolojik damlatılmış pamukla dıştan içe silin.',
          ],
          goldenRules: [
            'Her iki göz ve kulak için mutlaka ayrı temiz pamuk kullanın; mikropları birbirine taşımayın.',
          ],
          dangerWarnings: [
            'KULAĞIN İÇİNE KESİNLİKLE KULAK ÇUBUĞU (Q-TIP) SOKMAYIN! Kirleri derine iter ve ani bir kafa hareketinde kulak zarını patlatabilir.',
            'Göz içine alkol, kolonya veya insan göz damlası asla damlatmayın.',
          ],
          vetTip:
              'Köpeğiniz sık sık kafasını sallıyor veya kulağını yere sürtüyorsa bu genellikle erken kulak enfeksiyonu veya kulağa giren pisi pisi otu işaretidir.',
        ),
        CareCategoryDetail(
          id: 'dog_teeth',
          title: 'Diş & Ağız Sağlığı',
          subtitle: 'Tartar önleme, diş eti iltihabı ve taze nefes',
          icon: Icons.sentiment_very_satisfied_rounded,
          color: const Color(0xFFE74C3C),
          frequency: 'Haftada en az 2-3 kez (İdeal olan her gün 1 dakikadır)',
          whyImportant:
              '3 yaşın üzerindeki köpeklerin %80\'inde diş eti hastalığı (periodontitis) görülür. Ağızdaki bakteriler sadece diş kaybına yol açmaz; diş etinden kan dolaşımına karışarak kalp kapakçıklarına, karaciğere ve böbreklere kalıcı hasar verir.',
          supplies: [
            'Enzimatik köpek diş macunu (Tavuklu veya ciğer aromalı)',
            'Yumuşak parmak fırça veya çift taraflı pet diş fırçası',
            'Plak önleyici doğal çiğneme çubukları (dental treats)',
          ],
          stepByStep: [
            '1. Adım - Macun Tadına Alıştırma: İlk gün fırça kullanmayın; parmağınızın ucuna biraz köpek diş macunu koyup yalamasına izin verin (bu macunlar yutulabilir ve lezzetlidir).',
            '2. Adım - Diş Etine Dokunma: Parmağınızla dudaklarını nazikçe kaldırıp dişlerine ve diş etlerine hafifçe dokunarak sevin, hemen ödüllendirin.',
            '3. Adım - Parmak Fırçaya Geçiş: Parmak fırçayı takıp az miktarda macunla dış diş yüzeylerini dairesel hareketlerle 15-20 saniye fırçalayın.',
            '4. Adım - Azı Dişlerine Odaklanın: En çok diş taşı arka büyük çiğneme dişlerinde birikir; fırçayı arkalara doğru ulaştırın.',
            '5. Adım - Durulama Gerekmez: Köpek macunları durulanmaz, tükürükle kendiliğinden enzimatik temizlik yapmaya devam eder.',
          ],
          goldenRules: [
            'Sabırlı olun; ilk hafta sadece dudak açma egzersizi bile yapsanız büyük bir başarıdır.',
            'Fırçalamayı oyun veya yürüyüş öncesi yaparak keyifli bir rutin haline getirin.',
          ],
          dangerWarnings: [
            'İNSAN DİŞ MACUNU KÖPEKLER İÇİN ÖLÜMCÜL ZEHİRDİR! İçindeki Florür ve Ksilitol maddeleri köpeklerde ani karaciğer iflası ve hipoglisemi yapar.',
            'Sert gerçek pişmiş kemik vermeyin; dişleri kırabilir ve mide-bağırsak delinmesine yol açar.',
          ],
          vetTip:
              'Ağızda pas veya çürük benzeri yoğun bir koku varsa diş taşları diş etinin altına inmiş olabilir; bu durumda veterinerde anestezi altında ultrasonik diş taşı temizliği gerekir.',
        ),
        CareCategoryDetail(
          id: 'dog_parasite',
          title: 'Parazit Kontrolü & Rutinler',
          subtitle: 'İç-dış parazit takvimi ve kene/pire koruması',
          icon: Icons.shield_rounded,
          color: const Color(0xFF16A085),
          frequency: 'Dış parazit damlası: 1-2 ayda bir; İç parazit hapı: 2-3 ayda bir',
          whyImportant:
              'Pire ve keneler sadece kaşıntı yapmaz; Lyme hastalığı, Anaplazma gibi ölümcül kan hastalıkları bulaştırır. İç parazitler (şeritler, tenyalar) ise köpeğin besinine ortak olup zayıflamasına yol açtığı gibi insanlara da bulaşabilir (Zoonoz).',
          supplies: [
            'Veteriner hekiminizin reçete ettiği ense damlası veya çiğneme tableti',
            'Kene çıkarma cımbızı / kene kartı',
            'İç parazit takip takvimi (PatiRehber içinden takip edebilirsiniz)',
          ],
          stepByStep: [
            '1. Adım - Ense Damlası Uygulaması: Damlayı köpeğin kafasının arkasında, tam kürek kemikleri arasına uygulayın (orayı diliyle yalayamaz).',
            '2. Adım - Tüyleri İki Yana Açın: Damlayı tüye değil, mutlaka pembe deri yüzeyine damlatın.',
            '3. Adım - 48 Saat Su Yok: Damla derideki yağ bezlerine yayılacağı için uygulamadan 2 gün önce ve 2 gün sonra banyo yaptırmayın.',
            '4. Adım - Yürüyüş Sonrası Kene Taraması: Çimlik alandan döndüğünüzde koltuk altı, kulak arkası ve parmak aralarını elinizle yoklayın.',
          ],
          goldenRules: [
            'Kene görürseniz üzerine ASLA kolonya, alkol, yağ dökmeyin veya sigara basmayın! Boğulan kene midesindeki tüm zehirli bakterileri köpeğin kanına kusar.',
            'Kene cımbızla deriye en yakın yerden tutulup düz bir hareketle dik olarak çekilmelidir.',
          ],
          dangerWarnings: [
            'Marketlerde satılan ucuz ve markasız bit-pire tasmaları deride kimyasal yanık yapabilir; daima veteriner hekim onaylı ürün kullanın.',
          ],
          vetTip:
              'Köpeğiniz poposunu yere sürtüyorsa (kızak hareketi) bu ya tenya (iç parazit) ya da anüs keselerinin dolup şişmesinden kaynaklanır; hemen veterinerinize muayene ettirin.',
        ),
      ],
      commonMistakes: [
        CareMythFact(
          myth: 'Köpekler ter koktuğu için haftada bir yıkanmalıdır.',
          fact: 'Köpekler deriden terlemez. Sık yıkamak derinin koruyucu yağ tabakasını yok eder ve daha çok kötü koku üretmesine yol açar. İdeal olan ayda birdir.',
        ),
        CareMythFact(
          myth: 'Sıcak yaz günlerinde köpeği sıfıra tıraş ettirmek serinletir.',
          fact: 'Tüyler sadece soğuktan değil güneş sıcağından ve UV ışınlarından da koruyan bir klimadır. Sıfır tıraş güneş yanığına ve sıcak çarpmasına yol açar.',
        ),
        CareMythFact(
          myth: 'Kemik vermek köpeğin dişlerini doğal yolla temizler.',
          fact: 'Özellikle pişmiş kemikler cam gibi parçalanıp diş kırıklarına, damak ve bağırsak delinmelerine neden olur. Bunun yerine kauçuk dental oyuncaklar tercih edilmelidir.',
        ),
      ],
      defaultWeeklyChecklist: [
        'Haftalık tüy taraması ve keçe kontrolü yapıldı',
        'Kulak içi koklandı ve kir temizliği yapıldı',
        'Pati yastıkları ve tırnak uzunluğu kontrol edildi',
        'En az 2 kez diş fırçalama veya dental ödül verildi',
        'Kene ve pire için deri kontrolü yapıldı',
      ],
    );
  }

  // ==========================================
  // 🐱 KEDİ DETAYLI BAKIM REHBERİ
  // ==========================================
  static PetCareProfile _buildCatProfile(String name) {
    return PetCareProfile(
      petType: 'Kedi',
      introTitle: '$name İçin Sıfırdan Adım Adım Kedi Bakımı',
      introSubtitle: 'Temizliğiyle ünlü kediler için tüy yumağı önleme, kum hijyeni ve tırnak bakımı kılavuzu.',
      beginnerRules: [
        'Kediler uyanık kaldıkları sürenin %30-50\'sini kendilerini yalayarak temizlemeye ayırırlar. Çok zorunlu kalmadıkça (çamur, zehirli madde) ASLA yıkanmamalıdırlar.',
        'Yalanırken yutulan tüyler midede birikip bağırsak tıkanıklığı yapabilir. Düzenli tarama ve haftada 2-3 kez malt macunu vermek hayat kurtarır.',
        'Kedilerin kum kabı asla mama ve su kaplarının yanında olmamalıdır; doğaları gereği tuvalet ile besin alanını ayrı tutarlar.',
        'Pencere ve balkonlara dayanıklı kedi sinekliği/filesi taktırmak şarttır; "benim kedim çok dikkatli, düşmez" yanılgısı en yaygın kazadır.',
        'Zambak, paşa kılıcı, difenbahya gibi ev bitkileri kediler için ölümcül derecede zehirlidir; ev bitkilerini kontrol edin.',
      ],
      categories: [
        CareCategoryDetail(
          id: 'cat_brushing',
          title: 'Tüy Taraması & Tüy Yumağı (Malt)',
          subtitle: 'Kusmayı önleme, parlak kürk ve tüy döküm kontrolü',
          icon: Icons.auto_awesome_rounded,
          color: const Color(0xFF8E44AD),
          frequency: 'Kısa tüylüler için haftada 2 kez; Uzun tüylüler (British, Fars vb.) için her gün',
          whyImportant:
              'Kedilerin dillerinde zımpara benzeri geriye dönük minik kancalar (papilla) bulunur. Yalanırken dökülen tüyleri tüküremezler ve mecburen yutarlar. Yutulan tüyler midede birikerek tüy yumağına (bezoar/hairball) dönüşür; kusmaya veya cerrahi müdahale gerektiren bağırsak tıkanmalarına yol açabilir.',
          supplies: [
            'Silikon eldiven tarak veya ince telli kedi fırçası (Furminator/Slicker)',
            'Yüksek kaliteli malt macunu (Hairball paste)',
            'Kedi nanesi (Catnip) veya sıvı ödül maması',
          ],
          stepByStep: [
            '1. Adım - Sevme Moduyla Başlayın: $name uykuluyken veya mırıldarken çene altını ve başını severek başlayın.',
            '2. Adım - Önce Baş ve Yanaklar: Kediler kendi kokularını taşıyan yüz bölgelerinin taranmasından büyük keyif alırlar; ilk olarak oraları tarayın.',
            '3. Adım - Sırt ve Kuyruk Üstü: Nazik hareketlerle tüy çıkış yönünde fırçalayın. Asla tersten taramayın.',
            '4. Adım - Karın Bölgesi Hassasiyeti: Kedilerin karnı savunmasız bölgesidir. İzin vermiyorsa karnını zorlamayın; yan yatarken yavaşça tarayın.',
            '5. Adım - Malt Desteği: Tarama sonrası parmağınıza 2-3 cm malt macunu sıkıp yalatın; bu midedeki tüylerin dışkıyla güvenle atılmasını sağlar.',
          ],
          goldenRules: [
            'Kediniz kuyruğunu hızlıca yere vurmaya veya patisiyle itmeye başladıysa toleransı bitmiştir; hemen durun ve zorlamayın.',
            'Furminator gibi alt tüy bıçaklarını haftada 1 kereden fazla ve aynı noktaya dakikalarca uygulamayın (deriyi tahriş edebilir).',
          ],
          dangerWarnings: [
            'Kedilerde tüy topaklanmasını çözmek için asla makasla dibinden kesmeyin; kedi derisi çok elastiktir ve kumaş gibi makasın arasına girip kolayca kesilebilir.',
          ],
          vetTip:
              'Kediniz öğürüyor ama tüy çıkaramıyor, iştahı kesildi ve dışkı yapmıyorsa acilen veterinere gidin; bağırsak tıkanıklığı başlamış olabilir.',
        ),
        CareCategoryDetail(
          id: 'cat_nails',
          title: 'Tırnak Kesimi & Tırmalama',
          subtitle: 'Mobilya koruma, batık önleme ve tırmalama tahtası',
          icon: Icons.content_cut_rounded,
          color: const Color(0xFFE67E22),
          frequency: '2 - 3 haftada bir (Sadece ön patiler; arka patiler nadiren gerekir)',
          whyImportant:
              'Ev kedileri dışarıdaki gibi ağaç tırmalamadığı için tırnak kılıflarını tam dökemezler. Kesilmeyen tırnaklar uzayıp kıvrılarak pati yastığına batabilir ve enfeksiyon oluşturabilir.',
          supplies: [
            'Küçük boy kedi tırnak makası (Hilal ağızlı)',
            'Kedi tırmalama tahtası veya tırmalama kulesi',
            'Sıvı kedi ödül maması (Churu vb.)',
            'Mısır nişastası (Olası kanama için)',
          ],
          stepByStep: [
            '1. Adım - Patiye Dokunma Alıştırması: Kediniz kucağınızdayken patisini tutup hafifçe sıkma egzersizleri yapın ve ödüllendirin.',
            '2. Adım - Tırnağı Ortaya Çıkarma: Kedilerin tırnakları içe çekilebilirdir. Pati yastığının hemen üstüne ve altına parmağınızla hafifçe bastırdığınızda tırnak dışarı fırlar.',
            '3. Adım - Şeffaf Kısma Odaklanın: Kedi tırnağı şeffaftır ve içindeki pembe damar (quick) çok net görünür.',
            '4. Adım - Sadece Uçtaki Kanca: Pembe damara kesinlikle yaklaşmayın; sadece en uçtaki sivri ve iğne gibi olan 1-2 milimetrelik kavisli ucu kesin.',
            '5. Adım - Birkaç Seferde Bitirin: Tek oturuşta tüm tırnakları kesmek zorunda değilsiniz. Huysuzlanırsa 2 tırnak kesip bırakın.',
          ],
          goldenRules: [
            'Tırnak keserken kediyi kucağınıza sırtı size dönük olacak şekilde oturtmak en güvenli pozisyondur.',
            'Tırmalama tahtasını kedinin uyandığı yerin veya en çok sevdiği koltuğun hemen yanına koyun.',
          ],
          dangerWarnings: [
            'ASLA TIRNAK ÇIKARMA OPERASYONU (DECLAWING) YAPTIRMAYIN! Bu operasyon tırnak kesimi değil, kedinin parmak ucundaki son kemiğin ampute edilmesidir; ömür boyu sakatlık ve şiddetli kronik ağrı bırakır.',
          ],
          vetTip:
              'Eğer kediniz koltukları tırmalıyorsa ceza vermeyin; tırmalama kokusal ve görsel bir bölge işaretleme ihtiyacıdır. Oraya çift taraflı bant yapıştırıp yanına tırmalama tahtası koyun.',
        ),
        CareCategoryDetail(
          id: 'cat_litter',
          title: 'Kum Kabı & Tuvalet Hijyeni',
          subtitle: 'İdrar yolu sağlığı, kum temizliği ve koku önleme',
          icon: Icons.cleaning_services_rounded,
          color: const Color(0xFF27AE60),
          frequency: 'Her gün en az 1-2 kez kürekle temizlik; 2-3 haftada bir kumun tamamını yenileme',
          whyImportant:
              'Kediler aşırı temiz canlılardır. Kirli bir kum kabı kedide yoğun stres yaratır; bu da idrarını tutmasına ve ölümcül olan idrar yolu tıkanıklığına (FUS/FLUTD) veya eve idrar yapma davranışına yol açar.',
          supplies: [
            'Tozsuz bentonit veya doğal çam peleti / soya kumu',
            'Geniş ve sağlam kum küreği',
            'Kum paspası (patilere yapışan kumları tutmak için)',
            'Kokusuz sabun veya karbonat (kutu temizliği için)',
          ],
          stepByStep: [
            '1. Adım - Günlük Temizlik: Sabah ve akşam katı dışkı ve topaklanan çiş bloklarını kürekle eleyip atın.',
            '2. Adım - Kum Seviyesi: Kum kabında daima 6-8 cm derinlikte kum olmalıdır; az kum dibe yapışır, çok kum dışarı taşar.',
            '3. Adım - Komple Yıkama: 2-3 haftada bir kumu tamamen boşaltın. Kabı sıcak su ve kokusuz sabunla yıkayıp güneşte tamamen kurutun.',
            '4. Adım - Altın Kural (N+1): Evdeki kum kabı sayısı = Kedi sayısı + 1 olmalıdır (1 kedi için 2 kum kabı idealdir).',
          ],
          goldenRules: [
            'Kum kabını çamaşır makinesi yanı gibi gürültülü veya izbe yerlere değil, sessiz ve kaçış yolu açık alanlara koyun.',
            'Yoğun parfümlü kimyasal kokulu kumlar kedilerin hassas burnunu rahatsız eder; kokusuz doğal kumları tercih edin.',
          ],
          dangerWarnings: [
            'Kum kabını ASLA çamaşır suyu veya amonyakla yıkamayın! İdrarın içindeki amonyakla tepkimeye girip zehirli gaz üretir ve kediyi oradan kaçırır.',
            'Kediniz kum kabına sık gidip az işiyor veya acıyla miyavlıyorsa dakikalar içinde acil veteriner hekime gidilmelidir (özellikle erkek kedilerde idrar yolu tıkanması 24 saatte ölüme götürür).',
          ],
          vetTip:
              'Kediniz aniden kum kabı dışına çiş yapmaya başladıysa bu kesinlikle "intikam" veya "şımarıklık" değildir; %90 sistit (idrar yolu enfeksiyonu) ağrısı çekmektedir.',
        ),
        CareCategoryDetail(
          id: 'cat_ears_eyes',
          title: 'Göz & Kulak Bakımı',
          subtitle: 'Çapak temizliği, kulak uyuzu kontrolü',
          icon: Icons.remove_red_eye_rounded,
          color: const Color(0xFF3498DB),
          frequency: 'Haftada bir kontrol (Basık burunlu ırklarda her gün)',
          whyImportant:
              'Basık burunlu ırklarda (British, Scottish, İran) gözyaşı kanalları dardır; göz akıntısı deride lekelenme ve bakteriye yol açar. Kulak uyuzu ise kedilerde en sık görülen ve şiddetli kaşıntı yapan parazittir.',
          supplies: [
            'Steril serum fizyolojik (izotonik su)',
            'Makyaj pamuğu veya gazlı bez',
            'Veteriner onaylı kulak temizleme damlası',
          ],
          stepByStep: [
            '1. Adım - Göz Çapakları: Pamuğu ılık serum fizyolojik ile ıslatıp gözün iç köşesinden dışa doğru tek bir hareketle nazikçe silin.',
            '2. Adım - Kulak İçi İnceleme: Kulağı arkaya yatırıp içine bakın. Temiz bir kedi kulağı açık pembe ve kokusuzdur.',
            '3. Adım - Kir Varsa: Pamuğa 1 damla solüsyon damlatıp sadece kulağın kepçe kısmındaki görünen kiri nazikçe alın.',
          ],
          goldenRules: [
            'Her iki göz için asla aynı pamuğu kullanmayın; birindeki enfeksiyon diğerine geçer.',
          ],
          dangerWarnings: [
            'Kulağın derinliklerine asla çubuk sokmayın; kedinin kafa yapısı çok küçüktür, zarı çok yakındadır.',
            'Kulak içinde kahve telvesi gibi kuru siyah-kahverengi tortular varsa kulak uyuzudur; evde temizlenemez, özel ilaç damlası gerekir.',
          ],
          vetTip:
              'Gözde sarı/yeşil iltihaplı akıntı ve gözü kısma varsa kornea ülseri olabilir; çayla silmek yerine vakit kaybetmeden veterinere gösterin.',
        ),
      ],
      commonMistakes: [
        CareMythFact(
          myth: 'Kediler kirlenince ayda bir köpüklü banyo yaptırılmalıdır.',
          fact: 'Kediler yıkanmaktan aşırı stres olur, bağışıklıkları düşer ve derilerini kurutur. Kedi kendini yalayarak 7/24 steril tutar; banyoya gerek yoktur.',
        ),
        CareMythFact(
          myth: 'Evden hiç çıkmayan kedide pire veya iç parazit olmaz.',
          fact: 'Pire yumurtaları ve parazit larvaları sokaktan ayakkabı tabanımızla ve kıyafetlerimizle eve taşınır. Ev kedilerine de düzenli parazit damlası şarttır.',
        ),
        CareMythFact(
          myth: 'Kediler inek sütünü çok sever ve onlar için çok besleyicidir.',
          fact: 'Yetişkin kedilerde laktozu sindirecek enzim yoktur. İnek sütü şiddetli ishale, gaz sancısına ve bağırsak iltihabına yol açar. Asla süt verilmemelidir.',
        ),
      ],
      defaultWeeklyChecklist: [
        'Haftada en az 2-3 kez tüy taraması yapıldı',
        '2 kez parmakla tüy yumağı önleyici malt verildi',
        'Kum kabı her gün sabah-akşam temizlendi, kum tazelendi',
        'Göz ve kulak temizliği kontrol edildi',
        'Ön patilerin sivri tırnak uçları kontrol edildi',
      ],
    );
  }

  // ==========================================
  // 🦜 KUŞ DETAYLI BAKIM REHBERİ
  // ==========================================
  static PetCareProfile _buildBirdProfile(String name) {
    return PetCareProfile(
      petType: 'Kuş',
      introTitle: '$name İçin Sıfırdan Adım Adım Kuş Bakımı',
      introSubtitle: 'Muhabbet kuşu, papağan ve kanaryalar için hayati kafes düzeni, banyo ve gaga sağlığı.',
      beginnerRules: [
        'Kuşların solunum sistemi olağanüstü hassastır. Evde teflon tava dumanı, oda spreyi, parfüm, çamaşır suyu veya sigara dumanı kuşları dakikalar içinde zehirleyip öldürür.',
        'Kuşlar asla kafese hapsedilmemelidir; evde tüm cam ve kapılar kapalıyken her gün en az 1-2 saat güvenle uçmalıdırlar.',
        'Sadece yemle beslemek yetersizdir; kalamar kemiği, mineral blok, dal darı ve haftada 2 gün taze sebze/yeşillik (marul değil, brokoli, havuç) verilmelidir.',
        'Cere (burun) rengi, tüy parlaklığı ve dışkı kıvamı kuşun sağlığının en net aynasıdır; her sabah kafes tabanını kontrol edin.',
        'Kuşlar av hayvanı oldukları için hastalıklarını son ana kadar gizlerler; tünediğinde kabarıp gözlerini kapatıyorsa acil bir durumdur.',
      ],
      categories: [
        CareCategoryDetail(
          id: 'bird_bath',
          title: 'Banyo & Kanat Bakımı',
          subtitle: 'Kendi kendine banyo, tüylerin parlaması ve ferahlama',
          icon: Icons.water_drop_rounded,
          color: const Color(0xFF3498DB),
          frequency: 'Haftada 1-2 kez (Özellikle ılık havalarda ve tüy dökümünde)',
          whyImportant:
              'Kuşlar tüylerindeki toz ve kepeği atmak için banyoya ihtiyaç duyarlar. Banyo yapmak tüy köklerini rahatlatır, yeni çıkan tüylerin kılıflarından kolay çıkmasını sağlar ve parazitleri önler.',
          supplies: [
            'Kafese asılan kapalı kuş banyoluğu veya sığ seramik kase',
            'Oda sıcaklığında temiz içme suyu (1-2 cm derinlikte)',
            'İnce sisleme yapan temiz su püskürtücü (spreyleme)',
          ],
          stepByStep: [
            '1. Adım - Hazırlık: Banyoluğa en fazla 1.5 - 2 cm yüksekliğinde oda sıcaklığında içme suyu koyun (asla derin olmamalıdır).',
            '2. Adım - Asla Zorlamayın: Banyoluğu kafes kapısına takın veya masaya koyun. Kuşu asla elinizle tutup suya sokmayın; kendi merak edip girecektir.',
            '3. Adım - Püskürtme Alternatifi: Eğer suya girmiyorsa, temiz bir sprey şişesiyle 30-40 cm yukarıdan yağmur gibi havaya su sıkın, serpintiyle ıslansın.',
            '4. Adım - Cereyandan Koruyun: Islak kuşu ASLA rüzgar alan, pencere açık veya klima çalışan odaya koymayın; çok çabuk zatürre olurlar.',
            '5. Adım - Kurutma Makinesi YASAK: Saç kurutma makinesi kuşu yakabilir ve motorundaki teflon parçalar zehirler; kendi kendine kurumalıdır.',
          ],
          goldenRules: [
            'Banyo suyuna KESİNLİKLE sabun, şampuan veya sirke koymayın; sadece saf içme suyu olmalıdır.',
            'Banyoyu akşam değil, sabah veya öğle saatlerinde yaptırın ki uyku vaktine kadar tüyleri tamamen kurusun.',
          ],
          dangerWarnings: [
            'Kuşu lavabonun musluğunun altına tutup zorla yıkamayın; şoka girip kalp krizi geçirebilir.',
          ],
          vetTip:
              'Tüy döküm dönemlerinde banyo suyuna veterinerden alacağınız B-vitamini takviyesi eklemek yeni tüylerin güçlü ve parlak çıkmasını sağlar.',
        ),
        CareCategoryDetail(
          id: 'bird_cage',
          title: 'Kafes Hijyeni & Taban Temizliği',
          subtitle: 'Dışkı kontrolü, bakteri önleme ve suluk temizliği',
          icon: Icons.cleaning_services_rounded,
          color: const Color(0xFF27AE60),
          frequency: 'Taban kağıdı: 2 günde bir; Suluk: Her gün; Komple kafes: Haftada bir',
          whyImportant:
              'Kafes tabanında biriken nemli dışkılar koksidiyoz, mantar ve bakteri yuvasıdır. Kuşlar tabana inip dışkılı yemleri yediklerinde kursak iltihabı ve ölümcül ishallere yakalanırlar.',
          supplies: [
            'Kafes tabanı için ızgara ve ızgara altına beyaz havlu kağıt',
            'Doğal ahşap tünekler (Plastik tünekler ayak mantarı yapar!)',
            'Suluk fırçası ve sıcak su',
            'Kalamar kemiği ve mineral gaga taşı',
          ],
          stepByStep: [
            '1. Adım - Suluk Değişimi: Suluktaki suyu her gün dökün, suluğun içini fırçalayıp taze içme suyu doldurun (bekleyen su yosun ve bakteri üretir).',
            '2. Adım - Taban Kağıdı: Gazete kağıdı yerine desensiz beyaz havlu kağıt serin (gazete mürekkebi zehirlidir).',
            '3. Adım - Dışkı Gözlemi: Kağıdı atarken dışkıyı kontrol edin; yeşil/beyaz kıvamlı mı, ishal var mı inceleyin.',
            '4. Adım - Tünek Temizliği: Ahşap tüneklerin üzerindeki dışkıları sıcak su ve zımparayla haftalık olarak kazıyın.',
          ],
          goldenRules: [
            'Plastik tünekleri atıp yerine farklı kalınlıklarda doğal meyve ağacı dalları takın; kuşun ayak kaslarını çalıştırır ve tırnaklarını doğal törpüler.',
          ],
          dangerWarnings: [
            'Kafes temizliğinde çamaşır suyu veya kokulu deterjan kullanmayın; kokusundan bile zehirlenebilirler. Sadece sıcak su ve beyaz sirke kullanın.',
          ],
          vetTip:
              'Kalamar kemiği kuşların kalsiyum ihtiyacını karşılar ve gagasının aşırı uzamasını engeller; kafeste 365 gün mutlaka asılı olmalıdır.',
        ),
      ],
      commonMistakes: [
        CareMythFact(
          myth: 'Kuşlar mutfakta daha mutlu olur, yemek kokularını severler.',
          fact: 'Mutfak kuşlar için evdeki en tehlikeli yerdir. Isınan teflon tavalardan çıkan PTFE gazı kuşların ciğerlerini anında kanatarak öldürür.',
        ),
        CareMythFact(
          myth: 'Kuşa sadece hazır tohum yemi vermek yeterlidir.',
          fact: 'Sadece tohumla beslenen kuşlar karaciğer yağlanmasından erken ölür. Günlük beslenmesine brokoli, havuç, haşlanmış yumurta gibi ek besinler eklenmelidir.',
        ),
      ],
      defaultWeeklyChecklist: [
        'Suluk her gün taze içme suyuyla yenilendi',
        'Taban kağıdı değiştirildi ve dışkı kontrolü yapıldı',
        'Kalamar kemiği ve gaga taşı kontrol edildi',
        'Haftalık ılık su banyoluğu verildi',
        'Günde en az 1 saat oda içinde uçuruldu',
      ],
    );
  }

  // ==========================================
  // 🐰 TAVŞAN DETAYLI BAKIM REHBERİ
  // ==========================================
  static PetCareProfile _buildRabbitProfile(String name) {
    return PetCareProfile(
      petType: 'Tavşan',
      introTitle: '$name İçin Sıfırdan Adım Adım Tavşan Bakımı',
      introSubtitle: 'Tavşanların hassas sindirim sistemi, tüy bakımı ve kafessiz yaşam sırları.',
      beginnerRules: [
        'HAYATİ KURAL: Tavşanlar KESİNLİKLE SUYLA YIKANMAZ! Şoka girip kalp krizinden veya hipotermiden saatler içinde ölebilirler. Kendilerini kedi gibi yalarlar.',
        'Beslenmelerinin %80-85\'i sınırsız KURU OT (Timothy/Çayır otu) olmalıdır. Ot yemeyen tavşanın bağırsakları durur (GI Stasis) ve dişleri aşırı uzayıp kafatasına batar.',
        'Tavşanlar kusamazlar! Yalanırken yuttukları tüyleri geri çıkaramadıkları için düzenli taranmazlarsa mide tıkanmasından hayatlarını kaybederler.',
        'Tavşanları kulaklarından veya kollarının altından havaya kaldırmayın; arka bacaklarını desteklemezseniz omurgalarını kırabilirler.',
        'Evdeki tüm elektrik kablolarını koruma hortumuna alın; tavşanlar içgüdüsel olarak kablo kemirirler.',
      ],
      categories: [
        CareCategoryDetail(
          id: 'rabbit_hay',
          title: 'Kuru Ot & Diş Sağlığı',
          subtitle: 'Sonsuz kuru ot mucizesi ve diş aşınması',
          icon: Icons.grass_rounded,
          color: const Color(0xFF27AE60),
          frequency: 'Her saniye, 7/24 sınırsız taze çayır otu bulunmalıdır',
          whyImportant:
              'Tavşanların dişleri ömürleri boyunca sürekli uzar. Sadece sert lifli kuru otları birbirine sürterek çiğnediklerinde dişler doğal olarak aşınır. Kuru ot yemeyen tavşanlarda diş kökleri uzayarak göz çukuruna ve çene kemiğine batar.',
          supplies: [
            'Timothy (çayır) otu veya yulaf otu (Sonsuz miktarda)',
            'Geniş otluk veya ot sepeti (kum kabının üstüne konulmalı)',
            'Temiz elma ağacı kemirme dalları',
          ],
          stepByStep: [
            '1. Adım - Her Sabah Taze Ot: Otluktaki tozlaşmış otları temizleyip taze, yeşil ve mis gibi kokan kuru ot doldurun.',
            '2. Adım - Otluğu Tuvaletin Üstüne Koyun: Tavşanlar tuvaletlerini yaparken ot yemeyi çok severler; otluğu kum kabının hemen üstüne asarsanız tuvalet eğitimini %100 çözer.',
            '3. Adım - Pelet Yemi Sınırlandırın: Günde en fazla 1 yemek kaşığı kaliteli pelet yem verin; çok pelet yerse ot yemeyi bırakır.',
          ],
          goldenRules: [
            'Tavşanınız 12 saat boyunca hiçbir şey yemez ve dışkılamazsa bu ACİL VETERİNER durumudur (bağırsak durması).',
          ],
          dangerWarnings: [
            'Yetişkin tavşanlara sınırsız yonca (alfalfa) otu vermeyin; aşırı kalsiyum böbrek ve mesane taşı yapar. Timothy çayır otu verin.',
          ],
          vetTip:
              'Çizgi filmlerdeki gibi tavşana sürekli havuç verilmez; havuç şeker deposudur ve bağırsak florasını çökertir. Haftada bir parmak ucu kadar ödül olarak verilmelidir.',
        ),
        CareCategoryDetail(
          id: 'rabbit_brushing',
          title: 'Tüy Taraması & Tırnak',
          subtitle: 'Mide tıkanmasını önleme ve canlı damarlı tırnak kesimi',
          icon: Icons.content_cut_rounded,
          color: const Color(0xFF8E44AD),
          frequency: 'Haftada 2-3 kez; tüy dökümünde her gün',
          whyImportant:
              'Tavşanlar kusamayan canlılardır. Yuttukları tüy yumağını kediler gibi çıkaramazlar ve mideyi tıkayarak sindirimi kilitler. Düzenli tarama hayati öneme sahiptir.',
          supplies: [
            'Tavşanlar için yumuşak uçlu telli fırça veya kauçuk eldiven',
            'Küçük boy tırnak makası',
            'Fener (tırnak damarını görmek için)',
          ],
          stepByStep: [
            '1. Adım - Yerde Tarayın: Tavşanı yüksek masaya koymayın; aniden panikleyip atlayabilir. Yere yanına oturun.',
            '2. Adım - Nazikçe Fırçalama: Başından kuyruğuna doğru fazla bastırmadan dökülen pamuksu alt tüyleri toplayın.',
            '3. Adım - Popo Çevresi Tüy Dökümü: Mevsim geçişlerinde popo üstündeki gevşek tüy tutamlarını parmak uçlarınızla hafifçe çekerek alın.',
          ],
          goldenRules: [
            'Tavşan derisi kağıt gibi incedir; asla sert metal tarakları bastırarak çekmeyin.',
          ],
          dangerWarnings: [
            'TAVŞANI KESİNLİKLE BANYOYA VEYA SU DOLU LEĞENE SOKMAYIN! Islanan tavşan şoka girer ve kurutulamazsa hipotermiden hayatını kaybeder.',
          ],
          vetTip:
              'Dışkıların birbirine saç teli gibi bir iple bağlı çıktığını görürseniz tüy yutuyor demektir; taramayı hemen iki katına çıkarın.',
        ),
      ],
      commonMistakes: [
        CareMythFact(
          myth: 'Tavşanlar küçücük bir kafeste ömür boyu yaşayabilir.',
          fact: 'Kafes hapsi tavşanlarda omurga eğriliğine, depresyona ve ayak tabanı yaralarına yol açar. Tavşanlar evde serbestçe veya geniş oyun çitlerinde koşmalıdır.',
        ),
        CareMythFact(
          myth: 'Tavşan kokar.',
          fact: 'Tavşanın kendisi kokusuzdur; kokan şey temizlenmeyen tuvaletidir. Kum kabı düzenli temizlenen kısırlaştırılmış bir tavşan sıfır kokuya sahiptir.',
        ),
      ],
      defaultWeeklyChecklist: [
        'Ot kutusu her gün taze kuru otla dolduruldu',
        'Haftalık tüy taraması yapıldı, gevşek tüyler toplandı',
        'Tuvalet kabı temizlendi ve taze pelet serildi',
        'Dışkı boyutu ve yuvarlaklığı kontrol edildi',
        'Ayak tabanları (Sore hocks) kızarıklık için incelendi',
      ],
    );
  }

  // ==========================================
  // 🐹 HAMSTER & KEMİRGEN BAKIM REHBERİ
  // ==========================================
  static PetCareProfile _buildHamsterProfile(String name) {
    return PetCareProfile(
      petType: 'Hamster',
      introTitle: '$name İçin Sıfırdan Adım Adım Hamster Bakımı',
      introSubtitle: 'Gece aktif olan sevimli dostunuz için derin taban, çark ve kum banyosu rehberi.',
      beginnerRules: [
        'HAMSTERLAR ASLA SUYLA YIKANMAZ! Doğal temizliklerini özel kalsiyumsuz çöl kumu banyosunda yuvarlanarak yaparlar.',
        'Suriye hamsterları kesinlikle TEK YAŞAMALIDIR. Aynı kafese ikinci bir hamster koyarsanız sabaha kadar birbirlerini ölümcül şekilde yaralarlar.',
        'Kafes tabanında en az 15-20 cm kalınlığında tozsuz talaş/kağıt tabanlık olmalıdır; hamsterlar tünel kazarak yuva yapar.',
        'Koşu çarkı küçük olmamalıdır (en az 28 cm çap). Küçük çarklarda koşan hamsterın omurgası geriye doğru bükülür ve sakatlanır.',
        'Pamuk ve kumaş yuva malzemeleri YASAKTIR; ipleri ayaklarına dolanıp kangren yapabilir veya yutulup bağırsağı tıkayabilir.',
      ],
      categories: [
        CareCategoryDetail(
          id: 'hamster_sand',
          title: 'Kum Banyosu & Hijyen',
          subtitle: 'Su olmadan yağdan arınma ve tüy parlaklığı',
          icon: Icons.waves_rounded,
          color: const Color(0xFFE67E22),
          frequency: 'Kafeste 7/24 temiz bir kum kabı bulunmalıdır',
          whyImportant:
              'Hamsterların tüylerindeki fazla yağı ve kiri temizleme yöntemi kumda yuvarlanmaktır. Suya sokulduklarında kürklerindeki koruyucu tabaka yok olur ve hızla üşütüp zatürreden ölürler.',
          supplies: [
            'Hamster veya çinçilla özel banyo kumu (Kalsiyumsuz ve tozsuz)',
            'Seramik veya cam derin banyo kabı',
            'Elekli minik kum küreği',
          ],
          stepByStep: [
            '1. Adım - Kum Seçimi: Toz olmayan, tane yapılı banyo kumunu kabın içine 3-4 cm doldurun.',
            '2. Adım - Yuvarlanma: Hamster banyo kabına girip sırtüstü döner ve kumun tüylerinin arasına girmesini sağlar.',
            '3. Adım - Kum Temizliği: Kum kabını dışkıladığında küçük bir çay süzgeci veya elekle eleyip temizleyin.',
          ],
          goldenRules: [
            'Banyo kumunu asla kedi kumuyla karıştırmayın; kedi kumu kimyasal ve kokuludur.',
          ],
          dangerWarnings: [
            'Asla su dolu leğene koymayın, yıkamayın; hamsterlar suda panikler ve boğulma/zatürre riski çok yüksektir.',
          ],
          vetTip:
              'Hamsterınız gece uyanıp banyosunu yaptıktan sonra tüylerini tarar; tüylerinde yağlı bir görünüm varsa kumunu tazeleyin.',
        ),
      ],
      commonMistakes: [
        CareMythFact(
          myth: 'Hamsterlar küçücük plastik tüplü kafeslerde mutlu olur.',
          fact: 'Tüplü kafesler havalandırmasızdır ve küçüktür. Bir hamsterın en az 100x50 cm taban alanına ve 20 cm tünel kazma derinliğine ihtiyacı vardır.',
        ),
      ],
      defaultWeeklyChecklist: [
        'Banyo kumu elendi ve tazelendi',
        'Koşu çarkı nemli bezle silindi',
        'Taze içme suyu yenilendi',
        'Yuvasındaki bozulmuş taze sebze parçaları temizlendi',
      ],
    );
  }

  // ==========================================
  // 🐠 BALIK & AKVARYUM BAKIM REHBERİ
  // ==========================================
  static PetCareProfile _buildFishProfile(String name) {
    return PetCareProfile(
      petType: 'Balık',
      introTitle: '$name İçin Sıfırdan Adım Adım Akvaryum Bakımı',
      introSubtitle: 'Su kimyası, azot döngüsü ve doğru yemleme ile sağlıklı akvaryum yönetimi.',
      beginnerRules: [
        'HAYATİ HATA: Balıklar ASLA fanusta yaşayamaz! Fanusta filtre, ısıtıcı ve bakteri döngüsü kurulamaz; balık kendi dışkısının zehirlediği suda boğulur.',
        'Akvaryum temizlenirken suyun TAMAMI ASLA DEĞİŞTİRİLMEZ! Sadece haftada bir %20-25 su çekilir. Suyun tamamını değiştirmek faydalı bakterileri yok eder ve balığı şoka sokar.',
        'Akvaryuma musluktan direkt su konulmaz; şebeke suyundaki klor balıkların solungaçlarını yakar. Su en az 48 saat dinlendirilmeli veya su düzenleyici katılmalıdır.',
        'Balıklar açlıktan değil, aşırı yemlemeden ölürler! Balıklara günde 1-2 kez, 1 dakikada bitirebilecekleri kadar az yem verilmelidir.',
        'Filtre süngeri asla musluk suyuyla yıkanmaz; musluktaki klor filtredeki yararlı filtre bakterilerini öldürür. Akvaryumdan çektiğiniz eski suyla hafifçe sıkılmalıdır.',
      ],
      categories: [
        CareCategoryDetail(
          id: 'fish_water',
          title: 'Haftalık Su Değişimi & Dip Çekimi',
          subtitle: 'Amonyak patlamasını önleme ve su berraklığı',
          icon: Icons.water_rounded,
          color: const Color(0xFF3498DB),
          frequency: 'Haftada bir gün düzenli olarak %20 - %25 oranında',
          whyImportant:
              'Balıkların dışkıları ve yenmeyen yemler suda zehirli amonyak ve nitrata dönüşür. Düzenli kısmi su değişimi bu zehirleri uzaklaştırır ve balıkların solungaçlarını rahatlatır.',
          supplies: [
            'Dip sifonu (çakıl süpürgesi)',
            'Temiz sadece akvaryuma ayrılmış kova',
            'Dinlendirilmiş ve akvaryumla aynı sıcaklıkta su',
            'Su düzenleyici klor giderici damla',
          ],
          stepByStep: [
            '1. Adım - Ekipmanları Kapatın: Filtre ve ısıtıcının fişini çekin (ısıtıcı susuz kalırsa patlar).',
            '2. Adım - Dip Çekimi: Dip sifonunu kumların arasına daldırıp kirli suyu kovaya çekin (akvaryum suyunun %20\'sini çekince durun).',
            '3. Adım - Cam Temizliği: Camdaki yosunları mıknatıslı silecek veya süngerle temizleyin.',
            '4. Adım - Yeni Su Ekleme: En az 2 gün dinlendirilmiş ve sıcaklığı akvaryumla eşitlenmiş taze suyu yavaşça akvaryuma dökün.',
            '5. Adım - Filtreyi Çalıştırın: Filtre ve ısıtıcının fişini takıp çalıştığından emin olun.',
          ],
          goldenRules: [
            'Filtrenin içindeki süngeri musluk altında yıkamayın; akvaryumdan çektiğiniz kovanın içinde hafifçe 1-2 kez sıkıp geri takın.',
          ],
          dangerWarnings: [
            'Akvaryuma veya filtrelere ASLA sabun, deterjan veya kimyasal temizleyici değdirmeyin; tek bir damlası tüm balıkları öldürür.',
          ],
          vetTip:
              'Balıklarınız su yüzeyinde ağızlarını açıp hava yutmaya çalışıyorsa sudaki oksijen bitmiş veya amonyak zehirlenmesi başlamıştır; derhal %30 su değişimi yapıp filtre hava motorunu artırın.',
        ),
      ],
      commonMistakes: [
        CareMythFact(
          myth: 'Japon balığı fanusta mutlu yaşar.',
          fact: 'Japon balığı 30 cm boya ulaşabilen ve çok kirleten bir sazan türüdür. Fanus balığın gözlerini kör eder, organ gelişimini durdurur ve ömrünü 20 yıldan birkaç aya düşürür.',
        ),
      ],
      defaultWeeklyChecklist: [
        'Haftalık %20-25 dip çekimi ve su değişimi yapıldı',
        'Su sıcaklığı termometre ile kontrol edildi',
        'Filtrenin su debisi kontrol edildi',
        'Balıkların yüzgeçlerinde beyaz benek veya yırtık kontrolü yapıldı',
      ],
    );
  }
}
