import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/material/material_page.dart' as mp;
import 'package:shiori/presentation/shared/details/detail_horizontal_list.dart';
import 'package:shiori/presentation/shared/dialogs/item_common_with_name_dialog.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/images/square_item_image.dart';
import 'package:shiori/presentation/shared/styles.dart';
import 'package:shiori/presentation/shared/utils/size_utils.dart';

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

class DetailMaterialsSliderColumn extends StatefulWidget {
  final Color color;
  final List<MaterialsData> data;

  const DetailMaterialsSliderColumn({
    required this.color,
    required this.data,
  });

  @override
  State<DetailMaterialsSliderColumn> createState() => _DetailMaterialsSliderColumnState();
}

class _DetailMaterialsSliderColumnState extends State<DetailMaterialsSliderColumn> {
  int _currentIndex = 0;
  late MaterialsData _current;

  @override
  void initState() {
    _current = widget.data.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${s.level}: ${_current.level}',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        FractionallySizedBox(
          widthFactor: 0.8,
          child: SliderTheme(
            data: SliderThemeData.fromPrimaryColors(
              primaryColor: widget.color,
              primaryColorDark: widget.color,
              primaryColorLight: widget.color,
              valueIndicatorTextStyle: theme.textTheme.bodySmall!,
            ).copyWith(
              overlayShape: SliderComponentShape.noOverlay,
              trackHeight: 5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _currentIndex.toDouble(),
              onChanged: (val) => _onAddOrRemove(val.toInt()),
              label: '${s.level}: ${_current.level}',
              max: widget.data.length - 1,
              activeColor: widget.color,
              divisions: widget.data.length - 1,
            ),
          ),
        ),
        DetailHorizontalListView(
          onTap: (key) => mp.MaterialPage.route(key, context),
          items: _current.materials.map((e) => ItemCommonWithName(e.key, e.image, e.iconImage, 'x ${e.quantity}')).toList(),
        ),
        DetailHorizontalListButton(
          color: widget.color,
          onTap: () => showDialog(
            context: context,
            builder: (context) => _SeeAllMaterialsDialog(
              color: widget.color,
              title: s.materials,
              data: widget.data,
            ),
          ),
        ),
      ],
    );
  }

  void _onAddOrRemove(int index) {
    setState(() {
      _currentIndex = index;
      _current = widget.data[index];
    });
  }
}

class _SeeAllMaterialsDialog extends StatelessWidget {
  final Color color;
  final String title;
  final List<MaterialsData> data;

  const _SeeAllMaterialsDialog({
    required this.color,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    final theme = Theme.of(context);
    final int count = data.sum((x) => x.materials.length);
    return AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: mq.getDialogBoxConstraints(count),
        child: GroupedListView<MaterialsData, int>(
          elements: data,
          groupBy: (item) => item.level,
          groupSeparatorBuilder: (level) => Container(
            color: theme.colorScheme.secondary.withOpacity(0.5),
            padding: Styles.edgeInsetAll5,
            child: Text('${s.level}: $level', style: theme.textTheme.titleMedium),
          ),
          itemBuilder: (context, element) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: element.materials
                .map(
                  (item) => InkWell(
                    onTap: () => mp.MaterialPage.route(item.key, context),
                    child: Container(
                      margin: Styles.edgeInsetVertical5,
                      child: Row(
                        children: [
                          AbsorbPointer(
                            child: SquareItemImage(
                              image: item.iconImage,
                              size: SizeUtils.getSizeForSquareImages(context, smallImage: true).height,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: Styles.edgeInsetHorizontal10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    item.name,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                  Text(
                                    '${s.quantity}: ${item.quantity}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(s.ok),
        ),
      ],
    );
  }
}

class DetailMaterialsHorizontalListColumn extends StatelessWidget {
  final Color color;
  final String title;
  final List<ItemCommonWithQuantityAndName> items;

  const DetailMaterialsHorizontalListColumn({
    required this.color,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailHorizontalListView(
          onTap: (key) => mp.MaterialPage.route(key, context),
          items: items.map((e) => ItemCommonWithName(e.key, e.image, e.iconImage, 'x ${e.quantity}')).toList(),
        ),
        DetailHorizontalListButton(
          color: color,
          title: s.seeAll,
          onTap: () => showDialog(
            context: context,
            builder: (context) => ItemCommonWithNameDialog.quantity(
              title: title,
              itemsWithQuantity: items,
              onTap: (key) => mp.MaterialPage.route(key, context),
            ),
          ),
        ),
      ],
    );
  }
}
