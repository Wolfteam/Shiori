part of '../material_page.dart';

class _Main extends StatelessWidget {
  final String name;
  final int rarity;
  final enums.MaterialType type;
  final String image;
  final List<int> days;

  const _Main({
    required this.name,
    required this.rarity,
    required this.type,
    required this.image,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final gradient = rarity.getRarityGradient();
    final textStyle = theme.textTheme.bodyMedium!.copyWith(color: Colors.white);
    return DetailTopLayout(
      fullImage: image,
      secondFullImage: image,
      decoration: BoxDecoration(gradient: gradient),
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
              child: Text(
                s.translateMaterialType(type),
                style: textStyle,
              ),
            ),
          ),
          if (days.isNotEmpty)
            GeneralCardRow(
              left: GeneralCardColumn(
                title: s.day,
                child: Text(
                  s.translateDays(days),
                  style: textStyle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
