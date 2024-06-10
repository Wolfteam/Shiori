import 'package:flutter_test/flutter_test.dart';
import 'package:shiori/domain/enums/enums.dart';

import '../../common.dart';
import 'common_file.dart';

void main() {
  test('Get debuffs', () async {
    for (final lang in AppLanguageType.values) {
      final service = await getElementFileService(lang);
      final debuffs = service.getElementDebuffs();
      expect(debuffs.length, equals(4));
      for (final debuff in debuffs) {
        expect(debuff.name, allOf([isNotNull, isNotEmpty]));
        expect(debuff.effect, allOf([isNotNull, isNotEmpty]));
        checkAsset(debuff.image);
      }
    }
  });

  test('Get reactions', () async {
    for (final lang in AppLanguageType.values) {
      final service = await getElementFileService(lang);
      final reactions = service.getElementReactions();
      expect(reactions.length, equals(17));
      for (final reaction in reactions) {
        expect(reaction.name, allOf([isNotNull, isNotEmpty]));
        expect(reaction.effect, allOf([isNotNull, isNotEmpty]));
        expect(reaction.principal, isNotEmpty);
        expect(reaction.secondary, isNotEmpty);

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
      expect(resonances.length, equals(8));
      for (final resonance in resonances) {
        expect(resonance.name, allOf([isNotNull, isNotEmpty]));
        expect(resonance.effect, allOf([isNotNull, isNotEmpty]));

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
    expect(debuffs.isEmpty, isTrue);
    expect(reactions.isEmpty, isTrue);
    expect(resonances.isEmpty, isTrue);
  });
}
