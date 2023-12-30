import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';

class ElementsButtonBar extends StatelessWidget {
  final List<ElementType> selectedValues;
  final Function(ElementType) onClick;
  final double iconSize;

  const ElementsButtonBar({
    super.key,
    required this.onClick,
    this.selectedValues = const [],
    this.iconSize = 24,
  });

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
      iconSize: iconSize,
      icon: Opacity(
        opacity: !isSelected ? 1 : 0.2,
        child: Image.asset(
          value.getElementAssetPath(),
          width: iconSize * 1.3,
          height: iconSize * 1.3,
        ),
      ),
      onPressed: () => onClick(value),
      tooltip: tooltip,
    );
  }
}
