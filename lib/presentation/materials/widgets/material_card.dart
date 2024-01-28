import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart' as enums;
import 'package:shiori/domain/models/materials/material_card_model.dart';
import 'package:shiori/domain/utils/currency_utils.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/material/material_page.dart' as mp;
import 'package:shiori/presentation/shared/dialogs/item_quantity_dialog.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/gradient_card.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:transparent_image/transparent_image.dart';

const double defaultWidth = 70;
const double defaultHeight = 60;

class MaterialCard extends StatelessWidget {
  final String keyName;
  final String? name;
  final String image;
  final int rarity;
  final double imgWidth;
  final double imgHeight;
  final bool withoutDetails;
  final bool withElevation;
  final int quantity;
  final bool isInSelectionMode;
  final bool isInQuantityMode;
  final enums.MaterialType type;
  final int usedQuantity;

  const MaterialCard({
    super.key,
    required this.keyName,
    required this.name,
    required this.image,
    required this.rarity,
    required this.type,
    this.imgWidth = defaultWidth,
    this.imgHeight = defaultHeight,
    this.withElevation = true,
    this.isInSelectionMode = false,
  })  : withoutDetails = false,
        isInQuantityMode = false,
        quantity = -1,
        usedQuantity = -1;

  MaterialCard.item({
    super.key,
    required MaterialCardModel item,
    this.imgWidth = defaultWidth,
    this.imgHeight = defaultHeight,
    this.withElevation = true,
    this.isInSelectionMode = false,
  })  : keyName = item.key,
        name = item.name,
        image = item.image,
        rarity = item.rarity,
        withoutDetails = false,
        isInQuantityMode = false,
        quantity = -1,
        usedQuantity = -1,
        type = item.type;

  const MaterialCard.withoutDetails({
    super.key,
    required this.keyName,
    required this.image,
    required this.rarity,
    required this.type,
    this.isInSelectionMode = false,
  })  : name = null,
        imgWidth = defaultWidth,
        imgHeight = defaultHeight,
        withoutDetails = true,
        withElevation = false,
        isInQuantityMode = false,
        quantity = -1,
        usedQuantity = -1;

  MaterialCard.quantity({
    super.key,
    required MaterialCardModel item,
    this.isInSelectionMode = false,
  })  : keyName = item.key,
        name = item.name,
        image = item.image,
        rarity = item.rarity,
        quantity = item.quantity,
        imgWidth = defaultWidth,
        imgHeight = defaultHeight,
        withoutDetails = true,
        withElevation = false,
        isInQuantityMode = true,
        type = item.type,
        usedQuantity = item.usedQuantity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: imgWidth * 1.5,
      height: imgHeight * 2,
      child: InkWell(
        borderRadius: Styles.mainCardBorderRadius,
        onTap: () => _gotoMaterialPage(context),
        child: GradientCard(
          shape: Styles.mainCardShape,
          elevation: withElevation ? Styles.cardTenElevation : 0,
          gradient: rarity.getRarityGradient(),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              FadeInImage(
                width: imgWidth,
                height: imgHeight,
                placeholder: MemoryImage(kTransparentImage),
                fit: BoxFit.fill,
                placeholderFit: BoxFit.fill,
                alignment: Alignment.topCenter,
                image: FileImage(File(image)),
              ),
              if (usedQuantity > 0 && isInQuantityMode)
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => _showUsedItemsDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: theme.colorScheme.primaryContainer,
                      ),
                      child: Tooltip(
                        message: ' - ${CurrencyUtils.formatNumber(usedQuantity)}',
                        child: Text(
                          ' - ${CurrencyUtils.formatNumber(usedQuantity)} ',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ),
                  ),
                ),
              if (quantity >= 0 && isInQuantityMode)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: Styles.commonCardBoxDecoration,
                    width: double.infinity,
                    padding: Styles.edgeInsetAll5,
                    child: Text(
                      CurrencyUtils.formatNumber(quantity),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall!.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              if (!withoutDetails && !isInQuantityMode)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: Styles.commonCardBoxDecoration,
                    width: double.infinity,
                    padding: Styles.edgeInsetAll5,
                    child: Tooltip(
                      message: name,
                      child: Text(
                        name!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _gotoMaterialPage(BuildContext context) async {
    if (isInQuantityMode) {
      return _showQuantityPickerDialog(context);
    }

    if (isInSelectionMode) {
      Navigator.pop(context, keyName);
      return;
    }

    final route = MaterialPageRoute(builder: (c) => mp.MaterialPage(itemKey: keyName));
    await Navigator.push(context, route);
  }

  Future<void> _showQuantityPickerDialog(BuildContext context) async {
    await showDialog<int>(
      context: context,
      builder: (_) => ItemQuantityDialog(quantity: quantity),
    ).then((newValue) {
      if (newValue == null) {
        return;
      }

      context.read<InventoryBloc>().add(InventoryEvent.updateMaterial(key: keyName, quantity: newValue));
    });
  }

  Future<void> _showUsedItemsDialog(BuildContext context) async {
    final s = S.of(context);
    final used = CurrencyUtils.formatNumber(usedQuantity);
    await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.usedItem),
        content: Text(s.itemIsBeingUsedOnACalculation(used)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(s.ok),
          ),
        ],
      ),
    );
  }
}
