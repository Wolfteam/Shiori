import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';

import '../../common.dart';
import 'common_file.dart';

void main() {
  group('Get monsters for card', () {
    for (final lang in AppLanguageType.values) {
      test('language = ${lang.name}', () async {
        final service = await getMonsterFileService(lang);
        final monsters = service.getAllMonstersForCard();
        checkKeys(monsters.map((e) => e.key).toList());
        for (final monster in monsters) {
          checkKey(monster.key);
          checkAsset(monster.image);
          expect(monster.name, allOf([isNotEmpty, isNotNull]));
        }
      });
    }

    test('no resources have been downloaded', () async {
      final service = await getMonsterFileService(AppLanguageType.english, noResourcesHaveBeenDownloaded: true);
      final monsters = service.getAllMonstersForCard();
      expect(monsters.isEmpty, isTrue);
    });
  });

  test('Get monster', () async {
    final service = await getMonsterFileService(AppLanguageType.english);
    final materialFileService = await getMaterialFileService(AppLanguageType.english);
    final artifactFileService = await getArtifactFileService(AppLanguageType.english);
    final monsters = service.getAllMonstersForCard();
    for (final monster in monsters) {
      final detail = service.getMonster(monster.key);
      checkKey(detail.key);
      checkAsset(service.resources.getMonsterImagePath(detail.image));

      for (final drop in detail.drops) {
        switch (drop.type) {
          case MonsterDropType.material:
            expect(() => materialFileService.getMaterial(drop.key), returnsNormally);
          case MonsterDropType.artifact:
            expect(() => artifactFileService.getArtifact(drop.key), returnsNormally);
        }
      }
    }
  });
}
