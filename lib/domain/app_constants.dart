import 'package:darq/darq.dart';
import 'package:genshindb/domain/enums/enums.dart';

import 'models/models.dart';

//This order matches the one in the game, and the numbers represent each image
const artifactOrder = [4, 2, 5, 1, 3];

const languagesMap = {
  AppLanguageType.english: LanguageModel('en', 'US'),
  AppLanguageType.spanish: LanguageModel('es', 'ES'),
  AppLanguageType.russian: LanguageModel('ru', 'RU'),
  AppLanguageType.simplifiedChinese: LanguageModel('zh', 'CN'),
  AppLanguageType.portuguese: LanguageModel('pt', 'PT'),
  AppLanguageType.italian: LanguageModel('it', 'IT'),
};

const int minSkillLevel = 1;
const int maxSkillLevel = 10;
const int minAscensionLevel = 1;
const int maxAscensionLevel = 6;
const int minItemLevel = 1;
const int maxItemLevel = 90;

const minResinValue = 0;
const maxResinValue = 160;
const resinRefillsEach = 8;

//key = ascension level
//value = item level
//Remember that you can be level 80 but that doesn't mean you have ascended to level 6
const itemAscensionLevelMap = {
  1: 20,
  2: 40,
  3: 50,
  4: 60,
  5: 70,
  6: 80,
};

//key = ascension level
//value = the possible skill upgrades level
const skillAscensionMap = {
  1: [1],
  2: [2],
  3: [3, 4],
  4: [5, 6],
  5: [7, 8],
  6: [9, 10]
};

