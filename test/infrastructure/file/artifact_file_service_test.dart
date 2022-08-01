import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';

import '../../common.dart';
import 'common_file.dart';

void main() {
  test('Get artifacts for card', () async {
    for (final lang in AppLanguageType.values) {
      final service = await getArtifactFileService(lang);
      final artifacts = service.getArtifactsForCard();
      checkKeys(artifacts.map((e) => e.key).toList());
      for (final artifact in artifacts) {
        checkKey(artifact.key);
        checkAsset(artifact.image);
        expect(artifact.name, allOf([isNotEmpty, isNotNull]));
        expect(artifact.rarity, allOf([greaterThanOrEqualTo(3), lessThanOrEqualTo(5)]));
        expect(artifact.bonus, isNotEmpty);
        for (final bonus in artifact.bonus) {
          expect(bonus.bonus, allOf([isNotEmpty, isNotNull]));
          if (artifact.bonus.length == 2) {
            expect(bonus.pieces, isIn([2, 4]));
          } else {
            expect(bonus.pieces == 1, isTrue);
          }
        }
      }
    }
  });

  test('Get artifact', () async {
    final service = await getArtifactFileService(AppLanguageType.english);
    final artifacts = service.getArtifactsForCard();
    for (final artifact in artifacts) {
      final detail = service.getArtifact(artifact.key);
      checkKey(detail.key);
      checkAsset(service.resources.getArtifactImagePath(detail.image));
      expect(detail.minRarity, inInclusiveRange(2, 4));
      expect(detail.maxRarity, inInclusiveRange(3, 5));
    }
  });
}
