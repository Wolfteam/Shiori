import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/enums/material_type.dart' as mat;
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/bottom_sheets/common_bottom_sheet.dart';
import 'package:shiori/presentation/shared/bottom_sheets/common_button_bar.dart';
import 'package:shiori/presentation/shared/bottom_sheets/right_bottom_sheet.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/item_popupmenu_filter.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/rarity_rating.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';
import 'package:shiori/presentation/shared/sort_direction_popupmenu_filter.dart';
import 'package:shiori/presentation/shared/styles.dart';

final _ignoredSubStats = [
  mat.MaterialType.others,
  mat.MaterialType.expWeapon,
  mat.MaterialType.weaponPrimary,
];

class MaterialBottomSheet extends StatelessWidget {
  const MaterialBottomSheet({super.key});

  static Widget route(BuildContext context) {
    return BlocProvider.value(
      value: context.read<MaterialsBloc>(),
      child: const MaterialBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final forEndDrawer = getDeviceType(MediaQuery.of(context).size) != DeviceScreenType.mobile;

    if (!forEndDrawer) {
      return CommonBottomSheet(
        titleIcon: Shiori.filter,
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
  final mat.MaterialType? tempType;
  final MaterialFilterType tempFilterType;
  final SortDirectionType tempSortDirectionType;
  final bool forEndDrawer;

  const _OtherFilters({
    required this.tempType,
    required this.tempFilterType,
    required this.tempSortDirectionType,
    required this.forEndDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return CommonButtonBar(
      alignment: WrapAlignment.spaceEvenly,
      children: [
        ItemPopupMenuFilterWithAllValue(
          tooltipText: s.secondaryState,
          onAllOrValueSelected: (v) => context.read<MaterialsBloc>().add(MaterialsEvent.typeChanged(v != null ? mat.MaterialType.values[v] : null)),
          selectedValue: tempType?.index,
          values: mat.MaterialType.values.where((el) => !_ignoredSubStats.contains(el)).map((e) => e.index).toList(),
          itemText: (val, _) => s.translateMaterialType(mat.MaterialType.values[val]),
          icon: Icon(Shiori.sliders_h, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, false)),
        ),
        ItemPopupMenuFilter<MaterialFilterType>(
          tooltipText: s.sortBy,
          onSelected: (v) => context.read<MaterialsBloc>().add(MaterialsEvent.filterTypeChanged(v)),
          selectedValue: tempFilterType,
          values: MaterialFilterType.values,
          itemText: (val, _) => s.translateMaterialFilterType(val),
          icon: Icon(Icons.filter_list, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, true)),
        ),
        SortDirectionPopupMenuFilter(
          selectedSortDirection: tempSortDirectionType,
          onSelected: (v) => context.read<MaterialsBloc>().add(MaterialsEvent.sortDirectionTypeChanged(v)),
          icon: Icon(Icons.sort, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, true)),
        ),
      ],
    );
  }
}

class _ButtonBar extends StatelessWidget {
  const _ButtonBar();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return CommonButtonBar(
      children: <Widget>[
        TextButton(
          onPressed: () {
            context.read<MaterialsBloc>().add(const MaterialsEvent.cancelChanges());
            Navigator.pop(context);
          },
          child: Text(s.cancel),
        ),
        TextButton(
          onPressed: () {
            context.read<MaterialsBloc>().add(const MaterialsEvent.resetFilters());
            Navigator.pop(context);
          },
          child: Text(s.reset),
        ),
        FilledButton(
          onPressed: () {
            context.read<MaterialsBloc>().add(const MaterialsEvent.applyFilterChanges());
            Navigator.pop(context);
          },
          child: Text(s.ok),
        ),
      ],
    );
  }
}
