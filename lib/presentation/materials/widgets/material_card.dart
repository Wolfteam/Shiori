import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/models/materials/material_card_model.dart';
import 'package:genshindb/presentation/material/material_page.dart' as mp;
import 'package:genshindb/presentation/shared/extensions/rarity_extensions.dart';
import 'package:genshindb/presentation/shared/gradient_card.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:transparent_image/transparent_image.dart';

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

  const MaterialCard({
    Key key,
    @required this.keyName,
    @required this.name,
    @required this.image,
    @required this.rarity,
    this.imgWidth = 70,
    this.imgHeight = 60,
    this.withElevation = true,
  })  : withoutDetails = false,
        quantity = -1,
        super(key: key);

  MaterialCard.item({
    Key key,
    @required MaterialCardModel item,
    this.imgWidth = 70,
    this.imgHeight = 60,
    this.withElevation = true,
  })  : keyName = item.key,
        name = item.name,
        image = item.image,
        rarity = item.rarity,
        withoutDetails = false,
        quantity = -1,
        super(key: key);

  const MaterialCard.withoutDetails({
    Key key,
    @required this.keyName,
    @required this.image,
    @required this.rarity,
  })  : name = null,
        imgWidth = 70,
        imgHeight = 60,
        withoutDetails = true,
        withElevation = false,
        quantity = -1,
        super(key: key);

  const MaterialCard.quantity({
    Key key,
    @required this.keyName,
    @required this.image,
    @required this.rarity,
    @required this.quantity,
  })  : name = null,
        imgWidth = 70,
        imgHeight = 60,
        withoutDetails = true,
        withElevation = false,
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
              if (quantity >= 0) Text('$quantity', style: theme.textTheme.subtitle2),
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
    final bloc = context.read<MaterialBloc>();
    bloc.add(MaterialEvent.loadFromName(key: keyName));
    final route = MaterialPageRoute(builder: (c) => mp.MaterialPage());
    await Navigator.push(context, route);
    bloc.pop();
  }
}
