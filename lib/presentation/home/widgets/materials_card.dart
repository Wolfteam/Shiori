import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/assets.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/materials/materials_page.dart';

import 'card_item.dart';

class MaterialsCard extends StatelessWidget {
  final bool iconToTheLeft;

  const MaterialsCard({
    Key? key,
    required this.iconToTheLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return CardItem(
      title: s.materials,
      iconToTheLeft: iconToTheLeft,
      onClick: _gotoMaterialsPage,
      icon: Image.asset(Assets.getOtherMaterialPath('bag.png'), width: 60, height: 60, color: theme.accentColor),
      children: [
        Text(
          s.checkAllMaterials,
          style: theme.textTheme.subtitle2,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _gotoMaterialsPage(BuildContext context) async {
    context.read<MaterialsBloc>().add(const MaterialsEvent.init());
    final route = MaterialPageRoute(builder: (_) => const MaterialsPage());
    await Navigator.push(context, route);
    await route.completed;
    context.read<MaterialsBloc>().add(const MaterialsEvent.close());
  }
}
