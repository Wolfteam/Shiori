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
    'aquila-favonia',
    'lost-prayer-to-the-sacred-winds',
    'primordial-jade-winged-spear',
    'skyward-atlas',
    'skyward-blade',
    'skyward-harp',
    'skyward-pride',
    'skyward-spine',
    'wolfs-gravestone',
  ];

  static const commonFourStarWeaponKeys = [
    'dragons-bane',
    'eye-of-perception',
    'favonius-codex',
    'favonius-greatsword',
    'favonius-lance',
    'favonius-sword',
    'favonius-warbow',
    'lions-roar',
    'rainslasher',
    'rust',
    'sacrificial-bow',
    'sacrificial-fragments',
    'sacrificial-greatsword',
    'sacrificial-sword',
    'the-bell',
    'the-flute',
    'the-stringless',
    'the-widsith',
  ];

  static const commonThreeStarWeaponKeys = [
    'black-tassel',
    'bloodtainted-greatsword',
    'cool-steel',
    'debate-club',
    'emerald-orb',
    'ferrous-shadow',
    'harbinger-of-dawn',
    'magic-guide',
    'raven-bow',
    'sharpshooters-oath',
    'skyrider-sword',
    'slingshot',
    'thrilling-tales-of-dragon-slayers',
  ];

  static List<String> commonWeaponKeys =
      commonFiveStarWeaponKeys + commonFourStarWeaponKeys + commonThreeStarWeaponKeys + commonFiveStarCharacterKeys;
}
