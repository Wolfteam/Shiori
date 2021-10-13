import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/presentation/shared/details/detail_top_layout.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/loading.dart';

import 'weapon_detail_general_card.dart';

class WeaponDetailTop extends StatelessWidget {
  final String name;
  final double atk;
  final int rarity;
  final StatType secondaryStatType;
  final double secondaryStatValue;
  final WeaponType type;
  final ItemLocationType locationType;
  final String image;

  const WeaponDetailTop({
    Key? key,
    required this.name,
    required this.atk,
    required this.rarity,
    required this.secondaryStatType,
    required this.secondaryStatValue,
    required this.type,
    required this.locationType,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    return DetailTopLayout(
      fullImage: image,
      secondFullImage: image,
      decoration: BoxDecoration(gradient: rarity.getRarityGradient()),
      showShadowImage: isPortrait,
      charDescriptionHeight: 220,
      isAnSmallImage: isPortrait,
      generalCard: WeaponDetailGeneralCard(
        type: type,
        atk: atk,
        locationType: locationType,
        name: name,
        rarity: rarity,
        secondaryStatValue: secondaryStatValue,
        statType: secondaryStatType,
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          BlocBuilder<WeaponBloc, WeaponState>(
            builder: (ctx, state) => state.map(
              loading: (_) => const Loading(useScaffold: false),
              loaded: (state) => IconButton(
                icon: Icon(state.isInInventory ? Icons.favorite : Icons.favorite_border),
                color: Colors.red,
                onPressed: () => _favoriteWeapon(state.key, state.isInInventory, context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _favoriteWeapon(String key, bool isInInventory, BuildContext context) {
    final event = !isInInventory ? InventoryEvent.addWeapon(key: key) : InventoryEvent.deleteWeapon(key: key);
    context.read<InventoryBloc>().add(event);
  }
}
