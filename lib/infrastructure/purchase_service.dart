import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/purchase_service.dart';
import 'package:shiori/env.dart';

class PurchaseServiceImpl implements PurchaseService {
  final LoggingService _loggingService;

  bool _initialized = false;
  List<AppUnlockedFeature>? _unlockedFeatures;

  @override
  bool get isInitialized => _initialized;

  PurchaseServiceImpl(this._loggingService);

  @override
  Future<bool> init() async {
    final isSupported = await isPlatformSupported();
    if (!isSupported) {
      return false;
    }

    try {
      if (_initialized) {
        return true;
      }

      if (!kReleaseMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      final key = Platform.isAndroid
          ? Env.androidPurchasesKey
          : Platform.isIOS || Platform.isMacOS
              ? Env.iosPurchasesKey
              : throw Exception('Platform not supported');
      await Purchases.configure(PurchasesConfiguration(key));
      _initialized = true;
      return true;
    } catch (e, s) {
      _handleError('init', e, s);
      return true;
    }
  }

  @override
  Future<bool> isPlatformSupported() {
    if (kIsWeb) {
      return Future.value(false);
    }

    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      return Future.value(true);
    }

    return Future.value(false);
  }

  @override
  Future<bool> canMakePurchases() async {
    try {
      return await Purchases.canMakePayments();
    } catch (e, s) {
      _handleError('canMakePurchases', e, s);
      return false;
    }
  }

  @override
  Future<List<PackageItemModel>> getInAppPurchases() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.all.values
          .expand((o) => o.availablePackages)
          .map(
            (p) => PackageItemModel(
              identifier: p.identifier,
              offeringIdentifier: p.offeringIdentifier,
              priceString: p.storeProduct.priceString,
              productIdentifier: p.storeProduct.identifier,
            ),
          )
          .toList()..sort((x,y) => x.priceString.compareTo(y.priceString));
    } catch (e, s) {
      _handleError('getInAppPurchases', e, s);
      return [];
    }
  }

  @override
  Future<bool> purchase(String identifier, String offeringIdentifier) async {
    try {
      //behind the scenes, the purchase method just uses two params...
      //that's why I create dummy object to satisfy the constructor
      const dummyProduct = StoreProduct('', '', '', 0, '0', '');
      final package = Package(identifier, PackageType.lifetime, dummyProduct, offeringIdentifier);
      final customerInfo = await Purchases.purchasePackage(package);
      return true;
    } catch (e, s) {
      _handleError('purchase', e, s);
      return false;
    }
  }

  @override
  Future<bool> restorePurchases({String? entitlementIdentifier}) async {
    try {
      _unlockedFeatures = null;
      final transactions = await Purchases.restorePurchases();
      final features = await _getUnlockedFeatures(entitlementIdentifier: entitlementIdentifier);
      return features.isNotEmpty;
    } catch (e, s) {
      _handleError('restorePurchases', e, s);
      return false;
    }
  }

  @override
  Future<List<AppUnlockedFeature>> getUnlockedFeatures() async {
    try {
      final features = await _getUnlockedFeatures();
      return features;
    } catch (e, s) {
      _handleError('getUnlockedFeatures', e, s);
      return [];
    }
  }

  @override
  Future<bool> isFeatureUnlocked(AppUnlockedFeature feature) async {
    final features = await getUnlockedFeatures();
    return features.contains(feature);
  }

  Future<List<AppUnlockedFeature>> _getUnlockedFeatures({String? entitlementIdentifier}) async {
    try {
      if (_unlockedFeatures != null) {
        return _unlockedFeatures!;
      }

      if (!await isPlatformSupported()) {
        return [];
      }

      final customerInfo = await Purchases.getCustomerInfo();
      if (entitlementIdentifier.isNullEmptyOrWhitespace) {
        final activeEntitlements = customerInfo.entitlements.active.values.any((el) => el.isActive);
        _unlockedFeatures = activeEntitlements ? AppUnlockedFeature.values : [];
        return _unlockedFeatures!;
      }

      final entitlement = customerInfo.entitlements.active.values.firstWhereOrNull((el) => el.identifier == entitlementIdentifier && el.isActive);
      _unlockedFeatures = entitlement != null ? AppUnlockedFeature.values : [];
      return _unlockedFeatures!;
    } catch (e) {
      rethrow;
    }
  }

  void _handleError(String methodName, dynamic e, StackTrace s) {
    if (e is PlatformException) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        _loggingService.error(runtimeType, '$methodName: Purchase error = $errorCode', e, s);
      }
      return;
    }

    _loggingService.error(runtimeType, '$methodName: Unknown error occurred', e, s);
  }
}
