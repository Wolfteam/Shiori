import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/material/material_page.dart' as mp;
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/material_item_button.dart';

class MaterialsData {
  final int level;
  final List<ItemCommonWithQuantityAndName> materials;

  MaterialsData({required this.level, required this.materials});

  MaterialsData.fromAscensionMaterial(CharacterAscensionModel e)
      : level = e.level,
        materials = e.materials;

  MaterialsData.fromTalentAscensionMaterial(CharacterTalentAscensionModel e)
      : level = e.level,
        materials = e.materials;

  MaterialsData.fromWeaponAscensionModel(WeaponAscensionModel e)
      : level = e.level,
        materials = e.materials;
}

class AscensionMaterialsDialog extends StatelessWidget {
  final List<MaterialsData> data;

  const AscensionMaterialsDialog({required this.data});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    return AlertDialog(
      title: Text(s.materials),
      content: SizedBox(
        width: mq.getWidthForDialogs(),
        child: ListView.separated(
          itemCount: data.length,
          itemBuilder: (context, index) => AscensionMaterialsListTile(data: data[index]),
          separatorBuilder: (context, index) => const Divider(),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.ok),
        ),
      ],
    );
  }
}

class AscensionMaterialsListTile extends StatelessWidget {
  final MaterialsData data;

  const AscensionMaterialsListTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ListTile(
      title: Text('${s.level}: ${data.level}'),
      contentPadding: EdgeInsets.zero,
      subtitle: AscensionMaterialsTable(materials: data.materials),
    );
  }
}

class AscensionMaterialsTable extends StatelessWidget {
  final List<ItemCommonWithQuantityAndName> materials;

  const AscensionMaterialsTable({required this.materials});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.titleSmall;
    return DataTable(
      showCheckboxColumn: false,
      dividerThickness: 0.00000000001,
      headingTextStyle: headerStyle,
      columns: <DataColumn>[
        DataColumn(
          label: Expanded(
            child: Text(s.materials),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(s.quantity),
          ),
        ),
      ],
      rows: <DataRow>[
        ...materials.map(
          (m) => DataRow(
            onSelectChanged: (selected) => mp.MaterialPage.route(m.key, context),
            cells: [
              DataCell(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialItemButton(
                      itemKey: m.key,
                      image: m.image,
                      size: 36,
                      useButton: false,
                    ),
                    Expanded(
                      child: Text(
                        m.name,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(Text('${m.quantity}')),
            ],
          ),
        ),
      ],
    );
  }
}