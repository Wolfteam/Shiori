import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../common/enums/material_type.dart' as app;
import '../../../common/styles.dart';

class MaterialItem extends StatelessWidget {
  final app.MaterialType type;
  final String image;
  final int quantity;

  const MaterialItem({
    Key key,
    @required this.type,
    @required this.image,
    @required this.quantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: Styles.edgeInsetAll5,
      child: Column(
        children: [
          Image.asset(image, width: 50, height: 50),
          Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: theme.textTheme.subtitle2.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
