import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/child_item_disabled.dart';
import 'package:genshindb/presentation/shared/extensions/rarity_extensions.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:genshindb/presentation/shared/utils/modal_bottom_sheet_utils.dart';
import 'package:transparent_image/transparent_image.dart';

import 'add_edit_item_bottom_sheet.dart';
import 'material_item.dart';

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

  const ItemCard({
    Key? key,
    required this.sessionKey,
    required this.index,
    required this.itemKey,
    required this.name,
    required this.image,
    required this.rarity,
    required this.isWeapon,
    required this.materials,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final cardColor = rarity.getRarityColors().last;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInImage(
                height: 280,
                placeholder: MemoryImage(kTransparentImage),
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                    // topLeft: Radius.circular(20),
                    // topRight: Radius.circular(20),
                  ),
                  color: Colors.black.withOpacity(0.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: name,
                      child: Container(
                        margin: Styles.edgeInsetAll5,
                        child: Text(
                          name,
                          style: theme.textTheme.headline6!.copyWith(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Text(
                      s.materials,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.subtitle2!.copyWith(color: Colors.white),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 12, right: 5, left: 5),
                      child: SizedBox(
                        height: 90,
                        child: ListView.builder(
                          itemCount: materials.length,
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, index) {
                            final item = materials[index];
                            return MaterialItem(
                              type: item.materialType,
                              image: item.fullImagePath,
                              quantity: item.quantity,
                              textColor: Colors.white,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
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
