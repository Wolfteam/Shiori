import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/models/materials/material_card_model.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/material/material_page.dart' as mp;
import 'package:genshindb/presentation/shared/extensions/rarity_extensions.dart';
import 'package:genshindb/presentation/shared/gradient_card.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:transparent_image/transparent_image.dart';

const double defaultWidth = 70;
const double defaultHeight = 60;

class MaterialCard extends StatelessWidget {
  final String keyName;
  final String name;
  final String image;
  final int rarity;
  final double imgWidth;
  final double imgHeight;
  final bool withoutDetails;
  final bool withElevation;
  final int quantity;
  final bool isInSelectionMode;
  final bool isInQuantityMode;

  const MaterialCard({
    Key key,
    @required this.keyName,
    @required this.name,
    @required this.image,
    @required this.rarity,
    this.imgWidth = defaultWidth,
    this.imgHeight = defaultHeight,
    this.withElevation = true,
    this.isInSelectionMode = false,
  })  : withoutDetails = false,
        isInQuantityMode = false,
        quantity = -1,
        super(key: key);

  MaterialCard.item({
    Key key,
    @required MaterialCardModel item,
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
        super(key: key);

  const MaterialCard.withoutDetails({
    Key key,
    @required this.keyName,
    @required this.image,
    @required this.rarity,
    this.isInSelectionMode = false,
  })  : name = null,
        imgWidth = defaultWidth,
        imgHeight = defaultHeight,
        withoutDetails = true,
        withElevation = false,
        isInQuantityMode = false,
        quantity = -1,
        super(key: key);

  MaterialCard.quantity({
    Key key,
    @required MaterialCardModel item,
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
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: Styles.mainCardBorderRadius,
      onTap: () => _gotoMaterialPage(context),
      child: GradientCard(
        clipBehavior: Clip.hardEdge,
        shape: Styles.mainCardShape,
        elevation: withElevation ? Styles.cardTenElevation : 0,
        gradient: rarity.getRarityGradient(),
        child: Padding(
          padding: withoutDetails ? Styles.edgeInsetAll5 : Styles.edgeInsetAll10,
          child: Column(
            children: [
              FadeInImage(
                width: imgWidth,
                height: imgHeight,
                placeholder: MemoryImage(kTransparentImage),
                image: AssetImage(image),
              ),
              if (quantity >= 0 && isInQuantityMode) Text('$quantity', style: theme.textTheme.subtitle2),
              if (!withoutDetails)
                Center(
                  child: Tooltip(
                    message: name,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
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

    final bloc = context.read<MaterialBloc>();
    bloc.add(MaterialEvent.loadFromName(key: keyName));
    final route = MaterialPageRoute(builder: (c) => mp.MaterialPage());
    await Navigator.push(context, route);
    bloc.pop();
  }

  Future<void> _showQuantityPickerDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final s = S.of(context);
    final newValue = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return NumberPickerDialog.integer(
          minValue: 0,
          //TODO: CHANGE THIS
          maxValue: 2000,
          title: Text(s.quantity),
          initialIntegerValue: quantity,
          infiniteLoop: true,
          cancelWidget: Text(s.cancel),
          confirmWidget: Text(s.ok, style: TextStyle(color: theme.primaryColor)),
        );
      },
    );

    if (newValue == null) {
      return;
    }

    context.read<InventoryBloc>().add(InventoryEvent.updateMaterial(key: keyName, quantity: newValue));
  }
}
