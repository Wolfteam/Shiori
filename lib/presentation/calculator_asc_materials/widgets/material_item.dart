import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart' as app;
import 'package:shiori/domain/utils/currency_utils.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/change_material_quantity_dialog.dart';
import 'package:shiori/presentation/material/material_page.dart' as mp;

class MaterialItem extends StatelessWidget {
  final app.MaterialType type;
  final String itemKey;
  final String image;
  final int quantity;
  final Color? textColor;
  final int sessionKey;

  const MaterialItem({
    super.key,
    required this.itemKey,
    required this.type,
    required this.image,
    required this.quantity,
    required this.sessionKey,
    this.textColor,
  });

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
            icon: Image.file(File(image)),
            iconSize: 45,
            splashRadius: 30,
            constraints: const BoxConstraints(),
            onPressed: () => _gotoMaterialPage(context),
          ),
        ),
        if (quantity > 0)
          Text(
            type == app.MaterialType.currency ? CurrencyUtils.formatNumber(quantity) : '$quantity',
            textAlign: TextAlign.center,
            style: textColor != null ? theme.textTheme.titleSmall!.copyWith(color: textColor) : theme.textTheme.titleSmall,
          ),
        if (quantity == 0) const Icon(Icons.check, color: Colors.green, size: 18),
      ],
    );
  }

  Future<void> _showQuantityPickerDialog(BuildContext context) async {
    await showDialog<int>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CalculatorAscMaterialsBloc>(),
        child: ChangeMaterialQuantityDialog(sessionKey: sessionKey, itemKey: itemKey),
      ),
    );
  }

  Future<void> _gotoMaterialPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => mp.MaterialPage(itemKey: itemKey));
    await Navigator.push(context, route);
  }
}