const characterExp = [
  ItemExperienceModel.forCharacters(1, 1000, 0),
  ItemExperienceModel.forCharacters(2, 1325, 1000),
  ItemExperienceModel.forCharacters(3, 1700, 2325),
  ItemExperienceModel.forCharacters(4, 2150, 4025),
  ItemExperienceModel.forCharacters(5, 2625, 6175),
  ItemExperienceModel.forCharacters(6, 3150, 8800),
  ItemExperienceModel.forCharacters(7, 3725, 11950),
  ItemExperienceModel.forCharacters(8, 4350, 15675),
  ItemExperienceModel.forCharacters(9, 5000, 20025),
  ItemExperienceModel.forCharacters(10, 5700, 25025),
  ItemExperienceModel.forCharacters(11, 6450, 30725),
  ItemExperienceModel.forCharacters(12, 7225, 37175),
  ItemExperienceModel.forCharacters(13, 8050, 44400),
  ItemExperienceModel.forCharacters(14, 8925, 52450),
  ItemExperienceModel.forCharacters(15, 9825, 61375),
  ItemExperienceModel.forCharacters(16, 10750, 71200),
  ItemExperienceModel.forCharacters(17, 11725, 81950),
  ItemExperienceModel.forCharacters(18, 12725, 93675),
  ItemExperienceModel.forCharacters(19, 13775, 106400),
  ItemExperienceModel.forCharacters(20, 14875, 120175),
  ItemExperienceModel.forCharacters(21, 16800, 135050),
  ItemExperienceModel.forCharacters(22, 18000, 151850),
  ItemExperienceModel.forCharacters(23, 19250, 169850),
  ItemExperienceModel.forCharacters(24, 20550, 189100),
  ItemExperienceModel.forCharacters(25, 21875, 209650),
  ItemExperienceModel.forCharacters(26, 23250, 231525),
  ItemExperienceModel.forCharacters(27, 24650, 254775),
  ItemExperienceModel.forCharacters(28, 26100, 279425),
  ItemExperienceModel.forCharacters(29, 27575, 305525),
  ItemExperienceModel.forCharacters(30, 29100, 333100),
  ItemExperienceModel.forCharacters(31, 30650, 362200),
  ItemExperienceModel.forCharacters(32, 32250, 392850),
  ItemExperienceModel.forCharacters(33, 33875, 425100),
  ItemExperienceModel.forCharacters(34, 35550, 458975),
  ItemExperienceModel.forCharacters(35, 37250, 494525),
  ItemExperienceModel.forCharacters(36, 38975, 531775),
  ItemExperienceModel.forCharacters(37, 40750, 570750),
  ItemExperienceModel.forCharacters(38, 42575, 611500),
  ItemExperienceModel.forCharacters(39, 44425, 654075),
  ItemExperienceModel.forCharacters(40, 46300, 698500),
  ItemExperienceModel.forCharacters(41, 50625, 744800),
  ItemExperienceModel.forCharacters(42, 52700, 795425),
  ItemExperienceModel.forCharacters(43, 54775, 848125),
  ItemExperienceModel.forCharacters(44, 56900, 902900),
  ItemExperienceModel.forCharacters(45, 59075, 959800),
  ItemExperienceModel.forCharacters(46, 61275, 1018875),
  ItemExperienceModel.forCharacters(47, 63525, 1080150),
  ItemExperienceModel.forCharacters(48, 65800, 1143675),
  ItemExperienceModel.forCharacters(49, 68125, 1209475),
  ItemExperienceModel.forCharacters(50, 70475, 1277600),
  ItemExperienceModel.forCharacters(51, 76500, 1348075),
  ItemExperienceModel.forCharacters(52, 79050, 1424575),
  ItemExperienceModel.forCharacters(53, 81650, 1503625),
  ItemExperienceModel.forCharacters(54, 84275, 1585275),
  ItemExperienceModel.forCharacters(55, 86950, 1669550),
  ItemExperienceModel.forCharacters(56, 89650, 1756500),
  ItemExperienceModel.forCharacters(57, 92400, 1846150),
  ItemExperienceModel.forCharacters(58, 95175, 1938550),
  ItemExperienceModel.forCharacters(59, 98000, 2033725),
  ItemExperienceModel.forCharacters(60, 100875, 2131725),
  ItemExperienceModel.forCharacters(61, 108950, 2232600),
  ItemExperienceModel.forCharacters(62, 112050, 2341550),
  ItemExperienceModel.forCharacters(63, 115175, 2453600),
  ItemExperienceModel.forCharacters(64, 118325, 2568775),
  ItemExperienceModel.forCharacters(65, 121525, 2687100),
  ItemExperienceModel.forCharacters(66, 124775, 2808625),
  ItemExperienceModel.forCharacters(67, 128075, 2933400),
  ItemExperienceModel.forCharacters(68, 131400, 3061475),
  ItemExperienceModel.forCharacters(69, 134775, 3192875),
  ItemExperienceModel.forCharacters(70, 138175, 3327650),
  ItemExperienceModel.forCharacters(71, 148700, 3465825),
  ItemExperienceModel.forCharacters(72, 152375, 3614525),
  ItemExperienceModel.forCharacters(73, 156075, 3766900),
  ItemExperienceModel.forCharacters(74, 159825, 3922975),
  ItemExperienceModel.forCharacters(75, 163600, 4082800),
  ItemExperienceModel.forCharacters(76, 167425, 4246400),
  ItemExperienceModel.forCharacters(77, 171300, 4413825),
  ItemExperienceModel.forCharacters(78, 175225, 4585125),
  ItemExperienceModel.forCharacters(79, 179175, 4760350),
  ItemExperienceModel.forCharacters(80, 183175, 4939525),
  ItemExperienceModel.forCharacters(81, 216225, 5122700),
  ItemExperienceModel.forCharacters(82, 243025, 5338925),
  ItemExperienceModel.forCharacters(83, 273100, 5581950),
  ItemExperienceModel.forCharacters(84, 306800, 5855050),
  ItemExperienceModel.forCharacters(85, 344600, 6161850),
  ItemExperienceModel.forCharacters(86, 386950, 6506450),
  ItemExperienceModel.forCharacters(87, 434425, 6893400),
  ItemExperienceModel.forCharacters(88, 487625, 7327825),
  ItemExperienceModel.forCharacters(89, 547200, 7815450),
  ItemExperienceModel.forCharacters(90, -1, 8362650),
];

