import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../../bloc/bloc.dart';
import '../../../common/extensions/rarity_extensions.dart';
import '../../../common/styles.dart';
import '../../../generated/l10n.dart';
import '../../../models/items/item_ascention_material_model.dart';
import 'add_edit_item_bottom_sheet.dart';
import 'material_item.dart';

class ItemCard extends StatelessWidget {
  final int index;
  final String itemKey;
  final String name;
  final String image;
  final int rarity;
  final bool isWeapon;
  final List<ItemAscentionMaterialModel> materials;

  const ItemCard({
    Key key,
    @required this.index,
    @required this.itemKey,
    @required this.name,
    @required this.image,
    @required this.rarity,
    @required this.isWeapon,
    @required this.materials,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return InkWell(
      onTap: () => _editItem(context),
      child: Card(
        shape: Styles.mainCardShape,
        elevation: Styles.cardTenElevation,
        color: rarity.getRarityColors().last,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInImage(
              height: 280,
              placeholder: MemoryImage(kTransparentImage),
              image: AssetImage(image),
              fit: BoxFit.fill,
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.white,
                          onPressed: () => _editItem(context),
                        ),
                      ),
                      Flexible(
                        child: Tooltip(
                          message: name,
                          child: Text(
                            name,
                            style: theme.textTheme.headline6.copyWith(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Flexible(
                        child: IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.white,
                          onPressed: () => _removeItem(context),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    s.materials,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.subtitle2.copyWith(color: Colors.white),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      height: 80,
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
              skills: currentData.skills),
        );

    await showModalBottomSheet<bool>(
      context: context,
      shape: Styles.modalBottomSheetShape,
      isDismissible: true,
      isScrollControlled: true,
      builder: (_) => AddEditItemBottomSheet.toEditItem(index: index, isAWeapon: isWeapon),
    );
  }

  void _removeItem(BuildContext context) => context.read<CalculatorAscMaterialsBloc>().add(CalculatorAscMaterialsEvent.removeItem(index: index));
}
