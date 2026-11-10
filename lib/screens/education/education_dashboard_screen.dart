import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/global_state.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_language.dart';
import '../../services/ad_service.dart';

class EducationDashboardScreen extends StatefulWidget {
  @override
  _EducationDashboardScreenState createState() => _EducationDashboardScreenState();
}

class _EducationDashboardScreenState extends State<EducationDashboardScreen> {
  int _selectedPetIndex = 0;
  String _activeCategoryTab = 'Seçili Dost';
  String _activeTopicTab = 'Tümü';

  final List<String> _topics = [
    'Tümü',
    'Yemek & Beslenme',
    'Barınma & Güvenlik',
    'Yatma & Uyku',
    'Temel Eğitim',
    'Tuvalet Eğitimi',
  ];

  final Map<String, List<Map<String, String>>> _educationGuides = {
    'Köpek': [
      {
        'category': 'Yemek & Beslenme',
        'title': 'Beslenme Programı, Porsiyonlama ve Toksik Gıdalar',
        'desc': '• Yaşa Göre Öğün: Yavru köpekler (2-6 ay) günde 3-4 öğün, genç köpekler (6-12 ay) günde 3 öğün, 1 yaşından büyük yetişkin köpekler ise günde 2 öğün beslenmelidir.\n\n• Porsiyon Tayini: Mama paketinin arkasındaki ağırlık/gramaj tablosuna sadık kalın. Aşırı mama obeziteye ve eklem sorunlarına yol açar.\n\n• Su İhtiyacı: Taze, temiz içme suyu daima mama kabının yanında olmalı ve günde en az iki kez tazelenmelidir.\n\n• KESİNLİKLE YASAKLI GIDALAR:\n- Çikolata ve Kafein (Teobromin zehirlenmesi kalbi durdurabilir)\n- Soğan ve Sarımsak (Kırmızı kan hücrelerini parçalar)\n- Üzüm ve Kuru Üzüm (Böbrek yetmezliğine yol açar)\n- Pişmiş Tavuk/Kırmızı Et Kemiği (Mide ve bağırsağı deler)\n- Ksilitollü (sakız/tatlandırıcı) gıdalar (Karaciğer iflası yaratır).'
      },
      {
        'category': 'Barınma & Güvenlik',
        'title': 'Evde Güvenli Yaşam Alanı ve Yuva Kurulumu',
        'desc': '• Yatak Konumu: Köpeğin yatağı cereyandan, kapı arkasından ve direkt radyatör peteği yanından uzak olmalıdır. Ailenin varlığını hissedebileceği sakin bir salon köşesi en idealidir.\n\n• Ev Güvenliği Önlemleri:\n- Yerdeki elektrik kablolarını spiral plastik koruyuculara alın.\n- Zehirli ev bitkilerini (Difenbahya, Paşa Kılıcı, Açelya) yüksek raflara kaldırın.\n- Çöp kutusunun kapağını kilitli tutun (kemik veya plastik yutmasını önleyin).\n- Balkon parmaklıklarına kedi/köpek güvenlik filesi taktırın.'
      },
      {
        'category': 'Yatma & Uyku',
        'title': 'Gece Uyku Rutini ve Yatağına Alıştırma',
        'desc': '• Uyku Süresi: Yetişkin köpekler günde 12-14 saat, yavru köpekler ise gelişim için 18-20 saat uyur.\n\n• Gece Rutini: Akşam yatmadan 1-2 saat önce köpeğinizle uzun bir yürüyüş yapıp zihinsel enerjisini boşaltın. Yatmadan 2 saat önce mamayı, 1 saat önce suyu kaldırın.\n\n• Yatak Eğitimi: Yatağına her kendi isteğiyle gittiğinde "Yatağa Git" diyerek ödül maması verin. Gece yatağınızın kenarında sızlandığında sakin sesle sakinleştirin ancak yatağınıza çekerek alışkanlık yapmasına izin vermeyin.'
      },
      {
        'category': 'Temel Eğitim',
        'title': 'Otur, Bekle ve Çağrı (Gel) Komutları',
        'desc': '• "Otur" Komutu: Bir ödül mamasını burnunun hizasından yavaşça arkaya (kulaklarına doğru) götürün. Kafasını yukarı kaldırdıkça poposu doğal olarak yere değecektir. Yere değdiği an "Otur" deyin ve ödülü verin. Günde 5 dakikalık 2 seans çalışın.\n\n• "Bekle" Komutu: Otururken avucunuzu dur pozisyonunda gösterip 1 adım geri çekilin. Kıpırdamazsa 3 saniye sonra ödüllendirin. Mesafeyi zamanla açın.\n\n• "Gel" Komutu: Asla ceza vermek veya sevmediği bir işlemi (ilaç, banyo) yapmak için çağırmayın. Her geldiğinde coşkulu bir ses tonu ve ödülle karşılayın.'
      },
      {
        'category': 'Tuvalet Eğitimi',
        'title': 'Pedden Dışarı Tuvalet Rutinine Geçiş',
        'desc': '• Biyolojik Saatler: Yavru köpekler uykudan uyanır uyanmaz, mama yedikten 15-20 dakika sonra ve yoğun oyundan hemen sonra tuvalete ihtiyaç duyar.\n\n• Doğru Davranış: Bu saatlerde onu hemen tuvalet pedine veya bahçeye çıkarın. Tuvaletini yaptığı AN (bittiğinde değil, yaparken veya hemen sonrasında) "Aferin" diyerek yüksek ödüllü mama verin.\n\n• Kaza Anında: Asla burnunu pisliğe sürtmeyin veya bağırmayın! Ceza vermek sadece sizden korkup gizli köşelere yapmasına yol açar. Kazayı kokuyu nötralize eden enzimatik sirke/temizleyici ile silin.'
      },
    ],
    'Kedi': [
      {
        'category': 'Yemek & Beslenme',
        'title': 'Kuru ve Yaş Mama Dengesi, Su Tüketimini Artırma',
        'desc': '• Zorunlu Etobur: Kediler zorunlu etoburdur; tahılsız ve yüksek hayvansal proteinli mamalar tercih edilmelidir.\n\n• Yaş Mama Önemi: Kediler susama hissini az hissettikleri için böbrek hastalıklarına yatkındır. Haftada en az 2-3 porsiyon kaliteli yaş mama verilmelidir.\n\n• Su Kabı Kuralı: Su kabı mama kabının hemen yanına değil, en az 1-2 metre uzağa konmalıdır. Kediler içgüdüsel olarak avının yanındaki suyun kirlendiğini düşünür. Su şelalesi/çeşmesi su içme oranını 2 katına çıkarır.\n\n• KESİNLİKLE ZEHİRLİ: Zambak ve lilyum polenleri (böbreği saatler içinde iflas ettirir), soğan, sarımsak, çikolata, çiğ hamur mayası ve süt (laktoz yetişkin kedilerde şiddetli ishale yol açar).'
      },
      {
        'category': 'Barınma & Güvenlik',
        'title': 'Kedi Dostu Ev: Pencereler, Yüksek Alanlar ve Bitkiler',
        'desc': '• Dikey Alan İhtiyacı: Kediler yüksekte olmayı güvenli bulur. Kedi tırmalama kulesi, kitaplık üstü alanlar ve pencere kenarı yatakları kedinizin stresini sıfıra indirir.\n\n• Pencere ve Balkon Güvenliği: Standart sineklik telleri kedinin ağırlığıyla kolayca yırtılır veya yerinden fırlar. Mutlaka çelik tel örgü veya kedi güvenlik filesi kullanılmalıdır.\n\n• Zehirli Ev Bitkileri: Difenbahya, paşa kılıcı, aloe vera ve açelya kedi için zehirlidir. Bunların yerine kedi çimi (arpa/buğday çimi) yetiştirin.'
      },
      {
        'category': 'Yatma & Uyku',
        'title': 'Gece Koşturmacası (Zoomies) ve Uyku Düzeni',
        'desc': '• Uyku Döngüsü: Kediler günde ortalama 14-16 saat uyur. Doğaları gereği alacakaranlıkta (sabah erken ve gece geç saatlerde) avlanma moduna geçerler.\n\n• Gece Sakinleştirme Rutini: Yatmadan yarım saat önce olta veya lazer oyuncağıyla 15 dakika enerjisini attırın. Oyun biter bitmez küçük bir porsiyon yaş mama verin.\n• Biyolojik Formül: Avlanma -> Yemek Yeme -> Taranma -> Derin Uyku. Bu rutin kedinizin sabaha kadar mışıl mışıl uyumasını sağlayacaktır.'
      },
      {
        'category': 'Temel Eğitim',
        'title': 'Tırmalama Tahtası ve Çağrıya Yanıt Verme',
        'desc': '• Tırmalama Tahtası: Kediler pençelerini bilemek ve koku bırakmak için tırmalar. Koltuğu tırmalamaması için koltuğun hemen yanına dikey, sağlam sisal ip kütüğü koyun ve üzerine catnip (kedi nanesi) spreyi sıkın. Koltuğu tırmalamaya başladığında bağırmadan kucağınıza alıp tırmalama kütüğüne yönlendirin.\n\n• İsim Eğitimi: Adını sadece mama verirken veya severken melodik tonda tekrarlayın. Adına baktığı an ödüllendirin. Asla adını kızarken kullanmayın.'
      },
      {
        'category': 'Tuvalet Eğitimi',
        'title': 'Kum Kabı Sayısı, Kum Türü ve Temizlik Hijyeni',
        'desc': '• Altın Kural (N+1): Evdeki kedi sayısının 1 fazlası kadar kum kabı olmalıdır (1 kedi için 2 kap, 2 kedi için 3 kap).\n\n• Konum: Kum kabı çamaşır makinesi gürültüsünden, mama kabından ve ayak altından uzak, havadar ve mahrem bir yerde olmalıdır.\n\n• Kum Seçimi: Tozsuz, kokusuz doğal bentonit veya biyolojik çözünür pelet kumlar kedi burnunu tahriş etmez.\n\n• Temizlik: Her gün en az bir kez topaklar kürekle alınmalı, ayda bir kap tamamen yıkanıp taze kum konmalıdır.'
      },
    ],
    'Kuş': [
      {
        'category': 'Yemek & Beslenme',
        'title': 'Tohum, Taze Sebze-Meyve ve Mineral Desteği',
        'desc': '• Sadece Yem Yetmez: Yalnızca tohumla beslenen kuşlar karaciğer yağlanması sebebiyle genç yaşta hayatını kaybeder. Günlük beslenmenin %30’u taze sebze ve meyvelerden oluşmalıdır.\n\n• Güvenli Gıdalar: Havuç rendesi, brokoli, kırmızı biber, elma, armut, marul ve haşlanmış yumurta sarısı.\n\n• ÖLÜMCÜL TOKSİK: Avokado (içindeki persin maddesi kuşun kalbini anında durdurur!), soğan, sarımsak, elma ve kiraz çekirdekleri (siyanür içerir), tuzlu krakerler.\n\n• Kafes İçi Şartlar: Kalamar kemiği (kalsiyum kaynağı) ve mineral gaga taşı kafeste sürekli asılı olmalıdır.'
      },
      {
        'category': 'Barınma & Güvenlik',
        'title': 'Geniş Dikdörtgen Kafes ve Mutfak Tehlikesi',
        'desc': '• Kafes Geometrisi: Yuvarlak kafesler kuşların yön algısını bozar ve panikletir. Enine geniş, yatay telli dikdörtgen kafesler tercih edilmelidir (tırmanabilmesi için).\n\n• Mutfak Asla!: Kuş kafesi mutfakta TUTULAMAZ. Isınan teflon tavalardan salınan PTFE gazı ve fırın buharları kuşların solunum sistemini dakikalar içinde zehirler.\n\n• Konum: Kafes göz veya omuz hizasında, doğrudan pencere cereyanından ve klimadan uzak, en az bir tarafı duvara yaslanacak şekilde konulmalıdır.'
      },
      {
        'category': 'Yatma & Uyku',
        'title': '10-12 Saatlik Karanlık ve Sessiz Gece Düzeni',
        'desc': '• Sirkadiyen Ritim: Kuşların bağışıklığı ve hormon dengesi için her gün 10 ila 12 saat kesintisiz, zifiri karanlık ortamda uyuması şarttır.\n\n• Gece Terörü (Night Fright): Gece aniden kafeste çırpınmaya başlarsa loş bir ışık açıp sakin bir sesle "Buradayım, güvendesin" diyerek sakinleştirin.\n\n• Kafes Örtüsü: Akşam 20:00-21:00 gibi kafesin üzerine nefes alabilen pamuklu, koyu renk bir örtü örtün ve sessiz bir odaya alın.'
      },
      {
        'category': 'Temel Eğitim',
        'title': 'Ele Alıştırma ve Kelime Konuşma Eğitimi',
        'desc': '• Güven Adımları: Kuş yeni geldiyse ilk 3 gün kafesine dokunmayın. Sonraki günlerde elinizi kafes tellerinin dışından yaklaştırıp sakin ses tonuyla konuşun. Kafes içine elinizi soktuğunuzda kovalamayın; parmağınızı göğsünün altına doğru yaklaştırıp dal darı uzatın. Aç olduğunda parmağınıza tüneyecektir.\n\n• Konuşma Eğitimi: Sabah ilk uyandığı saatlerde veya akşam loş ışıkta tek bir kelimeyi (örn: "Aşkım", "Cici Kuş") yüksek enerji ve net bir tonlamayla 15-20 kez tekrarlayın.'
      },
      {
        'category': 'Tuvalet Eğitimi',
        'title': 'Kafes Taban Hijyeni ve Doğal Banyo',
        'desc': '• Taban Temizliği: Kafes taban ızgarasının altına mısır granülü veya havlu kağıt serin. Haftada en az 2 kez değiştirin. Asla gazete kağıdı sermeyin (mürekkep zehirler).\n\n• Kuş Banyosu: Kuşlar asla deterjan veya şampuanla yıkanmaz! Sığ bir kaba ılık içme suyu koyup kafes tabanına bırakın, yanına bir marul yaprağı koyun. İstemiyorsa asla zorlamayın, fısfıs şişesiyle uzaktan püskürtün.'
      },
    ],
    'Tavşan': [
      {
        'category': 'Yemek & Beslenme',
        'title': '%80 Saman Kuralı, Taze Otlar ve Sınırlı Pelet',
        'desc': '• Diyetin Temeli (%80): Tavşanın diyetinin yüzde sekseni sınırsız taze çayır samanı (kuru ot) olmalıdır. Saman sindirim sisteminin durmasını önler ve sürekli uzayan dişleri doğal olarak törpüler.\n\n• Yeşillikler: Dereotu, nane, fesleğen, marul ve karahindiba yaprakları günlük verilebilir.\n\n• Havuç Efsanesi: Havuç sanılanın aksine tavşanlar için yüksek şekerli bir ödüldür; haftada en fazla 1-2 ince dilim verilmelidir.\n\n• ZEHİRLİ: Çikolata, patates, fasulye, soğan, mısır ve ekmek/makarna gibi tahıllar tavşanın hassas bağırsak florasını çökertebilir.'
      },
      {
        'category': 'Barınma & Güvenlik',
        'title': 'Tavşan Korumalı Ev (Rabbit-Proofing) ve Geniş Alan',
        'desc': '• Kafese Mahkum Etmeyin: Tavşanlar dar kafeslerde yaşayamaz. En az 2-3 metrekarelik çocuk oyun çiti veya serbest oda yaşamı gereklidir.\n\n• Kablo Koruması: Tavşanlar dişlerini bilemek için kablo kemirir. Tüm elektrik kablolarını sert spiral kablo kanallarına alın.\n\n• Zemin Halısı: Kaygan laminat parkeler tavşanların eklemlerine zarar verir ve bacak kaymasına (splay leg) yol açar. Koşabileceği alanlara kaymaz halı veya kilim serin.'
      },
      {
        'category': 'Yatma & Uyku',
        'title': 'Gündüz Şekerlemeleri ve Flop Hareketi',
        'desc': '• Alacakaranlık Canlısı: Tavşanlar sabah erken ve gün batımında aktiftir, gündüzün büyük kısmını dinlenerek ve uyuyarak geçirirler.\n\n• Flop (Yana Devrilme): Tavşanınız aniden kendini yana sertçe atıp gözlerini kaparsa korkmayın; bu "Flop" hareketidir ve ortamda kendini %100 güvende hissettiğinin en büyük kanıtıdır.\n\n• Yuva: Yattığı köşeye içine girip saklanabileceği ahşap bir yuva kutusu veya yumuşak polar örtü koyun.'
      },
      {
        'category': 'Temel Eğitim',
        'title': 'Kucağa Alınma Korkusunu Yenme ve Sevgi Dili',
        'desc': '• Zorla Kucaklamayın: Tavşanlar av hayvanı oldukları için yerden havaya kaldırılmaktan yırtıcı kuş kapmış gibi dehşete düşerler. Onu kucağınıza almaya zorlamayın.\n\n• Halı Üzerinde Güven: Halıya uzanın ve yanına bir yaprak nane koyun. Merakla üzerinize gelmesini bekleyin. Sevmek için alnını iki kulağının arasından nazikçe okşayın, çenesine veya burnuna önden aniden elinizi uzatmayın.'
      },
      {
        'category': 'Tuvalet Eğitimi',
        'title': 'Samanlı Tuvalet Kabı Sistemi',
        'desc': '• Doğal Mekanizma: Tavşanlar saman yerken bağırsakları uyarılır ve tuvaletlerini yaparlar. Bu yüzden tuvalet kabı kedi tuvalet kabı şeklinde olmalı, tabanına talaş/pelet kum serilmeli ve kabın bir yarısına bol miktarda taze saman doldurulmalıdır.\n\n• Dışkıları Aktarma: Başlangıçta odaya düşürdüğü dışkıları peçeteyle toplayıp bu kabın içine atın. Kokuya alışınca birkaç günde sadece o kaba gidecektir.'
      },
    ],
    'Hamster': [
      {
        'category': 'Yemek & Beslenme',
        'title': 'Tohum Karışımı, Protein Takviyesi ve Zulalama',
        'desc': '• Temel Diyet: Kaliteli tohum, tahıl ve kuru sebze içeren hazır hamster yemleri verilmelidir.\n\n• Protein İhtiyacı: Haftada 1 kez haşlanmış yumurta akı parçası veya kurutulmuş un kurdu verilmelidir.\n\n• Yanak Kesesi Uyarısı: Hamsterlar yemleri yanaklarına doldurup yuvalarında saklarlar. Yuvalarındaki bozulabilecek taze sebze parçalarını haftada bir sessizce temizleyin.\n\n• YASAKLI: Portakal, mandalina gibi narenciyeler (asit mideyi yakar), soğan, sarımsak, çikolata ve yapışkan şekerli gıdalar (yanak kesesine yapışıp çürür).'
      },
      {
        'category': 'Barınma & Güvenlik',
        'title': 'Geniş Kafes (En az 80x50 cm) ve Derin Talaş',
        'desc': '• Alan Boyutu: Pet shoplarda satılan rengarenk minik kafesler hamsterlara işkencedir. Taban alanı en az 4000 cm² (80x50 cm) olan akvaryum veya geniş kutu kafesler kullanılmalıdır.\n\n• Tünel Kazma: Tabanına en az 15-20 cm kalınlığında tozsuz aspen talaşı veya kağıt taban kumu konmalıdır ki doğasındaki gibi derin tüneller kazabilsin.\n\n• Güvenli Çark: Suriye hamsterı için en az 28 cm, cüce hamsterlar için en az 20 cm düz zeminli tekerlek olmalıdır. Telli çarklar ayak kırar.'
      },
      {
        'category': 'Yatma & Uyku',
        'title': 'Gece Aktifliği ve Gündüz Derin Uykusu',
        'desc': '• Gececildir (Noktürnal): Hamsterlar gündüzleri derin uykudadır ve akşam 21:00-22:00 saatlerinden sonra uyanırlar.\n\n• Uykusundan Asla Uyandırmayın: Uyuyan bir hamsterı ellemeyin veya sarsmayın; kalp krizine girebilir veya korkudan ısırır.\n\n• Yuva Malzemesi: Pamuk vermeyin (bağırsağa dolanır veya bacağına dolanıp kangren yapar!). En güvenli yuva malzemesi desensiz, kokusuz beyaz tuvalet kağıdı veya peçete parçalarıdır.'
      },
      {
        'category': 'Temel Eğitim',
        'title': 'Ele Alıştırma (Taming) ve Isırma Kontrolü',
        'desc': '• İlk Hafta Sabır: Eve getirdiğiniz ilk 5-7 gün kafesine elinizi hiç sokmayın, sadece yem ve suyunu yenileyin.\n\n• Avuçtan Yemleme: Avucunuza bir adet çiğ ayçekirdeği koyun ve elinizi kafes tabanında düz, hareketsiz tutun. Merakla elinize basıp yemi almasına izin verin. Birkaç gün sonra avucunuza güvenle tırmanacaktır.'
      },
      {
        'category': 'Tuvalet Eğitimi',
        'title': 'Kalsiyumsuz Kum Banyosu ve Temizlik',
        'desc': '• ASLA SUYLA YIKANMAZ: Hamsterlar suyla yıkanırsa üşütüp zatürreden ölürler!\n\n• Kum Banyosu: Bir kabın içine kalsiyumsuz çöl kumu (şinşila banyo kumu) koyun. Kumun içine girip dönerek tüylerindeki fazla yağı ve kiri temizlerler.\n\n• Köşe Tuvaleti: Hamsterlar tuvaletlerini kafesin belirli tek bir köşesine yaparlar. O köşeye kum kabı koyarsanız temizliği çok kolaylaşır.'
      },
    ],
    'Balık': [
      {
        'category': 'Yemek & Beslenme',
        'title': '2 Dakika Kuralı ve Yem Çeşitliliği',
        'desc': '• Az Yem Hayat Kurtarır: Balık ölümlerinin %90’ı açlıktan değil, aşırı yemlemeden ve suyun amonyakla zehirlenmesinden kaynaklanır.\n\n• 2 Dakika Kuralı: Balıklarınıza günde 1 veya 2 kez, yalnızca 2 dakika içinde tüketebilecekleri kadar yem atın. Dibe çöken artık yemleri hemen kepçeyle toplayın.\n\n• Çeşitlilik: Pul yem, batan granül yem ve haftada 1 kez kurutulmuş kan kurdu / artemia ile besin değerlerini zenginleştirin.'
      },
      {
        'category': 'Barınma & Güvenlik',
        'title': 'Fanus Hatası, Filtreleme ve Isıtıcı Kurulumu',
        'desc': '• Fanusa Son Verin: Fanus balığın gözlerini bozar, oksijensiz bırakır ve bakteri dengesi tutmaz. En az 30-50 litrelik dikdörtgen cam akvaryum gereklidir.\n\n• Su Döngüsü (Azot Döngüsü): Akvaryuma su doldurulup filtre çalıştırıldıktan sonra balıklar hemen atılmaz; yararlı bakterilerin oturması için en az 1-2 hafta boş çalıştırılmalıdır.\n\n• Sabit Isı: Tropikal balıklar için 24-26°C sabit su ısıtıcısı şarttır. Ani ısı dalgalanmaları beyaz benek hastalığına yol açar.'
      },
      {
        'category': 'Yatma & Uyku',
        'title': 'Akvaryum Işık Düzeni ve Gece Karanlığı',
        'desc': '• Balıklar da Uyur: Balıkların göz kapağı yoktur ancak geceleri metabolizmalarını yavaşlatıp dinlenirler.\n\n• Işık Süresi: Akvaryum ışığı günde en fazla 8 saat açık kalmalıdır. Fazla ışık yeşil alg patlamasına ve balıklarda strese neden olur.\n\n• Gece Rutini: Gece mutlaka akvaryum lambasını kapatın. Balıklar bitki aralarında veya dipte hareketsiz durarak uyku moduna geçerler.'
      },
      {
        'category': 'Temel Eğitim',
        'title': 'Yemleme Rutinine ve Ele Alışma',
        'desc': '• Şartlandırma: Yem vermeden önce suyun üzerindeki cama hafifçe iki parmak vurun (aynı ritimle). Balıklar bu sesi yem ile bağdaştıracak ve ses gelince yüzeye toplanacaktır.\n\n• El Besleme: Zamanla parmağınızın ucundaki pul yemi su yüzeyinden doğrudan parmağınızdan yiyecek kadar güven kazanacaklardır.'
      },
      {
        'category': 'Tuvalet Eğitimi',
        'title': 'Haftalık Dip Çekimi ve Filtre Temizliği',
        'desc': '• Dip Çekimi: Her hafta akvaryum suyunun %20-25’ini dip süpürgesiyle kumun üzerindeki dışkıları emdirerek boşaltın. Asla tüm suyu tek seferde değiştirmeyin!\n\n• Dinlenmiş Su: Ekleyeceğiniz taze su, klorunun uçması için en az 48 saat ağzı açık kapta dinlendirilmiş ve akvaryumla aynı sıcaklıkta olmalıdır.\n\n• Filtre Yıkama Püf Noktası: Filtre süngerini musluk altında klorlu suda yıkamayın (bakteriler ölür). Akvaryumdan çektiğiniz kirli suyun içinde hafifçe sıkarak durulayın.'
      },
    ],
    'Diğer': [
      {
        'category': 'Yemek & Beslenme',
        'title': 'Canlı Türüne Özel Diyet ve Temiz Su',
        'desc': 'Her canlının metabolizması farklıdır. Canlınızın türüne uygun profesyonel yemler tercih edin, insan yiyeceklerinden uzak tutun ve suyunu her gün tazeleyin.'
      },
      {
        'category': 'Barınma & Güvenlik',
        'title': 'İdeal Sıcaklık, Nem ve Kaçış Güvenliği',
        'desc': 'Teraryum veya yaşam alanının canlının doğal ortamındaki nem ve sıcaklık değerlerine uyumlu olduğundan emin olun. Kaçış deliklerini kapatın.'
      },
      {
        'category': 'Yatma & Uyku',
        'title': 'Sirkadiyen Ritim ve Sessiz Ortam',
        'desc': 'Canlınızın gececil mi yoksa gündüzcül mü olduğunu öğrenin ve ışık döngüsünü buna göre düzenleyin.'
      },
      {
        'category': 'Temel Eğitim',
        'title': 'Güven Bağı ve Pozitif Pekiştirme',
        'desc': 'Canlıyı zorlamadan, ödül mamaları ve sakin yaklaşımlarla elinize ve varlığınıza alıştırın.'
      },
      {
        'category': 'Tuvalet Eğitimi',
        'title': 'Düzenli Alan Temizliği ve Hijyen',
        'desc': 'Yaşam alanındaki atıkları günlük olarak temizleyin ve aylık periyotlarla canlının sağlığına zarar vermeyecek doğal malzemelerle sterilize edin.'
      },
    ]
  };

