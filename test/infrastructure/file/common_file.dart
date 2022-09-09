import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/file/file_infrastructure.dart';
import 'package:shiori/infrastructure/file/file_infrastructure.dart';

import '../../common.dart';

Future<TranslationFileService> getTranslationService(AppLanguageType lang) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final translationService = TranslationFileServiceImpl();
  final path = Assets.getTranslationPath(lang);
  await translationService.initTranslations(lang, path);
  return translationService;
}

Future<ArtifactFileService> getArtifactFileService(AppLanguageType lang) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final translationService = await getTranslationService(lang);
  final service = ArtifactFileServiceImpl(translationService);
  await service.init(Assets.artifactsDbPath);
  return service;
}

Future<MaterialFileService> getMaterialFileService(AppLanguageType lang) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final translationService = await getTranslationService(lang);
  final service = MaterialFileServiceImpl(translationService);
  await service.init(Assets.materialsDbPath);
  return service;
}

Future<WeaponFileService> getWeaponFileService(AppLanguageType lang) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final translationService = await getTranslationService(lang);
  final materialService = await getMaterialFileService(lang);
  final service = WeaponFileServiceImpl(materialService, translationService);
  await service.init(Assets.weaponsDbPath);
  return service;
}

Future<MonsterFileService> getMonsterFileService(AppLanguageType lang) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final translationService = await getTranslationService(lang);
  final service = MonsterFileServiceImpl(translationService);
  await service.init(Assets.monstersDbPath);
  return service;
}

Future<ElementFileService> getElementFileService(AppLanguageType lang) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final translationService = await getTranslationService(lang);
  final service = ElementFileServiceImpl(translationService);
  await service.init(Assets.elementsDbPath);
  return service;
}

Future<CharacterFileService> getCharacterFileService(AppLanguageType lang) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final translationService = await getTranslationService(lang);
  final localeService = getLocaleService(lang);
  final artifactService = await getArtifactFileService(lang);
  final materialService = await getMaterialFileService(lang);
  final weaponService = await getWeaponFileService(lang);
  final service = CharacterFileServiceImpl(localeService, artifactService, materialService, weaponService, translationService);
  await service.init(Assets.charactersDbPath);
  return service;
}

Future<BannerHistoryFileService> getBannerHistoryFileService(AppLanguageType lang) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final characterFileService = await getCharacterFileService(lang);
  final weaponFileService = await getWeaponFileService(lang);
  final service = BannerHistoryFileServiceImpl(characterFileService, weaponFileService);
  await service.init(Assets.bannerHistoryDbPath);
  return service;
}
