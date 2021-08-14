import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
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
import 'package:genshindb/presentation/shared/weapons_button_bar.dart';
import 'package:responsive_builder/responsive_builder.dart';

final _ignoredSubStats = [
  StatType.atk,
  StatType.critAtk,
  StatType.critRate,
  StatType.physDmgBonusPercentage,
  StatType.hp,
  StatType.electroDmgBonusPercentage,
  StatType.cryoDmgBonusPercentage,
  StatType.pyroDmgBonusPercentage,
  StatType.hydroDmgBonusPercentage,
  StatType.geoDmgBonusPercentage,
  StatType.anemoDmgBonusPercentage,
  StatType.healingBonusPercentage,
];

class WeaponBottomSheet extends StatelessWidget {
  const WeaponBottomSheet({Key? key}) : super(key: key);

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
                const _ButtonBar(),
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
          bottom: const _ButtonBar(),
          children: [
            Container(margin: Styles.endDrawerFilterItemMargin, child: Text(s.type)),
            WeaponsButtonBar(
              selectedValues: state.tempWeaponTypes,
              iconSize: 40,
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
  final ItemLocationType tempWeaponLocationType;
  final StatType tempWeaponSubStatType;
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
        ItemPopupMenuFilter<ItemLocationType>(
          tooltipText: s.location,
          onSelected: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.weaponLocationTypeChanged(v)),
          selectedValue: tempWeaponLocationType,
          values: ItemLocationType.values.where((el) => el != ItemLocationType.na).toList(),
          itemText: (val) => s.translateItemLocationType(val),
          icon: Icon(Icons.location_pin, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, false)),
        ),
        ItemPopupMenuFilter<StatType>(
          tooltipText: s.secondaryState,
          onSelected: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.weaponSubStatTypeChanged(v)),
          selectedValue: tempWeaponSubStatType,
          values: StatType.values.where((el) => !_ignoredSubStats.contains(el)).toList(),
          itemText: (val) => s.translateStatTypeWithoutValue(val),
          icon: Icon(GenshinDb.sliders_h, size: Styles.getIconSizeForItemPopupMenuFilter(forEndDrawer, false)),
        ),
        ItemPopupMenuFilter<WeaponFilterType>(
          tooltipText: s.sortBy,
          onSelected: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.weaponFilterTypeChanged(v)),
          selectedValue: tempWeaponFilterType,
          values: WeaponFilterType.values,
          itemText: (val) => s.translateWeaponFilterType(val),
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
  const _ButtonBar({Key? key}) : super(key: key);

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
          onPressed: () {
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
