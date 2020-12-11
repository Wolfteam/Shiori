import 'package:flutter/material.dart';

import '../../../common/enums/element_type.dart';
import '../../../common/extensions/element_type_extensions.dart';
import '../../../common/extensions/i18n_extensions.dart';
import '../../../generated/l10n.dart';

class ElementsButtonBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final buttons = ElementType.values
        .map(
          (e) => IconButton(
            icon: Image.asset(e.getElementAsssetPath()),
            onPressed: () => {},
            tooltip: s.translateElementType(e),
          ),
        )
        .toList();

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: buttons,
    );
  }
}
