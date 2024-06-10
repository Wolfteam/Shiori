import 'package:flutter/material.dart';
import 'package:shiori/domain/assets.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/home/widgets/card_description.dart';
import 'package:shiori/presentation/home/widgets/card_item.dart';
import 'package:shiori/presentation/materials/materials_page.dart';

class MaterialsCard extends StatelessWidget {
  final bool iconToTheLeft;

  const MaterialsCard({
    super.key,
    required this.iconToTheLeft,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return CardItem(
      title: s.materials,
      iconToTheLeft: iconToTheLeft,
      onClick: _gotoMaterialsPage,
      icon: Image.asset(Assets.bagIconPath, width: 60, height: 60, color: theme.colorScheme.primary),
      children: [
        CardDescription(text: s.checkAllMaterials),
      ],
    );
  }

  Future<void> _gotoMaterialsPage(BuildContext context) async {
    final route = MaterialPageRoute(builder: (_) => const MaterialsPage());
    await Navigator.push(context, route);
    await route.completed;
  }
}
