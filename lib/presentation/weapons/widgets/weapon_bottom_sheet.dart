import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/enums/enums.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/common_bottom_sheet.dart';
import 'package:genshindb/presentation/shared/extensions/i18n_extensions.dart';
import 'package:genshindb/presentation/shared/genshin_db_icons.dart';
import 'package:genshindb/presentation/shared/item_popupmenu_filter.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/rarity_rating.dart';
import 'package:genshindb/presentation/shared/sort_direction_popupmenu_filter.dart';
import 'package:genshindb/presentation/shared/styles.dart';
import 'package:genshindb/presentation/shared/weapons_button_bar.dart';

class WeaponBottomSheet extends StatelessWidget {
  final ignoredSubStats = [
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

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
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
              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ItemPopupMenuFilter<ItemLocationType>(
                    tooltipText: s.location,
                    onSelected: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.weaponLocationTypeChanged(v)),
                    selectedValue: state.tempWeaponLocationType,
                    values: ItemLocationType.values.where((el) => el != ItemLocationType.na).toList(),
                    itemText: (val) => s.translateItemLocationType(val),
                    icon: const Icon(Icons.location_pin, size: 18),
                  ),
                  ItemPopupMenuFilter<StatType>(
                    tooltipText: s.secondaryState,
                    onSelected: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.weaponSubStatTypeChanged(v)),
                    selectedValue: state.tempWeaponSubStatType,
                    values: StatType.values.where((el) => !ignoredSubStats.contains(el)).toList(),
                    itemText: (val) => s.translateStatTypeWithoutValue(val),
                    icon: const Icon(GenshinDb.sliders_h, size: 18),
                  ),
                  ItemPopupMenuFilter<WeaponFilterType>(
                    tooltipText: s.sortBy,
                    onSelected: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.weaponFilterTypeChanged(v)),
                    selectedValue: state.tempWeaponFilterType,
                    values: WeaponFilterType.values,
                    itemText: (val) => s.translateWeaponFilterType(val),
                  ),
                  SortDirectionPopupMenuFilter(
                    selectedSortDirection: state.tempSortDirectionType,
                    onSelected: (v) => context.read<WeaponsBloc>().add(WeaponsEvent.sortDirectionTypeChanged(v)),
                  )
                ],
              ),
              ButtonBar(
                buttonPadding: Styles.edgeInsetHorizontal10,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
