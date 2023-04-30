import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/models/models.dart';

import '../../mocks.mocks.dart';

void main() {
  const packages = <PackageItemModel>[
    PackageItemModel(identifier: '123', offeringIdentifier: 'xyz', productIdentifier: 'xxx', priceString: '2\$'),
    PackageItemModel(identifier: '456', offeringIdentifier: 'xyz', productIdentifier: 'yyy', priceString: '5\$'),
    PackageItemModel(identifier: '789', offeringIdentifier: 'xyz', productIdentifier: 'zzz', priceString: '10\$'),
  ];

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test(
    'Initial state',
    () => expect(DonationsBloc(MockPurchaseService(), MockNetworkService(), MockTelemetryService()).state, const DonationsState.loading()),
  );

  group('init', () {
    blocTest<DonationsBloc, DonationsState>(
      'network is not available',
      build: () {
        final networkService = MockNetworkService();
        final purchaseService = MockPurchaseService();
        when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(false));
        return DonationsBloc(purchaseService, networkService, MockTelemetryService());
      },
      act: (bloc) => bloc.add(const DonationsEvent.init()),
      expect: () => const [
        DonationsState.loading(),
        DonationsState.initial(
          packages: [],
          isInitialized: false,
          noInternetConnection: true,
          canMakePurchases: false,
        )
      ],
    );

    blocTest<DonationsBloc, DonationsState>(
      'platform is not supported',
      build: () {
        final networkService = MockNetworkService();
        final purchaseService = MockPurchaseService();
        when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(true));
        when(purchaseService.isPlatformSupported()).thenAnswer((_) => Future.value(false));
        return DonationsBloc(purchaseService, networkService, MockTelemetryService());
      },
      act: (bloc) => bloc.add(const DonationsEvent.init()),
      expect: () => const [
        DonationsState.loading(),
        DonationsState.initial(
          packages: [],
          isInitialized: false,
          noInternetConnection: false,
          canMakePurchases: false,
        )
      ],
    );

    blocTest<DonationsBloc, DonationsState>(
      'cannot make purchases',
      build: () {
        final networkService = MockNetworkService();
        final purchaseService = MockPurchaseService();
        when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(true));
        when(purchaseService.isPlatformSupported()).thenAnswer((_) => Future.value(true));
        when(purchaseService.isInitialized).thenReturn(true);
        when(purchaseService.init()).thenAnswer((_) => Future.value(true));
        when(purchaseService.canMakePurchases()).thenAnswer((_) => Future.value(false));
        return DonationsBloc(purchaseService, networkService, MockTelemetryService());
      },
      act: (bloc) => bloc.add(const DonationsEvent.init()),
      expect: () => const [
        DonationsState.loading(),
        DonationsState.initial(
          packages: [],
          isInitialized: true,
          noInternetConnection: false,
          canMakePurchases: false,
        ),
      ],
    );

    blocTest<DonationsBloc, DonationsState>(
      'purchases are loaded',
      build: () {
        final networkService = MockNetworkService();
        final purchaseService = MockPurchaseService();
        when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(true));
        when(purchaseService.isPlatformSupported()).thenAnswer((_) => Future.value(true));
        when(purchaseService.isInitialized).thenReturn(true);
        when(purchaseService.init()).thenAnswer((_) => Future.value(true));
        when(purchaseService.canMakePurchases()).thenAnswer((_) => Future.value(true));
        when(purchaseService.getInAppPurchases()).thenAnswer((_) => Future.value(packages));
        return DonationsBloc(purchaseService, networkService, MockTelemetryService());
      },
      act: (bloc) => bloc.add(const DonationsEvent.init()),
      expect: () => const [
        DonationsState.loading(),
        DonationsState.initial(
          packages: packages,
          isInitialized: true,
          noInternetConnection: false,
          canMakePurchases: true,
        ),
      ],
    );
  });

  group('restore purchases', () {
    DonationsBloc getBloc({bool restoreSucceeds = true}) {
      final networkService = MockNetworkService();
      final purchaseService = MockPurchaseService();
      when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(true));
      when(purchaseService.isPlatformSupported()).thenAnswer((_) => Future.value(true));
      when(purchaseService.isInitialized).thenReturn(true);
      when(purchaseService.init()).thenAnswer((_) => Future.value(true));
      when(purchaseService.canMakePurchases()).thenAnswer((_) => Future.value(true));
      when(purchaseService.getInAppPurchases()).thenAnswer((_) => Future.value(packages));
      when(purchaseService.restorePurchases()).thenAnswer((_) => Future.value(restoreSucceeds));
      return DonationsBloc(purchaseService, networkService, MockTelemetryService());
    }

    blocTest<DonationsBloc, DonationsState>(
      'succeeds',
      build: () => getBloc(),
      act: (bloc) => bloc..add(const DonationsEvent.restorePurchases()),
      expect: () => const [
        DonationsState.loading(),
        DonationsState.restoreCompleted(error: false),
      ],
    );

    blocTest<DonationsBloc, DonationsState>(
      'fails',
      build: () => getBloc(restoreSucceeds: false),
      act: (bloc) => bloc..add(const DonationsEvent.restorePurchases()),
      expect: () => const [
        DonationsState.loading(),
        DonationsState.restoreCompleted(error: true),
        DonationsState.initial(packages: packages, isInitialized: true, noInternetConnection: false, canMakePurchases: true),
      ],
    );
  });

  group('purchase', () {
    DonationsBloc getBloc({bool purchaseSucceeds = true}) {
      final networkService = MockNetworkService();
      final purchaseService = MockPurchaseService();
      final telemetryService = MockTelemetryService();
      when(networkService.isInternetAvailable()).thenAnswer((_) => Future.value(true));
      when(purchaseService.isPlatformSupported()).thenAnswer((_) => Future.value(true));
      when(purchaseService.isInitialized).thenReturn(true);
      when(purchaseService.init()).thenAnswer((_) => Future.value(true));
      when(purchaseService.canMakePurchases()).thenAnswer((_) => Future.value(true));
      when(purchaseService.getInAppPurchases()).thenAnswer((_) => Future.value(packages));
      when(purchaseService.purchase(packages.first.identifier, packages.first.offeringIdentifier)).thenAnswer((_) => Future.value(purchaseSucceeds));
      return DonationsBloc(purchaseService, networkService, telemetryService);
    }

    blocTest<DonationsBloc, DonationsState>(
      'invalid identifier',
      build: () => getBloc(),
      act: (bloc) => bloc..add(const DonationsEvent.purchase(identifier: '', offeringIdentifier: '')),
      errors: () => [isA<Exception>()],
      expect: () => const [
        DonationsState.loading(),
      ],
    );

    blocTest<DonationsBloc, DonationsState>(
      'invalid offering identifier',
      build: () => getBloc(),
      act: (bloc) => bloc..add(DonationsEvent.purchase(identifier: packages.first.identifier, offeringIdentifier: '')),
      errors: () => [isA<Exception>()],
      expect: () => const [
        DonationsState.loading(),
      ],
    );

    blocTest<DonationsBloc, DonationsState>(
      'succeed',
      build: () => getBloc(),
      act: (bloc) => bloc..add(DonationsEvent.purchase(identifier: packages.first.identifier, offeringIdentifier: packages.first.offeringIdentifier)),
      expect: () => const [
        DonationsState.loading(),
        DonationsState.purchaseCompleted(error: false),
      ],
    );

    blocTest<DonationsBloc, DonationsState>(
      'succeeds',
      build: () => getBloc(purchaseSucceeds: false),
      act: (bloc) => bloc..add(DonationsEvent.purchase(identifier: packages.first.identifier, offeringIdentifier: packages.first.offeringIdentifier)),
      expect: () => const [
        DonationsState.loading(),
        DonationsState.purchaseCompleted(error: true),
        DonationsState.initial(packages: packages, isInitialized: true, noInternetConnection: false, canMakePurchases: true),
      ],
    );
  });
}
