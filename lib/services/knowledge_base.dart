import '../models/care_article_model.dart';
import '../models/sitter_model.dart';
import '../models/clinic_model.dart';

class KnowledgeBase {
  static List<ClinicModel> getClinics() {
    return const [
      ClinicModel(
        id: 'clinic_1',
        name: 'Pati 7/24 Acil Hayvan Hastanesi',
        type: 'Hayvan Hastanesi',
        city: 'İstanbul',
        district: 'Kadıköy',
        address: 'Caferağa Mah. Moda Cad. No: 42, Kadıköy',
        phone: '+90 216 333 4455',
        rating: 4.9,
        reviewsCount: 340,
        is24Hours: true,
        workingHours: '7/24 Açık',
        services: ['7/24 Acil', 'Cerrahi', 'Yoğun Bakım', 'Röntgen', 'Aşı'],
      ),
      ClinicModel(
        id: 'clinic_2',
        name: 'Boğaziçi Nöbetçi Veteriner Polikliniği',
        type: 'Poliklinik',
        city: 'İstanbul',
        district: 'Beşiktaş',
        address: 'Sinanpaşa Mah. Ihlamurdere Cad. No: 18, Beşiktaş',
        phone: '+90 212 222 7788',
        rating: 4.8,
        reviewsCount: 220,
        is24Hours: true,
        workingHours: '7/24 Açık',
        services: ['7/24 Acil', 'Laboratuvar', 'Ultrason', 'İç/Dış Parazit'],
      ),
      ClinicModel(
        id: 'clinic_3',
        name: 'Anadolu Veteriner Tıp Merkezi',
        type: 'Poliklinik',
        city: 'İstanbul',
        district: 'Üsküdar',
        address: 'Mimar Sinan Mah. Hakimiyeti Milliye Cad. No: 65, Üsküdar',
        phone: '+90 216 444 8899',
        rating: 4.7,
        reviewsCount: 185,
        is24Hours: false,
        workingHours: '08:30 - 23:00',
        services: ['Genel Muayene', 'Aşı', 'Diş Sağlığı', 'Kısırlaştırma'],
      ),
      ClinicModel(
        id: 'clinic_4',
        name: 'Başkent 7/24 Acil Hayvan Hastanesi',
        type: 'Hayvan Hastanesi',
        city: 'Ankara',
        district: 'Çankaya',
        address: 'Tunalı Hilmi Cad. No: 88, Çankaya',
        phone: '+90 312 444 1122',
        rating: 4.9,
        reviewsCount: 410,
        is24Hours: true,
        workingHours: '7/24 Açık',
        services: ['7/24 Acil', 'Ortopedi', 'Cerrahi', 'Doğum & Jinekoloji'],
      ),
      ClinicModel(
        id: 'clinic_5',
        name: 'Ege Nöbetçi Veteriner Kliniği',
        type: 'Klinik',
        city: 'İzmir',
        district: 'Karşıyaka',
        address: 'Cemal Gürsel Cad. No: 154, Karşıyaka',
        phone: '+90 232 333 9900',
        rating: 4.8,
        reviewsCount: 260,
        is24Hours: true,
        workingHours: '7/24 Açık',
        services: ['7/24 Acil', 'Yoğun Bakım', 'Aşı Takvimi', 'Kan Tahlili'],
      ),
      ClinicModel(
        id: 'clinic_6',
        name: 'Akdeniz Acil Hayvan Sağlık Merkezi',
        type: 'Hayvan Hastanesi',
        city: 'Antalya',
        district: 'Muratpaşa',
        address: 'Fener Mah. Lara Cad. No: 72, Muratpaşa',
        phone: '+90 242 321 6543',
        rating: 4.7,
        reviewsCount: 190,
        is24Hours: true,
        workingHours: '7/24 Açık',
        services: ['7/24 Acil', 'Sıcak Çarpması Müdahale', 'Cerrahi', 'Röntgen'],
      ),
      ClinicModel(
        id: 'clinic_7',
        name: 'Marmara Veteriner Polikliniği',
        type: 'Poliklinik',
        city: 'Bursa',
        district: 'Nilüfer',
        address: 'İhsaniye Mah. Fatih Sultan Mehmet Bulv. No: 91, Nilüfer',
        phone: '+90 224 240 1234',
        rating: 4.8,
        reviewsCount: 175,
        is24Hours: false,
        workingHours: '09:00 - 22:00',
        services: ['Aşı & Mikroçip', 'Laboratuvar', 'Genel Cerrahi', 'Beslenme Danışmanlığı'],
      ),
    ];
  }

