import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart' as app;
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/utils/currency_utils.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/change_material_quantity_dialog.dart';
import 'package:shiori/presentation/material/material_page.dart' as mp;
import 'package:shiori/presentation/shared/styles.dart';

enum _DialogOptionType {
  updateQuantity,
  goToDetails,
}

class MaterialItem extends StatelessWidget {
  final app.MaterialType type;
  final String itemKey;
  final String image;
  final int usedQuantity;
  final int requiredQuantity;
  final int remainingQuantity;
  final Color? textColor;
  final int sessionKey;
  final bool showMaterialUsage;

  const MaterialItem({
    super.key,
    required this.itemKey,
    required this.type,
    required this.image,
    required this.usedQuantity,
    required this.requiredQuantity,
    required this.remainingQuantity,
    required this.sessionKey,
    required this.showMaterialUsage,
    this.textColor,
  });

  MaterialItem.fromSummary({
    required this.sessionKey,
    required MaterialSummary summary,
    required this.showMaterialUsage,
  })  : itemKey = summary.key,
        image = summary.fullImagePath,
        usedQuantity = summary.usedQuantity,
        requiredQuantity = summary.requiredQuantity,
        remainingQuantity = summary.remainingQuantity,
        type = summary.type,
        textColor = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usedText = _formatQuantity(usedQuantity);
    final requiredText = _formatQuantity(requiredQuantity);
    final remainingText = _formatQuantity(remainingQuantity);
    final usageText = '$usedText / $requiredText';
    return Container(
      margin: Styles.edgeInsetHorizontal5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Image.file(File(image)),
            iconSize: 45,
            splashRadius: 30,
            constraints: const BoxConstraints(),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => _OptionsDialog(
                usedText: usedText,
                requiredText: requiredText,
                remainingText: remainingText,
                showUsage: showMaterialUsage,
              ),
            ).then((option) {
              switch (option) {
                case _DialogOptionType.goToDetails:
                  _gotoMaterialPage(context);
                case _DialogOptionType.updateQuantity:
                  _showQuantityPickerDialog(context);
                default:
                  break;
              }
            }),
          ),
          if (showMaterialUsage && usedQuantity == requiredQuantity)
            const Icon(Icons.check, color: Colors.green, size: 18)
          else
            Text(
              showMaterialUsage ? usageText : requiredText,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: textColor != null ? theme.textTheme.titleSmall!.copyWith(color: textColor) : theme.textTheme.titleSmall,
            ),
        ],
      ),
    );
  }

  String _formatQuantity(int quantity) {
    return type == app.MaterialType.currency ? CurrencyUtils.formatNumber(quantity) : '$quantity';
  }

  Future<void> _showQuantityPickerDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ChangeMaterialQuantityDialog(itemKey: itemKey),
    ).then((saved) {
      if (saved == true) {
        context.read<CalculatorAscMaterialsBloc>().add(CalculatorAscMaterialsEvent.init(sessionKey: sessionKey));
      }
    });
  }

  Future<void> _gotoMaterialPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (c) => mp.MaterialPage(itemKey: itemKey));
    await Navigator.push(context, route);
  }
}

class _OptionsDialog extends StatelessWidget {
  final String usedText;
  final String requiredText;
  final String remainingText;
  final bool showUsage;

  const _OptionsDialog({
    required this.usedText,
    required this.requiredText,
    required this.remainingText,
    required this.showUsage,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(s.selectAnOption),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
      ],
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(s.details),
            onTap: () => Navigator.pop(context, _DialogOptionType.goToDetails),
          ),
          ListTile(
            title: Text(s.update),
            isThreeLine: showUsage,
            subtitle: showUsage
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${s.required}: $requiredText', overflow: TextOverflow.ellipsis),
                      Text('${s.used}: $usedText', overflow: TextOverflow.ellipsis),
                      Text('${s.remaining}: $remainingText', overflow: TextOverflow.ellipsis),
                    ],
                  )
                : null,
            onTap: () => Navigator.pop(context, _DialogOptionType.updateQuantity),
          ),
        ],
      ),
    );
  }
}
