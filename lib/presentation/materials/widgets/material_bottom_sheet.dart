import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/enums/material_type.dart' as mat;
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/common_bottom_sheet.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/genshin_db_icons.dart';
import 'package:genshindb/presentation/shared/item_popupmenu_filter.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/rarity_rating.dart';
import 'package:genshindb/presentation/shared/sort_direction_popupmenu_filter.dart';
import 'package:genshindb/presentation/shared/styles.dart';

class MaterialBottomSheet extends StatelessWidget {
  final ignoredSubStats = [
    mat.MaterialType.others,
    mat.MaterialType.expWeapon,
    mat.MaterialType.weaponPrimary,
  ];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return CommonBottomSheet(
      titleIcon: GenshinDb.filter,
      title: s.filters,
      showOkButton: false,
      showCancelButton: false,
      child: BlocBuilder<MaterialsBloc, MaterialsState>(
        builder: (context, state) => state.map(
          loading: (_) => const Loading(),
          loaded: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(s.rarity),
              RarityRating(
                rarity: state.rarity,
                onRated: (v) => context.read<MaterialsBloc>().add(MaterialsEvent.rarityChanged(v)),
              ),
              Text(s.others),
              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ItemPopupMenuFilter<mat.MaterialType>(
                    tooltipText: s.secondaryState,
                    onSelected: (v) => context.read<MaterialsBloc>().add(MaterialsEvent.typeChanged(v)),
                    selectedValue: state.tempType,
                    values: mat.MaterialType.values.where((el) => !ignoredSubStats.contains(el)).toList(),
                    itemText: (val) => s.translateMaterialType(val),
                    icon: const Icon(GenshinDb.sliders_h, size: 18),
                  ),
                  ItemPopupMenuFilter<MaterialFilterType>(
                    tooltipText: s.sortBy,
                    onSelected: (v) => context.read<MaterialsBloc>().add(MaterialsEvent.filterTypeChanged(v)),
                    selectedValue: state.tempFilterType,
                    values: MaterialFilterType.values,
                    itemText: (val) => s.translateMaterialFilterType(val),
                  ),
                  SortDirectionPopupMenuFilter(
                    selectedSortDirection: state.tempSortDirectionType,
                    onSelected: (v) => context.read<MaterialsBloc>().add(MaterialsEvent.sortDirectionTypeChanged(v)),
                  )
                ],
              ),
              ButtonBar(
                buttonPadding: Styles.edgeInsetHorizontal10,
                children: <Widget>[
                  OutlinedButton(
                    onPressed: () {
                      context.read<MaterialsBloc>().add(const MaterialsEvent.cancelChanges());
                      Navigator.pop(context);
                    },
                    child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      context.read<MaterialsBloc>().add(const MaterialsEvent.resetFilters());
                      Navigator.pop(context);
                    },
                    child: Text(s.reset, style: TextStyle(color: theme.primaryColor)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MaterialsBloc>().add(const MaterialsEvent.applyFilterChanges());
                      Navigator.pop(context);
                    },
                    child: Text(s.ok),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
