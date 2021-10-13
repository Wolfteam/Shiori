import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/home/widgets/card_description.dart';
import 'package:shiori/presentation/materials/materials_page.dart';

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
        CardDescription(text: s.checkAllMaterials),
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
