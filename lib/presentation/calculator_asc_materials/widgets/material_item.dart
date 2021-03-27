import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:genshindb/domain/enums/enums.dart' as app;
import 'package:genshindb/domain/utils/currency_utils.dart';
import 'package:genshindb/presentation/shared/styles.dart';

class MaterialItem extends StatelessWidget {
  final app.MaterialType type;
  final String image;
  final int quantity;
  final Color textColor;

  const MaterialItem({
    Key key,
    @required this.type,
    @required this.image,
    @required this.quantity,
    this.textColor,
  }) : super(key: key);

  //TODO: GO TO THE MATERIALS PAGE
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: Styles.edgeInsetAll5,
      child: Column(
        children: [
          Image.asset(image, width: 50, height: 50),
          Text(
            type == app.MaterialType.currency ? CurrencyUtils.formatNumber(quantity) : '$quantity',
            textAlign: TextAlign.center,
            style: textColor != null ? theme.textTheme.subtitle2.copyWith(color: textColor) : theme.textTheme.subtitle2,
          ),
        ],
      ),
    );
  }
}
