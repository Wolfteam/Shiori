part of '../artifact_page.dart';

class _UsedBy extends StatelessWidget {
  final Color color;
  final List<ItemCommonWithName> usedBy;

  const _UsedBy({
    required this.color,
    required this.usedBy,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailSection.complex(
      title: s.builds,
      color: color,
      children: [
        DetailHorizontalListView(
          items: usedBy,
          onTap: (key) => CharacterPage.route(key, context),
        ),
        DetailHorizontalListButton(
          color: color,
          onTap: () => showDialog(
            context: context,
            builder: (context) => ItemCommonWithNameDialog.simple(
              title: s.characters,
              items: usedBy,
              onTap: (key) => CharacterPage.route(key, context),
            ),
          ),
        ),
      ],
    );
  }
}