const weaponExp = [
  ItemExperienceModel.forWeapons(1, 600, 0),
  ItemExperienceModel.forWeapons(2, 950, 600),
  ItemExperienceModel.forWeapons(3, 1350, 1550),
  ItemExperienceModel.forWeapons(4, 1800, 2900),
  ItemExperienceModel.forWeapons(5, 2325, 4700),
  ItemExperienceModel.forWeapons(6, 2925, 7025),
  ItemExperienceModel.forWeapons(7, 3525, 9950),
  ItemExperienceModel.forWeapons(8, 4200, 13475),
  ItemExperienceModel.forWeapons(9, 4950, 17675),
  ItemExperienceModel.forWeapons(10, 5700, 22625),
  ItemExperienceModel.forWeapons(11, 6525, 28325),
  ItemExperienceModel.forWeapons(12, 7400, 34850),
  ItemExperienceModel.forWeapons(13, 8300, 42250),
  ItemExperienceModel.forWeapons(14, 9225, 50550),
  ItemExperienceModel.forWeapons(15, 10200, 59775),
  ItemExperienceModel.forWeapons(16, 11250, 69975),
  ItemExperienceModel.forWeapons(17, 12300, 81225),
  ItemExperienceModel.forWeapons(18, 13425, 93525),
  ItemExperienceModel.forWeapons(19, 14600, 106950),
  ItemExperienceModel.forWeapons(20, 15750, 121550),
  ItemExperienceModel.forWeapons(21, 17850, 137300),
  ItemExperienceModel.forWeapons(22, 19175, 155150),
  ItemExperienceModel.forWeapons(23, 20550, 174325),
  ItemExperienceModel.forWeapons(24, 21975, 194875),
  ItemExperienceModel.forWeapons(25, 23450, 216850),
  ItemExperienceModel.forWeapons(26, 24950, 240300),
  ItemExperienceModel.forWeapons(27, 26475, 265250),
  ItemExperienceModel.forWeapons(28, 28050, 291725),
  ItemExperienceModel.forWeapons(29, 29675, 319775),
  ItemExperienceModel.forWeapons(30, 31350, 349450),
  ItemExperienceModel.forWeapons(31, 33050, 380800),
  ItemExperienceModel.forWeapons(32, 34800, 413850),
  ItemExperienceModel.forWeapons(33, 36575, 448650),
  ItemExperienceModel.forWeapons(34, 38400, 485225),
  ItemExperienceModel.forWeapons(35, 40250, 523625),
  ItemExperienceModel.forWeapons(36, 42150, 563875),
  ItemExperienceModel.forWeapons(37, 44100, 606025),
  ItemExperienceModel.forWeapons(38, 46100, 650125),
  ItemExperienceModel.forWeapons(39, 48125, 696225),
  ItemExperienceModel.forWeapons(40, 50150, 744350),
  ItemExperienceModel.forWeapons(41, 54875, 794500),
  ItemExperienceModel.forWeapons(42, 57125, 849375),
  ItemExperienceModel.forWeapons(43, 59400, 906500),
  ItemExperienceModel.forWeapons(44, 61725, 965900),
  ItemExperienceModel.forWeapons(45, 64100, 1027625),
  ItemExperienceModel.forWeapons(46, 66500, 1091725),
  ItemExperienceModel.forWeapons(47, 68925, 1158225),
  ItemExperienceModel.forWeapons(48, 71400, 1227150),
  ItemExperienceModel.forWeapons(49, 73950, 1298550),
  ItemExperienceModel.forWeapons(50, 76500, 1372500),
  ItemExperienceModel.forWeapons(51, 83075, 1449000),
  ItemExperienceModel.forWeapons(52, 85850, 1532075),
  ItemExperienceModel.forWeapons(53, 88650, 1617925),
  ItemExperienceModel.forWeapons(54, 91550, 1706575),
  ItemExperienceModel.forWeapons(55, 94425, 1798125),
  ItemExperienceModel.forWeapons(56, 97400, 1892550),
  ItemExperienceModel.forWeapons(57, 100350, 1989950),
  ItemExperienceModel.forWeapons(58, 103400, 2090300),
  ItemExperienceModel.forWeapons(59, 106475, 2193700),
  ItemExperienceModel.forWeapons(60, 109575, 2300175),
  ItemExperienceModel.forWeapons(61, 118350, 2409750),
  ItemExperienceModel.forWeapons(62, 121700, 2528100),
  ItemExperienceModel.forWeapons(63, 125100, 2649800),
  ItemExperienceModel.forWeapons(64, 128550, 2774900),
  ItemExperienceModel.forWeapons(65, 132050, 2903450),
  ItemExperienceModel.forWeapons(66, 135575, 3035500),
  ItemExperienceModel.forWeapons(67, 139125, 3171075),
  ItemExperienceModel.forWeapons(68, 142725, 3310200),
  ItemExperienceModel.forWeapons(69, 146375, 3452925),
  ItemExperienceModel.forWeapons(70, 150075, 3599300),
  ItemExperienceModel.forWeapons(71, 161525, 3749375),
  ItemExperienceModel.forWeapons(72, 165500, 3910900),
  ItemExperienceModel.forWeapons(73, 169500, 4076400),
  ItemExperienceModel.forWeapons(74, 173550, 4245900),
  ItemExperienceModel.forWeapons(75, 177650, 4419450),
  ItemExperienceModel.forWeapons(76, 181800, 4597100),
  ItemExperienceModel.forWeapons(77, 186000, 4778900),
  ItemExperienceModel.forWeapons(78, 190250, 4964900),
  ItemExperienceModel.forWeapons(79, 194525, 5155150),
  ItemExperienceModel.forWeapons(80, 198875, 5349675),
  ItemExperienceModel.forWeapons(81, 234725, 5548550),
  ItemExperienceModel.forWeapons(82, 263825, 5783275),
  ItemExperienceModel.forWeapons(83, 296400, 6047100),
  ItemExperienceModel.forWeapons(84, 332975, 6343500),
  ItemExperienceModel.forWeapons(85, 373950, 6676475),
  ItemExperienceModel.forWeapons(86, 419925, 7050425),
  ItemExperienceModel.forWeapons(87, 471375, 7470350),
  ItemExperienceModel.forWeapons(88, 529050, 7941725),
  ItemExperienceModel.forWeapons(89, 593675, 8470775),
  ItemExperienceModel.forWeapons(90, -1, 9064450),
];

