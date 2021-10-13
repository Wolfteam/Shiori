import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart' as app;
import 'package:shiori/domain/utils/currency_utils.dart';
import 'package:shiori/presentation/material/material_page.dart' as mp;

import 'change_material_quantity_dialog.dart';

class MaterialItem extends StatelessWidget {
  final app.MaterialType type;
  final String itemKey;
  final String image;
  final int quantity;
  final Color? textColor;
  final int sessionKey;

  const MaterialItem({
    Key? key,
    required this.itemKey,
    required this.type,
    required this.image,
    required this.quantity,
    required this.sessionKey,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
            onLongPress: () => _showQuantityPickerDialog(context),
            borderRadius: BorderRadius.circular(30),
            child: IconButton(
              icon: Image.asset(image),
              iconSize: 45,
              splashRadius: 30,
              constraints: const BoxConstraints(),
              onPressed: () => _gotoMaterialPage(context),
            )),
        if (quantity > 0)
          Text(
            type == app.MaterialType.currency ? CurrencyUtils.formatNumber(quantity) : '$quantity',
            textAlign: TextAlign.center,
            style: textColor != null ? theme.textTheme.subtitle2!.copyWith(color: textColor) : theme.textTheme.subtitle2,
          ),
        if (quantity == 0) const Icon(Icons.check, color: Colors.green, size: 18),
      ],
    );
  }

  Future<void> _showQuantityPickerDialog(BuildContext context) async {
    context.read<CalculatorAscMaterialsItemUpdateQuantityBloc>().add(CalculatorAscMaterialsItemUpdateQuantityEvent.load(key: itemKey));
    await showDialog<int>(
      context: context,
      builder: (_) => ChangeMaterialQuantityDialog(sessionKey: sessionKey),
    );
  }

  Future<void> _gotoMaterialPage(BuildContext context) async {
    final bloc = context.read<MaterialBloc>();
    bloc.add(MaterialEvent.loadFromKey(key: itemKey));
    final route = MaterialPageRoute(builder: (c) => mp.MaterialPage());
    await Navigator.push(context, route);
    bloc.pop();
  }
}
