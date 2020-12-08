// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static m0(value) => "${value} ATK";

  static m1(value) => "${value} ATK%";

  static m2(value) => "${value} CRIT ATK";

  static m3(value) => "${value} CRIT DMG";

  static m4(value) => "${value} CRIT Rate";

  static m5(value) => "${value} CRIT Rate%";

  static m6(value) => "${value} DEF%";

  static m7(value) => "${value} Elementary Master";

  static m8(value) => "${value} Energy Recharge %";

  static m9(value) => "${value} HP%";

  static m10(value) => "${value} PHYS DMG Bonus";

  static m11(value) => "${value} PHYS DMG %";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "appName" : MessageLookupByLibrary.simpleMessage("GenshinDb"),
    "atk" : m0,
    "atkPercentage" : m1,
    "bow" : MessageLookupByLibrary.simpleMessage("Bow"),
    "bpBounty" : MessageLookupByLibrary.simpleMessage("BP Bounty"),
    "catalyst" : MessageLookupByLibrary.simpleMessage("Catalyst"),
    "chest" : MessageLookupByLibrary.simpleMessage("Chest"),
    "claymore" : MessageLookupByLibrary.simpleMessage("Claymore"),
    "crafting" : MessageLookupByLibrary.simpleMessage("Crafting"),
    "critAtk" : m2,
    "critDmgPercentage" : m3,
    "critRate" : m4,
    "critRatePercentage" : m5,
    "dark" : MessageLookupByLibrary.simpleMessage("Dark"),
    "defPercentage" : m6,
    "elementaryMaster" : m7,
    "energyRechargePercentage" : m8,
    "english" : MessageLookupByLibrary.simpleMessage("English"),
    "gacha" : MessageLookupByLibrary.simpleMessage("Gacha"),
    "hpPercentage" : m9,
    "light" : MessageLookupByLibrary.simpleMessage("Light"),
    "none" : MessageLookupByLibrary.simpleMessage("None"),
    "physDmgBonus" : m10,
    "physDmgPercentage" : m11,
    "polearm" : MessageLookupByLibrary.simpleMessage("Polearm"),
    "spanish" : MessageLookupByLibrary.simpleMessage("Spanish"),
    "starglitterExchange" : MessageLookupByLibrary.simpleMessage("Starglitter Exchange"),
    "sword" : MessageLookupByLibrary.simpleMessage("Sword")
  };
}