  static List<SitterModel> getSitters() {
    return [
      SitterModel(
        id: '1',
        name: 'Ayşe Yılmaz',
        bio: '10 yıldır evcil hayvan bakıcılığı yapıyorum. Kediler ve köpekler benim dünyam!',
        hourlyRate: 150.0,
        services: ['Günlük Yürüyüş', 'Evde Bakım'],
        isApproved: true,
        city: 'İstanbul',
        district: 'Kadıköy',
        rating: 4.9,
        reviewsCount: 120,
        contactPhone: '+90 555 123 4567',
        avatarUrl: 'https://i.pravatar.cc/150?u=1',
      ),
      SitterModel(
        id: '3',
        name: 'Burak Demir (Gezdirici)',
        bio: 'Profesyonel Köpek Gezdiricisi. Enerjisi yüksek büyük ırklarla (Husky, Alman Kurdu) orman yürüyüşleri.',
        hourlyRate: 120.0,
        services: ['Köpek Gezdirme', 'Park Eğitimi'],
        isApproved: true,
        city: 'İstanbul',
        district: 'Beşiktaş',
        rating: 5.0,
        reviewsCount: 210,
        contactPhone: '+90 544 111 2233',
        avatarUrl: 'https://i.pravatar.cc/150?u=3',
      ),
    ];
  }

