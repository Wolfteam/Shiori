import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/domain/enums/material_type.dart' as mat;
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/bottom_sheets/common_bottom_sheet.dart';
import 'package:genshindb/presentation/shared/bottom_sheets/common_button_bar.dart';
import 'package:genshindb/presentation/shared/bottom_sheets/right_bottom_sheet.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/genshin_db_icons.dart';
import 'package:genshindb/presentation/shared/item_popupmenu_filter.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/rarity_rating.dart';
import 'package:genshindb/presentation/shared/sort_direction_popupmenu_filter.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:responsive_builder/responsive_builder.dart';

final _ignoredSubStats = [
  mat.MaterialType.others,
  mat.MaterialType.expWeapon,
  mat.MaterialType.weaponPrimary,
];

class MaterialBottomSheet extends StatelessWidget {
  const MaterialBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final forEndDrawer = getDeviceType(MediaQuery.of(context).size) != DeviceScreenType.mobile;

    if (!forEndDrawer) {
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
                _OtherFilters(
                  tempFilterType: state.tempFilterType,
                  tempSortDirectionType: state.tempSortDirectionType,
                  tempType: state.tempType,
                  forEndDrawer: forEndDrawer,
                ),
                const _ButtonBar(),
              ],
            ),
          ),
        ),
      );
    }

    return BlocBuilder<MaterialsBloc, MaterialsState>(
      builder: (ctx, state) => state.map(
        loading: (_) => const Loading(useScaffold: false),
        loaded: (state) => RightBottomSheet(
          bottom: const _ButtonBar(),
          children: [
            Container(margin: Styles.endDrawerFilterItemMargin, child: Text(s.rarity)),
            RarityRating(
              rarity: state.rarity,
              onRated: (v) => context.read<MaterialsBloc>().add(MaterialsEvent.rarityChanged(v)),
            ),
            Container(margin: Styles.endDrawerFilterItemMargin, child: Text(s.others)),
            _OtherFilters(
              tempFilterType: state.tempFilterType,
              tempSortDirectionType: state.tempSortDirectionType,
              tempType: state.tempType,
              forEndDrawer: forEndDrawer,
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherFilters extends StatelessWidget {
  final mat.MaterialType tempType;
  final MaterialFilterType tempFilterType;
  final SortDirectionType tempSortDirectionType;
  final bool forEndDrawer;

  const _OtherFilters({
    Key? key,
    required this.tempType,
    required this.tempFilterType,
    required this.tempSortDirectionType,
    required this.forEndDrawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return CommonButtonBar(
      alignment: WrapAlignment.spaceEvenly,
      children: [
        ItemPopupMenuFilter<mat.MaterialType>(
          tooltipText: s.secondaryState,
          onSelected: (v) => context.read<MaterialsBloc>().add(MaterialsEvent.typeChanged(v)),
          selectedValue: tempType,
          values: mat.MaterialType.values.where((el) => !_ignoredSubStats.contains(el)).toList(),
          itemText: (val) => s.translateMaterialType(val),
          icon: Icon(GenshinDb.sliders_h, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, false)),
        ),
        ItemPopupMenuFilter<MaterialFilterType>(
          tooltipText: s.sortBy,
          onSelected: (v) => context.read<MaterialsBloc>().add(MaterialsEvent.filterTypeChanged(v)),
          selectedValue: tempFilterType,
          values: MaterialFilterType.values,
          itemText: (val) => s.translateMaterialFilterType(val),
          icon: Icon(Icons.filter_list, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, true)),
        ),
        SortDirectionPopupMenuFilter(
          selectedSortDirection: tempSortDirectionType,
          onSelected: (v) => context.read<MaterialsBloc>().add(MaterialsEvent.sortDirectionTypeChanged(v)),
          icon: Icon(Icons.sort, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, true)),
        )
      ],
    );
  }
}

class _ButtonBar extends StatelessWidget {
  const _ButtonBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return CommonButtonBar(
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
    );
  }
}
