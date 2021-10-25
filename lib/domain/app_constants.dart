import 'package:darq/darq.dart';
import 'package:shiori/domain/enums/enums.dart';

import 'models/models.dart';

const githubPage = 'https://github.com/Wolfteam/Shiori';

//This order matches the one in the game, and the numbers represent each image
const artifactOrder = [4, 2, 5, 1, 3];

const languagesMap = {
  AppLanguageType.english: LanguageModel('en', 'US'),
  AppLanguageType.spanish: LanguageModel('es', 'ES'),
  AppLanguageType.russian: LanguageModel('ru', 'RU'),
  AppLanguageType.simplifiedChinese: LanguageModel('zh', 'CN'),
  AppLanguageType.portuguese: LanguageModel('pt', 'PT'),
  AppLanguageType.italian: LanguageModel('it', 'IT'),
  AppLanguageType.japanese: LanguageModel('ja', 'JA'),
  AppLanguageType.vietnamese: LanguageModel('vi', 'VI'),
  AppLanguageType.indonesian: LanguageModel('id', 'ID'),
  AppLanguageType.deutsch: LanguageModel('de', 'DE'),
  AppLanguageType.french: LanguageModel('fr', 'FR'),
  AppLanguageType.traditionalChinese: LanguageModel('zh', 'TW'),
  AppLanguageType.korean: LanguageModel('ko', 'KO'),
  AppLanguageType.thai: LanguageModel('th', 'th'),
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

// According to this page, the server reset happens at 4 am
// https://game8.co/games/Genshin-Impact/archives/301599
const serverResetHour = 4;

const dailyCheckInResetDuration = Duration(hours: 24);

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

const weaponExp5Stars = [
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

const weaponExp4Stars = [
  ItemExperienceModel.forWeapons(1, 400, 0),
  ItemExperienceModel.forWeapons(2, 625, 400),
  ItemExperienceModel.forWeapons(3, 900, 1025),
  ItemExperienceModel.forWeapons(4, 1200, 1925),
  ItemExperienceModel.forWeapons(5, 1550, 3125),
  ItemExperienceModel.forWeapons(6, 1950, 4675),
  ItemExperienceModel.forWeapons(7, 2350, 6625),
  ItemExperienceModel.forWeapons(8, 2800, 8975),
  ItemExperienceModel.forWeapons(9, 3300, 11775),
  ItemExperienceModel.forWeapons(10, 3800, 15075),
  ItemExperienceModel.forWeapons(11, 4350, 18875),
  ItemExperienceModel.forWeapons(12, 4925, 23225),
  ItemExperienceModel.forWeapons(13, 5525, 28150),
  ItemExperienceModel.forWeapons(14, 6150, 33675),
  ItemExperienceModel.forWeapons(15, 6800, 39825),
  ItemExperienceModel.forWeapons(16, 7500, 46625),
  ItemExperienceModel.forWeapons(17, 8200, 54125),
  ItemExperienceModel.forWeapons(18, 8950, 62325),
  ItemExperienceModel.forWeapons(19, 9725, 71275),
  ItemExperienceModel.forWeapons(20, 10500, 81000),
  ItemExperienceModel.forWeapons(21, 11900, 91500),
  ItemExperienceModel.forWeapons(22, 12775, 103400),
  ItemExperienceModel.forWeapons(23, 13700, 116175),
  ItemExperienceModel.forWeapons(24, 14650, 129875),
  ItemExperienceModel.forWeapons(25, 15625, 144525),
  ItemExperienceModel.forWeapons(26, 16625, 160150),
  ItemExperienceModel.forWeapons(27, 17650, 176775),
  ItemExperienceModel.forWeapons(28, 18700, 194425),
  ItemExperienceModel.forWeapons(29, 19775, 213125),
  ItemExperienceModel.forWeapons(30, 20900, 232900),
  ItemExperienceModel.forWeapons(31, 22025, 253800),
  ItemExperienceModel.forWeapons(32, 23200, 275825),
  ItemExperienceModel.forWeapons(33, 24375, 299025),
  ItemExperienceModel.forWeapons(34, 25600, 323400),
  ItemExperienceModel.forWeapons(35, 26825, 349000),
  ItemExperienceModel.forWeapons(36, 28100, 375825),
  ItemExperienceModel.forWeapons(37, 29400, 403925),
  ItemExperienceModel.forWeapons(38, 30725, 433325),
  ItemExperienceModel.forWeapons(39, 32075, 464050),
  ItemExperienceModel.forWeapons(40, 33425, 496125),
  ItemExperienceModel.forWeapons(41, 36575, 529550),
  ItemExperienceModel.forWeapons(42, 38075, 566125),
  ItemExperienceModel.forWeapons(43, 39600, 604200),
  ItemExperienceModel.forWeapons(44, 41150, 643800),
  ItemExperienceModel.forWeapons(45, 42725, 684950),
  ItemExperienceModel.forWeapons(46, 44325, 727675),
  ItemExperienceModel.forWeapons(47, 45950, 772000),
  ItemExperienceModel.forWeapons(48, 47600, 817950),
  ItemExperienceModel.forWeapons(49, 49300, 865550),
  ItemExperienceModel.forWeapons(50, 51000, 914850),
  ItemExperienceModel.forWeapons(51, 55375, 965850),
  ItemExperienceModel.forWeapons(52, 57225, 1021225),
  ItemExperienceModel.forWeapons(53, 59100, 1078450),
  ItemExperienceModel.forWeapons(54, 61025, 1137550),
  ItemExperienceModel.forWeapons(55, 62950, 1198575),
  ItemExperienceModel.forWeapons(56, 64925, 1261525),
  ItemExperienceModel.forWeapons(57, 66900, 1326450),
  ItemExperienceModel.forWeapons(58, 68925, 1393350),
  ItemExperienceModel.forWeapons(59, 70975, 1462275),
  ItemExperienceModel.forWeapons(60, 73050, 1533250),
  ItemExperienceModel.forWeapons(61, 78900, 1606300),
  ItemExperienceModel.forWeapons(62, 81125, 1685200),
  ItemExperienceModel.forWeapons(63, 83400, 1766325),
  ItemExperienceModel.forWeapons(64, 85700, 1849725),
  ItemExperienceModel.forWeapons(65, 88025, 1935425),
  ItemExperienceModel.forWeapons(66, 90375, 2023450),
  ItemExperienceModel.forWeapons(67, 92750, 2113825),
  ItemExperienceModel.forWeapons(68, 95150, 2206575),
  ItemExperienceModel.forWeapons(69, 97575, 2301725),
  ItemExperienceModel.forWeapons(70, 100050, 2399300),
  ItemExperienceModel.forWeapons(71, 107675, 2499350),
  ItemExperienceModel.forWeapons(72, 110325, 2607025),
  ItemExperienceModel.forWeapons(73, 113000, 2717350),
  ItemExperienceModel.forWeapons(74, 115700, 2830350),
  ItemExperienceModel.forWeapons(75, 118425, 2946050),
  ItemExperienceModel.forWeapons(76, 121200, 3064475),
  ItemExperienceModel.forWeapons(77, 124000, 3185675),
  ItemExperienceModel.forWeapons(78, 126825, 3309675),
  ItemExperienceModel.forWeapons(79, 129675, 3436500),
  ItemExperienceModel.forWeapons(80, 132575, 3566175),
  ItemExperienceModel.forWeapons(81, 156475, 3698750),
  ItemExperienceModel.forWeapons(82, 175875, 3855225),
  ItemExperienceModel.forWeapons(83, 197600, 4031100),
  ItemExperienceModel.forWeapons(84, 221975, 4228700),
  ItemExperienceModel.forWeapons(85, 249300, 4450675),
  ItemExperienceModel.forWeapons(86, 279950, 4699975),
  ItemExperienceModel.forWeapons(87, 314250, 4979925),
  ItemExperienceModel.forWeapons(88, 352700, 5294175),
  ItemExperienceModel.forWeapons(89, 395775, 5646875),
  ItemExperienceModel.forWeapons(90, -1, 6042650)
];

const weaponExp3Stars = [
  ItemExperienceModel.forWeapons(1, 275, 0),
  ItemExperienceModel.forWeapons(2, 425, 275),
  ItemExperienceModel.forWeapons(3, 600, 700),
  ItemExperienceModel.forWeapons(4, 800, 1300),
  ItemExperienceModel.forWeapons(5, 1025, 2100),
  ItemExperienceModel.forWeapons(6, 1275, 3125),
  ItemExperienceModel.forWeapons(7, 1550, 4400),
  ItemExperienceModel.forWeapons(8, 1850, 5950),
  ItemExperienceModel.forWeapons(9, 2175, 7800),
  ItemExperienceModel.forWeapons(10, 2500, 9975),
  ItemExperienceModel.forWeapons(11, 2875, 12475),
  ItemExperienceModel.forWeapons(12, 3250, 15350),
  ItemExperienceModel.forWeapons(13, 3650, 18600),
  ItemExperienceModel.forWeapons(14, 4050, 22250),
  ItemExperienceModel.forWeapons(15, 4500, 26300),
  ItemExperienceModel.forWeapons(16, 4950, 30800),
  ItemExperienceModel.forWeapons(17, 5400, 35750),
  ItemExperienceModel.forWeapons(18, 5900, 41150),
  ItemExperienceModel.forWeapons(19, 6425, 47050),
  ItemExperienceModel.forWeapons(20, 6925, 53475),
  ItemExperienceModel.forWeapons(21, 7850, 60400),
  ItemExperienceModel.forWeapons(22, 8425, 68250),
  ItemExperienceModel.forWeapons(23, 9050, 76675),
  ItemExperienceModel.forWeapons(24, 9675, 85725),
  ItemExperienceModel.forWeapons(25, 10325, 95400),
  ItemExperienceModel.forWeapons(26, 10975, 105725),
  ItemExperienceModel.forWeapons(27, 11650, 116700),
  ItemExperienceModel.forWeapons(28, 12350, 128350),
  ItemExperienceModel.forWeapons(29, 13050, 140700),
  ItemExperienceModel.forWeapons(30, 13800, 153750),
  ItemExperienceModel.forWeapons(31, 14525, 167550),
  ItemExperienceModel.forWeapons(32, 15300, 182075),
  ItemExperienceModel.forWeapons(33, 16100, 197375),
  ItemExperienceModel.forWeapons(34, 16900, 213475),
  ItemExperienceModel.forWeapons(35, 17700, 230375),
  ItemExperienceModel.forWeapons(36, 18550, 248075),
  ItemExperienceModel.forWeapons(37, 19400, 266625),
  ItemExperienceModel.forWeapons(38, 20275, 286025),
  ItemExperienceModel.forWeapons(39, 21175, 306300),
  ItemExperienceModel.forWeapons(40, 22050, 327475),
  ItemExperienceModel.forWeapons(41, 24150, 349525),
  ItemExperienceModel.forWeapons(42, 25125, 373675),
  ItemExperienceModel.forWeapons(43, 26125, 398800),
  ItemExperienceModel.forWeapons(44, 27150, 424925),
  ItemExperienceModel.forWeapons(45, 28200, 452075),
  ItemExperienceModel.forWeapons(46, 29250, 480275),
  ItemExperienceModel.forWeapons(47, 30325, 509525),
  ItemExperienceModel.forWeapons(48, 31425, 539850),
  ItemExperienceModel.forWeapons(49, 32550, 571275),
  ItemExperienceModel.forWeapons(50, 33650, 603825),
  ItemExperienceModel.forWeapons(51, 36550, 637475),
  ItemExperienceModel.forWeapons(52, 37775, 674025),
  ItemExperienceModel.forWeapons(53, 39000, 711800),
  ItemExperienceModel.forWeapons(54, 40275, 750800),
  ItemExperienceModel.forWeapons(55, 41550, 791075),
  ItemExperienceModel.forWeapons(56, 42850, 832625),
  ItemExperienceModel.forWeapons(57, 44150, 875475),
  ItemExperienceModel.forWeapons(58, 45500, 919625),
  ItemExperienceModel.forWeapons(59, 46850, 965125),
  ItemExperienceModel.forWeapons(60, 48225, 1011975),
  ItemExperienceModel.forWeapons(61, 52075, 1060200),
  ItemExperienceModel.forWeapons(62, 53550, 1112275),
  ItemExperienceModel.forWeapons(63, 55050, 1165825),
  ItemExperienceModel.forWeapons(64, 56550, 1220875),
  ItemExperienceModel.forWeapons(65, 58100, 1277425),
  ItemExperienceModel.forWeapons(66, 59650, 1335525),
  ItemExperienceModel.forWeapons(67, 61225, 1395175),
  ItemExperienceModel.forWeapons(68, 62800, 1456400),
  ItemExperienceModel.forWeapons(69, 64400, 1519200),
  ItemExperienceModel.forWeapons(70, 66025, 1583600),
  ItemExperienceModel.forWeapons(71, 71075, 1649625),
  ItemExperienceModel.forWeapons(72, 72825, 1720700),
  ItemExperienceModel.forWeapons(73, 74575, 1793525),
  ItemExperienceModel.forWeapons(74, 76350, 1868100),
  ItemExperienceModel.forWeapons(75, 78150, 1944450),
  ItemExperienceModel.forWeapons(76, 80000, 2022600),
  ItemExperienceModel.forWeapons(77, 81850, 2102600),
  ItemExperienceModel.forWeapons(78, 83700, 2184450),
  ItemExperienceModel.forWeapons(79, 85575, 2268150),
  ItemExperienceModel.forWeapons(80, 87500, 2353725),
  ItemExperienceModel.forWeapons(81, 103275, 2441225),
  ItemExperienceModel.forWeapons(82, 116075, 2544500),
  ItemExperienceModel.forWeapons(83, 130425, 2660575),
  ItemExperienceModel.forWeapons(84, 146500, 2791000),
  ItemExperienceModel.forWeapons(85, 164550, 2937500),
  ItemExperienceModel.forWeapons(86, 184775, 3102050),
  ItemExperienceModel.forWeapons(87, 207400, 3286825),
  ItemExperienceModel.forWeapons(88, 232775, 3494225),
  ItemExperienceModel.forWeapons(89, 261200, 3727000),
  ItemExperienceModel.forWeapons(90, -1, 3988200)
];

const weaponExp2Stars = [
  ItemExperienceModel.forWeapons(1, 175, 0),
  ItemExperienceModel.forWeapons(2, 275, 175),
  ItemExperienceModel.forWeapons(3, 400, 450),
  ItemExperienceModel.forWeapons(4, 550, 850),
  ItemExperienceModel.forWeapons(5, 700, 1400),
  ItemExperienceModel.forWeapons(6, 875, 2100),
  ItemExperienceModel.forWeapons(7, 1050, 2975),
  ItemExperienceModel.forWeapons(8, 1250, 4025),
  ItemExperienceModel.forWeapons(9, 1475, 5275),
  ItemExperienceModel.forWeapons(10, 1700, 6750),
  ItemExperienceModel.forWeapons(11, 1950, 8450),
  ItemExperienceModel.forWeapons(12, 2225, 10400),
  ItemExperienceModel.forWeapons(13, 2475, 12625),
  ItemExperienceModel.forWeapons(14, 2775, 15100),
  ItemExperienceModel.forWeapons(15, 3050, 17875),
  ItemExperienceModel.forWeapons(16, 3375, 20925),
  ItemExperienceModel.forWeapons(17, 3700, 24300),
  ItemExperienceModel.forWeapons(18, 4025, 28000),
  ItemExperienceModel.forWeapons(19, 4375, 32025),
  ItemExperienceModel.forWeapons(20, 4725, 36400),
  ItemExperienceModel.forWeapons(21, 5350, 41125),
  ItemExperienceModel.forWeapons(22, 5750, 46475),
  ItemExperienceModel.forWeapons(23, 6175, 52225),
  ItemExperienceModel.forWeapons(24, 6600, 58400),
  ItemExperienceModel.forWeapons(25, 7025, 65000),
  ItemExperienceModel.forWeapons(26, 7475, 72025),
  ItemExperienceModel.forWeapons(27, 7950, 79500),
  ItemExperienceModel.forWeapons(28, 8425, 87450),
  ItemExperienceModel.forWeapons(29, 8900, 95875),
  ItemExperienceModel.forWeapons(30, 9400, 104775),
  ItemExperienceModel.forWeapons(31, 9900, 114175),
  ItemExperienceModel.forWeapons(32, 10450, 124075),
  ItemExperienceModel.forWeapons(33, 10975, 134525),
  ItemExperienceModel.forWeapons(34, 11525, 145500),
  ItemExperienceModel.forWeapons(35, 12075, 157025),
  ItemExperienceModel.forWeapons(36, 12650, 169100),
  ItemExperienceModel.forWeapons(37, 13225, 181750),
  ItemExperienceModel.forWeapons(38, 13825, 194975),
  ItemExperienceModel.forWeapons(39, 14425, 208800),
  ItemExperienceModel.forWeapons(40, 15050, 223225),
  ItemExperienceModel.forWeapons(41, 16450, 238275),
  ItemExperienceModel.forWeapons(42, 17125, 254725),
  ItemExperienceModel.forWeapons(43, 17825, 271850),
  ItemExperienceModel.forWeapons(44, 18525, 289675),
  ItemExperienceModel.forWeapons(45, 19225, 308200),
  ItemExperienceModel.forWeapons(46, 19950, 327425),
  ItemExperienceModel.forWeapons(47, 20675, 347375),
  ItemExperienceModel.forWeapons(48, 21425, 368050),
  ItemExperienceModel.forWeapons(49, 22175, 389475),
  ItemExperienceModel.forWeapons(50, 22950, 411650),
  ItemExperienceModel.forWeapons(51, 24925, 434600),
  ItemExperienceModel.forWeapons(52, 25750, 459525),
  ItemExperienceModel.forWeapons(53, 26600, 485275),
  ItemExperienceModel.forWeapons(54, 27450, 511875),
  ItemExperienceModel.forWeapons(55, 28325, 539325),
  ItemExperienceModel.forWeapons(56, 29225, 567650),
  ItemExperienceModel.forWeapons(57, 30100, 596875),
  ItemExperienceModel.forWeapons(58, 31025, 626975),
  ItemExperienceModel.forWeapons(59, 31950, 658000),
  ItemExperienceModel.forWeapons(60, 32875, 689950),
  ItemExperienceModel.forWeapons(61, 35500, 722825),
  ItemExperienceModel.forWeapons(62, 36500, 758325),
  ItemExperienceModel.forWeapons(63, 37525, 794825),
  ItemExperienceModel.forWeapons(64, 38575, 832350),
  ItemExperienceModel.forWeapons(65, 39600, 870925),
  ItemExperienceModel.forWeapons(66, 40675, 910525),
  ItemExperienceModel.forWeapons(67, 41750, 951200),
  ItemExperienceModel.forWeapons(68, 42825, 992950),
  ItemExperienceModel.forWeapons(69, 43900, 1035775),
  ItemExperienceModel.forWeapons(70, -1, 1079675)
];

const weaponExp1Star = [
  ItemExperienceModel.forWeapons(1, 125, 0),
  ItemExperienceModel.forWeapons(2, 200, 125),
  ItemExperienceModel.forWeapons(3, 275, 325),
  ItemExperienceModel.forWeapons(4, 350, 600),
  ItemExperienceModel.forWeapons(5, 475, 950),
  ItemExperienceModel.forWeapons(6, 575, 1425),
  ItemExperienceModel.forWeapons(7, 700, 2000),
  ItemExperienceModel.forWeapons(8, 850, 2700),
  ItemExperienceModel.forWeapons(9, 1000, 3550),
  ItemExperienceModel.forWeapons(10, 1150, 4550),
  ItemExperienceModel.forWeapons(11, 1300, 5700),
  ItemExperienceModel.forWeapons(12, 1475, 7000),
  ItemExperienceModel.forWeapons(13, 1650, 8475),
  ItemExperienceModel.forWeapons(14, 1850, 10125),
  ItemExperienceModel.forWeapons(15, 2050, 11975),
  ItemExperienceModel.forWeapons(16, 2250, 14025),
  ItemExperienceModel.forWeapons(17, 2450, 16275),
  ItemExperienceModel.forWeapons(18, 2675, 18725),
  ItemExperienceModel.forWeapons(19, 2925, 21400),
  ItemExperienceModel.forWeapons(20, 3150, 24325),
  ItemExperienceModel.forWeapons(21, 3575, 27475),
  ItemExperienceModel.forWeapons(22, 3825, 31050),
  ItemExperienceModel.forWeapons(23, 4100, 34875),
  ItemExperienceModel.forWeapons(24, 4400, 38975),
  ItemExperienceModel.forWeapons(25, 4700, 43375),
  ItemExperienceModel.forWeapons(26, 5000, 48075),
  ItemExperienceModel.forWeapons(27, 5300, 53075),
  ItemExperienceModel.forWeapons(28, 5600, 58375),
  ItemExperienceModel.forWeapons(29, 5925, 63975),
  ItemExperienceModel.forWeapons(30, 6275, 69900),
  ItemExperienceModel.forWeapons(31, 6600, 76175),
  ItemExperienceModel.forWeapons(32, 6950, 82775),
  ItemExperienceModel.forWeapons(33, 7325, 89725),
  ItemExperienceModel.forWeapons(34, 7675, 97050),
  ItemExperienceModel.forWeapons(35, 8050, 104725),
  ItemExperienceModel.forWeapons(36, 8425, 112775),
  ItemExperienceModel.forWeapons(37, 8825, 121200),
  ItemExperienceModel.forWeapons(38, 9225, 130025),
  ItemExperienceModel.forWeapons(39, 9625, 139250),
  ItemExperienceModel.forWeapons(40, 10025, 148875),
  ItemExperienceModel.forWeapons(41, 10975, 158900),
  ItemExperienceModel.forWeapons(42, 11425, 169875),
  ItemExperienceModel.forWeapons(43, 11875, 181300),
  ItemExperienceModel.forWeapons(44, 12350, 193175),
  ItemExperienceModel.forWeapons(45, 12825, 205525),
  ItemExperienceModel.forWeapons(46, 13300, 218350),
  ItemExperienceModel.forWeapons(47, 13775, 231650),
  ItemExperienceModel.forWeapons(48, 14275, 245425),
  ItemExperienceModel.forWeapons(49, 14800, 259700),
  ItemExperienceModel.forWeapons(50, 15300, 274500),
  ItemExperienceModel.forWeapons(51, 16625, 289800),
  ItemExperienceModel.forWeapons(52, 17175, 306425),
  ItemExperienceModel.forWeapons(53, 17725, 323600),
  ItemExperienceModel.forWeapons(54, 18300, 341325),
  ItemExperienceModel.forWeapons(55, 18875, 359625),
  ItemExperienceModel.forWeapons(56, 19475, 378500),
  ItemExperienceModel.forWeapons(57, 20075, 397975),
  ItemExperienceModel.forWeapons(58, 20675, 418050),
  ItemExperienceModel.forWeapons(59, 21300, 438725),
  ItemExperienceModel.forWeapons(60, 21925, 460025),
  ItemExperienceModel.forWeapons(61, 23675, 481950),
  ItemExperienceModel.forWeapons(62, 24350, 505625),
  ItemExperienceModel.forWeapons(63, 25025, 529975),
  ItemExperienceModel.forWeapons(64, 25700, 555000),
  ItemExperienceModel.forWeapons(65, 26400, 580700),
  ItemExperienceModel.forWeapons(66, 27125, 607100),
  ItemExperienceModel.forWeapons(67, 27825, 634225),
  ItemExperienceModel.forWeapons(68, 28550, 662050),
  ItemExperienceModel.forWeapons(69, 29275, 690600),
  ItemExperienceModel.forWeapons(70, -1, 719875)
];

//Furnishing related
//This one represents the amount of realm currency you can gather per rank level
const realmTrustRank = {
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
const realmIncreasingRatio = {
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

double getItemTotalExp(int currentLevel, int desiredLevel, int rarity, bool forCharacters) {
  if (currentLevel > desiredLevel) {
    throw Exception('CurrentLevel = $currentLevel cannot be greater than DesiredLevel = $desiredLevel');
  }

  final items = <ItemExperienceModel>[];
  if (forCharacters) {
    items.addAll(characterExp);
  } else {
    switch (rarity) {
      case 5:
        items.addAll(weaponExp5Stars);
        break;
      case 4:
        items.addAll(weaponExp4Stars);
        break;
      case 3:
        items.addAll(weaponExp3Stars);
        break;
      case 2:
        items.addAll(weaponExp2Stars);
        break;
      case 1:
        items.addAll(weaponExp1Star);
        break;
      default:
        throw Exception('The provided rarity = $rarity');
    }
  }

  //here remember that the upper bound must not be included, that's why we use item.level < desiredLevel
  return items
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
    return expChar.orderBy((el) => el.position).thenBy((el) => el.level).toList() +
        expWeapon.orderBy((el) => el.position).thenBy((el) => el.level).toList() +
        common.orderBy((el) => el.position).thenBy((el) => el.level).toList() +
        weapon.orderBy((el) => el.position).thenBy((el) => el.level).toList() +
        talentsWithoutSiblings.orderBy((el) => el.position).thenBy((el) => el.level).toList() +
        stones.orderBy((el) => el.position).thenBy((el) => el.rarity).toList() +
        jewels.orderBy((el) => el.position).thenBy((el) => el.level).toList() +
        talentsWithSiblings.orderBy((el) => el.position).thenBy((el) => el.level).toList() +
        weaponPrimary.orderBy((el) => el.position).thenBy((el) => el.level).toList() +
        local.orderBy((el) => el.position).thenBy((el) => el.rarity).toList() +
        currency.orderBy((el) => el.position).thenBy((el) => el.rarity).toList() +
        ingredients.orderBy((el) => el.position).thenBy((el) => el.rarity).toList();
  }

  return expChar.orderByDescending((el) => el.position).thenByDescending((el) => el.level).toList() +
      expWeapon.orderByDescending((el) => el.position).thenByDescending((el) => el.level).toList() +
      common.orderByDescending((el) => el.position).thenByDescending((el) => el.level).toList() +
      weapon.orderByDescending((el) => el.position).thenByDescending((el) => el.level).toList() +
      talentsWithoutSiblings.orderByDescending((el) => el.position).thenByDescending((el) => el.level).toList() +
      stones.orderByDescending((el) => el.position).thenByDescending((el) => el.rarity).toList() +
      jewels.orderByDescending((el) => el.position).thenByDescending((el) => el.level).toList() +
      talentsWithSiblings.orderByDescending((el) => el.position).thenByDescending((el) => el.level).toList() +
      weaponPrimary.orderByDescending((el) => el.position).thenByDescending((el) => el.level).toList() +
      currency.orderByDescending((el) => el.position).thenByDescending((el) => el.rarity).toList() +
      local.orderByDescending((el) => el.position).thenByDescending((el) => el.rarity).toList() +
      ingredients.orderByDescending((el) => el.position).thenByDescending((el) => el.rarity).toList();
}

DateTime getNotificationDateForResin(int currentResinValue) {
  final now = DateTime.now();
  return now.add(getResinDuration(currentResinValue));
}

Duration getResinDuration(int currentResinValue) {
  final diff = maxResinValue - currentResinValue;
  return Duration(minutes: diff * resinRefillsEach);
}

int getCurrentResin(int initialResinValue, DateTime completesAt) {
  final now = DateTime.now();
  final createdAt = completesAt.subtract(getResinDuration(initialResinValue));
  final elapsedMinutes = (now.difference(createdAt).inMinutes).abs();
  final currentResinValue = (elapsedMinutes / resinRefillsEach).floor() + initialResinValue;
  return currentResinValue > maxResinValue ? maxResinValue : currentResinValue;
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
  final maxRealmCurrency = getRealmMaxCurrency(currentTrustRank);
  final ratioPerHour = getRealmIncreaseRatio(currentRealmRank);
  final remaining = maxRealmCurrency - currentRealmCurrency;
  //each 60 minutes you produce an x ratio per hour
  final minutesLeft = remaining * 60 ~/ ratioPerHour;

  return Duration(minutes: minutesLeft);
}

int getCurrentRealmCurrency(int initialRealmCurrency, int currentTrustRank, RealmRankType currentRealmRank, DateTime completesAt) {
  final now = DateTime.now();
  final maxRealmCurrency = getRealmMaxCurrency(currentTrustRank);
  final ratioPerHour = getRealmIncreaseRatio(currentRealmRank);
  final createdAt = completesAt.subtract(getRealmCurrencyDuration(initialRealmCurrency, currentTrustRank, currentRealmRank));
  final elapsedMinutes = (now.difference(createdAt).inMinutes).abs();
  final currentRealmCurrency = (elapsedMinutes * ratioPerHour / 60).floor() + initialRealmCurrency;
  return currentRealmCurrency > maxRealmCurrency ? maxRealmCurrency : currentRealmCurrency;
}

int getRealmMaxCurrency(int currentTrustRank) => realmTrustRank.entries.firstWhere((kvp) => kvp.key == currentTrustRank).value;

int getRealmIncreaseRatio(RealmRankType type) => realmIncreasingRatio.entries.firstWhere((kvp) => kvp.key == type).value;
