import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/file/file_infrastructure.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/infrastructure/file/file_infrastructure.dart';

import '../../common.dart';
import '../../mocks.mocks.dart';

Future<TranslationFileService> getTranslationService(ResourceService resourceService, AppLanguageType lang) async {
  final translationService = TranslationFileServiceImpl();
  await translationService.initTranslations(lang, resourceService.getJsonFilePath(AppJsonFileType.translations, language: lang));
  return translationService;
}

Future<ArtifactFileService> getArtifactFileService(AppLanguageType lang) async {
  final resourceService = getResourceService(MockSettingsService());
  final translationService = await getTranslationService(resourceService, lang);
  final service = ArtifactFileServiceImpl(resourceService, translationService);
  await service.init(resourceService.getJsonFilePath(AppJsonFileType.artifacts));
  return service;
}

Future<MaterialFileService> getMaterialFileService(AppLanguageType lang) async {
  final resourceService = getResourceService(MockSettingsService());
  final translationService = await getTranslationService(resourceService, lang);
  final service = MaterialFileServiceImpl(resourceService, translationService);
  await service.init(resourceService.getJsonFilePath(AppJsonFileType.materials));
  return service;
}

Future<WeaponFileService> getWeaponFileService(AppLanguageType lang) async {
  final resourceService = getResourceService(MockSettingsService());
  final translationService = await getTranslationService(resourceService, lang);
  final materialService = await getMaterialFileService(lang);
  final service = WeaponFileServiceImpl(resourceService, materialService, translationService);
  await service.init(resourceService.getJsonFilePath(AppJsonFileType.weapons));
  return service;
}

Future<MonsterFileService> getMonsterFileService(AppLanguageType lang) async {
  final resourceService = getResourceService(MockSettingsService());
  final translationService = await getTranslationService(resourceService, lang);
  final service = MonsterFileServiceImpl(resourceService, translationService);
  await service.init(resourceService.getJsonFilePath(AppJsonFileType.monsters));
  return service;
}

Future<ElementFileService> getElementFileService(AppLanguageType lang) async {
  final resourceService = getResourceService(MockSettingsService());
  final translationService = await getTranslationService(resourceService, lang);
  final service = ElementFileServiceImpl(translationService);
  await service.init(resourceService.getJsonFilePath(AppJsonFileType.elements));
  return service;
}

Future<CharacterFileService> getCharacterFileService(AppLanguageType lang) async {
  final resourceService = getResourceService(MockSettingsService());
  final translationService = await getTranslationService(resourceService, lang);
  final localeService = getLocaleService(lang);
  final artifactService = await getArtifactFileService(lang);
  final materialService = await getMaterialFileService(lang);
  final weaponService = await getWeaponFileService(lang);
  final service = CharacterFileServiceImpl(resourceService, localeService, artifactService, materialService, weaponService, translationService);
  await service.init(resourceService.getJsonFilePath(AppJsonFileType.characters));
  return service;
}

Future<BannerHistoryFileService> getBannerHistoryFileService(AppLanguageType lang) async {
  final resourceService = getResourceService(MockSettingsService());
  final characterFileService = await getCharacterFileService(lang);
  final weaponFileService = await getWeaponFileService(lang);
  final service = BannerHistoryFileServiceImpl(resourceService, characterFileService, weaponFileService);
  await service.init(resourceService.getJsonFilePath(AppJsonFileType.bannerHistory));
  return service;
}
