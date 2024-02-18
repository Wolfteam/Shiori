part of '../material_page.dart';

class _Weapons extends StatelessWidget {
  final Color color;
  final List<ItemCommonWithName> weapons;

  const _Weapons({
    required this.color,
    required this.weapons,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailHorizontalList(
      color: color,
      title: s.weapons,
      items: weapons,
      onTap: (key) => WeaponPage.route(key, context),
      onButtonTap: () => showDialog(
        context: context,
        builder: (context) => ItemCommonWithNameDialog.simple(
          title: s.weapons,
          items: weapons,
          onTap: (key) => WeaponPage.route(key, context),
        ),
      ),
    );
  }
}
