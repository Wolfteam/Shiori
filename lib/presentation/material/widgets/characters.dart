part of '../material_page.dart';

class _Characters extends StatelessWidget {
  final Color color;
  final List<ItemCommonWithName> characters;

  const _Characters({
    required this.color,
    required this.characters,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailHorizontalList(
      color: color,
      title: s.characters,
      items: characters,
      onTap: (key) => CharacterPage.route(key, context),
      onButtonTap: () => showDialog(
        context: context,
        builder: (context) => ItemCommonWithNameDialog.simple(
          title: s.characters,
          items: characters,
          onTap: (key) => CharacterPage.route(key, context),
        ),
      ),
    );
  }
}
