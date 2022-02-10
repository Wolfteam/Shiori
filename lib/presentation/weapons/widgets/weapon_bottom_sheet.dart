import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
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
import 'package:shiori/presentation/shared/weapons_button_bar.dart';

final _ignoredSubStats = [
  StatType.atk,
  StatType.critAtk,
  StatType.critRate,
  StatType.physDmgPercentage,
  StatType.hp,
  StatType.electroDmgBonusPercentage,
  StatType.cryoDmgBonusPercentage,
  StatType.pyroDmgBonusPercentage,
  StatType.hydroDmgBonusPercentage,
  StatType.geoDmgBonusPercentage,
  StatType.anemoDmgBonusPercentage,
  StatType.healingBonusPercentage,
  StatType.def,
];

const _areWeaponTypesEnabledKey = 'areWeaponTypesEnabled';

class WeaponBottomSheet extends StatelessWidget {
  final bool areWeaponTypesEnabled;

  const WeaponBottomSheet({
    Key? key,
    required this.areWeaponTypesEnabled,
  }) : super(key: key);

  static Map<String, dynamic> buildNavigationArgs({bool areWeaponTypesEnabled = true}) =>
      <String, dynamic>{_areWeaponTypesEnabledKey: areWeaponTypesEnabled};

  static Widget getWidgetFromArgs(BuildContext context, Map<String, dynamic> args) {
    assert(args.isNotEmpty);
    final areWeaponTypesEnabled = args[_areWeaponTypesEnabledKey] as bool;
    return WeaponBottomSheet(areWeaponTypesEnabled: areWeaponTypesEnabled);
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
        child: BlocBuilder<WeaponsBloc, WeaponsState>(
          builder: (context, state) => state.map(
            loading: (_) => const Loading(),
            loaded: (state) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(s.type),
                WeaponsButtonBar(
                  selectedValues: state.tempWeaponTypes,
                  enabled: areWeaponTypesEnabled,
                  onClick: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.weaponTypeChanged(v)),
                ),
                Text(s.rarity),
                RarityRating(
                  rarity: state.rarity,
                  onRated: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.rarityChanged(v)),
                ),
                Text(s.others),
                _OtherFilters(
                  tempWeaponFilterType: state.tempWeaponFilterType,
                  tempWeaponLocationType: state.tempWeaponLocationType,
                  tempWeaponSubStatType: state.tempWeaponSubStatType,
                  tempSortDirectionType: state.tempSortDirectionType,
                ),
                _ButtonBar(isResetEnabled: areWeaponTypesEnabled),
              ],
            ),
          ),
        ),
      );
    }

    return BlocBuilder<WeaponsBloc, WeaponsState>(
      builder: (ctx, state) => state.map(
        loading: (_) => const Loading(useScaffold: false),
        loaded: (state) => RightBottomSheet(
          bottom: _ButtonBar(isResetEnabled: areWeaponTypesEnabled),
          children: [
            Container(margin: Styles.endDrawerFilterItemMargin, child: Text(s.type)),
            WeaponsButtonBar(
              selectedValues: state.tempWeaponTypes,
              iconSize: 40,
              enabled: areWeaponTypesEnabled,
              onClick: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.weaponTypeChanged(v)),
            ),
            Container(margin: Styles.endDrawerFilterItemMargin, child: Text(s.rarity)),
            RarityRating(
              rarity: state.rarity,
              size: 40,
              onRated: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.rarityChanged(v)),
            ),
            Container(margin: Styles.endDrawerFilterItemMargin, child: Text(s.others)),
            _OtherFilters(
              tempWeaponFilterType: state.tempWeaponFilterType,
              tempWeaponLocationType: state.tempWeaponLocationType,
              tempWeaponSubStatType: state.tempWeaponSubStatType,
              tempSortDirectionType: state.tempSortDirectionType,
              forEndDrawer: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherFilters extends StatelessWidget {
  final ItemLocationType? tempWeaponLocationType;
  final StatType? tempWeaponSubStatType;
  final WeaponFilterType tempWeaponFilterType;
  final SortDirectionType tempSortDirectionType;
  final bool forEndDrawer;

  const _OtherFilters({
    Key? key,
    required this.tempWeaponLocationType,
    required this.tempWeaponSubStatType,
    required this.tempWeaponFilterType,
    required this.tempSortDirectionType,
    this.forEndDrawer = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return CommonButtonBar(
      alignment: WrapAlignment.spaceEvenly,
      children: [
        ItemPopupMenuFilterWithAllValue(
          tooltipText: s.location,
          onAllOrValueSelected: (v) =>
              context.read<WeaponsBloc>().add(WeaponsEvent.weaponLocationTypeChanged(v != null ? ItemLocationType.values[v] : null)),
          selectedValue: tempWeaponLocationType?.index,
          values: ItemLocationType.values.where((el) => el != ItemLocationType.na).map((e) => e.index).toList(),
          itemText: (val, _) => s.translateItemLocationType(ItemLocationType.values[val]),
          icon: Icon(Icons.location_pin, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, false)),
        ),
        ItemPopupMenuFilterWithAllValue(
          tooltipText: s.secondaryState,
          onAllOrValueSelected: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.weaponSubStatTypeChanged(v != null ? StatType.values[v] : null)),
          selectedValue: tempWeaponSubStatType?.index,
          values: StatType.values.where((el) => !_ignoredSubStats.contains(el)).map((e) => e.index).toList(),
          itemText: (val, _) => s.translateStatTypeWithoutValue(StatType.values[val]),
          icon: Icon(Shiori.sliders_h, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, false)),
        ),
        ItemPopupMenuFilter<WeaponFilterType>(
          tooltipText: s.sortBy,
          onSelected: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.weaponFilterTypeChanged(v)),
          selectedValue: tempWeaponFilterType,
          values: WeaponFilterType.values,
          itemText: (val, _) => s.translateWeaponFilterType(val),
          icon: Icon(Icons.filter_list, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, true)),
        ),
        SortDirectionPopupMenuFilter(
          selectedSortDirection: tempSortDirectionType,
          onSelected: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.sortDirectionTypeChanged(v)),
          icon: Icon(Icons.sort, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, true)),
        )
      ],
    );
  }
}

class _ButtonBar extends StatelessWidget {
  final bool isResetEnabled;

  const _ButtonBar({
    Key? key,
    required this.isResetEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return CommonButtonBar(
      children: <Widget>[
        OutlinedButton(
          onPressed: () {
            context.read<WeaponsBloc>().add(const WeaponsEvent.cancelChanges());
            Navigator.pop(context);
          },
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        OutlinedButton(
          onPressed: !isResetEnabled
              ? null
              : () {
                  context.read<WeaponsBloc>().add(const WeaponsEvent.resetFilters());
                  Navigator.pop(context);
                },
          child: Text(s.reset, style: TextStyle(color: theme.primaryColor)),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<WeaponsBloc>().add(const WeaponsEvent.applyFilterChanges());
            Navigator.pop(context);
          },
          child: Text(s.ok),
        )
      ],
    );
  }
}
