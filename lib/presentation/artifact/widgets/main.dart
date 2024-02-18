part of '../artifact_page.dart';

class Main extends StatelessWidget {
  final String name;
  final int maxRarity;
  final String image;

  const Main({
    required this.name,
    required this.maxRarity,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final gradient = maxRarity.getRarityGradient();
    return DetailMainContent(
      fullImage: image,
      secondFullImage: image,
      decoration: BoxDecoration(gradient: gradient),
      isAnSmallImage: isPortrait,
      generalCard: DetailMainCard(
        itemName: name,
        color: gradient.colors.first,
        rows: [
          CardRow(
            left: CardColumn(
              title: s.rarity,
              child: Rarity(
                stars: maxRarity,
                color: Colors.white,
                centered: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
