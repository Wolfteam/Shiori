part of '../weapon_page.dart';

class Main extends StatelessWidget {
  final String itemKey;
  final String name;
  final double atk;
  final int rarity;
  final StatType secondaryStatType;
  final double secondaryStatValue;
  final WeaponType type;
  final ItemLocationType locationType;
  final String image;
  final bool isInInventory;

  const Main({
    required this.itemKey,
    required this.name,
    required this.atk,
    required this.rarity,
    required this.secondaryStatType,
    required this.secondaryStatValue,
    required this.type,
    required this.locationType,
    required this.image,
    required this.isInInventory,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final gradient = rarity.getRarityGradient();
    final textStyle = theme.textTheme.bodyMedium!.copyWith(color: Colors.white);
    return DetailTopLayout(
      fullImage: image,
      secondFullImage: image,
      decoration: BoxDecoration(gradient: gradient),
      charDescriptionHeight: 220,
      isAnSmallImage: isPortrait,
      generalCard: DetailGeneralCardNew(
        itemName: name,
        color: gradient.colors.first,
        rows: [
          GeneralCardRow(
            left: GeneralCardColumn(
              title: s.rarity,
              child: Rarity(
                stars: rarity,
                color: Colors.white,
                centered: false,
              ),
            ),
            right: GeneralCardColumn(
              title: s.type,
              child: Row(
                children: [
                  Image.asset(
                    type.getWeaponNormalSkillAssetPath(),
                    width: 20,
                    height: 20,
                  ),
                  Text(
                    s.translateWeaponType(type),
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          GeneralCardRow(
            left: GeneralCardColumn(
              title: s.baseAtk,
              child: Text(
                '$atk',
                style: textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            right: GeneralCardColumn(
              title: s.secondaryState,
              child: Text(
                s.translateStatType(secondaryStatType, secondaryStatValue),
                style: textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          GeneralCardRow(
            left: GeneralCardColumn(
              title: s.location,
              child: Text(
                s.translateItemLocationType(locationType),
                style: textStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
      appBarActions: [
        IconButton(
          icon: Icon(isInInventory ? Icons.favorite : Icons.favorite_border),
          color: Colors.red,
          splashRadius: Styles.mediumButtonSplashRadius,
          onPressed: () => _favoriteWeapon(itemKey, isInInventory, context),
        ),
      ],
    );
  }

  void _favoriteWeapon(String key, bool isInInventory, BuildContext context) {
    final event = !isInInventory ? WeaponEvent.addToInventory(key: key) : WeaponEvent.deleteFromInventory(key: key);
    context.read<WeaponBloc>().add(event);
  }
}
