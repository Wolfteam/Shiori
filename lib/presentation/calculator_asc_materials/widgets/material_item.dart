import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart' as app;
import 'package:genshindb/domain/utils/currency_utils.dart';
import 'package:genshindb/presentation/material/material_page.dart' as mp;

class MaterialItem extends StatelessWidget {
  final app.MaterialType type;
  final String image;
  final int quantity;
  final Color textColor;

  const MaterialItem({
    Key key,
    @required this.type,
    @required this.image,
    @required this.quantity,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Image.asset(image),
          iconSize: 45,
          splashRadius: 30,
          constraints: const BoxConstraints(),
          onPressed: () => _gotoMaterialPage(context),
        ),
        if (quantity > 0)
          Text(
            type == app.MaterialType.currency ? CurrencyUtils.formatNumber(quantity) : '$quantity',
            textAlign: TextAlign.center,
            style: textColor != null ? theme.textTheme.subtitle2.copyWith(color: textColor) : theme.textTheme.subtitle2,
          ),
        if (quantity == 0) const Icon(Icons.check, color: Colors.green, size: 18),
      ],
    );
  }

  Future<void> _gotoMaterialPage(BuildContext context) async {
    final bloc = context.read<MaterialBloc>();
    bloc.add(MaterialEvent.loadFromImg(image: image));
    final route = MaterialPageRoute(builder: (c) => mp.MaterialPage());
    await Navigator.push(context, route);
    bloc.pop();
  }
}
