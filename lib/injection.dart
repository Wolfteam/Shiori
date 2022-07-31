import 'package:get_it/get_it.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/services/calculator_service.dart';
import 'package:shiori/domain/services/changelog_provider.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/device_info_service.dart';
import 'package:shiori/domain/services/game_code_service.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/locale_service.dart';
import 'package:shiori/domain/services/logging_service.dart';
import 'package:shiori/domain/services/network_service.dart';
import 'package:shiori/domain/services/notification_service.dart';
import 'package:shiori/domain/services/purchase_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/settings_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';
import 'package:shiori/infrastructure/infrastructure.dart';

final GetIt getIt = GetIt.instance;

class Injection {
  static CalculatorAscMaterialsSessionFormBloc get calculatorAscMaterialsSessionFormBloc {
    return CalculatorAscMaterialsSessionFormBloc();
  }

  static ChangelogBloc get changelogBloc {
    final changelogProvider = getIt<ChangelogProvider>();
    return ChangelogBloc(changelogProvider);
  }

  static ElementsBloc get elementsBloc {
    final genshinService = getIt<GenshinService>();
    return ElementsBloc(genshinService);
  }

  static GameCodesBloc get gameCodesBloc {
    final dataService = getIt<DataService>();
    final telemetryService = getIt<TelemetryService>();
    final gameCodeService = getIt<GameCodeService>();
    final networkService = getIt<NetworkService>();
    return GameCodesBloc(dataService, telemetryService, gameCodeService, networkService);
  }

  static ItemQuantityFormBloc get itemQuantityFormBloc {
    return ItemQuantityFormBloc();
  }

  static NotificationTimerBloc get notificationTimerBloc {
    return NotificationTimerBloc();
  }

  static NotificationsBloc get notificationsBloc {
    final dataService = getIt<DataService>();
    final notificationService = getIt<NotificationService>();
    final settingsService = getIt<SettingsService>();
    final telemetryService = getIt<TelemetryService>();
    return NotificationsBloc(dataService, notificationService, settingsService, telemetryService);
  }

  static CalculatorAscMaterialsSessionsBloc get calculatorAscMaterialsSessionsBloc {
    final dataService = getIt<DataService>();
    final telemetryService = getIt<TelemetryService>();
    return CalculatorAscMaterialsSessionsBloc(dataService, telemetryService);
  }

  static TierListBloc get tierListBloc {
    final genshinService = getIt<GenshinService>();
    final dataService = getIt<DataService>();
    final telemetryService = getIt<TelemetryService>();
    final loggingService = getIt<LoggingService>();
    return TierListBloc(genshinService, dataService, telemetryService, loggingService);
  }

  static TierListFormBloc get tierListFormBloc {
    return TierListFormBloc();
  }

  static UrlPageBloc get urlPageBloc {
    final networkService = getIt<NetworkService>();
    final telemetryService = getIt<TelemetryService>();
    final deviceInfoService = getIt<DeviceInfoService>();
    final settingsService = getIt<SettingsService>();
    return UrlPageBloc(networkService, telemetryService, deviceInfoService, settingsService);
  }

  static CalculatorAscMaterialsItemUpdateQuantityBloc get calculatorAscMaterialsItemUpdateQuantityBloc {
    final dataService = getIt<DataService>();
    final telemetryService = getIt<TelemetryService>();
    return CalculatorAscMaterialsItemUpdateQuantityBloc(dataService, telemetryService);
  }

  static MonstersBloc get monstersBloc {
    final genshinService = getIt<GenshinService>();
    return MonstersBloc(genshinService);
  }

  static ArtifactBloc get artifactBloc {
    final genshinService = getIt<GenshinService>();
    final telemetryService = getIt<TelemetryService>();
    final resourceService = getIt<ResourceService>();
    return ArtifactBloc(genshinService, telemetryService, resourceService);
  }

  static MaterialsBloc get materialsBloc {
    final genshinService = getIt<GenshinService>();
    return MaterialsBloc(genshinService);
  }

  static MaterialBloc get materialBloc {
    final genshinService = getIt<GenshinService>();
    final telemetryService = getIt<TelemetryService>();
    final resourceService = getIt<ResourceService>();
    return MaterialBloc(genshinService, telemetryService, resourceService);
  }

  static CharacterBloc get characterBloc {
    final genshinService = getIt<GenshinService>();
    final telemetryService = getIt<TelemetryService>();
    final localeService = getIt<LocaleService>();
    final dataService = getIt<DataService>();
    final resourceService = getIt<ResourceService>();
    return CharacterBloc(genshinService, telemetryService, localeService, dataService, resourceService);
  }

