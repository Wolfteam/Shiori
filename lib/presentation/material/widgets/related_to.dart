part of '../material_page.dart';

class _RelatedTo extends StatelessWidget {
  final Color color;
  final List<ItemCommonWithName> relatedTo;

  const _RelatedTo({
    required this.color,
    required this.relatedTo,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailHorizontalList(
      color: color,
      title: s.related,
      items: relatedTo,
      onTap: (key) => mp.MaterialPage.route(key, context),
      onButtonTap: () => showDialog(
        context: context,
        builder: (context) => ItemCommonWithNameDialog.simple(
          title: s.related,
          items: relatedTo,
          onTap: (key) => mp.MaterialPage.route(key, context),
        ),
      ),
    );
  }
}
