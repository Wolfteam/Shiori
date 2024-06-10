import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/add_edit_item_bottom_sheet.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/material_item.dart';
import 'package:shiori/presentation/shared/child_item_disabled.dart';
import 'package:shiori/presentation/shared/extensions/element_type_extensions.dart';
import 'package:shiori/presentation/shared/extensions/rarity_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/modal_bottom_sheet_utils.dart';
import 'package:transparent_image/transparent_image.dart';

class ItemCard extends StatelessWidget {
  final int sessionKey;
  final int index;
  final String itemKey;
  final String name;
  final String image;
  final int rarity;
  final bool isWeapon;
  final List<ItemAscensionMaterialModel> materials;
  final bool isActive;
  final ElementType? elementType;
  final bool showMaterialUsage;
  final bool useMaterialsFromInventory;

  static const double itemWidth = 210;
  static const double minItemHeight = 420;
  static const double maxItemHeight = 600;

  const ItemCard({
    super.key,
    required this.sessionKey,
    required this.index,
    required this.itemKey,
    required this.name,
    required this.image,
    required this.rarity,
    required this.isWeapon,
    required this.materials,
    required this.isActive,
    required this.showMaterialUsage,
    required this.useMaterialsFromInventory,
    this.elementType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final cardColor = elementType != null ? elementType!.getElementColorFromContext(context) : rarity.getRarityColors().last;
    return InkWell(
      borderRadius: Styles.mainCardBorderRadius,
      onTap: () => _editItem(context),
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: Styles.mainCardShape,
        elevation: Styles.cardTenElevation,
        color: cardColor,
        child: ChildItemDisabled(
          isDisabled: !isActive,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FadeInImage(
                fit: BoxFit.cover,
                placeholderFit: BoxFit.cover,
                alignment: Alignment.topCenter,
                placeholder: MemoryImage(kTransparentImage),
                image: FileImage(File(image)),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: Styles.commonCardBoxDecoration,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: name,
                        child: Container(
                          margin: Styles.edgeInsetAll5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (useMaterialsFromInventory)
                                const Flexible(
                                  child: Icon(Icons.inventory, color: Colors.white),
                                ),
                              Expanded(
                                child: Text(
                                  name,
                                  style: theme.textTheme.titleLarge!.copyWith(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        s.materials,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall!.copyWith(color: Colors.white),
                      ),
                      Container(
                        height: 80,
                        padding: const EdgeInsets.only(bottom: 5),
                        child: ListView.builder(
                          itemCount: materials.length,
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, index) {
                            final item = materials[index];

                            return Container(
                              margin: Styles.edgeInsetHorizontal10,
                              child: MaterialItem(
                                itemKey: item.key,
                                type: item.type,
                                image: item.image,
                                requiredQuantity: item.requiredQuantity,
                                usedQuantity: item.usedQuantity,
                                remainingQuantity: item.remainingQuantity,
                                textColor: Colors.white,
                                sessionKey: sessionKey,
                                showMaterialUsage: showMaterialUsage,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editItem(BuildContext context) async {
    final currentData = context.read<CalculatorAscMaterialsBloc>().getItem(index);

    context.read<CalculatorAscMaterialsItemBloc>().add(
          CalculatorAscMaterialsItemEvent.loadWith(
            key: itemKey,
            isCharacter: currentData.isCharacter,
            currentLevel: currentData.currentLevel,
            desiredLevel: currentData.desiredLevel,
            skills: currentData.skills,
            currentAscensionLevel: currentData.currentAscensionLevel,
            desiredAscensionLevel: currentData.desiredAscensionLevel,
            useMaterialsFromInventory: currentData.useMaterialsFromInventory,
          ),
        );

    await ModalBottomSheetUtils.showAppModalBottomSheet(
      context,
      EndDrawerItemType.calculatorAscMaterialsEdit,
      args: AddEditItemBottomSheet.buildNavigationArgsToEditItem(sessionKey, index, isActive, isAWeapon: isWeapon),
    );
  }
}