  static List<CareArticleModel> getArticlesByPetAndTopic(String petType, String topic) {
    // Generate dynamic articles based on combination to ensure no empty states.
    List<CareArticleModel> articles = [];

    // --- SAĞLIK ---
    if (topic == 'Sağlık') {
      articles.add(CareArticleModel(
        id: '${petType}_health_1',
        petType: petType,
        title: '$petType Sağlığında Dikkat Edilmesi Gereken 5 Kural',
        category: 'Veteriner & Aşı',
        summary: 'Rutin veteriner kontrolleri ve genel sağlık belirtileri.',
        content: '$petType türü hayvanların yılda en az bir kez genel muayeneden geçmesi şarttır. Dışkı kontrolü, tüy ve deri kalitesi sağlığın en büyük göstergesidir. İştahsızlık, halsizlik ve normal dışı sesler çıkarıldığında vakit kaybetmeden veterinerinize başvurmalısınız.',
        imageUrl: 'https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&q=80&w=800',
      ));
      if (petType == 'Köpek' || petType == 'Kedi') {
        articles.add(CareArticleModel(
          id: '${petType}_health_2',
          petType: petType,
          title: 'Aşı Takvimi ve İç/Dış Parazit',
          category: 'Aşı',
          summary: 'Karma, Kuduz ve Lösemi (Kediler için) aşılarının periyotları.',
          content: 'Yavruluktan itibaren başlayan aşı takvimi, hayvanın bağışıklık sistemini ölümcül hastalıklara karşı korur. Karma aşılar yavrulukta 3 doz, yetişkinlikte yılda 1 doz uygulanır. İç ve dış parazit uygulamaları ise yaşadığınız bölgenin risk durumuna göre 2 veya 3 ayda bir tekrarlanmalıdır.',
          imageUrl: 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?auto=format&fit=crop&q=80&w=800',
        ));
      }
    } 
    // --- BESLENME ---
    else if (topic == 'Beslenme') {
      articles.add(CareArticleModel(
        id: '${petType}_food_1',
        petType: petType,
        title: 'Doğru Mama Seçimi: $petType İçin Ne Almalı?',
        category: 'Mama Önerileri',
        summary: 'Tahılsız, yüksek proteinli veya bitkisel beslenme dengesi.',
        content: '$petType için mama seçerken yaş, kilo, kısırlaştırma durumu ve ırk özellikleri göz önünde bulundurulmalıdır. İçindekiler listesinde ilk sırada et/protein kaynağı olduğundan emin olun (kediler ve köpekler için). Kuş ve kemirgenler için ise tohum çeşitliliği ve peletlenmiş taze yemler tercih edilmelidir.',
        imageUrl: 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?auto=format&fit=crop&q=80&w=800',
      ));
      articles.add(CareArticleModel(
        id: '${petType}_food_2',
        petType: petType,
        title: 'Ödül Mamaları ve Ek Takviyeler',
        category: 'Besin Takviyesi',
        summary: 'Eğitim sırasında verilebilecek sağlıklı ödüller.',
        content: 'Ödül mamaları günlük kalori ihtiyacının %10\'unu geçmemelidir. $petType eğitimlerinde pozitif pekiştirme için küçük parçalara ayrılabilen, kokusu cazip ve sağlıklı içerikli (örneğin kurutulmuş et veya doğal tohumlar) ödüller kullanabilirsiniz.',
        imageUrl: 'https://images.unsplash.com/photo-1623366302587-bca978019a51?auto=format&fit=crop&q=80&w=800',
      ));
    }
    // --- BAKIM ---
    else if (topic == 'Bakım') {
      articles.add(CareArticleModel(
        id: '${petType}_care_1',
        petType: petType,
        title: 'Tüy, Deri ve Tırnak Bakımı',
        category: 'Tıraş & Temizlik',
        summary: 'Düzenli tarama ve hijyenik yaşam alanı sağlama.',
        content: '$petType dostunuzun tüylerini düzenli taramak hem deri havalandırmasını sağlar hem de aranızdaki bağı güçlendirir. Tırnak kesimi, eğer doğal yollarla (yürüyüş, tünek) törpülenmiyorsa veteriner hekim veya uzman pet kuaförleri tarafından yapılmalıdır. Göz ve kulak temizliğine haftalık olarak dikkat edilmelidir.',
        imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&q=80&w=800',
      ));
    }
    // --- EĞİTİM ---
    else if (topic == 'Eğitim') {
      articles.add(CareArticleModel(
        id: '${petType}_train_1',
        petType: petType,
        title: '$petType Davranış Problemleri ve Çözümleri',
        category: 'Davranış & Eğitim',
        summary: 'Stres, ısırma ve tuvalet sorunlarına modern yaklaşımlar.',
        content: 'Hiçbir hayvan sebepsiz yere agresyon göstermez. $petType dostunuzun temel ihtiyaçlarının (hareket, ilgi, doğru beslenme) karşılandığından emin olun. Tuvalet eğitiminde asla cezalandırma yöntemini kullanmayın. Yanlış yapılan yeri kokusuzlaştırıcı enzimlerle temizleyin ve doğru yeri kullandığında büyük ödüller verin.',
        imageUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?auto=format&fit=crop&q=80&w=800',
      ));
    }
    // --- DAVRANIŞ ---
    else if (topic == 'Davranış') {
      articles.add(CareArticleModel(
        id: '${petType}_behavior_1',
        petType: petType,
        title: '$petType Psikolojisi ve Karakter Analizi',
        category: 'Karakter & Uyum',
        summary: 'Korku, kaygı ve uyum süreçlerini yönetmek.',
        content: '$petType dostlarımızın davranışları çoğu zaman bize ihtiyaçlarını anlatma şekilleridir. Eve yeni gelen bir hayvanın adaptasyon süreci sabır gerektirir. Agresif veya aşırı çekingen davranışlar sergilediğinde cezalandırmak yerine temelinde yatan korku unsurunu bulup güven inşası yapmak gerekir.',
        imageUrl: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&q=80&w=800',
      ));
    }
    // --- ALIŞVERİŞ ---
    else if (topic == 'Alışveriş') {
      articles.add(CareArticleModel(
        id: '${petType}_shop_1',
        petType: petType,
        title: 'En Çok Tercih Edilen $petType Ürünleri',
        category: 'Ürün Önerileri',
        summary: 'Yatak, oyuncak, taşıma çantası ve kafes/akvaryum ekipmanları.',
        content: 'Alışveriş yaparken hayvanın ergonomisi çok önemlidir. Kalitesiz plastiklerden yapılmış oyuncaklar toksik olabilir. $petType için BPA içermeyen silikon, doğal ahşap veya onaylı seramik ürünleri tercih edin. Doğru boyutta bir taşıma çantası / kafes, veteriner ziyaretlerindeki stresi yarı yarıya azaltacaktır.',
        imageUrl: 'https://images.unsplash.com/photo-1585559700398-1385b3a8aeb6?auto=format&fit=crop&q=80&w=800',
      ));
    }
    
    // Fallback if none match
    if (articles.isEmpty) {
      articles.add(CareArticleModel(
        id: '${petType}_general_1',
        petType: petType,
        title: '$petType Hakkında Bilmeniz Gerekenler',
        category: 'Genel Bilgi',
        summary: 'Yakında eklenecek profesyonel içerikler...',
        content: 'Bu bölüm uzman veteriner hekimlerimiz tarafından güncellenmektedir.',
        imageUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&q=80&w=800',
      ));
    }

    return articles;
  }
}

