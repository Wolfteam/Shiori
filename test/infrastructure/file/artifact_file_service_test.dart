import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';

import '../../common.dart';
import 'common_file.dart';

void main() {
  group('Get artifacts for card', () {
    for (final lang in AppLanguageType.values) {
      test('language = ${lang.name}', () async {
        final service = await getArtifactFileService(lang);
        final artifacts = service.getArtifactsForCard();
        checkKeys(artifacts.map((e) => e.key).toList());
        for (final artifact in artifacts) {
          checkKey(artifact.key);
          checkAsset(artifact.image);
          expect(artifact.name, allOf([isNotEmpty, isNotNull]), reason: 'Should not be empty (property=name, key=${artifact.key})');
          expect(artifact.rarity, allOf([greaterThanOrEqualTo(3), lessThanOrEqualTo(5)]), reason: 'Should be greater than expected (property=rarity, key=${artifact.key})');
          expect(artifact.bonus, isNotEmpty, reason: 'Should not be empty (property=bonus, key=${artifact.key})');
          for (final bonus in artifact.bonus) {
            expect(bonus.bonus, allOf([isNotEmpty, isNotNull]), reason: 'Should not be empty (property=bonus, key=${artifact.key})');
            if (artifact.bonus.length == 2) {
              expect(bonus.pieces, inInclusiveRange(1, 4), reason: 'Should be within expected range (property=pieces, key=${artifact.key})');
            } else {
              expect(bonus.pieces == 1, isTrue, reason: 'Should be true (property=pieces == 1, key=${artifact.key})');
            }
          }
        }
      });
    }

    test('no resources have been downloaded', () async {
      final service = await getArtifactFileService(AppLanguageType.english, noResourcesHaveBeenDownloaded: true);
      final artifacts = service.getArtifactsForCard();
      expect(artifacts.isEmpty, isTrue, reason: 'Should be true');
    });
  });

  test('Get artifact', () async {
    final service = await getArtifactFileService(AppLanguageType.english);
    final artifacts = service.getArtifactsForCard();
    for (final artifact in artifacts) {
      final detail = service.getArtifact(artifact.key);
      checkKey(detail.key);
      checkAsset(service.resources.getArtifactImagePath(detail.image));
      expect(detail.minRarity, inInclusiveRange(1, 4), reason: 'Should be within expected range (property=minRarity)');
      expect(detail.maxRarity, inInclusiveRange(3, 5), reason: 'Should be within expected range (property=maxRarity)');
    }
  });
}