  static InventoryBloc get inventoryBloc {
    final genshinService = getIt<GenshinService>();
    final telemetryService = getIt<TelemetryService>();
    final dataService = getIt<DataService>();
    return InventoryBloc(genshinService, dataService, telemetryService);
  }

  static WeaponBloc get weaponBloc {
    final genshinService = getIt<GenshinService>();
    final telemetryService = getIt<TelemetryService>();
    final dataService = getIt<DataService>();
    final resourceService = getIt<ResourceService>();
    return WeaponBloc(genshinService, telemetryService, dataService, resourceService);
  }

  static CustomBuildsBloc get customBuildsBloc {
    final dataService = getIt<DataService>();
    return CustomBuildsBloc(dataService);
  }

  static DonationsBloc get donationsBloc {
    final purchaseService = getIt<PurchaseService>();
    final networkService = getIt<NetworkService>();
    final telemetryService = getIt<TelemetryService>();
    return DonationsBloc(purchaseService, networkService, telemetryService);
  }

  static BannerHistoryBloc get bannerHistoryBloc {
    final genshinService = getIt<GenshinService>();
    final telemetryService = getIt<TelemetryService>();
    return BannerHistoryBloc(genshinService, telemetryService);
  }

  static BannerHistoryItemBloc get bannerHistoryItemBloc {
    final genshinService = getIt<GenshinService>();
    final telemetryService = getIt<TelemetryService>();
    return BannerHistoryItemBloc(genshinService, telemetryService);
  }

  static ItemReleaseHistoryBloc get itemReleaseHistoryBloc {
    final genshinService = getIt<GenshinService>();
    final telemetryService = getIt<TelemetryService>();
    return ItemReleaseHistoryBloc(genshinService, telemetryService);
  }

  static ChartTopsBloc get chartTopsBloc {
    final genshinService = getIt<GenshinService>();
    final telemetryService = getIt<TelemetryService>();
    return ChartTopsBloc(genshinService, telemetryService);
  }

  static ChartBirthdaysBloc get chartBirthdaysBloc {
    final genshinService = getIt<GenshinService>();
    return ChartBirthdaysBloc(genshinService);
  }

  static ChartElementsBloc get chartElementsBloc {
    final genshinService = getIt<GenshinService>();
    return ChartElementsBloc(genshinService);
  }

  static ChartAscensionStatsBloc get chartAscensionStatsBloc {
    final genshinService = getIt<GenshinService>();
    return ChartAscensionStatsBloc(genshinService);
  }

  static CharactersBirthdaysPerMonthBloc get charactersBirthdaysPerMonthBloc {
    final genshinService = getIt<GenshinService>();
    final telemetryService = getIt<TelemetryService>();
    return CharactersBirthdaysPerMonthBloc(genshinService, telemetryService);
  }

  static ItemsAscensionStatsBloc get itemsAscensionStatsBloc {
    final genshinService = getIt<GenshinService>();
    return ItemsAscensionStatsBloc(genshinService);
  }

  static ChartRegionsBloc get chartRegionsBloc {
    final genshinService = getIt<GenshinService>();
    return ChartRegionsBloc(genshinService);
  }

  static CharactersPerRegionBloc get charactersPerRegionBloc {
    final genshinService = getIt<GenshinService>();
    return CharactersPerRegionBloc(genshinService);
  }

  static ChartGendersBloc get chartGendersBloc {
    final genshinService = getIt<GenshinService>();
    return ChartGendersBloc(genshinService);
  }

  static CharactersPerRegionGenderBloc get charactersPerRegionGenderBloc {
    final genshinService = getIt<GenshinService>();
    return CharactersPerRegionGenderBloc(genshinService);
  }

  static SplashBloc get splashBloc {
    final resourceService = getIt<ResourceService>();
    final settingsService = getIt<SettingsService>();
    final deviceInfoService = getIt<DeviceInfoService>();
    final localeService = getIt<LocaleService>();
    return SplashBloc(resourceService, settingsService, deviceInfoService, localeService);
  }

  //TODO: USE THIS PROP
  // static CalculatorAscMaterialsItemBloc get calculatorAscMaterialsItemBloc {
  //   final genshinService = getIt<GenshinService>();
  //   final calculatorService = getIt<CalculatorService>();
  //   return CalculatorAscMaterialsItemBloc(genshinService, calculatorService);
  // }

