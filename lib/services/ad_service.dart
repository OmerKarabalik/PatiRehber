import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/global_state.dart';

class AdService {
  static bool _isInitialized = false;

  // Rewarded Ad state (Android: RewardedAd, iOS: RewardedInterstitialAd)
  static RewardedAd? _rewardedAd;
  static RewardedInterstitialAd? _rewardedInterstitialAd;
  static bool _isRewardedLoading = false;

  // Interstitial Ad state
  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialLoading = false;

  // Smart Anti-Annoyance Frequency Capping
  static int _completedActionCount = 0;
  static const int actionThreshold = 3; // En az 3 işlem geçmeden reklam çıkmaz
  static DateTime? _lastInterstitialShownTime;
  static const Duration cooldownDuration = Duration(minutes: 3); // İki reklam arası en az 3 dk

  // --- REKLAM BİRİM KODLARI (AD UNIT IDS) ---
  // Android App ID: ca-app-pub-5160530830178108~7553810435
  // iOS App ID: ca-app-pub-5160530830178108~8435098526
  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      // PDF Odullu Reklam
      return 'ca-app-pub-5160530830178108/3562806563';
    } else if (Platform.isIOS) {
      // PatiRehber iOS Odullu (Rewarded Interstitial)
      return 'ca-app-pub-5160530830178108/3905660724';
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      // PatiRehber Akilli Gecis
      return 'ca-app-pub-5160530830178108/2956301902';
    } else if (Platform.isIOS) {
      // PatiRehber iOS Gecis
      return 'ca-app-pub-5160530830178108/4971330386';
    }
    return '';
  }

  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      // PatiRehber Alt Banner
      return 'ca-app-pub-5160530830178108/4998257294';
    } else if (Platform.isIOS) {
      // PatiRehber iOS Banner
      return 'ca-app-pub-5160530830178108/5410314086';
    }
    return '';
  }

  /// Initializes the Google Mobile Ads SDK
  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdMob SDK Başarıyla Başlatıldı.');
      loadRewardedAd();
      loadInterstitialAd();
    } catch (e) {
      debugPrint('AdMob Başlatma Hatası: $e');
    }
  }

  // ==========================================
  // 1. ÖDÜLLÜ REKLAM (REWARDED AD)
  // ==========================================

  /// Pre-loads a rewarded ad in the background
  static void loadRewardedAd() {
    if (kIsWeb || _isRewardedLoading || _rewardedAd != null || _rewardedInterstitialAd != null) return;
    final adUnitId = rewardedAdUnitId;
    if (adUnitId.isEmpty) return;

    _isRewardedLoading = true;
    if (Platform.isIOS) {
      RewardedInterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedInterstitialAd = ad;
            _isRewardedLoading = false;
            debugPrint('AdMob: iOS Ödüllü Geçiş Reklamı Hazır.');
          },
          onAdFailedToLoad: (error) {
            _rewardedInterstitialAd = null;
            _isRewardedLoading = false;
            debugPrint('AdMob: iOS Ödüllü Geçiş Reklamı Yüklenemedi: $error');
          },
        ),
      );
      return;
    }

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          debugPrint('AdMob: Ödüllü Reklam Hazır.');
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedLoading = false;
          debugPrint('AdMob: Ödüllü Reklam Yüklenemedi: $error');
        },
      ),
    );
  }

  /// Displays the rewarded ad and triggers [onUserEarnedReward] when completed
  static void showRewardedAd({
    required BuildContext context,
    required VoidCallback onUserEarnedReward,
    VoidCallback? onAdDismissed,
  }) {
    if (kIsWeb) {
      onUserEarnedReward();
      return;
    }

    if (Platform.isIOS && _rewardedInterstitialAd != null) {
      _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedInterstitialAd = null;
          loadRewardedAd();
          onAdDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _rewardedInterstitialAd = null;
          loadRewardedAd();
          onUserEarnedReward();
        },
      );

      _rewardedInterstitialAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint('AdMob: iOS ödülü kazandı: ${reward.amount} ${reward.type}');
          onUserEarnedReward();
        },
      );
      _rewardedInterstitialAd = null;
      return;
    }

    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          loadRewardedAd();
          onAdDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _rewardedAd = null;
          loadRewardedAd();
          onUserEarnedReward();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint('AdMob: Kullanıcı ödülü kazandı: ${reward.amount} ${reward.type}');
          onUserEarnedReward();
        },
      );
      _rewardedAd = null;
    } else {
      loadRewardedAd();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF1B5E20),
          content: Text('Sponsor desteğiniz alındı! PDF belgeniz hazırlanıyor...'),
          duration: Duration(seconds: 2),
        ),
      );
      onUserEarnedReward();
    }
  }

  // ==========================================
  // 2. AKILLI GEÇİŞ REKLAMI (SMART INTERSTITIAL)
  // ==========================================

  /// Pre-loads an interstitial ad in the background
  static void loadInterstitialAd() {
    if (kIsWeb || _isInterstitialLoading || _interstitialAd != null) return;
    final adUnitId = interstitialAdUnitId;
    if (adUnitId.isEmpty) return;

    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          debugPrint('AdMob: Geçiş Reklamı Hazır.');
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
          debugPrint('AdMob: Geçiş Reklamı Yüklenemedi: $error');
        },
      ),
    );
  }

  /// Triggers an action completion check. Only shows ad if threshold & cooldown conditions are met.
  static void onActionCompleted({VoidCallback? onFinished}) {
    if (kIsWeb || GlobalState.isPatiPlus) {
      onFinished?.call();
      return;
    }

    _completedActionCount++;
    final now = DateTime.now();

    final bool meetsThreshold = _completedActionCount >= actionThreshold;
    final bool meetsCooldown = _lastInterstitialShownTime == null ||
        now.difference(_lastInterstitialShownTime!) >= cooldownDuration;

    if (meetsThreshold && meetsCooldown && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd();
          onFinished?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd();
          onFinished?.call();
        },
      );

      _lastInterstitialShownTime = now;
      _completedActionCount = 0; // Reset counter
      _interstitialAd!.show();
      _interstitialAd = null;
      debugPrint('AdMob: Akıllı Geçiş Reklamı Gösterildi (Frekans & Bekleme Kuralına Uygun).');
    } else {
      // Reklam koşulları oluşmadı veya reklam hazır değil, kullanıcıyı bekletme
      if (_interstitialAd == null) {
        loadInterstitialAd();
      }
      onFinished?.call();
    }
  }
}

// ==========================================
// 3. ZARİF ALT BANNER WIDGET (PATIBANNER)
// ==========================================

class PatiBannerAdWidget extends StatefulWidget {
  const PatiBannerAdWidget({super.key});

  @override
  State<PatiBannerAdWidget> createState() => _PatiBannerAdWidgetState();
}

class _PatiBannerAdWidgetState extends State<PatiBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!GlobalState.isPatiPlus) {
      _loadBanner();
    }
  }

  void _loadBanner() {
    if (kIsWeb) return;
    final adUnitId = AdService.bannerAdUnitId;
    if (adUnitId.isEmpty) return;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isBannerLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('AdMob Banner Hatası: $error');
          if (mounted) {
            setState(() {
              _isBannerLoaded = false;
            });
          }
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (GlobalState.isPatiPlus || !_isBannerLoaded || _bannerAd == null) {
      // PatiPlus destekçisi veya reklam yüklenmediğinde 0 piksel kapla
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.8)),
      ),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
