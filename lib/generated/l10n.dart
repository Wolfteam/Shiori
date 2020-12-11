// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `GenshinDb`
  String get appName {
    return Intl.message(
      'GenshinDb',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark {
    return Intl.message(
      'Dark',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light {
    return Intl.message(
      'Light',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `Spanish`
  String get spanish {
    return Intl.message(
      'Spanish',
      name: 'spanish',
      desc: '',
      args: [],
    );
  }

  /// `Bow`
  String get bow {
    return Intl.message(
      'Bow',
      name: 'bow',
      desc: '',
      args: [],
    );
  }

  /// `Claymore`
  String get claymore {
    return Intl.message(
      'Claymore',
      name: 'claymore',
      desc: '',
      args: [],
    );
  }

  /// `Sword`
  String get sword {
    return Intl.message(
      'Sword',
      name: 'sword',
      desc: '',
      args: [],
    );
  }

  /// `Polearm`
  String get polearm {
    return Intl.message(
      'Polearm',
      name: 'polearm',
      desc: '',
      args: [],
    );
  }

  /// `Catalyst`
  String get catalyst {
    return Intl.message(
      'Catalyst',
      name: 'catalyst',
      desc: '',
      args: [],
    );
  }

  /// `None`
  String get none {
    return Intl.message(
      'None',
      name: 'none',
      desc: '',
      args: [],
    );
  }

  /// `{value} ATK`
  String atk(Object value) {
    return Intl.message(
      '$value ATK',
      name: 'atk',
      desc: '',
      args: [value],
    );
  }

  /// `{value} ATK%`
  String atkPercentage(Object value) {
    return Intl.message(
      '$value ATK%',
      name: 'atkPercentage',
      desc: '',
      args: [value],
    );
  }

  /// `{value} DEF%`
  String defPercentage(Object value) {
    return Intl.message(
      '$value DEF%',
      name: 'defPercentage',
      desc: '',
      args: [value],
    );
  }

  /// `{value} CRIT ATK`
  String critAtk(Object value) {
    return Intl.message(
      '$value CRIT ATK',
      name: 'critAtk',
      desc: '',
      args: [value],
    );
  }

  /// `{value} CRIT Rate`
  String critRate(Object value) {
    return Intl.message(
      '$value CRIT Rate',
      name: 'critRate',
      desc: '',
      args: [value],
    );
  }

  /// `{value} CRIT Rate%`
  String critRatePercentage(Object value) {
    return Intl.message(
      '$value CRIT Rate%',
      name: 'critRatePercentage',
      desc: '',
      args: [value],
    );
  }

  /// `{value} CRIT DMG`
  String critDmgPercentage(Object value) {
    return Intl.message(
      '$value CRIT DMG',
      name: 'critDmgPercentage',
      desc: '',
      args: [value],
    );
  }

  /// `{value} Elementary Master`
  String elementaryMaster(Object value) {
    return Intl.message(
      '$value Elementary Master',
      name: 'elementaryMaster',
      desc: '',
      args: [value],
    );
  }

  /// `{value} HP%`
  String hpPercentage(Object value) {
    return Intl.message(
      '$value HP%',
      name: 'hpPercentage',
      desc: '',
      args: [value],
    );
  }

  /// `{value} PHYS DMG %`
  String physDmgPercentage(Object value) {
    return Intl.message(
      '$value PHYS DMG %',
      name: 'physDmgPercentage',
      desc: '',
      args: [value],
    );
  }

  /// `{value} PHYS DMG Bonus`
  String physDmgBonus(Object value) {
    return Intl.message(
      '$value PHYS DMG Bonus',
      name: 'physDmgBonus',
      desc: '',
      args: [value],
    );
  }

  /// `{value} Energy Recharge %`
  String energyRechargePercentage(Object value) {
    return Intl.message(
      '$value Energy Recharge %',
      name: 'energyRechargePercentage',
      desc: '',
      args: [value],
    );
  }

  /// `Gacha`
  String get gacha {
    return Intl.message(
      'Gacha',
      name: 'gacha',
      desc: '',
      args: [],
    );
  }

  /// `Crafting`
  String get crafting {
    return Intl.message(
      'Crafting',
      name: 'crafting',
      desc: '',
      args: [],
    );
  }

  /// `Starglitter Exchange`
  String get starglitterExchange {
    return Intl.message(
      'Starglitter Exchange',
      name: 'starglitterExchange',
      desc: '',
      args: [],
    );
  }

  /// `Chest`
  String get chest {
    return Intl.message(
      'Chest',
      name: 'chest',
      desc: '',
      args: [],
    );
  }

  /// `BP Bounty`
  String get bpBounty {
    return Intl.message(
      'BP Bounty',
      name: 'bpBounty',
      desc: '',
      args: [],
    );
  }

  /// `Monday`
  String get monday {
    return Intl.message(
      'Monday',
      name: 'monday',
      desc: '',
      args: [],
    );
  }

  /// `Tuesday`
  String get tuesday {
    return Intl.message(
      'Tuesday',
      name: 'tuesday',
      desc: '',
      args: [],
    );
  }

  /// `Wednesday`
  String get wednesday {
    return Intl.message(
      'Wednesday',
      name: 'wednesday',
      desc: '',
      args: [],
    );
  }

  /// `Thursday`
  String get thursday {
    return Intl.message(
      'Thursday',
      name: 'thursday',
      desc: '',
      args: [],
    );
  }

  /// `Friday`
  String get friday {
    return Intl.message(
      'Friday',
      name: 'friday',
      desc: '',
      args: [],
    );
  }

  /// `Saturday`
  String get saturday {
    return Intl.message(
      'Saturday',
      name: 'saturday',
      desc: '',
      args: [],
    );
  }

  /// `Sunday`
  String get sunday {
    return Intl.message(
      'Sunday',
      name: 'sunday',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Rarity`
  String get rarity {
    return Intl.message(
      'Rarity',
      name: 'rarity',
      desc: '',
      args: [],
    );
  }

  /// `Element`
  String get element {
    return Intl.message(
      'Element',
      name: 'element',
      desc: '',
      args: [],
    );
  }

  /// `Region`
  String get region {
    return Intl.message(
      'Region',
      name: 'region',
      desc: '',
      args: [],
    );
  }

  /// `Weapon`
  String get weapon {
    return Intl.message(
      'Weapon',
      name: 'weapon',
      desc: '',
      args: [],
    );
  }

  /// `Role`
  String get role {
    return Intl.message(
      'Role',
      name: 'role',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  /// `Male`
  String get male {
    return Intl.message(
      'Male',
      name: 'male',
      desc: '',
      args: [],
    );
  }

  /// `Female`
  String get female {
    return Intl.message(
      'Female',
      name: 'female',
      desc: '',
      args: [],
    );
  }

  /// `Elements`
  String get elements {
    return Intl.message(
      'Elements',
      name: 'elements',
      desc: '',
      args: [],
    );
  }

  /// `Elemental Debuffs`
  String get elementalDebuffs {
    return Intl.message(
      'Elemental Debuffs',
      name: 'elementalDebuffs',
      desc: '',
      args: [],
    );
  }

  /// `Each of these have a different negative effect when applied to you or your enemies`
  String get elementalDebuffsExplainded {
    return Intl.message(
      'Each of these have a different negative effect when applied to you or your enemies',
      name: 'elementalDebuffsExplainded',
      desc: '',
      args: [],
    );
  }

  /// `Elemental Reactions`
  String get elementalReactions {
    return Intl.message(
      'Elemental Reactions',
      name: 'elementalReactions',
      desc: '',
      args: [],
    );
  }

  /// `Combinations of different elements produces different reactions`
  String get elementalReactionsExplainded {
    return Intl.message(
      'Combinations of different elements produces different reactions',
      name: 'elementalReactionsExplainded',
      desc: '',
      args: [],
    );
  }

  /// `Elemental Resonances`
  String get elementalResonances {
    return Intl.message(
      'Elemental Resonances',
      name: 'elementalResonances',
      desc: '',
      args: [],
    );
  }

  /// `Having these types of character in your party will give you the corresponding effect`
  String get elemetalResonancesExplanined {
    return Intl.message(
      'Having these types of character in your party will give you the corresponding effect',
      name: 'elemetalResonancesExplanined',
      desc: '',
      args: [],
    );
  }

  /// `Today's Ascention Materials`
  String get todayAscentionMaterials {
    return Intl.message(
      'Today\'s Ascention Materials',
      name: 'todayAscentionMaterials',
      desc: '',
      args: [],
    );
  }

  /// `See all`
  String get seeAll {
    return Intl.message(
      'See all',
      name: 'seeAll',
      desc: '',
      args: [],
    );
  }

  /// `Characters`
  String get characters {
    return Intl.message(
      'Characters',
      name: 'characters',
      desc: '',
      args: [],
    );
  }

  /// `Weapons`
  String get weapons {
    return Intl.message(
      'Weapons',
      name: 'weapons',
      desc: '',
      args: [],
    );
  }

  /// `Artifacts`
  String get artifacts {
    return Intl.message(
      'Artifacts',
      name: 'artifacts',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Map`
  String get map {
    return Intl.message(
      'Map',
      name: 'map',
      desc: '',
      args: [],
    );
  }

  /// `Type`
  String get type {
    return Intl.message(
      'Type',
      name: 'type',
      desc: '',
      args: [],
    );
  }

  /// `Base Atk`
  String get baseAtk {
    return Intl.message(
      'Base Atk',
      name: 'baseAtk',
      desc: '',
      args: [],
    );
  }

  /// `Secondary Stat`
  String get secondaryState {
    return Intl.message(
      'Secondary Stat',
      name: 'secondaryState',
      desc: '',
      args: [],
    );
  }

  /// `Secondary Stat Value`
  String get secondaryStatValue {
    return Intl.message(
      'Secondary Stat Value',
      name: 'secondaryStatValue',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get location {
    return Intl.message(
      'Location',
      name: 'location',
      desc: '',
      args: [],
    );
  }

  /// `Loading`
  String get loading {
    return Intl.message(
      'Loading',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `For characters`
  String get forCharacters {
    return Intl.message(
      'For characters',
      name: 'forCharacters',
      desc: '',
      args: [],
    );
  }

  /// `For weapons`
  String get forWeapons {
    return Intl.message(
      'For weapons',
      name: 'forWeapons',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Others`
  String get others {
    return Intl.message(
      'Others',
      name: 'others',
      desc: '',
      args: [],
    );
  }

  /// `Filters`
  String get filters {
    return Intl.message(
      'Filters',
      name: 'filters',
      desc: '',
      args: [],
    );
  }

  /// `Sort by`
  String get sortBy {
    return Intl.message(
      'Sort by',
      name: 'sortBy',
      desc: '',
      args: [],
    );
  }

  /// `Flower`
  String get flower {
    return Intl.message(
      'Flower',
      name: 'flower',
      desc: '',
      args: [],
    );
  }

  /// `Plume`
  String get plume {
    return Intl.message(
      'Plume',
      name: 'plume',
      desc: '',
      args: [],
    );
  }

  /// `Clock`
  String get clock {
    return Intl.message(
      'Clock',
      name: 'clock',
      desc: '',
      args: [],
    );
  }

  /// `Goblet`
  String get goblet {
    return Intl.message(
      'Goblet',
      name: 'goblet',
      desc: '',
      args: [],
    );
  }

  /// `Crown`
  String get crown {
    return Intl.message(
      'Crown',
      name: 'crown',
      desc: '',
      args: [],
    );
  }

  /// `Elemental DMG%`
  String get elementalDmgPercentage {
    return Intl.message(
      'Elemental DMG%',
      name: 'elementalDmgPercentage',
      desc: '',
      args: [],
    );
  }

  /// `Healing Bonus`
  String get healingBonus {
    return Intl.message(
      'Healing Bonus',
      name: 'healingBonus',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get note {
    return Intl.message(
      'Note',
      name: 'note',
      desc: '',
      args: [],
    );
  }

  /// `Ascention Materials`
  String get ascentionMaterials {
    return Intl.message(
      'Ascention Materials',
      name: 'ascentionMaterials',
      desc: '',
      args: [],
    );
  }

  /// `Released`
  String get released {
    return Intl.message(
      'Released',
      name: 'released',
      desc: '',
      args: [],
    );
  }

  /// `Unreleased`
  String get unreleased {
    return Intl.message(
      'Unreleased',
      name: 'unreleased',
      desc: '',
      args: [],
    );
  }

  /// `Coming soon`
  String get comingSoon {
    return Intl.message(
      'Coming soon',
      name: 'comingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Recent`
  String get recent {
    return Intl.message(
      'Recent',
      name: 'recent',
      desc: '',
      args: [],
    );
  }

  /// `Rank`
  String get rank {
    return Intl.message(
      'Rank',
      name: 'rank',
      desc: '',
      args: [],
    );
  }

  /// `Level`
  String get level {
    return Intl.message(
      'Level',
      name: 'level',
      desc: '',
      args: [],
    );
  }

  /// `Materials`
  String get materials {
    return Intl.message(
      'Materials',
      name: 'materials',
      desc: '',
      args: [],
    );
  }

  /// `Constellation {value}`
  String constellationX(Object value) {
    return Intl.message(
      'Constellation $value',
      name: 'constellationX',
      desc: '',
      args: [value],
    );
  }

  /// `Constellations`
  String get constellations {
    return Intl.message(
      'Constellations',
      name: 'constellations',
      desc: '',
      args: [],
    );
  }

  /// `Passives`
  String get passives {
    return Intl.message(
      'Passives',
      name: 'passives',
      desc: '',
      args: [],
    );
  }

  /// `Unlocked Automatically`
  String get unlockedAutomatically {
    return Intl.message(
      'Unlocked Automatically',
      name: 'unlockedAutomatically',
      desc: '',
      args: [],
    );
  }

  /// `Unlocked at ascention level {value}`
  String unclockedAtAscentionLevelX(Object value) {
    return Intl.message(
      'Unlocked at ascention level $value',
      name: 'unclockedAtAscentionLevelX',
      desc: '',
      args: [value],
    );
  }

  /// `Skills`
  String get skills {
    return Intl.message(
      'Skills',
      name: 'skills',
      desc: '',
      args: [],
    );
  }

  /// `Talents Ascention`
  String get talentsAscention {
    return Intl.message(
      'Talents Ascention',
      name: 'talentsAscention',
      desc: '',
      args: [],
    );
  }

  /// `Talent Ascention {value}`
  String talentAscentionX(Object value) {
    return Intl.message(
      'Talent Ascention $value',
      name: 'talentAscentionX',
      desc: '',
      args: [value],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Sort direction`
  String get sortDirection {
    return Intl.message(
      'Sort direction',
      name: 'sortDirection',
      desc: '',
      args: [],
    );
  }

  /// `Refinements`
  String get refinements {
    return Intl.message(
      'Refinements',
      name: 'refinements',
      desc: '',
      args: [],
    );
  }

  /// `Sort type`
  String get sortType {
    return Intl.message(
      'Sort type',
      name: 'sortType',
      desc: '',
      args: [],
    );
  }

  /// `Ascending`
  String get asc {
    return Intl.message(
      'Ascending',
      name: 'asc',
      desc: '',
      args: [],
    );
  }

  /// `Descending`
  String get desc {
    return Intl.message(
      'Descending',
      name: 'desc',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Weapon type`
  String get weaponType {
    return Intl.message(
      'Weapon type',
      name: 'weaponType',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}