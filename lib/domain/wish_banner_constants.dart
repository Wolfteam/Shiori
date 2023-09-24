import 'package:intl/intl.dart';

class WishBannerConstants {
  static const int maxObtainableRarity = 5;
  static const int minObtainableRarity = 3;

  static final dateFormat = DateFormat('yyyy-MM-dd');

  static const commonFiveStarCharacterKeys = [
    'qiqi',
    'jean',
    'tighnari',
    'keqing',
    'mona',
    'dehya',
    'diluc',
  ];

  static const fourStarStandardBannerCharacterExclusiveKeys = ['lisa', 'amber', 'kaeya'];

  static const commonFiveStarWeaponKeys = [
    'amos-bow',
    'skyward-harp',
    'lost-prayer-to-the-sacred-winds',
    'skyward-atlas',
    'skyward-pride',
    'wolfs-gravestone',
    'primordial-jade-winged-spear',
    'skyward-spine',
    'aquila-favonia',
    'skyward-blade',
  ];

  static const commonFourStarWeaponKeys = [
    'favonius-warbow',
    'rust',
    'sacrificial-bow',
    'the-stringless',
    'eye-of-perception',
    'favonius-codex',
    'sacrificial-fragments',
    'the-widsith',
    'favonius-greatsword',
    'rainslasher',
    'sacrificial-greatsword',
    'the-bell',
    'dragons-bane',
    'favonius-lance',
    'favonius-sword',
    'lions-roar',
    'sacrificial-sword',
    'the-flute',
  ];

  static const commonThreeStarWeaponKeys = [
    'raven-bow',
    'sharpshooters-oath',
    'slingshot',
    'emerald-orb',
    'magic-guide',
    'thrilling-tales-of-dragon-slayers',
    'bloodtainted-greatsword',
    'debate-club',
    'ferrous-shadow',
    'black-tassel',
    'cool-steel',
    'harbinger-of-dawn',
    'skyrider-sword',
  ];

  static List<String> commonWeaponKeys =
      commonFiveStarWeaponKeys + commonFourStarWeaponKeys + commonThreeStarWeaponKeys + commonFiveStarCharacterKeys;
}