//Furnishing related
//This one represents the amount of realm currency you can gather per rank level
const trustRank = {
  1: 300,
  2: 600,
  3: 900,
  4: 1200,
  5: 1400,
  6: 1600,
  7: 1800,
  8: 2000,
  9: 2200,
  10: 2400,
};

//This one represents the ratio at which you gain realm currency
//E.g: At level 1 you gain 4 realm currency per hour
const increasingRatio = {
  RealmRankType.bareBones: 4,
  RealmRankType.humbleAbode: 8,
  RealmRankType.cozy: 12,
  RealmRankType.queenSize: 16,
  RealmRankType.elegant: 20,
  RealmRankType.exquisite: 22,
  RealmRankType.extraordinary: 24,
  RealmRankType.stately: 26,
  RealmRankType.luxury: 28,
  RealmRankType.fitForAKing: 30,
};

double getItemTotalExp(int currentLevel, int desiredLevel, bool forCharacters) {
  if (currentLevel > desiredLevel) {
    throw Exception('CurrentLevel = $currentLevel cannot be greater than DesiredLevel = $desiredLevel');
  }

  //here remember that the upper bound must not be included, that's why we use item.level < desiredLevel
  return (forCharacters ? characterExp : weaponExp)
      .where((item) => item.level >= currentLevel && item.level < desiredLevel)
      .map((item) => item.nextLevelExp)
      .fold(0, (previous, current) => previous + current);
}

