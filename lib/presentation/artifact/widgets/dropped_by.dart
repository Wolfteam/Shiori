part of '../artifact_page.dart';

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
    return DetailSection.complex(
      title: s.droppedBy,
      color: color,
      children: [
        DetailHorizontalListView(
          items: droppedBy,
          onTap: (key) => ToastUtils.showWarningToast(fToast, s.comingSoon),
        ),
        DetailHorizontalListButton(
          color: color,
          onTap: () => ToastUtils.showWarningToast(fToast, s.comingSoon),
        ),
      ],
    );
  }
}
