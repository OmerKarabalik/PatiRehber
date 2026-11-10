import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalState {
  // Live user data (persisted to SharedPreferences)
  static List<Map<String, dynamic>> pets = [];
  static Map<String, List<Map<String, dynamic>>> vaccines = {};
  static Map<String, List<Map<String, dynamic>>> appointments = {};
  static Map<String, List<Map<String, dynamic>>> healthRecords = {};
  static Map<String, List<Map<String, dynamic>>> medications = {};
  static Map<String, List<Map<String, dynamic>>> weightHistory = {};
  static Map<String, List<Map<String, dynamic>>> symptoms = {};
  static Map<String, List<Map<String, dynamic>>> emergencyContacts = {};
  static Map<String, Map<String, dynamic>> nutritionPlans = {};
  static Map<String, List<Map<String, dynamic>>> trainings = {};
  static Map<String, List<Map<String, dynamic>>> behaviorIssues = {};

  // PatiPlus / Pro (Ad-free & Full access)
  static bool isPatiPlus = false;

  // Sample / Demo Data (available on demand via "Örnek Veriyle İncele")
  static final List<Map<String, dynamic>> sampleDemoPets = [
    {
      'id': 'pet_1',
      'name': 'Max',
      'type': 'Köpek',
      'breed': 'Golden Retriever',
      'gender': 'Erkek',
      'birthDate': '15.03.2023',
      'age': '3 Yaş',
      'weight': 24.5,
      'chipNo': '981098102938475',
      'isNeutered': true,
      'allergies': 'Tavuk Proteini',
      'bloodType': 'DEA 1.1+',
      'notes': 'Sıcak havalarda çabuk yorulur. Tüy döküm mevsiminde günde 2 kez taranmalı. Çok sevecen ve enerjik.',
      'image': 'assets/images/dog_avatar.png',
    },
    {
      'id': 'pet_2',
      'name': 'Luna',
      'type': 'Kedi',
      'breed': 'British Shorthair',
      'gender': 'Dişi',
      'birthDate': '10.06.2024',
      'age': '1.5 Yaş',
      'weight': 4.2,
      'chipNo': '981098109923812',
      'isNeutered': true,
      'allergies': 'Yok',
      'bloodType': 'A Grubu',
      'notes': 'Yaş mamayı çok seviyor. Akşamları hareketli oyunlar oynamayı tercih ediyor.',
      'image': 'assets/images/cat_avatar.png',
    },
    {
      'id': 'pet_3',
      'name': 'Maviş',
      'type': 'Kuş',
      'breed': 'Muhabbet Kuşu',
      'gender': 'Erkek',
      'birthDate': '01.01.2025',
      'age': '1 Yaş',
      'weight': 0.04,
      'chipNo': 'Bilezik: TR-2025-48',
      'isNeutered': false,
      'allergies': 'Yok',
      'bloodType': '-',
      'notes': 'Cici kuş ve Babacık kelimelerini söylüyor. Dal darı ödülü verildiğinde hemen ele geliyor.',
      'image': 'assets/images/bird_avatar.png',
    },
  ];

  static final Map<String, List<Map<String, dynamic>>> sampleDemoVaccines = {
    'Max': [
      {'title': 'Karma Aşı (DHPPi)', 'date': '15 Mart 2026', 'status': 'Tamamlandı', 'vet': 'Dr. Ayşe Yılmaz', 'notes': 'Aşı sonrası 1 gün dinlendirildi.', 'color': const Color(0xFF27AE60)},
      {'title': 'Kuduz Aşısı', 'date': '20 Nisan 2026', 'status': 'Tamamlandı', 'vet': 'Patili Klinik', 'notes': 'Yıllık tekrar yapıldı.', 'color': const Color(0xFF27AE60)},
      {'title': 'Lyme Aşısı', 'date': '10 Haziran 2026', 'status': 'Yaklaşan', 'vet': 'Dr. Ayşe Yılmaz', 'notes': 'Kene mevsimi öncesi planlandı.', 'color': const Color(0xFFF39C12)},
    ],
    'Luna': [
      {'title': 'Karma Aşı (FVRCP)', 'date': '12 Şubat 2026', 'status': 'Tamamlandı', 'vet': 'Dr. Mert Kaya', 'notes': '1. doz tamamlandı.', 'color': const Color(0xFF27AE60)},
      {'title': 'Kuduz Aşısı', 'date': '18 Mart 2026', 'status': 'Tamamlandı', 'vet': 'Dr. Mert Kaya', 'notes': 'Çip kaydıyla eşleştirildi.', 'color': const Color(0xFF27AE60)},
    ],
    'Maviş': [
      {'title': 'İç-Dış Parazit Damlası', 'date': '10 Ocak 2026', 'status': 'Tamamlandı', 'vet': 'Dr. Sema Ak', 'notes': 'Kanat altına 1 damla uygulandı.', 'color': const Color(0xFF27AE60)},
    ],
  };

  static final Map<String, List<Map<String, dynamic>>> sampleDemoAppointments = {
    'Max': [
      {
        'title': 'Genel Muayene & Check-up',
        'clinic': 'Patili Veteriner Kliniği',
        'location': 'Patili Veteriner Kliniği (Kadıköy)',
        'doctor': 'Dr. Ayşe Yılmaz',
        'date': '10 Mayıs 2026',
        'time': '14:00',
        'status': 'Yaklaşan',
        'hasAlarm': true,
        'reminder': '1 Gün Önce',
        'alarmLabel': 'Max Muayene Hatırlatıcı',
        'notes': 'Yıllık kan tahlilleri ve kulak kontrolü yapılacak.'
      },
    ],
    'Luna': [
      {
        'title': 'Diş Temizliği & Kontrol',
        'clinic': 'Kedi Dostu Sağlık Merkezi',
        'location': 'Kedi Dostu Sağlık Merkezi (Beşiktaş)',
        'doctor': 'Dr. Mert Kaya',
        'date': '22 Mayıs 2026',
        'time': '11:30',
        'status': 'Yaklaşan',
        'hasAlarm': true,
        'reminder': '3 Saat Önce',
        'alarmLabel': 'Luna Diş Randevusu',
        'notes': 'Hafif tartar başlangıcı kontrol edilecek.'
      }
    ],
    'Maviş': [],
  };

  static final Map<String, List<Map<String, dynamic>>> sampleDemoHealthRecords = {
    'Max': [
      {
        'title': 'Mide Hassasiyeti & Kusma',
        'date': '12 Ocak 2026',
        'doctor': 'Dr. Ayşe Yılmaz',
        'clinic': 'Patili Veteriner Kliniği',
        'notes': '2 gün boyunca kusma şikayeti ile gidildi. Gastrit teşhisi konuldu. Diyet mamaya geçildi.',
        'type': 'Muayene',
        'prescriptions': 'Mide Koruyucu Süspansiyon (5 gün), Gastrointestinal Diyet Mama',
        'nextControlDate': '25 Ocak 2026',
        'color': const Color(0xFFE74C3C)
      },
      {
        'title': 'Yıllık Kapsamlı Check-up',
        'date': '05 Kasım 2025',
        'doctor': 'Dr. Ayşe Yılmaz',
        'clinic': 'Patili Veteriner Kliniği',
        'notes': 'Kan değerleri normal. Karaciğer ve böbrek fonksiyonları mükemmel. Kilosu ideal.',
        'type': 'Check-up',
        'prescriptions': 'Omega-3 Balık Yağı Takviyesi',
        'nextControlDate': '05 Kasım 2026',
        'color': const Color(0xFF2ECC71)
      },
    ],
    'Luna': [
      {
        'title': 'Kısırlaştırma Operasyonu',
        'date': '20 Eylül 2025',
        'doctor': 'Dr. Mert Kaya',
        'clinic': 'Kedi Dostu Sağlık Merkezi',
        'notes': 'Laparoskopik kısırlaştırma yapıldı. Dikişler 10 gün sonra alındı, iyileşme sorunsuz.',
        'type': 'Ameliyat',
        'prescriptions': 'Ağrı Kesici Meloksikam, Yakalık',
        'nextControlDate': '30 Eylül 2025',
        'color': const Color(0xFF9B59B6)
      },
    ],
    'Maviş': [],
  };

  static final Map<String, List<Map<String, dynamic>>> sampleDemoMedications = {
    'Max': [
      {
        'title': 'Kalp Kurdu Hapı (NexGard Spectra)',
        'dosage': '1 tablet (Çiğneme)',
        'frequency': 'Ayda 1 kez',
        'nextTime': '15 Kasım 2026',
        'status': 'Aktif',
        'instructions': 'Tok karnına ödül gibi verilebilir.',
        'color': const Color(0xFFE67E22)
      },
      {
        'title': 'Omega-3 Somon Yağı',
        'dosage': '2 pompa',
        'frequency': 'Günde 1 kez',
        'nextTime': 'Her Sabah',
        'status': 'Aktif',
        'instructions': 'Sabah mamasına karıştırılacak.',
        'color': const Color(0xFF27AE60)
      },
    ],
    'Luna': [],
    'Maviş': [],
  };

  static final Map<String, List<Map<String, dynamic>>> sampleDemoWeightHistory = {
    'Max': [
      {'date': '15 Nisan 2026', 'weight': 24.5, 'diff': '+0.3 kg', 'notes': 'İdeal kilo'},
      {'date': '15 Mart 2026', 'weight': 24.2, 'diff': '-0.1 kg', 'notes': 'Düzenli egzersiz'},
    ],
    'Luna': [
      {'date': '10 Nisan 2026', 'weight': 4.2, 'diff': '+0.1 kg', 'notes': 'Kısır kedi standart'},
    ],
    'Maviş': [
      {'date': '01 Nisan 2026', 'weight': 0.040, 'diff': '0.0 kg', 'notes': 'Normal (40 gram)'},
    ],
  };

  static final Map<String, List<Map<String, dynamic>>> sampleDemoSymptoms = {
    'Max': [],
    'Luna': [],
    'Maviş': [],
  };

  static final Map<String, List<Map<String, dynamic>>> sampleDemoEmergencyContacts = {
    'Max': [
      {'title': 'Kendi Veterinerimiz', 'name': 'Dr. Ayşe Yılmaz (Patili Klinik)', 'phone': '0555 123 45 67', 'color': const Color(0xFFE74C3C)},
      {'title': '7/24 Nöbetçi Hayvan Hastanesi', 'name': 'Umut Acil Kliniği', 'phone': '0212 987 65 43', 'color': const Color(0xFFF39C12)}
    ],
    'Luna': [
      {'title': 'Kedi Hekimimiz', 'name': 'Dr. Mert Kaya', 'phone': '0532 999 88 77', 'color': const Color(0xFFE74C3C)},
    ],
    'Maviş': [],
  };

  static final Map<String, Map<String, dynamic>> sampleDemoNutritionPlans = {
    'Max': {
      'totalAmount': '420 g',
      'meals': 2,
      'foodType': 'Tahılsız Kuzu Etli Kuru Mama',
      'brand': 'Acana / ProPlan Sensitive',
      'morningTime': '08:00',
      'morningAmount': '210 g',
      'eveningTime': '18:00',
      'eveningAmount': '210 g',
      'notes': 'Tavuk içerikli hiçbir mama ve ödül verilmeyecek.'
    },
    'Luna': {
      'totalAmount': '65 g',
      'meals': 3,
      'foodType': 'Kısırlaştırılmış Somonlu Kuru Mama',
      'brand': 'Royal Canin Sterilised',
      'morningTime': '07:30',
      'morningAmount': '25 g',
      'eveningTime': '19:30',
      'eveningAmount': '40 g',
      'notes': 'Haftada 2 kez yaş mama ödülü verilir.'
    },
    'Maviş': {
      'totalAmount': '15 g',
      'meals': 1,
      'foodType': 'Karışık Tohum & Pelet Yem',
      'brand': 'Versele-Laga Prestige',
      'morningTime': '08:30',
      'morningAmount': '15 g',
      'eveningTime': '-',
      'eveningAmount': '-',
      'notes': 'Günde 1 dilim elma veya havuç rendesi takviye edilir.'
    },
  };

  static final Map<String, List<Map<String, dynamic>>> sampleDemoTrainings = {
    'Max': [
      {'title': 'Tuvalet Eğitimi', 'status': 'Tamamlandı', 'color': const Color(0xFF27AE60), 'notes': 'Dışarı alıştı.'},
      {'title': 'Temel İtaat (Otur / Bekle)', 'status': 'Tamamlandı', 'color': const Color(0xFF27AE60), 'notes': 'Komutlara uyuyor.'},
    ],
    'Luna': [],
    'Maviş': [],
  };

  static final Map<String, List<Map<String, dynamic>>> sampleDemoBehaviorIssues = {
    'Max': [],
    'Luna': [],
    'Maviş': [],
  };

  // -------------------------------------------------------------
  // PERSISTENCE (SharedPreferences JSON Storage)
  // -------------------------------------------------------------

  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSavedData = prefs.containsKey('pr_user_pets');

      if (!hasSavedData) {
        // First install: start clean with 0 pets
        pets = [];
        vaccines = {};
        appointments = {};
        healthRecords = {};
        medications = {};
        weightHistory = {};
        symptoms = {};
        emergencyContacts = {};
        nutritionPlans = {};
        trainings = {};
        behaviorIssues = {};
        await saveToDisk();
      } else {
        await loadFromDisk();
      }
    } catch (e) {
      debugPrint('GlobalState.initialize error: $e');
    }
  }

  static Future<void> saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pr_user_pets', jsonEncode(_serialize(pets)));
      await prefs.setString('pr_user_vaccines', jsonEncode(_serialize(vaccines)));
      await prefs.setString('pr_user_appointments', jsonEncode(_serialize(appointments)));
      await prefs.setString('pr_user_health_records', jsonEncode(_serialize(healthRecords)));
      await prefs.setString('pr_user_medications', jsonEncode(_serialize(medications)));
      await prefs.setString('pr_user_weight_history', jsonEncode(_serialize(weightHistory)));
      await prefs.setString('pr_user_symptoms', jsonEncode(_serialize(symptoms)));
      await prefs.setString('pr_user_emergency_contacts', jsonEncode(_serialize(emergencyContacts)));
      await prefs.setString('pr_user_nutrition_plans', jsonEncode(_serialize(nutritionPlans)));
      await prefs.setString('pr_user_trainings', jsonEncode(_serialize(trainings)));
      await prefs.setString('pr_user_behavior_issues', jsonEncode(_serialize(behaviorIssues)));
      await prefs.setBool('pr_is_pati_plus', isPatiPlus);
    } catch (e) {
      debugPrint('GlobalState.saveToDisk error: $e');
    }
  }

  static Future<void> loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final petsRaw = prefs.getString('pr_user_pets');
      if (petsRaw != null) {
        final decoded = jsonDecode(petsRaw) as List;
        pets = decoded.map((e) => Map<String, dynamic>.from(_deserialize(e) as Map)).toList();
      }

      final vaccinesRaw = prefs.getString('pr_user_vaccines');
      if (vaccinesRaw != null) {
        final decoded = jsonDecode(vaccinesRaw) as Map<String, dynamic>;
        vaccines = decoded.map((k, v) => MapEntry(k, (v as List).map((i) => Map<String, dynamic>.from(_deserialize(i) as Map)).toList()));
      }

      final apptRaw = prefs.getString('pr_user_appointments');
      if (apptRaw != null) {
        final decoded = jsonDecode(apptRaw) as Map<String, dynamic>;
        appointments = decoded.map((k, v) => MapEntry(k, (v as List).map((i) => Map<String, dynamic>.from(_deserialize(i) as Map)).toList()));
      }

      final recordsRaw = prefs.getString('pr_user_health_records');
      if (recordsRaw != null) {
        final decoded = jsonDecode(recordsRaw) as Map<String, dynamic>;
        healthRecords = decoded.map((k, v) => MapEntry(k, (v as List).map((i) => Map<String, dynamic>.from(_deserialize(i) as Map)).toList()));
      }

      final medsRaw = prefs.getString('pr_user_medications');
      if (medsRaw != null) {
        final decoded = jsonDecode(medsRaw) as Map<String, dynamic>;
        medications = decoded.map((k, v) => MapEntry(k, (v as List).map((i) => Map<String, dynamic>.from(_deserialize(i) as Map)).toList()));
      }

      final weightRaw = prefs.getString('pr_user_weight_history');
      if (weightRaw != null) {
        final decoded = jsonDecode(weightRaw) as Map<String, dynamic>;
        weightHistory = decoded.map((k, v) => MapEntry(k, (v as List).map((i) => Map<String, dynamic>.from(_deserialize(i) as Map)).toList()));
      }

      final nutritionRaw = prefs.getString('pr_user_nutrition_plans');
      if (nutritionRaw != null) {
        final decoded = jsonDecode(nutritionRaw) as Map<String, dynamic>;
        nutritionPlans = decoded.map((k, v) => MapEntry(k, Map<String, dynamic>.from(_deserialize(v) as Map)));
      }

      isPatiPlus = prefs.getBool('pr_is_pati_plus') ?? false;
    } catch (e) {
      debugPrint('GlobalState.loadFromDisk error: $e');
    }
  }

  static dynamic _serialize(dynamic val) {
    if (val is Color) {
      return {'__is_color__': true, 'value': val.toARGB32()};
    }
    if (val is Map) {
      return val.map((k, v) => MapEntry(k.toString(), _serialize(v)));
    }
    if (val is List) {
      return val.map(_serialize).toList();
    }
    return val;
  }

  static dynamic _deserialize(dynamic val) {
    if (val is Map && val['__is_color__'] == true) {
      return Color(val['value'] as int);
    }
    if (val is Map) {
      return val.map((k, v) => MapEntry(k.toString(), _deserialize(v)));
    }
    if (val is List) {
      return val.map(_deserialize).toList();
    }
    return val;
  }

  /// Populates standard sample demo data for inspection or testing
  static Future<void> loadSampleDemoData() async {
    pets = List<Map<String, dynamic>>.from(sampleDemoPets.map((p) => Map<String, dynamic>.from(p)));
    vaccines = Map.from(sampleDemoVaccines.map((k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v))));
    appointments = Map.from(sampleDemoAppointments.map((k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v))));
    healthRecords = Map.from(sampleDemoHealthRecords.map((k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v))));
    medications = Map.from(sampleDemoMedications.map((k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v))));
    weightHistory = Map.from(sampleDemoWeightHistory.map((k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v))));
    symptoms = Map.from(sampleDemoSymptoms.map((k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v))));
    emergencyContacts = Map.from(sampleDemoEmergencyContacts.map((k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v))));
    nutritionPlans = Map.from(sampleDemoNutritionPlans.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v))));
    trainings = Map.from(sampleDemoTrainings.map((k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v))));
    behaviorIssues = Map.from(sampleDemoBehaviorIssues.map((k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v))));
    await saveToDisk();
  }

  /// Completely clears all user pets and resets to clean installation state
  static Future<void> clearAllUserPets() async {
    pets = [];
    vaccines = {};
    appointments = {};
    healthRecords = {};
    medications = {};
    weightHistory = {};
    symptoms = {};
    emergencyContacts = {};
    nutritionPlans = {};
    trainings = {};
    behaviorIssues = {};
    await saveToDisk();
  }

  static Future<void> setPatiPlus(bool value) async {
    isPatiPlus = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pr_is_pati_plus', value);
    } catch (_) {}
  }

  static void removePet(int index) {
    if (index >= 0 && index < pets.length) {
      final pet = pets.removeAt(index);
      final petName = pet['name']?.toString() ?? '';
      vaccines.remove(petName);
      appointments.remove(petName);
      healthRecords.remove(petName);
      medications.remove(petName);
      weightHistory.remove(petName);
      symptoms.remove(petName);
      emergencyContacts.remove(petName);
      nutritionPlans.remove(petName);
      trainings.remove(petName);
      behaviorIssues.remove(petName);
      saveToDisk();
    }
  }

  static List<Map<String, dynamic>> getVaccinesForPet(String petName) {
    return (vaccines[petName] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  static List<Map<String, dynamic>> getHealthRecordsForPet(String petName) {
    return (healthRecords[petName] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  static List<Map<String, dynamic>> getAppointmentsForPet(String petName) {
    return (appointments[petName] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  static ImageProvider getPetImage(String? imagePath, [String petType = 'Köpek']) {
    if (imagePath != null && imagePath.trim().isNotEmpty) {
      if (imagePath.startsWith('assets/')) {
        return AssetImage(imagePath);
      }
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        return NetworkImage(imagePath);
      }
      try {
        final file = File(imagePath);
        if (file.existsSync()) {
          return FileImage(file);
        }
      } catch (_) {}
    }
    final lower = petType.toLowerCase();
    if (lower.contains('kedi')) {
      return const AssetImage('assets/images/cat_avatar.png');
    } else if (lower.contains('kuş') || lower.contains('kus')) {
      return const AssetImage('assets/images/bird_avatar.png');
    } else if (lower.contains('tavşan') || lower.contains('tavsan')) {
      return const AssetImage('assets/images/rabbit_avatar.png');
    } else if (lower.contains('hamster') || lower.contains('kemirgen')) {
      return const AssetImage('assets/images/hamster_avatar.png');
    } else if (lower.contains('balık') || lower.contains('balik')) {
      return const AssetImage('assets/images/fish_avatar.png');
    } else if (lower.contains('köpek') || lower.contains('kopek')) {
      return const AssetImage('assets/images/dog_avatar.png');
    }
    return const AssetImage('assets/images/pet_avatar.png');
  }

  static void addNewPet(
    String name, 
    String type, {
    String breed = 'Belirtilmedi',
    String gender = 'Erkek',
    String birthDate = '01.01.2024',
    String age = '1 Yaş',
    double weight = 5.0,
    String chipNo = '',
    bool isNeutered = false,
    String allergies = 'Yok',
    String bloodType = '-',
    String notes = '',
    String? image,
  }) {
    String imagePath;
    if (image != null && image.trim().isNotEmpty) {
      imagePath = image.trim();
    } else {
      final lower = type.toLowerCase();
      if (lower.contains('kedi')) {
        imagePath = 'assets/images/cat_avatar.png';
      } else if (lower.contains('kuş') || lower.contains('kus')) {
        imagePath = 'assets/images/bird_avatar.png';
      } else if (lower.contains('tavşan') || lower.contains('tavsan')) {
        imagePath = 'assets/images/rabbit_avatar.png';
      } else if (lower.contains('hamster') || lower.contains('kemirgen')) {
        imagePath = 'assets/images/hamster_avatar.png';
      } else if (lower.contains('balık') || lower.contains('balik')) {
        imagePath = 'assets/images/fish_avatar.png';
      } else if (lower.contains('köpek') || lower.contains('kopek')) {
        imagePath = 'assets/images/dog_avatar.png';
      } else {
        imagePath = 'assets/images/pet_avatar.png';
      }
    }

    pets.add({
      'id': 'pet_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'type': type,
      'breed': breed,
      'gender': gender,
      'birthDate': birthDate,
      'age': age,
      'weight': weight,
      'chipNo': chipNo.isEmpty ? 'TR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}' : chipNo,
      'isNeutered': isNeutered,
      'allergies': allergies,
      'bloodType': bloodType,
      'notes': notes,
      'image': imagePath,
    });
    
    vaccines[name] = [];
    appointments[name] = [];
    healthRecords[name] = [];
    medications[name] = [];
    symptoms[name] = [];
    emergencyContacts[name] = [];
    nutritionPlans[name] = {
      'totalAmount': '0 g',
      'meals': 2,
      'foodType': 'Belirtilmedi',
      'brand': '-',
      'morningTime': '08:00',
      'morningAmount': '0 g',
      'eveningTime': '19:00',
      'eveningAmount': '0 g',
      'notes': ''
    };
    trainings[name] = [];
    behaviorIssues[name] = [];
    weightHistory[name] = [
      {'date': 'Bugün', 'weight': weight, 'diff': 'İlk Kayıt', 'notes': 'Başlangıç kilosu'}
    ];

    saveToDisk();
  }

  static void updatePet(int index, Map<String, dynamic> updatedData) {
    if (index >= 0 && index < pets.length) {
      final oldName = pets[index]['name'];
      final newName = updatedData['name'] ?? oldName;

      pets[index] = {...pets[index], ...updatedData};

      if (oldName != newName) {
        vaccines[newName] = vaccines.remove(oldName) ?? [];
        appointments[newName] = appointments.remove(oldName) ?? [];
        healthRecords[newName] = healthRecords.remove(oldName) ?? [];
        medications[newName] = medications.remove(oldName) ?? [];
        symptoms[newName] = symptoms.remove(oldName) ?? [];
        emergencyContacts[newName] = emergencyContacts.remove(oldName) ?? [];
        nutritionPlans[newName] = nutritionPlans.remove(oldName) ?? {};
        trainings[newName] = trainings.remove(oldName) ?? [];
        behaviorIssues[newName] = behaviorIssues.remove(oldName) ?? [];
        weightHistory[newName] = weightHistory.remove(oldName) ?? [];
      }
      saveToDisk();
    }
  }

  static void toggleAppointmentAlarm(String petName, int index) {
    final list = appointments[petName];
    if (list != null && index >= 0 && index < list.length) {
      bool current = list[index]['hasAlarm'] ?? false;
      list[index]['hasAlarm'] = !current;
      saveToDisk();
    }
  }

  static void addWeightRecord(String petName, double weight, String note) {
    weightHistory.putIfAbsent(petName, () => []);
    final now = DateTime.now();
    final months = ['', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    final dateStr = '${now.day} ${months[now.month]} ${now.year}';
    
    double diff = 0.0;
    if (weightHistory[petName]!.isNotEmpty) {
      double lastWeight = (weightHistory[petName]!.first['weight'] as num).toDouble();
      diff = weight - lastWeight;
    }
    String diffStr = diff == 0 ? '0.0 kg' : (diff > 0 ? '+${diff.toStringAsFixed(1)} kg' : '${diff.toStringAsFixed(1)} kg');

    weightHistory[petName]!.insert(0, {
      'date': dateStr,
      'weight': weight,
      'diff': diffStr,
      'notes': note.isEmpty ? 'Kilo ölçümü' : note,
    });

    for (var pet in pets) {
      if (pet['name'] == petName) {
        pet['weight'] = weight;
        break;
      }
    }

    saveToDisk();
  }

  static List<Map<String, dynamic>> feedbackMessages = [];

  static void addFeedbackMessage(Map<String, dynamic> fb) {
    feedbackMessages.insert(0, fb);
  }
}