List<MaterialCardModel> sortMaterialsByGrouping(List<MaterialCardModel> data, SortDirectionType sortDirectionType) {
  final expChar = data.where((el) => el.type == MaterialType.expCharacter);
  final expWeapon = data.where((el) => el.type == MaterialType.expWeapon);
  final common = data.where((el) => el.type == MaterialType.common);
  final weaponPrimary = data.where((el) => el.type == MaterialType.weaponPrimary);
  final weapon = data.where((el) => el.type == MaterialType.weapon);
  final stones = data.where((el) => el.type == MaterialType.elementalStone);
  final jewels = data.where((el) => el.type == MaterialType.jewels);
  final local = data.where((el) => el.type == MaterialType.local);
  final currency = data.where((el) => el.type == MaterialType.currency);
  final ingredients = data.where((el) => el.type == MaterialType.ingredient);
  final talents = data.where((el) => el.type == MaterialType.talents);
  final talentsWithSiblings = talents.where((el) => el.hasSiblings);
  final talentsWithoutSiblings = talents.where((el) => !el.hasSiblings);

  if (sortDirectionType == SortDirectionType.asc) {
    return jewels.orderBy((el) => el.key).thenBy((el) => el.level).toList() +
        expChar.orderBy((el) => el.key).thenBy((el) => el.level).toList() +
        expWeapon.orderBy((el) => el.key).thenBy((el) => el.level).toList() +
        weaponPrimary.orderBy((el) => el.key).thenBy((el) => el.level).toList() +
        weapon.orderBy((el) => el.key).thenBy((el) => el.level).toList() +
        talentsWithSiblings.orderBy((el) => el.key).thenBy((el) => el.level).toList() +
        talentsWithoutSiblings.orderBy((el) => el.key).thenBy((el) => el.level).toList() +
        common.orderBy((el) => el.key).thenBy((el) => el.level).toList() +
        stones.orderBy((el) => el.rarity).toList() +
        local.orderBy((el) => el.rarity).toList() +
        currency.orderBy((el) => el.rarity).toList() +
        ingredients.orderBy((el) => el.rarity).toList();
  }

  return jewels.orderByDescending((el) => el.key).thenByDescending((el) => el.level).toList() +
      expChar.orderByDescending((el) => el.key).thenByDescending((el) => el.level).toList() +
      expWeapon.orderByDescending((el) => el.key).thenByDescending((el) => el.level).toList() +
      weaponPrimary.orderByDescending((el) => el.key).thenByDescending((el) => el.level).toList() +
      weapon.orderByDescending((el) => el.key).thenByDescending((el) => el.level).toList() +
      talentsWithSiblings.orderByDescending((el) => el.key).thenByDescending((el) => el.level).toList() +
      talentsWithoutSiblings.orderByDescending((el) => el.key).thenByDescending((el) => el.level).toList() +
      common.orderByDescending((el) => el.key).thenByDescending((el) => el.level).toList() +
      stones.orderByDescending((el) => el.rarity).toList() +
      local.orderByDescending((el) => el.rarity).toList() +
      currency.orderByDescending((el) => el.rarity).toList() +
      ingredients.orderByDescending((el) => el.rarity).toList();
}

Duration getExpeditionDuration(ExpeditionTimeType type, bool withTimeReduction) {
  switch (type) {
    case ExpeditionTimeType.fourHours:
      return _getExpeditionDuration(4, withTimeReduction);
    case ExpeditionTimeType.eightHours:
      return _getExpeditionDuration(8, withTimeReduction);
    case ExpeditionTimeType.twelveHours:
      return _getExpeditionDuration(12, withTimeReduction);
    case ExpeditionTimeType.twentyHours:
      return _getExpeditionDuration(20, withTimeReduction);
    default:
      throw Exception('The provided expedition time type = $type is not valid');
  }
}

Duration getFurnitureDuration(FurnitureCraftingTimeType type) {
  switch (type) {
    case FurnitureCraftingTimeType.twelveHours:
      return const Duration(hours: 12);
    case FurnitureCraftingTimeType.fourteenHours:
      return const Duration(hours: 14);
    case FurnitureCraftingTimeType.sixteenHours:
      return const Duration(hours: 16);
    default:
      throw Exception('The provided furniture creation type = $type is not valid');
  }
}

Duration getArtifactFarmingCooldownDuration(ArtifactFarmingTimeType type) {
  switch (type) {
    case ArtifactFarmingTimeType.twelveHours:
      return const Duration(hours: 12);
    case ArtifactFarmingTimeType.twentyFourHours:
      return const Duration(hours: 24);
    default:
      throw Exception('The provided artifact farming time type = $type is not valid');
  }
}

Duration _getExpeditionDuration(int hours, bool withTimeReduction) {
  const reductionPercentage = 0.25;
  final totalMinutes = hours * 60;
  final int reducedMinutes = (withTimeReduction ? totalMinutes * reductionPercentage : 0).toInt();
  return Duration(minutes: totalMinutes - reducedMinutes);
}

Duration getRealmCurrencyDuration(int currentRealmCurrency, int currentTrustRank, RealmRankType currentRealmRank) {
  final maxRealmCurrency = getMaxRealmCurrency(currentTrustRank);
  final ratioPerHour = increasingRatio.entries.firstWhere((kvp) => kvp.key == currentRealmRank).value;
  final remaining = maxRealmCurrency - currentRealmCurrency;
  final minutesLeft = remaining * 60 ~/ ratioPerHour;

  return Duration(minutes: minutesLeft);
}

int getMaxRealmCurrency(int currentTrustRank) => trustRank.entries.firstWhere((kvp) => kvp.key == currentTrustRank).value;