  static CalculatorAscMaterialsBloc getCalculatorAscMaterialsBloc(CalculatorAscMaterialsSessionsBloc parentBloc) {
    final genshinService = getIt<GenshinService>();
    final telemetryService = getIt<TelemetryService>();
    final calculatorService = getIt<CalculatorService>();
    final dataService = getIt<DataService>();
    final resourceService = getIt<ResourceService>();
    return CalculatorAscMaterialsBloc(genshinService, telemetryService, calculatorService, dataService, resourceService, parentBloc);
  }

  static NotificationBloc getNotificationBloc(NotificationsBloc bloc) {
    final dataService = getIt<DataService>();
    final notificationService = getIt<NotificationService>();
    final genshinService = getIt<GenshinService>();
    final localeService = getIt<LocaleService>();
    final loggingService = getIt<LoggingService>();
    final telemetryService = getIt<TelemetryService>();
    final settingsService = getIt<SettingsService>();
    final resourceService = getIt<ResourceService>();
    return NotificationBloc(
      dataService,
      notificationService,
      genshinService,
      localeService,
      loggingService,
      telemetryService,
      settingsService,
      resourceService,
      bloc,
    );
  }

  static CalculatorAscMaterialsOrderBloc getCalculatorAscMaterialsOrderBloc(CalculatorAscMaterialsBloc bloc) {
    final dataService = getIt<DataService>();
    return CalculatorAscMaterialsOrderBloc(dataService, bloc);
  }

  static CalculatorAscMaterialsSessionsOrderBloc getCalculatorAscMaterialsSessionsOrderBloc(CalculatorAscMaterialsSessionsBloc bloc) {
    final dataService = getIt<DataService>();
    return CalculatorAscMaterialsSessionsOrderBloc(dataService, bloc);
  }

  static CustomBuildBloc getCustomBuildBloc(CustomBuildsBloc bloc) {
    final genshinService = getIt<GenshinService>();
    final dataService = getIt<DataService>();
    final telemetryService = getIt<TelemetryService>();
    final loggingService = getIt<LoggingService>();
    final resourceService = getIt<ResourceService>();
    return CustomBuildBloc(genshinService, dataService, telemetryService, loggingService, resourceService, bloc);
  }

  static Future<void> init() async {
    final networkService = NetworkServiceImpl();
    networkService.init();
    getIt.registerSingleton<NetworkService>(networkService);

    final deviceInfoService = DeviceInfoServiceImpl();
    getIt.registerSingleton<DeviceInfoService>(deviceInfoService);
    await deviceInfoService.init();

    final telemetryService = TelemetryServiceImpl(deviceInfoService);
    getIt.registerSingleton<TelemetryService>(telemetryService);
    await telemetryService.initTelemetry();

    final loggingService = LoggingServiceImpl(getIt<TelemetryService>(), deviceInfoService);

    getIt.registerSingleton<LoggingService>(loggingService);
    final settingsService = SettingsServiceImpl(loggingService);
    await settingsService.init();
    getIt.registerSingleton<SettingsService>(settingsService);

    final resourcesService = ResourceServiceImpl(loggingService, settingsService, networkService);
    await resourcesService.init();
    getIt.registerSingleton<ResourceService>(resourcesService);

    getIt.registerSingleton<LocaleService>(LocaleServiceImpl(getIt<SettingsService>()));
    getIt.registerSingleton<GenshinService>(GenshinServiceImpl(getIt<ResourceService>(), getIt<LocaleService>()));
    getIt.registerSingleton<CalculatorService>(CalculatorServiceImpl(getIt<GenshinService>(), getIt<ResourceService>()));

    final dataService = DataServiceImpl(getIt<GenshinService>(), getIt<CalculatorService>(), getIt<ResourceService>());
    await dataService.init();
    getIt.registerSingleton<DataService>(dataService);

    getIt.registerSingleton<GameCodeService>(GameCodeServiceImpl(getIt<LoggingService>(), getIt<GenshinService>()));

    final notificationService = NotificationServiceImpl(loggingService);
    await notificationService.init();
    getIt.registerSingleton<NotificationService>(notificationService);

    final changelogProvider = ChangelogProviderImpl(loggingService, networkService);
    getIt.registerSingleton<ChangelogProvider>(changelogProvider);

    final purchaseService = PurchaseServiceImpl(loggingService);
    await purchaseService.init();
    getIt.registerSingleton<PurchaseService>(purchaseService);
  }
}
