import 'package:shiori/domain/enums/enums.dart';

/// Canonical game-data facts referenced by the integration tests, in one place for easy reference.
///
/// These tests download the LIVE production resources at runtime, so every value here is a **stable
/// invariant** — named-entity identity facts and fixed game-mechanic counts, all grounded in
/// `Resources/db/*.json`. Do NOT add volatile totals (character/weapon/monster/material counts grow
/// every patch) — those would make the tests flaky on every resource update.
///
/// `key` = kebab-case slug (stable across runs); `name` = English display name shown in the UI.
class TestCharacter {
  final String key;
  final String name;
  final int rarity;
  final ElementType element;
  final WeaponType weapon;

  const TestCharacter({
    required this.key,
    required this.name,
    required this.rarity,
    required this.element,
    required this.weapon,
  });
}

class TestWeapon {
  final String key;
  final String name;
  final int rarity;
  final WeaponType type;

  const TestWeapon({
    required this.key,
    required this.name,
    required this.rarity,
    required this.type,
  });
}

class TestMaterial {
  final String key;
  final String name;
  final int rarity;
  final MaterialType type;

  const TestMaterial({
    required this.key,
    required this.name,
    required this.rarity,
    required this.type,
  });
}

class TestArtifact {
  final String key;
  final String name;
  final int minRarity;
  final int maxRarity;

  const TestArtifact({
    required this.key,
    required this.name,
    required this.minRarity,
    required this.maxRarity,
  });
}

class TestMonster {
  final String key;
  final String name;

  const TestMonster({required this.key, required this.name});
}

/// An immutable past banner from `banners_history.json` (safe to assert — history never changes).
class TestBanner {
  final String version;
  final String featuredCharacterKey;
  final String featuredWeaponKey;

  const TestBanner({
    required this.version,
    required this.featuredCharacterKey,
    required this.featuredWeaponKey,
  });
}

abstract final class GameData {
  // --- Characters (characters.json) ---
  static const TestCharacter keqing = TestCharacter(
    key: 'keqing',
    name: 'Keqing',
    rarity: 5,
    element: ElementType.electro,
    weapon: WeaponType.sword,
  );
  static const TestCharacter nahida = TestCharacter(
    key: 'nahida',
    name: 'Nahida',
    rarity: 5,
    element: ElementType.dendro,
    weapon: WeaponType.catalyst,
  );
  static const TestCharacter fischl = TestCharacter(
    key: 'fischl',
    name: 'Fischl',
    rarity: 4,
    element: ElementType.electro,
    weapon: WeaponType.bow,
  );
  static const TestCharacter kazuha = TestCharacter(
    key: 'kaedehara-kazuha',
    name: 'Kaedehara Kazuha',
    rarity: 5,
    element: ElementType.anemo,
    weapon: WeaponType.sword,
  );

  // --- Weapons (weapons.json) ---
  static const TestWeapon prototypeArchaic = TestWeapon(
    key: 'prototype-archaic',
    name: 'Prototype Archaic',
    rarity: 4,
    type: WeaponType.claymore,
  );
  static const TestWeapon messenger = TestWeapon(
    key: 'messenger',
    name: 'Messenger',
    rarity: 3,
    type: WeaponType.bow,
  );
  static const TestWeapon sacrificialSword = TestWeapon(
    key: 'sacrificial-sword',
    name: 'Sacrificial Sword',
    rarity: 4,
    type: WeaponType.sword,
  );
  static const TestWeapon mistsplitterReforged = TestWeapon(
    key: 'mistsplitter-reforged',
    name: 'Mistsplitter Reforged',
    rarity: 5,
    type: WeaponType.sword,
  );
  static const TestWeapon aThousandFloatingDreams = TestWeapon(
    key: 'a-thousand-floating-dreams',
    name: 'A Thousand Floating Dreams',
    rarity: 5,
    type: WeaponType.catalyst,
  );

  // --- Materials (materials.json) ---
  static const TestMaterial stainedMask = TestMaterial(
    key: 'stained-mask',
    name: 'Stained Mask',
    rarity: 2,
    type: MaterialType.common,
  );
  static const TestMaterial mora = TestMaterial(
    key: 'mora',
    name: 'Mora',
    rarity: 3,
    type: MaterialType.currency,
  );

  // --- Artifacts (artifacts.json) ---
  static const TestArtifact gladiatorsFinale = TestArtifact(
    key: 'gladiators-finale',
    name: "Gladiator's Finale",
    minRarity: 4,
    maxRarity: 5,
  );
  static const TestArtifact thunderingFury = TestArtifact(
    key: 'thundering-fury',
    name: 'Thundering Fury',
    minRarity: 4,
    maxRarity: 5,
  );

  // --- Monsters (monsters.json) ---
  static const TestMonster raidenShogun = TestMonster(key: 'raiden-shogun', name: 'Raiden Shogun');

  // --- Banner history (banners_history.json, immutable) ---
  static const TestBanner banner32 = TestBanner(
    version: '3.2',
    featuredCharacterKey: 'nahida',
    featuredWeaponKey: 'a-thousand-floating-dreams',
  );

  // A fixed set of historical (immutable) banner versions used to bound the wish-history scroll test.
  // Past versions never change and, under ascending sort, keep a constant distance from the top no
  // matter how many new banners are appended — so the scroll stays real but never grows unbounded.
  // Ends at [banner32] (3.2), which sorts last, forcing a genuine multi-item scroll to reach it.
  static const List<String> stableBannerVersions = ['1.0', '1.1', '2.0', '3.0', '3.2'];

  // --- Elements page: fixed game-mechanic counts (elements.json) ---
  static const int elementDebuffCount = 4;
  static const int elementReactionCount = 17;
  static const int elementResonanceCount = 8;
}
