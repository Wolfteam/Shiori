import 'package:flutter/material.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/generated/l10n.dart';

import 'extensions/element_type_extensions.dart';
import 'extensions/i18n_extensions.dart';

class ElementsButtonBar extends StatelessWidget {
  final List<ElementType> selectedValues;
  final Function(ElementType) onClick;

  const ElementsButtonBar({
    Key? key,
    required this.onClick,
    this.selectedValues = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final buttons = ElementType.values.map((e) => _buildIconButton(e, s.translateElementType(e))).toList();

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: buttons,
    );
  }

  Widget _buildIconButton(ElementType value, String tooltip) {
    final isSelected = selectedValues.isEmpty || !selectedValues.contains(value);
    return IconButton(
      icon: Opacity(
        opacity: !isSelected ? 1 : 0.2,
        child: Image.asset(value.getElementAsssetPath()),
      ),
      onPressed: () => onClick(value),
      tooltip: tooltip,
    );
  }
}
