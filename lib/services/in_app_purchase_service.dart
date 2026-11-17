import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../models/global_state.dart';

class InAppPurchaseService {
  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  static bool _isInitialized = false;

  // Product IDs configured for Google Play Console & App Store
  static const String productCoffee = 'pati_coffee';
  static const String productPatiPlus = 'pati_plus_pro';
  static const Set<String> _kProductIds = {productCoffee, productPatiPlus};

  static List<ProductDetails> products = [];
  static bool isStoreAvailable = false;

  /// Initializes in-app purchase stream and queries store products
  static Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      final available = await _iap.isAvailable();
      isStoreAvailable = available;

      if (available) {
        final response = await _iap.queryProductDetails(_kProductIds);
        products = response.productDetails;
        debugPrint('IAP: Loaded ${products.length} products from store.');
      }

      _subscription = _iap.purchaseStream.listen(
        _onPurchaseStream,
        onDone: () => _subscription?.cancel(),
        onError: (e) => debugPrint('IAP Stream error: $e'),
      );
    } catch (e) {
      debugPrint('IAP initialize error: $e');
    }
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _isInitialized = false;
  }

  static Future<void> _onPurchaseStream(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('IAP: Purchase pending: ${purchaseDetails.productID}');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('IAP: Purchase error: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Grant PatiPlus / Ad-free access
        await GlobalState.setPatiPlus(true);
        debugPrint('IAP: Purchase granted for ${purchaseDetails.productID}');

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  /// Initiates Google Play / App Store purchase for coffee support
  static Future<void> buyCoffee(BuildContext context, {required VoidCallback onSuccess}) async {
    await _handlePurchase(context, productCoffee, isConsumable: true, onSuccess: onSuccess);
  }

  /// Initiates Google Play / App Store purchase for PatiPlus lifetime pro
  static Future<void> buyPatiPlus(BuildContext context, {required VoidCallback onSuccess}) async {
    await _handlePurchase(context, productPatiPlus, isConsumable: false, onSuccess: onSuccess);
  }

  static Future<void> _handlePurchase(
    BuildContext context,
    String productId, {
    required bool isConsumable,
    required VoidCallback onSuccess,
  }) async {
    try {
      final available = await _iap.isAvailable();
      if (!available) {
        if (context.mounted) {
          _showStoreNotAvailableDialog(context, productId, onSuccess);
        }
        return;
      }

      ProductDetails? product;
      try {
        product = products.firstWhere((p) => p.id == productId);
      } catch (_) {
        product = null;
      }

      if (product == null) {
        // Query again if list was empty
        final res = await _iap.queryProductDetails({productId});
        if (res.productDetails.isNotEmpty) {
          product = res.productDetails.first;
        }
      }

      if (product == null) {
        if (context.mounted) {
          _showStoreNotAvailableDialog(context, productId, onSuccess);
        }
        return;
      }

      final purchaseParam = PurchaseParam(productDetails: product);
      if (isConsumable) {
        await _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
      } else {
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      debugPrint('IAP purchase error: $e');
      if (context.mounted) {
        _showStoreNotAvailableDialog(context, productId, onSuccess);
      }
    }
  }

  static void _showStoreNotAvailableDialog(
    BuildContext context,
    String productId,
    VoidCallback onSuccess,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.error_outline_rounded, color: Color(0xFFE74C3C)),
              SizedBox(width: 8),
              Text('Ödeme Servisi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: const Text(
            'Mağaza ödeme sistemine şu anda ulaşılamıyor veya ürün bilgisi doğrulanamadı. Lütfen internet bağlantınızı kontrol edip biraz sonra tekrar deneyiniz.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tamam', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  /// Restores previous purchases
  static Future<void> restorePurchases(BuildContext context) async {
    try {
      final available = await _iap.isAvailable();
      if (!available) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mağaza bağlantısı kurulamadı.')),
          );
        }
        return;
      }
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('IAP restore error: $e');
    }
  }
}
