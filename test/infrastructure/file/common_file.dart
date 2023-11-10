import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/file/file_infrastructure.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/file/file_infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

Future<TranslationFileService> getTranslationService(
  ResourceService resourceService,
  AppLanguageType lang, {
  bool noResourcesHaveBeenDownloaded = false,
}) async {
  final translationService = TranslationFileServiceImpl();
  await translationService.initTranslations(
    lang,
    resourceService.getJsonFilePath(AppJsonFileType.translations, language: lang),
    noResourcesHaveBeenDownloaded: noResourcesHaveBeenDownloaded,
  );
  return translationService;
}

Future<ArtifactFileService> getArtifactFileService(AppLanguageType lang, {bool noResourcesHaveBeenDownloaded = false}) async {
  final resourceService = getResourceService(MockSettingsService());
  final translationService = await getTranslationService(resourceService, lang, noResourcesHaveBeenDownloaded: noResourcesHaveBeenDownloaded);
  final service = ArtifactFileServiceImpl(resourceService, translationService);
  await service.init(resourceService.getJsonFilePath(AppJsonFileType.artifacts), noResourcesHaveBeenDownloaded: noResourcesHaveBeenDownloaded);
  return service;
}

Future<MaterialFileService> getMaterialFileService(AppLanguageType lang, {bool noResourcesHaveBeenDownloaded = false}) async {
  final resourceService = getResourceService(MockSettingsService());
  final translationService = await getTranslationService(resourceService, lang, noResourcesHaveBeenDownloaded: noResourcesHaveBeenDownloaded);
  final service = MaterialFileServiceImpl(resourceService, translationService);
  await service.init(resourceService.getJsonFilePath(AppJsonFileType.materials), noResourcesHaveBeenDownloaded: noResourcesHaveBeenDownloaded);
  return service;
}

Future<WeaponFileService> getWeaponFileService(AppLanguageType lang, {bool noResourcesHaveBeenDownloaded = false}) async {
  final resourceService = getResourceService(MockSettingsService());
  final translationService = await getTranslationService(resourceService, lang, noResourcesHaveBeenDownloaded: noResourcesHaveBeenDownloaded);
  final materialService = await getMaterialFileService(lang);
  final service = WeaponFileServiceImpl(resourceService, materialService, translationService);
  await service.init(resourceService.getJsonFilePath(AppJsonFileType.weapons), noResourcesHaveBeenDownloaded: noResourcesHaveBeenDownloaded);
  return service;
}

Future<MonsterFileService> getMonsterFileService(AppLanguageType lang, {bool noResourcesHaveBeenDownloaded = false}) async {
  final resourceService = getResourceService(MockSettingsService());
  final translationService = await getTranslationService(resourceService, lang, noResourcesHaveBeenDownloaded: noResourcesHaveBeenDownloaded);
  final service = MonsterFileServiceImpl(resourceService, translationService);
  await service.init(resourceService.getJsonFilePath(AppJsonFileType.monsters), noResourcesHaveBeenDownloaded: noResourcesHaveBeenDownloaded);
  return service;
}

Future<ElementFileService> getElementFileService(AppLanguageType lang, {bool noResourcesHaveBeenDownloaded = false}) async {
  final resourceService = getResourceService(MockSettingsService());
  final translationService = await getTranslationService(resourceService, lang, noResourcesHaveBeenDownloaded: noResourcesHaveBeenDownloaded);
  final service = ElementFileServiceImpl(translationService);
  await service.init(resourceService.getJsonFilePath(AppJsonFileType.elements), noResourcesHaveBeenDownloaded: noResourcesHaveBeenDownloaded);
  return service;
}

Future<CharacterFileService> getCharacterFileService(AppLanguageType lang, {bool noResourcesHaveBeenDownloaded = false}) async {
  final resourceService = getResourceService(MockSettingsService());
  final translationService = await getTranslationService(resourceService, lang, noResourcesHaveBeenDownloaded: noResourcesHaveBeenDownloaded);
  final localeService = getLocaleService(lang);
  final artifactService = await getArtifactFileService(lang);
  final materialService = await getMaterialFileService(lang);
  final weaponService = await getWeaponFileService(lang);
  final service = CharacterFileServiceImpl(resourceService, localeService, artifactService, materialService, weaponService, translationService);
  await service.init(resourceService.getJsonFilePath(AppJsonFileType.characters), noResourcesHaveBeenDownloaded: noResourcesHaveBeenDownloaded);
  return service;
}

Future<BannerHistoryFileService> getBannerHistoryFileService(AppLanguageType lang, {bool noResourcesHaveBeenDownloaded = false}) async {
  final resourceService = getResourceService(MockSettingsService());
  final characterFileService = await getCharacterFileService(lang);
  final weaponFileService = await getWeaponFileService(lang);
  final service = BannerHistoryFileServiceImpl(resourceService, characterFileService, weaponFileService);
  await service.init(resourceService.getJsonFilePath(AppJsonFileType.bannerHistory), noResourcesHaveBeenDownloaded: noResourcesHaveBeenDownloaded);
  return service;
}
