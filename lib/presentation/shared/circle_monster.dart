import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/utils/toast_utils.dart';

import 'circle_item.dart';

class CircleMonster extends StatelessWidget {
  final String image;
  final double radius;

  const CircleMonster({
    Key key,
    @required this.image,
    this.radius = 35,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final fToast = ToastUtils.of(context);
    return CircleItem(
      image: image,
      radius: radius,
      onTap: (_) => ToastUtils.showWarningToast(fToast, s.comingSoon),
    );
  }
}
