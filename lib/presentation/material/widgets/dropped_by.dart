part of '../material_page.dart';

class _DroppedBy extends StatelessWidget {
  final Color color;
  final List<ItemCommonWithName> droppedBy;

  const _DroppedBy({
    required this.color,
    required this.droppedBy,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final fToast = ToastUtils.of(context);
    return DetailHorizontalList(
      color: color,
      title: s.droppedBy,
      items: droppedBy,
      onTap: (key) => ToastUtils.showWarningToast(fToast, s.comingSoon),
      onButtonTap: () => showDialog(
        context: context,
        builder: (context) => ItemCommonWithNameDialog.simple(
          title: s.droppedBy,
          items: droppedBy,
          onTap: (_) => ToastUtils.showWarningToast(fToast, s.comingSoon),
        ),
      ),
    );
  }
}
