part of '../weapon_page.dart';

class Builds extends StatelessWidget {
  final Color color;
  final List<ItemCommonWithName> characters;

  const Builds({
    required this.color,
    required this.characters,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailSection.complex(
      title: s.characters,
      color: color,
      children: [
        DetailHorizontalListView(
          items: characters,
          onTap: (key) => CharacterPage.route(key, context),
        ),
        DetailHorizontalListButton(
          color: color,
          onTap: () => showDialog(
            context: context,
            builder: (context) => ItemCommonWithNameDialog.simple(
              title: s.characters,
              items: characters,
              fit: BoxFit.contain,
              useSquare: false,
              onTap: (key) => CharacterPage.route(key, context),
            ),
          ),
        ),
      ],
    );
  }
}
