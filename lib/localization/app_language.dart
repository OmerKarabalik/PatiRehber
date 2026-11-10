import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'guide_translations.dart';

class LanguageModel {
  final String code;
  final String name;
  final String flag;

  const LanguageModel({required this.code, required this.name, required this.flag});
}

class AppLanguage extends ChangeNotifier {
  static const String _prefKey = 'selected_language';
  String _currentLanguage = 'tr';

  String get currentLanguage => _currentLanguage;

  static const List<LanguageModel> supportedLanguages = [
    LanguageModel(code: 'tr', name: 'Türkçe', flag: '🇹🇷'),
    LanguageModel(code: 'de', name: 'Deutsch', flag: '🇩🇪'),
    LanguageModel(code: 'ru', name: 'Русский', flag: '🇷🇺'),
    LanguageModel(code: 'en', name: 'English', flag: '🇬🇧'),
    LanguageModel(code: 'fr', name: 'Français', flag: '🇫🇷'),
    LanguageModel(code: 'es', name: 'Español', flag: '🇪🇸'),
    LanguageModel(code: 'it', name: 'Italiano', flag: '🇮🇹'),
  ];

  LanguageModel get currentLanguageModel {
    return supportedLanguages.firstWhere(
      (l) => l.code == _currentLanguage,
      orElse: () => supportedLanguages.first,
    );
  }

  static void showLanguageModal(BuildContext context) {
    final appLanguage = AppLanguage.of(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.language_rounded, color: Color(0xFFE67E22), size: 24),
                    const SizedBox(width: 10),
                    Text(
                      appLanguage.translate('language_selection'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Multi-Language (TR, DE, RU, EN, FR, ES)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: AppLanguage.supportedLanguages.length,
                    itemBuilder: (context, index) {
                      final lang = AppLanguage.supportedLanguages[index];
                      final isSelected = appLanguage.currentLanguage == lang.code;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE67E22).withValues(alpha: 0.1) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isSelected ? const Color(0xFFE67E22) : Colors.grey.shade200, width: 1.2),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: Text(lang.flag, style: const TextStyle(fontSize: 26)),
                            title: Text(lang.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2C3E50))),
                            subtitle: Text(lang.code.toUpperCase(), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFFE67E22)) : null,
                            onTap: () {
                              appLanguage.changeLanguage(lang.code);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFFE67E22),
                                  content: Text('${lang.flag} ${lang.name} seçildi / Selected'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget buildLanguagePill(BuildContext context) {
    final appLanguage = AppLanguage.of(context, listen: true);
    final currentLang = appLanguage.currentLanguageModel;

    return InkWell(
      onTap: () => showLanguageModal(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(currentLang.flag, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 3),
              Text(
                currentLang.code.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.arrow_drop_down_rounded, size: 15, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  static AppLanguage of(BuildContext context, {bool listen = false}) {
    try {
      return Provider.of<AppLanguage>(context, listen: listen);
    } catch (_) {
      return Provider.of<AppLanguage>(context, listen: false);
    }
  }

  Future<void> loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null && supportedLanguages.any((l) => l.code == saved)) {
        _currentLanguage = saved;
        notifyListeners();
      }
    } catch (_) {}
  }

  String translateGuideTitle(String title) {
    if (_currentLanguage == 'tr') return title;
    return GuideTranslations.getEducationTitle(title, _currentLanguage);
  }

  String translateGuideDesc(String title, String defaultDesc) {
    if (_currentLanguage == 'tr') return defaultDesc;
    return GuideTranslations.getEducationDesc(title, _currentLanguage, defaultDesc);
  }

  String translateBehaviorTitle(String title) {
    if (_currentLanguage == 'tr') return title;
    return GuideTranslations.getBehaviorTitle(title, _currentLanguage);
  }

  String translateBehaviorDesc(String title, String defaultDesc) {
    if (_currentLanguage == 'tr') return defaultDesc;
    return GuideTranslations.getBehaviorDesc(title, _currentLanguage, defaultDesc);
  }

  String translateCareDesc(String title, String petType, String petName, String defaultDesc) {
    if (_currentLanguage == 'tr') return defaultDesc;
    return GuideTranslations.getCareInfo(title, _currentLanguage, petType, petName);
  }

  Future<void> changeLanguage(String langCode) async {
    if (_currentLanguage == langCode) return;
    _currentLanguage = langCode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, langCode);
    } catch (_) {}
  }

  // Localized Brand Name (e.g. PatiRehber, PawGuide, PfotenGuide, PatiGuide, PatiGuía, ЛапаГид)
  String get brandPrefix {
    final val = translate('brand_prefix');
    if (val != 'brand_prefix' && val.isNotEmpty) return val;
    switch (_currentLanguage) {
      case 'en': return 'Paw';
      case 'de': return 'Pfoten';
      case 'fr': return 'Pati';
      case 'es': return 'Pati';
      case 'it': return 'Pati';
      case 'ru': return 'Лапа';
      case 'tr':
      default: return 'Pati';
    }
  }

  String get brandSuffix {
    final val = translate('brand_suffix');
    if (val != 'brand_suffix' && val.isNotEmpty) return val;
    switch (_currentLanguage) {
      case 'en': return 'Guide';
      case 'de': return 'Guide';
      case 'fr': return 'Guide';
      case 'es': return 'Guía';
      case 'it': return 'Guida';
      case 'ru': return 'Гид';
      case 'tr':
      default: return 'Rehber';
    }
  }

  String translate(String key) {
    final langMap = _translations[_currentLanguage] ?? _translations['tr']!;
    if (langMap.containsKey(key)) {
      return langMap[key]!;
    }
    // Fallback to Turkish or English
    return _translations['tr']?[key] ?? _translations['en']?[key] ?? key;
  }

  // Dynamic currency & localized pricing
  String get priceSinglePdf {
    switch (_currentLanguage) {
      case 'en':
        return '\$2.99';
      case 'de':
      case 'fr':
      case 'es':
        return '2,99 €';
      case 'ru':
        return '249 ₽';
      case 'tr':
      default:
        return '49.99 ₺';
    }
  }

  String get priceCoffee {
    switch (_currentLanguage) {
      case 'en':
        return '\$1.99';
      case 'de':
      case 'fr':
      case 'es':
        return '1,99 €';
      case 'ru':
        return '149 ₽';
      case 'tr':
      default:
        return '29.99 ₺';
    }
  }

  String get pricePatiPlus {
    switch (_currentLanguage) {
      case 'en':
        return '\$4.99';
      case 'de':
      case 'fr':
      case 'es':
        return '4,99 €';
      case 'ru':
        return '449 ₽';
      case 'tr':
      default:
        return '99.99 ₺';
    }
  }

  String translatePetType(dynamic type) {
    if (type == null) return '';
    final str = type.toString().trim();
    final lower = str.toLowerCase();
    if (lower.contains('köpek') || lower.contains('dog') || lower.contains('hund') || lower.contains('собака') || lower.contains('chien') || lower.contains('perro')) {
      return translate('dog');
    }
    if (lower.contains('kedi') || lower.contains('cat') || lower.contains('katze') || lower.contains('кошка') || lower.contains('chat') || lower.contains('gato')) {
      return translate('cat');
    }
    if (lower.contains('kuş') || lower.contains('bird') || lower.contains('vogel') || lower.contains('птица') || lower.contains('oiseau') || lower.contains('pájaro')) {
      return translate('bird');
    }
    if (lower.contains('tavşan') || lower.contains('rabbit') || lower.contains('kaninchen') || lower.contains('кролик') || lower.contains('lapin') || lower.contains('conejo')) {
      return translate('rabbit');
    }
    if (lower.contains('hamster') || lower.contains('хомяк')) {
      return translate('hamster');
    }
    if (lower.contains('balık') || lower.contains('fish') || lower.contains('fisch') || lower.contains('рыб') || lower.contains('poisson') || lower.contains('pez')) {
      return translate('fish');
    }
    return str;
  }

  String translateDate(dynamic date) {
    if (date == null) return '';
    String str = date.toString();
    if (_currentLanguage == 'tr') return str;

    final months = {
      'Ocak': {'en': 'January', 'de': 'Januar', 'fr': 'Janvier', 'es': 'Enero', 'ru': 'Января'},
      'Şubat': {'en': 'February', 'de': 'Februar', 'fr': 'Février', 'es': 'Febrero', 'ru': 'Февраля'},
      'Mart': {'en': 'March', 'de': 'März', 'fr': 'Mars', 'es': 'Marzo', 'ru': 'Марта'},
      'Nisan': {'en': 'April', 'de': 'April', 'fr': 'Avril', 'es': 'Abril', 'ru': 'Апреля'},
      'Mayıs': {'en': 'May', 'de': 'Mai', 'fr': 'Mai', 'es': 'Mayo', 'ru': 'Мая'},
      'Haziran': {'en': 'June', 'de': 'Juni', 'fr': 'Juin', 'es': 'Junio', 'ru': 'Июня'},
      'Temmuz': {'en': 'July', 'de': 'Juli', 'fr': 'Juillet', 'es': 'Julio', 'ru': 'Июля'},
      'Ağustos': {'en': 'August', 'de': 'August', 'fr': 'Août', 'es': 'Agosto', 'ru': 'Августа'},
      'Eylül': {'en': 'September', 'de': 'September', 'fr': 'Septembre', 'es': 'Septiembre', 'ru': 'Сентября'},
      'Ekim': {'en': 'October', 'de': 'Oktober', 'fr': 'Octobre', 'es': 'Octubre', 'ru': 'Октября'},
      'Kasım': {'en': 'November', 'de': 'November', 'fr': 'Novembre', 'es': 'Noviembre', 'ru': 'Ноября'},
      'Aralık': {'en': 'December', 'de': 'Dezember', 'fr': 'Décembre', 'es': 'Diciembre', 'ru': 'Декабря'},
    };

    months.forEach((trMonth, map) {
      if (str.contains(trMonth)) {
        str = str.replaceAll(trMonth, map[_currentLanguage] ?? map['en']!);
      }
    });

    if (str.contains('Bugün')) {
      str = str.replaceAll('Bugün', translate('today'));
    }
    if (str.contains('Tarih Belirtilmedi')) {
      str = str.replaceAll('Tarih Belirtilmedi', translate('date'));
    }
    return str;
  }

  String translateDynamic(dynamic value) {
    if (value == null) return '';
    String str = value.toString().trim();
    if (str.isEmpty || _currentLanguage == 'tr') return str;

    // Direct phrases dictionary
    final dict = {
      // Vaccines
      'Karma Aşı (DHPPi)': {
        'en': 'Combined Vaccine (DHPPi)', 'de': 'Kombi-Impfung (DHPPi)', 'fr': 'Vaccin combiné (DHPPi)', 'es': 'Vacuna combinada (DHPPi)', 'ru': 'Комплексная вакцина (DHPPi)'
      },
      'Kuduz Aşısı': {
        'en': 'Rabies Vaccine', 'de': 'Tollwut-Impfung', 'fr': 'Vaccin contre la rage', 'es': 'Vacuna contra la rabia', 'ru': 'Вакцина от бешенства'
      },
      'Lyme Aşısı': {
        'en': 'Lyme Disease Vaccine', 'de': 'Borreliose-Impfung', 'fr': 'Vaccin maladie de Lyme', 'es': 'Vacuna enfermedad de Lyme', 'ru': 'Вакцина против болезни Лайма'
      },
      'Bordetella (Bronşin)': {
        'en': 'Bordetella (Kennel Cough)', 'de': 'Bordetella (Zwingerhusten)', 'fr': 'Bordetella (Toux de chenil)', 'es': 'Bordetella (Tos perreras)', 'ru': 'Бордетелла (Питомниковый кашель)'
      },
      'Karma Aşı (FVRCP)': {
        'en': 'Combined Vaccine (FVRCP)', 'de': 'Kombi-Impfung (FVRCP)', 'fr': 'Vaccin combiné (FVRCP)', 'es': 'Vacuna combinada (FVRCP)', 'ru': 'Комплексная вакцина (FVRCP)'
      },
      'Lösemi Aşısı (FeLV)': {
        'en': 'Feline Leukemia Vaccine (FeLV)', 'de': 'Katzenleukämie-Impfung', 'fr': 'Vaccin leucose féline', 'es': 'Vacuna leucemia felina', 'ru': 'Вакцина против лейкемии кошек'
      },
      'İç-Dış Parazit Damlası': {
        'en': 'Internal & External Parasite Drops', 'de': 'Parasiten-Tropfen', 'fr': 'Gouttes antiparasitaires', 'es': 'Pipeta antiparasitaria', 'ru': 'Капли от паразитов'
      },
      'Vitamin & Mineral Kürü': {
        'en': 'Vitamin & Mineral Treatment', 'de': 'Vitamin- & Mineralkur', 'fr': 'Cure de vitamines et minéraux', 'es': 'Tratamiento vitamínico', 'ru': 'Витаминно-минеральный курс'
      },
      'Karma RHD & Miksomatozis': {
        'en': 'Combined RHD & Myxomatosis', 'de': 'Kombi RHD & Myxomatose', 'fr': 'Vaccin combiné RHD & Myxomatose', 'es': 'Vacuna combinada RHD y mixomatosis', 'ru': 'Вакцина RHD и миксоматоз'
      },
      'İç Parazit Kürü': {
        'en': 'Deworming Treatment', 'de': 'Entwurmungskur', 'fr': 'Traitement vermifuge', 'es': 'Tratamiento desparasitante', 'ru': 'Дегельминтизация'
      },
      'Genel Sağlık & Diş Kontrolü': {
        'en': 'General Health & Dental Check', 'de': 'Gesundheits- & Zahncheck', 'fr': 'Bilan santé & Contrôle dentaire', 'es': 'Chequeo general y dental', 'ru': 'Осмотр здоровья и зубов'
      },

      // Appointments
      'Genel Muayene & Kontrol': {
        'en': 'General Examination & Check-up', 'de': 'Allgemeine Untersuchung', 'fr': 'Examen général & Contrôle', 'es': 'Examen general y control', 'ru': 'Общий осмотр и контроль'
      },
      'Aşı Uygulaması (DHPPi & Kuduz)': {
        'en': 'Vaccination (DHPPi & Rabies)', 'de': 'Impfung (DHPPi & Tollwut)', 'fr': 'Vaccination (DHPPi & Rage)', 'es': 'Vacunación (DHPPi y Rabia)', 'ru': 'Вакцинация (DHPPi и бешенство)'
      },
      'Patili Veteriner Kliniği': {
        'en': 'Paws Veterinary Clinic', 'de': 'Pfoten-Tierklinik', 'fr': 'Clinique Vétérinaire Les Pattes', 'es': 'Clínica Veterinaria Patitas', 'ru': 'Ветеринарная клиника «Лапки»'
      },
      'Patili Veteriner Kliniği • Dr. Ayşe Yılmaz': {
        'en': 'Paws Veterinary Clinic • Dr. Ayşe Yılmaz', 'de': 'Pfoten-Tierklinik • Dr. Ayşe Yılmaz', 'fr': 'Clinique Les Pattes • Dr. Ayşe Yılmaz', 'es': 'Clínica Patitas • Dra. Ayşe Yılmaz', 'ru': 'Ветклиника «Лапки» • Д-р Айше Йылмаз'
      },
      'Patili Klinik': {
        'en': 'Paws Clinic', 'de': 'Pfoten-Klinik', 'fr': 'Clinique Les Pattes', 'es': 'Clínica Patitas', 'ru': 'Клиника «Лапки»'
      },
      'Yıllık kan tahlilleri ve kulak kontrolü yapılacak.': {
        'en': 'Annual blood tests and ear check will be performed.', 'de': 'Jährliche Blutuntersuchung und Ohrenkontrolle.', 'fr': 'Bilan sanguin annuel et examen des oreilles.', 'es': 'Se realizarán análisis de sangre y revisión de oídos.', 'ru': 'Ежегодные анализы крови и осмотр ушей.'
      },
      'Karma aşı uygulandı, karnesine işlendi.': {
        'en': 'Combined vaccine administered, recorded in passport.', 'de': 'Kombi-Impfung verabreicht und eingetragen.', 'fr': 'Vaccin combiné administré et consigné.', 'es': 'Vacuna combinada aplicada y registrada.', 'ru': 'Комплексная вакцина введена и записана.'
      },
      'Aşı sonrası 1 gün dinlendirildi.': {
        'en': 'Rested 1 day after vaccination.', 'de': 'Nach Impfung 1 Tag geschont.', 'fr': 'Reposé 1 jour après la vaccination.', 'es': 'Reposo de 1 día tras la vacunación.', 'ru': 'Отдых 1 день после прививки.'
      },
      'Yıllık tekrar yapıldı.': {
        'en': 'Annual booster administered.', 'de': 'Jährliche Auffrischung erfolgt.', 'fr': 'Rappel annuel effectué.', 'es': 'Refuerzo anual realizado.', 'ru': 'Ежегодная ревакцинация проведена.'
      },
      'Kene mevsimi öncesi planlandı.': {
        'en': 'Scheduled before tick season.', 'de': 'Vor der Zeckensaison geplant.', 'fr': 'Planifié avant la saison des tiques.', 'es': 'Programado antes de la época de garrapatas.', 'ru': 'Запланировано перед сезоном клещей.'
      },
      'Barınak/Pansiyon öncesi gerekli.': {
        'en': 'Required before pet hotel boarding.', 'de': 'Vor Tierpension erforderlich.', 'fr': 'Requis avant mise en pension.', 'es': 'Requerido antes del hospedaje.', 'ru': 'Необходимо перед передержкой.'
      },
      '1. doz tamamlandı.': {
        'en': '1st dose completed.', 'de': '1. Dosis verabreicht.', 'fr': '1ère dose terminée.', 'es': '1ª dosis completada.', 'ru': '1-я доза завершена.'
      },
      'Çip kaydıyla eşleştirildi.': {
        'en': 'Matched with microchip registry.', 'de': 'Mit Mikrochip-Register verknüpft.', 'fr': 'Lié au registre de la puce.', 'es': 'Vinculado al registro del microchip.', 'ru': 'Связано с реестром чипа.'
      },
      'Öncesinde test yapılacak.': {
        'en': 'Test will be performed prior.', 'de': 'Vorabtest erforderlich.', 'fr': 'Test préalable prévu.', 'es': 'Se realizará prueba previa.', 'ru': 'Предварительно будет сдан тест.'
      },

      'Hızlı İşlemler': {
        'en': 'Quick Actions', 'de': 'Schnellaktionen', 'fr': 'Actions rapides', 'es': 'Acciones rápidas', 'ru': 'Быстрые действия'
      },
      'Minik dostunuz için anında kayıt oluşturun.': {
        'en': 'Create records instantly for your furry friend.', 'de': 'Erstellen Sie sofort Einträge für Ihr Haustier.', 'fr': 'Créez instantanément des enregistrements pour votre animal.', 'es': 'Cree registros al instante para su mascota.', 'ru': 'Мгновенно создавайте записи для вашего питомца.'
      },

      // Statuses & Alarms
      'Tamamlandı': {
        'en': 'Completed', 'de': 'Erledigt', 'fr': 'Terminé', 'es': 'Completado', 'ru': 'Завершено'
      },
      'Yaklaşan': {
        'en': 'Upcoming', 'de': 'Bevorstehend', 'fr': 'À venir', 'es': 'Próximo', 'ru': 'Предстоящие'
      },
      'Yaklaşıyor': {
        'en': 'Upcoming', 'de': 'Bevorstehend', 'fr': 'À venir', 'es': 'Próximo', 'ru': 'Скоро'
      },
      'Planlandı': {
        'en': 'Planned', 'de': 'Geplant', 'fr': 'Planifié', 'es': 'Planificado', 'ru': 'Запланировано'
      },
      'Aktif': {
        'en': 'Active', 'de': 'Aktiv', 'fr': 'Actif', 'es': 'Activo', 'ru': 'Активно'
      },
      'Bitti': {
        'en': 'Finished', 'de': 'Beendet', 'fr': 'Terminé', 'es': 'Terminado', 'ru': 'Завершено'
      },
      '1 Gün Önce': {
        'en': '1 Day Before', 'de': '1 Tag vorher', 'fr': '1 jour avant', 'es': '1 día antes', 'ru': 'За 1 день'
      },
      '1 Saat Önce': {
        'en': '1 Hour Before', 'de': '1 Stunde vorher', 'fr': '1 heure avant', 'es': '1 hora antes', 'ru': 'За 1 час'
      },
      '3 Saat Önce': {
        'en': '3 Hours Before', 'de': '3 Stunden vorher', 'fr': '3 heures avant', 'es': '3 horas antes', 'ru': 'За 3 часа'
      },
      '2 Gün Önce': {
        'en': '2 Days Before', 'de': '2 Tage vorher', 'fr': '2 jours avant', 'es': '2 días antes', 'ru': 'За 2 дня'
      },
      'Randevu Anında': {
        'en': 'At appointment time', 'de': 'Zum Terminzeitpunkt', 'fr': 'À l\'heure du rendez-vous', 'es': 'A la hora de la cita', 'ru': 'Во время приёма'
      },
      'Belirtilmedi': {
        'en': 'Not specified', 'de': 'Nicht angegeben', 'fr': 'Non spécifié', 'es': 'No especificado', 'ru': 'Не указано'
      },

      // Health records & Meds
      'Karma Aşı & Parazit Uygulaması': {
        'en': 'Combined Vaccine & Parasite', 'de': 'Kombi-Impfung & Parasit', 'fr': 'Vaccin combiné & Parasite', 'es': 'Vacuna combinada y parásitos', 'ru': 'Комплексная вакцина и паразиты'
      },
      'Rutin Muayene & Göz Kontrolü': {
        'en': 'Routine Exam & Eye Check', 'de': 'Routineuntersuchung & Augen', 'fr': 'Examen de routine & Yeux', 'es': 'Revisión de rutina y ojos', 'ru': 'Плановый осмотр и глаза'
      },
      'Mide Hassasiyeti Muayenesi': {
        'en': 'Stomach Sensitivity Exam', 'de': 'Magenempfindlichkeits-Check', 'fr': 'Consultation sensibilité gastrique', 'es': 'Consulta sensibilidad estomacal', 'ru': 'Осмотр чувствительности желудка'
      },
      'Mide Hassasiyeti & Kusma': {
        'en': 'Stomach Sensitivity & Vomiting', 'de': 'Magenempfindlichkeit & Erbrechen', 'fr': 'Sensibilité gastrique & Vomissements', 'es': 'Sensibilidad estomacal y vómitos', 'ru': 'Чувствительность желудка и рвота'
      },
      'Gastrovit Koruyucu Damla': {
        'en': 'Gastrovit Protective Drops', 'de': 'Gastrovit Schutz-Tropfen', 'fr': 'Gouttes protectrices Gastrovit', 'es': 'Gotas protectoras Gastrovit', 'ru': 'Защитные капли Гастровит'
      },
      'Parazitol Tablet': {
        'en': 'Parasitol Tablet', 'de': 'Parasitol Tablette', 'fr': 'Comprimé Parasitol', 'es': 'Comprimido Parasitol', 'ru': 'Таблетки Паразитол'
      },
      'Göz Damlası (Gentavet)': {
        'en': 'Eye Drops (Gentavet)', 'de': 'Augentropfen (Gentavet)', 'fr': 'Gouttes oculaires (Gentavet)', 'es': 'Gotas oculares (Gentavet)', 'ru': 'Глазные капли (Гентавет)'
      },

      // Appointments & Clinics
      'Genel Muayene & Check-up': {
        'en': 'General Examination & Check-up', 'de': 'Allgemeine Untersuchung & Check-up', 'fr': 'Examen général & Bilan', 'es': 'Examen general y chequeo', 'ru': 'Общий осмотр и чек-ап'
      },
      'Aşı Uygulaması (DHPPi)': {
        'en': 'Vaccination (DHPPi)', 'de': 'Impfung (DHPPi)', 'fr': 'Vaccination (DHPPi)', 'es': 'Vacunación (DHPPi)', 'ru': 'Вакцинация (DHPPi)'
      },
      'Patili Veteriner Kliniği (Kadıköy)': {
        'en': 'Paws Veterinary Clinic (Kadıköy)', 'de': 'Pfoten-Tierklinik (Kadıköy)', 'fr': 'Clinique Vétérinaire Les Pattes', 'es': 'Clínica Veterinaria Patitas', 'ru': 'Ветклиника «Лапки» (Кадыкёй)'
      },
      'Aşı Hatırlatıcısı': {
        'en': 'Vaccine Reminder', 'de': 'Impferinnerung', 'fr': 'Rappel de vaccin', 'es': 'Recordatorio de vacuna', 'ru': 'Напоминание о прививке'
      },
      'Diş Temizliği & Kontrol': {
        'en': 'Dental Cleaning & Check', 'de': 'Zahnreinigung & Kontrolle', 'fr': 'Détartrage & Contrôle dentaire', 'es': 'Limpieza y control dental', 'ru': 'Чистка зубов и осмотр'
      },
      'Kedi Dostu Sağlık Merkezi': {
        'en': 'Cat Friendly Health Center', 'de': 'Katzenfreundliches Gesundheitszentrum', 'fr': 'Centre de santé félin', 'es': 'Centro de salud felino', 'ru': 'Центр здоровья кошек'
      },
      'Kedi Dostu Sağlık Merkezi (Beşiktaş)': {
        'en': 'Cat Friendly Health Center (Beşiktaş)', 'de': 'Katzenfreundliches Zentrum (Beşiktaş)', 'fr': 'Centre de santé félin (Beşiktaş)', 'es': 'Centro de salud felino (Beşiktaş)', 'ru': 'Центр здоровья кошек (Бешикташ)'
      },
      'Hafif tartar başlangıcı kontrol edilecek.': {
        'en': 'Mild tartar onset will be checked.', 'de': 'Leichter Zahnsteinansatz wird kontrolliert.', 'fr': 'Début de tartre léger à vérifier.', 'es': 'Se revisará inicio leve de sarro.', 'ru': 'Будет проверен начальный зубной камень.'
      },
      'Luna Diş Randevusu': {
        'en': 'Luna Dental Appointment', 'de': 'Luna Zahnarzttermin', 'fr': 'Rendez-vous dentaire Luna', 'es': 'Cita dental de Luna', 'ru': 'Приём стоматолога Луны'
      },
      'Gaga ve Tırnak Kontrolü': {
        'en': 'Beak & Nail Check', 'de': 'Schnabel- & Krallenkontrolle', 'fr': 'Contrôle bec et griffes', 'es': 'Control de pico y uñas', 'ru': 'Осмотр клюва и когтей'
      },
      'Kanatlı Dostlar Kliniği': {
        'en': 'Winged Friends Clinic', 'de': 'Gefiederte Freunde Klinik', 'fr': 'Clinique des Oiseaux', 'es': 'Clínica Amigos Alados', 'ru': 'Клиника пернатых друзей'
      },
      'Gaga taşı ve mineral blok durumu incelenecek.': {
        'en': 'Cuttlebone and mineral block condition will be examined.', 'de': 'Wetzstein und Mineralblock werden geprüft.', 'fr': 'État de la pierre et du bloc minéral à vérifier.', 'es': 'Se revisará piedra de afilar y bloque mineral.', 'ru': 'Будет проверено состояние минерального камня.'
      },
      'Maviş Bakım Randevusu': {
        'en': 'Maviş Care Appointment', 'de': 'Maviş Pflegetermin', 'fr': 'Rendez-vous soin Maviş', 'es': 'Cita de cuidado de Maviş', 'ru': 'Приём по уходу за Мавиш'
      },
      'Diş Uzaması ve Sindirim Kontrolü': {
        'en': 'Tooth Overgrowth & Digestion Check', 'de': 'Zahnlänge- & Verdauungskontrolle', 'fr': 'Contrôle dentaire & digestion', 'es': 'Control dental y digestivo', 'ru': 'Осмотр длины зубов и пищеварения'
      },
      'Egzotik Dostlar Veterineri': {
        'en': 'Exotic Friends Veterinary', 'de': 'Exoten-Tierarzt', 'fr': 'Vétérinaire Nouveaux Animaux de Compagnie', 'es': 'Veterinaria Mascotas Exóticas', 'ru': 'Ветеринар экзотических животных'
      },
      'Arka azı dişlerinin hizalanması incelenecek.': {
        'en': 'Alignment of molar teeth will be examined.', 'de': 'Ausrichtung der Backenzähne wird untersucht.', 'fr': 'Alignement des molaires à examiner.', 'es': 'Se examinará alineación de molares.', 'ru': 'Будет проверено смыкание коренных зубов.'
      },
      'Pamuk Diş Kontrolü': {
        'en': 'Pamuk Dental Check', 'de': 'Pamuk Zahnkontrolle', 'fr': 'Contrôle dentaire Pamuk', 'es': 'Control dental de Pamuk', 'ru': 'Осмотр зубов Памук'
      },
      'Rutin Kilo & Sağlık Taraması': {
        'en': 'Routine Weight & Health Screening', 'de': 'Routine-Gewichts- & Gesundheitscheck', 'fr': 'Contrôle de poids & bilan de routine', 'es': 'Chequeo rutinario de peso y salud', 'ru': 'Плановый вес и скрининг здоровья'
      },

      // Medications
      'Kalp Kurdu Hapı (NexGard Spectra)': {
        'en': 'Heartworm Pill (NexGard Spectra)', 'de': 'Herzwurm-Tablette (NexGard Spectra)', 'fr': 'Comprimé vers du cœur (NexGard Spectra)', 'es': 'Pastilla parásitos corazón (NexGard Spectra)', 'ru': 'Таблетка от сердечных глистов (NexGard)'
      },
      '1 tablet (Çiğneme)': {
        'en': '1 chewable tablet', 'de': '1 Kautablette', 'fr': '1 comprimé à croquer', 'es': '1 comprimido masticable', 'ru': '1 жевательная таблетка'
      },
      'Ayda 1 kez': {
        'en': 'Once a month', 'de': 'Einmal im Monat', 'fr': '1 fois par mois', 'es': 'Una vez al mes', 'ru': '1 раз в месяц'
      },
      'Tok karnına ödül gibi verilebilir.': {
        'en': 'Can be given on full stomach as a treat.', 'de': 'Kann nach dem Fressen als Leckerli gegeben werden.', 'fr': 'À donner après le repas comme friandise.', 'es': 'Se puede dar tras la comida como premio.', 'ru': 'Можно давать на сытый желудок как лакомство.'
      },
      'Omega-3 Somon Yağı': {
        'en': 'Omega-3 Salmon Oil', 'de': 'Omega-3 Lachsöl', 'fr': 'Huile de saumon Oméga-3', 'es': 'Aceite de salmón Omega-3', 'ru': 'Лососевое масло Омега-3'
      },
      '2 pompa': {
        'en': '2 pumps', 'de': '2 Pumpstöße', 'fr': '2 pressions', 'es': '2 pulsaciones', 'ru': '2 дозы (нажатия)'
      },
      'Günde 1 kez': {
        'en': 'Once a day', 'de': 'Einmal täglich', 'fr': '1 fois par jour', 'es': 'Una vez al día', 'ru': '1 раз в день'
      },
      'Her Sabah': {
        'en': 'Every Morning', 'de': 'Jeden Morgen', 'fr': 'Chaque matin', 'es': 'Cada mañana', 'ru': 'Каждое утро'
      },
      'Her Akşam': {
        'en': 'Every Evening', 'de': 'Jeden Abend', 'fr': 'Chaque soir', 'es': 'Cada noche', 'ru': 'Каждый вечер'
      },
      'Sabah mamasına karıştırılacak.': {
        'en': 'To be mixed into morning food.', 'de': 'Wird unter das Morgenfutter gemischt.', 'fr': 'À mélanger à la pâtée du matin.', 'es': 'Mezclar con la comida de la mañana.', 'ru': 'Добавлять в утреннюю порцию корма.'
      },
      'Malt Macunu (Hairball)': {
        'en': 'Malt Paste (Hairball)', 'de': 'Maltpaste (Anti-Haarballen)', 'fr': 'Pâte de malt (Anti-boules de poils)', 'es': 'Pasta de malta (Bolas de pelo)', 'ru': 'Мальт-паста (для вывода шерсти)'
      },
      '2 cm': {
        'en': '2 cm', 'de': '2 cm', 'fr': '2 cm', 'es': '2 cm', 'ru': '2 см'
      },
      'Haftada 3 kez': {
        'en': '3 times a week', 'de': '3 Mal pro Woche', 'fr': '3 fois par semaine', 'es': '3 veces por semana', 'ru': '3 раза в неделю'
      },
      'Çarşamba - Cuma - Pazar': {
        'en': 'Wed - Fri - Sun', 'de': 'Mi - Fr - So', 'fr': 'Mer - Ven - Dim', 'es': 'Mié - Vie - Dom', 'ru': 'Ср - Пт - Вс'
      },
      'Tüy yumaklarının dışarı atılmasını sağlar.': {
        'en': 'Helps excrete hairballs naturally.', 'de': 'Fördert das Ausscheiden von Haarballen.', 'fr': 'Facilite l\'élimination des poils.', 'es': 'Ayuda a expulsar las bolas de pelo.', 'ru': 'Способствует выведению комков шерсти.'
      },
      'Multivitamin B-Complex': {
        'en': 'Multivitamin B-Complex', 'de': 'Multivitamin B-Komplex', 'fr': 'Multivitamines Complexe B', 'es': 'Multivitamínico Complejo B', 'ru': 'Мультивитамины B-Комплекс'
      },
      '5 damla': {
        'en': '5 drops', 'de': '5 Tropfen', 'fr': '5 gouttes', 'es': '5 gotas', 'ru': '5 капель'
      },
      'Haftada 2 gün': {
        'en': '2 days a week', 'de': '2 Tage pro Woche', 'fr': '2 jours par semaine', 'es': '2 días por semana', 'ru': '2 дня в неделю'
      },
      'Salı - Cumartesi': {
        'en': 'Tue - Sat', 'de': 'Di - Sa', 'fr': 'Mar - Sam', 'es': 'Mar - Sáb', 'ru': 'Вт - Сб'
      },
      'Taze içme suyuna damlatılmalıdır.': {
        'en': 'Should be dripped into fresh water.', 'de': 'In frisches Trinkwasser träufeln.', 'fr': 'À verser dans de l\'eau fraîche.', 'es': 'Añadir al agua fresca.', 'ru': 'Капать в свежую питьевую воду.'
      },
      'Tavşan C Vitamini & Lif Takviyesi': {
        'en': 'Rabbit Vitamin C & Fiber Supplement', 'de': 'Kaninchen Vitamin C & Ballaststoff-Zusatz', 'fr': 'Vitamine C & Fibres pour Lapin', 'es': 'Suplemento de vitamina C y fibra para conejos', 'ru': 'Витамин C и клетчатка для кроликов'
      },
      '1 tablet': {
        'en': '1 tablet', 'de': '1 Tablette', 'fr': '1 comprimé', 'es': '1 comprimido', 'ru': '1 таблетка'
      },
      'Ödül olarak çiğnetilir.': {
        'en': 'Chewed as a treat.', 'de': 'Wird als Kausnack gegeben.', 'fr': 'Donné à mâcher comme friandise.', 'es': 'Masticado como premio.', 'ru': 'Даётся как жевательное лакомство.'
      },

      // Symptoms & Common Symptoms Guide
      'Kusma': {
        'en': 'Vomiting', 'de': 'Erbrechen', 'fr': 'Vomissements', 'es': 'Vómitos', 'ru': 'Рвота'
      },
      'Sabah aç karnına sarı safra kustu.': {
        'en': 'Vomited yellow bile in the morning on an empty stomach.', 'de': 'Erbrach morgens auf nüchternen Magen gelbe Galle.', 'fr': 'A vomi de la bile jaune le matin à jeun.', 'es': 'Vomitó bilis amarilla por la mañana en ayunas.', 'ru': 'Утром натощак вырвало желтой желчью.'
      },
      'Tüy Yumağı Kusması': {
        'en': 'Hairball Vomiting', 'de': 'Haarballen-Erbrechen', 'fr': 'Régurgitation de boules de poils', 'es': 'Vómito de bola de pelo', 'ru': 'Срыгивание шерстью'
      },
      'Malt dozu artırıldı.': {
        'en': 'Malt paste dosage increased.', 'de': 'Malt-Dosis erhöht.', 'fr': 'Dose de pâte de malt augmentée.', 'es': 'Se aumentó dosis de malta.', 'ru': 'Доза мальт-пасты увеличена.'
      },
      'İştahsızlık': {
        'en': 'Loss of Appetite', 'de': 'Appetitlosigkeit', 'fr': 'Perte d\'appétit', 'es': 'Falta de apetito', 'ru': 'Потеря аппетита'
      },
      '24 saatten uzun süren iştahsızlık durumunda veteriner kontrolü önerilir.': {
        'en': 'Vet consultation recommended if appetite loss exceeds 24 hours.', 'de': 'Tierarztbesuch empfohlen, wenn Appetitlosigkeit länger als 24 Std. anhält.', 'fr': 'Consultez si la perte d\'appétit dure plus de 24h.', 'es': 'Se recomienda veterinario si la falta de apetito dura más de 24 horas.', 'ru': 'Рекомендуется осмотр ветеринара при отсутствии аппетита более 24 часов.'
      },
      'Sık Su İçme ve İdrara Çıkma': {
        'en': 'Frequent Drinking & Urination', 'de': 'Häufiges Trinken & Urinieren', 'fr': 'Boisson & miction fréquentes', 'es': 'Beber y orinar con frecuencia', 'ru': 'Частая жажда и мочеиспускание'
      },
      'Diyabet veya böbrek rahatsızlıklarının erken belirtisi olabilir.': {
        'en': 'May be an early sign of diabetes or kidney conditions.', 'de': 'Kann ein frühes Anzeichen für Diabetes oder Nierenprobleme sein.', 'fr': 'Peut être un signe précoce de diabète ou de troubles rénaux.', 'es': 'Puede ser signo precoz de diabetes o problemas renales.', 'ru': 'Может быть ранним признаком диабета или болезней почек.'
      },
      'Halsizlik ve İsteksizlik': {
        'en': 'Lethargy & Fatigue', 'de': 'Trägheit & Lustlosigkeit', 'fr': 'Léthargie & Apathie', 'es': 'Letargo y debilidad', 'ru': 'Вялость и слабость'
      },
      'Sürekli uyuma, oyun oynamama enfeksiyon veya ağrı işareti olabilir.': {
        'en': 'Constant sleeping or reluctance to play can indicate pain or infection.', 'de': 'Ständiges Schlafen oder Spielunlust kann auf Infektion oder Schmerz hinweisen.', 'fr': 'Sommeil continu ou manque de jeu peut indiquer douleur ou infection.', 'es': 'Dormir todo el tiempo o no querer jugar puede indicar infección o dolor.', 'ru': 'Постоянный сон и отказ от игр могут быть признаком инфекции или боли.'
      },
      'Sık Kaşınma veya Tüy Dökme': {
        'en': 'Frequent Scratching or Hair Loss', 'de': 'Häufiges Kratzen oder Haarausfall', 'fr': 'Grattage fréquent ou perte de poils', 'es': 'Rascado frecuente o caída de pelo', 'ru': 'Частый зуд или выпадение шерсти'
      },
      'Alerji, parazit veya mantar enfeksiyonlarına işaret edebilir.': {
        'en': 'May indicate allergies, parasites or fungal infections.', 'de': 'Kann auf Allergien, Parasiten oder Pilzinfektionen hindeuten.', 'fr': 'Peut signaler des allergies, parasites ou mycoses.', 'es': 'Puede indicar alergias, parásitos o infecciones por hongos.', 'ru': 'Может указывать на аллергию, паразитов или грибковые инфекции.'
      },

      // Emergency Contacts & Guides
      'Kendi Veterinerimiz': {
        'en': 'Our Primary Vet', 'de': 'Unser Haustierarzt', 'fr': 'Notre Vétérinaire Titulaire', 'es': 'Nuestro Veterinario Habitual', 'ru': 'Наш постоянный ветеринар'
      },
      'Dr. Ayşe Yılmaz (Patili Klinik)': {
        'en': 'Dr. Ayşe Yılmaz (Paws Clinic)', 'de': 'Dr. Ayşe Yılmaz (Pfoten-Klinik)', 'fr': 'Dr. Ayşe Yılmaz (Clinique Les Pattes)', 'es': 'Dra. Ayşe Yılmaz (Clínica Patitas)', 'ru': 'Д-р Айше Йылмаз (Клиника «Лапки»)'
      },
      '7/24 Nöbetçi Hayvan Hastanesi': {
        'en': '24/7 Emergency Animal Hospital', 'de': '24/7 Notfall-Tierklinik', 'fr': 'Hôpital vétérinaire d\'urgence 24h/7', 'es': 'Hospital veterinario de urgencias 24/7', 'ru': 'Круглосуточный стационар для животных 24/7'
      },
      'Umut Acil Kliniği': {
        'en': 'Hope Emergency Vet Clinic', 'de': 'Umut Notfall-Tierklinik', 'fr': 'Clinique d\'Urgence Espoir', 'es': 'Clínica de Urgencias Umut', 'ru': 'Ветклиника экстренной помощи «Умут»'
      },
      'Kedi Hekimimiz': {
        'en': 'Our Cat Vet', 'de': 'Unser Katzenspezialist', 'fr': 'Notre Vétérinaire Félin', 'es': 'Nuestro Veterinario Felino', 'ru': 'Наш фелинолог'
      },
      'Egzotik & Kuş Veterineri': {
        'en': 'Exotic & Avian Vet', 'de': 'Exoten- & Vogel-Tierarzt', 'fr': 'Vétérinaire Nouveaux Animaux & Oiseaux', 'es': 'Veterinario de aves y exóticos', 'ru': 'Ветеринар экзотических птиц и животных'
      },
      'Tavşan & Egzotik Uzmanı': {
        'en': 'Rabbit & Exotic Specialist', 'de': 'Kaninchen- & Exotenspezialist', 'fr': 'Spécialiste Lapins & NAC', 'es': 'Especialista en conejos y exóticos', 'ru': 'Специалист по кроликам и экзотам'
      },
      'Egzotik Klinik': {
        'en': 'Exotic Pet Clinic', 'de': 'Exoten-Tierklinik', 'fr': 'Clinique Vétérinaire Spécialisée', 'es': 'Clínica Mascotas Exóticas', 'ru': 'Клиника экзотических животных'
      },
      'Zehirlenme Durumu': {
        'en': 'Poisoning Emergency', 'de': 'Vergiftungs-Notfall', 'fr': 'Intoxication d\'urgence', 'es': 'Urgencia por intoxicación', 'ru': 'Случай отравления'
      },
      'Kusma, titreme, nefes darlığı varsa derhal veterineri arayın. Asla kendi başınıza kusturmaya çalışmayın.': {
        'en': 'If vomiting, tremors or shortness of breath occur, call a vet immediately. Never attempt to induce vomiting yourself.',
        'de': 'Bei Erbrechen, Zittern oder Atemnot sofort Tierarzt rufen. Niemals eigenständig Erbrechen herbeiführen.',
        'fr': 'En cas de vomissements, tremblements ou détresse respiratoire, appelez immédiatement un vétérinaire. Ne pas faire vomir vous-même.',
        'es': 'Si hay vómitos, temblores o dificultad para respirar, llame al veterinario de inmediato. Nunca intente inducir el vómito.',
        'ru': 'При рвоте, судорогах или одышке немедленно свяжитесь с ветеринаром. Никогда не пытайтесь вызвать рвоту самостоятельно.'
      },
      'Yaralanma / Kanama': {
        'en': 'Injury / Bleeding', 'de': 'Verletzung / Blutung', 'fr': 'Blessure / Saignement', 'es': 'Herida / Sangrado', 'ru': 'Травма / Кровотечение'
      },
      'Kanayan bölgeye temiz bir bezle hafif baskı uygulayın. Turnike yapmaktan kaçının ve hızlıca kliniğe gidin.': {
        'en': 'Apply gentle pressure to bleeding area with a clean cloth. Avoid tourniquets and rush to clinic.',
        'de': 'Üben Sie mit einem sauberen Tuch leichten Druck auf die blutende Stelle aus. Keine Abschnürung anwenden und zügig zur Klinik fahren.',
        'fr': 'Appliquez une pression douce avec un tissu propre. Évitez les garrots et rendez-vous rapidement en clinique.',
        'es': 'Aplique ligera presión con un paño limpio sobre la herida. Evite torniquetes y acuda rápido a la clínica.',
        'ru': 'Приложите чистую ткань с легким давлением к кровоточащему месту. Избегайте жгутов и срочно отправляйтесь в клинику.'
      },
      'Sıcak Çarpması': {
        'en': 'Heatstroke', 'de': 'Hitzschlag', 'fr': 'Coup de chaleur', 'es': 'Golpe de calor', 'ru': 'Тепловой удар'
      },
      'Aşırı nefes nefese kalma ve baygınlık durumunda patilerini ve göbeğini serin (buzlu olmayan) suyla ıslatın.': {
        'en': 'In case of severe panting and faintness, wet paws and belly with cool (not ice-cold) water.',
        'de': 'Bei starkem Hecheln und Benommenheit Pfoten und Bauch mit kühlem (nicht eiskaltem) Wasser benetzen.',
        'fr': 'En cas d\'essoufflement extrême et malaise, mouillez coussinets et ventre avec de l\'eau fraîche (non glacée).',
        'es': 'Si jadea en exceso o se desmaya, moje almohadillas y vientre con agua fresca (no helada).',
        'ru': 'При сильной одышке и обморочном состоянии смочите лапы и живот прохладной (не ледяной) водой.'
      },

      // Food & Nutrition
      'Kuru Mama': {
        'en': 'Dry Food', 'de': 'Trockenfutter', 'fr': 'Croquettes', 'es': 'Pienso seco', 'ru': 'Сухой корм'
      },
      'Yaş Mama': {
        'en': 'Wet Food', 'de': 'Nassfutter', 'fr': 'Pâtée', 'es': 'Comida húmeda', 'ru': 'Влажный корм'
      },
      'Günlük Miktar': {
        'en': 'Daily Amount', 'de': 'Tagesmenge', 'fr': 'Quantité journalière', 'es': 'Cantidad diaria', 'ru': 'Суточная норма'
      },
      'Mama Türü': {
        'en': 'Food Type', 'de': 'Futterart', 'fr': 'Type d\'aliment', 'es': 'Tipo de comida', 'ru': 'Тип корма'
      },
      'Öğün Planı': {
        'en': 'Meal Plan', 'de': 'Mahlzeitenplan', 'fr': 'Plan des repas', 'es': 'Plan de comidas', 'ru': 'План кормления'
      },
      'Besin Önerileri': {
        'en': 'Nutrition Recommendations', 'de': 'Ernährungstipps', 'fr': 'Conseils nutritionnels', 'es': 'Recomendaciones nutricionales', 'ru': 'Рекомендации по питанию'
      },
      'Sabah': {
        'en': 'Morning', 'de': 'Morgens', 'fr': 'Matin', 'es': 'Mañana', 'ru': 'Утро'
      },
      'Akşam': {
        'en': 'Evening', 'de': 'Abends', 'fr': 'Soir', 'es': 'Noche', 'ru': 'Вечер'
      },
      'öğün': {
        'en': 'meals', 'de': 'Mahlzeiten', 'fr': 'repas', 'es': 'comidas', 'ru': 'приёма'
      },
      'Doğru Mama Seçimi': {
        'en': 'Right Food Choice', 'de': 'Richtige Futterwahl', 'fr': 'Bien choisir les croquettes', 'es': 'Elegir el alimento adecuado', 'ru': 'Выбор правильного корма'
      },
      'Yaş, ırk ve aktiviteye göre beslenme önerileri.': {
        'en': 'Nutrition suggestions by age, breed and activity.', 'de': 'Ernährung nach Alter, Rasse und Aktivität.', 'fr': 'Recommandations selon l\'âge, la race et l\'activité.', 'es': 'Recomendaciones según edad, raza y actividad.', 'ru': 'Советы по питанию по возрасту, породе и активности.'
      },
      'Ev Yapımı Doğal Tarifler': {
        'en': 'Homemade Natural Recipes', 'de': 'Hausgemachte Naturrezepte', 'fr': 'Recettes naturelles maison', 'es': 'Recetas naturales caseras', 'ru': 'Домашние натуральные рецепты'
      },
      'Sağlıklı ve dengeli beslenme tarifleri.': {
        'en': 'Healthy and balanced nutrition recipes.', 'de': 'Rezepte für gesunde und ausgewogene Ernährung.', 'fr': 'Recettes saines et équilibrées.', 'es': 'Recetas sanas y equilibradas.', 'ru': 'Рецепты здорового и сбалансированного питания.'
      },
      'Su Tüketimi': {
        'en': 'Water Consumption', 'de': 'Wasseraufnahme', 'fr': 'Consommation d\'eau', 'es': 'Consumo de agua', 'ru': 'Потребление воды'
      },
      'Dostunuzun sağlığı için günde ne kadar su içmeli?': {
        'en': 'How much water should your pet drink daily?', 'de': 'Wie viel Wasser sollte Ihr Tier täglich trinken?', 'fr': 'Combien d\'eau votre compagnon doit-il boire par jour ?', 'es': '¿Cuánta agua debe beber su mascota al día?', 'ru': 'Сколько воды должен пить питомец в день?'
      },
      'Yavru, yetişkin ve yaşlı dostlarımızın kalori ve protein ihtiyacı farklıdır.': {
        'en': 'Calorie and protein needs vary for puppies, adults, and seniors.', 'de': 'Kalorien- und Proteinbedarf variiert je nach Lebensphase.', 'fr': 'Les besoins caloriques et protéiques varient selon l\'âge.', 'es': 'Las necesidades calóricas y de proteínas varían con la edad.', 'ru': 'Потребности в калориях и белке различаются в зависимости от возраста.'
      },
      'Mama içeriğinde ilk sırada et veya gerçek protein kaynağı yer almalıdır.': {
        'en': 'Meat or a real protein source should be the first ingredient.', 'de': 'Fleisch oder echtes Protein sollte an erster Stelle stehen.', 'fr': 'La viande ou une vraie source de protéine doit être le 1er ingrédient.', 'es': 'La carne o proteína real debe ser el primer ingrediente.', 'ru': 'Мясо или натуральный белок должны стоять на первом месте в составе.'
      },
      'Alerjik veya hassas sindirimi olan patiler için tahılsız formüller önerilir.': {
        'en': 'Grain-free formulas are recommended for sensitive digestion or allergies.', 'de': 'Getreidefreie Rezepturen werden bei empfindlicher Verdauung empfohlen.', 'fr': 'Des formules sans céréales sont recommandées en cas de digestion sensible.', 'es': 'Se recomiendan fórmulas sin cereales para digestiones sensibles o alergias.', 'ru': 'Беззерновые корма рекомендуются при чувствительном пищеварении или аллергии.'
      },
      'Haşlanmış tavuk göğsü, balkabağı ve havuç püresi mideyi rahatlatır.': {
        'en': 'Boiled chicken breast, pumpkin, and carrot puree soothe the stomach.', 'de': 'Gekochte Hähnchenbrust, Kürbis und Karottenpüree beruhigen den Magen.', 'fr': 'Poulet bouilli, purée de courge et carotte apaisent l\'estomac.', 'es': 'Pechuga de pollo hervida, calabaza y puré de zanahoria calman el estómago.', 'ru': 'Вареная куриная грудка, тыква и морковное пюре успокаивают желудок.'
      },
      'İshal ve hazımsızlık dönemlerinde yağsız pirinç lapası güvenlidir.': {
        'en': 'Plain white rice porridge is safe during diarrhea or upset stomach.', 'de': 'Fettfreier Reisschleim ist sicher bei Durchfall und Magenverstimmung.', 'fr': 'Une bouillie de riz sans matière grasse est sûre en cas de diarrhée.', 'es': 'El arroz blanco cocido es seguro durante diarreas o indigestión.', 'ru': 'Нежирный рисовый отвар безопасен при диарее и расстройстве желудка.'
      },
      'Asla verilmemesi gerekenler: Soğan, sarımsak, çikolata, üzüm ve baharat.': {
        'en': 'Never feed: Onion, garlic, chocolate, grapes, and spices.', 'de': 'Niemals füttern: Zwiebeln, Knoblauch, Schokolade, Weintrauben & Gewürze.', 'fr': 'À proscrire : Oignons, ail, chocolat, raisin et épices.', 'es': 'Nunca dar: Cebolla, ajo, chocolate, uvas ni especias.', 'ru': 'Категорически запрещено: лук, чеснок, шоколад, виноград и специи.'
      },
      'Evcil hayvanlar kilo başına günlük ortalama 50-60 ml temiz su içmelidir.': {
        'en': 'Pets should drink about 50-60 ml of fresh water per kg of body weight daily.', 'de': 'Tiere sollten täglich etwa 50-60 ml frisches Wasser pro kg trinken.', 'fr': 'Les animaux doivent boire environ 50-60 ml d\'eau fraîche par kg par jour.', 'es': 'Las mascotas deben beber entre 50-60 ml de agua fresca por kg al día.', 'ru': 'Питомцы должны выпивать около 50-60 мл свежей воды на кг веса в день.'
      },
      'Su kapları her gün temizlenmeli ve su sürekli taze tutulmalıdır.': {
        'en': 'Water bowls must be cleaned daily and refilled with fresh water.', 'de': 'Wassernäpfe sollten täglich gereinigt und frisch befüllt werden.', 'fr': 'Les écuelles d\'eau doivent être lavées tous les jours et renouvelées.', 'es': 'Los bebederos deben lavarse a diario y mantenerse siempre con agua fresca.', 'ru': 'Миски для воды нужно мыть каждый день и регулярно менять воду.'
      },
      'Kuru mama ile beslenen dostlarımızda su tüketimi 2-3 kat daha kritiktir.': {
        'en': 'Water intake is 2-3x more critical for pets on dry food diets.', 'de': 'Bei Trockenfutter-Ernährung ist die Wasseraufnahme 2-3 mal wichtiger.', 'fr': 'L\'apport en eau est 2 à 3 fois plus vital pour les animaux aux croquettes.', 'es': 'El consumo de agua es 2-3 veces más crítico para mascotas que comen pienso.', 'ru': 'Для питомцев на сухом корме потребление воды важнее в 2-3 раза.'
      },

      // Clinics & Emergency
      '153 Hayvan Ambulansı & Acil Müdahale': {
        'en': '153 Pet Ambulance & Emergency Rescue', 'de': '153 Tierrettungsdienst & Notfall', 'fr': '153 Ambulance & Urgences Animales', 'es': '153 Ambulancia y Urgencias de Mascotas', 'ru': '153 Скорая помощь для животных'
      },
      'Yaralı veya acil durumdaki evcil dostlarımız için 7/24 belediye acil hattı': {
        'en': '24/7 municipal emergency rescue for injured or critical pets', 'de': '24/7 Notdienst für verletzte oder kranke Tiere', 'fr': 'Assistance municipale 24/7 pour animaux blessés ou en détresse', 'es': 'Servicio municipal 24/7 para mascotas heridas o en emergencia', 'ru': 'Круглосуточная городская служба для раненых животных'
      },
      '81 İl Şehir Bazlı Nöbetçi Arama': {
        'en': '81 Cities Live Emergency Search', 'de': 'Notdienst-Suche nach Stadt', 'fr': 'Recherche d\'urgences par ville', 'es': 'Búsqueda de urgencias por ciudad', 'ru': 'Поиск дежурных клиник по городам'
      },
      'Seçtiğiniz şehir veya ilçedeki açık veterinerleri haritada canlı görün': {
        'en': 'View live open veterinary clinics on map for your selected city or district', 'de': 'Live geöffnete Tierkliniken für Ihre Stadt auf der Karte sehen', 'fr': 'Voir en direct sur la carte les vétérinaires ouverts dans votre ville', 'es': 'Vea en directo las clínicas veterinarias abiertas en su ciudad', 'ru': 'Смотрите открытые ветклиники на карте для выбранного города'
      },
      'Haritada Canlı Aç': {
        'en': 'Open Live on Map', 'de': 'Live auf Karte öffnen', 'fr': 'Ouvrir en direct sur la carte', 'es': 'Abrir en directo en el mapa', 'ru': 'Открыть на карте'
      },
      'Acil Hattı Ara': {
        'en': 'Call Emergency Hotline', 'de': 'Notruf anrufen', 'fr': 'Appeler la ligne d\'urgence', 'es': 'Llamar a emergencias', 'ru': 'Позвонить на горячую линию'
      },
      'Yakınımdaki Nöbetçi Veterinerleri Canlı Bul': {
        'en': 'Find Nearest Emergency Vets Live on Map', 'de': 'Notdienst-Tierärzte in der Nähe live finden', 'fr': 'Trouver les vétérinaires de garde à proximité', 'es': 'Buscar veterinarios de urgencias en directo', 'ru': 'Найти дежурные ветклиники рядом на карте'
      },
      '81 İl & Konumunuza göre açık acil klinikleri Google Haritalar\'da açın': {
        'en': 'Open Google Maps for 24/7 emergency clinics based on your live GPS location', 'de': 'Öffnen Sie Google Maps für 24/7 Notfallkliniken an Ihrem Live-Standort', 'fr': 'Ouvrez Google Maps pour les cliniques 24/7 selon votre position GPS', 'es': 'Abra Google Maps para clínicas 24/7 según su ubicación GPS en directo', 'ru': 'Открыть Google Карты с круглосуточными клиниками по вашему GPS'
      },
      'Şehir, İlçe veya Klinik Ara...': {
        'en': 'Search City, District or Clinic...', 'de': 'Stadt, Bezirk oder Klinik suchen...', 'fr': 'Rechercher ville, quartier ou clinique...', 'es': 'Buscar ciudad, distrito o clínica...', 'ru': 'Поиск города, района или клиники...'
      },
      'Aramanıza uygun klinik bulunamadı.': {
        'en': 'No clinics found matching your search.', 'de': 'Keine passende Klinik gefunden.', 'fr': 'Aucune clinique trouvée pour cette recherche.', 'es': 'No se encontraron clínicas que coincidan.', 'ru': 'Клиники по вашему запросу не найдены.'
      },
      '7/24 Nöbetçi / Acil': {
        'en': '24/7 Emergency', 'de': '24/7 Notdienst', 'fr': 'Urgences 24h/7j', 'es': 'Urgencias 24/7', 'ru': '24/7 Дежурный / Экстренный'
      },
      'Hayvan Hastanesi': {
        'en': 'Animal Hospital', 'de': 'Tierklinik / Tierkrankenhaus', 'fr': 'Hôpital vétérinaire', 'es': 'Hospital veterinario', 'ru': 'Ветеринарная клиника'
      },
      'Poliklinik': {
        'en': 'Polyclinic', 'de': 'Poliklinik', 'fr': 'Polyclinique', 'es': 'Policlínica', 'ru': 'Поликлиника'
      },
      'Hemen Ara': {
        'en': 'Call Now', 'de': 'Jetzt anrufen', 'fr': 'Appeler maintenant', 'es': 'Llamar ahora', 'ru': 'Позвонить'
      },
      'Haritada Aç': {
        'en': 'Open in Maps', 'de': 'Auf Karte öffnen', 'fr': 'Ouvrir sur la carte', 'es': 'Abrir en mapas', 'ru': 'Открыть на карте'
      },
      'Cerrahi': {
        'en': 'Surgery', 'de': 'Chirurgie', 'fr': 'Chirurgie', 'es': 'Cirugía', 'ru': 'Хирургия'
      },
      'Yoğun Bakım': {
        'en': 'Intensive Care', 'de': 'Intensivpflege', 'fr': 'Soins intensifs', 'es': 'Cuidados intensivos', 'ru': 'Интенсивная терапия'
      },
      'Röntgen': {
        'en': 'X-Ray', 'de': 'Röntgen', 'fr': 'Radiographie', 'es': 'Radiografía', 'ru': 'Рентген'
      },
      'Ultrason': {
        'en': 'Ultrasound', 'de': 'Ultraschall', 'fr': 'Échographie', 'es': 'Ecografía', 'ru': 'УЗИ'
      },
      'Laboratuvar': {
        'en': 'Laboratory', 'de': 'Labor', 'fr': 'Laboratoire', 'es': 'Laboratorio', 'ru': 'Лаборатория'
      },
      'İç/Dış Parazit': {
        'en': 'Internal/External Parasites', 'de': 'Innen-/Außenparasiten', 'fr': 'Parasites internes/externes', 'es': 'Parásitos internos/externos', 'ru': 'Внутренние/внешние паразиты'
      },
      'Genel Muayene': {
        'en': 'General Examination', 'de': 'Allgemeine Untersuchung', 'fr': 'Examen général', 'es': 'Examen general', 'ru': 'Общий осмотр'
      },
      'Diş Sağlığı': {
        'en': 'Dental Health', 'de': 'Zahngesundheit', 'fr': 'Santé dentaire', 'es': 'Salud dental', 'ru': 'Здоровье зубов'
      },
      'Kısırlaştırma': {
        'en': 'Neutering / Spaying', 'de': 'Kastration / Sterilisation', 'fr': 'Stérilisation', 'es': 'Esterilización', 'ru': 'Стерилизация'
      },
      'Ortopedi': {
        'en': 'Orthopedics', 'de': 'Orthopädie', 'fr': 'Orthopédie', 'es': 'Ortopedia', 'ru': 'Ортопедия'
      },
      'Doğum & Jinekoloji': {
        'en': 'Obstetrics & Gynecology', 'de': 'Geburtshilfe & Gynäkologie', 'fr': 'Obstétrique & Gynécologie', 'es': 'Obstetricia y Ginecología', 'ru': 'Акушерство и гинекология'
      },
      'Aşı Takvimi': {
        'en': 'Vaccination Schedule', 'de': 'Impfplan', 'fr': 'Calendrier de vaccination', 'es': 'Calendario de vacunación', 'ru': 'Календарь вакцинации'
      },
      'Kan Tahlili': {
        'en': 'Blood Test', 'de': 'Blutuntersuchung', 'fr': 'Analyse de sang', 'es': 'Análisis de sangre', 'ru': 'Анализ крови'
      },
      'Sıcak Çarpması Müdahale': {
        'en': 'Heatstroke Intervention', 'de': 'Hitzschlag-Behandlung', 'fr': 'Traitement coup de chaleur', 'es': 'Tratamiento golpe de calor', 'ru': 'Помощь при тепловом ударе'
      },
      'Aşı & Mikroçip': {
        'en': 'Vaccine & Microchip', 'de': 'Impfung & Mikrochip', 'fr': 'Vaccin & Puce', 'es': 'Vacuna y microchip', 'ru': 'Вакцинация и микрочипирование'
      },
      'Genel Cerrahi': {
        'en': 'General Surgery', 'de': 'Allgemeine Chirurgie', 'fr': 'Chirurgie générale', 'es': 'Cirugía general', 'ru': 'Общая хирургия'
      },
      'Beslenme Danışmanlığı': {
        'en': 'Nutrition Consultation', 'de': 'Ernährungsberatung', 'fr': 'Conseil en nutrition', 'es': 'Consulta nutricional', 'ru': 'Консультация по питанию'
      },

      // Spotlight Search & Home Greeting
      'Arama Sonuçları': {
        'en': 'Search Results', 'de': 'Suchergebnisse', 'fr': 'Résultats de recherche', 'es': 'Resultados de búsqueda', 'ru': 'Результаты поиска'
      },
      'Temizle': {
        'en': 'Clear', 'de': 'Löschen', 'fr': 'Effacer', 'es': 'Borrar', 'ru': 'Очистить'
      },
      'Aramanıza uygun başlık veya modül bulunamadı.': {
        'en': 'No matching topic or module found.', 'de': 'Kein passendes Thema oder Modul gefunden.', 'fr': 'Aucun sujet ou module correspondant trouvé.', 'es': 'No se encontró ningún tema o módulo coincidente.', 'ru': 'Подходящих тем или разделов не найдено.'
      },
      'İpucu: Aşı, Mama, Klinik, Acil, Eğitim kelimelerini deneyin.': {
        'en': 'Tip: Try searching Vaccines, Food, Clinics, Emergency, Training.', 'de': 'Tipp: Versuchen Sie Impfungen, Futter, Klinik, Notfall, Training.', 'fr': 'Astuce : Essayez Vaccin, Nourriture, Clinique, Urgence, Dressage.', 'es': 'Consejo: Pruebe Vacunas, Comida, Clínica, Urgencias, Adiestramiento.', 'ru': 'Подсказка: попробуйте Прививки, Корм, Клиника, Экстренно, Обучение.'
      },
      'Evcil Dostlarım': {
        'en': 'My Pets', 'de': 'Meine Haustiere', 'fr': 'Mes Animaux', 'es': 'Mis Mascotas', 'ru': 'Мои питомцы'
      },
      'Evcil Dostunla Tanışalım': {
        'en': 'Meet Your Pet', 'de': 'Lerne dein Haustier kennen', 'fr': 'Rencontrez votre animal', 'es': 'Conoce a tu mascota', 'ru': 'Познакомимся с питомцем'
      },
      'Sağlık Takibi Aktif': {
        'en': 'Health Tracking Active', 'de': 'Gesundheits-Tracking aktiv', 'fr': 'Suivi de santé actif', 'es': 'Seguimiento de salud activo', 'ru': 'Отслеживание здоровья активно'
      },
      'Görüntüle': {
        'en': 'View', 'de': 'Ansehen', 'fr': 'Voir', 'es': 'Ver', 'ru': 'Открыть'
      },

      // Pet Hub & Records
      'Kayıt': {
        'en': 'Records', 'de': 'Einträge', 'fr': 'Dossiers', 'es': 'Registros', 'ru': 'Записей'
      },
      'Randevu': {
        'en': 'Appointments', 'de': 'Termine', 'fr': 'Rendez-vous', 'es': 'Citas', 'ru': 'Приёмов'
      },
      'İlaç': {
        'en': 'Meds', 'de': 'Medikamente', 'fr': 'Médicaments', 'es': 'Medicamentos', 'ru': 'Лекарств'
      },
      'Plan & Porsiyon': {
        'en': 'Plan & Portions', 'de': 'Plan & Portionen', 'fr': 'Plan & Portions', 'es': 'Plan y porciones', 'ru': 'План и порции'
      },
      'İpuçları & Komut': {
        'en': 'Tips & Commands', 'de': 'Tipps & Kommandos', 'fr': 'Conseils & Ordres', 'es': 'Consejos y órdenes', 'ru': 'Советы и команды'
      },
      'Çip Kaydı Yok': {
        'en': 'No Microchip Record', 'de': 'Kein Mikrochip registriert', 'fr': 'Aucune puce enregistrée', 'es': 'Sin registro de microchip', 'ru': 'Нет записи микрочипа'
      },
      'Kayıtlı alerji yok': {
        'en': 'No recorded allergies', 'de': 'Keine Allergien bekannt', 'fr': 'Aucune allergie enregistrée', 'es': 'Sin alergias registradas', 'ru': 'Аллергий не зафиксировано'
      },
      'Sabah aç karnına': {
        'en': 'Morning on empty stomach', 'de': 'Morgens auf nüchternen Magen', 'fr': 'Le matin à jeun', 'es': 'Por la mañana en ayunas', 'ru': 'Утром натощак'
      },
      'Melez': {
        'en': 'Mixed Breed', 'de': 'Mischling', 'fr': 'Croisé', 'es': 'Mestizo', 'ru': 'Метис'
      },
      'Yok': {
        'en': 'None', 'de': 'Keine', 'fr': 'Aucun', 'es': 'Ninguno', 'ru': 'Нет'
      },
      'Kilo Kontrolü': {
        'en': 'Weight Check', 'de': 'Gewichtskontrolle', 'fr': 'Contrôle du poids', 'es': 'Control de peso', 'ru': 'Контроль веса'
      },
      'Henüz kilo ölçümü kaydedilmedi.': {
        'en': 'No weight measurements recorded yet.', 'de': 'Noch keine Gewichtsmessung erfasst.', 'fr': 'Aucune mesure de poids enregistrée.', 'es': 'Aún no se han registrado medidas de peso.', 'ru': 'Измерений веса пока нет.'
      },

      // Training
      'Tuvalet Eğitimi': {
        'en': 'Potty Training', 'de': 'Stubenreinheit', 'fr': 'Apprentissage de la propreté', 'es': 'Adiestramiento para ir al baño', 'ru': 'Приучение к туалету'
      },
      'Otur Komutu': {
        'en': 'Sit Command', 'de': 'Sitz-Kommando', 'fr': 'Ordre Assis', 'es': 'Orden Sentado', 'ru': 'Команда «Сидеть»'
      },
      'Pati Ver': {
        'en': 'Give Paw', 'de': 'Pfote geben', 'fr': 'Donne la patte', 'es': 'Dar la pata', 'ru': 'Дай лапу'
      },
      'Gel Komutu': {
        'en': 'Come Command', 'de': 'Hier-Kommando', 'fr': 'Rappel (Viens)', 'es': 'Orden Ven', 'ru': 'Команда «Ко мне»'
      },
      'Tasma Eğitimi': {
        'en': 'Leash Training', 'de': 'Leinenführigkeit', 'fr': 'Marche en laisse', 'es': 'Paseo con correa', 'ru': 'Хождение на поводке'
      },
      'Temel İtaat': {
        'en': 'Basic Obedience', 'de': 'Grundgehorsam', 'fr': 'Obéissance de base', 'es': 'Obediencia básica', 'ru': 'Базовое послушание'
      },
      'İleri İtaat': {
        'en': 'Advanced Obedience', 'de': 'Fortgeschrittener Gehorsam', 'fr': 'Obéissance avancée', 'es': 'Obediencia avanzada', 'ru': 'Продвинутое послушание'
      },
      'Sosyalleşme': {
        'en': 'Socialization', 'de': 'Sozialisierung', 'fr': 'Socialisation', 'es': 'Socialización', 'ru': 'Социализация'
      },
      'Yavru Bakımı': {
        'en': 'Puppy/Kitten Care', 'de': 'Welpenpflege', 'fr': 'Soins des petits', 'es': 'Cuidado de cachorros', 'ru': 'Уход за малышами'
      },
      'Ev Kuralları': {
        'en': 'House Rules', 'de': 'Hausregeln', 'fr': 'Règles de la maison', 'es': 'Normas de la casa', 'ru': 'Правила дома'
      },

      // Behavior
      'Ayrılık Kaygısı': {
        'en': 'Separation Anxiety', 'de': 'Verlustangst', 'fr': 'Anxiété de séparation', 'es': 'Ansiedad por separación', 'ru': 'Тревога разлуки'
      },
      'Aşırı Havlama': {
        'en': 'Excessive Barking', 'de': 'Übermäßiges Bellen', 'fr': 'Aboiements excessifs', 'es': 'Ladrido excesivo', 'ru': 'Чрезмерный лай'
      },
      'Eşyaları Kemirme': {
        'en': 'Chewing Furniture', 'de': 'Möbelkauen', 'fr': 'Mastication destructrice', 'es': 'Morder objetos', 'ru': 'Грызение вещей'
      },
      'Agresyon & Hırlama': {
        'en': 'Aggression & Growling', 'de': 'Aggression & Knurren', 'fr': 'Agressivité & Grognements', 'es': 'Agresión y gruñidos', 'ru': 'Агрессия и рычание'
      },
      'Korku & Çekingenlik': {
        'en': 'Fear & Shyness', 'de': 'Angst & Schüchternheit', 'fr': 'Peur & Timidité', 'es': 'Miedo y timidez', 'ru': 'Страх и робость'
      },
      'Evde Yalnız Kalma': {
        'en': 'Staying Home Alone', 'de': 'Alleinbleiben', 'fr': 'Rester seul à la maison', 'es': 'Quedarse solo en casa', 'ru': 'Пребывание дома в одиночестве'
      },
      'Tırmalama Alışkanlığı': {
        'en': 'Scratching Habits', 'de': 'Kratzgewohnheiten', 'fr': 'Habitude de griffage', 'es': 'Hábito de arañar', 'ru': 'Привычка точить когти'
      },
      'Geceleri Miyavlama': {
        'en': 'Nighttime Meowing', 'de': 'Nächtliches Miauen', 'fr': 'Miaulements nocturnes', 'es': 'Maullidos nocturnos', 'ru': 'Ночное мяуканье'
      },
      'Kafes Dışına Çıkmama': {
        'en': 'Reluctance to Leave Cage', 'de': 'Käfigscheu', 'fr': 'Refus de sortir de cage', 'es': 'No querer salir de la jaula', 'ru': 'Нежелание выходить из клетки'
      },
      'Öğün': {
        'en': 'Meals', 'de': 'Mahlzeiten', 'fr': 'Repas', 'es': 'Comidas', 'ru': 'Приема пищи'
      },

      // Severity
      'Hafif': {
        'en': 'Mild', 'de': 'Leicht', 'fr': 'Léger', 'es': 'Leve', 'ru': 'Легкая'
      },
      'Orta': {
        'en': 'Moderate', 'de': 'Mittel', 'fr': 'Modéré', 'es': 'Moderada', 'ru': 'Средняя'
      },
      'Yüksek': {
        'en': 'High', 'de': 'Hoch', 'fr': 'Élevé', 'es': 'Alta', 'ru': 'Высокая'
      },
      'Şiddetli': {
        'en': 'Severe', 'de': 'Schwer', 'fr': 'Sévère', 'es': 'Grave', 'ru': 'Тяжелая'
      },

      // Categories & UI buttons
      'Yemek & Beslenme': {
        'en': 'Food & Nutrition', 'de': 'Futter & Ernährung', 'fr': 'Alimentation & Nutrition', 'es': 'Comida y nutrición', 'ru': 'Еда и питание'
      },
      'Barınma & Güvenlik': {
        'en': 'Habitat & Safety', 'de': 'Unterkunft & Sicherheit', 'fr': 'Habitat & Sécurité', 'es': 'Hábitat y seguridad', 'ru': 'Жилье и безопасность'
      },
      'Yatma & Uyku': {
        'en': 'Sleep Routine', 'de': 'Schlaf & Ruhe', 'fr': 'Sommeil & Repos', 'es': 'Rutina de sueño', 'ru': 'Сон и отдых'
      },
      'Temel Eğitim': {
        'en': 'Basic Training', 'de': 'Grundausbildung', 'fr': 'Éducation de base', 'es': 'Entrenamiento básico', 'ru': 'Базовое обучение'
      },
      'Tümü': {
        'en': 'All', 'de': 'Alle', 'fr': 'Tout', 'es': 'Todos', 'ru': 'Все'
      },
      'Rehber': {
        'en': 'Guide', 'de': 'Leitfaden', 'fr': 'Guide', 'es': 'Guía', 'ru': 'Руководство'
      },
      'Davranış': {
        'en': 'Behavior', 'de': 'Verhalten', 'fr': 'Comportement', 'es': 'Comportamiento', 'ru': 'Поведение'
      },
      'Anladım, Harika!': {
        'en': 'Got it, Great!', 'de': 'Verstanden, super!', 'fr': 'Compris, super !', 'es': '¡Entendido, genial!', 'ru': 'Понятно, отлично!'
      },
      'Anladım, Teşekkürler!': {
        'en': 'Got it, Thanks!', 'de': 'Verstanden, danke!', 'fr': 'Compris, merci !', 'es': '¡Entendido, gracias!', 'ru': 'Понятно, спасибо!'
      },

      // Care Grid items
      'Tıraş': {
        'en': 'Grooming / Shave', 'de': 'Schur & Fellpflege', 'fr': 'Toilettage / Tonte', 'es': 'Peluquería / Afeitado', 'ru': 'Стрижка'
      },
      'Tüy bakımı & tıraş': {
        'en': 'Coat care & grooming', 'de': 'Fellpflege & Schur', 'fr': 'Soin du pelage & tonte', 'es': 'Cuidado del pelaje y afeitado', 'ru': 'Уход за шерстью и стрижка'
      },
      'Banyo': {
        'en': 'Bath', 'de': 'Baden', 'fr': 'Bain', 'es': 'Baño', 'ru': 'Купание'
      },
      'Hijyenik temizlik': {
        'en': 'Hygienic cleaning', 'de': 'Hygienische Reinigung', 'fr': 'Nettoyage hygiénique', 'es': 'Limpieza higiénica', 'ru': 'Гигиеническая чистка'
      },
      'Tırnak Kesimi': {
        'en': 'Nail Trimming', 'de': 'Krallenschneiden', 'fr': 'Coupe des griffes', 'es': 'Corte de uñas', 'ru': 'Стрижка когтей'
      },
      'Sağlıklı patiler': {
        'en': 'Healthy paws', 'de': 'Gesunde Pfoten', 'fr': 'Pattes saines', 'es': 'Patas saludables', 'ru': 'Здоровые лапы'
      },
      'Kulak Temizliği': {
        'en': 'Ear Cleaning', 'de': 'Ohrenreinigung', 'fr': 'Nettoyage des oreilles', 'es': 'Limpieza de oídos', 'ru': 'Чистка ушей'
      },
      'Enfeksiyona karşı': {
        'en': 'Against infection', 'de': 'Gegen Infektionen', 'fr': 'Contre les infections', 'es': 'Contra infecciones', 'ru': 'Против инфекций'
      },
      'Diş Bakımı': {
        'en': 'Dental Care', 'de': 'Zahnpflege', 'fr': 'Soins dentaires', 'es': 'Cuidado dental', 'ru': 'Уход за зубами'
      },
      'Ağız ve diş sağlığı': {
        'en': 'Oral & dental health', 'de': 'Mund- & Zahngesundheit', 'fr': 'Santé bucco-dentaire', 'es': 'Salud bucal y dental', 'ru': 'Здоровье полости рта'
      },
      'Parazit Kontrolü': {
        'en': 'Parasite Control', 'de': 'Parasitenkontrolle', 'fr': 'Contrôle parasitaire', 'es': 'Control de parásitos', 'ru': 'Контроль паразитов'
      },
      'Daha sağlıklı yaşam': {
        'en': 'A healthier life', 'de': 'Gesünderes Leben', 'fr': 'Une vie plus saine', 'es': 'Una vida más saludable', 'ru': 'Более здоровая жизнь'
      },

      // Common Symptoms
      'İştahsızlık & Kilo Kaybı': {
        'en': 'Loss of Appetite & Weight Loss', 'de': 'Appetitlosigkeit & Gewichtsverlust', 'fr': 'Perte d\'appétit & de poids', 'es': 'Pérdida de apetito y peso', 'ru': 'Потеря аппетита и веса'
      },
      'Aşırı Kaşınma & Tüy Dökülmesi': {
        'en': 'Excessive Itching & Hair Loss', 'de': 'Starker Juckreiz & Haarausfall', 'fr': 'Démangeaisons excessives & Perte de poils', 'es': 'Picazón excesiva y caída de pelo', 'ru': 'Сильный зуд и выпадение шерсти'
      },
      'Kusma & İshal': {
        'en': 'Vomiting & Diarrhea', 'de': 'Erbrechen & Durchfall', 'fr': 'Vomissements & Diarrhée', 'es': 'Vómitos y diarrea', 'ru': 'Рвота и диарея'
      },
      'Halsizlik & Uyuşukluk': {
        'en': 'Lethargy & Sluggishness', 'de': 'Schwäche & Trägheit', 'fr': 'Faiblesse & Léthargie', 'es': 'Debilidad y letargo', 'ru': 'Слабость и вялость'
      },

      // Common Symptoms Descriptions & Titles

      // Emergency Guides Descriptions & Titles
      'Trafik Kazası / Düşme': {
        'en': 'Traffic Accident / Fall', 'de': 'Verkehrsunfall / Sturz', 'fr': 'Accident de la route / Chute', 'es': 'Accidente de tráfico / Caída', 'ru': 'Травма / Падение'
      },
      'Solunum Güçlüğü': {
        'en': 'Breathing Difficulty', 'de': 'Atemnot', 'fr': 'Difficulté respiratoire', 'es': 'Dificultad para respirar', 'ru': 'Затрудненное дыхание'
      },
      'Yabancı Cisim Yutma': {
        'en': 'Swallowing Foreign Object', 'de': 'Fremdkörper verschluckt', 'fr': 'Ingestion de corps étranger', 'es': 'Ingestión de cuerpo extraño', 'ru': 'Проглатывание инородного тела'
      },

      // Reminders & States
      'Aktif Akıllı Hatırlatıcılar': {
        'en': 'Active Smart Reminders', 'de': 'Aktive Intelligente Erinnerungen', 'fr': 'Rappels intelligents actifs', 'es': 'Recordatorios inteligentes activos', 'ru': 'Активные напоминания'
      },
      'Tüm dostlarınız için yaklaşan veteriner randevusu, aşı ve ilaç hatırlatıcısı kuruldu.': {
        'en': 'Smart reminders set for upcoming vet visits, vaccines, and medications.', 'de': 'Erinnerungen für Tierarztbesuche, Impfungen und Medikamente aktiviert.', 'fr': 'Rappels configurés pour les rendez-vous, vaccins et médicaments.', 'es': 'Recordatorios activados para citas veterinarias, vacunas y medicamentos.', 'ru': 'Напоминания о визитах к ветеринару, прививках и лекарствах настроены.'
      },
      'Yaklaşan Hatırlatıcı Yok': {
        'en': 'No Upcoming Reminders', 'de': 'Keine anstehenden Erinnerungen', 'fr': 'Aucun rappel à venir', 'es': 'Sin recordatorios pendientes', 'ru': 'Нет предстоящих напоминаний'
      },
      'Seçtiğiniz kategoride henüz bekleyen bir randevu veya alarm bulunmuyor.': {
        'en': 'No pending appointment or alarm in the selected category.', 'de': 'Keine anstehenden Termine oder Alarme in dieser Kategorie.', 'fr': 'Aucun rendez-vous ou alarme dans la catégorie sélectionnée.', 'es': 'No hay citas ni alarmas pendientes en la categoría seleccionada.', 'ru': 'В выбранной категории нет запланированных визитов или напоминаний.'
      },
      'Kayıtlı Randevu Bulunmuyor': {
        'en': 'No Appointments Registered', 'de': 'Keine Termine registriert', 'fr': 'Aucun rendez-vous enregistré', 'es': 'No hay citas registradas', 'ru': 'Записи на прием отсутствуют'
      },
      'Yeni bir randevu ekleyerek takviminizi oluşturun.': {
        'en': 'Create your schedule by adding a new appointment.', 'de': 'Erstellen Sie Ihren Zeitplan mit einem neuen Termin.', 'fr': 'Créez votre planning en ajoutant un nouveau rendez-vous.', 'es': 'Organice su calendario agregando una nueva cita.', 'ru': 'Добавьте прием, чтобы заполнить календарь.'
      },
      'Dostunuz için yaklaşan bir veteriner randevusu oluşturup alarmını kurabilirsiniz.': {
        'en': 'You can schedule an upcoming vet visit for your pet and set its alarm.', 'de': 'Sie können einen bevorstehenden Tierarzttermin vereinbaren und die Erinnerung aktivieren.', 'fr': 'Vous pouvez planifier un prochain rendez-vous vétérinaire et activer son alarme.', 'es': 'Puedes programar una próxima cita veterinaria y configurar su alarma.', 'ru': 'Вы можете запланировать визит к ветеринару и включить напоминание.'
      },
      'Randevu Ekle': {
        'en': 'Add Appointment', 'de': 'Termin hinzufügen', 'fr': 'Ajouter un rendez-vous', 'es': 'Agregar cita', 'ru': 'Добавить прием'
      },

      // Home Screen Subtitles & Tooltips
      'Temel itaat, tuvalet ve tasma eğitimi...': {
        'en': 'Basic obedience, potty and leash training...', 'de': 'Grundgehorsam, Stubenreinheit und Leinenführung...', 'fr': 'Obéissance de base, propreté et marche en laisse...', 'es': 'Obediencia básica, baño y correa...', 'ru': 'Базовое послушание, туалет и поводок...'
      },
      'Kum alışkanlığı, tırmalama ve beslenme...': {
        'en': 'Litter box habits, scratching and nutrition...', 'de': 'Katzenklo-Gewöhnung, Kratzen und Ernährung...', 'fr': 'Bac à litière, griffades et alimentation...', 'es': 'Arenero, rascado y alimentación...', 'ru': 'Приучение к лотку, когтеточка и питание...'
      },
      'Kafes ortamı, konuşma eğitimi ve vitaminler...': {
        'en': 'Cage setup, speech training and vitamins...', 'de': 'Käfiggestaltung, Sprechtraining und Vitamine...', 'fr': 'Environnement en cage, apprentissage de la parole et vitamines...', 'es': 'Entorno de jaula, habla y vitaminas...', 'ru': 'Обустройство клетки, речь и витамины...'
      },
      'Tuvalet kabı eğitimi, kuru ot ve kemirme...': {
        'en': 'Litter training, hay diet and chew habits...', 'de': 'Toilettentraining, Heufütterung und Knabbern...', 'fr': 'Apprentissage de la litière, foin et mastication...', 'es': 'Caja de arena, heno y roer...', 'ru': 'Приучение к лотку, сено и грызение...'
      },
      'Çark egzersizi, talaş seçimi ve gece düzeni...': {
        'en': 'Wheel exercise, bedding choice and night routine...', 'de': 'Laufrad-Übung, Einstreu-Wahl und Nachtrhythmus...', 'fr': 'Roue d\'exercice, litière et rythme nocturne...', 'es': 'Rueda de ejercicio, viruta y noche...', 'ru': 'Колесо для бега, опилки и ночной режим...'
      },
      'Akvaryum su dengesi, filtre ve porsiyon...': {
        'en': 'Aquarium water balance, filters and portions...', 'de': 'Aquarium-Wasserwerte, Filter und Portionierung...', 'fr': 'Équilibre de l\'eau, filtration et portions...', 'es': 'Equilibrio del agua, filtración y raciones...', 'ru': 'Баланс воды в аквариуме, фильтрация и порции...'
      },
      'Hatırlatıcılar & Bildirimler': {
        'en': 'Reminders & Notifications', 'de': 'Erinnerungen & Benachrichtigungen', 'fr': 'Rappels & Notifications', 'es': 'Recordatorios y Notificaciones', 'ru': 'Напоминания и уведомления'
      },

      // Profile & Feedback Modal
      'Geliştiriciye Mesaj & Öneri': {
        'en': 'Message & Feedback to Developer', 'de': 'Nachricht & Feedback an Entwickler', 'fr': 'Message & Suggestion au développeur', 'es': 'Mensaje y sugerencia al desarrollador', 'ru': 'Сообщение и отзыв разработчику'
      },
      'Uygulamayı mükemmelleştirmek için fikirleriniz bizim için çok değerli!': {
        'en': 'Your ideas are valuable to make the app perfect!', 'de': 'Ihre Ideen sind uns wertvoll, um die App zu verbessern!', 'fr': 'Vos idées sont précieuses pour perfectionner l\'application !', 'es': '¡Tus ideas son muy valiosas para perfeccionar la aplicación!', 'ru': 'Ваши идеи очень ценны для улучшения приложения!'
      },
      'Mesaj Konusu': {
        'en': 'Message Topic', 'de': 'Betreff', 'fr': 'Sujet du message', 'es': 'Asunto del mensaje', 'ru': 'Тема сообщения'
      },
      '💡 Yeni Fikir / Öneri': {
        'en': '💡 New Idea / Suggestion', 'de': '💡 Neue Idee / Vorschlag', 'fr': '💡 Nouvelle idée / Suggestion', 'es': '💡 Nueva idea / Sugerencia', 'ru': '💡 Новая идея / Предложение'
      },
      '🐞 Hata Bildirimi': {
        'en': '🐞 Bug Report', 'de': '🐞 Fehlerbericht', 'fr': '🐞 Signalement de bug', 'es': '🐞 Reporte de error', 'ru': '🐞 Сообщение об ошибке'
      },
      '🐾 Yeni Hayvan Türü': {
        'en': '🐾 New Pet Species', 'de': '🐾 Neue Tierart', 'fr': '🐾 Nouvelle espèce animale', 'es': '🐾 Nueva especie de mascota', 'ru': '🐾 Новый вид питомца'
      },
      '⭐ Teşekkür & Görüş': {
        'en': '⭐ Thanks & Review', 'de': '⭐ Dank & Feedback', 'fr': '⭐ Remerciements & Avis', 'es': '⭐ Agradecimientos y opinión', 'ru': '⭐ Благодарность и отзыв'
      },
      'Adınız & Soyadınız (İsteğe bağlı)': {
        'en': 'Full Name (Optional)', 'de': 'Vollständiger Name (Optional)', 'fr': 'Nom complet (Facultatif)', 'es': 'Nombre completo (Opcional)', 'ru': 'Имя и фамилия (необязательно)'
      },
      'E-posta Adresiniz (Geri dönüş için)': {
        'en': 'Email Address (For reply)', 'de': 'E-Mail-Adresse (Für Rückfragen)', 'fr': 'Adresse e-mail (Pour réponse)', 'es': 'Correo electrónico (Para respuesta)', 'ru': 'Электронная почта (для ответа)'
      },
      'Mesajınız, Öneriniz veya Hata Bildirimi': {
        'en': 'Your message, suggestion, or bug report', 'de': 'Ihre Nachricht, Anregung oder Fehlermeldung', 'fr': 'Votre message, suggestion ou signalement', 'es': 'Tu mensaje, sugerencia o reporte de error', 'ru': 'Ваше сообщение, предложение или ошибка'
      },
      'Örn: Şu özellik eklense çok iyi olurdu...': {
        'en': 'E.g.: It would be great to add this feature...', 'de': 'Z.B.: Es wäre toll, wenn diese Funktion hinzugefügt würde...', 'fr': 'Ex: Ce serait super d\'ajouter cette fonctionnalité...', 'es': 'Ej: Sería genial si se añadiera esta función...', 'ru': 'Напр.: Было бы здорово добавить такую функцию...'
      },
      'v1.0.0 (Canlı)': {
        'en': 'v1.0.0 (Live)', 'de': 'v1.0.0 (Live)', 'fr': 'v1.0.0 (En direct)', 'es': 'v1.0.0 (En vivo)', 'ru': 'v1.0.0 (Релиз)'
      },
      '(Canlı)': {
        'en': '(Live)', 'de': '(Live)', 'fr': '(En direct)', 'es': '(En vivo)', 'ru': '(Релиз)'
      },
      'PatiRehber Kullanıcısı': {
        'en': 'App User', 'de': 'App-Benutzer', 'fr': 'Utilisateur de l\'app', 'es': 'Usuario de la app', 'ru': 'Пользователь приложения'
      },
      'Uygulama İçi': {
        'en': 'In-App', 'de': 'In-App', 'fr': 'Dans l\'app', 'es': 'En la app', 'ru': 'В приложении'
      },

      // Health Records Screen
      'Toplam Kayıt': {
        'en': 'Total Records', 'de': 'Einträge gesamt', 'fr': 'Total dossiers', 'es': 'Registros totales', 'ru': 'Всего записей'
      },
      'Son Ziyaret': {
        'en': 'Last Visit', 'de': 'Letzter Besuch', 'fr': 'Dernière visite', 'es': 'Última visita', 'ru': 'Последний визит'
      },
      'Kontrol': {
        'en': 'Follow-up', 'de': 'Kontrolle', 'fr': 'Contrôle', 'es': 'Control', 'ru': 'Контроль'
      },
      'Kayıtlarda veya hekim adında ara...': {
        'en': 'Search in records or doctor name...', 'de': 'In Einträgen oder nach Tierarzt suchen...', 'fr': 'Rechercher dans les dossiers ou par vétérinaire...', 'es': 'Buscar en registros o nombre del veterinario...', 'ru': 'Поиск по записям или врачу...'
      },
      'Henüz Kayıt Yok': {
        'en': 'No Records Yet', 'de': 'Noch keine Einträge', 'fr': 'Aucun dossier pour le moment', 'es': 'Sin registros aún', 'ru': 'Пока нет записей'
      },
      'Bu evcil dostunuz için henüz bir sağlık geçmişi bulunmuyor. Yeni bir kayıt ekleyerek başlayabilirsiniz.': {
        'en': 'No health history found for this pet yet. You can start by adding a new record.', 'de': 'Für dieses Haustier liegt noch keine Gesundheitshistorie vor. Beginnen Sie mit einem neuen Eintrag.', 'fr': 'Aucun historique médical pour cet animal. Commencez par ajouter un nouveau dossier.', 'es': 'Aún no hay historial médico para esta mascota. Puedes comenzar agregando un nuevo registro.', 'ru': 'Для этого питомца пока нет истории здоровья. Начните с добавления первой записи.'
      },
      'İlk Kaydı Oluştur': {
        'en': 'Create First Record', 'de': 'Ersten Eintrag erstellen', 'fr': 'Créer le premier dossier', 'es': 'Crear primer registro', 'ru': 'Создать первую запись'
      },
      'Kayıtlı ilaç bulunmuyor.': {
        'en': 'No medications registered.', 'de': 'Keine Medikamente registriert.', 'fr': 'Aucun médicament enregistré.', 'es': 'No hay medicamentos registrados.', 'ru': 'Нет сохраненных лекарств.'
      },

      // Sitters & Chat
      'Aramanıza uygun bakıcı bulunamadı.': {
        'en': 'No pet sitters found matching your search.', 'de': 'Keine passenden Tiersitter gefunden.', 'fr': 'Aucun gardien trouvé pour votre recherche.', 'es': 'No se encontraron cuidadores que coincidan con la búsqueda.', 'ru': 'Подходящие ситтеры не найдены.'
      },
      'Şehir, İlçe veya İsim Ara...': {
        'en': 'Search City, District or Name...', 'de': 'Stadt, Bezirk oder Name suchen...', 'fr': 'Rechercher ville, quartier ou nom...', 'es': 'Buscar ciudad, distrito o nombre...', 'ru': 'Поиск по городу, району или имени...'
      },
      'Profili İncele & Mesaj Gönder': {
        'en': 'View Profile & Send Message', 'de': 'Profil ansehen & Nachricht senden', 'fr': 'Voir le profil & Envoyer un message', 'es': 'Ver perfil y enviar mensaje', 'ru': 'Посмотреть профиль и написать'
      },
      'Bakıcı Profili': {
        'en': 'Sitter Profile', 'de': 'Sitter-Profil', 'fr': 'Profil du gardien', 'es': 'Perfil del cuidador', 'ru': 'Профиль ситтера'
      },
      'Hakkında': {
        'en': 'About', 'de': 'Über mich', 'fr': 'À propos', 'es': 'Acerca de', 'ru': 'О себе'
      },
      'Hizmetler ve Ücretlendirme': {
        'en': 'Services & Pricing', 'de': 'Leistungen & Preise', 'fr': 'Services & Tarifs', 'es': 'Servicios y tarifas', 'ru': 'Услуги и стоимость'
      },
      'İletişim Bilgileri': {
        'en': 'Contact Information', 'de': 'Kontaktdaten', 'fr': 'Coordonnées', 'es': 'Información de contacto', 'ru': 'Контактная информация'
      },
      'Telefon Numarası': {
        'en': 'Phone Number', 'de': 'Telefonnummer', 'fr': 'Numéro de téléphone', 'es': 'Número de teléfono', 'ru': 'Номер телефона'
      },
      'Mesaj Gönder / Sohbet Başlat': {
        'en': 'Send Message / Start Chat', 'de': 'Nachricht senden / Chat starten', 'fr': 'Envoyer un message / Démarrer le chat', 'es': 'Enviar mensaje / Iniciar chat', 'ru': 'Отправить сообщение / Начать чат'
      },
      'Günlük Yürüyüş': {
        'en': 'Daily Walk', 'de': 'Täglicher Spaziergang', 'fr': 'Promenade quotidienne', 'es': 'Paseo diario', 'ru': 'Ежедневный выгул'
      },
      'Evde Bakım': {
        'en': 'Home Sitting', 'de': 'Betreuung zu Hause', 'fr': 'Garde à domicile', 'es': 'Cuidado a domicilio', 'ru': 'Уход на дому'
      },
      'Köpek Gezdirme': {
        'en': 'Dog Walking', 'de': 'Gassigehen', 'fr': 'Promenade de chien', 'es': 'Paseo de perros', 'ru': 'Выгул собак'
      },
      'Park Eğitimi': {
        'en': 'Park Training', 'de': 'Park-Training', 'fr': 'Entraînement au parc', 'es': 'Entrenamiento en parque', 'ru': 'Дрессировка в парке'
      },
      'Saatlik': {
        'en': 'Hourly', 'de': 'Stündlich', 'fr': 'À l\'heure', 'es': 'Por hora', 'ru': 'Почасовой'
      },
      'Günlük': {
        'en': 'Daily', 'de': 'Täglich', 'fr': 'Par jour', 'es': 'Diario', 'ru': 'Посуточный'
      },
      'Profesyonel Bakıcı Ol': {
        'en': 'Become a Professional Sitter', 'de': 'Professioneller Tiersitter werden', 'fr': 'Devenir gardien professionnel', 'es': 'Conviértete en cuidador profesional', 'ru': 'Стать профессиональным ситтером'
      },
      'PatiRehber ailesine katılın! Başvurunuz yöneticilerimiz tarafından incelendikten sonra sistemde yer alacaktır.': {
        'en': 'Join our family! Your application will be listed once reviewed by administrators.', 'de': 'Werden Sie Teil unserer Familie! Ihr Antrag wird nach Prüfung freigeschaltet.', 'fr': 'Rejoignez notre famille ! Votre candidature sera publiée après validation.', 'es': '¡Únete a nuestra familia! Tu solicitud se listará tras la revisión.', 'ru': 'Присоединяйтесь к нашей семье! Заявка появится после проверки.'
      },
      'Ad Soyad': {
        'en': 'Full Name', 'de': 'Vor- und Nachname', 'fr': 'Nom et prénom', 'es': 'Nombre y apellido', 'ru': 'Имя и фамилия'
      },
      'Kendinizden Bahsedin (Bio)': {
        'en': 'Tell Us About Yourself (Bio)', 'de': 'Erzählen Sie über sich (Bio)', 'fr': 'Présentez-vous (Bio)', 'es': 'Cuéntanos sobre ti (Bio)', 'ru': 'Расскажите о себе (Био)'
      },
      'İl': {
        'en': 'City', 'de': 'Stadt', 'fr': 'Ville', 'es': 'Ciudad', 'ru': 'Город'
      },
      'İlçe': {
        'en': 'District', 'de': 'Bezirk', 'fr': 'Quartier', 'es': 'Distrito', 'ru': 'Район'
      },
      'Saatlik Ücretiniz (₺)': {
        'en': 'Hourly Rate', 'de': 'Stundensatz', 'fr': 'Tarif horaire', 'es': 'Tarifa por hora', 'ru': 'Почасовая ставка'
      },
      'Telefon Numaranız': {
        'en': 'Phone Number', 'de': 'Telefonnummer', 'fr': 'Numéro de téléphone', 'es': 'Número de teléfono', 'ru': 'Номер телефона'
      },
      'Numaranız profilinizde GİZLİ kalacaktır. Sadece siz isterseniz mesajlarda paylaşabilirsiniz.': {
        'en': 'Your number will remain PRIVATE. You only share it in messages if you choose to.', 'de': 'Ihre Nummer bleibt GEHEIM. Sie entscheiden selbst, ob Sie sie im Chat teilen.', 'fr': 'Votre numéro restera CONFIDENTIEL. Vous ne le partagez dans les messages que si vous le souhaitez.', 'es': 'Tu número permanecerá PRIVADO. Solo lo compartirás en los mensajes si lo deseas.', 'ru': 'Ваш номер останется СКРЫТЫМ. Вы делитесь им только по желанию.'
      },
      'Başvuruyu Tamamla': {
        'en': 'Submit Application', 'de': 'Bewerbung einreichen', 'fr': 'Finaliser la candidature', 'es': 'Enviar solicitud', 'ru': 'Отправить заявку'
      },
      'Başvurunuz başarıyla alındı! Yönetici onayından sonra listeleneceksiniz.': {
        'en': 'Application received! You will be listed after administrator approval.', 'de': 'Bewerbung erfolgreich eingereicht! Freischaltung erfolgt nach Prüfung.', 'fr': 'Candidature reçue avec succès ! Vous serez listé après approbation.', 'es': '¡Solicitud recibida con éxito! Aparecerás tras la aprobación.', 'ru': 'Заявка успешно принята! Вы появитесь в списке после одобрения.'
      },
      'Güvenli İletişim': {
        'en': 'Secure Communication', 'de': 'Sichere Kommunikation', 'fr': 'Communication sécurisée', 'es': 'Comunicación segura', 'ru': 'Безопасное общение'
      },
      'Numaranız siz paylaşana kadar gizlidir. Yalnızca güvendiğiniz kişilerle numaranızı paylaşın.': {
        'en': 'Your number is hidden until you share it. Only share it with people you trust.', 'de': 'Ihre Nummer bleibt verborgen, bis Sie sie teilen. Nur vertrauenswürdigen Kontakten mitteilen.', 'fr': 'Votre numéro est caché jusqu\'à ce que vous le partagiez. Ne le donnez qu\'aux personnes de confiance.', 'es': 'Tu número se mantiene oculto hasta que lo compartas. Compártelo solo con personas de confianza.', 'ru': 'Номер скрыт, пока вы сами им не поделитесь.'
      },
      'Anladım': {
        'en': 'Got it', 'de': 'Verstanden', 'fr': 'Compris', 'es': 'Entendido', 'ru': 'Понятно'
      },
      'Numaramı Güvenle Paylaş': {
        'en': 'Share My Number Securely', 'de': 'Nummer sicher teilen', 'fr': 'Partager mon numéro en sécurité', 'es': 'Compartir mi número con seguridad', 'ru': 'Безопасно поделиться номером'
      },
      'Mesaj yazın...': {
        'en': 'Type a message...', 'de': 'Nachricht schreiben...', 'fr': 'Écrire un message...', 'es': 'Escribe un mensaje...', 'ru': 'Введите сообщение...'
      },
      'Şu an aktif': {
        'en': 'Active now', 'de': 'Jetzt aktiv', 'fr': 'Actif maintenant', 'es': 'Activo ahora', 'ru': 'В сети'
      },
      'Güvenlik Bilgisi': {
        'en': 'Security Info', 'de': 'Sicherheitsinformation', 'fr': 'Informations de sécurité', 'es': 'Información de seguridad', 'ru': 'Информация о безопасности'
      },
      'Mesajlarınız uçtan uca şifrelidir. Gizliliğiniz için numaranızı sadece güvendiğinizde paylaşın.': {
        'en': 'Messages are encrypted. For your privacy, only share your phone number when you trust.', 'de': 'Nachrichten sind verschlüsselt. Teilen Sie Ihre Nummer nur bei berechtigtem Vertrauen.', 'fr': 'Messages chiffrés. Pour votre confidentialité, ne partagez votre numéro que si vous avez confiance.', 'es': 'Los mensajes están encriptados. Por privacidad, solo comparte tu número si confías.', 'ru': 'Сообщения зашифрованы. Делитесь номером только при доверии.'
      },
      'Numaranız güvenle paylaşıldı.': {
        'en': 'Your phone number was securely shared.', 'de': 'Ihre Telefonnummer wurde sicher geteilt.', 'fr': 'Votre numéro a été partagé en toute sécurité.', 'es': 'Tu número de teléfono se compartió de forma segura.', 'ru': 'Номер телефона безопасно передан.'
      },
      'Merhaba, evcil dostunuzla ilgilenmek için buradayım. Aklınıza takılan bir şey var mı?': {
        'en': 'Hello! I am here to care for your pet. Do you have any questions?', 'de': 'Hallo! Ich bin hier, um mich um Ihr Haustier zu kümmern. Haben Sie Fragen?', 'fr': 'Bonjour ! Je suis là pour m\'occuper de votre compagnon. Avez-vous des questions ?', 'es': '¡Hola! Estoy aquí para cuidar de tu mascota. ¿Tienes alguna pregunta?', 'ru': 'Здравствуйте! Я готов позаботиться о вашем питомце. Есть ли у вас вопросы?'
      },
      'Anlıyorum. Detayları yüz yüze veya telefonda da görüşebiliriz.': {
        'en': 'I understand. We can also discuss details in person or over the phone.', 'de': 'Verstehe. Wir können Details auch persönlich oder telefonisch besprechen.', 'fr': 'Je comprends. Nous pouvons aussi échanger de vive voix ou par téléphone.', 'es': 'Entiendo. También podemos hablar de los detalles en persona o por teléfono.', 'ru': 'Понимаю. Мы также можем обсудить детали лично или по телефону.'
      },
      'Şimdi': {
        'en': 'Now', 'de': 'Jetzt', 'fr': 'Maintenant', 'es': 'Ahora', 'ru': 'Сейчас'
      },

      // Knowledge Base & Pet Breeds
      'Tür Seçimi': {
        'en': 'Species Selection', 'de': 'Tierart-Auswahl', 'fr': 'Choix de l\'espèce', 'es': 'Selección de especie', 'ru': 'Выбор вида'
      },
      'İçerik bulunamadı.': {
        'en': 'No content found.', 'de': 'Kein Inhalt gefunden.', 'fr': 'Aucun contenu trouvé.', 'es': 'No se encontró contenido.', 'ru': 'Контент не найден.'
      },
      'Kemirgen': {
        'en': 'Rodent', 'de': 'Nagetier', 'fr': 'Rongeur', 'es': 'Roedor', 'ru': 'Грызуны'
      },
      'Balık': {
        'en': 'Fish', 'de': 'Fisch', 'fr': 'Poisson', 'es': 'Pez', 'ru': 'Рыбы'
      },
      'Hamster': {
        'en': 'Hamster', 'de': 'Hamster', 'fr': 'Hamster', 'es': 'Hámster', 'ru': 'Хомяк'
      },
      'Kuş': {
        'en': 'Bird', 'de': 'Vogel', 'fr': 'Oiseau', 'es': 'Pájaro', 'ru': 'Птица'
      },
      'Tavşan': {
        'en': 'Rabbit', 'de': 'Kaninchen', 'fr': 'Lapin', 'es': 'Conejo', 'ru': 'Кролик'
      },
      'Kedi': {
        'en': 'Cat', 'de': 'Katze', 'fr': 'Chat', 'es': 'Gato', 'ru': 'Кошка'
      },
      'Köpek': {
        'en': 'Dog', 'de': 'Hund', 'fr': 'Chien', 'es': 'Perro', 'ru': 'Собака'
      },
      'Diğer': {
        'en': 'Other', 'de': 'Andere', 'fr': 'Autre', 'es': 'Otro', 'ru': 'Другое'
      },
      'Muhabbet Kuşu': {
        'en': 'Budgerigar', 'de': 'Wellensittich', 'fr': 'Perruche ondulée', 'es': 'Periquito', 'ru': 'Волнистый попугай'
      },
      'Hollanda Lop': {
        'en': 'Holland Lop', 'de': 'Zwergwidder', 'fr': 'Bélier néerlandais', 'es': 'Belier enano', 'ru': 'Голландский вислоухий'
      },
      'Suriye Hamsterı': {
        'en': 'Syrian Hamster', 'de': 'Goldhamster', 'fr': 'Hamster syrien', 'es': 'Hámster sirio', 'ru': 'Сирийский хомяк'
      },
      'Tavuk Proteini': {
        'en': 'Chicken Protein', 'de': 'Geflügelprotein', 'fr': 'Protéine de poulet', 'es': 'Proteína de pollo', 'ru': 'Куриный белок'
      },
      'Tahıl & Şekerli Meyveler': {
        'en': 'Grains & Sugary Fruits', 'de': 'Getreide & zuckerhaltige Früchte', 'fr': 'Céréales & Fruits sucrés', 'es': 'Cereales y frutas azucaradas', 'ru': 'Зерновые и сладкие фрукты'
      },
      'İdeal kilo': {
        'en': 'Ideal weight', 'de': 'Idealgewicht', 'fr': 'Poids idéal', 'es': 'Peso ideal', 'ru': 'Идеальный вес'
      },
      'Düzenli egzersiz': {
        'en': 'Regular exercise', 'de': 'Regelmäßige Bewegung', 'fr': 'Exercice régulier', 'es': 'Ejercicio regular', 'ru': 'Регулярные нагрузки'
      },
      'Kısır kedi standart': {
        'en': 'Neutered cat standard', 'de': 'Standard für kastrierte Katzen', 'fr': 'Standard chat stérilisé', 'es': 'Estándar de gato esterilizado', 'ru': 'Норма для стерилизованных кошек'
      },
      'Gelişim iyi': {
        'en': 'Good growth', 'de': 'Gutes Wachstum', 'fr': 'Bonne croissance', 'es': 'Buen desarrollo', 'ru': 'Хорошее развитие'
      },
      'Sabit': {
        'en': 'Stable', 'de': 'Stabil', 'fr': 'Stable', 'es': 'Estable', 'ru': 'Стабильно'
      },
      'Normal (40 gram)': {
        'en': 'Normal (40 grams)', 'de': 'Normal (40 Gramm)', 'fr': 'Normal (40 grammes)', 'es': 'Normal (40 gramos)', 'ru': 'Норма (40 грамм)'
      },

      // Pet Notes & Nutrition
      'Sıcak havalarda çabuk yorulur. Tüy döküm mevsiminde günde 2 kez taranmalı. Çok sevecen ve enerjik.': {
        'en': 'Tires easily in hot weather. Should be brushed twice daily during shedding season. Very affectionate and energetic.', 'de': 'Wird bei Hitze schnell müde. Im Fellwechsel 2x täglich bürsten. Sehr anhänglich und energiegeladen.', 'fr': 'Se fatigue vite par temps chaud. À brosser 2 fois par jour en mue. Très affectueux et plein d\'énergie.', 'es': 'Se cansa rápido con el calor. Cepillar 2 veces al día en época de muda. Muy cariñoso y enérgico.', 'ru': 'В жару быстро утомляется. В период линьки вычесывать 2 раза в день. Очень ласковый и активный.'
      },
      'Yaş mamayı çok seviyor. Akşamları hareketli oyunlar oynamayı tercih ediyor.': {
        'en': 'Loves wet food. Prefers active playtime in the evenings.', 'de': 'Liebt Nassfutter. Bevorzugt abends aktives Spielen.', 'fr': 'Adore la pâtée humide. Préfère les jeux actifs en soirée.', 'es': 'Le encanta la comida húmeda. Prefiere juegos activos por las noches.', 'ru': 'Очень любит влажный корм. По вечерам предпочитает активные игры.'
      },
      'Cici kuş ve Babacık kelimelerini söylüyor. Dal darı ödülü verildiğinde hemen ele geliyor.': {
        'en': 'Says cute phrases. Readily hops onto hands when offered millet spray treat.', 'de': 'Spricht kleine Wörter nach. Kommt sofort auf die Hand, wenn Kolbenhirse angeboten wird.', 'fr': 'Répète des mots affectueux. Vient sur la main dès qu\'on lui offre du millet.', 'es': 'Dice frases cariñosas. Se sube a la mano de inmediato cuando se le ofrece mijo.', 'ru': 'Говорит забавные слова. Охотно идет на руку за лакомством из проса.'
      },
      'Beslenmesinin %85’i kuru çayır otu olmalı. Kabloları kemirmemesi için koruyucu kullanılıyor.': {
        'en': '85% of diet must be hay. Cable protectors are used to prevent chewing.', 'de': '85 % der Ernährung muss Heu sein. Kabelschutz wird verwendet, um Knabbern zu verhindern.', 'fr': '85 % de l\'alimentation doit être du foin. Des protège-câbles évitent les grignotages.', 'es': 'El 85% de la dieta debe ser heno. Se usan protectores para evitar que muerda cables.', 'ru': '85% рациона должно составлять сено. Используется защита проводов от перегрызания.'
      },
      'Gece aktif olur. Gündüz uyurken rahatsız edilmemelidir. Çarkında koşmayı çok sever.': {
        'en': 'Active at night. Do not disturb daytime sleep. Loves running on the wheel.', 'de': 'Nachtaktiv. Tagsüber beim Schlafen nicht stören. Liebt das Laufrad.', 'fr': 'Actif la nuit. Ne pas déranger pendant son sommeil le jour. Adore sa roue.', 'es': 'Activo por la noche. No molestar mientras duerme de día. Le encanta correr en su rueda.', 'ru': 'Ночная активность. Не беспокоить во время дневного сна. Очень любит бегать в колесе.'
      },
      'Tahılsız Kuzu Etli Kuru Mama': {
        'en': 'Grain-Free Lamb Dry Food', 'de': 'Getreidefreies Trockenfutter mit Lamm', 'fr': 'Croquettes sans céréales à l\'agneau', 'es': 'Pienso sin cereales con cordero', 'ru': 'Беззерновой сухой корм с ягненком'
      },
      'Kısırlaştırılmış Somonlu Kuru Mama': {
        'en': 'Sterilised Salmon Dry Food', 'de': 'Trockenfutter für kastrierte Katzen mit Lachs', 'fr': 'Croquettes au saumon pour chat stérilisé', 'es': 'Pienso de salmón para gatos esterilizados', 'ru': 'Сухой корм с лососем для стерилизованных'
      },
      'Karışık Tohum & Pelet Yem': {
        'en': 'Mixed Seeds & Pellet Feed', 'de': 'Körnermischung & Pelletfutter', 'fr': 'Mélange de graines & granulés', 'es': 'Semillas mixtas y pienso extrusionado', 'ru': 'Смесь семян и гранулированный корм'
      },
      'Kuru Çayır Otu + Pelet Yem': {
        'en': 'Meadow Hay + Pellet Feed', 'de': 'Wiesenheu + Pelletfutter', 'fr': 'Foin de prairie + granulés', 'es': 'Heno de prado + pienso en pellets', 'ru': 'Луговое сено + гранулы'
      },
      'Tavuk içerikli hiçbir mama ve ödül verilmeyecek.': {
        'en': 'No food or treats containing chicken should be given.', 'de': 'Kein Futter oder Leckerli mit Huhn füttern.', 'fr': 'Ne donner aucun aliment ni friandise contenant du poulet.', 'es': 'No dar alimentos ni premios con pollo.', 'ru': 'Не давать корм и лакомства, содержащие курицу.'
      },
      'Haftada 2 kez yaş mama ödülü verilir.': {
        'en': 'Wet food treat given twice a week.', 'de': 'Nassfutter als Belohnung 2x pro Woche.', 'fr': 'Pâtée humide offerte 2 fois par semaine.', 'es': 'Premio de comida húmeda 2 veces por semana.', 'ru': 'Влажный корм в качестве лакомства 2 раза в неделю.'
      },
      'Günde 1 dilim elma veya havuç rendesi takviye edilir.': {
        'en': 'Supplemented with 1 slice of apple or grated carrot daily.', 'de': 'Täglich 1 Scheibe Apfel oder geriebene Karotte als Ergänzung.', 'fr': '1 tranche de pomme ou carotte râpée ajoutée chaque jour.', 'es': 'Suplementado con 1 rodaja de manzana o zanahoria rallada al día.', 'ru': 'Добавляется 1 долька яблока или тертая морковь в день.'
      },
      'Samanlığı 24 saat dolu tutulmalıdır. Marul ve maydanoz az miktarda verilir.': {
        'en': 'Hay rack must stay full 24/7. Lettuce and parsley given in moderation.', 'de': 'Heuraufe rund um die Uhr füllen. Salat und Petersilie sparsam anbieten.', 'fr': 'Râtelier à foin toujours plein. Laitue et persil en petites quantités.', 'es': 'La henera debe estar llena las 24 horas. Lechuga y perejil en poca cantidad.', 'ru': 'Сенник должен быть полон 24/7. Салат и петрушка в малых количествах.'
      },

      // Auth
      'Giriş Yap': {
        'en': 'Sign In', 'de': 'Anmelden', 'fr': 'Se connecter', 'es': 'Iniciar sesión', 'ru': 'Войти'
      },
      'Kayıt Ol': {
        'en': 'Sign Up', 'de': 'Registrieren', 'fr': 'S\'inscrire', 'es': 'Registrarse', 'ru': 'Регистрация'
      },
      'E-posta': {
        'en': 'Email', 'de': 'E-Mail', 'fr': 'E-mail', 'es': 'Correo electrónico', 'ru': 'Эл. почта'
      },
      'Şifre': {
        'en': 'Password', 'de': 'Passwort', 'fr': 'Mot de passe', 'es': 'Contraseña', 'ru': 'Пароль'
      },
      'Giriş başarısız oldu. Bilgileri kontrol edin.': {
        'en': 'Sign in failed. Please check your credentials.', 'de': 'Anmeldung fehlgeschlagen. Bitte Daten prüfen.', 'fr': 'Échec de connexion. Vérifiez vos identifiants.', 'es': 'Error al iniciar sesión. Comprueba tus datos.', 'ru': 'Не удалось войти. Проверьте данные.'
      },
      'Kayıt başarısız oldu. Geçerli bir e-posta girin.': {
        'en': 'Sign up failed. Please enter a valid email.', 'de': 'Registrierung fehlgeschlagen. Bitte gültige E-Mail angeben.', 'fr': 'Échec de l\'inscription. Entrez un e-mail valide.', 'es': 'Error en el registro. Introduce un correo válido.', 'ru': 'Ошибка регистрации. Введите корректный адрес эл. почты.'
      },
      'Numaranı Paylaş (Sadece Bakıcı İçin)': {
        'en': 'Share Number (Sitter Only)', 'de': 'Nummer teilen (Nur Sitter)', 'fr': 'Partager le numéro (Gardien uniquement)', 'es': 'Compartir número (Solo cuidador)', 'ru': 'Поделиться номером (только ситтер)'
      },
      'Güvenli sohbete başlayın.\nTelefon numaraları asla izinsiz paylaşılmaz.': {
        'en': 'Start a secure chat.\nPhone numbers are never shared without permission.', 'de': 'Starten Sie einen sicheren Chat.\nNummern werden nie ohne Erlaubnis geteilt.', 'fr': 'Démarrez un chat sécurisé.\nLes numéros ne sont jamais partagés sans accord.', 'es': 'Inicia un chat seguro.\nLos números nunca se comparten sin permiso.', 'ru': 'Начните безопасный чат.\nНомера телефонов никогда не передаются без согласия.'
      },
      'Mesajınızı yazın...': {
        'en': 'Type your message...', 'de': 'Schreiben Sie Ihre Nachricht...', 'fr': 'Écrivez votre message...', 'es': 'Escribe tu mensaje...', 'ru': 'Введите ваше сообщение...'
      },
      'Yönetici Paneli': {
        'en': 'Admin Dashboard', 'de': 'Admin-Bereich', 'fr': 'Panneau d\'administration', 'es': 'Panel de administración', 'ru': 'Панель администратора'
      },
      'Gelen Kutusu': {
        'en': 'Inbox', 'de': 'Posteingang', 'fr': 'Boîte de réception', 'es': 'Bandeja de entrada', 'ru': 'Входящие'
      },
      'Bekleyen bakıcı başvurusu yok.': {
        'en': 'No pending sitter applications.', 'de': 'Keine ausstehenden Sitter-Bewerbungen.', 'fr': 'Aucune candidature de gardien en attente.', 'es': 'No hay solicitudes de cuidadores pendientes.', 'ru': 'Нет ожидающих заявок ситтеров.'
      },
      'Geliştirici Gelen Kutusu': {
        'en': 'Developer Inbox', 'de': 'Entwickler-Posteingang', 'fr': 'Boîte de réception développeur', 'es': 'Bandeja del desarrollador', 'ru': 'Входящие разработчика'
      },
      'Kullanıcı Geri Bildirimleri': {
        'en': 'User Feedback', 'de': 'Benutzer-Feedback', 'fr': 'Retours utilisateurs', 'es': 'Comentarios de usuarios', 'ru': 'Отзывы пользователей'
      },
      'Henüz gelen geri bildirim yok': {
        'en': 'No feedback yet', 'de': 'Noch kein Feedback', 'fr': 'Aucun retour pour le moment', 'es': 'Sin comentarios aún', 'ru': 'Пока нет отзывов'
      },
      'Kullanıcılar Profil ekranındaki formdan mesaj gönderdiklerinde burada canlı ve ücretsiz listelenecektir.': {
        'en': 'When users send messages from the profile form, they will appear here live.', 'de': 'Wenn Benutzer Nachrichten senden, erscheinen sie hier live.', 'fr': 'Les messages envoyés depuis le profil apparaîtront ici en direct.', 'es': 'Cuando los usuarios envíen mensajes desde el perfil, aparecerán aquí en vivo.', 'ru': 'Когда пользователи отправят сообщение, оно появится здесь.'
      },
      'E-posta ile Yanıt Yaz': {
        'en': 'Reply via Email', 'de': 'Per E-Mail antworten', 'fr': 'Répondre par e-mail', 'es': 'Responder por correo', 'ru': 'Ответить по эл. почте'
      },
      'Mesaj silindi.': {
        'en': 'Message deleted.', 'de': 'Nachricht gelöscht.', 'fr': 'Message supprimé.', 'es': 'Mensaje eliminado.', 'ru': 'Сообщение удалено.'
      },

      // Navigation & Header
      'Dostunu Ekle': {
        'en': 'Add Pet', 'de': 'Tier hinzufügen', 'fr': 'Ajouter un animal', 'es': 'Añadir mascota', 'ru': 'Добавить питомца'
      },
      'Aşı': {
        'en': 'Vaccines', 'de': 'Impfungen', 'fr': 'Vaccins', 'es': 'Vacunas', 'ru': 'Прививки'
      },
      'Henüz Kayıtlı Bir Dostun Yok': {
        'en': 'No Registered Pets Yet', 'de': 'Noch kein Haustier registriert', 'fr': 'Aucun animal enregistré', 'es': 'Aún no tienes mascotas', 'ru': 'У вас пока нет питомцев'
      },
      'Köpeğin, kedin, kuşun veya diğer dostların için dijital aşı pasaportu, kilo grafiği ve resmi sağlık karnesi oluşturmak için hemen başla.': {
        'en': 'Start now to create a digital vaccine passport, weight chart, and official health record for your dog, cat, or bird.',
        'de': 'Erstelle jetzt einen digitalen Impfpass, Gewichtskurven und offizielle Gesundheitsakten für dein Haustier.',
        'fr': 'Commencez dès maintenant pour créer un passeport vaccinal numérique, une courbe de poids et un carnet de santé officiel.',
        'es': 'Comienza ahora a crear un pasaporte de vacunación digital, gráfico de peso y cartilla oficial de salud.',
        'ru': 'Создайте цифровой ветеринарный паспорт, график веса и официальную медкарту для вашего питомца.'
      },
      '🐾 İlk Evcil Dostumu Ekle': {
        'en': '🐾 Add My First Pet', 'de': '🐾 Erstes Haustier hinzufügen', 'fr': '🐾 Ajouter mon premier animal', 'es': '🐾 Añadir mi primera mascota', 'ru': '🐾 Добавить первого питомца'
      },
      '🐾 Evcil Dostumu Ekle': {
        'en': '🐾 Add My Pet', 'de': '🐾 Haustier hinzufügen', 'fr': '🐾 Ajouter mon animal', 'es': '🐾 Añadir mi mascota', 'ru': '🐾 Добавить питомца'
      },
      '💡 Örnek Veriyle İncele (Demo)': {
        'en': '💡 Explore with Demo Data', 'de': '💡 Mit Beispieldaten erkunden', 'fr': '💡 Explorer avec données de démo', 'es': '💡 Explorar con datos demo', 'ru': '💡 Попробовать с демо-данными'
      },
      '💡 Örnek Demo Verilerini Yükle': {
        'en': '💡 Load Sample Demo Data', 'de': '💡 Beispieldaten laden', 'fr': '💡 Charger les données de démo', 'es': '💡 Cargar datos de muestra', 'ru': '💡 Загрузить демо-данные'
      },
      'Örnek evcil dostlar (Max, Luna, Maviş) yüklendi!': {
        'en': 'Sample pets (Max, Luna, Mavis) loaded!', 'de': 'Beispiel-Haustiere (Max, Luna, Mavis) geladen!', 'fr': 'Animaux de démo (Max, Luna, Mavis) chargés !', 'es': '¡Mascotas de muestra (Max, Luna, Mavis) cargadas!', 'ru': 'Демо-питомцы (Макс, Луна, Мавиш) загружены!'
      },
      'Henüz kayıtlı bir evcil hayvanın yok.': {
        'en': 'No pets registered yet.', 'de': 'Noch kein Haustier registriert.', 'fr': 'Aucun animal enregistré.', 'es': 'No tienes mascotas registradas.', 'ru': 'У вас пока нет зарегистрированных питомцев.'
      },
      'Resmi Uluslararası PDF Pasaport': {
        'en': 'Official International PDF Passport', 'de': 'Offizieller internationaler PDF-Pass', 'fr': 'Passeport PDF international officiel', 'es': 'Pasaporte PDF internacional oficial', 'ru': 'Официальный международный PDF-паспорт'
      },
      'QR kodlu ve onaylı resmi A4 aşı çıktısı': {
        'en': 'Approved official A4 vaccination printout with QR code', 'de': 'Offizieller A4-Impfausdruck mit QR-Code', 'fr': 'Impression vaccinale A4 officielle avec QR code', 'es': 'Certificado oficial de vacunación A4 con QR', 'ru': 'Официальная распечатка А4 с QR-кодом'
      },
      'Aşı ve Doz Takvim Alarmı': {
        'en': 'Vaccine & Dose Calendar Alarm', 'de': 'Impf- & Dosierungsalarm', 'fr': 'Alarme vaccins et calendrier de doses', 'es': 'Alarma de vacunas y calendario de dosis', 'ru': 'Напоминания о прививках и дозах'
      },
      'Karma, kuduz, parazit dozları asla unutulmaz': {
        'en': 'Never forget core, rabies, and parasite treatments', 'de': 'Verpasse nie wieder Impfungen oder Wurmkuren', 'fr': 'N\'oubliez jamais les vaccins ou antiparasitaires', 'es': 'No olvides nunca las vacunas o desparasitaciones', 'ru': 'Никогда не забывайте о прививках и обработках'
      },
      'Kilo ve Gelişim Grafiği': {
        'en': 'Weight & Growth Chart', 'de': 'Gewichts- & Wachstumskurve', 'fr': 'Courbe de poids et croissance', 'es': 'Gráfico de peso y crecimiento', 'ru': 'График веса и развития'
      },
      'İdeal kilo değişimlerini tarihsel izleyin': {
        'en': 'Track ideal weight changes over time', 'de': 'Verfolge Gewichtsentwicklungen im Zeitverlauf', 'fr': 'Suivez l\'évolution du poids idéal dans le temps', 'es': 'Sigue el historial de variaciones de peso ideal', 'ru': 'Отслеживайте динамику веса во времени'
      },
      'Günü Gününe Sesli Alarm Aktif 🔔': {
        'en': 'Daily Audible Alarm Active 🔔', 'de': 'Täglicher Audio-Alarm aktiv 🔔', 'fr': 'Alarme sonore quotidienne active 🔔', 'es': 'Alarma de audio diaria activa 🔔', 'ru': 'Ежедневный звуковой будильник активен 🔔'
      },
      'Kayıtlı Evcil Dost Bulunamadı': {
        'en': 'No Registered Pet Found', 'de': 'Kein registriertes Haustier gefunden', 'fr': 'Aucun animal trouvé', 'es': 'No se encontró mascota registrada', 'ru': 'Питомец не найден'
      },
      'Aşı takvimini ve doz planlarını takip edebilmek için lütfen önce evcil hayvanını ekle.': {
        'en': 'Please add your pet first to track vaccination schedules and doses.', 'de': 'Bitte füge zuerst ein Haustier hinzu, um Impfpläne zu verwalten.', 'fr': 'Veuillez d\'abord ajouter un animal pour suivre les vaccins.', 'es': 'Por favor, añade primero una mascota para ver el calendario de vacunas.', 'ru': 'Пожалуйста, добавьте питомца для просмотра календаря прививок.'
      },
      'İlaç ve vitamin takibi yapabilmek için lütfen önce bir evcil hayvan ekle.': {
        'en': 'Please add a pet first to track medications and vitamins.', 'de': 'Bitte füge zuerst ein Haustier hinzu, um Medikamente und Vitamine zu erfassen.', 'fr': 'Veuillez d\'abord ajouter un animal pour suivre ses médicaments.', 'es': 'Por favor, añade primero una mascota para registrar medicamentos.', 'ru': 'Пожалуйста, добавьте питомца для отслеживания лекарств.'
      },
      'Veteriner randevularını ve muayene tarihlerini takip edebilmek için lütfen önce evcil hayvanını ekle.': {
        'en': 'Please add a pet first to track vet appointments and exams.', 'de': 'Bitte füge zuerst ein Haustier hinzu, um Tierarzttermine zu erfassen.', 'fr': 'Veuillez d\'abord ajouter un animal pour suivre les rendez-vous vétérinaires.', 'es': 'Por favor, añade primero una mascota para citas veterinarias.', 'ru': 'Пожалуйста, добавьте питомца для отслеживания визитов к ветеринару.'
      },
      'Muayene, tahlil ve ameliyat geçmişini kaydetmek için önce bir evcil hayvan ekle.': {
        'en': 'Add a pet first to record examinations, tests, and surgeries.', 'de': 'Füge zuerst ein Haustier hinzu, um Untersuchungsergebnisse zu speichern.', 'fr': 'Ajoutez d\'abord un animal pour enregistrer ses soins et analyses.', 'es': 'Añade una mascota para registrar consultas y cirugías.', 'ru': 'Добавьте питомца для сохранения истории осмотров и анализов.'
      },
      'Henüz bir eğitim hedefi eklenmedi.': {
        'en': 'No training goals added yet.', 'de': 'Noch keine Trainingsziele hinzugefügt.', 'fr': 'Aucun objectif de dressage ajouté.', 'es': 'Aún no hay objetivos de entrenamiento.', 'ru': 'Цели дрессировки еще не добавлены.'
      },
      'Bu kategoride henüz rehber bulunamadı.': {
        'en': 'No guides found in this category yet.', 'de': 'In dieser Kategorie wurden noch keine Anleitungen gefunden.', 'fr': 'Aucun guide trouvé dans cette catégorie.', 'es': 'No se encontraron guías en esta categoría.', 'ru': 'В этой категории пока нет руководств.'
      },

      // Comprehensive Nutrition Section
      'Günün Beslenme Rutini': {
        'en': 'Daily Feeding Routine', 'de': 'Tägliche Fütterungsroutine', 'fr': 'Routine alimentaire du jour', 'es': 'Rutina diaria de alimentación', 'ru': 'Дневной рацион питания'
      },
      'Bugün Tüketilen Kalori': {
        'en': 'Calories Consumed Today', 'de': 'Heute verzehrte Kalorien', 'fr': 'Calories consommées aujourd\'hui', 'es': 'Calorías consumidas hoy', 'ru': 'Калорий потреблено сегодня'
      },
      'Günlük Hedef': {
        'en': 'Daily Target', 'de': 'Tagesziel', 'fr': 'Objectif quotidien', 'es': 'Meta diaria', 'ru': 'Дневная цель'
      },
      'Kalan': {
        'en': 'Remaining', 'de': 'Verbleibend', 'fr': 'Restant', 'es': 'Restante', 'ru': 'Осталось'
      },
      'Günlük Su Tüketimi': {
        'en': 'Daily Water Intake', 'de': 'Tägliche Wasseraufnahme', 'fr': 'Consommation d\'eau quotidienne', 'es': 'Consumo diario de agua', 'ru': 'Потребление воды в день'
      },
      'Taze Su Takibi': {
        'en': 'Fresh Water Tracking', 'de': 'Frischwasser-Tracking', 'fr': 'Suivi eau fraîche', 'es': 'Seguimiento de agua fresca', 'ru': 'Контроль свежей воды'
      },
      'Su Kabı Yenilendi 💧': {
        'en': 'Water Refreshed 💧', 'de': 'Wasser erneuert 💧', 'fr': 'Eau rafraîchie 💧', 'es': 'Agua renovada 💧', 'ru': 'Вода обновлена 💧'
      },
      'Öğün Ekle': {
        'en': 'Add Meal', 'de': 'Mahlzeit hinzufügen', 'fr': 'Ajouter repas', 'es': 'Añadir comida', 'ru': 'Добавить прием пищи'
      },
      'Öğün Adı': {
        'en': 'Meal Name', 'de': 'Name der Mahlzeit', 'fr': 'Nom du repas', 'es': 'Nombre de la comida', 'ru': 'Название приема пищи'
      },
      'Mama / Yiyecek': {
        'en': 'Food / Ingredient', 'de': 'Futter / Zutat', 'fr': 'Nourriture / Ingrédient', 'es': 'Alimento / Comida', 'ru': 'Корм / Еда'
      },
      'Miktar (Gram)': {
        'en': 'Amount (Grams)', 'de': 'Menge (Gramm)', 'fr': 'Quantité (Grammes)', 'es': 'Cantidad (Gramos)', 'ru': 'Количество (граммы)'
      },
      'Kalori (kcal)': {
        'en': 'Calories (kcal)', 'de': 'Kalorien (kcal)', 'fr': 'Calories (kcal)', 'es': 'Calorías (kcal)', 'ru': 'Калории (ккал)'
      },
      'Saat': {
        'en': 'Time', 'de': 'Uhrzeit', 'fr': 'Heure', 'es': 'Hora', 'ru': 'Время'
      },
      'Verildi': {
        'en': 'Given', 'de': 'Gefüttert', 'fr': 'Donné', 'es': 'Dado', 'ru': 'Выдано'
      },
      'Bekliyor': {
        'en': 'Pending', 'de': 'Ausstehend', 'fr': 'En attente', 'es': 'Pendiente', 'ru': 'Ожидает'
      },
      'Zehirli ve Güvenli Gıdalar': {
        'en': 'Toxic & Safe Foods', 'de': 'Giftige & sichere Lebensmittel', 'fr': 'Aliments toxiques et sûrs', 'es': 'Alimentos tóxicos y seguros', 'ru': 'Опасные и безопасные продукты'
      },
      'Tüm Gıdalar': {
        'en': 'All Foods', 'de': 'Alle Lebensmittel', 'fr': 'Tous les aliments', 'es': 'Todos los alimentos', 'ru': 'Все продукты'
      },
      '🚫 Kesinlikle Yasak': {
        'en': '🚫 Strictly Forbidden', 'de': '🚫 Streng verboten', 'fr': '🚫 Strictement interdit', 'es': '🚫 Estrictamente prohibido', 'ru': '🚫 Строго запрещено'
      },
      '⚠️ Dikkatli Verilmeli': {
        'en': '⚠️ Give with Caution', 'de': '⚠️ Mit Vorsicht füttern', 'fr': '⚠️ Avec modération', 'es': '⚠️ Con precaución', 'ru': '⚠️ С осторожностью'
      },
      '✅ Güvenli ve Faydalı': {
        'en': '✅ Safe & Healthy', 'de': '✅ Sicher & gesund', 'fr': '✅ Sûr et sain', 'es': '✅ Seguro y saludable', 'ru': '✅ Безопасно и полезно'
      },
      'Besin Değerleri Dengesi': {
        'en': 'Nutritional Value Balance', 'de': 'Nährwert-Balance', 'fr': 'Équilibre nutritionnel', 'es': 'Balance nutricional', 'ru': 'Баланс питательных веществ'
      },
      'Protein': {
        'en': 'Protein', 'de': 'Protein', 'fr': 'Protéines', 'es': 'Proteína', 'ru': 'Белки'
      },
      'Sağlıklı Yağlar': {
        'en': 'Healthy Fats', 'de': 'Gesunde Fette', 'fr': 'Graisses saines', 'es': 'Grasas saludables', 'ru': 'Полезные жиры'
      },
      'Sindirim Lifi': {
        'en': 'Dietary Fiber', 'de': 'Ballaststoffe', 'fr': 'Fibres alimentaires', 'es': 'Fibra dietética', 'ru': 'Клетчатка'
      },
      'Nem & Sıvı': {
        'en': 'Moisture & Liquid', 'de': 'Feuchtigkeit & Wasser', 'fr': 'Humidité & Liquide', 'es': 'Humedad y líquido', 'ru': 'Влага и жидкость'
      },
      'Veteriner Beslenme Tavsiyeleri': {
        'en': 'Veterinary Nutrition Tips', 'de': 'Tierärztliche Ernährungstipps', 'fr': 'Conseils vétérinaires en nutrition', 'es': 'Consejos nutricionales del veterinario', 'ru': 'Советы ветеринара по питанию'
      },
      'Ödül & Çiğneme': {
        'en': 'Treats & Chews', 'de': 'Leckerlis & Kausnacks', 'fr': 'Friandises & À mâcher', 'es': 'Premios y masticables', 'ru': 'Лакомства'
      },
      'Vitamin & Takviye': {
        'en': 'Vitamins & Supplements', 'de': 'Vitamine & Zusätze', 'fr': 'Vitamines & Suppléments', 'es': 'Vitaminas y suplementos', 'ru': 'Витамины и добавки'
      },
      'Sabah Kahvaltısı': {
        'en': 'Morning Breakfast', 'de': 'Morgens / Frühstück', 'fr': 'Petit-déjeuner du matin', 'es': 'Desayuno de la mañana', 'ru': 'Утренний завтрак'
      },
      'Öğle Atıştırmalığı': {
        'en': 'Noon Snack', 'de': 'Mittagssnack', 'fr': 'Collation de midi', 'es': 'Bocadillo del mediodía', 'ru': 'Дневной перекус'
      },
      'Akşam Yemeği': {
        'en': 'Evening Dinner', 'de': 'Abendessen', 'fr': 'Dîner du soir', 'es': 'Cena de la noche', 'ru': 'Вечерний ужин'
      },
      'Gece Takviyesi': {
        'en': 'Night Supplement', 'de': 'Nacht-Zusatz', 'fr': 'Complément du soir', 'es': 'Suplemento nocturno', 'ru': 'Ночная добавка'
      },
      'Öğün tamamlandı olarak işaretlendi!': {
        'en': 'Meal marked as completed!', 'de': 'Mahlzeit als erledigt markiert!', 'fr': 'Repas marqué comme terminé !', 'es': '¡Comida marcada como completada!', 'ru': 'Прием пищи отмечен как завершенный!'
      },
      'Öğün durumu güncellendi.': {
        'en': 'Meal status updated.', 'de': 'Mahlzeitenstatus aktualisiert.', 'fr': 'Statut du repas mis à jour.', 'es': 'Estado de comida actualizado.', 'ru': 'Статус приема пищи обновлен.'
      },
      'Su tüketimi eklendi!': {
        'en': 'Water intake recorded!', 'de': 'Wasseraufnahme erfasst!', 'fr': 'Consommation d\'eau ajoutée !', 'es': '¡Consumo de agua registrado!', 'ru': 'Потребление воды добавлено!'
      },
      'Öğün silindi.': {
        'en': 'Meal removed.', 'de': 'Mahlzeit gelöscht.', 'fr': 'Repas supprimé.', 'es': 'Comida eliminada.', 'ru': 'Прием пищи удален.'
      },
      'Öğün Ekle / Düzenle': {
        'en': 'Add / Edit Meal', 'de': 'Mahlzeit hinzufügen / bearbeiten', 'fr': 'Ajouter / Modifier repas', 'es': 'Añadir / Editar comida', 'ru': 'Добавить / изменить прием пищи'
      },
      'Beslenme Planını Düzenle': {
        'en': 'Edit Nutrition Plan', 'de': 'Ernährungsplan bearbeiten', 'fr': 'Modifier le plan de nutrition', 'es': 'Editar plan de nutrición', 'ru': 'Редактировать план питания'
      },
      'Günlük Tüketim': {
        'en': 'Daily Consumption', 'de': 'Tagesverbrauch', 'fr': 'Consommation quotidienne', 'es': 'Consumo diario', 'ru': 'Суточное потребление'
      },
      'Günlük İdeal Su İhtiyacı': {
        'en': 'Ideal Daily Water Need', 'de': 'Idealer täglicher Wasserbedarf', 'fr': 'Besoin quotidien idéal en eau', 'es': 'Necesidad diaria ideal de agua', 'ru': 'Суточная норма воды'
      },
      'kg başına ~50-60 ml': {
        'en': '~50-60 ml per kg', 'de': '~50-60 ml pro kg', 'fr': '~50-60 ml par kg', 'es': '~50-60 ml por kg', 'ru': '~50-60 мл на кг'
      },
      'Su Ekle': {
        'en': 'Add Water', 'de': 'Wasser hinzufügen', 'fr': 'Ajouter de l\'eau', 'es': 'Añadir agua', 'ru': 'Добавить воду'
      },
      'Tümünü Sıfırla': {
        'en': 'Reset Today', 'de': 'Zurücksetzen', 'fr': 'Réinitialiser', 'es': 'Reiniciar día', 'ru': 'Сбросить день'
      },
      'Gıdayı İncele': {
        'en': 'Food Details', 'de': 'Lebensmittel-Details', 'fr': 'Détails de l\'aliment', 'es': 'Detalles del alimento', 'ru': 'Подробнее о продукте'
      },
      'Önemli Uyarı': {
        'en': 'Important Warning', 'de': 'Wichtiger Hinweis', 'fr': 'Avertissement important', 'es': 'Aviso importante', 'ru': 'Важное предупреждение'
      },
      'Faydaları': {
        'en': 'Benefits', 'de': 'Vorteile', 'fr': 'Bienfaits', 'es': 'Beneficios', 'ru': 'Польза'
      },
      'Neden Zararlı?': {
        'en': 'Why is it Harmful?', 'de': 'Warum schädlich?', 'fr': 'Pourquoi est-ce nocif ?', 'es': '¿Por qué es dañino?', 'ru': 'Почему это вредно?'
      },
      'Nasıl Verilmeli?': {
        'en': 'How to Serve?', 'de': 'Wie füttern?', 'fr': 'Comment servir ?', 'es': '¿Cómo servir?', 'ru': 'Как давать?'
      },
      'Yasak': {
        'en': 'Toxic', 'de': 'Giftig', 'fr': 'Toxique', 'es': 'Tóxico', 'ru': 'Опасно'
      },
      'Dikkat': {
        'en': 'Caution', 'de': 'Vorsicht', 'fr': 'Attention', 'es': 'Cuidado', 'ru': 'Внимание'
      },
      'Güvenli': {
        'en': 'Safe', 'de': 'Sicher', 'fr': 'Sûr', 'es': 'Seguro', 'ru': 'Безопасно'
      },
      'Çikolata & Kakao': {
        'en': 'Chocolate & Cocoa', 'de': 'Schokolade & Kakao', 'fr': 'Chocolat & Cacao', 'es': 'Chocolate y cacao', 'ru': 'Шоколад и какао'
      },
      'Teobromin maddesi kalp ve sinir sistemine şiddetli zarar verir, ölümcül olabilir.': {
        'en': 'Theobromine severely damages the heart and nervous system and can be fatal.',
        'de': 'Theobromin schädigt Herz und Nervensystem schwer und kann tödlich sein.',
        'fr': 'La théobromine endommage gravement le cœur et le système nerveux, peut être mortelle.',
        'es': 'La teobromina daña gravemente el corazón y el sistema nervioso, puede ser fatal.',
        'ru': 'Теобромин тяжело поражает сердце и нервную систему, может быть смертельным.'
      },
      'Soğan & Sarımsak': {
        'en': 'Onion & Garlic', 'de': 'Zwiebeln & Knoblauch', 'fr': 'Oignon & Ail', 'es': 'Cebolla y ajo', 'ru': 'Лук и чеснок'
      },
      'Alyuvarları tahrip ederek hemolitik anemiye (kansızlığa) neden olur.': {
        'en': 'Destroys red blood cells leading to severe hemolytic anemia.',
        'de': 'Zerstört rote Blutkörperchen und führt zu hämolytischer Anämie.',
        'fr': 'Détruit les globules rouges et provoque une anémie hémolytique sévère.',
        'es': 'Destruye los glóbulos rojos provocando anemia hemolítica severa.',
        'ru': 'Разрушает эритроциты, приводя к гемолитической анемии.'
      },
      'Üzüm & Kuru Üzüm': {
        'en': 'Grapes & Raisins', 'de': 'Weintrauben & Rosinen', 'fr': 'Raisins et raisins secs', 'es': 'Uvas y pasas', 'ru': 'Виноград и изюм'
      },
      'Küçük miktarları bile ani akut böbrek yetmezliğine yol açabilir.': {
        'en': 'Even small amounts can cause sudden acute kidney failure.',
        'de': 'Bereits kleine Mengen können zu akutem Nierenversagen führen.',
        'fr': 'Même de petites quantités peuvent provoquer une insuffisance rénale aiguë.',
        'es': 'Incluso pequeñas cantidades pueden causar insuficiencia renal aguda.',
        'ru': 'Даже малые количества могут вызвать острую почечную недостаточность.'
      },
      'Ksilitol (Tatlandırıcı)': {
        'en': 'Xylitol (Sweetener)', 'de': 'Xylit (Süßstoff)', 'fr': 'Xylitol (Édulcorant)', 'es': 'Xilitol (Edulcorante)', 'ru': 'Ксилит (Подсластитель)'
      },
      'Ani insülin patlaması, hipoglisemi ve karaciğer nekrozuna neden olur.': {
        'en': 'Triggers rapid insulin release, acute hypoglycemia, and liver necrosis.',
        'de': 'Führt zu schneller Insulinausschüttung, Unterzuckerung und Leberschäden.',
        'fr': 'Déclenche une libération massive d\'insuline, hypoglycémie et nécrose hépatique.',
        'es': 'Provoca una liberación masiva de insulina, hipoglucemia y necrosis hepática.',
        'ru': 'Вызывает резкий выброс инсулина, гипогликемию и некроз печени.'
      },
      'Avokado': {
        'en': 'Avocado', 'de': 'Avocado', 'fr': 'Avocat', 'es': 'Aguacate', 'ru': 'Авокадо'
      },
      'İçerdiği persin toksini akciğer ve midede sıvı birikimine yol açar.': {
        'en': 'Contains persin toxin, causing fluid accumulation in lungs and stomach.',
        'de': 'Enthält Persin, das zu Flüssigkeitsansammlungen in Lunge und Magen führt.',
        'fr': 'Contient de la persine, provoquant une accumulation de liquide pulmonaire et gastrique.',
        'es': 'Contiene persina, provocando acumulación de líquido en pulmones y estómago.',
        'ru': 'Содержит токсин персин, вызывающий скопление жидкости в легких и желудке.'
      },
      'Kahve & Kafein': {
        'en': 'Coffee & Caffeine', 'de': 'Kaffee & Koffein', 'fr': 'Café & Caféine', 'es': 'Café y cafeína', 'ru': 'Кофе и кофеин'
      },
      'Aşırı kalp çarpıntısı, titreme ve merkezi sinir sistemi çökmesine yol açar.': {
        'en': 'Causes rapid heartbeat, tremors, and central nervous system breakdown.',
        'de': 'Verursacht Herzrasen, Zittern und Zusammenbruch des Nervensystems.',
        'fr': 'Provoque tachycardie, tremblements et défaillance du système nerveux.',
        'es': 'Causa taquicardia, temblores y colapso del sistema nervioso central.',
        'ru': 'Вызывает сильную тахикардию, судороги и сбой нервной системы.'
      },
      'Süt ve Süt Ürünleri': {
        'en': 'Milk & Dairy', 'de': 'Milch & Milchprodukte', 'fr': 'Lait et produits laitiers', 'es': 'Leche y lácteos', 'ru': 'Молоко и молочные продукты'
      },
      'Yetişkin patiler laktozu sindiremez; şişkinlik, kusma ve ishale neden olur.': {
        'en': 'Adult pets lack lactase enzymes, causing bloating, vomiting, and diarrhea.',
        'de': 'Erwachsene Tiere vertragen Laktose nicht; Blähungen und Durchfall sind die Folge.',
        'fr': 'Les adultes ne digèrent pas le lactose ; cela cause ballonnements et diarrhée.',
        'es': 'Los adultos no digieren la lactosa; causa hinchazón, vómitos y diarrea.',
        'ru': 'Взрослые животные не переносят лактозу, что приводит к вздутию и диарее.'
      },
      'Pişmiş Kemikler': {
        'en': 'Cooked Bones', 'de': 'Gekochte Knochen', 'fr': 'Os cuits', 'es': 'Huesos cocidos', 'ru': 'Вареные кости'
      },
      'Pişince sertleşip kıymıklanır; boğazı, mideyi veya bağırsağı yırtabilir.': {
        'en': 'Brittle splinters can puncture or tear the throat, stomach, or intestines.',
        'de': 'Splittern leicht und können Magen, Speiseröhre oder Darm perforieren.',
        'fr': 'Se brisent en éclats pointus pouvant perforer gorge, estomac ou intestins.',
        'es': 'Se astillan fácilmente pudiendo perforar la garganta, estómago o intestinos.',
        'ru': 'Легко раскалываются на острые осколки и протыкают желудок или пищевод.'
      },
      'Yağlı & Baharatlı Etler': {
        'en': 'Fatty & Spiced Meats', 'de': 'Fettiges & gewürztes Fleisch', 'fr': 'Viandes grasses et épicées', 'es': 'Carnes grasas y especiadas', 'ru': 'Жирное и пряное мясо'
      },
      'Şiddetli akut pankreatit ve mide yanmasına davetiye çıkarır.': {
        'en': 'Triggers acute pancreatitis, severe abdominal pain, and gastritis.',
        'de': 'Kann akute Bauchspeicheldrüsenentzündung und Magenschmerzen auslösen.',
        'fr': 'Déclenche de graves pancréatites aiguës et de l\'acidité gastrique.',
        'es': 'Desencadena pancreatitis aguda severa y gastritis dolorosa.',
        'ru': 'Провоцирует острый панкреатит и тяжелое воспаление желудка.'
      },
      'Haşlanmış Tavuk Göğsü': {
        'en': 'Boiled Chicken Breast', 'de': 'Gekochte Hähnchenbrust', 'fr': 'Blanc de poulet bouilli', 'es': 'Pechuga de pollo hervida', 'ru': 'Отварная куриная грудка'
      },
      'Yağsız, hafif ve sindirimi son derece kolay en kaliteli saf protein kaynağıdır.': {
        'en': 'Lean, gentle, and highly digestible source of premium pure protein.',
        'de': 'Mager, magenschonend und eine hochverdauliche reine Proteinquelle.',
        'fr': 'Source de protéines pures hautement digestibles, maigre et saine.',
        'es': 'Fuente de proteína pura, magra y de fácil digestión para el estómago.',
        'ru': 'Постный, легкоусвояемый источник чистейшего высококачественного белка.'
      },
      'Balkabağı Püresi': {
        'en': 'Pumpkin Puree', 'de': 'Kürbispüree', 'fr': 'Purée de citrouille', 'es': 'Puré de calabaza', 'ru': 'Пюре из тыквы'
      },
      'Zengin çözünür lif içeriğiyle hem ishali hem kabızlığı mükemmel dengeler.': {
        'en': 'Rich soluble fiber regulates digestion, relieving diarrhea and constipation.',
        'de': 'Reich an löslichen Ballaststoffen, reguliert Durchfall und Verstopfung.',
        'fr': 'Riche en fibres solubles, régule aussi bien la diarrhée que la constipation.',
        'es': 'Rico en fibra soluble, alivia de forma natural diarreas y estreñimiento.',
        'ru': 'Богато растворимой клетчаткой, нормализует стул при расстройствах пищеварения.'
      },
      'Havuç': {
        'en': 'Carrots', 'de': 'Karotten', 'fr': 'Carottes', 'es': 'Zanahorias', 'ru': 'Морковь'
      },
      'Düşük kalorili, beta-karoten zengini ve çiğnendiğinde diş plağını temizler.': {
        'en': 'Low calorie, rich in beta-carotene, cleans dental plaque naturally.',
        'de': 'Kalorienarm, reich an Beta-Carotin und reinigt beim Kauen die Zähne.',
        'fr': 'Faible en calories, riche en bêta-carotène, nettoie la plaque dentaire.',
        'es': 'Bajo en calorías, rico en betacaroteno, limpia el sarro dental al masticar.',
        'ru': 'Низкокалорийная, богата бета-каротином, счищает зубной налет при жевании.'
      },
      'Yaban Mersini & Elma': {
        'en': 'Blueberries & Apple', 'de': 'Blaubeeren & Apfel', 'fr': 'Myrtilles & Pomme', 'es': 'Arándanos y manzana', 'ru': 'Черника и яблоко'
      },
      'Hücre yenileyici güçlü antioksidanlar ve C vitamini deposudur (çekirdeksiz).': {
        'en': 'Potent antioxidant powerhouses loaded with vitamin C (seedless).',
        'de': 'Reich an zellschützenden Antioxidantien und Vitamin C (ohne Kerne).',
        'fr': 'Riche en antioxydants cellulaires et vitamine C (sans pépins).',
        'es': 'Potente antioxidante natural y vitamina C saludable (sin semillas).',
        'ru': 'Мощные антиоксиданты и источник витамина C для иммунитета (без косточек).'
      },
      'Somon & Balık Yağı': {
        'en': 'Salmon & Fish Oil', 'de': 'Lachs & Fischöl', 'fr': 'Saumon & Huile de poisson', 'es': 'Salmón y aceite de pescado', 'ru': 'Лосось и рыбий жир'
      },
      'Omega-3 ve Omega-6 ile parlak tüy yapısı, eklem esnekliği ve kalp sağlığı sunar.': {
        'en': 'Omega-3 and Omega-6 promote shiny coat, joint flexibility, and cardiac health.',
        'de': 'Omega-3 und Omega-6 für glänzendes Fell, gesunde Gelenke und starkes Herz.',
        'fr': 'Les Oméga-3 et 6 favorisent un pelage soyeux, des articulations souples et un cœur sain.',
        'es': 'Los Omega-3 y 6 aportan un pelaje brillante, articulaciones sanas y cuidan el corazón.',
        'ru': 'Омега-3 и Омега-6 для блестящей шерсти, гибких суставов и здоровья сердца.'
      },

      // Food Details & Emergency Actions
      'Kakao çekirdeklerindeki teobromin ve kafein, kedi ve köpeklerin metabolizması tarafından sindirilemez. Kalp atışında şiddetli artış, titreme, nöbetler ve kalp krizine yol açabilir. Bitter çikolata en tehlikelisidir.': {
        'en': 'Theobromine and caffeine in cocoa beans cannot be metabolized by dogs and cats. It causes rapid heartbeat, tremors, seizures, and can be fatal. Dark chocolate is the most dangerous.',
        'de': 'Theobromin und Koffein in Kakaobohnen können von Hunden und Katzen nicht abgebaut werden. Es verursacht Herzrasen, Zittern, Krämpfe und Herzstillstand. Zartbitterschokolade ist am gefährlichsten.',
        'fr': 'La théobromine et la caféine du cacao ne peuvent être éliminées. Elles provoquent tachycardie, tremblements, convulsions et arrêt cardiaque. Le chocolat noir est le plus mortel.',
        'es': 'La teobromina y cafeína del cacao no se metabolizan. Provocan taquicardia, temblores, convulsiones e infartos. El chocolate negro es el más tóxico.',
        'ru': 'Теобромин и кофеин не усваиваются кошками и собаками. Они вызывают тахикардию, тремор, судороги и остановку сердца. Горький шоколад наиболее опасен.'
      },
      'Acil olarak veterinere başvurun ve tüketilen miktarı bildirin.': {
        'en': 'Immediately contact an emergency vet and report the consumed amount.',
        'de': 'Sofort einen Notfalltierarzt kontaktieren und die aufgenommene Menge melden.',
        'fr': 'Contactez d\'urgence un vétérinaire et précisez la quantité ingérée.',
        'es': 'Contacta de urgencia al veterinario e informa la cantidad ingerida.',
        'ru': 'Немедленно обратитесь к ветеринару и сообщите съеденное количество.'
      },
      'Çiğ, pişmiş veya toz halinde olması fark etmeksizin sülfür bileşikleri içerir. Kırmızı kan hücrelerini parçalar ve idrarda koyulaşma, halsizlik, soluk diş etleri ile kendini belli eder.': {
        'en': 'Contains sulfur compounds in all forms. Destroys red blood cells leading to pale gums, weakness, and dark urine.',
        'de': 'Enthält Schwefelverbindungen in jeder Form. Zerstört rote Blutkörperchen und führt zu blassem Zahnfleisch, Schwäche und dunklem Urin.',
        'fr': 'Contient des composés soufrés sous toutes ses formes. Détruit les globules rouges entraînant faiblesse et gencives pâles.',
        'es': 'Contiene compuestos de azufre en cualquier forma. Destruye los glóbulos rojos provocando encías pálidas, debilidad y orina oscura.',
        'ru': 'Содержит соединения серы в любом виде. Разрушает эритроциты, приводя к бледности десен, слабости и темной моче.'
      },
      'Yemek artıklarında soğan veya sarımsak tozu bulunmamasına dikkat edin.': {
        'en': 'Ensure table scraps and broths contain no onion or garlic powder.',
        'de': 'Achte darauf, dass Essensreste kein Zwiebel- oder Knoblauchpulver enthalten.',
        'fr': 'Vérifiez que les restes ne contiennent aucune trace de poudre d\'oignon ou d\'ail.',
        'es': 'Asegúrate de que las sobras de comida no contengan cebolla ni ajo.',
        'ru': 'Следите, чтобы в пище не было лукового или чесночного порошка.'
      },
      'Hangi toksinin buna yol açtığı tam bilinmese de 1-2 adet kuru üzüm bile özellikle küçük ırklarda birkaç saat içinde kusma ve 24-48 saat içinde böbrek iflasına neden olabilir.': {
        'en': 'Even 1-2 raisins can trigger vomiting within hours and acute kidney failure within 24-48 hours.',
        'de': 'Bereits 1-2 Rosinen können innerhalb von Stunden Erbrechen und innerhalb von 24-48 Stunden Nierenversagen auslösen.',
        'fr': 'Même 1 ou 2 raisins secs peuvent provoquer des vomissements en quelques heures et une insuffisance rénale aiguë.',
        'es': 'Incluso 1 o 2 uvas pasas pueden causar vómitos en horas e insuficiencia renal aguda en 24-48 horas.',
        'ru': 'Даже 1-2 изюминки могут вызвать рвоту через несколько часов и острую почечную недостаточность за сутки.'
      },
      'Kusma belirtisi varsa derhal sıvı tedavisi için acil kliniğe gidin.': {
        'en': 'Seek emergency intravenous fluid therapy at once if ingested or vomiting occurs.',
        'de': 'Suche sofort eine Tierklinik für Infusionstherapie auf, falls Rosinen aufgenommen wurden.',
        'fr': 'Consultez immédiatement pour une perfusion intraveineuse d\'urgence en cas d\'ingestion.',
        'es': 'Acude de inmediato a una clínica veterinaria para fluidoterapia si hay ingestión.',
        'ru': 'Срочно обратитесь в клинику для проведения инфузионной терапии.'
      },
      'Şekersiz sakızlarda, fıstık ezmelerinde ve diyet keklerde bulunur. Kana hızla karışarak şekeri ölümcül seviyede düşürür ve akut karaciğer çöküşü yaratır.': {
        'en': 'Found in sugar-free gum, peanut butter, and baked goods. Causes fatal hypoglycemia and liver collapse.',
        'de': 'In zuckerfreien Kaugummis, Erdnussbutter und Diätgebäck enthalten. Löst lebensgefährliche Unterzuckerung und Leberschäden aus.',
        'fr': 'Présent dans les chewing-gums sans sucre et pâtes à tartiner. Provoque hypoglycémie mortelle et défaillance hépatique.',
        'es': 'Presente en chicles sin azúcar y mantequilla de cacahuete. Provoca hipoglucemia severa y fallo hepático agudo.',
        'ru': 'Содержится в жевачках без сахара и диет-продуктах. Вызывает смертельную гипогликемию и коллапс печени.'
      },
      'Fıstık ezmesi verirken mutlaka içerik tablosunda Xylitol olmadığını doğrulayın.': {
        'en': 'Always check labels to ensure peanut butter contains absolutely zero Xylitol or Birch Sugar.',
        'de': 'Prüfe Erdnussbutteretiketten sorgfältig auf Xylit oder Birkenzucker.',
        'fr': 'Vérifiez toujours que le beurre de cacahuète ne contient aucun xylitol.',
        'es': 'Comprueba siempre que la crema de cacahuete no contenga xilitol.',
        'ru': 'Всегда проверяйте состав арахисовой пасты на отсутствие ксилита.'
      },
      'Özellikle kuşlar, tavşanlar ve kediler için ölümcül olabilir. Meyvesi, çekirdeği ve yaprakları persin adı verilen mantar ilacı türevi doğal toksin barındırır.': {
        'en': 'Deadly for birds, rabbits, and cats. The fruit, pit, and leaves contain persin, a fungicidal toxin.',
        'de': 'Tödlich für Vögel, Kaninchen und Katzen. Frucht, Kern und Blätter enthalten das Toxin Persin.',
        'fr': 'Mortel pour les oiseaux, lapins et chats. La chair, le noyau et les feuilles contiennent de la persine.',
        'es': 'Mortal para aves, conejos y gatos. El fruto, hueso y hojas contienen la toxina persina.',
        'ru': 'Смертельно для птиц, кроликов и кошек. Мякоть, косточка и листья содержат токсин персин.'
      },
      'Evde kuşunuz varsa avokadoyu kesinlikle aynı odada açıkta tutmayın.': {
        'en': 'Never leave open avocados in the same room where pet birds live.',
        'de': 'Bewahre Avocados niemals offen in Räumen mit Ziervögeln auf.',
        'fr': 'Ne laissez jamais d\'avocat ouvert dans la même pièce qu\'un oiseau.',
        'es': 'Nunca dejes aguacates al descubierto cerca de aves domésticas.',
        'ru': 'Никогда не держите авокадо открытым в комнате с птицами.'
      },
      'Metilksantin sınıfı maddeler evcil hayvanların kalbini aşırı hızlandırır, kan basıncını yükseltir ve komaya sebep olabilir.': {
        'en': 'Methylxanthines dangerously accelerate heart rate, raise blood pressure, and can cause coma.',
        'de': 'Methylxanthine beschleunigen den Herzschlag drastisch, steigern den Blutdruck und können ins Koma führen.',
        'fr': 'Les méthylxanthines accélèrent dangereusement le rythme cardiaque et peuvent provoquer le coma.',
        'es': 'Las metilxantinas aceleran peligrosamente el ritmo cardíaco y pueden inducir al coma.',
        'ru': 'Метилксантины резко учащают пульс, повышают давление и могут вызвать кому.'
      },
      'Fincan diplerindeki kahve artıklarına ulaşmalarına izin vermeyin.': {
        'en': 'Never allow pets to lick coffee mugs, tea bags, or grounds.',
        'de': 'Lass Tiere niemals an Kaffeetassen, Kaffeesatz oder Teebeuteln lecken.',
        'fr': 'Ne laissez jamais votre animal lécher les fonds de tasse ou marc de café.',
        'es': 'No permitas que laman restos de tazas de café o posos.',
        'ru': 'Не позволяйте питомцам слизывать остатки кофе со дна чашек.'
      },
      'Sütten kesildikten sonra laktaz enzimi üretimi durur. İnek sütü yerine laktozsuz kefir veya az tuzlu doğal ev yoğurdu bağırsak florası için probiyotik olarak verilebilir.': {
        'en': 'Lactase production stops after weaning. Instead of cow milk, small amounts of plain kefir or natural yogurt can be offered.',
        'de': 'Nach dem Absetzen stoppt die Laktasebildung. Statt Kuhmilch kann laktosefreier Kefir oder Naturjoghurt als Probiotikum dienen.',
        'fr': 'La production de lactase cesse après le sevrage. Privilégiez un peu de kéfir ou yaourt nature comme probiotique.',
        'es': 'La producción de lactasa cesa tras el destete. Prefiere un poco de kéfir o yogur natural como probiótico.',
        'ru': 'Выработка лактазы прекращается после отъема. Вместо молока можно давать немного натурального кефира.'
      },
      'Haftada en fazla 1 tatlı kaşığı laktozsuz yoğurt veya kefirle sınırlayın.': {
        'en': 'Limit to maximum 1 teaspoon of lactose-free yogurt or kefir per week.',
        'de': 'Auf maximal 1 Teelöffel laktosefreien Joghurt oder Kefir pro Woche beschränken.',
        'fr': 'Limitez à 1 cuillère à café de yaourt sans lactose ou kéfir par semaine.',
        'es': 'Limita a un máximo de 1 cucharadita de yogur sin lactosa por semana.',
        'ru': 'Ограничьтесь максимум 1 чайной ложкой йогурта без лактозы в неделю.'
      },
      'Tavuk ve kuzu kemikleri fırınlanıp kaynatıldığında esnekliğini kaybeder. Sivri uçlar yemek borusunu delip acil cerrahi müdahale gerektirebilir.': {
        'en': 'Cooked bones become brittle and needle-sharp, risking esophageal or stomach perforation.',
        'de': 'Gekochte Knochen verlieren ihre Elastizität und splittern nadelscharf; sie können Magen und Speiseröhre durchbohren.',
        'fr': 'Les os cuits durcissent et forment des pointes acérées pouvant perforer l\'œsophage et nécessiter une chirurgie.',
        'es': 'Los huesos cocinados se vuelven quebradizos y afilados, pudiendo perforar el esófago o estómago.',
        'ru': 'Вареные кости становятся ломкими и острыми, они могут проколоть пищевод и потребовать срочной операции.'
      },
      'Yalnızca veteriner onaylı özel preslenmiş diş kemiklerini tercih edin.': {
        'en': 'Only choose vet-approved pressed dental chews or chew toys.',
        'de': 'Verwende nur tierärztlich zugelassene gepresste Zahnpflegeknochen.',
        'fr': 'Optez uniquement pour des os à mâcher dentaires certifiés vétérinaires.',
        'es': 'Elige solo huesos prensados dentales aprobados por veterinarios.',
        'ru': 'Выбирайте только сертифицированные ветеринарные жевательные косточки.'
      },
      'Sucuk, sosis, pastırma ve tuzlu kavurmalar yüksek sodyum ve baharat nedeniyle böbrekleri yorar ve pankreası aniden iltihaplandırabilir.': {
        'en': 'Sausages, bacon, and processed meats overload kidneys with sodium and spices, triggering acute pancreatitis.',
        'de': 'Würstchen, Schinken und gewürztes Fleisch belasten Nieren mit Salz und Gewürzen und können akute Pankreatitis auslösen.',
        'fr': 'Les saucisses, charcuteries et épices surchargent les reins et peuvent causer de graves pancréatites aiguës.',
        'es': 'Los embutidos, salchichas y carnes curadas sobrecargan los riñones y desatan pancreatitis aguda por la sal y especias.',
        'ru': 'Колбасы, сосиски и специи перегружают почки солью и могут спровоцировать тяжелый острый панкреатит.'
      },
      'Yalnızca haşlanmış ve tuzsuz saf et parçaları ödül olarak verilmelidir.': {
        'en': 'Only offer boiled, unseasoned, lean meat pieces as treats.',
        'de': 'Als Belohnung nur ungewürztes, gekochtes, mageres Fleisch füttern.',
        'fr': 'Seuls des morceaux de viande maigre bouillis et sans sel doivent être donnés.',
        'es': 'Solo se deben dar como premio trocitos de carne hervida sin sal.',
        'ru': 'В качестве лакомства давайте только отварное несоленое постное мясо.'
      },
      'Baharat ve tuz eklenmeden sadece suda haşlanan tavuk göğsü, sindirim hassasiyeti ve ishal dönemlerinde bağırsakları dinlendirir.': {
        'en': 'Plain boiled chicken breast without seasonings calms intestines during sensitive digestion and diarrhea.',
        'de': 'Ohne Gewürze und Salz gekochte Hähnchenbrust schont den Darm bei Magenverstimmungen und Durchfall.',
        'fr': 'Le blanc de poulet bouilli à l\'eau sans sel apaise les intestins lors d\'épisodes diarrhéiques.',
        'es': 'La pechuga de pollo hervida sin sal ni especias calma el intestino en casos de diarrea.',
        'ru': 'Отварная куриная грудка без соли и специй успокаивает кишечник при диарее.'
      },
      'Kemiksiz ve derisiz şekilde ılık olarak servis edin.': {
        'en': 'Serve skinless and boneless at lukewarm room temperature.',
        'de': 'Haut- und knochenlos bei lauwarmem Zimmertemperatur servieren.',
        'fr': 'Servez tiède, sans peau et sans aucun os.',
        'es': 'Sirve tibio, deshuesado y sin piel.',
        'ru': 'Подавайте теплым, без кожи и костей.'
      },
      'Bağırsaktaki fazla sıvıyı emerek dışkıyı kıvamına getirir. İçerdiği A vitamini ve antioksidanlar bağışıklık sistemini destekler.': {
        'en': 'Absorbs excess intestinal fluid to normalize stool consistency while boosting immunity with vitamin A.',
        'de': 'Nimmt überschüssige Flüssigkeit im Darm auf und festigt den Stuhl, während Vitamin A das Immunsystem stärkt.',
        'fr': 'Absorbe l\'excès de liquide intestinal pour réguler les selles, tandis que la vitamine A soutient l\'immunité.',
        'es': 'Absorbe el exceso de líquido intestinal para regular las heces y aporta vitamina A inmune.',
        'ru': 'Впитывает лишнюю жидкость в кишечнике, нормализуя стул, а витамин A укрепляет иммунитет.'
      },
      'Şekersiz ve katkısız püre halinde mamaya 1 yemek kaşığı karıştırılabilir.': {
        'en': 'Mix 1 tablespoon of pure additive-free pumpkin puree directly into food.',
        'de': '1 Esslöffel reines Kürbispüree ohne Zusätze direkt unter das Futter mischen.',
        'fr': 'Mélangez 1 cuillère à soupe de purée de citrouille pure directement au repas.',
        'es': 'Se puede mezclar 1 cucharada sopera de puré 100% natural con su pienso.',
        'ru': 'Добавьте 1 столовую ложку пюре без сахара прямо в корм.'
      },
      'Çiğ verildiğinde dişlerdeki plakları mekanik olarak fırçalar, haşlandığında ise mideye şifa verir. Kilo kontrolündeki köpekler için harika bir atıştırmalıktır.': {
        'en': 'Raw carrots mechanically scrub dental plaque, while cooked ones soothe the stomach. Great low-calorie snack.',
        'de': 'Roh fegt sie Zahnbelag mechanisch ab, gekocht beruhigt sie den Magen. Hervorragender Snack zur Gewichtskontrolle.',
        'fr': 'Crue, elle frotte la plaque dentaire ; cuite, elle apaise l\'estomac. Encas parfait pour le contrôle du poids.',
        'es': 'Cruda limpia el sarro de los dientes, cocida alivia el estómago. Gran snack para el control de peso.',
        'ru': 'Сырая морковь счищает зубной налет, вареная успокаивает желудок. Идеальный диетический перекус.'
      },
      'Boğulma riskine karşı köpeğinizin boyutuna uygun dilimleyin.': {
        'en': 'Slice into appropriate bite sizes for your dog to prevent choking.',
        'de': 'Passend zur Hundegröße schneiden, um Erstickungsgefahren zu vermeiden.',
        'fr': 'Coupez en morceaux adaptés à la taille du chien pour éviter tout étouffement.',
        'es': 'Corta en trozos adecuados al tamaño del animal para evitar asfixia.',
        'ru': 'Нарезайте кусочками по размеру собаки во избежание удушья.'
      },
      'Elma çekirdeklerinde siyanür türevi bileşikler olduğundan çekirdeksiz verilmelidir. Yaban mersini ise beyin yaşlanmasını yavaşlatır.': {
        'en': 'Apple seeds contain cyanide traces and must be removed. Blueberries boost cognitive health.',
        'de': 'Apfelkerne enthalten Cyanidspuren und müssen entfernt werden. Blaubeeren verlangsamen die Gehirnalterung.',
        'fr': 'Les pépins de pomme contiennent du cyanure et doivent être retirés. La myrtille protège le cerveau.',
        'es': 'Las semillas de manzana contienen cianuro y deben retirarse. Los arándanos protegen el cerebro.',
        'ru': 'Семечки яблок содержат следы цианида и должны быть удалены. Черника замедляет старение мозга.'
      },
      'Günde 3-4 adet yaban mersini veya 2 dilim soyulmuş elma yeterlidir.': {
        'en': '3-4 blueberries or 2 slices of peeled apple per day is ideal.',
        'de': '3-4 Blaubeeren oder 2 geschälte Apfelscheiben pro Tag sind ideal.',
        'fr': '3 à 4 myrtilles ou 2 quartiers de pomme pelée par jour suffisent.',
        'es': '3-4 arándanos o 2 rodajas de manzana pelada al día son suficientes.',
        'ru': '3-4 ягоды черники или 2 ломтика очищенного яблока в день вполне достаточно.'
      },
      'Mevsimsel tüy dökülmesini belirgin derecede azaltır, cilt kaşıntılarını dindirir ve yaşlı dostlarımızın eklem kireçlenmesine karşı kıkırdağı korur.': {
        'en': 'Significantly reduces seasonal shedding, relieves itchy skin, and lubricates arthritic joints.',
        'de': 'Reduziert den Fellwechsel deutlich, lindert Hautjucken und schützt Gelenkknorpel im Alter.',
        'fr': 'Réduit la mue, apaise les démangeaisons et protège le cartilage articulaire des seniors.',
        'es': 'Reduce notablemente la caída de pelo, alivia picores y protege las articulaciones.',
        'ru': 'Значительно снижает линьку, снимает зуд кожи и защищает суставные хрящи.'
      },
      'Kılçıksız pişmiş somon veya günde 1 pompa saf somon balık yağı ekleyin.': {
        'en': 'Add boneless cooked salmon or 1 pump of pure salmon oil to meals daily.',
        'de': 'Grätenfreien gegarten Lachs oder 1 Pumpstoß reines Lachsöl täglich ins Futter geben.',
        'fr': 'Ajoutez du saumon cuit désossé ou 1 pression d\'huile de saumon pure par jour.',
        'es': 'Añade salmón cocido sin espinas o una dosis de aceite de salmón al día.',
        'ru': 'Добавляйте отварной лосось без костей или 1 дозу рыбьего жира в день.'
      },

      // Education & Training Demo Strings
      'Temel İtaat (Otur / Bekle)': {
        'en': 'Basic Obedience (Sit / Stay)', 'de': 'Grundgehorsam (Sitz / Bleib)', 'fr': 'Obéissance de base (Assis / Reste)', 'es': 'Obediencia básica (Sentado / Quieto)', 'ru': 'Базовые команды (Сидеть / Ждать)'
      },
      'Dışarı alıştı.': {
        'en': 'Accustomed to going outside.', 'de': 'An draußen gewöhnt.', 'fr': 'Habitué à faire ses besoins dehors.', 'es': 'Acostumbrado a hacer sus necesidades fuera.', 'ru': 'Привык ходить в туалет на улице.'
      },
      'Komutlara uyuyor.': {
        'en': 'Responds well to commands.', 'de': 'Befolgt Kommandos zuverlässig.', 'fr': 'Répond parfaitement aux ordres.', 'es': 'Responde muy bien a las órdenes.', 'ru': 'Хорошо выполняет команды.'
      },

      // Emergency Hotlines & Veterinary Live Search
      '7/24 Resmi Acil Hatlar': {
        'en': '24/7 Official Emergency Hotlines',
        'de': '24/7 Offizielle Notfallnummern',
        'fr': 'Lignes d\'urgence officielles 24/7',
        'es': 'Líneas de emergencia oficiales 24/7',
        'ru': 'Официальные экстренные линии 24/7'
      },
      'Ara (153)': {
        'en': 'Call (153)',
        'de': 'Anrufen (153)',
        'fr': 'Appeler (153)',
        'es': 'Llamar (153)',
        'ru': 'Вызов (153)'
      },
      'İl veya İlçe Ara (Örn: Kadıköy, Çankaya, İzmir)...': {
        'en': 'Search City or District (e.g. Kadıköy, Çankaya, İzmir)...',
        'de': 'Stadt oder Bezirk suchen (z.B. Kadıköy, Çankaya, İzmir)...',
        'fr': 'Rechercher ville ou quartier (ex: Kadıköy, Çankaya, İzmir)...',
        'es': 'Buscar ciudad o distrito (ej: Kadıköy, Çankaya, İzmir)...',
        'ru': 'Поиск города или района (напр: Кадыкёй, Чанкая, Измир)...'
      },
      'Nöbetçi Veterinerleri': {
        'en': 'Emergency Veterinarians',
        'de': 'Notdienst-Tierärzte',
        'fr': 'Vétérinaires de garde',
        'es': 'Veterinarios de urgencias',
        'ru': 'Дежурные ветеринары'
      },
      'Canlı Google Haritalar üzerinde açık klinikler': {
        'en': 'Live open clinics on Google Maps',
        'de': 'Live geöffnete Kliniken auf Google Maps',
        'fr': 'Cliniques ouvertes en direct sur Google Maps',
        'es': 'Clínicas abiertas en vivo en Google Maps',
        'ru': 'Открытые клиники в реальном времени на Google Картах'
      },
      'Kliniklerini Canlı Haritada Göster': {
        'en': 'Show Clinics on Live Map',
        'de': 'Kliniken auf Live-Karte anzeigen',
        'fr': 'Afficher les cliniques sur la carte',
        'es': 'Ver clínicas en el mapa en vivo',
        'ru': 'Показать клиники на карте'
      },
      'Harita uygulaması açılamadı. Lütfen Google Haritalar\'ı açıp aratın.': {
        'en': 'Could not open map app. Please open Google Maps directly to search.',
        'de': 'Karten-App konnte nicht geöffnet werden. Bitte öffnen Sie Google Maps manuell.',
        'fr': 'Impossible d\'ouvrir l\'application cartographique. Veuillez ouvrir Google Maps directement.',
        'es': 'No se pudo abrir la app de mapas. Por favor, abre Google Maps directamente.',
        'ru': 'Не удалось открыть карты. Пожалуйста, откройте Google Карты вручную.'
      },

      // Home Screen Feature Grid & Search Items
      '7/24 nöbetçi hayvan hastaneleri, yol tarifi ve arama': {
        'en': '24/7 emergency pet hospitals, directions and calls',
        'de': '24/7 Notfall-Tierkliniken, Routen und Anrufe',
        'fr': 'Hôpitaux pour animaux 24/7, itinéraires et appels',
        'es': 'Hospitales de animales 24/7, rutas y llamadas',
        'ru': 'Круглосуточные ветклиники, маршруты и звонки'
      },
      'Acil Durum & İlk Yardım': {
        'en': 'Emergency & First Aid',
        'de': 'Notfall & Erste Hilfe',
        'fr': 'Urgences & Premiers secours',
        'es': 'Emergencias y primeros auxilios',
        'ru': 'Экстренная помощь и первая помощь'
      },
      'Zehirlenme, kanama, sıcak çarpması ve kırık müdahalesi': {
        'en': 'Poisoning, bleeding, heatstroke and fracture response',
        'de': 'Vergiftung, Blutungen, Hitzschlag & Knochenbrüche',
        'fr': 'Empoisonnement, hémorragie, coup de chaleur et fractures',
        'es': 'Intoxicación, hemorragia, golpe de calor y fracturas',
        'ru': 'Отравления, кровотечения, тепловой удар и переломы'
      },
      'Aşı Takvimi & Dozlar': {
        'en': 'Vaccine Schedule & Doses',
        'de': 'Impfkalender & Dosierungen',
        'fr': 'Calendrier vaccinal & Doses',
        'es': 'Calendario de vacunas y dosis',
        'ru': 'Календарь прививок и дозы'
      },
      'Karma, kuduz, parazit aşıları ve alarm takvimi': {
        'en': 'Core, rabies, parasite vaccines and reminder schedule',
        'de': 'Kombi-, Tollwut-, Parasitenimpfungen & Alarme',
        'fr': 'Vaccins combinés, rage, antiparasitaires et rappels',
        'es': 'Vacunas combinadas, rabia, parásitos y alarmas',
        'ru': 'Комплексные вакцины, бешенство, паразиты и календарь'
      },
      'İlaç Takibi & Dozaj': {
        'en': 'Medication Tracking & Dosage',
        'de': 'Medikamenten-Tracking & Dosierung',
        'fr': 'Suivi des médicaments & Dosage',
        'es': 'Seguimiento de medicación y dosis',
        'ru': 'Учет лекарств и дозировка'
      },
      'Antibiyotik, vitamin, damla ve şurup hatırlatıcıları': {
        'en': 'Antibiotic, vitamin, drop, and syrup reminders',
        'de': 'Erinnerungen für Antibiotika, Vitamine, Tropfen & Sirup',
        'fr': 'Rappels antibiotiques, vitamines, gouttes et sirops',
        'es': 'Recordatorios de antibióticos, vitaminas, gotas y jarabes',
        'ru': 'Напоминания об антибиотиках, витаминах, каплях и сиропах'
      },
      'Veteriner Randevuları': {
        'en': 'Vet Appointments',
        'de': 'Tierarzttermine',
        'fr': 'Rendez-vous vétérinaires',
        'es': 'Citas veterinarias',
        'ru': 'Записи к ветеринару'
      },
      'Yaklaşan doktor kontrolleri ve randevu alarmları': {
        'en': 'Upcoming doctor check-ups and appointment alarms',
        'de': 'Anstehende Kontrolluntersuchungen & Terminarme',
        'fr': 'Prochains contrôles médicaux et alarmes de rdv',
        'es': 'Próximas revisiones médicas y alarmas de citas',
        'ru': 'Предстоящие осмотры врача и напоминания о визитах'
      },
      'Sağlık Kayıtları & Tahlil': {
        'en': 'Health Records & Lab Tests',
        'de': 'Gesundheitsakten & Laboranalysen',
        'fr': 'Dossiers médicaux & Analyses labo',
        'es': 'Historial médico y análisis',
        'ru': 'Медицинские карты и анализы'
      },
      'Muayene': {
        'en': 'Examination',
        'de': 'Untersuchung',
        'fr': 'Examen',
        'es': 'Consulta',
        'ru': 'Осмотр'
      },
      'Aşı/Parazit': {
        'en': 'Vaccine / Parasite',
        'de': 'Impfung / Parasit',
        'fr': 'Vaccin / Parasite',
        'es': 'Vacuna / Parásito',
        'ru': 'Вакцина / Паразиты'
      },
      'Ameliyat': {
        'en': 'Surgery',
        'de': 'Operation',
        'fr': 'Chirurgie',
        'es': 'Cirugía',
        'ru': 'Операция'
      },
      'Tahlil': {
        'en': 'Lab Test',
        'de': 'Labor',
        'fr': 'Analyse',
        'es': 'Análisis',
        'ru': 'Анализы'
      },
      'Diş': {
        'en': 'Dental',
        'de': 'Zähne',
        'fr': 'Dentaire',
        'es': 'Dental',
        'ru': 'Зубы'
      },
      'Geçmiş tedaviler, ameliyatlar, tahliller ve alerjiler': {
        'en': 'Past treatments, surgeries, lab tests and allergies',
        'de': 'Frühere Behandlungen, Operationen, Analysen & Allergien',
        'fr': 'Traitements passés, chirurgies, analyses et allergies',
        'es': 'Tratamientos previos, cirugías, análisis y alergias',
        'ru': 'Прошлые лечения, операции, анализы и аллергии'
      },
      'Hastalık Belirtileri & Teşhis': {
        'en': 'Disease Symptoms & Diagnosis',
        'de': 'Krankheitssymptome & Diagnose',
        'fr': 'Symptômes & Diagnostic',
        'es': 'Síntomas de enfermedades y diagnóstico',
        'ru': 'Симптомы болезней и диагностика'
      },
      'İştahsızlık, halsizlik, kaşınma ve alarm veren semptomlar': {
        'en': 'Loss of appetite, fatigue, itching, and red-flag symptoms',
        'de': 'Appetitlosigkeit, Schwäche, Juckreiz & Warnsymptome',
        'fr': 'Perte d\'appétit, fatigue, démangeaisons et signaux d\'alarme',
        'es': 'Falta de apetito, debilidad, picor y signos de alarma',
        'ru': 'Потеря аппетита, слабость, зуд и тревожные симптомы'
      },
      'Beslenme & Mama Planı': {
        'en': 'Nutrition & Meal Plan',
        'de': 'Ernährungs- & Futterplan',
        'fr': 'Nutrition & Plan de repas',
        'es': 'Nutrición y plan de alimentación',
        'ru': 'Питание и план кормления'
      },
      'Günlük porsiyon, doğru mama seçimi, su tüketimi': {
        'en': 'Daily portions, right food choice, water consumption',
        'de': 'Tagesportionen, richtige Futterwahl, Wasseraufnahme',
        'fr': 'Portions journalières, bon choix d\'aliments, eau',
        'es': 'Porciones diarias, elección del pienso, ingesta de agua',
        'ru': 'Суточные порции, выбор корма, потребление воды'
      },
      'Tuvalet & İtaat Eğitimi': {
        'en': 'Potty & Obedience Training',
        'de': 'Stubenreinheit & Gehorsamstraining',
        'fr': 'Propreté & Dressage d\'obéissance',
        'es': 'Educación higiénica y obediencia',
        'ru': 'Приучение к туалету и послушание'
      },
      'Otur, pati ver, bekle komutları ve ödül sistemi': {
        'en': 'Sit, give paw, stay commands, and reward system',
        'de': 'Sitz-, Pfote-, Bleib-Kommandos & Belohnungssystem',
        'fr': 'Assis, donne la patte, reste et système de récompenses',
        'es': 'Comandos sienta, da la pata, quieto y premios',
        'ru': 'Команды «Сидеть», «Дай лапу», «Ждать» и поощрения'
      },
      'Davranış & Psikoloji': {
        'en': 'Behavior & Psychology',
        'de': 'Verhalten & Psychologie',
        'fr': 'Comportement & Psychologie',
        'es': 'Comportamiento y psicología',
        'ru': 'Поведение и психология'
      },
      'Miyavlama, havlama, tırmalama, korku ve stres yönetimi': {
        'en': 'Meowing, barking, scratching, fear, and stress management',
        'de': 'Miauen, Bellen, Kratzen, Angst- & Stressbewältigung',
        'fr': 'Miaulement, aboiement, griffures, peur et gestion du stress',
        'es': 'Maullidos, ladridos, arañazos, miedo y gestión del estrés',
        'ru': 'Мяуканье, лай, царапание, страх и управление стрессом'
      },
      'Tüy Bakımı & Hijyen': {
        'en': 'Coat Care & Hygiene',
        'de': 'Fellpflege & Hygiene',
        'fr': 'Soin du pelage & Hygiène',
        'es': 'Cuidado del pelaje e higiene',
        'ru': 'Уход за шерстью и гигиена'
      },
      'Banyo, tırnak kesimi, göz ve kulak temizliği': {
        'en': 'Bathing, nail trimming, eye and ear cleaning',
        'de': 'Baden, Krallenschneiden, Augen- & Ohrenreinigung',
        'fr': 'Bain, coupe des griffes, nettoyage yeux et oreilles',
        'es': 'Baño, corte de uñas, limpieza de ojos y oídos',
        'ru': 'Купание, стрижка когтей, чистка глаз и ушей'
      },
      'Veteriner & Acil Klinikler': {
        'en': 'Veterinarians & Emergency Clinics',
        'de': 'Tierärzte & Notfallkliniken',
        'fr': 'Vétérinaires & Cliniques d\'urgence',
        'es': 'Veterinarios y clínicas de urgencias',
        'ru': 'Ветеринары и дежурные клиники'
      },
      'Akıllı Hatırlatıcılar & Alarmlar': {
        'en': 'Smart Reminders & Alarms',
        'de': 'Intelligente Erinnerungen & Alarme',
        'fr': 'Rappels intelligents & Alarmes',
        'es': 'Recordatorios inteligentes y alarmas',
        'ru': 'Умные напоминания и будильники'
      },
      'Yaklaşan aşı, mama, ilaç ve randevu bildirimleri': {
        'en': 'Upcoming vaccine, food, medication, and appointment alerts',
        'de': 'Benachrichtigungen für Impfungen, Futter, Medizin & Termine',
        'fr': 'Alertes pour vaccins, nourriture, médicaments et rdv',
        'es': 'Notificaciones de vacunas, comida, medicinas y citas',
        'ru': 'Оповещения о вакцинах, корме, лекарствах и записях'
      },
      'Dijital Pati Pasaportu & PDF': {
        'en': 'Digital Pet Passport & PDF',
        'de': 'Digitaler Haustierpass & PDF',
        'fr': 'Passeport numérique pour animal & PDF',
        'es': 'Pasaporte digital para mascotas y PDF',
        'ru': 'Цифровой ветпаспорт и PDF'
      },
      'Resmi PDF sağlık & aşı pasaportu çıktısı, çip no ve kilo grafiği': {
        'en': 'Official PDF health & vaccine passport printout, chip no & weight chart',
        'de': 'Offizieller PDF-Gesundheits- & Impfpass, Chip-Nr. & Gewichtskurve',
        'fr': 'Impression passeport santé & vaccins officiel, puce & courbe de poids',
        'es': 'Pasaporte oficial en PDF de salud y vacunas, chip y gráfica de peso',
        'ru': 'Официальный PDF-ветпаспорт, номер чипа и график веса'
      },
      'Resmi Aşı & Sağlık Pasaportu (PDF)': {
        'en': 'Official Vaccine & Health Passport (PDF)',
        'de': 'Offizieller Impf- & Gesundheitspass (PDF)',
        'fr': 'Passeport vaccinal & de santé officiel (PDF)',
        'es': 'Pasaporte oficial de vacunación y salud (PDF)',
        'ru': 'Официальный паспорт вакцинации и здоровья (PDF)'
      },
      'Aşı ve pasaport için ilk dostunu kaydet': {
        'en': 'Register your first pet for vaccines and passport',
        'de': 'Registriere dein erstes Tier für Impfpass & Akte',
        'fr': 'Enregistrez votre premier animal pour le passeport',
        'es': 'Registra a tu primera mascota para pasaporte y vacunas',
        'ru': 'Зарегистрируйте первого питомца для ветпаспорта и прививок'
      },
      'Reklamsız deneyim, sınırsız dijital pasaport & bağımsız yazılım desteği.': {
        'en': 'Ad-free experience, unlimited digital passports & independent software support.',
        'de': 'Werbefreies Erlebnis, unbegrenzte digitale Pässe & Software-Support.',
        'fr': 'Sans publicité, passeports numériques illimités & soutien au développement.',
        'es': 'Sin anuncios, pasaportes digitales ilimitados y apoyo al software.',
        'ru': 'Без рекламы, безлимитные цифровые паспорта и поддержка проекта.'
      },
      'PDF pasaport oluşturmak için önce evcil dostunuzu ekleyin.': {
        'en': 'Please add your pet first to generate a PDF passport.',
        'de': 'Füge zuerst dein Haustier hinzu, um einen PDF-Pass zu erstellen.',
        'fr': 'Veuillez d\'abord ajouter votre animal pour générer un passeport PDF.',
        'es': 'Añade primero a tu mascota para generar el pasaporte en PDF.',
        'ru': 'Сначала добавьте питомца, чтобы создать PDF-паспорт.'
      },
      'Örnek veriler (Max, Luna, Maviş) yüklendi!': {
        'en': 'Sample data (Max, Luna, Mavis) loaded!',
        'de': 'Beispieldaten (Max, Luna, Mavis) geladen!',
        'fr': 'Données de démo (Max, Luna, Mavis) chargées !',
        'es': '¡Datos de muestra (Max, Luna, Mavis) cargados!',
        'ru': 'Демо-данные (Макс, Луна, Мавиш) загружены!'
      },
      'Pati Kimliği': {
        'en': 'Pet ID',
        'de': 'Haustier-ID',
        'fr': 'Passeport ID',
        'es': 'Identidad Mascota',
        'ru': 'Паспорт питомца'
      },
      'silinsin mi?': {
        'en': 'delete?',
        'de': 'löschen?',
        'fr': 'supprimer ?',
        'es': '¿eliminar?',
        'ru': 'удалить?'
      },
      'Bu evcil dostu ve tüm sağlık, aşı ve beslenme kayıtlarını kalıcı olarak silmek istediğinize emin misiniz?': {
        'en': 'Are you sure you want to permanently delete this pet and all health, vaccine, and nutrition records?',
        'de': 'Möchten Sie dieses Haustier und alle Gesundheits-, Impf- und Ernährungsdaten wirklich dauerhaft löschen?',
        'fr': 'Êtes-vous sûr de vouloir supprimer définitivement cet animal ainsi que tous ses dossiers médicaux et nutritionnels ?',
        'es': '¿Está seguro de que desea eliminar permanentemente esta mascota y todos sus registros?',
        'ru': 'Вы уверены, что хотите навсегда удалить этого питомца и все медицинские записи?'
      },
      'Bu evcil dostu ve tüm beslenme/sağlık verilerini silmek istediğinize emin misiniz?': {
        'en': 'Are you sure you want to delete this pet and all associated nutrition and health data?',
        'de': 'Möchten Sie dieses Haustier und alle zugehörigen Daten wirklich löschen?',
        'fr': 'Êtes-vous sûr de vouloir supprimer cet animal et toutes les données associées ?',
        'es': '¿Está seguro de que desea eliminar esta mascota y todos los datos asociados?',
        'ru': 'Вы уверены, что хотите удалить этого питомца и связанные данные?'
      },
      'profili silindi.': {
        'en': 'profile deleted.',
        'de': 'Profil gelöscht.',
        'fr': 'profil supprimé.',
        'es': 'perfil eliminado.',
        'ru': 'профиль удален.'
      },
      'Tüm Verileri Temizle': {
        'en': 'Clear All Data',
        'de': 'Alle Daten löschen',
        'fr': 'Effacer toutes les données',
        'es': 'Borrar todos los datos',
        'ru': 'Очистить все данные'
      },
      'Tüm evcil hayvan profilleri ve kayıtları sıfırlanacaktır. Uygulamayı sıfır kurulum durumuna getirmek istediğinize emin misiniz?': {
        'en': 'All pet profiles and records will be reset. Are you sure you want to reset the app to initial state?',
        'de': 'Alle Profile und Aufzeichnungen werden zurückgesetzt. Möchten Sie die App wirklich zurücksetzen?',
        'fr': 'Tous les profils et dossiers seront réinitialisés. Êtes-vous sûr ?',
        'es': 'Se restablecerán todos los perfiles y registros. ¿Está seguro?',
        'ru': 'Все профили и записи будут сброшены. Вы уверены?'
      },
      'Tüm test verileri temizlendi. Uygulama sıfırlandı.': {
        'en': 'All test data cleared. App has been reset.',
        'de': 'Alle Testdaten wurden gelöscht. App zurückgesetzt.',
        'fr': 'Toutes les données de test ont été effacées. Application réinitialisée.',
        'es': 'Todos los datos de prueba han sido borrados.',
        'ru': 'Все тестовые данные удалены. Приложение сброшено.'
      },
      'Tüm Demo / Test Verilerini Sil': {
        'en': 'Delete All Demo / Test Data',
        'de': 'Alle Demo- / Testdaten löschen',
        'fr': 'Supprimer toutes les données de test',
        'es': 'Eliminar todos los datos de prueba',
        'ru': 'Удалить все демо / тестовые данные'
      },
      'Bu Hayvanı Sil': {
        'en': 'Delete This Pet',
        'de': 'Dieses Haustier löschen',
        'fr': 'Supprimer cet animal',
        'es': 'Eliminar esta mascota',
        'ru': 'Удалить этого питомца'
      },
      'Tüm Demo Verileri Sil': {
        'en': 'Delete All Demo Data',
        'de': 'Alle Demodaten löschen',
        'fr': 'Supprimer toutes les données démo',
        'es': 'Eliminar todos los datos demo',
        'ru': 'Удалить все демо-данные'
      },
      'Tüm Test Verilerini Temizle': {
        'en': 'Clear All Test Data',
        'de': 'Alle Testdaten löschen',
        'fr': 'Effacer toutes les données de test',
        'es': 'Borrar todos los datos de prueba',
        'ru': 'Очистить все тестовые данные'
      },
      'Evcil hayvanları ve kayıtları sıfırla': {
        'en': 'Reset pets and all health records',
        'de': 'Haustiere und alle Datensätze zurücksetzen',
        'fr': 'Réinitialiser les animaux et tous les dossiers',
        'es': 'Restablecer mascotas y registros',
        'ru': 'Сбросить питомцев и все записи'
      },
      'Pati Takip': {
        'en': 'Pet Tracking',
        'de': 'Haustier-Tracking',
        'fr': 'Suivi animal',
        'es': 'Seguimiento',
        'ru': 'Учет питомца'
      },
      'İncele': {
        'en': 'Explore',
        'de': 'Erkunden',
        'fr': 'Examiner',
        'es': 'Explorar',
        'ru': 'Обзор'
      },
      'Acil Durum': {
        'en': 'Emergency',
        'de': 'Notfall',
        'fr': 'Urgence',
        'es': 'Emergencia',
        'ru': 'Экстренно'
      },
      'Hatırlatıcı': {
        'en': 'Reminder',
        'de': 'Erinnerung',
        'fr': 'Rappel',
        'es': 'Recordatorio',
        'ru': 'Напоминание'
      },
      'Kayıtlı bir davranış sorunu bulunmuyor.': {
        'en': 'No behavioral issues recorded.',
        'de': 'Keine Verhaltensauffälligkeiten erfasst.',
        'fr': 'Aucun problème de comportement enregistré.',
        'es': 'No hay problemas de comportamiento registrados.',
        'ru': 'Записей о проблемах поведения нет.'
      },
      'Köpeğin, kedin veya diğer dostlarının günlük kalori, su, mama ve beslenme rutinini takip etmek için hemen başla.': {
        'en': 'Start now to track daily calories, water, food, and feeding routines for your pets.',
        'de': 'Beginne jetzt, um Kalorien, Wasser und Fütterungsroutinen deines Tieres zu erfassen.',
        'fr': 'Commencez dès maintenant pour suivre les calories, l\'eau et la routine de repas.',
        'es': 'Comienza ahora a registrar calorías, agua, alimento y rutinas de nutrición.',
        'ru': 'Начните отслеживать суточные калории, воду, корм и рацион питания питомца.'
      },
      'Fotoğrafı Değiştir': {
        'en': 'Change Photo', 'de': 'Foto ändern', 'fr': 'Modifier la photo', 'es': 'Cambiar foto', 'ru': 'Изменить фото'
      },
      'Fotoğraf Seç / Değiştir': {
        'en': 'Select / Change Photo', 'de': 'Foto wählen / ändern', 'fr': 'Choisir / Modifier la photo', 'es': 'Seleccionar / Cambiar foto', 'ru': 'Выбрать / Изменить фото'
      },
      'Fotoğraf güncellendi!': {
        'en': 'Photo updated!', 'de': 'Foto aktualisiert!', 'fr': 'Photo mise à jour !', 'es': '¡Foto actualizada!', 'ru': 'Фотография обновлена!'
      },
      'Evcil Dostunun Fotoğrafı': {
        'en': 'Pet Photo', 'de': 'Haustier-Foto', 'fr': 'Photo de l\'animal', 'es': 'Foto de la mascota', 'ru': 'Фотография питомца'
      },
      'Kendi fotoğrafını yükle veya sevimli avatar seç': {
        'en': 'Upload your photo or choose a cute avatar', 'de': 'Lade ein Foto hoch oder wähle einen Avatar', 'fr': 'Téléchargez une photo ou choisissez un avatar', 'es': 'Sube tu foto o elige un avatar', 'ru': 'Загрузите фото или выберите милый аватар'
      },
      'Veya Hazır Sevimli Karakter Seç:': {
        'en': 'Or Choose a Predefined Avatar:', 'de': 'Oder wähle einen Avatar:', 'fr': 'Ou choisissez un avatar mignon :', 'es': 'O elige un avatar predefinido:', 'ru': 'Или выберите готового персонажа:'
      },
    };

    if (dict.containsKey(str)) {
      return dict[str]![_currentLanguage] ?? dict[str]!['en'] ?? str;
    }

    if (_translations.containsKey(_currentLanguage) && _translations[_currentLanguage]!.containsKey(str)) {
      return _translations[_currentLanguage]![str]!;
    }

    // Check if it's a date with a month
    const testMonths = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık', 'Bugün'];
    for (var m in testMonths) {
      if (str.contains(m)) {
        return translateDate(str);
      }
    }

    if (GuideTranslations.educationTitles.containsKey(str)) {
      return GuideTranslations.getEducationTitle(str, _currentLanguage);
    }

    if (GuideTranslations.behaviorTitles.containsKey(str)) {
      return GuideTranslations.getBehaviorTitle(str, _currentLanguage);
    }

    if (str.contains('Hatırlatıcı') || str.contains('Alarmı')) {
      String out = str;
      out = out.replaceAll('Muayene', translate('type_exam'));
      out = out.replaceAll('Randevu', translate('appointment'));
      out = out.replaceAll('Aşı', translate('vaccine'));
      out = out.replaceAll('Hatırlatıcı', translate('reminders'));
      out = out.replaceAll('Alarmı', translate('appointment_alarm_card'));
      out = out.replaceAll('1 Gün Önce', translate('days_before_1'));
      out = out.replaceAll('2 Gün Önce', translate('days_before_2'));
      out = out.replaceAll('1 Saat Önce', translate('hours_before_1'));
      out = out.replaceAll('3 Saat Önce', translate('hours_before_3'));
      out = out.replaceAll('Randevu Anında', translate('at_appointment_time'));
      return out;
    }

    if (str.endsWith('Yaş') || str.endsWith('Yaşında') || str.endsWith('Aylık')) {
      final parts = str.split(' ');
      if (parts.length >= 2) {
        final numPart = parts[0];
        if (str.contains('Yaş')) {
          switch (_currentLanguage) {
            case 'en': return '$numPart Years';
            case 'de': return '$numPart Jahre';
            case 'fr': return '$numPart Ans';
            case 'es': return '$numPart Años';
            case 'ru': return '$numPart Лет';
          }
        } else if (str.contains('Aylık')) {
          switch (_currentLanguage) {
            case 'en': return '$numPart Months';
            case 'de': return '$numPart Monate';
            case 'fr': return '$numPart Mois';
            case 'es': return '$numPart Meses';
            case 'ru': return '$numPart Месяцев';
          }
        }
      }
    }

    if (str.contains(' Adet')) {
      final numPart = str.replaceAll(' Adet', '').trim();
      switch (_currentLanguage) {
        case 'en': return '$numPart Items';
        case 'de': return '$numPart Einträge';
        case 'fr': return '$numPart Éléments';
        case 'es': return '$numPart Elementos';
        case 'ru': return '$numPart шт.';
      }
    }

    if (str == '/ saat') {
      switch (_currentLanguage) {
        case 'en': return '/ hr';
        case 'de': return '/ Std.';
        case 'fr': return '/ h';
        case 'es': return '/ hr';
        case 'ru': return '/ час';
      }
    }

    if (str.contains(' Yorum')) {
      final numPart = str.replaceAll(' Yorum', '').trim();
      switch (_currentLanguage) {
        case 'en': return '$numPart Reviews';
        case 'de': return '$numPart Bewertungen';
        case 'fr': return '$numPart Avis';
        case 'es': return '$numPart Reseñas';
        case 'ru': return '$numPart Отзывов';
      }
    }

    return str;
  }

  static final Map<String, Map<String, String>> _translations = {
    // --- ITALIANO ---
    'it': {
      'app_title': 'PatiGuida',
      'brand_prefix': 'Pati',
      'brand_suffix': 'Guida',
      'home': 'Home',
      'my_pet': 'Il Mio Pet',
      'reminders': 'Promemoria',
      'profile': 'Profilo',
      'search_hint': 'Cerca nelle guide, addestramento o cura...',
      'categories': 'Categorie',
      'health': 'Salute',
      'health_sub': 'Malattie e vaccini',
      'nutrition': 'Nutrizione',
      'nutrition_sub': 'Cibo e porzioni',
      'care': 'Cura & Igiene',
      'care_sub': 'Igiene e pulizia',
      'education': 'Addestramento',
      'education_sub': 'Comandi e guide',
      'behavior': 'Comportamento',
      'behavior_sub': 'Carattere e problemi',
      'sitters': 'Veterinari & Cliniche',
      'sitters_sub': 'Emergenze e cliniche',
      'clinics': 'Veterinari & Cliniche',
      'clinics_sub': 'Emergenze e cliniche',
      'popular_topics': 'Guide Popolari per la Cura',
      'comprehensive_list': 'Elenco Completo delle Guide',
      'digital_passport': 'PASSAPORTO DIGITALE DEL PET',
      'pdf_export_passport': 'Scarica Passaporto & Libretto Vaccini (PDF)',
      'pdf_export_desc': 'Documento digitale ufficiale pronto per veterinari, viaggi e controlli.',
      'pdf_view_print': 'Anteprima e Stampa PDF',
      'pdf_official_cert': 'Passaporto Ufficiale Internazionale',
      'pdf_modal_title': 'Passaporto Sanitario Digitale',
      'pdf_modal_subtitle': 'Pronto per veterinari, viaggi internazionali e controlli ufficiali',
      'pdf_modal_info': 'Supporta il nostro sviluppo indipendente guardando un breve video per scaricare subito gratuitamente il tuo passaporto PDF.',
      'pdf_watch_ad_btn': 'Guarda 1 Breve Video e Scarica PDF (Gratis)',
      'pdf_support_dev_btn': 'Supporta lo Sviluppatore ({price} • Accesso Immediato)',
      'pdf_direct_open_btn': 'Apri Direttamente Senza Attese',
      'pdf_thank_you_support': 'Grazie per aver supportato lo sviluppatore! Generazione PDF in corso...',
      'support_dev_title': 'Supporto Sviluppatore',
      'support_dev_voluntary': 'Volontario',
      'support_dev_subtitle': 'PatiRehber è un progetto di sviluppo indipendente',
      'support_dev_transparency_title': 'Informativa Trasparente ed Etica',
      'support_dev_transparency_desc': 'Tutti i contributi volontari finanziano direttamente lo sviluppo continuo dell\'applicazione, i costi dei server e nuove funzionalità. Nessuna funzione principale è a pagamento.',
      'support_dev_options_title': 'Contribuisci allo Sviluppo',
      'support_dev_options_sub': 'Scegli un livello di supporto per aiutarci a mantenere questa app indipendente e senza pubblicità:',
      'support_dev_coffee': 'Offri un Caffè allo Sviluppatore',
      'support_dev_coffee_sub': 'Un gesto simbolico di apprezzamento e motivazione',
      'support_dev_plus': 'Diventa Sostenitore PatiPlus (Una Tantum)',
      'support_dev_plus_sub': 'Badge sostenitore, esperienza senza pubblicità ed export PDF istantaneo',
      'support_dev_continue_free': 'Continua a Usare Gratuitamente',
      'support_coffee_thank_you': 'Grazie mille per il tuo supporto! Fai una grande differenza.',
      'support_plus_thank_you': 'Sei diventato un sostenitore PatiPlus! Te ne siamo davvero grati.',
      'gender': 'GENERE',
      'birth': 'NASCITA',
      'neutered': 'STERILIZZATO',
      'male': 'Maschio',
      'female': 'Femmina',
      'yes': 'Sì',
      'no': 'No',
      'age': 'Età',
      'weight': 'Peso',
      'blood_type': 'Gruppo Sanguigno',
      'add_weight': '+ Peso',
      'edit_profile': 'Modifica',
      'health_management': 'Gestione Salute & Cura',
      'vaccine_calendar': 'Vaccini',
      'vet_appointments': 'Visite Vet',
      'health_records': 'Cartella Clinica',
      'medication_tracking': 'Farmaci',
      'emergency': 'Emergenza',
      'disease_symptoms': 'Sintomi',
      'feedback_title': 'Note & Feedback per lo Sviluppatore',
      'feedback_sub': 'Condividi suggerimenti, nuove idee o segnala problemi',
      'whatsapp_btn': 'WhatsApp',
      'email_btn': 'E-mail',
      'fill_form_btn': 'Compila Modulo di Feedback',
      'view_inbox_btn': 'Visualizza Messaggi in Arrivo (Sviluppatore)',
      'offline_status': '100% Funzionante Offline',
      'offline_desc': 'Tutte le foto e i registri sanitari sono salvati al sicuro sul tuo dispositivo.',
      'my_registered_pets': 'I Miei Animali Registrati',
      'manage': 'Gestisci',
      'app_preferences': 'Preferenze App',
      'language_selection': 'Selezione Lingua / Lingua',
      'notifications': 'Promemoria Visite & Vaccini',
      'offline_cache': 'Cache Locale Offline',
      'app_version': 'Versione App',
      'save': 'Salva',
      'cancel': 'Annulla',
      'add': 'Aggiungi',
      'delete': 'Elimina',
      'understood': 'Ho capito, Ottimo!',
      'all': 'Tutti',
      'selected_pet': 'Animale Selezionato',
      'dog': 'Cane',
      'cat': 'Gatto',
      'bird': 'Uccello',
      'rabbit': 'Coniglio',
      'hamster': 'Criceto',
      'fish': 'Pesce',
      'other': 'Altro',
      'food_nutrition': 'Cibo & Nutrizione',
      'housing_safety': 'Habitat & Sicurezza',
      'sleep_rest': 'Sonno & Routine',
      'basic_training': 'Addestramento Base',
      'toilet_training': 'Educazione ai Bisogni',
      'edit_pet_info': 'Modifica Informazioni',
      'pet_name': 'Nome Animale',
      'breed_label': 'Razza',
      'chip_no': 'Numero Microchip',
      'weight_history': 'Cronologia del Peso',
      'add_weight_record': 'Aggiungi Peso',
      'medical_alerts': 'Avvisi Medici Importanti',
      'active_reminders': 'Promemoria Attivi',
      'all_filter': 'Tutti',
      'appointment': 'Visita',
      'vaccine': 'Vaccino',
      'medication': 'Farmaco',
      'close': 'Chiudi',
      'details': 'Dettagli',
      'app_subtitle': 'La guida completa per il tuo animale',
      'vaccine_calendar_sub': 'Piano vaccinale aggiornato',
      'vet_appointments_sub': 'Appuntamenti e visite',
      'health_records_sub': 'Esami e referti',
      'medication_tracking_sub': 'Dosaggi e orari',
      'disease_symptoms_sub': 'Segni precoci e diagnosi',
      'emergency_sub': 'Emergenza & cliniche',
      'vaccines_desc': 'Tieni traccia di tutti i vaccini del tuo animale.',
      'vet_appts_desc': 'Pianifica controlli e imposta sveglie di promemoria.',
      'meds_desc': 'Monitora i farmaci con precisione senza dimenticare dosi.',
      'symptoms_desc': 'Registra i sintomi per condividerli col veterinario.',
      'emergency_desc': 'Raggiungi l\'aiuto di emergenza con un solo tocco.',
      'health_records_desc': 'Conserva esami, prescrizioni e visite in un unico posto.',
      'add_vaccine_btn': 'Aggiungi Nuovo Vaccino',
      'add_appointment_btn': 'Nuova Visita & Promemoria',
      'add_medication_btn': 'Aggiungi Farmaco',
      'add_symptom_btn': 'Aggiungi Sintomo',
      'add_contact_btn': 'Aggiungi Contatto',
      'add_record_btn': 'Aggiungi Cartella',
      'vaccine_list': 'Elenco Vaccini',
      'appointment_list': 'Elenco Visite',
      'medication_list': 'Elenco Farmaci',
      'symptoms_list': 'Elenco Sintomi',
      'emergency_contacts_list': 'Contatti di Emergenza',
      'common_symptoms_guide': 'Guida ai Sintomi Comuni',
      'emergency_guide': 'Guida di Primo Soccorso',
      'next_vaccine': 'Prossimo Vaccino',
      'days_left': 'giorni rimasti',
      'alarms_active': 'Promemoria Attivi',
      'status_completed': 'Completato',
      'status_upcoming': 'In arrivo',
      'status_planned': 'Pianificato',
      'status_active': 'Attivo',
      'alarm_on': 'Attivo',
      'alarm_off': 'Disattivato',
      'tap_to_enable_alarm': 'Sveglia Disattivata - Tocca per attivare',
      'severity_medium': 'Gravità: Media',
      'vaccines_completed': 'Vaccini completati',
      'vaccines_upcoming': 'Vaccini in arrivo',
      'vaccines_planned': 'Vaccini pianificati',
      'feedback_desc': 'Aggiorniamo costantemente l\'app in base ai tuoi suggerimenti. Inviaci un feedback in qualsiasi momento.',
      'pet_parent': 'Genitore del Pet',
      'family_member': 'Membro della Famiglia PatiRehber',
      'pets_registered_count': 'Animali Registrati',
      'chipped': 'Microchippato',
      'notifications_sub': 'Ricevi avvisi e promemoria delle visite',
      'dev_inbox_title': 'Messaggi Sviluppatore',
      'dev_inbox_sub': 'Tutti i suggerimenti e feedback degli utenti',
      'no_symptoms_recorded': 'Nessun sintomo registrato.',
      'no_contacts_recorded': 'Nessun contatto di emergenza registrato.',
      'health_tracking_title': 'Cartella Sanitaria',
      'health_tracking_sub': 'Tutte le visite precedenti, analisi e vaccini',
      'education_process': 'Percorso di Addestramento',
      'add_target_btn': 'Aggiungi Obiettivo',
      'education_guides_title': 'Guide Complete & Addestramento',
      'education_guides_sub': 'Nutrizione, habitat, routine del sonno e comandi di base',
      'care_needs_title': 'Esigenze di Cura',
      'nutrition_plan_title': 'Piano Nutrizionale Giornaliero',
      'behavior_tracking_title': 'Monitoraggio Comportamento',
      'behavior_guides_title': 'Comportamento & Psicologia',
      'behavior_guides_sub': 'Comportamento, linguaggio del corpo e psicologia',
      'send_feedback_btn': 'Invia Messaggio',
      'feedback_sent_success': 'Il tuo messaggio è stato inviato con successo! Grazie. 🐾',
      'feedback_enter_message': 'Per favore, inserisci il tuo messaggio.',
      'edit_vaccine': 'Modifica Vaccino',
      'new_vaccine': 'Aggiungi Nuovo Vaccino',
      'vaccine_name': 'Nome del Vaccino',
      'date': 'Data',
      'time': 'Ora',
      'status': 'Stato',
      'edit_appointment': 'Modifica Visita',
      'new_appointment': 'Nuova Visita Veterinaria',
      'appointment_reason': 'Motivo della Visita (es. Controllo e Vaccino)',
      'vet_clinic_address': 'Clinica Veterinaria & Indirizzo',
      'vet_doctor_name': 'Nome del Veterinario',
      'appointment_note': 'Nota sulla Visita (Opzionale)',
      'appointment_alarm_card': 'Sveglia & Promemoria Visita',
      'alarm_subtitle': 'Avvisami quando arriva il momento',
      'alarm_title_field': 'Titolo del Promemoria',
      'notification_time': 'Orario di Notifica:',
      'at_appointment_time': 'All\'ora della visita',
      'hours_before_1': '1 Ora Prima',
      'hours_before_3': '3 Ore Prima',
      'days_before_1': '1 Giorno Prima',
      'days_before_2': '2 Giorni Prima',
      'edit_health_record': 'Modifica Cartella Clinica',
      'new_health_record': 'Aggiungi Cartella Clinica',
      'record_type': 'Tipo di Cartella',
      'type_exam': 'Visita Generale',
      'type_checkup': 'Check-up',
      'type_vaccine_parasite': 'Vaccino / Antiparassitario',
      'type_surgery': 'Chirurgia',
      'type_lab': 'Esami di Laboratorio',
      'type_dental': 'Cure Dentali',
      'diagnosis_title': 'Diagnosi / Titolo (es. Gastrite o Controllo)',
      'exam_date': 'Data della Visita',
      'next_control_date': 'Data Prossimo Controllo (Opzionale)',
      'prescriptions_label': 'Farmaci Prescritti / Dieta',
      'treatment_notes': 'Note sul Trattamento & Consigli',
      'complete_record_btn': 'Salva Cartella',
      'edit_medication': 'Modifica Farmaco',
      'new_medication': 'Aggiungi Nuovo Farmaco',
      'medication_name': 'Nome del Farmaco',
      'dosage_label': 'Dosaggio (es. 1 compressa)',
      'frequency_label': 'Frequenza (es. 2 volte al giorno)',
      'next_use_label': 'Prossima Dose / Data Fine',
      'status_finished': 'Terminato',
      'add_pet_title': 'Aggiungi Nuovo Animale',
      'pet_type_label': 'Specie / Tipo',
      'edit_symptom': 'Modifica Sintomo',
      'new_symptom': 'Aggiungi Nuovo Sintomo',
      'symptom_name_hint': 'Sintomo (es. Vomito, Letargia)',
      'notes_desc': 'Note / Descrizione',
      'severity': 'Gravità',
      'form_severity': 'Gravità',
      'field_required': 'Questo campo è obbligatorio',
      'severity_mild': 'Lieve',
      'severity_moderate': 'Moderata',
      'severity_severe': 'Alta',
      'severity_high': 'Grave',
      'today': 'Oggi',
      'edit_emergency_contact': 'Modifica Contatto',
      'new_emergency_contact': 'Aggiungi Contatto di Emergenza',
      'contact_title_hint': 'Etichetta (es. Clinica 24/7)',
      'contact_name_hint': 'Nome Persona / Clinica',
      'phone_number': 'Numero di Telefono',
      'birth_date': 'Data di Nascita',
      'weight_kg': 'Peso (kg)',
      'chip_no_label': 'Numero Microchip',
      'gender_label': 'Genere:',
      'is_neutered_question': 'È sterilizzato/castrato?',
      'allergies_label': 'Allergie Note (es. Pollo, Glutine)',
      'allergies': 'Allergie',
      'blood_type_label': 'Gruppo Sanguigno (es. DEA 1.1+ / Gruppo A)',
      'special_notes_label': 'Note Speciali & Abitudini',
      'notes_label': 'Note',
      'save_and_update': 'Salva e Aggiorna',
      'profile_updated_msg': 'Informazioni del profilo aggiornate.',
      'weight_entry_title': 'Registrazione Peso',
      'new_weight_kg': 'Nuovo Peso (kg)',
      'weight_note_hint': 'Nota (es. A digiuno al mattino)',
      'weight_saved_msg': 'peso registrato.',
      'edit_training': 'Modifica Addestramento',
      'new_training': 'Aggiungi Nuovo Addestramento',
      'training_name_hint': 'Nome Comando / Esercizio',
      'training_notes_hint': 'Note (es. 5 min di pratica al giorno)',
      'status_in_progress': 'In Corso',
      'edit_behavior': 'Modifica Comportamento',
      'new_behavior': 'Aggiungi Nuovo Comportamento',
      'behavior_name_hint': 'Nome Comportamento / Problema',
      'noticed_date_hint': 'Data in cui è stato notato',
      'behavior_details_hint': 'Dettagli / Note',
      'severity_frequency': 'Gravità / Frequenza',
      'edit_nutrition_plan': 'Modifica Piano Nutrizionale',
      'total_daily_amount': 'Quantità Giornaliera Totale (es. 350 g)',
      'food_type': 'Tipo di Alimento (es. Crocchette secche)',
      'morning_meal': 'Pasto del Mattino',
      'evening_meal': 'Pasto della Sera',
      'amount': 'Quantità',
      'guide_suffix': 'Guida',
      'care_tips_for': 'Consigli di Cura per',
      'Evcil Dostunun Fotoğrafı': 'Foto dell\'Animale',
      'Kendi fotoğrafını yükle veya sevimli avatar seç': 'Carica una foto o scegli un simpatico avatar',
      'Kamera': 'Fotocamera',
      'Yeni Çek': 'Scatta Foto',
      'Galeri': 'Galleria',
      'Cihazdan Seç': 'Scegli dal Dispositivo',
      'Veya Hazır Sevimli Karakter Seç:': 'Oppure Scegli un Avatar Predefinito:',
      'Fotoğrafı Kaldır / Varsayılana Dön': 'Rimuovi Foto / Ripristina Predefinito',
      'Fotoğraf Seç / Değiştir': 'Seleziona / Cambia Foto',
      'Fotoğrafı Değiştir': 'Cambia Foto',
      'Fotoğraf güncellendi!': 'Foto aggiornata!',
    },

    // --- TÜRKÇE ---
    'tr': {
      'app_title': 'PatiRehber',
      'brand_prefix': 'Pati',
      'brand_suffix': 'Rehber',
      'home': 'Ana Sayfa',
      'my_pet': 'Dostum',
      'reminders': 'Hatırlatıcılar',
      'profile': 'Profil',
      'search_hint': 'Rehberde, eğitim veya bakımda ara...',
      'categories': 'Kategoriler',
      'health': 'Sağlık',
      'health_sub': 'Hastalıklar ve aşı',
      'nutrition': 'Beslenme',
      'nutrition_sub': 'Mama ve porsiyon',
      'care': 'Bakım',
      'care_sub': 'Temizlik ve hijyen',
      'education': 'Eğitim',
      'education_sub': 'Komut ve rehber',
      'behavior': 'Davranış',
      'behavior_sub': 'Karakter ve sorunlar',
      'sitters': 'Veteriner & Klinik',
      'sitters_sub': 'Nöbetçi klinikler',
      'clinics': 'Veteriner & Klinik',
      'clinics_sub': 'Nöbetçi klinikler',
      'popular_topics': 'Popüler Evcil Dost Rehberleri',
      'comprehensive_list': 'Kapsamlı Liste',
      'digital_passport': 'DİJİTAL EVCİL DOST PASAPORTU',
      'pdf_export_passport': 'PDF Pasaport & Aşı Karnesi İndir',
      'pdf_export_desc': 'Veteriner hekim, seyahat veya resmi işlemler için hazır dijital çıktı alın.',
      'pdf_view_print': 'PDF Önizle & Yazdır',
      'pdf_official_cert': 'Resmi Uluslararası Pasaport',
      'pdf_modal_title': 'Dijital Evcil Hayvan Pasaportu',
      'pdf_modal_subtitle': 'Veteriner hekim, seyahat ve resmi işlemler için hazır çıktı',
      'pdf_modal_info': 'Bağımsız geliştirici emeğimize destek olmak için kısa bir video izleyerek PDF pasaportunuzu hemen ücretsiz açabilirsiniz.',
      'pdf_watch_ad_btn': '1 Kısa Video İzle & PDF İndir (Ücretsiz)',
      'pdf_support_dev_btn': 'Geliştiriciye Destek Ol ({price} • Beklemesiz)',
      'pdf_direct_open_btn': 'Beklemeden Doğrudan Aç',
      'pdf_thank_you_support': 'Geliştiriciye desteğiniz için teşekkürler! PDF çıktınız açılıyor...',
      'support_dev_title': 'Geliştiriciye Destek',
      'support_dev_voluntary': 'Gönüllü',
      'support_dev_subtitle': 'PatiRehber bağımsız bir yazılım geliştirme projesidir',
      'support_dev_transparency_title': 'Şeffaf ve Açık Bilgilendirme',
      'support_dev_transparency_desc': 'Burada yapılan tüm destekler doğrudan uygulamanın geliştirilmesine, sunucu masraflarına ve yeni özelliklerin kodlanmasına harcanır. Hiçbir kullanıcıya zorunlu ödeme veya kilit konulmaz.',
      'support_dev_options_title': 'Uygulama Geliştirme Emeğine Katkıda Bulun',
      'support_dev_options_sub': 'Uygulamayı reklamsız ve bağımsız olarak geliştirmeye devam edebilmemiz için dilediğiniz desteği seçebilirsiniz:',
      'support_dev_coffee': 'Geliştiriciye Bir Kahve Ismarla',
      'support_dev_coffee_sub': 'Yazılım emeğine sembolik bir teşekkür ve motivasyon',
      'support_dev_plus': 'PatiPlus Destekçisi Ol (Tek Seferlik)',
      'support_dev_plus_sub': 'Geliştirici destekçi rozeti, reklamsız deneyim & beklemesiz PDF',
      'support_dev_continue_free': 'Ücretsiz Olarak Kullanmaya Devam Et',
      'support_coffee_thank_you': 'Desteğiniz için çok teşekkürler! Emeğimize güç kattınız.',
      'support_plus_thank_you': 'PatiPlus destekçisi oldunuz! Minnettarız.',
      'gender': 'CİNSİYET',
      'birth': 'DOĞUM',
      'neutered': 'KISIRLAŞTIRMA',
      'male': 'Erkek',
      'female': 'Dişi',
      'yes': 'Evet',
      'no': 'Hayır',
      'age': 'Yaş',
      'weight': 'Ağırlık',
      'blood_type': 'Kan Grubu',
      'add_weight': '+ Kilo',
      'edit_profile': 'Düzenle',
      'health_management': 'Sağlık ve Takip Yönetimi',
      'vaccine_calendar': 'Aşı Takvimi',
      'vet_appointments': 'Veteriner',
      'health_records': 'Sağlık Kayıtları',
      'medication_tracking': 'İlaç Takibi',
      'emergency': 'Acil Durum',
      'disease_symptoms': 'Hastalık Belirtileri',
      'feedback_title': 'Geliştiriciye Not & Geri Bildirim',
      'feedback_sub': 'Eksik gördüğünüz özellik veya fikirleri yazın',
      'whatsapp_btn': 'WhatsApp',
      'email_btn': 'E-posta',
      'fill_form_btn': 'Detaylı Öneri Formu Doldur',
      'view_inbox_btn': 'Gelen Mesajları İncele (Geliştirici Girişi)',
      'offline_status': '100% Çevrimdışı Çalışır (Offline Ready)',
      'offline_desc': 'Tüm hayvan fotoğrafları ve sağlık verileri cihazınızda yerel olarak saklanır.',
      'my_registered_pets': 'Kayıtlı Dostlarım',
      'manage': 'Yönet',
      'app_preferences': 'Uygulama Tercihleri',
      'language_selection': 'Uygulama Dili / Language',
      'notifications': 'Randevu ve Aşı Bildirimleri',
      'offline_cache': 'Yerel Çevrimdışı Ön Bellek',
      'app_version': 'Uygulama Sürümü',
      'save': 'Kaydet',
      'cancel': 'İptal',
      'add': 'Ekle',
      'delete': 'Sil',
      'understood': 'Anladım, Harika!',
      'all': 'Tümü',
      'selected_pet': 'Seçili Dost',
      'dog': 'Köpek',
      'cat': 'Kedi',
      'bird': 'Kuş',
      'rabbit': 'Tavşan',
      'hamster': 'Hamster',
      'fish': 'Balık',
      'other': 'Diğer',
      'food_nutrition': 'Yemek & Beslenme',
      'housing_safety': 'Barınma & Güvenlik',
      'sleep_rest': 'Yatma & Uyku',
      'basic_training': 'Temel Eğitim',
      'toilet_training': 'Tuvalet Eğitimi',
      'edit_pet_info': 'Bilgileri Düzenle',
      'pet_name': 'Hayvanın Adı',
      'breed_label': 'Irkı',
      'chip_no': 'Mikroçip Numarası',
      'weight_history': 'Kilo Takip Geçmişi',
      'add_weight_record': 'Kilo Ekle',
      'medical_alerts': 'Önemli Tıbbi Uyarılar',
      'active_reminders': 'Aktif Hatırlatmalar',
      'all_filter': 'Tümü',
      'appointment': 'Randevu',
      'vaccine': 'Aşı',
      'medication': 'İlaç',
      'close': 'Kapat',
      'details': 'Detaylar',
      'app_subtitle': 'Minik dostunuzun sağlığı bizim için önemli.',
      'vaccine_calendar_sub': 'Güncel aşı takvimi',
      'vet_appointments_sub': 'Randevu & kontrol',
      'health_records_sub': 'Muayene & tahliller',
      'medication_tracking_sub': 'Doz & ilaç saatleri',
      'disease_symptoms_sub': 'Erken teşhis & belirti',
      'emergency_sub': 'Acil yardım & klinik',
      'vaccines_desc': 'Aşılarını düzenli takip edin.',
      'vet_appts_desc': 'Yaklaşan kontrolleri planlayın, alarm kurun.',
      'meds_desc': 'İlaçlarınızı düzenli takip edin, asla unutmayın.',
      'symptoms_desc': 'Fark ettiğiniz belirtileri kaydedin, hekiminize aktarın.',
      'emergency_desc': 'Kritik anlarda hekiminize tek tuşla ulaşın.',
      'health_records_desc': 'Muayene, reçete ve kontrol tarihlerini toplayın.',
      'add_vaccine_btn': 'Yeni Aşı Ekle',
      'add_appointment_btn': 'Yeni Randevu & Alarm Oluştur',
      'add_medication_btn': 'İlaç Ekle',
      'add_symptom_btn': 'Belirti Ekle',
      'add_contact_btn': 'Numara Ekle',
      'add_record_btn': 'Kayıt Ekle',
      'vaccine_list': 'Aşı Listesi',
      'appointment_list': 'Randevu Listesi',
      'medication_list': 'İlaç Listesi',
      'symptoms_list': 'Belirtiler Listesi',
      'emergency_contacts_list': 'Acil İletişim Numaraları',
      'common_symptoms_guide': 'Sık Görülen Belirtiler Rehberi',
      'emergency_guide': 'Acil Durum Rehberi',
      'next_vaccine': 'Sonraki Aşı',
      'days_left': 'gün kaldı',
      'alarms_active': 'Alarmlar Aktif',
      'status_completed': 'Tamamlandı',
      'status_upcoming': 'Yaklaşan',
      'status_planned': 'Planlandı',
      'status_active': 'Aktif',
      'alarm_on': 'Açık',
      'alarm_off': 'Kapalı',
      'tap_to_enable_alarm': 'Alarm Kapalı - Dokunarak Aç',
      'severity_medium': 'Şiddet: Orta',
      'vaccines_completed': 'Aşı tamamlandı',
      'vaccines_upcoming': 'Aşı yaklaşıyor',
      'vaccines_planned': 'Aşı planlandı',
      'feedback_desc': 'Uygulamayı sizlerin isteklerine göre sürekli güncelliyor ve geliştiriyoruz. Bize dilediğiniz zaman öneri formundan ulaşabilirsiniz.',
      'pet_parent': 'Evcil Hayvan Ebeveyni',
      'family_member': 'PatiRehber Ailesi Üyesi',
      'pets_registered_count': 'Evcil Hayvan Kayıtlı',
      'chipped': 'Çipli',
      'notifications_sub': 'Hatırlatma alarmlarını telefon ekranına ilet',
      'dev_inbox_title': 'Geliştirici Gelen Kutusu',
      'dev_inbox_sub': 'Gelen tüm öneri ve kullanıcı bildirimleri',
      'no_symptoms_recorded': 'Kayıtlı hastalık belirtisi bulunmuyor.',
      'no_contacts_recorded': 'Kayıtlı acil durum numarası bulunmuyor.',
      'health_tracking_title': 'Sağlık Takibi',
      'health_tracking_sub': 'Tüm geçmiş muayene, tahlil ve aşı kayıtları',
      'education_process': 'Eğitim Süreci',
      'add_target_btn': 'Hedef Ekle',
      'education_guides_title': 'Kapsamlı Rehber ve Eğitimler',
      'education_guides_sub': 'Yemek, barınma, uyku düzeni ve temel itaat eğitimleri',
      'care_needs_title': 'Bakım İhtiyaçları',
      'nutrition_plan_title': 'Günlük Beslenme Planı',
      'behavior_tracking_title': 'Davranış Takibi',
      'behavior_guides_title': 'Davranış ve Karakter Rehberi',
      'behavior_guides_sub': 'Davranış, beden dili ve psikoloji',
      'send_feedback_btn': 'Mesajı Gönder',
      'feedback_sent_success': 'Mesajınız başarıyla iletildi! Teşekkür ederiz. 🐾',
      'feedback_enter_message': 'Lütfen iletmek istediğiniz mesajınızı yazın.',
      'edit_vaccine': 'Aşıyı Düzenle',
      'new_vaccine': 'Yeni Aşı Ekle',
      'vaccine_name': 'Aşı Adı',
      'date': 'Tarih',
      'time': 'Saat',
      'status': 'Durum',
      'edit_appointment': 'Randevuyu Düzenle',
      'new_appointment': 'Yeni Veteriner Randevusu',
      'appointment_reason': 'Randevu Nedeni (Örn: Genel Kontrol & Aşı)',
      'vet_clinic_address': 'Veteriner Kliniği & Adres',
      'vet_doctor_name': 'Veteriner Hekim Adı',
      'appointment_note': 'Randevu Notu / Açıklama (Opsiyonel)',
      'appointment_alarm_card': 'Randevu Alarmı & Hatırlatıcı',
      'alarm_subtitle': 'Zamanı geldiğinde bildirimle uyar',
      'alarm_title_field': 'Alarm İsmi / Başlığı',
      'notification_time': 'Bildirim Zamanı:',
      'at_appointment_time': 'Randevu Anında',
      'hours_before_1': '1 Saat Önce',
      'hours_before_3': '3 Saat Önce',
      'days_before_1': '1 Gün Önce',
      'days_before_2': '2 Gün Önce',
      'edit_health_record': 'Sağlık Kaydını Düzenle',
      'new_health_record': 'Yeni Sağlık Kaydı Ekle',
      'record_type': 'Kayıt Türü',
      'type_exam': 'Muayene',
      'type_checkup': 'Check-up',
      'type_vaccine_parasite': 'Aşı/Parazit',
      'type_surgery': 'Ameliyat',
      'type_lab': 'Tahlil',
      'type_dental': 'Diş',
      'diagnosis_title': 'Teşhis / Başlık (Örn: Mide Hassasiyeti)',
      'exam_date': 'Muayene Tarihi',
      'next_control_date': 'Kontrol Tarihi (Opsiyonel)',
      'prescriptions_label': 'Verilen İlaçlar / Reçete (Örn: Gastrovit, Yaş Mama)',
      'treatment_notes': 'Tedavi Notları & Tavsiyeler',
      'complete_record_btn': 'Kaydı Tamamla',
      'edit_medication': 'İlacı Düzenle',
      'new_medication': 'Yeni İlaç Ekle',
      'medication_name': 'İlaç Adı',
      'dosage_label': 'Dozaj (Örn: 1 tablet)',
      'frequency_label': 'Sıklık (Örn: Günde 2 kez)',
      'next_use_label': 'Sonraki Kullanım / Bitiş',
      'status_finished': 'Bitti',
      'add_pet_title': 'Yeni Evcil Hayvan Ekle',
      'pet_type_label': 'Türü',
      'edit_symptom': 'Belirtiyi Düzenle',
      'new_symptom': 'Yeni Belirti Ekle',
      'symptom_name_hint': 'Belirti (Örn: Kusma, Halsizlik)',
      'notes_desc': 'Notlar / Açıklama',
      'severity': 'Şiddeti',
      'form_severity': 'Şiddeti',
      'field_required': 'Bu alan zorunludur',
      'severity_mild': 'Hafif',
      'severity_moderate': 'Orta',
      'severity_severe': 'Yüksek',
      'severity_high': 'Şiddetli',
      'today': 'Bugün',
      'edit_emergency_contact': 'Kişiyi Düzenle',
      'new_emergency_contact': 'Yeni Acil Kişi Ekle',
      'contact_title_hint': 'Etiket (Örn: 7/24 Klinik)',
      'contact_name_hint': 'Kişi / Kurum Adı',
      'phone_number': 'Telefon Numarası',
      'birth_date': 'Doğum Tarihi',
      'weight_kg': 'Kilo (kg)',
      'chip_no_label': 'Mikroçip / Küpe Numarası',
      'gender_label': 'Cinsiyet:',
      'is_neutered_question': 'Kısırlaştırıldı mı?',
      'allergies_label': 'Bilinen Alerjiler (Örn: Tavuk, Tahıl)',
      'allergies': 'Alerjiler',
      'blood_type_label': 'Kan Grubu (Örn: DEA 1.1+ / A Grubu)',
      'special_notes_label': 'Özel Notlar & Alışkanlıklar',
      'notes_label': 'Notlar',
      'save_and_update': 'Kaydet ve Güncelle',
      'profile_updated_msg': 'Profil bilgileri güncellendi.',
      'weight_entry_title': 'Kilo Girişi',
      'new_weight_kg': 'Yeni Ağırlık (kg)',
      'weight_note_hint': 'Not (Örn: Sabah aç karnına)',
      'weight_saved_msg': 'kilosu kaydedildi.',
      'edit_training': 'Eğitimi Düzenle',
      'new_training': 'Yeni Eğitim Ekle',
      'training_name_hint': 'Eğitim / Komut Adı',
      'training_notes_hint': 'Notlar (Örn: Günde 5 dk çalışıldı)',
      'status_in_progress': 'Devam Ediyor',
      'edit_behavior': 'Davranışı Düzenle',
      'new_behavior': 'Yeni Davranış Ekle',
      'behavior_name_hint': 'Davranış / Sorun Adı',
      'noticed_date_hint': 'Fark Edilme Tarihi',
      'behavior_details_hint': 'Detaylar / Notlar',
      'severity_frequency': 'Şiddeti / Sıklığı',
      'edit_nutrition_plan': 'Beslenme Planını Düzenle',
      'total_daily_amount': 'Toplam Günlük Miktar (Örn: 420 g)',
      'food_type': 'Mama Türü (Örn: Kuru Mama)',
      'morning_meal': 'Sabah Öğünü',
      'evening_meal': 'Akşam Öğünü',
      'amount': 'Miktar',
      'guide_suffix': 'Rehberi',
      'care_tips_for': 'İçin Bakım İpuçları',
      'Evcil Dostunun Fotoğrafı': 'Evcil Dostunun Fotoğrafı',
      'Kendi fotoğrafını yükle veya sevimli avatar seç': 'Kendi fotoğrafını yükle veya sevimli avatar seç',
      'Kamera': 'Kamera',
      'Yeni Çek': 'Yeni Çek',
      'Galeri': 'Galeri',
      'Cihazdan Seç': 'Cihazdan Seç',
      'Veya Hazır Sevimli Karakter Seç:': 'Veya Hazır Sevimli Karakter Seç:',
      'Fotoğrafı Kaldır / Varsayılana Dön': 'Fotoğrafı Kaldır / Varsayılana Dön',
      'Fotoğraf Seç / Değiştir': 'Fotoğraf Seç / Değiştir',
      'Fotoğrafı Değiştir': 'Fotoğrafı Değiştir',
      'Fotoğraf güncellendi!': 'Fotoğraf güncellendi!',
    },

    // --- ENGLISH ---
    'en': {
      'app_title': 'PawGuide',
      'brand_prefix': 'Paw',
      'brand_suffix': 'Guide',
      'home': 'Home',
      'my_pet': 'My Pet',
      'reminders': 'Reminders',
      'profile': 'Profile',
      'search_hint': 'Search in guides, training or care...',
      'categories': 'Categories',
      'health': 'Health',
      'health_sub': 'Diseases & vaccines',
      'nutrition': 'Nutrition',
      'nutrition_sub': 'Food & portions',
      'care': 'Care',
      'care_sub': 'Hygiene & grooming',
      'education': 'Training',
      'education_sub': 'Commands & guides',
      'behavior': 'Behavior',
      'behavior_sub': 'Character & issues',
      'sitters': 'Vets & Clinics',
      'sitters_sub': 'Emergency & clinics',
      'clinics': 'Vets & Clinics',
      'clinics_sub': 'Emergency & clinics',
      'popular_topics': 'Popular Pet Care Guides',
      'comprehensive_list': 'Full Guide List',
      'digital_passport': 'DIGITAL PET PASSPORT',
      'pdf_export_passport': 'Download PDF Passport & Vaccine Book',
      'pdf_export_desc': 'Official digital document ready for veterinarians, travel, and checkups.',
      'pdf_view_print': 'Preview & Print PDF',
      'pdf_official_cert': 'Official International Passport',
      'pdf_modal_title': 'Digital Pet Health Passport',
      'pdf_modal_subtitle': 'Ready for veterinarians, international travel & official procedures',
      'pdf_modal_info': 'Support our independent development by watching a short video to download your PDF passport for free immediately.',
      'pdf_watch_ad_btn': 'Watch 1 Short Video & Download PDF (Free)',
      'pdf_support_dev_btn': 'Support Developer ({price} • Instant Access)',
      'pdf_direct_open_btn': 'Open Directly Without Waiting',
      'pdf_thank_you_support': 'Thank you for supporting the developer! Generating your PDF...',
      'support_dev_title': 'Developer Support',
      'support_dev_voluntary': 'Voluntary',
      'support_dev_subtitle': 'PatiRehber is an independent open development project',
      'support_dev_transparency_title': 'Transparent & Ethical Disclosure',
      'support_dev_transparency_desc': 'All voluntary contributions directly fund continued application development, server costs, and new feature coding. No core feature is ever paywalled.',
      'support_dev_options_title': 'Contribute to App Development',
      'support_dev_options_sub': 'Choose an optional support tier to help us maintain this app ad-free and independent:',
      'support_dev_coffee': 'Buy the Developer a Coffee',
      'support_dev_coffee_sub': 'A symbolic gesture of appreciation and motivation',
      'support_dev_plus': 'Become a PatiPlus Supporter (One-Time)',
      'support_dev_plus_sub': 'Developer supporter badge, ad-free experience & instant PDF export',
      'support_dev_continue_free': 'Continue Using for Free',
      'support_coffee_thank_you': 'Thank you so much for your support! You make a huge difference.',
      'support_plus_thank_you': 'You became a PatiPlus supporter! We are truly grateful.',
      'gender': 'GENDER',
      'birth': 'BIRTH',
      'neutered': 'NEUTERED',
      'male': 'Male',
      'female': 'Female',
      'yes': 'Yes',
      'no': 'No',
      'age': 'Age',
      'weight': 'Weight',
      'blood_type': 'Blood Type',
      'add_weight': '+ Weight',
      'edit_profile': 'Edit',
      'health_management': 'Health & Care Management',
      'vaccine_calendar': 'Vaccines',
      'vet_appointments': 'Vet Appts',
      'health_records': 'Medical Records',
      'medication_tracking': 'Medications',
      'emergency': 'Emergency',
      'disease_symptoms': 'Symptoms',
      'feedback_title': 'Developer Notes & Feedback',
      'feedback_sub': 'Share suggestions, feature requests or report bugs',
      'whatsapp_btn': 'WhatsApp',
      'email_btn': 'Email',
      'fill_form_btn': 'Fill Feedback Form',
      'view_inbox_btn': 'Review Incoming Messages (Developer)',
      'offline_status': '100% Offline Ready',
      'offline_desc': 'All photos and health logs are safely saved locally on your device.',
      'my_registered_pets': 'My Registered Pets',
      'manage': 'Manage',
      'app_preferences': 'App Preferences',
      'language_selection': 'Language / Sprache',
      'notifications': 'Appointment & Vaccine Reminders',
      'offline_cache': 'Local Offline Cache',
      'app_version': 'App Version',
      'save': 'Save',
      'cancel': 'Cancel',
      'add': 'Add',
      'delete': 'Delete',
      'understood': 'Understood, Great!',
      'all': 'All',
      'selected_pet': 'Selected Pet',
      'dog': 'Dog',
      'cat': 'Cat',
      'bird': 'Bird',
      'rabbit': 'Rabbit',
      'hamster': 'Hamster',
      'fish': 'Fish',
      'other': 'Other',
      'food_nutrition': 'Food & Nutrition',
      'housing_safety': 'Habitat & Safety',
      'sleep_rest': 'Sleep & Routine',
      'basic_training': 'Basic Training',
      'toilet_training': 'Potty Training',
      'edit_pet_info': 'Edit Information',
      'pet_name': 'Pet Name',
      'breed_label': 'Breed',
      'chip_no': 'Microchip Number',
      'weight_history': 'Weight Tracking History',
      'add_weight_record': 'Add Weight',
      'medical_alerts': 'Important Medical Alerts',
      'active_reminders': 'Active Reminders',
      'all_filter': 'All',
      'appointment': 'Appointment',
      'vaccine': 'Vaccine',
      'medication': 'Medication',
      'close': 'Close',
      'details': 'Details',
      'app_subtitle': 'Your pet\'s health is important to us.',
      'vaccine_calendar_sub': 'Current vaccine schedule',
      'vet_appointments_sub': 'Appointments & visits',
      'health_records_sub': 'Exams & reports',
      'medication_tracking_sub': 'Dosage & schedule',
      'disease_symptoms_sub': 'Early diagnosis & signs',
      'emergency_sub': 'Emergency & clinics',
      'vaccines_desc': 'Keep track of all vaccines.',
      'vet_appts_desc': 'Plan checkups and set reminder alarms.',
      'meds_desc': 'Track medications regularly, never miss a dose.',
      'symptoms_desc': 'Log symptoms to share with your vet.',
      'emergency_desc': 'Reach emergency help with one tap.',
      'health_records_desc': 'Keep exams, prescriptions and checkups in one place.',
      'add_vaccine_btn': 'Add New Vaccine',
      'add_appointment_btn': 'New Appt & Alarm',
      'add_medication_btn': 'Add Medication',
      'add_symptom_btn': 'Add Symptom',
      'add_contact_btn': 'Add Contact',
      'add_record_btn': 'Add Record',
      'vaccine_list': 'Vaccine List',
      'appointment_list': 'Appointment List',
      'medication_list': 'Medication List',
      'symptoms_list': 'Symptoms List',
      'emergency_contacts_list': 'Emergency Contacts',
      'common_symptoms_guide': 'Common Symptoms Guide',
      'emergency_guide': 'Emergency Guide',
      'next_vaccine': 'Next Vaccine',
      'days_left': 'days left',
      'alarms_active': 'Alarms Active',
      'status_completed': 'Completed',
      'status_upcoming': 'Upcoming',
      'status_planned': 'Planned',
      'status_active': 'Active',
      'alarm_on': 'On',
      'alarm_off': 'Off',
      'tap_to_enable_alarm': 'Alarm Off - Tap to enable',
      'severity_medium': 'Severity: Medium',
      'vaccines_completed': 'Vaccines completed',
      'vaccines_upcoming': 'Vaccines upcoming',
      'vaccines_planned': 'Vaccines planned',
      'feedback_desc': 'We continuously update and improve the app based on your requests. Feel free to send us feedback anytime.',
      'pet_parent': 'Pet Parent',
      'family_member': 'Pet Guide Family Member',
      'pets_registered_count': 'Pets Registered',
      'chipped': 'Chipped',
      'notifications_sub': 'Deliver reminder alarms to notifications',
      'dev_inbox_title': 'Developer Inbox',
      'dev_inbox_sub': 'All incoming suggestions and user feedback',
      'no_symptoms_recorded': 'No disease symptoms recorded.',
      'no_contacts_recorded': 'No emergency numbers recorded.',
      'health_tracking_title': 'Health Records',
      'health_tracking_sub': 'All past exams, lab tests and vaccine logs',
      'education_process': 'Training Process',
      'add_target_btn': 'Add Goal',
      'education_guides_title': 'Comprehensive Guides & Training',
      'education_guides_sub': 'Nutrition, habitat, sleep routine and obedience training',
      'care_needs_title': 'Care Needs',
      'nutrition_plan_title': 'Daily Nutrition Plan',
      'behavior_tracking_title': 'Behavior Tracking',
      'behavior_guides_title': 'Behavior & Character Guide',
      'behavior_guides_sub': 'Behavior, body language and psychology',
      'send_feedback_btn': 'Send Feedback',
      'feedback_sent_success': 'Your message has been sent successfully! Thank you. 🐾',
      'feedback_enter_message': 'Please enter your message.',
      'edit_vaccine': 'Edit Vaccine',
      'new_vaccine': 'Add New Vaccine',
      'vaccine_name': 'Vaccine Name',
      'date': 'Date',
      'time': 'Time',
      'status': 'Status',
      'edit_appointment': 'Edit Appointment',
      'new_appointment': 'New Vet Appointment',
      'appointment_reason': 'Reason for Appointment (e.g. Checkup & Vaccine)',
      'vet_clinic_address': 'Vet Clinic & Address',
      'vet_doctor_name': 'Veterinarian Name',
      'appointment_note': 'Appointment Note / Description (Optional)',
      'appointment_alarm_card': 'Appointment Alarm & Reminder',
      'alarm_subtitle': 'Notify when the time comes',
      'alarm_title_field': 'Alarm Name / Title',
      'notification_time': 'Notification Time:',
      'at_appointment_time': 'At Appointment Time',
      'hours_before_1': '1 Hour Before',
      'hours_before_3': '3 Hours Before',
      'days_before_1': '1 Day Before',
      'days_before_2': '2 Days Before',
      'edit_health_record': 'Edit Health Record',
      'new_health_record': 'Add New Health Record',
      'record_type': 'Record Type',
      'type_exam': 'Examination',
      'type_checkup': 'Check-up',
      'type_vaccine_parasite': 'Vaccine/Parasite',
      'type_surgery': 'Surgery',
      'type_lab': 'Lab Tests',
      'type_dental': 'Dental',
      'diagnosis_title': 'Diagnosis / Title (e.g. Sensitive Stomach)',
      'exam_date': 'Exam Date',
      'next_control_date': 'Follow-up Date (Optional)',
      'prescriptions_label': 'Prescribed Medications / Diet',
      'treatment_notes': 'Treatment Notes & Advice',
      'complete_record_btn': 'Complete Record',
      'edit_medication': 'Edit Medication',
      'new_medication': 'Add New Medication',
      'medication_name': 'Medication Name',
      'dosage_label': 'Dosage (e.g. 1 tablet)',
      'frequency_label': 'Frequency (e.g. 2 times a day)',
      'next_use_label': 'Next Dose / End Date',
      'status_finished': 'Finished',
      'add_pet_title': 'Add New Pet',
      'pet_type_label': 'Species / Type',
      'edit_symptom': 'Edit Symptom',
      'new_symptom': 'Add New Symptom',
      'symptom_name_hint': 'Symptom (e.g. Vomiting, Lethargy)',
      'notes_desc': 'Notes / Description',
      'severity': 'Severity',
      'form_severity': 'Severity',
      'field_required': 'This field is required',
      'severity_mild': 'Mild',
      'severity_moderate': 'Moderate',
      'severity_severe': 'High',
      'severity_high': 'Severe',
      'today': 'Today',
      'edit_emergency_contact': 'Edit Contact',
      'new_emergency_contact': 'Add Emergency Contact',
      'contact_title_hint': 'Tag (e.g. 24/7 Vet Clinic)',
      'contact_name_hint': 'Person / Clinic Name',
      'phone_number': 'Phone Number',
      'birth_date': 'Birth Date',
      'weight_kg': 'Weight (kg)',
      'chip_no_label': 'Microchip / Tag Number',
      'gender_label': 'Gender:',
      'is_neutered_question': 'Is Neutered / Spayed?',
      'allergies_label': 'Known Allergies (e.g. Chicken, Grain)',
      'allergies': 'Allergies',
      'blood_type_label': 'Blood Type (e.g. DEA 1.1+ / Group A)',
      'special_notes_label': 'Special Notes & Habits',
      'notes_label': 'Notes',
      'save_and_update': 'Save & Update',
      'profile_updated_msg': 'Profile information updated.',
      'weight_entry_title': 'Weight Entry',
      'new_weight_kg': 'New Weight (kg)',
      'weight_note_hint': 'Note (e.g. Fasting morning)',
      'weight_saved_msg': 'weight recorded.',
      'edit_training': 'Edit Training',
      'new_training': 'Add New Training',
      'training_name_hint': 'Training / Command Name',
      'training_notes_hint': 'Notes (e.g. 5 min daily practice)',
      'status_in_progress': 'In Progress',
      'edit_behavior': 'Edit Behavior',
      'new_behavior': 'Add New Behavior',
      'behavior_name_hint': 'Behavior / Issue Name',
      'noticed_date_hint': 'Date Noticed',
      'behavior_details_hint': 'Details / Notes',
      'severity_frequency': 'Severity / Frequency',
      'edit_nutrition_plan': 'Edit Nutrition Plan',
      'total_daily_amount': 'Total Daily Amount (e.g. 420 g)',
      'food_type': 'Food Type (e.g. Dry Kibble)',
      'morning_meal': 'Morning Meal',
      'evening_meal': 'Evening Meal',
      'amount': 'Amount',
      'guide_suffix': 'Guide',
      'care_tips_for': 'Care Tips for',
      'Evcil Dostunun Fotoğrafı': 'Pet Photo',
      'Kendi fotoğrafını yükle veya sevimli avatar seç': 'Upload your photo or choose a cute avatar',
      'Kamera': 'Camera',
      'Yeni Çek': 'Take Photo',
      'Galeri': 'Gallery',
      'Cihazdan Seç': 'Choose from Device',
      'Veya Hazır Sevimli Karakter Seç:': 'Or Choose a Predefined Avatar:',
      'Fotoğrafı Kaldır / Varsayılana Dön': 'Remove Photo / Reset to Default',
      'Fotoğraf Seç / Değiştir': 'Select / Change Photo',
      'Fotoğrafı Değiştir': 'Change Photo',
      'Fotoğraf güncellendi!': 'Photo updated!',
    },

    // --- DEUTSCH (GERMAN) ---
    'de': {
      'app_title': 'PfotenGuide',
      'brand_prefix': 'Pfoten',
      'brand_suffix': 'Guide',
      'home': 'Startseite',
      'my_pet': 'Mein Tier',
      'reminders': 'Erinnerungen',
      'profile': 'Profil',
      'search_hint': 'In Leitfäden, Training oder Pflege suchen...',
      'categories': 'Kategorien',
      'health': 'Gesundheit',
      'health_sub': 'Krankheiten & Impfungen',
      'nutrition': 'Ernährung',
      'nutrition_sub': 'Futter & Portionen',
      'care': 'Pflege',
      'care_sub': 'Hygiene & Fellpflege',
      'education': 'Training',
      'education_sub': 'Kommandos & Ratgeber',
      'behavior': 'Verhalten',
      'behavior_sub': 'Charakter & Probleme',
      'sitters': 'Tierärzte & Kliniken',
      'sitters_sub': 'Notfall-Kliniken',
      'clinics': 'Tierärzte & Kliniken',
      'clinics_sub': 'Notfall-Kliniken',
      'popular_topics': 'Beliebte Haustier-Ratgeber',
      'comprehensive_list': 'Komplette Liste',
      'digital_passport': 'DIGITALER HAUSTIERAUSWEIS',
      'pdf_export_passport': 'PDF-Heimtierausweis herunterladen',
      'pdf_export_desc': 'Offizielles digitales Dokument für Tierärzte, Reisen und Vorsorge.',
      'pdf_view_print': 'PDF anzeigen & drucken',
      'pdf_official_cert': 'Offizieller internationaler Ausweis',
      'pdf_modal_title': 'Digitaler Tiergesundheitspass',
      'pdf_modal_subtitle': 'Bereit für Tierarztbesuche, Reisen und behördliche Zwecke',
      'pdf_modal_info': 'Unterstützen Sie unsere unabhängige Entwicklung durch ein kurzes Video, um Ihren PDF-Pass sofort kostenlos herunterzuladen.',
      'pdf_watch_ad_btn': '1 kurzes Video ansehen & PDF laden (Kostenlos)',
      'pdf_support_dev_btn': 'Entwickler unterstützen ({price} • Sofort)',
      'pdf_direct_open_btn': 'Direkt ohne Wartezeit öffnen',
      'pdf_thank_you_support': 'Vielen Dank für Ihre Unterstützung! PDF wird geöffnet...',
      'support_dev_title': 'Entwickler unterstützen',
      'support_dev_voluntary': 'Freiwillig',
      'support_dev_subtitle': 'PatiRehber ist ein unabhängiges Softwareprojekt',
      'support_dev_transparency_title': 'Transparente Information',
      'support_dev_transparency_desc': 'Jede Unterstützung fließt direkt in die Weiterentwicklung, Serverkosten und neue Funktionen. Keine Pflichtzahlung.',
      'support_dev_options_title': 'Projekt unterstützen',
      'support_dev_options_sub': 'Wählen Sie eine Unterstützung, um werbefreie Entwicklung zu ermöglichen:',
      'support_dev_coffee': 'Dem Entwickler einen Kaffee spendieren',
      'support_dev_coffee_sub': 'Ein symbolisches Dankeschön und Motivation für den Entwickler',
      'support_dev_plus': 'PatiPlus-Unterstützer werden (Einmalig)',
      'support_dev_plus_sub': 'Unterstützer-Abzeichen, werbefrei & Sofort-PDF-Download',
      'support_dev_continue_free': 'Kostenlos weiternutzen',
      'support_coffee_thank_you': 'Vielen Dank für Ihre Unterstützung!',
      'support_plus_thank_you': 'Sie sind jetzt PatiPlus-Unterstützer! Herzlichen Dank.',
      'gender': 'GESCHLECHT',
      'birth': 'GEBURT',
      'neutered': 'KASTRIERT',
      'male': 'Männlich',
      'female': 'Weiblich',
      'yes': 'Ja',
      'no': 'Nein',
      'age': 'Alter',
      'weight': 'Gewicht',
      'blood_type': 'Blutgruppe',
      'add_weight': '+ Gewicht',
      'edit_profile': 'Bearbeiten',
      'health_management': 'Gesundheitsmanagement',
      'vaccine_calendar': 'Impfplan',
      'vet_appointments': 'Tierarzt',
      'health_records': 'Krankenakte',
      'medication_tracking': 'Medikamente',
      'emergency': 'Notfall 24/7',
      'disease_symptoms': 'Symptome',
      'feedback_title': 'Entwickler-Feedback & Ideen',
      'feedback_sub': 'Teilen Sie Vorschläge oder Fehlermeldungen direkt mit',
      'whatsapp_btn': 'WhatsApp',
      'email_btn': 'E-Mail',
      'fill_form_btn': 'Feedback-Formular ausfüllen',
      'view_inbox_btn': 'Nachrichten prüfen (Entwickler)',
      'offline_status': '100% Offline-Fähig',
      'offline_desc': 'Alle Fotos und Gesundheitsdaten sind lokal auf Ihrem Gerät gespeichert.',
      'my_registered_pets': 'Meine registrierten Tiere',
      'manage': 'Verwalten',
      'app_preferences': 'App-Einstellungen',
      'language_selection': 'Sprache / Language',
      'notifications': 'Termin- & Impfbenachrichtigungen',
      'offline_cache': 'Lokaler Offline-Zwischenspeicher',
      'app_version': 'App-Version',
      'save': 'Speichern',
      'cancel': 'Abbrechen',
      'add': 'Hinzufügen',
      'delete': 'Löschen',
      'understood': 'Verstanden, Super!',
      'all': 'Alle',
      'selected_pet': 'Ausgewähltes Tier',
      'dog': 'Hund',
      'cat': 'Katze',
      'bird': 'Vogel',
      'rabbit': 'Kaninchen',
      'hamster': 'Hamster',
      'fish': 'Fisch',
      'other': 'Andere',
      'food_nutrition': 'Futter & Diät',
      'housing_safety': 'Wohnen & Sicherheit',
      'sleep_rest': 'Schlaf & Ruhe',
      'basic_training': 'Grundkommandos',
      'toilet_training': 'Stubenreinheit',
      'edit_pet_info': 'Informationen bearbeiten',
      'pet_name': 'Tiername',
      'breed_label': 'Rasse',
      'chip_no': 'Mikrochip-Nummer',
      'weight_history': 'Gewichtsverlauf',
      'add_weight_record': 'Gewicht hinzufügen',
      'medical_alerts': 'Wichtige medizinische Hinweise',
      'active_reminders': 'Aktive Erinnerungen',
      'all_filter': 'Alle',
      'appointment': 'Termin',
      'vaccine': 'Impfung',
      'medication': 'Medikament',
      'close': 'Schließen',
      'details': 'Details',
      'app_subtitle': 'Die Gesundheit Ihres Lieblings liegt uns am Herzen.',
      'vaccine_calendar_sub': 'Aktueller Impfplan',
      'vet_appointments_sub': 'Termine & Kontrolle',
      'health_records_sub': 'Untersuchungen & Befunde',
      'medication_tracking_sub': 'Dosierung & Zeiten',
      'disease_symptoms_sub': 'Früherkennung & Symptome',
      'emergency_sub': 'Notfall & Tierklinik',
      'vaccines_desc': 'Impfungen regelmäßig verfolgen.',
      'vet_appts_desc': 'Termine planen und Alarme einrichten.',
      'meds_desc': 'Medikamente pünktlich einnehmen, nie vergessen.',
      'symptoms_desc': 'Symptome notieren und dem Tierarzt zeigen.',
      'emergency_desc': 'Im Notfall mit einem Klick Hilfe anrufen.',
      'health_records_desc': 'Untersuchungen und Rezepte an einem Ort.',
      'add_vaccine_btn': 'Neue Impfung',
      'add_appointment_btn': 'Neuer Termin & Alarm',
      'add_medication_btn': 'Medikament hinzufügen',
      'add_symptom_btn': 'Symptom hinzufügen',
      'add_contact_btn': 'Kontakt hinzufügen',
      'add_record_btn': 'Eintrag hinzufügen',
      'vaccine_list': 'Impfungsliste',
      'appointment_list': 'Terminliste',
      'medication_list': 'Medikamentenliste',
      'symptoms_list': 'Symptomliste',
      'emergency_contacts_list': 'Notfall-Telefonnummern',
      'common_symptoms_guide': 'Häufige Symptome Ratgeber',
      'emergency_guide': 'Erste-Hilfe-Ratgeber',
      'next_vaccine': 'Nächste Impfung',
      'days_left': 'Tage verbleibend',
      'alarms_active': 'Alarme aktiv',
      'status_completed': 'Erledigt',
      'status_upcoming': 'Anstehend',
      'status_planned': 'Geplant',
      'status_active': 'Aktiv',
      'alarm_on': 'An',
      'alarm_off': 'Aus',
      'tap_to_enable_alarm': 'Alarm Aus - Tippen zum Einschalten',
      'severity_medium': 'Schweregrad: Mittel',
      'vaccines_completed': 'Impfungen erledigt',
      'vaccines_upcoming': 'Impfungen anstehend',
      'vaccines_planned': 'Impfungen geplant',
      'feedback_desc': 'Wir aktualisieren und verbessern die App kontinuierlich basierend auf Ihren Wünschen.',
      'pet_parent': 'Haustierbesitzer',
      'family_member': 'Mitglied der Haustier-Familie',
      'pets_registered_count': 'Haustiere registriert',
      'chipped': 'Gechippt',
      'notifications_sub': 'Erinnerungsalarme auf dem Bildschirm anzeigen',
      'dev_inbox_title': 'Entwickler Posteingang',
      'dev_inbox_sub': 'Alle eingegangenen Vorschläge und Rückmeldungen',
      'no_symptoms_recorded': 'Keine Krankheitssymptome aufgezeichnet.',
      'no_contacts_recorded': 'Keine Notfallnummern hinterlegt.',
      'health_tracking_title': 'Gesundheitsakte',
      'health_tracking_sub': 'Alle bisherigen Untersuchungen, Tests und Impfungen',
      'education_process': 'Trainingsfortschritt',
      'add_target_btn': 'Ziel hinzufügen',
      'education_guides_title': 'Umfassende Leitfäden & Training',
      'education_guides_sub': 'Ernährung, Wohnen, Schlaf und Gehorsam',
      'care_needs_title': 'Pflegebedürfnisse',
      'nutrition_plan_title': 'Täglicher Ernährungsplan',
      'behavior_tracking_title': 'Verhaltensverfolgung',
      'behavior_guides_title': 'Verhaltens- & Charakter-Ratgeber',
      'behavior_guides_sub': 'Verhalten, Körpersprache und Psychologie',
      'send_feedback_btn': 'Nachricht senden',
      'feedback_sent_success': 'Ihre Nachricht wurde erfolgreich übermittelt! Vielen Dank. 🐾',
      'feedback_enter_message': 'Bitte geben Sie Ihre Nachricht ein.',
      'edit_vaccine': 'Impfung bearbeiten',
      'new_vaccine': 'Neue Impfung hinzufügen',
      'vaccine_name': 'Impfstoffname',
      'date': 'Datum',
      'time': 'Uhrzeit',
      'status': 'Status',
      'edit_appointment': 'Termin bearbeiten',
      'new_appointment': 'Neuer Tierarzttermin',
      'appointment_reason': 'Termingrund (z.B. Check-up & Impfung)',
      'vet_clinic_address': 'Tierklinik & Adresse',
      'vet_doctor_name': 'Name des Tierarztes',
      'appointment_note': 'Terminhinweis / Notiz (Optional)',
      'appointment_alarm_card': 'Terminerinnerung & Wecker',
      'alarm_subtitle': 'Benachrichtigen, wenn die Zeit da ist',
      'alarm_title_field': 'Alarmbezeichnung',
      'notification_time': 'Benachrichtigungszeit:',
      'at_appointment_time': 'Zum Terminzeitpunkt',
      'hours_before_1': '1 Stunde vorher',
      'hours_before_3': '3 Stunden vorher',
      'days_before_1': '1 Tag vorher',
      'days_before_2': '2 Tage vorher',
      'edit_health_record': 'Gesundheitsakte bearbeiten',
      'new_health_record': 'Neuen Eintrag hinzufügen',
      'record_type': 'Eintragsart',
      'type_exam': 'Untersuchung',
      'type_checkup': 'Check-up',
      'type_vaccine_parasite': 'Impfung/Parasit',
      'type_surgery': 'Operation',
      'type_lab': 'Laborbefund',
      'type_dental': 'Zahnbehandlung',
      'diagnosis_title': 'Diagnose / Titel (z.B. Magenbeschwerden)',
      'exam_date': 'Untersuchungsdatum',
      'next_control_date': 'Kontrolltermin (Optional)',
      'prescriptions_label': 'Verschriebene Medikamente / Diät',
      'treatment_notes': 'Behandlungshinweise & Empfehlungen',
      'complete_record_btn': 'Eintrag speichern',
      'edit_medication': 'Medikament bearbeiten',
      'new_medication': 'Neues Medikament hinzufügen',
      'medication_name': 'Medikamentenname',
      'dosage_label': 'Dosierung (z.B. 1 Tablette)',
      'frequency_label': 'Häufigkeit (z.B. 2x täglich)',
      'next_use_label': 'Nächste Einnahme / Ende',
      'status_finished': 'Beendet',
      'add_pet_title': 'Neues Tier hinzufügen',
      'pet_type_label': 'Art',
      'edit_symptom': 'Symptom bearbeiten',
      'new_symptom': 'Neues Symptom hinzufügen',
      'symptom_name_hint': 'Symptom (z.B. Erbrechen, Schlappheit)',
      'notes_desc': 'Notizen / Beschreibung',
      'severity': 'Schweregrad',
      'form_severity': 'Schweregrad',
      'field_required': 'Dieses Feld ist erforderlich',
      'severity_mild': 'Leicht',
      'severity_moderate': 'Mittel',
      'severity_severe': 'Hoch',
      'severity_high': 'Schwer',
      'today': 'Heute',
      'edit_emergency_contact': 'Kontakt bearbeiten',
      'new_emergency_contact': 'Neuen Notfallkontakt hinzufügen',
      'contact_title_hint': 'Bezeichnung (z.B. 24/7 Notfallklinik)',
      'contact_name_hint': 'Name der Klinik / Person',
      'phone_number': 'Telefonnummer',
      'birth_date': 'Geburtsdatum',
      'weight_kg': 'Gewicht (kg)',
      'chip_no_label': 'Mikrochip / Ohrmarkennummer',
      'gender_label': 'Geschlecht:',
      'is_neutered_question': 'Kastriert / Sterilisiert?',
      'allergies_label': 'Bekannte Allergien (z.B. Huhn, Getreide)',
      'allergies': 'Allergien',
      'blood_type_label': 'Blutgruppe (z.B. DEA 1.1+ / Gruppe A)',
      'special_notes_label': 'Besondere Hinweise & Gewohnheiten',
      'notes_label': 'Notizen',
      'save_and_update': 'Speichern & Aktualisieren',
      'profile_updated_msg': 'Profilinformationen aktualisiert.',
      'weight_entry_title': 'Gewichtseintrag',
      'new_weight_kg': 'Neues Gewicht (kg)',
      'weight_note_hint': 'Notiz (z.B. Morgens nüchtern)',
      'weight_saved_msg': 'Gewicht gespeichert.',
      'edit_training': 'Training bearbeiten',
      'new_training': 'Neues Training hinzufügen',
      'training_name_hint': 'Kommando / Übungsname',
      'training_notes_hint': 'Notizen (z.B. 5 Min tägliche Übung)',
      'status_in_progress': 'In Bearbeitung',
      'edit_behavior': 'Verhalten bearbeiten',
      'new_behavior': 'Neues Verhalten hinzufügen',
      'behavior_name_hint': 'Verhaltensauffälligkeit / Problem',
      'noticed_date_hint': 'Festgestellt am',
      'behavior_details_hint': 'Details / Notizen',
      'severity_frequency': 'Schweregrad / Häufigkeit',
      'edit_nutrition_plan': 'Ernährungsplan bearbeiten',
      'total_daily_amount': 'Tagesgesamtmenge (z.B. 420 g)',
      'food_type': 'Futterart (z.B. Trockenfutter)',
      'morning_meal': 'Mahlzeit Morgens',
      'evening_meal': 'Mahlzeit Abends',
      'amount': 'Menge',
      'guide_suffix': 'Leitfaden',
      'care_tips_for': 'Pflegetipps für',
      'Evcil Dostunun Fotoğrafı': 'Haustier-Foto',
      'Kendi fotoğrafını yükle veya sevimli avatar seç': 'Lade ein Foto hoch oder wähle einen Avatar',
      'Kamera': 'Kamera',
      'Yeni Çek': 'Neues Foto',
      'Galeri': 'Galerie',
      'Cihazdan Seç': 'Aus Gerät wählen',
      'Veya Hazır Sevimli Karakter Seç:': 'Oder wähle einen Avatar:',
      'Fotoğrafı Kaldır / Varsayılana Dön': 'Foto entfernen / Zurücksetzen',
      'Fotoğraf Seç / Değiştir': 'Foto wählen / ändern',
      'Fotoğrafı Değiştir': 'Foto ändern',
      'Fotoğraf güncellendi!': 'Foto aktualisiert!',
    },

    // --- FRANÇAIS (FRENCH) ---
    'fr': {
      'app_title': 'PatiGuide',
      'brand_prefix': 'Pati',
      'brand_suffix': 'Guide',
      'home': 'Accueil',
      'my_pet': 'Mon Animal',
      'reminders': 'Rappels',
      'profile': 'Profil',
      'search_hint': 'Rechercher guides, éducation ou soins...',
      'categories': 'Catégories',
      'health': 'Santé',
      'health_sub': 'Maladies & vaccins',
      'nutrition': 'Alimentation',
      'nutrition_sub': 'Croquettes & rations',
      'care': 'Soins',
      'care_sub': 'Hygiène & toilettage',
      'education': 'Éducation',
      'education_sub': 'Ordres & dressage',
      'behavior': 'Comportement',
      'behavior_sub': 'Psychologie animale',
      'sitters': 'Vétérinaires & Cliniques',
      'sitters_sub': 'Urgences & cliniques',
      'clinics': 'Vétérinaires & Cliniques',
      'clinics_sub': 'Urgences & cliniques',
      'popular_topics': 'Guides Populaires pour Animaux',
      'comprehensive_list': 'Liste Complète',
      'digital_passport': 'PASSEPORT NUMÉRIQUE DE L\'ANIMAL',
      'pdf_export_passport': 'Télécharger le passeport PDF & carnet vaccinal',
      'pdf_export_desc': 'Document officiel prêt pour vétérinaires, voyages et contrôles.',
      'pdf_view_print': 'Aperçu et impression PDF',
      'pdf_official_cert': 'Passeport officiel international',
      'pdf_modal_title': 'Passeport santé animal numérique',
      'pdf_modal_subtitle': 'Prêt pour le vétérinaire, les voyages et les démarches officielles',
      'pdf_modal_info': 'Soutenez notre travail indépendant en regardant une courte vidéo pour télécharger votre passeport PDF gratuitement.',
      'pdf_watch_ad_btn': 'Regarder 1 courte vidéo & Télécharger (Gratuit)',
      'pdf_support_dev_btn': 'Soutenir le développeur ({price} • Immédiat)',
      'pdf_direct_open_btn': 'Ouvrir directement sans attendre',
      'pdf_thank_you_support': 'Merci pour votre soutien ! Ouverture de votre PDF...',
      'support_dev_title': 'Soutien au développeur',
      'support_dev_voluntary': 'Volontaire',
      'support_dev_subtitle': 'PatiRehber est un projet de développement indépendant',
      'support_dev_transparency_title': 'Information transparente',
      'support_dev_transparency_desc': 'Tout soutien finance directement le développement de l\'application et les serveurs. Aucun paiement n\'est obligatoire.',
      'support_dev_options_title': 'Contribuer au développement',
      'support_dev_options_sub': 'Choisissez votre niveau de soutien pour encourager le projet :',
      'support_dev_coffee': 'Offrir un café au développeur',
      'support_dev_coffee_sub': 'Un remerciement symbolique pour encourager le développement',
      'support_dev_plus': 'Devenir supporter PatiPlus (Paiement unique)',
      'support_dev_plus_sub': 'Badge de soutien, expérience sans pub et export PDF instantané',
      'support_dev_continue_free': 'Continuer à utiliser gratuitement',
      'support_coffee_thank_you': 'Merci beaucoup pour votre soutien chaleureux !',
      'support_plus_thank_you': 'Vous êtes désormais supporter PatiPlus ! Merci infiniment.',
      'gender': 'SEXE',
      'birth': 'NAISSANCE',
      'neutered': 'STÉRILISÉ',
      'male': 'Mâle',
      'female': 'Femelle',
      'yes': 'Oui',
      'no': 'Non',
      'age': 'Âge',
      'weight': 'Poids',
      'blood_type': 'Groupe Sanguin',
      'add_weight': '+ Poids',
      'edit_profile': 'Modifier',
      'health_management': 'Gestion Médicale & Suivi',
      'vaccine_calendar': 'Vaccins',
      'vet_appointments': 'Vétérinaire',
      'health_records': 'Carnet de Santé',
      'medication_tracking': 'Médicaments',
      'emergency': 'Urgences 24/7',
      'disease_symptoms': 'Symptômes',
      'feedback_title': 'Notes au Développeur & Avis',
      'feedback_sub': 'Partagez vos idées ou signalez des anomalies',
      'whatsapp_btn': 'WhatsApp',
      'email_btn': 'E-mail',
      'fill_form_btn': 'Remplir le Formulaire',
      'view_inbox_btn': 'Boîte de Réception (Développeur)',
      'offline_status': '100% Prêt Hors Ligne',
      'offline_desc': 'Vos photos et dossiers médicaux sont conservés localement.',
      'my_registered_pets': 'Mes Animaux Enregistrés',
      'manage': 'Gérer',
      'app_preferences': 'Préférences de l\'Application',
      'language_selection': 'Langue / Language',
      'notifications': 'Rappels Vaccins & Rendez-vous',
      'offline_cache': 'Cache Local Hors Ligne',
      'app_version': 'Version de l\'App',
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'add': 'Ajouter',
      'delete': 'Supprimer',
      'understood': 'Compris, Parfait!',
      'all': 'Tous',
      'selected_pet': 'Animal Sélectionné',
      'dog': 'Chien',
      'cat': 'Chat',
      'bird': 'Oiseau',
      'rabbit': 'Lapin',
      'hamster': 'Hamster',
      'fish': 'Poisson',
      'other': 'Autre',
      'food_nutrition': 'Repas & Nutrition',
      'housing_safety': 'Habitat & Sécurité',
      'sleep_rest': 'Sommeil & Repos',
      'basic_training': 'Dressage de Base',
      'toilet_training': 'Apprentissage Propreté',
      'edit_pet_info': 'Modifier les informations',
      'pet_name': 'Nom de l\'animal',
      'breed_label': 'Race',
      'chip_no': 'Numéro de puce',
      'weight_history': 'Historique de poids',
      'add_weight_record': 'Ajouter un poids',
      'medical_alerts': 'Alertes médicales importantes',
      'active_reminders': 'Rappels actifs',
      'all_filter': 'Tous',
      'appointment': 'Rendez-vous',
      'vaccine': 'Vaccin',
      'medication': 'Médicament',
      'close': 'Fermer',
      'details': 'Détails',
      'app_subtitle': 'La santé de votre animal est notre priorité.',
      'vaccine_calendar_sub': 'Calendrier vaccinal',
      'vet_appointments_sub': 'Rendez-vous & visites',
      'health_records_sub': 'Examens & rapports',
      'medication_tracking_sub': 'Dosages & horaires',
      'disease_symptoms_sub': 'Détection précoce',
      'emergency_sub': 'Urgences & cliniques',
      'vaccines_desc': 'Suivez tous les vaccins régulièrement.',
      'vet_appts_desc': 'Planifiez les visites et réglez des alarmes.',
      'meds_desc': 'Suivez les médicaments, n\'oubliez aucune prise.',
      'symptoms_desc': 'Notez les symptômes pour votre vétérinaire.',
      'emergency_desc': 'Appelez les urgences en un clic.',
      'health_records_desc': 'Gardez examens et ordonnances au même endroit.',
      'add_vaccine_btn': 'Nouveau Vaccin',
      'add_appointment_btn': 'Rendez-vous & Alarme',
      'add_medication_btn': 'Ajouter Médicament',
      'add_symptom_btn': 'Ajouter Symptôme',
      'add_contact_btn': 'Ajouter Contact',
      'add_record_btn': 'Ajouter Dossier',
      'vaccine_list': 'Liste des vaccins',
      'appointment_list': 'Liste des rendez-vous',
      'medication_list': 'Liste des médicaments',
      'symptoms_list': 'Liste des symptômes',
      'emergency_contacts_list': 'Numéros d\'urgence',
      'common_symptoms_guide': 'Guide des symptômes fréquents',
      'emergency_guide': 'Guide de premiers secours',
      'next_vaccine': 'Prochain vaccin',
      'days_left': 'jours restants',
      'alarms_active': 'Alarmes actives',
      'status_completed': 'Terminé',
      'status_upcoming': 'À venir',
      'status_planned': 'Planifié',
      'status_active': 'Actif',
      'alarm_on': 'Activé',
      'alarm_off': 'Désactivé',
      'tap_to_enable_alarm': 'Alarme désactivée - Toucher pour activer',
      'severity_medium': 'Gravité: Moyenne',
      'vaccines_completed': 'Vaccins terminés',
      'vaccines_upcoming': 'Vaccins à venir',
      'vaccines_planned': 'Vaccins planifiés',
      'feedback_desc': 'Nous améliorons constamment l\'application selon vos souhaits. Partagez vos idées à tout moment.',
      'pet_parent': 'Parent d\'animal',
      'family_member': 'Membre de la famille',
      'pets_registered_count': 'Animaux enregistrés',
      'chipped': 'Pucé',
      'notifications_sub': 'Afficher les alarmes de rappel sur l\'écran',
      'dev_inbox_title': 'Boîte de réception développeur',
      'dev_inbox_sub': 'Toutes les suggestions et retours reçus',
      'no_symptoms_recorded': 'Aucun symptôme de maladie enregistré.',
      'no_contacts_recorded': 'Aucun contact d\'urgence enregistré.',
      'health_tracking_title': 'Suivi de Santé',
      'health_tracking_sub': 'Tous les examens, analyses et vaccins passés',
      'education_process': 'Programme d\'éducation',
      'add_target_btn': 'Ajouter Objectif',
      'education_guides_title': 'Guides Complets & Dressage',
      'education_guides_sub': 'Nourriture, habitat, sommeil et obéissance de base',
      'care_needs_title': 'Besoins de Toilettage',
      'nutrition_plan_title': 'Plan Nutritionnel Quotidien',
      'behavior_tracking_title': 'Suivi Comportemental',
      'behavior_guides_title': 'Guide Comportement & Caractère',
      'behavior_guides_sub': 'Comportement, langage corporel et psychologie',
      'send_feedback_btn': 'Envoyer le message',
      'feedback_sent_success': 'Votre message a été envoyé avec succès! Merci. 🐾',
      'feedback_enter_message': 'Veuillez saisir votre message.',
      'edit_vaccine': 'Modifier le vaccin',
      'new_vaccine': 'Ajouter un vaccin',
      'vaccine_name': 'Nom du vaccin',
      'date': 'Date',
      'time': 'Heure',
      'status': 'Statut',
      'edit_appointment': 'Modifier le rendez-vous',
      'new_appointment': 'Nouveau rendez-vous vétérinaire',
      'appointment_reason': 'Motif de consultation (ex: Bilan & Vaccin)',
      'vet_clinic_address': 'Clinique vétérinaire & Adresse',
      'vet_doctor_name': 'Nom du vétérinaire',
      'appointment_note': 'Notes de consultation (Optionnel)',
      'appointment_alarm_card': 'Alarme & Rappel de Rendez-vous',
      'alarm_subtitle': 'Alerter avec une notification',
      'alarm_title_field': 'Titre du rappel',
      'notification_time': 'Moment du rappel:',
      'at_appointment_time': 'À l\'heure du RDV',
      'hours_before_1': '1 heure avant',
      'hours_before_3': '3 heures avant',
      'days_before_1': '1 jour avant',
      'days_before_2': '2 jours avant',
      'edit_health_record': 'Modifier le dossier médical',
      'new_health_record': 'Ajouter un dossier médical',
      'record_type': 'Type de dossier',
      'type_exam': 'Consultation',
      'type_checkup': 'Bilan de santé',
      'type_vaccine_parasite': 'Vaccin/Parasite',
      'type_surgery': 'Chirurgie',
      'type_lab': 'Analyses labo',
      'type_dental': 'Dentaire',
      'diagnosis_title': 'Diagnostic / Titre (ex: Troubles digestifs)',
      'exam_date': 'Date de consultation',
      'next_control_date': 'Date de suivi (Optionnel)',
      'prescriptions_label': 'Médicaments prescrits / Régime',
      'treatment_notes': 'Notes de traitement & Conseils',
      'complete_record_btn': 'Enregistrer le dossier',
      'edit_medication': 'Modifier le médicament',
      'new_medication': 'Ajouter un médicament',
      'medication_name': 'Nom du médicament',
      'dosage_label': 'Dosage (ex: 1 comprimé)',
      'frequency_label': 'Fréquence (ex: 2 fois/jour)',
      'next_use_label': 'Prochaine prise / Fin',
      'status_finished': 'Terminé',
      'add_pet_title': 'Ajouter un animal',
      'pet_type_label': 'Espèce',
      'edit_symptom': 'Modifier le symptôme',
      'new_symptom': 'Ajouter un symptôme',
      'symptom_name_hint': 'Symptôme (ex: Vomissements, Fatigue)',
      'notes_desc': 'Notes / Description',
      'severity': 'Sévérité',
      'form_severity': 'Sévérité',
      'field_required': 'Ce champ est obligatoire',
      'severity_mild': 'Léger',
      'severity_moderate': 'Modéré',
      'severity_severe': 'Élevé',
      'severity_high': 'Sévère',
      'today': 'Aujourd\'hui',
      'edit_emergency_contact': 'Modifier le contact',
      'new_emergency_contact': 'Ajouter un contact d\'urgence',
      'contact_title_hint': 'Libellé (ex: Clinique d\'urgence 24h)',
      'contact_name_hint': 'Nom du vétérinaire / Clinique',
      'phone_number': 'Numéro de téléphone',
      'birth_date': 'Date de naissance',
      'weight_kg': 'Poids (kg)',
      'chip_no_label': 'Numéro de puce / tatouage',
      'gender_label': 'Sexe :',
      'is_neutered_question': 'Stérilisé(e) ?',
      'allergies_label': 'Allergies connues (ex: Poulet, Céréales)',
      'allergies': 'Allergies',
      'blood_type_label': 'Groupe sanguin (ex: DEA 1.1+ / Groupe A)',
      'special_notes_label': 'Notes spéciales & Habitudes',
      'notes_label': 'Notes',
      'save_and_update': 'Enregistrer & Mettre à jour',
      'profile_updated_msg': 'Profil mis à jour.',
      'weight_entry_title': 'Saisie du poids',
      'new_weight_kg': 'Nouveau poids (kg)',
      'weight_note_hint': 'Note (ex: Le matin à jeun)',
      'weight_saved_msg': 'poids enregistré.',
      'edit_training': 'Modifier l\'entraînement',
      'new_training': 'Ajouter un entraînement',
      'training_name_hint': 'Ordre / Commande',
      'training_notes_hint': 'Notes (ex: 5 min d\'exercice par jour)',
      'status_in_progress': 'En cours',
      'edit_behavior': 'Modifier le comportement',
      'new_behavior': 'Ajouter un comportement',
      'behavior_name_hint': 'Nom du comportement / Problème',
      'noticed_date_hint': 'Date constatée',
      'behavior_details_hint': 'Détails / Notes',
      'severity_frequency': 'Intensité / Fréquence',
      'edit_nutrition_plan': 'Modifier le plan nutritionnel',
      'total_daily_amount': 'Quantité quotidienne totale (ex: 420 g)',
      'food_type': 'Type d\'aliment (ex: Croquettes)',
      'morning_meal': 'Repas du matin',
      'evening_meal': 'Repas du soir',
      'amount': 'Quantité',
      'guide_suffix': 'Guide',
      'care_tips_for': 'Conseils de soins pour',
      'Evcil Dostunun Fotoğrafı': 'Photo de l\'animal',
      'Kendi fotoğrafını yükle veya sevimli avatar seç': 'Téléchargez une photo ou choisissez un avatar',
      'Kamera': 'Appareil photo',
      'Yeni Çek': 'Prendre',
      'Galeri': 'Galerie',
      'Cihazdan Seç': 'Choisir',
      'Veya Hazır Sevimli Karakter Seç:': 'Ou choisissez un avatar mignon :',
      'Fotoğrafı Kaldır / Varsayılana Dön': 'Supprimer la photo / Réinitialiser',
      'Fotoğraf Seç / Değiştir': 'Choisir / Modifier la photo',
      'Fotoğrafı Değiştir': 'Modifier la photo',
      'Fotoğraf güncellendi!': 'Photo mise à jour !',
    },

    // --- ESPAÑOL (SPANISH) ---
    'es': {
      'app_title': 'PatiGuía',
      'brand_prefix': 'Pati',
      'brand_suffix': 'Guía',
      'home': 'Inicio',
      'my_pet': 'Mi Mascota',
      'reminders': 'Recordatorios',
      'profile': 'Perfil',
      'search_hint': 'Buscar guías, educación o cuidados...',
      'categories': 'Categorías',
      'health': 'Salud',
      'health_sub': 'Enfermedades y vacunas',
      'nutrition': 'Nutrición',
      'nutrition_sub': 'Alimentación y porciones',
      'care': 'Cuidados',
      'care_sub': 'Higiene y aseo',
      'education': 'Educación',
      'education_sub': 'Comandos y guías',
      'behavior': 'Conducta',
      'behavior_sub': 'Comportamiento y pautas',
      'sitters': 'Veterinarios y Clínicas',
      'sitters_sub': 'Urgencias y clínicas',
      'clinics': 'Veterinarios y Clínicas',
      'clinics_sub': 'Urgencias y clínicas',
      'popular_topics': 'Guías Populares de Mascotas',
      'comprehensive_list': 'Lista Completa',
      'digital_passport': 'PASAPORTE DIGITAL DE MASCOTA',
      'pdf_export_passport': 'Descargar pasaporte PDF y cartilla de vacunación',
      'pdf_export_desc': 'Documento oficial listo para veterinarios, viajes y consultas.',
      'pdf_view_print': 'Vista previa e imprimir PDF',
      'pdf_official_cert': 'Pasaporte internacional oficial',
      'pdf_modal_title': 'Pasaporte digital de salud para mascotas',
      'pdf_modal_subtitle': 'Listo para visitas al veterinario, viajes y trámites oficiales',
      'pdf_modal_info': 'Apoya nuestro desarrollo independiente viendo un video corto para descargar tu pasaporte PDF gratis al instante.',
      'pdf_watch_ad_btn': 'Ver 1 video corto y descargar PDF (Gratis)',
      'pdf_support_dev_btn': 'Apoyar al desarrollador ({price} • Inmediato)',
      'pdf_direct_open_btn': 'Abrir directamente sin esperar',
      'pdf_thank_you_support': '¡Gracias por apoyar al desarrollador! Abriendo tu PDF...',
      'support_dev_title': 'Apoyo al desarrollador',
      'support_dev_voluntary': 'Voluntario',
      'support_dev_subtitle': 'PatiRehber es un proyecto de desarrollo independiente',
      'support_dev_transparency_title': 'Información transparente',
      'support_dev_transparency_desc': 'Todas las aportaciones financian directamente el desarrollo y los costes del servidor. Ningún pago es obligatorio.',
      'support_dev_options_title': 'Contribuir al desarrollo',
      'support_dev_options_sub': 'Elige una opción para ayudarnos a mantener la app sin anuncios e independiente:',
      'support_dev_coffee': 'Invitar a un café al desarrollador',
      'support_dev_coffee_sub': 'Un gesto simbólico de agradecimiento y motivación',
      'support_dev_plus': 'Hacerse colaborador PatiPlus (Pago único)',
      'support_dev_plus_sub': 'Insignia de colaborador, sin anuncios y descarga PDF instantánea',
      'support_dev_continue_free': 'Continuar usando gratis',
      'support_coffee_thank_you': '¡Muchas gracias por tu apoyo! Nos da gran impulso.',
      'support_plus_thank_you': '¡Ahora eres colaborador PatiPlus! Estamos muy agradecidos.',
      'gender': 'GÉNERO',
      'birth': 'NACIMIENTO',
      'neutered': 'ESTERILIZADO',
      'male': 'Macho',
      'female': 'Hembra',
      'yes': 'Sí',
      'no': 'No',
      'age': 'Edad',
      'weight': 'Peso',
      'blood_type': 'Grupo Sanguíneo',
      'add_weight': '+ Peso',
      'edit_profile': 'Editar',
      'health_management': 'Gestión de Salud y Cuidados',
      'vaccine_calendar': 'Vacunas',
      'vet_appointments': 'Citas Veterinarias',
      'health_records': 'Historial Médico',
      'medication_tracking': 'Medicamentos',
      'emergency': 'Urgencias 24/7',
      'disease_symptoms': 'Síntomas',
      'feedback_title': 'Mensaje al Desarrollador & Sugerencias',
      'feedback_sub': 'Comparte ideas, mejoras o reporta problemas',
      'whatsapp_btn': 'WhatsApp',
      'email_btn': 'Correo',
      'fill_form_btn': 'Llenar Formulario',
      'view_inbox_btn': 'Revisar Mensajes (Desarrollador)',
      'offline_status': '100% Funciona Sin Internet',
      'offline_desc': 'Tus fotos y registros médicos se almacenan en tu dispositivo.',
      'my_registered_pets': 'Mis Mascotas Registradas',
      'manage': 'Administrar',
      'app_preferences': 'Preferencias de la App',
      'language_selection': 'Idioma / Language',
      'notifications': 'Notificaciones de Citas y Vacunas',
      'offline_cache': 'Caché Local Sin Conexión',
      'app_version': 'Versión de la App',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'add': 'Añadir',
      'delete': 'Eliminar',
      'understood': '¡Entendido, Genial!',
      'all': 'Todos',
      'selected_pet': 'Mascota Seleccionada',
      'dog': 'Perro',
      'cat': 'Gato',
      'bird': 'Pájaro',
      'rabbit': 'Conejo',
      'hamster': 'Hámster',
      'fish': 'Pez',
      'other': 'Otro',
      'food_nutrition': 'Comida y Nutrición',
      'housing_safety': 'Hábitat y Seguridad',
      'sleep_rest': 'Sueño y Descanso',
      'basic_training': 'Adiestramiento Básico',
      'toilet_training': 'Entrenamiento Higiénico',
      'edit_pet_info': 'Editar Información',
      'pet_name': 'Nombre de la Mascota',
      'breed_label': 'Raza',
      'chip_no': 'Número de Microchip',
      'weight_history': 'Historial de Peso',
      'add_weight_record': 'Añadir Peso',
      'medical_alerts': 'Alertas Médicas Importantes',
      'active_reminders': 'Recordatorios Activos',
      'all_filter': 'Todos',
      'appointment': 'Cita',
      'vaccine': 'Vacuna',
      'medication': 'Medicamento',
      'close': 'Cerrar',
      'details': 'Detalles',
      'app_subtitle': 'La salud de tu mascota nos importa.',
      'vaccine_calendar_sub': 'Calendario de vacunas',
      'vet_appointments_sub': 'Citas y revisiones',
      'health_records_sub': 'Exámenes e informes',
      'medication_tracking_sub': 'Dosis y horarios',
      'disease_symptoms_sub': 'Detección temprana',
      'emergency_sub': 'Urgencias y clínicas',
      'vaccines_desc': 'Lleva el control de vacunas.',
      'vet_appts_desc': 'Planifica visitas y pon alarmas.',
      'meds_desc': 'Controla los medicamentos sin olvidar dosis.',
      'symptoms_desc': 'Anota los síntomas para tu veterinario.',
      'emergency_desc': 'Llama a urgencias con un solo toque.',
      'health_records_desc': 'Reúne consultas y recetas en un solo lugar.',
      'add_vaccine_btn': 'Añadir Vacuna',
      'add_appointment_btn': 'Nueva Cita y Alarma',
      'add_medication_btn': 'Añadir Medicamento',
      'add_symptom_btn': 'Añadir Síntoma',
      'add_contact_btn': 'Añadir Contacto',
      'add_record_btn': 'Añadir Registro',
      'vaccine_list': 'Lista de vacunas',
      'appointment_list': 'Lista de citas',
      'medication_list': 'Lista de medicamentos',
      'symptoms_list': 'Lista de síntomas',
      'emergency_contacts_list': 'Números de emergencia',
      'common_symptoms_guide': 'Guía de síntomas comunes',
      'emergency_guide': 'Guía de primeros auxilios',
      'next_vaccine': 'Próxima vacuna',
      'days_left': 'días restantes',
      'alarms_active': 'Alarmas activas',
      'status_completed': 'Completado',
      'status_upcoming': 'Próximo',
      'status_planned': 'Planificado',
      'status_active': 'Activo',
      'alarm_on': 'Activada',
      'alarm_off': 'Desactivada',
      'tap_to_enable_alarm': 'Alarma desactivada - Toca para activar',
      'severity_medium': 'Gravedad: Media',
      'vaccines_completed': 'Vacunas completadas',
      'vaccines_upcoming': 'Vacunas próximas',
      'vaccines_planned': 'Vacunas planificadas',
      'feedback_desc': 'Actualizamos y mejoramos continuamente la app según tus peticiones. Envíanos tus opiniones cuando quieras.',
      'pet_parent': 'Dueño de mascota',
      'family_member': 'Miembro de la familia',
      'pets_registered_count': 'Mascotas registradas',
      'chipped': 'Con Chip',
      'notifications_sub': 'Mostrar recordatorios de alarmas en el teléfono',
      'dev_inbox_title': 'Bandeja del desarrollador',
      'dev_inbox_sub': 'Todas las sugerencias y comentarios recibidos',
      'no_symptoms_recorded': 'No hay síntomas de enfermedad registrados.',
      'no_contacts_recorded': 'No hay números de emergencia guardados.',
      'health_tracking_title': 'Historial de Salud',
      'health_tracking_sub': 'Todas las revisiones, pruebas y vacunas pasadas',
      'education_process': 'Proceso de Adiestramiento',
      'add_target_btn': 'Añadir Objetivo',
      'education_guides_title': 'Guías Completas y Educación',
      'education_guides_sub': 'Comida, descanso, sueño y obediencia básica',
      'care_needs_title': 'Necesidades de Cuidado',
      'nutrition_plan_title': 'Plan Diario de Nutrición',
      'behavior_tracking_title': 'Seguimiento de Conducta',
      'behavior_guides_title': 'Guía de Conducta y Carácter',
      'behavior_guides_sub': 'Comportamiento, lenguaje corporal y psicología',
      'send_feedback_btn': 'Enviar mensaje',
      'feedback_sent_success': '¡Tu mensaje ha sido enviado con éxito! Gracias. 🐾',
      'feedback_enter_message': 'Por favor, escribe tu mensaje.',
      'edit_vaccine': 'Editar vacuna',
      'new_vaccine': 'Añadir nueva vacuna',
      'vaccine_name': 'Nombre de vacuna',
      'date': 'Fecha',
      'time': 'Hora',
      'status': 'Estado',
      'edit_appointment': 'Editar cita',
      'new_appointment': 'Nueva cita veterinaria',
      'appointment_reason': 'Motivo de consulta (ej: Revisión y Vacuna)',
      'vet_clinic_address': 'Clínica veterinaria y Dirección',
      'vet_doctor_name': 'Nombre del veterinario',
      'appointment_note': 'Notas de la cita (Opcional)',
      'appointment_alarm_card': 'Alarma y Recordatorio de Cita',
      'alarm_subtitle': 'Avisar con notificación a tiempo',
      'alarm_title_field': 'Nombre de la alarma',
      'notification_time': 'Momento del aviso:',
      'at_appointment_time': 'A la hora de la cita',
      'hours_before_1': '1 hora antes',
      'hours_before_3': '3 horas antes',
      'days_before_1': '1 día antes',
      'days_before_2': '2 días antes',
      'edit_health_record': 'Editar historial médico',
      'new_health_record': 'Añadir nuevo registro',
      'record_type': 'Tipo de registro',
      'type_exam': 'Consulta',
      'type_checkup': 'Chequeo',
      'type_vaccine_parasite': 'Vacuna/Parásito',
      'type_surgery': 'Cirugía',
      'type_lab': 'Análisis',
      'type_dental': 'Dental',
      'diagnosis_title': 'Diagnóstico / Título (ej: Gastritis)',
      'exam_date': 'Fecha de consulta',
      'next_control_date': 'Fecha de revisión (Opcional)',
      'prescriptions_label': 'Medicamentos recetados / Dieta',
      'treatment_notes': 'Notas de tratamiento y Consejos',
      'complete_record_btn': 'Completar registro',
      'edit_medication': 'Editar medicamento',
      'new_medication': 'Añadir nuevo medicamento',
      'medication_name': 'Nombre del medicamento',
      'dosage_label': 'Dosis (ej: 1 comprimido)',
      'frequency_label': 'Frecuencia (ej: 2 veces al día)',
      'next_use_label': 'Siguiente toma / Fin',
      'status_finished': 'Finalizado',
      'add_pet_title': 'Añadir nueva mascota',
      'pet_type_label': 'Especie',
      'edit_symptom': 'Editar síntoma',
      'new_symptom': 'Añadir síntoma',
      'symptom_name_hint': 'Síntoma (ej: Vómitos, Decaimiento)',
      'notes_desc': 'Notas / Descripción',
      'severity': 'Severidad',
      'form_severity': 'Severidad',
      'field_required': 'Este campo es obligatorio',
      'severity_mild': 'Leve',
      'severity_moderate': 'Moderada',
      'severity_severe': 'Alta',
      'severity_high': 'Grave',
      'today': 'Hoy',
      'edit_emergency_contact': 'Editar contacto',
      'new_emergency_contact': 'Añadir contacto de emergencia',
      'contact_title_hint': 'Etiqueta (ej: Clínica 24h)',
      'contact_name_hint': 'Nombre del contacto / Clínica',
      'phone_number': 'Número de teléfono',
      'birth_date': 'Fecha de nacimiento',
      'weight_kg': 'Peso (kg)',
      'chip_no_label': 'Número de microchip / placa',
      'gender_label': 'Sexo:',
      'is_neutered_question': '¿Esterilizado/a?',
      'allergies_label': 'Alergias conocidas (ej: Pollo, Cereales)',
      'allergies': 'Alergias',
      'blood_type_label': 'Grupo sanguíneo (ej: DEA 1.1+ / Grupo A)',
      'special_notes_label': 'Notas especiales y hábitos',
      'notes_label': 'Notas',
      'save_and_update': 'Guardar y actualizar',
      'profile_updated_msg': 'Información del perfil actualizada.',
      'weight_entry_title': 'Registro de peso',
      'new_weight_kg': 'Nuevo peso (kg)',
      'weight_note_hint': 'Nota (ej: En ayunas por la mañana)',
      'weight_saved_msg': 'peso registrado.',
      'edit_training': 'Editar entrenamiento',
      'new_training': 'Añadir entrenamiento',
      'training_name_hint': 'Orden / Comando',
      'training_notes_hint': 'Notas (ej: 5 min al día)',
      'status_in_progress': 'En progreso',
      'edit_behavior': 'Editar conducta',
      'new_behavior': 'Añadir conducta',
      'behavior_name_hint': 'Conducta / Problema',
      'noticed_date_hint': 'Fecha detectada',
      'behavior_details_hint': 'Detalles / Notas',
      'severity_frequency': 'Gravedad / Frecuencia',
      'edit_nutrition_plan': 'Editar plan de nutrición',
      'total_daily_amount': 'Cantidad diaria total (ej: 420 g)',
      'food_type': 'Tipo de alimento (ej: Pienso seco)',
      'morning_meal': 'Comida de la mañana',
      'evening_meal': 'Comida de la noche',
      'amount': 'Cantidad',
      'guide_suffix': 'Guía',
      'care_tips_for': 'Consejos de cuidado para',
      'Evcil Dostunun Fotoğrafı': 'Foto de la mascota',
      'Kendi fotoğrafını yükle veya sevimli avatar seç': 'Sube tu foto o elige un avatar',
      'Kamera': 'Cámara',
      'Yeni Çek': 'Tomar foto',
      'Galeri': 'Galería',
      'Cihazdan Seç': 'Elegir del dispositivo',
      'Veya Hazır Sevimli Karakter Seç:': 'O elige un avatar predefinido:',
      'Fotoğrafı Kaldır / Varsayılana Dön': 'Eliminar foto / Restablecer',
      'Fotoğraf Seç / Değiştir': 'Seleccionar / Cambiar foto',
      'Fotoğrafı Değiştir': 'Cambiar foto',
      'Fotoğraf güncellendi!': '¡Foto actualizada!',
    },

    // --- РУССКИЙ (RUSSIAN) ---
    'ru': {
      'app_title': 'ЛапаГид',
      'brand_prefix': 'Лапа',
      'brand_suffix': 'Гид',
      'home': 'Главная',
      'my_pet': 'Питомец',
      'reminders': 'Напоминания',
      'profile': 'Профиль',
      'search_hint': 'Поиск по руководствам, уходу и дрессировке...',
      'categories': 'Категории',
      'health': 'Здоровье',
      'health_sub': 'Болезни и прививки',
      'nutrition': 'Питание',
      'nutrition_sub': 'Корм и рацион',
      'care': 'Уход',
      'care_sub': 'Гигиена и чистота',
      'education': 'Обучение',
      'education_sub': 'Команды и воспитание',
      'behavior': 'Поведение',
      'behavior_sub': 'Характер и привычки',
      'sitters': 'Ветеринары и клиники',
      'sitters_sub': 'Дежурные клиники',
      'clinics': 'Ветеринары и клиники',
      'clinics_sub': 'Дежурные клиники',
      'popular_topics': 'Популярные руководства',
      'comprehensive_list': 'Полный список',
      'digital_passport': 'ЦИФРОВОЙ ВЕТЕРИНАРНЫЙ ПАСПОРТ',
      'pdf_export_passport': 'Скачать PDF ветпаспорт и карту прививок',
      'pdf_export_desc': 'Официальный цифровой документ для ветврачей, поездок и учёта.',
      'pdf_view_print': 'Просмотр и печать PDF',
      'pdf_official_cert': 'Международный ветеринарный паспорт',
      'pdf_modal_title': 'Цифровой ветеринарный паспорт',
      'pdf_modal_subtitle': 'Готов для визитов к ветеринару, поездок и контроля',
      'pdf_modal_info': 'Поддержите независимую разработку: посмотрите короткое видео, чтобы сразу бесплатно скачать ветеринарный PDF-паспорт.',
      'pdf_watch_ad_btn': 'Посмотреть 1 видео и скачать PDF (Бесплатно)',
      'pdf_support_dev_btn': 'Поддержать разработчика ({price} • Без ожидания)',
      'pdf_direct_open_btn': 'Открыть напрямую без ожидания',
      'pdf_thank_you_support': 'Спасибо за поддержку разработчика! Открываем ваш PDF...',
      'support_dev_title': 'Поддержка разработчика',
      'support_dev_voluntary': 'Добровольно',
      'support_dev_subtitle': 'PatiRehber — независимый проект разработки',
      'support_dev_transparency_title': 'Прозрачность и открытость',
      'support_dev_transparency_desc': 'Все пожертвования идут напрямую на развитие приложения, оплату серверов и новые функции. Платежи не являются обязательными.',
      'support_dev_options_title': 'Внести вклад в развитие приложения',
      'support_dev_options_sub': 'Выберите вариант поддержки для развития приложения без навязчивой рекламы:',
      'support_dev_coffee': 'Угостить разработчика кофе',
      'support_dev_coffee_sub': 'Символическая благодарность и мотивация для команды',
      'support_dev_plus': 'Стать спонсором PatiPlus (Единоразово)',
      'support_dev_plus_sub': 'Значок спонсора, работа без рекламы и мгновенный экспорт в PDF',
      'support_dev_continue_free': 'Продолжить бесплатно',
      'support_coffee_thank_you': 'Большое спасибо за вашу поддержку!',
      'support_plus_thank_you': 'Вы стали спонсором PatiPlus! Мы искренне благодарны.',
      'gender': 'ПОЛ',
      'birth': 'ДАТА РОЖДЕНИЯ',
      'neutered': 'СТЕРИЛИЗАЦИЯ',
      'male': 'Самец',
      'female': 'Самка',
      'yes': 'Да',
      'no': 'Нет',
      'age': 'Возраст',
      'weight': 'Вес',
      'blood_type': 'Группа крови',
      'add_weight': '+ Вес',
      'edit_profile': 'Изменить',
      'health_management': 'Здоровье и мониторинг',
      'vaccine_calendar': 'Вакцинация',
      'vet_appointments': 'Ветеринар',
      'health_records': 'Медкарта',
      'medication_tracking': 'Лекарства',
      'emergency': 'Скорая помощь 24/7',
      'disease_symptoms': 'Симптомы',
      'feedback_title': 'Отзыв разработчику и предложения',
      'feedback_sub': 'Поделитесь идеями или сообщите об ошибке',
      'whatsapp_btn': 'WhatsApp',
      'email_btn': 'Эл. почта',
      'fill_form_btn': 'Заполнить форму отзыва',
      'view_inbox_btn': 'Входящие сообщения (Разработчик)',
      'offline_status': '100% Работает Офлайн',
      'offline_desc': 'Все фото и медицинские данные хранятся локально на вашем устройстве.',
      'my_registered_pets': 'Мои питомцы',
      'manage': 'Управление',
      'app_preferences': 'Настройки приложения',
      'language_selection': 'Язык / Language',
      'notifications': 'Напоминания о приёмах и прививках',
      'offline_cache': 'Локальный офлайн-кэш',
      'app_version': 'Версия приложения',
      'save': 'Сохранить',
      'cancel': 'Отмена',
      'add': 'Добавить',
      'delete': 'Удалить',
      'understood': 'Понятно, отлично!',
      'all': 'Все',
      'selected_pet': 'Выбранный питомец',
      'dog': 'Собака',
      'cat': 'Кошка',
      'bird': 'Птица',
      'rabbit': 'Кролик',
      'hamster': 'Хомяк',
      'fish': 'Рыбка',
      'other': 'Другое',
      'food_nutrition': 'Еда и питание',
      'housing_safety': 'Жильё и безопасность',
      'sleep_rest': 'Сон и отдых',
      'basic_training': 'Базовые команды',
      'toilet_training': 'Приучение к туалету',
      'edit_pet_info': 'Изменить данные',
      'pet_name': 'Имя питомца',
      'breed_label': 'Порода',
      'chip_no': 'Номер микрочипа',
      'weight_history': 'История веса',
      'add_weight_record': 'Добавить вес',
      'medical_alerts': 'Медицинские предупреждения',
      'active_reminders': 'Активные напоминания',
      'all_filter': 'Все',
      'appointment': 'Приём',
      'vaccine': 'Прививка',
      'medication': 'Лекарство',
      'close': 'Закрыть',
      'details': 'Подробнее',
      'app_subtitle': 'Здоровье вашего питомца важно для нас.',
      'vaccine_calendar_sub': 'График прививок',
      'vet_appointments_sub': 'Приёмы и осмотры',
      'health_records_sub': 'Осмотры и анализы',
      'medication_tracking_sub': 'Дозировка и приём',
      'disease_symptoms_sub': 'Ранняя диагностика',
      'emergency_sub': 'Скорая помощь 24/7',
      'vaccines_desc': 'Следите за графиком прививок.',
      'vet_appts_desc': 'Планируйте визиты и ставьте напоминания.',
      'meds_desc': 'Принимайте лекарства вовремя, не забывая.',
      'symptoms_desc': 'Записывайте симптомы для визита к ветеринару.',
      'emergency_desc': 'Экстренный звонок ветеринару в один клик.',
      'health_records_desc': 'Все осмотры, рецепты и анализы в одном месте.',
      'add_vaccine_btn': 'Добавить прививку',
      'add_appointment_btn': 'Добавить приём и будильник',
      'add_medication_btn': 'Добавить лекарство',
      'add_symptom_btn': 'Добавить симптом',
      'add_contact_btn': 'Добавить контакт',
      'add_record_btn': 'Добавить запись',
      'vaccine_list': 'Список прививок',
      'appointment_list': 'Список приёмов',
      'medication_list': 'Список лекарств',
      'symptoms_list': 'Список симптомов',
      'emergency_contacts_list': 'Экстренные номера',
      'common_symptoms_guide': 'Частые симптомы',
      'emergency_guide': 'Первая помощь',
      'next_vaccine': 'Следующая прививка',
      'days_left': 'дней осталось',
      'alarms_active': 'Будильники вкл',
      'status_completed': 'Выполнено',
      'status_upcoming': 'Скоро',
      'status_planned': 'Запланировано',
      'status_active': 'Активно',
      'alarm_on': 'Вкл',
      'alarm_off': 'Выкл',
      'tap_to_enable_alarm': 'Будильник выкл - Нажмите для включения',
      'severity_medium': 'Тяжесть: Средняя',
      'vaccines_completed': 'Прививок сделано',
      'vaccines_upcoming': 'Прививок скоро',
      'vaccines_planned': 'Прививок в плане',
      'feedback_desc': 'Мы постоянно обновляем и улучшаем приложение на основе ваших отзывов. Отправьте нам предложение в любое время.',
      'pet_parent': 'Владелец питомца',
      'family_member': 'Член семьи PatiRehber',
      'pets_registered_count': 'питомцев зарегистрировано',
      'chipped': 'С чипом',
      'notifications_sub': 'Отправлять напоминания о визитах на экран',
      'dev_inbox_title': 'Входящие разработчика',
      'dev_inbox_sub': 'Все предложения и отзывы пользователей',
      'no_symptoms_recorded': 'Симптомов болезни не зарегистрировано.',
      'no_contacts_recorded': 'Экстренных номеров не добавлено.',
      'health_tracking_title': 'Медконтроль',
      'health_tracking_sub': 'Все прошлые осмотры, анализы и прививки',
      'education_process': 'Процесс дрессировки',
      'add_target_btn': 'Добавить цель',
      'education_guides_title': 'Полные руководства и дрессировка',
      'education_guides_sub': 'Питание, жильё, сон и базовое послушание',
      'care_needs_title': 'Потребности в уходе',
      'nutrition_plan_title': 'Дневной план кормления',
      'behavior_tracking_title': 'Мониторинг поведения',
      'behavior_guides_title': 'Поведение и характер',
      'behavior_guides_sub': 'Поведение, язык тела и психология',
      'send_feedback_btn': 'Отправить сообщение',
      'feedback_sent_success': 'Ваше сообщение успешно отправлено! Спасибо. 🐾',
      'feedback_enter_message': 'Пожалуйста, введите ваше сообщение.',
      'edit_vaccine': 'Изменить прививку',
      'new_vaccine': 'Добавить новую прививку',
      'vaccine_name': 'Название прививки',
      'date': 'Дата',
      'time': 'Время',
      'status': 'Статус',
      'edit_appointment': 'Изменить приём',
      'new_appointment': 'Новый приём у ветеринара',
      'appointment_reason': 'Причина визита (напр. Осмотр и прививка)',
      'vet_clinic_address': 'Ветклиника и адрес',
      'vet_doctor_name': 'Имя ветеринарного врача',
      'appointment_note': 'Заметка к приёму (Необязательно)',
      'appointment_alarm_card': 'Будильник и напоминание о приёме',
      'alarm_subtitle': 'Предупредить уведомлением вовремя',
      'alarm_title_field': 'Название будильника',
      'notification_time': 'Время оповещения:',
      'at_appointment_time': 'Во время приёма',
      'hours_before_1': 'За 1 час',
      'hours_before_3': 'За 3 часа',
      'days_before_1': 'За 1 день',
      'days_before_2': 'За 2 дня',
      'edit_health_record': 'Изменить медкарту',
      'new_health_record': 'Добавить запись',
      'record_type': 'Тип записи',
      'type_exam': 'Осмотр',
      'type_checkup': 'Чек-ап',
      'type_vaccine_parasite': 'Прививка/Паразиты',
      'type_surgery': 'Операция',
      'type_lab': 'Анализы',
      'type_dental': 'Стоматология',
      'diagnosis_title': 'Диагноз / Заголовок (напр. Гастрит)',
      'exam_date': 'Дата осмотра',
      'next_control_date': 'Дата контроля (Необязательно)',
      'prescriptions_label': 'Назначенные лекарства / Рецепт',
      'treatment_notes': 'Заметки по лечению и рекомендации',
      'complete_record_btn': 'Завершить запись',
      'edit_medication': 'Изменить лекарство',
      'new_medication': 'Добавить лекарство',
      'medication_name': 'Название лекарства',
      'dosage_label': 'Дозировка (напр. 1 таб)',
      'frequency_label': 'Частота (напр. 2 раза в день)',
      'next_use_label': 'Следующий приём / Окончание',
      'status_finished': 'Завершено',
      'add_pet_title': 'Добавить питомца',
      'pet_type_label': 'Вид',
      'edit_symptom': 'Редактировать симптом',
      'new_symptom': 'Добавить симптом',
      'symptom_name_hint': 'Симптом (напр. рвота, вялость)',
      'notes_desc': 'Заметки / Описание',
      'severity': 'Тяжесть',
      'form_severity': 'Тяжесть',
      'field_required': 'Это поле обязательно для заполнения',
      'severity_mild': 'Легкая',
      'severity_moderate': 'Средняя',
      'severity_severe': 'Высокая',
      'severity_high': 'Тяжелая',
      'today': 'Сегодня',
      'edit_emergency_contact': 'Редактировать контакт',
      'new_emergency_contact': 'Добавить экстренный контакт',
      'contact_title_hint': 'Метка (напр. Круглосуточная клиника)',
      'contact_name_hint': 'Имя врача / Название клиники',
      'phone_number': 'Номер телефона',
      'birth_date': 'Дата рождения',
      'weight_kg': 'Вес (кг)',
      'chip_no_label': 'Номер микрочипа / бирки',
      'gender_label': 'Пол:',
      'is_neutered_question': 'Стерилизован(а)?',
      'allergies_label': 'Аллергии (напр. курица, злаки)',
      'allergies': 'Аллергии',
      'blood_type_label': 'Группа крови (напр. DEA 1.1+ / Группа A)',
      'special_notes_label': 'Особые отметки и привычки',
      'notes_label': 'Заметки',
      'save_and_update': 'Сохранить и обновить',
      'profile_updated_msg': 'Данные профиля обновлены.',
      'weight_entry_title': 'Ввод веса',
      'new_weight_kg': 'Новый вес (кг)',
      'weight_note_hint': 'Заметка (напр. Утром натощак)',
      'weight_saved_msg': 'вес сохранен.',
      'edit_training': 'Редактировать тренировку',
      'new_training': 'Добавить тренировку',
      'training_name_hint': 'Команда / Название',
      'training_notes_hint': 'Заметки (напр. 5 мин в день)',
      'status_in_progress': 'В процессе',
      'edit_behavior': 'Редактировать поведение',
      'new_behavior': 'Добавить поведение',
      'behavior_name_hint': 'Поведение / Проблема',
      'noticed_date_hint': 'Дата обнаружения',
      'behavior_details_hint': 'Подробности / Заметки',
      'severity_frequency': 'Тяжесть / Частота',
      'edit_nutrition_plan': 'Редактировать план питания',
      'total_daily_amount': 'Общее количество в день (напр. 420 г)',
      'food_type': 'Тип корма (напр. Сухой корм)',
      'morning_meal': 'Утреннее кормление',
      'evening_meal': 'Вечернее кормление',
      'amount': 'Количество',
      'guide_suffix': 'Руководство',
      'care_tips_for': 'Советы по уходу для',
      'Evcil Dostunun Fotoğrafı': 'Фотография питомца',
      'Kendi fotoğrafını yükle veya sevimli avatar seç': 'Загрузите фото или выберите милый аватар',
      'Kamera': 'Камера',
      'Yeni Çek': 'Сделать снимок',
      'Galeri': 'Галерея',
      'Cihazdan Seç': 'Выбрать из устройства',
      'Veya Hazır Sevimli Karakter Seç:': 'Или выберите готового персонажа:',
      'Fotoğrafı Kaldır / Varsayılana Dön': 'Удалить фото / Сбросить',
      'Fotoğraf Seç / Değiştir': 'Выбрать / Изменить фото',
      'Fotoğrafı Değiştir': 'Изменить фото',
      'Fotoğraf güncellendi!': 'Фотография обновлена!',
    },
  };
}
