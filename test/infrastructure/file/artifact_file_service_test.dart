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
          checkKey(artifact.key, ownerKey: artifact.key);
          checkAsset(artifact.image, ownerKey: artifact.key);
          expect(
            artifact.name,
            allOf([isNotEmpty, isNotNull]),
            reason: 'Artifact name is empty or malformed (key=${artifact.key}, lang=${lang.name})',
          );
          expect(
            artifact.rarity,
            allOf([greaterThanOrEqualTo(3), lessThanOrEqualTo(5)]),
            reason: 'Artifact rarity must be 3–5 stars, got ${artifact.rarity} (key=${artifact.key})',
          );
          expect(artifact.bonus, isNotEmpty, reason: 'Artifact has no set bonuses defined (key=${artifact.key})');
          for (final bonus in artifact.bonus) {
            expect(
              bonus.bonus,
              allOf([isNotEmpty, isNotNull]),
              reason: 'Artifact set-bonus text is empty or malformed (key=${artifact.key}, lang=${lang.name})',
            );
            if (artifact.bonus.length == 2) {
              expect(
                bonus.pieces,
                inInclusiveRange(1, 4),
                reason: 'Two-tier artifact set-bonus piece count must be 1–4, got ${bonus.pieces} '
                    '(key=${artifact.key})',
              );
            } else {
              expect(
                bonus.pieces == 1,
                isTrue,
                reason: 'Single-tier artifact set-bonus must require 1 piece, got ${bonus.pieces} '
                    '(key=${artifact.key})',
              );
            }
          }
        }
      });
    }

    test('no resources have been downloaded', () async {
      final service = await getArtifactFileService(AppLanguageType.english, noResourcesHaveBeenDownloaded: true);
      final artifacts = service.getArtifactsForCard();
      expect(
        artifacts.isEmpty,
        isTrue,
        reason: 'With no resources downloaded, artifacts for card must be empty, got ${artifacts.length}',
      );
    });
  });

  test('Get artifact', () async {
    final service = await getArtifactFileService(AppLanguageType.english);
    final artifacts = service.getArtifactsForCard();
    for (final artifact in artifacts) {
      final detail = service.getArtifact(artifact.key);
      checkKey(detail.key, ownerKey: detail.key);
      checkAsset(service.resources.getArtifactImagePath(detail.image), ownerKey: detail.key);
      expect(
        detail.minRarity,
        inInclusiveRange(1, 4),
        reason: 'Artifact min rarity must be 1–4 stars, got ${detail.minRarity} (key=${detail.key})',
      );
      expect(
        detail.maxRarity,
        inInclusiveRange(3, 5),
        reason: 'Artifact max rarity must be 3–5 stars, got ${detail.maxRarity} (key=${detail.key})',
      );
    }
  });
}