  void _showAddPetModal() {
    final appLang = AppLanguage.of(context);
    final nameController = TextEditingController();
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
          }
        );
      }
    );
  }

  void _showActionModal({Map<String, dynamic>? training, int? index}) {
    final appLang = AppLanguage.of(context, listen: false);
    final titleController = TextEditingController(text: training != null ? appLang.translateDynamic(training['title']?.toString() ?? '') : '');
    final notesController = TextEditingController(text: training != null ? appLang.translateDynamic(training['notes']?.toString() ?? '') : '');
    String status = training != null ? (training['status']?.toString() ?? 'Planlandı') : 'Planlandı';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          training != null ? appLang.translate('edit_training') : appLang.translate('new_training'),
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        if (training != null && index != null)
                          IconButton(
                            tooltip: appLang.translate('delete'),
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 24),
                            onPressed: () {
                              final petName = GlobalState.pets[_selectedPetIndex]['name'];
                              setState(() {
                                if (GlobalState.trainings[petName] != null && index < GlobalState.trainings[petName]!.length) {
                                  GlobalState.trainings[petName]!.removeAt(index);
                                }
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(appLang.translate('delete'))),
                              );
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    TextField(controller: titleController, decoration: InputDecoration(labelText: appLang.translate('training_name_hint'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
                    SizedBox(height: 12.h),
                    TextField(controller: notesController, maxLines: 2, decoration: InputDecoration(labelText: appLang.translate('training_notes_hint'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
                    SizedBox(height: 16.h),
                    Text(appLang.translate('status'), style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8,
                      children: [
                        {'key': 'Planlandı', 'label': appLang.translate('status_planned'), 'color': Colors.grey},
                        {'key': 'Devam Ediyor', 'label': appLang.translate('status_in_progress'), 'color': const Color(0xFFF39C12)},
                        {'key': 'Tamamlandı', 'label': appLang.translate('status_completed'), 'color': const Color(0xFF27AE60)},
                      ].map((item) {
                        bool isSelected = status == item['key'];
                        Color color = item['color'] as Color;
                        return ChoiceChip(
                          label: Text(item['label'] as String, style: TextStyle(color: isSelected ? Colors.white : color)),
                          selected: isSelected,
                          selectedColor: color,
                          onSelected: (selected) {
                            if (selected) setModalState(() => status = item['key'] as String);
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final notes = notesController.text.trim();
                          if (title.isNotEmpty) {
                            setState(() {
                              Color c = status == 'Tamamlandı' ? const Color(0xFF27AE60) : status == 'Devam Ediyor' ? const Color(0xFFF39C12) : Colors.grey;
                              final petName = GlobalState.pets[_selectedPetIndex]['name'];
                              GlobalState.trainings.putIfAbsent(petName, () => []);
                              if (index != null && index < GlobalState.trainings[petName]!.length) {
                                GlobalState.trainings[petName]![index] = {'title': title, 'status': status, 'color': c, 'notes': notes};
                              } else {
                                GlobalState.trainings[petName]!.add({'title': title, 'status': status, 'color': c, 'notes': notes});
                              }
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00ACC1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                        child: Text(appLang.translate('save'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  void _showGuideDetailModal(Map<String, String> guide) {
    final appLang = AppLanguage.of(context, listen: false);
    final catColor = _getCategoryColor(guide['category'] ?? '');
    final catIcon = _getCategoryIcon(guide['category'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.w),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40.w, height: 5.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10.r))),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(color: catColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10.r)),
                    child: Icon(catIcon, color: catColor, size: 20),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(color: catColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8.r)),
                    child: Text(appLang.translateDynamic(guide['category'] ?? 'Rehber'), style: TextStyle(color: catColor, fontWeight: FontWeight.bold, fontSize: 11.5.sp)),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(appLang.translateGuideTitle(guide['title'] ?? ''), style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
              SizedBox(height: 14.h),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    appLang.translateGuideDesc(guide['title'] ?? '', guide['desc'] ?? ''),
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade800, height: 1.55),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: catColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r))),
                  child: Text(appLang.translateDynamic('Anladım, Harika!'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 6.h),
            ],
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('Yemek') || category.contains('Beslenme')) {
      return Icons.restaurant_rounded;
    } else if (category.contains('Barınma') || category.contains('Güvenlik')) {
      return Icons.cottage_rounded;
    } else if (category.contains('Yatma') || category.contains('Uyku')) {
      return Icons.bedtime_rounded;
    } else if (category.contains('Tuvalet')) {
      return Icons.clean_hands_rounded;
    } else if (category.contains('Eğitim') || category.contains('İtaat')) {
      return Icons.school_rounded;
    }
    return Icons.pets_rounded;
  }

  Color _getCategoryColor(String category) {
    if (category.contains('Yemek') || category.contains('Beslenme')) {
      return const Color(0xFFE65100);
    } else if (category.contains('Barınma') || category.contains('Güvenlik')) {
      return const Color(0xFF2E7D32);
    } else if (category.contains('Yatma') || category.contains('Uyku')) {
      return const Color(0xFF5E35B1);
    } else if (category.contains('Tuvalet')) {
      return const Color(0xFF0277BD);
    } else if (category.contains('Eğitim') || category.contains('İtaat')) {
      return const Color(0xFF00838F);
    }
    return const Color(0xFF00ACC1);
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedPetIndex >= GlobalState.pets.length) {
      _selectedPetIndex = 0;
    }
    final pet = GlobalState.pets.isNotEmpty ? GlobalState.pets[_selectedPetIndex] : {'name': 'Max', 'type': 'Köpek'};
    final petName = pet['name'] ?? 'Max';
    final petType = pet['type'] ?? 'Köpek';

    final trainings = GlobalState.trainings[petName] ?? [];

    String guideKey = petType;
    if (_activeCategoryTab != 'Seçili Dost') {
      guideKey = _activeCategoryTab;
    }
    List<Map<String, String>> guides = _educationGuides[guideKey] ?? _educationGuides['Diğer'] ?? [];

    if (_activeTopicTab != 'Tümü') {
      guides = guides.where((g) {
        final cat = g['category'] ?? '';
        if (_activeTopicTab == 'Yemek & Beslenme') return cat.contains('Yemek') || cat.contains('Beslenme');
        if (_activeTopicTab == 'Barınma & Güvenlik') return cat.contains('Barınma') || cat.contains('Güvenlik');
        if (_activeTopicTab == 'Yatma & Uyku') return cat.contains('Yatma') || cat.contains('Uyku');
        if (_activeTopicTab == 'Temel Eğitim') return cat.contains('Eğitim') || cat.contains('İtaat');
        if (_activeTopicTab == 'Tuvalet Eğitimi') return cat.contains('Tuvalet');
        return true;
      }).toList();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 16.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 20.h),
              _buildTitleCard(),
              SizedBox(height: 16.h),
              _buildPetSelector(),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${AppLanguage.of(context).translate('education_process')} ($petName)',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton.icon(
                    onPressed: () => _showActionModal(),
                    icon: const Icon(Icons.add, color: Colors.white, size: 16),
                    label: Text(AppLanguage.of(context).translate('add_target_btn'), style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00ACC1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                      minimumSize: Size.zero,
                    ),
                  )
                ],
              ),
              SizedBox(height: 14.h),
              if (trainings.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      AppLanguage.of(context).translateDynamic("Henüz bir eğitim hedefi eklenmedi."),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...trainings.asMap().entries.map((entry) => Padding(
                  padding: EdgeInsets.only(bottom: 12.0.h),
                  child: _buildTrainingCard(entry.value, entry.key),
                )),
              SizedBox(height: 24.h),
              Text(AppLanguage.of(context).translate('education_guides_title'), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
              SizedBox(height: 6.h),
              Text(AppLanguage.of(context).translate('education_guides_sub'), style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight)),
              SizedBox(height: 12.h),
              _buildCategoryTabs(),
              SizedBox(height: 10.h),
              _buildTopicFilterChips(),
              SizedBox(height: 14.h),
              if (guides.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Text(
                      AppLanguage.of(context).translateDynamic('Bu kategoride henüz rehber bulunamadı.'),
                      style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                    ),
                  ),
                )
              else
                ...guides.map((g) => Padding(
                  padding: EdgeInsets.only(bottom: 12.0.h),
                  child: _buildGuideCard(g),
                )),
              SizedBox(height: 20.h),
              const PatiBannerAdWidget(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final appLang = AppLanguage.of(context);
    final categories = ['Seçili Dost', 'Köpek', 'Kedi', 'Kuş', 'Tavşan', 'Hamster', 'Balık'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSel = _activeCategoryTab == cat;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(
                cat == 'Seçili Dost' ? appLang.translate('selected_pet') : appLang.translatePetType(cat),
                style: TextStyle(
                  color: isSel ? Colors.white : AppTheme.textDark,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
              selected: isSel,
              selectedColor: const Color(0xFF00ACC1),
              backgroundColor: Colors.white,
              onSelected: (s) {
                if (s) setState(() => _activeCategoryTab = cat);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopicFilterChips() {
    final appLang = AppLanguage.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _topics.map((t) {
          final isSel = _activeTopicTab == t;
          final color = _getCategoryColor(t);

          String label = t;
          if (t == 'Tümü') label = appLang.translate('all_filter');
          if (t == 'Yemek & Beslenme') label = appLang.translate('food_nutrition');
          if (t == 'Barınma & Güvenlik') label = appLang.translate('housing_safety');
          if (t == 'Yatma & Uyku') label = appLang.translate('sleep_rest');
          if (t == 'Temel Eğitim') label = appLang.translate('basic_training');
          if (t == 'Tuvalet Eğitimi') label = appLang.translate('toilet_training');

          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: FilterChip(
              label: Text(
                label,
                style: TextStyle(
                  color: isSel ? Colors.white : AppTheme.textDark,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  fontSize: 11.5.sp,
                ),
              ),
              selected: isSel,
              selectedColor: color,
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
                side: BorderSide(color: isSel ? Colors.transparent : Colors.grey.shade300, width: 0.8),
              ),
              onSelected: (selected) {
                setState(() {
                  _activeTopicTab = t;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final appLang = AppLanguage.of(context);
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 18),
          ),
        ),
        SizedBox(width: 12.w),
        const Icon(Icons.pets, color: Color(0xFF1B5E20), size: 28),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appLang.translate('app_title'), style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
            Text(appLang.translate('education_sub'), style: TextStyle(fontSize: 11.sp, color: AppTheme.textLight)),
          ],
        )
      ],
    );
  }

  Widget _buildTitleCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF00ACC1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 32),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLanguage.of(context).translate('education'), style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                SizedBox(height: 4.h),
                Text(AppLanguage.of(context).translate('education_sub'), style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, height: 1.3)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPetSelector() {
    return SizedBox(
      height: 65.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: GlobalState.pets.length + 1,
        itemBuilder: (context, index) {
          if (index == GlobalState.pets.length) {
            return GestureDetector(
              onTap: _showAddPetModal,
              child: Container(
                margin: EdgeInsets.only(left: 8.w, right: 16.w),
                width: 55.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: const Icon(Icons.add, color: AppTheme.primary, size: 28),
              ),
            );
          }

          final pet = GlobalState.pets[index];
          final isSelected = index == _selectedPetIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPetIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(right: 14.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  CircleAvatar(radius: 18.r, backgroundImage: GlobalState.getPetImage(pet['image'], pet['type'] ?? 'Köpek')),
                  SizedBox(width: 10.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pet['name'], style: TextStyle(color: isSelected ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                      Text(AppLanguage.of(context).translatePetType(pet['type']), style: TextStyle(color: isSelected ? Colors.white70 : AppTheme.textLight, fontSize: 10.5.sp)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrainingCard(Map<String, dynamic> training, int index) {
    final appLang = AppLanguage.of(context);
    Color cardColor = (training['color'] is Color) ? training['color'] : const Color(0xFF00ACC1);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () => _showActionModal(training: training, index: index),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(color: cardColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.check_circle_outline, color: cardColor, size: 26),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              appLang.translateDynamic(training['title'] ?? ''),
                              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Material(
                            color: const Color(0xFF00ACC1).withOpacity(0.12),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _showActionModal(training: training, index: index),
                              child: Padding(
                                padding: EdgeInsets.all(12.w),
                                child: const Icon(Icons.edit_rounded, color: Color(0xFF00ACC1), size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(appLang.translateDynamic(training['status'] ?? ''), style: TextStyle(fontSize: 12.5.sp, color: cardColor, fontWeight: FontWeight.bold)),
                      if (training['notes'] != null && training['notes'].toString().isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 6.0.h),
                          child: Text(appLang.translateDynamic(training['notes']), style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, height: 1.3)),
                        )
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

  Widget _buildGuideCard(Map<String, String> guide) {
    final appLang = AppLanguage.of(context);
    final catColor = _getCategoryColor(guide['category'] ?? '');
    final catIcon = _getCategoryIcon(guide['category'] ?? '');

    return InkWell(
      onTap: () => _showGuideDetailModal(guide),
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(color: catColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(catIcon, color: catColor, size: 22),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(color: catColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6.r)),
                    child: Text(appLang.translateDynamic(guide['category'] ?? ''), style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: catColor)),
                  ),
                  SizedBox(height: 6.h),
                  Text(appLang.translateGuideTitle(guide['title'] ?? ''), style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  SizedBox(height: 4.h),
                  Text(appLang.translateGuideDesc(guide['title'] ?? '', guide['desc'] ?? ''), style: TextStyle(fontSize: 12.sp, color: AppTheme.textLight, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
