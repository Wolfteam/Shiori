part of '../material_page.dart';

class _ObtainedFrom extends StatelessWidget {
  final Color color;
  final List<ItemObtainedFrom> obtainedFrom;

  const _ObtainedFrom({
    required this.color,
    required this.obtainedFrom,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DetailSection.complex(
      title: s.obtainedFrom,
      color: color,
      children: [
        ...obtainedFrom.mapIndex(
          (e, index) => DetailMaterialsHorizontalListColumn(
            color: color,
            title: s.obtainedFrom,
            items: e.items,
          ),
        ),
      ],
    );
  }
}
