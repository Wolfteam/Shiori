import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';

import '../../common.dart';
import 'common_file.dart';

void main() {
  test('Get debuffs', () async {
    for (final lang in AppLanguageType.values) {
      final service = await getElementFileService(lang);
      final debuffs = service.getElementDebuffs();
      expect(
        debuffs.length,
        equals(4),
        reason: 'Expected exactly 4 element debuffs, got ${debuffs.length} (lang=${lang.name})',
      );
      for (final debuff in debuffs) {
        expect(
          debuff.name,
          allOf([isNotNull, isNotEmpty]),
          reason: 'Element debuff name is empty or malformed (name=${debuff.name}, lang=${lang.name})',
        );
        expect(
          debuff.effect,
          allOf([isNotNull, isNotEmpty]),
          reason: 'Element debuff effect is empty or malformed (name=${debuff.name}, lang=${lang.name})',
        );
        checkAsset(debuff.image);
      }
    }
  });

  test('Get reactions', () async {
    for (final lang in AppLanguageType.values) {
      final service = await getElementFileService(lang);
      final reactions = service.getElementReactions();
      expect(
        reactions.length,
        equals(17),
        reason: 'Expected exactly 17 element reactions, got ${reactions.length} (lang=${lang.name})',
      );
      for (final reaction in reactions) {
        expect(
          reaction.name,
          allOf([isNotNull, isNotEmpty]),
          reason: 'Element reaction name is empty or malformed (name=${reaction.name}, lang=${lang.name})',
        );
        expect(
          reaction.effect,
          allOf([isNotNull, isNotEmpty]),
          reason: 'Element reaction effect is empty or malformed (name=${reaction.name}, lang=${lang.name})',
        );
        expect(
          reaction.principal,
          isNotEmpty,
          reason: 'Element reaction has no principal element images (name=${reaction.name}, lang=${lang.name})',
        );
        expect(
          reaction.secondary,
          isNotEmpty,
          reason: 'Element reaction has no secondary element images (name=${reaction.name}, lang=${lang.name})',
        );

        final imgs = reaction.principal + reaction.secondary;
        for (final img in imgs) {
          checkAsset(img);
        }
      }
    }
  });

  test('Get resonances', () async {
    for (final lang in AppLanguageType.values) {
      final service = await getElementFileService(lang);
      final resonances = service.getElementResonances();
      expect(
        resonances.length,
        equals(8),
        reason: 'Expected exactly 8 element resonances, got ${resonances.length} (lang=${lang.name})',
      );
      for (final resonance in resonances) {
        expect(
          resonance.name,
          allOf([isNotNull, isNotEmpty]),
          reason: 'Element resonance name is empty or malformed (name=${resonance.name}, lang=${lang.name})',
        );
        expect(
          resonance.effect,
          allOf([isNotNull, isNotEmpty]),
          reason: 'Element resonance effect is empty or malformed (name=${resonance.name}, lang=${lang.name})',
        );

        final imgs = resonance.principal + resonance.secondary;
        for (final img in imgs) {
          checkAsset(img);
        }
      }
    }
  });

  test('No resources have been downloaded', () async {
    final service = await getElementFileService(AppLanguageType.english, noResourcesHaveBeenDownloaded: true);
    final debuffs = service.getElementDebuffs();
    final reactions = service.getElementReactions();
    final resonances = service.getElementResonances();
    expect(
      debuffs.isEmpty,
      isTrue,
      reason: 'With no resources downloaded, element debuffs must be empty, got ${debuffs.length}',
    );
    expect(
      reactions.isEmpty,
      isTrue,
      reason: 'With no resources downloaded, element reactions must be empty, got ${reactions.length}',
    );
    expect(
      resonances.isEmpty,
      isTrue,
      reason: 'With no resources downloaded, element resonances must be empty, got ${resonances.length}',
    );
  });
}
