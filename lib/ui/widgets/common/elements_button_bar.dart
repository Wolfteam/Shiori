import 'package:flutter/material.dart';

import '../../../common/enums/element_type.dart';
import '../../../common/extensions/element_type_extensions.dart';

class ElementsButtonBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final buttons = ElementType.values
        .map((e) => IconButton(
              icon: Image.asset(e.getElementAsssetPath()),
              onPressed: () => {},
              tooltip: 'Algo',
            ))
        .toList();

    return Wrap(
      children: buttons,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
    );
  }
}
