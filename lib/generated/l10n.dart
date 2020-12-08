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